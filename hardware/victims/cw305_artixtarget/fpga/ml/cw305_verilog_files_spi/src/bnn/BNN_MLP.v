module BNN_MLP(
	input wire [3:0] Input, 
	input wire [15:0] Bias, 
	input wire [15:0] Weights,
	output wire [3:0] Result
	);
	
	BNN_Neuron neuron0 (Input, Weights[15:12], Bias[15:12], Result[0]);
	BNN_Neuron neuron1 (Input, Weights[11:8], Bias[11:8], Result[1]);
	BNN_Neuron neuron2 (Input, Weights[7:4], Bias[7:4], Result[2]);
	BNN_Neuron neuron3 (Input, Weights[3:0], Bias[3:0], Result[3]);

endmodule 
