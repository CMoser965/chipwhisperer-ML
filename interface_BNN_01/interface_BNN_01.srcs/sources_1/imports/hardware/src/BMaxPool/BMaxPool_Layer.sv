module BMaxPool #(
    parameter I_SIZE = 26,
    parameter O_SIZE = 13,
    parameter POOL_H = 2,
    parameter POOL_W = 2
) (
    input  [I_SIZE-1:0][I_SIZE-1:0] layer_i,
    input  clk,
    output [O_SIZE-1:0][O_SIZE-1:0] layer_o
);


wire  [I_SIZE*I_SIZE-1:0] in_vector = layer_i;
logic [O_SIZE*O_SIZE-1:0] out_vector;

integer i = 0;
// always @(posedge clk) begin

// end

always @(*) begin

    for(i = 0; i < O_SIZE * O_SIZE; i = i + 1) begin
        out_vector[i] <= |in_vector[i*POOL_H +: POOL_W] | |in_vector[i*POOL_W+I_SIZE +: POOL_H];
    end

end

assign layer_o = out_vector;

endmodule