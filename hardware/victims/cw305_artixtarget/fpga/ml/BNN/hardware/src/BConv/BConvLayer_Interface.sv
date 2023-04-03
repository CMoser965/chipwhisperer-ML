module BConv_Interface #(
    parameter INPUT_H = 28,
    parameter INPUT_W = 28,
    parameter K_H = 3,
    parameter K_W = 3,    
    parameter OUTPUT_H = 26,
    parameter OUTPUT_W = 26
) (
    input  logic [INPUT_H-1:0][INPUT_W-1:0] layer_i,
    input  logic [K_H-1:0][K_W-1:0] kernel,
    input  logic clk,
    output logic  [OUTPUT_H-1:0][OUTPUT_W-1:0] layer_o [3:0]
);

logic [8:0] input_slice;

wire [K_W*K_H-1:0] kernel_flat;
wire [INPUT_H*INPUT_W-1:0] image_flat;

assign kernel_flat = kernel;
assign image_flat = layer_i;


XNOR_POPCOUNT convolver(
    .input_feat(input_slice),
    .weight_feat(kernel_flat),
    .convolution_o(layer_o)
);

integer i;

always @(*) begin
    for(i = 0; i < INPUT_H + K_H - 1; i = i + 1) begin
        input_slice[6:8] = image_flat[i +: 3];
        input_slice[3:5] = image_flat[i*INPUT_W +: 3];
        input_slice[0:2] = image_flat[i*2*INPUT_W +: 3];
    end
end

endmodule
