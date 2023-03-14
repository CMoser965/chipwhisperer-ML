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
`include "../cw305_ml_defines.v"

module cw305_reg_ml #(
   parameter pADDR_WIDTH    = 21,
   parameter pBYTECNT_SIZE  = 7,
   parameter pWEIGHTCNT     = 16,
   parameter pINPUTCNT      = 4,
   parameter pOUTPUTCNT     = 4,
   parameter pBIASCNT       = 16
)(
// Interface to cw305_usb_reg_fe:
   input  wire                                  usb_clk,
   input  wire [pADDR_WIDTH-pBYTECNT_SIZE-1:0]  reg_address,     // Address of register
   input  wire [pBYTECNT_SIZE-1:0]              reg_bytecnt,     // Current byte count
   output reg  [7:0]                            read_data,       //
   input  wire [7:0]                            write_data,      //
   input  wire                                  reg_read,        // Read flag. One clock cycle AFTER this flag is high
                                                                 // valid data must be present on the read_data bus
   input  wire                                  reg_write,       // Write flag. When high on rising edge valid data is
                                                                 // present on write_data
   input  wire                                  reg_addrvalid    // Address valid flag

);

   reg  [7:0]                   reg_read_data;

   wire [31:0]                  buildtime;
   
   reg  [pINPUTCNT-1:0]         inputs;
   reg  [pOUTPUTCNT-1:0]        outputs;
   reg  [pBIASCNT-1:0]          bias;
   reg  [pWEIGHTCNT-1:0]        weights;
   
   

   //////////////////////////////////
   // read logic:
   //////////////////////////////////

   always @(reg_bytecnt) begin
      if (reg_addrvalid && reg_read) begin
         case (reg_address)
            `REG_NN_INPUTS:             reg_read_data = inputs[reg_bytecnt*8 +: 8];
            `REG_NN_WEIGHTS:            reg_read_data = weights[reg_bytecnt*8 +: 8];
            `REG_NN_BIAS:               reg_read_data = bias[reg_bytecnt*8 +: 8];
            `REG_NN_RES:                reg_read_data = outputs[reg_bytecnt*8 +: 8];
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

   always @(reg_bytecnt) begin
      if (reg_addrvalid && reg_write) begin
         case (reg_address)
            `REG_NN_INPUTS:          inputs[reg_bytecnt*8 +: 8]    <= write_data;
            `REG_NN_WEIGHTS:         weights[reg_bytecnt*8 +: 8]   <= write_data;
            `REG_NN_BIAS:            bias[reg_bytecnt*8 +: 8]      <= write_data;
            `REG_NN_RES:             outputs[reg_bytecnt*8 +: 8]   <= write_data;
         endcase
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
