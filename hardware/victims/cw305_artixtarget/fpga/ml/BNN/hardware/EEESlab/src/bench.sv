module stimulus();

logic [0:0][7:0][7:0] test_image = {{8'b00000000},{8'b00000000},{8'b01000100},{8'b00101100},{8'b00111100},{8'b00000100},{8'b00000100},{8'b00000000}};
logic [9:0][4:0] classifier;

logic [0:0][7:0][7:0] test_image1 = {{8'b00000000},{8'b00000000},{8'b01111000},{8'b00000100},{8'b00011100},{8'b00100100},{8'b00000100},{8'b00000000}};

logic [0:0][7:0][7:0] test_image2 = {{8'b00000000},{8'b00000000},{8'b00001000},{8'b00011000},{8'b00001000},{8'b00001000},{8'b00000000},{8'b00000000}};

logic [0:0][7:0][7:0] testInput;
// top bnn_test(
//     .layer_i(test_image),
//     .layer_o(classifier)
// );

top bnn_test2(
    .layer_i(testInput),
    .layer_o(classifier)
);

initial begin
    #5 testInput = test_image;
    // foreach(test_image[k, i, j]) $display("%8b\t", test_image[k][i]);
    #10 foreach(classifier[n]) $display("OUTPUT[%0d]:\t%d\t%D (BIN: %8b, HEX: 0x%h )",n, $signed(classifier[n]),classifier[n], classifier[n], classifier[n]);
    // #100 foreach(classifier[n]) $display("OUTPUT[%0d]:\t%d\t%D (BIN: %5b, HEX: 0x%h )",n, $signed(classifier[n]),classifier[n], classifier[n], classifier[n]);
    #15 assign testInput = test_image1;
    #20 foreach(classifier[n]) $display("OUTPUT[%0d]:\t%d\t%D (BIN: %8b, HEX: 0x%h )",n, $signed(classifier[n]),classifier[n], classifier[n], classifier[n]);
    #25 assign testInput = test_image2;
    #30 foreach(classifier[n]) $display("OUTPUT[%0d]:\t%d\t%D (BIN: %8b, HEX: 0x%h )",n, $signed(classifier[n]),classifier[n], classifier[n], classifier[n]);
    
end

endmodule