`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/21/2022 09:58:56 AM
// Design Name: 
// Module Name: cw305_ml_top
// Project Name: 
// Target Devices: CW305 (Artix-7 A100T)
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`include "../cw305_ml_defines.v"

module cw305_ml_top #(
    parameter pBYTECNT_SIZE = 8,
    parameter pADDR_WIDTH = 21,
    parameter pDONE_EDGE_SENSITIVE = 1,
    parameter pIDENTIFY = 8'h2e,
    parameter pWEIGHTCNT = 16,
    parameter pINPUTCNT = 4,
    parameter pOUTPUTCNT = 4,
    parameter pBIASCNT = 1
)(

    // USB Interface
    input wire                          usb_clk,        // Clock
    inout wire [7:0]                    usb_data,       // Data for write/read
    input wire [pADDR_WIDTH-1:0]        usb_addr,       // Address
    input wire                          usb_rdn,        // !RD, low when addr valid for read
    input wire                          usb_wrn,        // !WR, low when data+addr valid for write
    input wire                          usb_cen,        // !CE, active low chip enable
    input wire                          usb_trigger,    // High when trigger requested

// Buttons/LEDs on Board
    input wire                          j16_sel,        // DIP switch J16
    input wire                          k16_sel,        // DIP switch K16
    input wire                          k15_sel,        // DIP switch K15
    input wire                          l14_sel,        // DIP Switch L14
    input wire                          pushbutton,     // Pushbutton SW4, connected to R1, used here as reset
//    output wire                         led1,           // red LED
//    output wire                         led2,           // green LED
//    output wire                         led3,           // blue LED

    // PLL
//    input wire                          pll_clk1,       //PLL Clock Channel #1
    //input wire                        pll_clk2,       //PLL Clock Channel #2 (unused in this example)

   // 20-Pin Connector Stuff
//   output wire                         tio_trigger,
//   output wire                         tio_clkout,
   input  wire                         tio_clkin
    );

    reg  [4:0]                            O_clksettings;
    reg                                   O_user_led;
    reg [pOUTPUTCNT-1:0]                  O_res; 
    wire usb_clk_buf;
    wire [7:0] usb_dout;
    wire isout;
    wire [pADDR_WIDTH-pBYTECNT_SIZE-1:0] reg_address;
    wire [pBYTECNT_SIZE-1:0] reg_bytecnt;
    wire reg_addrvalid;
    wire [7:0] write_data;
    wire [7:0] read_data;
    wire reg_read;
    wire reg_write;
    wire [4:0] clk_settings;
    wire crypt_clk;    

    wire resetn = pushbutton;
    wire reset = !resetn;

    // USB CLK Heartbeat
//    reg [24:0] usb_timer_heartbeat;
//    always @(posedge usb_clk_buf) usb_timer_heartbeat <= usb_timer_heartbeat +  25'd1;
//    assign led1 = usb_timer_heartbeat[24];

    cw305_usb_reg_fe #(
        .pBYTECNT_SIZE           (pBYTECNT_SIZE),
        .pADDR_WIDTH             (pADDR_WIDTH)
        ) U_usb_reg_fe (
        .rst                     (reset),
        .usb_clk                 (usb_clk_buf), 
        .usb_din                 (usb_data), 
        .usb_dout                (usb_dout), 
        .usb_rdn                 (usb_rdn), 
        .usb_wrn                 (usb_wrn),
        .usb_cen                 (usb_cen),
        .usb_alen                (1'b0),                 // unused
        .usb_addr                (usb_addr),
        .usb_isout               (isout), 
        .reg_address             (reg_address), 
        .reg_bytecnt             (reg_bytecnt), 
        .reg_datao               (write_data), 
        .reg_datai               (read_data),
        .reg_read                (reg_read), 
        .reg_write               (reg_write), 
        .reg_addrvalid           (reg_addrvalid)
        );
        
       reg  [7:0]                   reg_read_data;
    
       reg                          busy_usb;
       reg                          done_r;
       wire                         done_pulse;
       wire [31:0]                  buildtime;
       
       reg  [pINPUTCNT-1:0]         inputs;
       reg  [pOUTPUTCNT-1:0]        outputs;
       reg  [pBIASCNT-1:0]          bias;
       reg  [pWEIGHTCNT-1:0]        weights;
       
       wire [pOUTPUTCNT-1:0]        res;
       
       assign res = outputs;
        
       BNN_MLP bnn_mlp (
            .Input(inputs),
            .Bias(bias),
            .Weights(weights),
            .Result(res)
      );

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
   always @(posedge usb_clk) begin
      if (reset) begin
         O_clksettings <= 0;
         O_user_led <= 0;
//         reg_crypt_go_pulse <= 1'b0;
      end

      else begin
         if (reg_addrvalid && reg_write) begin
            case (reg_address)
               `REG_CLKSETTINGS:        O_clksettings               <= write_data;
               `REG_USER_LED:           O_user_led                  <= write_data;
               `REG_NN_INPUTS:          inputs[reg_bytecnt*8 +: 8]  <= write_data;
               `REG_NN_WEIGHTS:         weights[reg_bytecnt*8 +: 8] <= write_data;
               `REG_NN_BIAS:            bias[reg_bytecnt*8 +: 8]    <= write_data;
               `REG_NN_RES:             outputs[reg_bytecnt*8 +: 8] <= write_data;
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


    assign usb_data = isout? usb_dout : 8'bZ;

endmodule

`default_nettype wire