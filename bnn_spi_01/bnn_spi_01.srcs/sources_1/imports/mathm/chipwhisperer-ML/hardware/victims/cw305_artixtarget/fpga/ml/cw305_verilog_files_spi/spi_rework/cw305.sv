module cw305 (

    input logic clk,
    input logic MOSI,
    input logic MISO,
    input logic CS,
    input logic reset,

    output logic led1,
    output logic led2,        
    output logic led3
);

reg[7:0] command;

logic [99:0][15:0][15:0] layer_i;
logic [15:0][15:0] layer;
logic [3:0][6:0] layer_o;

data data_i(.input_o(layer_i));
bnn_top bnn_top_i(.layer_i(layer), .layer_o(layer_o));

SPI_Slave DUT(
    .rst(reset),
    .SCLK(clk),
    .MOSI(MOSI),
    .MISO(MISO),
    .CS(CS),
    .data(command)
);

always @(CS) begin
    if(command < 8'h64) layer = layer_i[command];
    else layer = layer_i[8'h0];
end 

//always_comb begin

//    led1 = |layer_o[0];
//    led2 = |layer_o[1];
//    led3 = |layer_o[2];
    

//end



endmodule