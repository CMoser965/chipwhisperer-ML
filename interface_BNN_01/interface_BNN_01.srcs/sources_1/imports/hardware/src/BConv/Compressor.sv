module compressor(
    input [5:0] i,
    output reg [2:0] o);    // # of 1's in i

    always @* begin
        case (i)
        6'h00: o = 0; 6'h01: o = 1; 6'h02: o = 1; 6'h03: o = 2;
        6'h04: o = 1; 6'h05: o = 2; 6'h06: o = 2; 6'h07: o = 3;
        6'h08: o = 1; 6'h09: o = 2; 6'h0A: o = 2; 6'h0B: o = 3;
        6'h0C: o = 2; 6'h0D: o = 3; 6'h0E: o = 3; 6'h0F: o = 4;
        6'h10: o = 1; 6'h11: o = 2; 6'h12: o = 2; 6'h13: o = 3;
        6'h14: o = 2; 6'h15: o = 3; 6'h16: o = 3; 6'h17: o = 4;
        6'h18: o = 2; 6'h19: o = 3; 6'h1A: o = 3; 6'h1B: o = 4;
        6'h1C: o = 3; 6'h1D: o = 4; 6'h1E: o = 4; 6'h1F: o = 5;
        6'h20: o = 1; 6'h21: o = 2; 6'h22: o = 2; 6'h23: o = 3;
        6'h24: o = 2; 6'h25: o = 3; 6'h26: o = 3; 6'h27: o = 4;
        6'h28: o = 2; 6'h29: o = 3; 6'h2A: o = 3; 6'h2B: o = 4;
        6'h2C: o = 3; 6'h2D: o = 4; 6'h2E: o = 4; 6'h2F: o = 5;
        6'h30: o = 2; 6'h31: o = 3; 6'h32: o = 3; 6'h33: o = 4;
        6'h34: o = 3; 6'h35: o = 4; 6'h36: o = 4; 6'h37: o = 5;
        6'h38: o = 3; 6'h39: o = 4; 6'h3A: o = 4; 6'h3B: o = 5;
        6'h3C: o = 4; 6'h3D: o = 5; 6'h3E: o = 5; 6'h3F: o = 6;
        endcase
    end
endmodule

module ripple_carry_adder #(parameter SIZE = 4) (
  input [SIZE-1:0] A, B, 
  input Cin,
  output [SIZE-1:0] S, Cout);
  
  genvar g;
  
  full_adder fa0(A[0], B[0], Cin, S[0], Cout[0]);
  generate  // This will instantiate full_adder SIZE-1 times
    for(g = 1; g<SIZE; g++) begin
      full_adder fa(A[g], B[g], Cout[g-1], S[g], Cout[g]);
    end
  endgenerate
endmodule

module full_adder(
  input a, b, cin,
  output sum, cout
);
  
  assign {sum, cout} = {a^b^cin, ((a & b) | (b & cin) | (a & cin))};
  //or
  //assign sum = a^b^cin;
  //assign cout = (a & b) | (b & cin) | (a & cin);
endmodule

