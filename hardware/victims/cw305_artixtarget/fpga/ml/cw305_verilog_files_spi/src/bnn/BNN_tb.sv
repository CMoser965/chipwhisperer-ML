`timescale 1ps/1ps

module BNN_tb(); 
    logic [3:0] Input = 4'b1001;
    logic [15:0] Bias  = 16'b1011001111000111;
	logic [15:0] Weights = 16'b1111111111111111;
	logic [3:0] Result;

    logic clk = 0;

    always clk = #5 ~clk;

    integer seed = 500;

    BNN_MLP mlp(Result);
    BNN_INPUT inp(Input);
    BNN_BIAS bias(Bias);
    BNN_WEIGHTS weights(Weights);
    
    integer k = 0;
    always @(negedge clk) begin
        $display("%b", Result);
        assign Input = $urandom(seed + k)%16;
        assign Bias = $urandom(seed + k)%1000;
        assign Weights = $urandom(seed + k)%1000;
        k = k + 1;
        $display("Input: %b; Bias: %b; Weights: %b", Input, Bias, Weights);
    end

endmodule