module top (

    input logic clk,
    input logic MOSI,
    output logic MISO,
    input logic CS,
    input logic reset,

    output logic led1,
    output logic led2,        
    output logic led3
);

reg[7:0] command;
reg[7:0] miso_r;
reg[7:0] outputs;

SPI_Slave interfacer(
    .SCLK(clk),
    .MOSI(MOSI),
    .CS(CS),
    .command(command)
);

decoder DUT(
    .cmd(command),
    .outs(outputs)
);

always @(posedge clk & ~CS) begin
    MISO <= miso_r[0];
    miso_r <= miso_r >> 1;
end

always @(posedge CS) begin
    miso_r <= outputs;
end



endmodule