`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Myself
// Engineer: Christian W. Moser
// 
// Create Date: 04/23/2023 09:25:43 PM
// Design Name: TOP
// Module Name: cw305_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: EEESlab
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cw305_top(
        input  reg  usb_clk, en, rst,
        input  reg  [7:0] usb_data,
        input  reg  [2:0] usb_addr,
        output reg  done, RS, RW, E,
        output reg  [7:0]    DB
    );
    
    reg [7:0][7:0]  image = 64'b0;
    reg [9:0][4:0]  classifier = 50'b0;
    
    image_stream_decoder decoder(
        .slice_i(usb_data), .sel(usb_addr),
        .en(en),      .clk(usb_clk),
        .rst(rst),     .image_o(image)    
    );
    
    top bnn_constructed (
        .layer_i(image), .layer_o(classifier)
    );
    
    LCD_Controller lcd(
        .values(classifier), .clk(usb_clk),
        .rst(rst),           .en(en), 
        .done(done), .RS(RS), .RW(RW), .E(E),
        .DB(DB)
    );
    
    
    
    
endmodule
