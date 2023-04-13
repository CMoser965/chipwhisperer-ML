module top (
    input logic [0:0][7:0][7:0] layer_i,
    output logic [9:0][6:0] layer_o
);

logic [31:0][0:0][8:0] weights_0;
logic [31:0][2:0] threshold_0;
logic [31:0][1:0] sign_0;
logic [287:0][63:0] weights_1;
logic [63:0][9:0] threshold_1;
logic [63:0][1:0] sign_1;
logic [63:0][9:0] weights_2;
logic [9:0][4:0] threshold_2;
logic [9:0][1:0] sign_2;

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
    .layer_o(layer_o)
);	

parameters parameters_i
(
    .weights_o_0	(weights_0),
    .threshold_o_0	(threshold_0),
    .sign_o_0		(sign_0),
    .weights_o_1	(weights_1),
    .threshold_o_1	(threshold_1),
    .sign_o_1		(sign_1),
    .weights_o_2	(weights_2),
    .threshold_o_2	(threshold_2),
    .sign_o_2		(sign_2)
);	

endmodule