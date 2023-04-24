module XNOR_POPCOUNT
 #( parameter IN_SIZE=9,
    parameter O_SIZE =4) 
 (
    input logic[IN_SIZE-1:0] input_feat,
    input logic[IN_SIZE-1:0] weight_feat,
    output logic[O_SIZE-1:0] convolution_o
);

reg[IN_SIZE-1:0] dot_prod;
reg[2:0] comp_sum_1;
reg[2:0] comp_sum_2;

logic[O_SIZE-2:0] convolved;
logic[O_SIZE-2:0] carried;

assign convolution_o = {carried[O_SIZE-2], convolved};

XNOR xnor_gate(
    .A(input_feat),
    .B(weight_feat),
    .Y(dot_prod)
);

compressor stage_1(
    .i(dot_prod[5:0]),
    .o(comp_sum_1)
);

compressor stage_2(
    .i({dot_prod[IN_SIZE-1:6], 3'b0}),
    .o(comp_sum_2)
);

ripple_carry_adder popcounted_add(  
    .A({1'b0, comp_sum_1}), 
    .B({1'b0, comp_sum_2}),
    .Cin(1'b0), 
    .S(convolved), 
    .Cout(carried)
);




endmodule