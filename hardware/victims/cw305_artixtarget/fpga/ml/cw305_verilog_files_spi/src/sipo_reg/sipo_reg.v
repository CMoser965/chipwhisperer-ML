module SIPO_Register(
    input wire clk,
    input wire si,
    output wire [7:0] po,
    input wire en_L,
    input wire rst
);

reg[7:0] tmp = 8'b1;

initial begin
    tmp = 8'b0;
end

always @(posedge clk & ~en_L | rst) begin
    if (rst) begin
        tmp <= {8'b0};
    end
    else begin
        tmp <= {tmp[6:0], si};    
    end
end

assign po = tmp;

endmodule