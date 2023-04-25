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
<<<<<<< HEAD
        input  reg  usb_clk, en, rst,
        input  reg  [7:0] usb_data,
        input  reg  [2:0] usb_addr,
        output reg  done, RS, RW, E,
        output reg  [7:0]    DB
    );
    
    reg [7:0][7:0]  image = 64'b0;
    reg [9:0][4:0]  classifier = 50'b0;
=======
        input  logic  usb_clk, en, rst,
        input  logic  usb_data[7:0],
        input  logic  usb_addr[2:0],
        output logic  done, RS, RW, E,
        output logic  DB[7:0]
    );
    
    reg [7:0][7:0]  image;
    reg [9:0][4:0]  classifier;
    
    wire [7:0] input_slice;
    wire [2:0] sel;
    wire [7:0] data_bus;
    
    assign input_slice = {usb_data[7],usb_data[6],usb_data[5],usb_data[4],usb_data[3],usb_data[2],usb_data[1],usb_data[0]};
    assign sel = {usb_addr[2], usb_addr[1], usb_addr[0]};
    assign data_bus = {DB[7],DB[6],DB[5],DB[4],DB[3],DB[2],DB[1],DB[0]};
>>>>>>> 08f178d4 (final push; commit; ultimate project failure and deprecation of such; to those that utilize this repo, if they exist, i wish the best, and hope you may succeed where I failed; signing off)
    
    image_stream_decoder decoder(
        .slice_i(input_slice), .sel(sel),
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
        .DB(data_bus)
    );
    
    
    
    
endmodule
