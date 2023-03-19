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

module cw305_top(
    
    /****** USB Interface ******/
    input wire        usb_clk, /* Clock */
    
//    input wire        usb_spare1, /* Routes to MOSI pin on SPI Flash */
//    input wire        usb_spare2, /* Routes to CS pin on SPI Flash */

    input wire         usb_a20, /* PICO command*/
    input wire         usb_a19, /* POCI command*/
    input wire         usb_a18, /* SCLK command*/
    input wire         usb_a17, /* CS   command*/

    output reg         usb_a16, /* Res3 command*/
    output reg         usb_a15, /* Res2 command*/
    output reg         usb_a14, /* Res1 command*/
    output reg         usb_a13, /* Res0 command*/
    
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
    
    wire cs;
    wire pico;
    wire poci;
    wire sclk;

    reg rst_reg;
    reg rst;
    wire valid_data_tx;
    wire[7:0] tx_byte;
    
    reg  valid_data_rx;
    reg [7:0] rx_byte;
    reg [7:0] tx_byte_origin;

    reg [3:0] inputs;
    reg [3:0] outputs;
    reg [15:0] bias;
    reg [15:0] weights;

    reg [7:0] addr_reg;
    reg [3:0] data_reg [7:0];

    reg [2:0] cycle;
    
    
    assign cs = usb_a17;
    assign pico = usb_a20;
    assign poci = usb_a19;
    assign sclk = usb_a18;

    initial begin
        cycle <= 3'b000;
        rst <= 1'b1;
    end
    
    /* USB CLK Heartbeat */
    reg [24:0] usb_timer_heartbeat;
    always @(posedge usb_clk_buf) usb_timer_heartbeat <= usb_timer_heartbeat +  25'd1;
    assign led1 = usb_timer_heartbeat[24];
    
    assign valid_data_tx = 1'b1;
    assign rst = rst_reg;
    
    spi_peripheral #(.SPI_MODE(0)) peripheral_interface (// Control/Data Signals,
        .i_Rst_L(rst),    // FPGA Reset, active low
        .i_Clk(usb_clk),      // FPGA Clock
        .o_RX_DV(valid_data_rx),    // Data Valid pulse (1 clock cycle)
        .o_RX_Byte(rx_byte),  // Byte received on MOSI
        .i_TX_DV(valid_data_tx),    // Data Valid pulse to register i_TX_Byte
        .i_TX_Byte(tx_byte),  // Byte to serialize to MISO.
   
    // SPI Interface
    .i_SPI_Clk(sclk),
    .o_SPI_MISO(poci),
    .i_SPI_MOSI(pico),
    .i_SPI_CS_n(cs)        // active low
    );

    BNN_MLP bnn(
        .Input(inputs),
        .Bias(bias),
        .Weights(weights),
        .Result(outputs)
    );
    

    always @(posedge valid_data_rx) begin
        
        if(cycle == 3'b000) begin
            cycle <= cycle + 1'b1;
            addr_reg <= rx_byte;
        end
        else if(cycles < 3'b100) begin
            cycle <= cycle + 1'b1;
            data_reg[cycles] <= rx_byte;
        end
        else begin
            case (addr_reg)
                    8'h01:      inputs <= data_reg[1][3:0];
                    8'h02:      bias <= data_reg[1:0];
                    8'h03:      weights <= data_reg[1:0];
                    8'h04:      rx_byte <= results;
            endcase
            cycles <= 3'b000;
        end

        rst_reg <= 1'b0;
    end

    always @(posedge rst_reg) begin
    addr_reg <= 8'b0;
    end

    always @(negedge valid_data_rx) begin
        rst_reg <= 1'b1;
    end

    always @(results) begin
        usb_a13 <= results[0];
        usb_a14 <= results[1];
        usb_a15 <= results[2];
        usb_a16 <= results[3];
        rst_reg <= 1'b0;
    end

    
endmodule
