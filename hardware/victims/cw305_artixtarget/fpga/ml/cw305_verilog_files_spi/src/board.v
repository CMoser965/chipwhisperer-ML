/* 
ChipWhisperer Artix Target - SPI Feed-Through to allow programming of on-board SPI Flash

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

`timescale 1ns / 1ps
`default_nettype none 

module cw305_top #(
    parameter pBYTECNT_SIZE  = 7,
    parameter pADDR_WIDTH    = 21
 )(
    
    /****** USB Interface ******/
    // USB Interface
    input wire                          usb_clk,        // Clock
    inout wire [7:0]                    usb_data,       // Data for write/read
    input wire [pADDR_WIDTH-1:0]        usb_addr,       // Address
    input wire                          usb_rdn,        // !RD, low when addr valid for read
    input wire                          usb_wrn,        // !WR, low when data+addr valid for write
    input wire                          usb_cen,        // !CE, active low chip enable
    input wire                          usb_trigger,    // High when trigger requested

    // input wire         usb_a20, /* PICO command*/
    // input wire         usb_a19, /* POCI command*/
    // input wire         usb_a18, /* SCLK command*/
    // input wire         usb_a17, /* CS   command*/
    
    /****** SPI Interface *****/
    //input wire        flash_din, //Not used - routes to SAM3U already
//    output wire       flash_dout,
//    output wire       flash_cs,
    //output wire       flash_sck, //Not used - routes to SAM3U already
    
    
    /****** Buttons/LEDs on Board ******/
    
    output wire led1, /* red LED */
    output wire led2, /* green LED */
    output wire led3,  /* blue LED */
    
    /****** PLL ******/
    input wire pll_clk1 //PLL Clock Channel #1
    );
    
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

    wire resetn = pushbutton;
    wire reset = !resetn;
    
    wire cs;
    wire pico;
    wire poci;
    wire sclk;
    wire done;

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
    
    wire [7:0] results;
    
    assign cs = usb_addr[17];
    assign pico = usb_addr[20];
    assign poci = usb_addr[19];
    assign sclk = usb_addr[18];

    SIPO_Register data_byte(
        .clk(sclk),
        .si(poci),
        .po(results),
        .en_L(done)
    );

    spi_peripheral peripheral_interface(
        .sclk(sclk),
        .cs(cs),
        .pico(pico),
        .poci(poci),
        .done(done)
    );
    /* USB CLK Heartbeat */
    reg [24:0] usb_timer_heartbeat;
    always @(posedge usb_clk_buf) usb_timer_heartbeat <= usb_timer_heartbeat +  25'd1;
    assign led1 = usb_timer_heartbeat[24];

    reg r_led4;
    reg r_led5;
    reg r_led6;
    
    always @(done) begin
        case(results)
            8'h11:  begin
                r_led4 <= 1;
                r_led5 <= 1;
                r_led6 <= 1;
            end
            8'h12:  
            begin
                r_led4 <= 1;
                r_led5 <= 0;
                r_led6 <= 1;
            end
            8'h13:  begin
                r_led4 <= 1;
                r_led5 <= 0;
                r_led6 <= 0;
            end
            8'h14:  begin
                r_led4 <= 0;
                r_led5 <= 0;
                r_led6 <= 1;
            end
        endcase
    end

    assign led1 = r_led4;
    assign led2 = r_led5;
    assign led3 = r_led6;
    
    clocks U_clocks (
      .usb_clk(clk),
      .usb_clk_buf(buf_clk)
    );
    
endmodule
