module BConv_Interface #(
    parameter INPUT_H = 28,
    parameter INPUT_W = 28,
    parameter K_H = 3,
    parameter K_W = 3,    
    parameter OUTPUT_H = 26,
    parameter OUTPUT_W = 26
) (
    input  [INPUT_H-1:0][INPUT_W-1:0] layer_i,
    input  [K_H-1:0][K_W-1:0] kernel,
    input  clk,
    output [OUTPUT_H-1:0][OUTPUT_W-1:0] layer_o,
    output done
);

logic [8:0] input_slice;
logic [3:0] output_slice;

wire [K_W*K_H-1:0] kernel_flat;
wire [INPUT_H*INPUT_W-1:0] image_flat;
logic [OUTPUT_H*OUTPUT_W-1:0] output_flat;

assign kernel_flat = kernel;
assign image_flat = layer_i;

XNOR_POPCOUNT convolver(
    .input_feat(input_slice),
    .weight_feat(kernel_flat),
    .convolution_o(output_slice)
);

integer i = 0;

always @(clk) begin
    input_slice[8:6] <= image_flat[i +: 3];
    input_slice[5:3] <= image_flat[i+INPUT_W +: 3];
    input_slice[2:0] <= image_flat[i+2*INPUT_W +: 3];
    output_flat[i-1] <= (2*output_slice > 8) ? 1'b1 : 1'b0;
    i <= i+1;
end

assign layer_o = output_flat;

endmodule
