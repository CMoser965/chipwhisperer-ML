module stimulus();

    logic [8:0] A = 9'b1_0101_0101;
    logic [8:0] B = 9'b1_0101_0101;
    logic [3:0] C;
    XNOR_POPCOUNT layertest(
        .input_feat(A),
        .weight_feat(B),
        .convolution_o(C)
    );

    initial begin
        #100 $display("A: %b\nB: %b\nC: %b\n", A, B, C);
        #500 A= 9'b1_0001_0000;
        #500 B= 9'b1_1101_0110;
        #10000 $finish();
    end

endmodule