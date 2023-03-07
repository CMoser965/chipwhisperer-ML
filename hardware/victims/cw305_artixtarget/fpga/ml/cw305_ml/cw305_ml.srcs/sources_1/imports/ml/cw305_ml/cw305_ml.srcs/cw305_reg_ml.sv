/* 
ChipWhisperer Artix Target - Example of connections between example registers
and rest of system.

Copyright (c) 2020, NewAE Technology Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted without restriction. Note that modules within
the project may have additional restrictions, please carefully inspect
additional licenses.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those
of the authors and should not be interpreted as representing official policies,
either expressed or implied, of NewAE Technology Inc.
*/

`default_nettype none
`timescale 1ns / 1ps
`include "cw305_ml_defines.v"

module cw305_reg_aes #(
   parameter pADDR_WIDTH = 21,
   parameter pBYTECNT_SIZE = 7,
   parameter pDONE_EDGE_SENSITIVE = 1,
   parameter pIDENTIFY = 8'h2e,
   parameter pWEIGHTCNT = 16,
   parameter pINPUTCNT = 4,
   parameter pOUTPUTCNT = 4,
   parameter pBIASCNT = 1
)(

// Interface to cw305_usb_reg_fe:
   input  wire                                  usb_clk,
   input  wire                                  crypto_clk,
   input  wire                                  reset_i,
   input  wire [pADDR_WIDTH-pBYTECNT_SIZE-1:0]  reg_address,     // Address of register
   input  wire [pBYTECNT_SIZE-1:0]              reg_bytecnt,     // Current byte count
   output reg  [7:0]                            read_data,       //
   input  wire [7:0]                            write_data,      //
   input  wire                                  reg_read,        // Read flag. One clock cycle AFTER this flag is high
                                                                 // valid data must be present on the read_data bus
   input  wire                                  reg_write,       // Write flag. When high on rising edge valid data is
                                                                 // present on write_data
   input  wire                                  reg_addrvalid,   // Address valid flag

// from top:
   input  wire                                  exttrigger_in,

// register inputs:
  input  wire [pPT_WIDTH-1:0]                  I_textout,
  input  wire [pCT_WIDTH-1:0]                  I_cipherout,
  input  wire                                  I_ready,  /* Crypto core ready. Tie to '1' if not used. */
  input  wire                                  I_done,   /* Crypto done. Can be high for one crypto_clk cycle or longer. */
  input  wire                                  I_busy,   /* Crypto busy. */ 
   // I_busy: Rising edge sets off power trace capture

// register outputs:
   output reg  [4:0]                            O_clksettings,
   output reg                                   O_user_led,
   output wire [pOUTPUTCNT-1:0]                 O_res
);

reg  [7:0]                   reg_read_data;
reg [pINPUTCNT-1:0]          reg_neural_input_textin;
reg [pWEIGHTCNT-1:0]         reg_neural_weight_textin;
reg [pBIASCNT-1:0]           reg_neural_bias_textin;
reg [pOUTPUTCNT-1:0]         reg_neural_output_textin;

reg [pINPUTCNT-1:0]          reg_neural_input_textout;
reg [pWEIGHTCNT-1:0]         reg_neural_weight_textout;
reg [pBIASCNT-1:0]           reg_neural_bias_textout;
reg [pOUTPUTCNT-1:0]         reg_neural_output_textout;


reg                          busy_usb;
reg                          done_r;
wire                         done_pulse;
wire                         crypt_go_pulse;
reg                          go_r;
reg                          go;
wire [31:0]                  buildtime;

(* ASYNC_REG = "TRUE") reg  [3:0]         inputs;
(* ASYNC_REG = "TRUE") reg  [3:0]        outputs;
(* ASYNC_REG = "TRUE") reg  [15:0]          bias;
(* ASYNC_REG = "TRUE") reg  [15:0]        weights;
   
assign I_done = 1'b1;

always @(posedge crypto_clk) begin
   done_r <= I_done & pDONE_EDGE_SENSITIVE;
end
assign done_pulse = I_done & ~done_r;

always @(posedge crypto_clk) begin
   // if (done_pulse) begin
   //    reg_neural_input_textout <= inputs;
   //    reg_neural_bias_textout <= bias;
   //    reg_neural_output_textout <= outputs;
   //    reg_neural_weight_textout <= weights;
   // end
   inputs <= reg_neural_input_textout;
   bias <= reg_neural_bias_textout;
   weights <= reg_neural_weight_textout;
   outputs <= reg_neural_output_textout;
end


   //////////////////////////////////
   // read logic:
   //////////////////////////////////

   always @(*) begin
      if (reg_addrvalid && reg_read) begin
         case (reg_address)
            `REG_CLKSETTINGS:           reg_read_data = O_clksettings;
            `REG_USER_LED:              reg_read_data = O_user_led;
            `REG_IDENTIFY:              reg_read_data = pIDENTIFY;
            `REG_CRYPT_GO:              reg_read_data = busy_usb;
            `REG_BUILDTIME:             reg_read_data = buildtime[reg_bytecnt*8 +: 8];
            `REG_NN_INPUTS:             reg_read_data = reg_neural_input_textout[reg_bytecnt*8 +: 8];
            `REG_NN_WEIGHTS:            reg_read_data = reg_neural_weight_textout[reg_bytecnt*8 +: 8];
            `REG_NN_BIAS:               reg_read_data = reg_neural_bias_textout[reg_bytecnt*8 +: 8];
            `REG_NN_RES:                reg_read_data = reg_neural_output_textout[reg_bytecnt*8 +: 8];
            default:                    reg_read_data = 0;
         endcase
      end
      else
         reg_read_data = 0;
   end

   // Register output read data to ease timing. If you need read data one clock 
   // cycle earlier, simply remove this stage:
  always @(posedge usb_clk)
     read_data <= reg_read_data;

   //////////////////////////////////
   // write logic (USB clock domain):
   //////////////////////////////////
   always @(posedge usb_clk) begin
      if (reset_i) begin
         O_clksettings <= 0;
         O_user_led <= 0;
         reg_crypt_go_pulse <= 1'b0;
      end

      else begin
         if (reg_addrvalid && reg_write) begin
            case (reg_address)
               `REG_CLKSETTINGS:        O_clksettings               <= write_data;
               `REG_USER_LED:           O_user_led                  <= write_data;
               `REG_NN_INPUTS:          reg_neural_input_textout[reg_bytecnt*8 +: 8]  <= write_data;
               `REG_NN_WEIGHTS:         reg_neural_weight_textout[reg_bytecnt*8 +: 8] <= write_data;
               `REG_NN_BIAS:            reg_neural_bias_textout[reg_bytecnt*8 +: 8]    <= write_data;
               `REG_NN_RES:             reg_neural_output_textout[reg_bytecnt*8 +: 8] <= write_data;
            endcase
         end
      end
   end

   `ifndef __ICARUS__
      USR_ACCESSE2 U_buildtime (
         .CFGCLK(),
         .DATA(buildtime),
         .DATAVALID()
      );
   `else
      assign buildtime = 0;
   `endif

endmodule

`default_nettype wire
