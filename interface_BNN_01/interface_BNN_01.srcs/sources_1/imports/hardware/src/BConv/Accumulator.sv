module accumulator (
    input clk,
    input clr,
    input [3:0] d,
    output [3:0] q
);

logic [3:0] tmp;

always @(posedge clk or posedge clr) begin
    if(clr) tmp = 4'b0;
    else tmp = tmp + d;
end

assign q = tmp;

endmodule