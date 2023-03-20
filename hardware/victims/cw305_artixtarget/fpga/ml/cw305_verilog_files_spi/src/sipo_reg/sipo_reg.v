module SIPO_Register(
    input wire clk,
    input wire si,
    output wire [7:0] po,
    input wire en_L
);

reg[7:0] tmp = 8'b1;

initial begin
    tmp = 8'b0;
end

always @(posedge clk & ~en_L) begin
    tmp <= {tmp[6:0], si};    
end

assign po = tmp;

endmodule