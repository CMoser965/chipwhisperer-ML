module top (
    input logic [0:0][27:0][27:0] layer_i,
    output logic [9:0][6:0] layer_o
);

logic [31:0][0:0][8:0] weights_i_0;
logic [31:0][3:0] threshold_i_0;
logic [31:0][1:0] sign_i_0;
logic [63:0][31:0][8:0] weights_i_1;
logic [62:0][8:0] threshold_i_1;
logic [63:0][1:0] sign_i_1;
logic [575:0][63:0][8:0] weights_i_2;
logic [575:0][9:0] threshold_i_2;
logic [575:0][1:0] sign_i_2;
logic [63:0][575:0] weights_i_4;
logic [63:0][7:0] threshold_i_4;
logic [63:0][1:0] sign_i_4;
logic [9:0][63:0] weights_i_5;

bnn bnn_i
(
    .layer_i(layer_i),
    .weights_i_0	(weights_0),
    .threshold_i_0	(threshold_0),
    .sign_i_0		(sign_0),
    .weights_i_1	(weights_1),
    .threshold_i_1	(threshold_1),
    .sign_i_1		(sign_1),
    .weights_i_2	(weights_2),
    .threshold_i_2	(threshold_2),
    .sign_i_2		(sign_2),
    .weights_i_4	(weights_4),
    .threshold_i_4	(threshold_4),
    .sign_i_4		(sign_4),
    .weights_i_5	(weights_5),
    .layer_o(layer_o)
);	

parameters parameters_i
(
    .weight_o_0	(weights_0),
    .threshold_o_0	(threshold_0),
    .sign_o_0		(sign_0),
    .weight_o_1	(weights_1),
    .threshold_o_1	(threshold_1),
    .sign_o_1		(sign_1),
    .weight_o_2	(weights_2),
    .threshold_o_2	(threshold_2),
    .sign_o_2		(sign_2),
    .weight_o_4	(weights_4),
    .threshold_o_4	(threshold_4),
    .sign_o_4		(sign_4),
    .weight_o_5	(weights_5)
);	

endmodule