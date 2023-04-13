module bnn (
    input logic [0:0][27:0][27:0] layer_i,

	input logic [31:0][0:0][8:0] weights_i_0,
	input logic [31:0][3:0] threshold_i_0,
	input logic [31:0][1:0] sign_i_0,
	input logic [63:0][31:0][8:0] weights_i_1,
	input logic [62:0][8:0] threshold_i_1,
	input logic [63:0][1:0] sign_i_1,
	input logic [575:0][63:0][8:0] weights_i_2,
	input logic [575:0][9:0] threshold_i_2,
	input logic [575:0][1:0] sign_i_2,
	input logic [63:0][575:0] weights_i_4,
	input logic [63:0][7:0] threshold_i_4,
	input logic [63:0][1:0] sign_i_4,
	input logic [9:0][63:0] weights_i_5,

	output logic [9:0][6:0] layer_o
);

logic [31:0][25:0][25:0] olayer_0;
logic [63:0][10:0][10:0] olayer_1;
logic [63:0][2:0][2:0] olayer_2;
logic [575:0] olayer_3;
logic [63:0] olayer_4;

bconv_layer #( .ISIZE_W (28), .ISIZE_H (28), .ISIZE_FEAT (1), .OSIZE_W (26), .OSIZE_H (26), .OSIZE_FEAT (32), .CONV_KW  (3), .CONV_SW (1), .CONV_PW (1), .CONV_KH (3), .CONV_SH (1), .CONV_PH (1), .POOL_SW (2), .POOL_PW (2), .POOL_SH (2), .POOL_PH (2), .N_RECFIELDS (784), .LENGHT_RECFIELDS (9), .N_BITCONV (4)) binConvLayer_0 (.layer_i (layer_i), .weights_i (weights_i_0), .threshold_i (threshold_i_0), .sign_i (sign_i_0), .layer_o (olayer_0));

bconv_layer #( .ISIZE_W (26), .ISIZE_H (26), .ISIZE_FEAT (32), .OSIZE_W (11), .OSIZE_H (11), .OSIZE_FEAT (64), .CONV_KW  (3), .CONV_SW (1), .CONV_PW (1), .CONV_KH (3), .CONV_SH (1), .CONV_PH (1), .POOL_SW (2), .POOL_PW (2), .POOL_SH (2), .POOL_PH (2), .N_RECFIELDS (676), .LENGHT_RECFIELDS (288), .N_BITCONV (9)) binConvLayer_1 (.layer_i (olayer_0), .weights_i (weights_i_1), .threshold_i (threshold_i_1), .sign_i (sign_i_1), .layer_o (olayer_1));

bconv_layer #( .ISIZE_W (11), .ISIZE_H (11), .ISIZE_FEAT (64), .OSIZE_W (3), .OSIZE_H (3), .OSIZE_FEAT (64), .CONV_KW  (3), .CONV_SW (1), .CONV_PW (1), .CONV_KH (3), .CONV_SH (1), .CONV_PH (1), .POOL_SW (2), .POOL_PW (2), .POOL_SH (2), .POOL_PH (2), .N_RECFIELDS (121), .LENGHT_RECFIELDS (576), .N_BITCONV (10)) binConvLayer_2 (.layer_i (olayer_1), .weights_i (weights_i_2), .threshold_i (threshold_i_2), .sign_i (sign_i_2), .layer_o (olayer_2));

bview_layer #( .ISIZE_W (3), .ISIZE_H (3), .ISIZE_FEAT (64), .OSIZE_FEAT (576)) binViewLayer_3 (.layer_i (olayer_2), .layer_o (olayer_3));

blin_layer #( .ISIZE_FEAT (576), .OSIZE_FEAT (64), .N_BITCONV (10)) binLinLayer_4 (.layer_i (olayer_3), .weights_i (weights_i_4), .threshold_i (threshold_i_4), .sign_i (sign_i_4), .layer_o (olayer_4));

blast_layer #( .ISIZE_FEAT (64), .OSIZE_FEAT (10), .N_BITCONV (7)) binLastLayer5 (.layer_i (olayer_4), .weights_i (weights_i_5), .layer_o (layer_o));

endmodule