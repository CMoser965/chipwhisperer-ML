module stimulus();

logic [25:0][25:0] test_layer;
logic clk = 1'b1;
logic [12:0][12:0] test_output;

always #1 clk = ~clk;

initial begin
    test_layer[0] =  26'b1110_0000_0000_0000_0000_0000_11;
    test_layer[1] =  26'b1110_0000_0000_0000_0000_0000_11;
    test_layer[2] =  26'b1110_0000_0000_0000_0000_0000_11;
    test_layer[3] =  26'b1110_0000_0000_0000_0000_0000_11;
    test_layer[4] =  26'b1110_0000_0000_0000_0000_0000_11;
    test_layer[5] =  26'b1110_0000_0000_0000_0000_0000_11;
    test_layer[6] =  26'b1110_0000_0000_0000_0000_0000_11;
    test_layer[7] =  26'b1110_0000_0000_0000_0000_0000_11;
    test_layer[8] =  26'b1110_0000_0000_0000_0000_0000_11;
    test_layer[9] =  26'b1110_0000_0000_0000_0000_0000_11;
    test_layer[10] = 26'b1110_0000_0000_0000_0000_0000_11;
    test_layer[11] = 26'b1110_0000_0000_0000_0000_0000_11;
    test_layer[12] = 26'b1110_0000_0000_0000_0000_0000_11;
    test_layer[13] = 26'b1110_0000_0000_0000_0000_0000_11;
    test_layer[14] = 26'b1110_0000_0000_0000_0000_0000_11;
    test_layer[15] = 26'b1110_0000_0000_0000_0000_0000_11;
    test_layer[16] = 26'b1110_0000_0000_0000_0000_0000_11;
    test_layer[17] = 26'b1110_0000_0000_0000_0000_0000_11;
    test_layer[18] = 26'b1110_0000_0000_0000_0000_0000_11;
    test_layer[19] = 26'b1110_0000_0000_0000_0000_0000_11;
    test_layer[20] = 26'b1110_0000_0000_0000_0000_0000_11;
    test_layer[21] = 26'b1110_0000_0000_0000_0000_0000_11;
    test_layer[22] = 26'b1110_0000_0000_0000_0000_0000_11;
    test_layer[23] = 26'b1110_0000_0000_0000_0000_0000_11;
    test_layer[24] = 26'b1110_0000_0000_0000_0000_0000_11;
    test_layer[25] = 26'b1110_0000_0000_0000_0000_0000_11;
end

BMaxPool DUT(
    .layer_i(test_layer),
    .clk(clk),
    .layer_o(test_output)
);

initial begin
    #20000 $display(test_output);
end

endmodule