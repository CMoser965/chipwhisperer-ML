module XNOR #(parameter SIZE=9)
(
    input  logic[SIZE-1:0] A,
    input  logic[SIZE-1:0] B,
    output logic[SIZE-1:0] Y
);

always @(*) begin
    Y = ~(A^B);
end

endmodule