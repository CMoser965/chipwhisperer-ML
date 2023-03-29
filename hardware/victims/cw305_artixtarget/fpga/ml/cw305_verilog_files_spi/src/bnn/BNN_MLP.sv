package BNN_PKG; 
	logic [3:0] Input;
	logic [15:0] Bias;
	logic [15:0] Weights;
	logic [3:0] Result;
endpackage

module BNN_MLP(output logic [3:0] R);
	import BNN_PKG::*;
	BNN_Neuron neuron0 (Input, Weights[15:12], Bias[15:12], Result[0]);
	BNN_Neuron neuron1 (Input, Weights[11:8], Bias[11:8], Result[1]);
	BNN_Neuron neuron2 (Input, Weights[7:4], Bias[7:4], Result[2]);
	BNN_Neuron neuron3 (Input, Weights[3:0], Bias[3:0], Result[3]);

	always @(Result) begin
		R = Result;
	end
endmodule 

module BNN_INPUT(input logic [3:0] I);
	import BNN_PKG::Input;
	assign Input = I;
endmodule

module BNN_BIAS(input logic [15:0] B);
	import BNN_PKG::Bias;
	assign Bias = B;
endmodule

module BNN_WEIGHTS(input logic [15:0] W);
	import BNN_PKG::Weights;
	assign Weights = W;
endmodule