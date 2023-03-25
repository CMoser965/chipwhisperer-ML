module HA (A, B, SUM, Cout);
	input logic A, B;
	output logic SUM, Cout;

	assign SUM = A ^ B;
	assign Cout = A & B;
endmodule

module FA (A, B, Cin, SUM, Cout);
	input logic A, B, Cin;
	output logic SUM, Cout;
	
	assign SUM = A ^ B ^ Cin;
	assign Cout = A & B | A & Cin | B & Cin;
endmodule

module BNN_Neuron  (X, Weight, Bias, Result);
	input logic [3:0] X;
	input logic [3:0] Weight;
	input logic [3:0] Bias;
	output logic Result;

	logic [2:0] Buffer;
	logic [2:0] PopCount;
	HA ha0 (~(X[0] ^ Weight[0]), ~(X[1] ^ Weight[1]), Buffer[0], Buffer[1]);
	FA fa0 (~(X[2] ^ Weight[2]), ~(X[3] ^ Weight[3]), Buffer[0], PopCount[0], Buffer[2]);
	HA ha1 (Buffer[1], Buffer[2], PopCount[1], PopCount[2]);
	
	logic [3:0] Carry;
	logic [3:0] Sum;
	FA fa1 (1'b0, ~Bias[0], 1'b1, Sum[0], Carry[0]);
	FA fa2 (PopCount[0], ~Bias[1], Carry[0], Sum[1], Carry[1]);
	FA fa3 (PopCount[1], ~Bias[2], Carry[1], Sum[2], Carry[2]);
	FA fa4 (PopCount[2], ~Bias[3], Carry[2], Sum[3], Carry[3]);
	
	assign Result = ~(Carry[3] | Sum[3]); 
endmodule
