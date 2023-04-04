module BMaxPool #(
    parameter I_SIZE = 26,
    parameter O_SIZE = 13,
    parameter POOL_SIZE = 4
) (
    input  [I_SIZE-1:0][I_SIZE-1:0] layer_i,
    input  clk,
    output [O_SIZE-1:0][O_SIZE-1:0] layer_o
);


wire  [I_SIZE*I_SIZE-1:0] in_vector = layer_i;
logic [O_SIZE*O_SIZE-1:0] out_vector;

integer i = 0;
always @(posedge clk) begin
    out_vector[i] <= in_vector[i*O_SIZE +: 2] | in_vector[i*O_SIZE+I_SIZE +: 2];
    i <= i + 2;
end

assign layer_o = out_vector;

endmodule