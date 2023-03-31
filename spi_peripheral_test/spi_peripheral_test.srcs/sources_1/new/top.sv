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
reg[7:0] outputs = 8'b0;

SPI_Slave interfacer(
    .SCLK(clk),
    .MOSI(MOSI),
    .CS(CS),
    .command(command)
);

decoder DUT(
    .cmd(command),
    .Results(outputs[3:0])
);

always @(posedge clk & ~CS) begin
    MISO <= miso_r[0];
//    miso_r = miso_r >> 1;
end

//always @(posedge CS) begin
//    miso_r = outputs;
//end

always @(*) begin

    if(~CS & clk) begin
        miso_r <= miso_r >>1;
    end
    else if (CS) begin
      miso_r <= outputs;
    end

end





endmodule