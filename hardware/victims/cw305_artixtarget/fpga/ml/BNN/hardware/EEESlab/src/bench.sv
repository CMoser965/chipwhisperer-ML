module stimulus();

logic [0:0][7:0][7:0] test_image = {{8'b00000000},{8'b00000000},{8'b01000100},{8'b00101100},{8'b00111100},{8'b00000100},{8'b00000100},{8'b00000000}};
logic [9:0][6:0] classifier;


top bnn_test(
    .layer_i(test_image),
    .layer_o(classifier)
);

endmodule