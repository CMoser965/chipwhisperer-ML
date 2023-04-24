module bnn (
    input logic [0:0][7:0][7:0] layer_i,

	input logic [31:0][0:0][8:0] weights_i_0,
	input logic [31:0][2:0] threshold_i_0,
	input logic [31:0][1:0] sign_i_0,
	input logic [287:0][63:0] weights_i_1,
	input logic [63:0][9:0] threshold_i_1,
	input logic [63:0][1:0] sign_i_1,
	input logic [63:0][9:0] weights_i_2,
	input logic [9:0][4:0] threshold_i_2,
	input logic [9:0][1:0] sign_i_2,

	output logic [9:0][4:0] layer_o
);

reg [31:0][2:0][2:0] olayer_0;
reg [287:0] olayer_1;
reg [63:0] olayer_2;

bconv_layer #( .ISIZE_W (8), .ISIZE_H (8), .ISIZE_FEAT (1), .OSIZE_W (3), .OSIZE_H (3), .OSIZE_FEAT (32), .CONV_KW  (3), .CONV_SW (1), .CONV_PW (1), .CONV_KH (3), .CONV_SH (1), .CONV_PH (1), .POOL_SW (2), .POOL_PW (2), .POOL_SH (2), .POOL_PH (2), .N_RECFIELDS (64), .LENGHT_RECFIELDS (9), .N_BITCONV (3)) binConvLayer_0 (.layer_i (layer_i), .weights_i (weights_i_0), .threshold_i (threshold_i_0), .sign_i (sign_i_0), .layer_o (olayer_0));

bview_layer #( .ISIZE_W (3), .ISIZE_H (3), .ISIZE_FEAT (32), .OSIZE_FEAT (288)) binViewLayer_1 (.layer_i (olayer_0), .layer_o (olayer_1));

blin_layer #( .ISIZE_FEAT (288), .OSIZE_FEAT (64), .N_BITCONV (10)) binLinLayer_2 (.layer_i (olayer_1), .weights_i (weights_i_1), .threshold_i (threshold_i_1), .sign_i (sign_i_1), .layer_o (olayer_2));

blast_layer #( .ISIZE_FEAT (64), .OSIZE_FEAT (10), .N_BITCONV (5)) binLastLayer3 (.layer_i (olayer_2), .weights_i (weights_i_2), .layer_o (layer_o));

endmodule