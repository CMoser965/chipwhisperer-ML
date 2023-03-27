`timescale 1ps/1ps

module decoder_tb(); 
    logic clk = 0;
    always clk = #5 ~clk;
    integer seed = 500;
    
    logic[7:0] cmd = 8'h11;
    logic[3:0] outs;

    decoder dec(cmd, outs);

    integer k = 0;
    initial begin
        //assign Input = $urandom(seed + k)%256;
        k = k + 1;

        //# 5 cmd = 8'hB2; // Write Weights
        //# 10 cmd = $urandom(seed + k*1)%256;
        //# 15 cmd = $urandom(seed + k*2)%256; // Weight Values   
        //# 20 cmd = 8'h00;
        //# 25 cmd = 8'hB3; // Write Bias
        //# 30 cmd = $urandom(seed + k*3)%256;
        //# 35 cmd = $urandom(seed + k*4)%256; // Bias
        //# 40 cmd = 8'h00; 
        # 5 cmd = 8'hB1; // Write Inputs
        # 10 cmd = 8'b00001110;
        # 15 cmd = 8'h00;
        # 20 cmd = 8'hB2; // Write Weights
        # 25 cmd = 00000000;
        # 30 cmd = 11011110; // Weight Values   
        # 35 cmd = 8'h00;
        # 40 cmd = 8'hB3; // Write Bias
        # 45 cmd = 00000000;
        # 50 cmd = 11011110; // Bias
        # 55 cmd = 8'h00;  
    end

    always @(outs) begin
        $display("%b", outs);
    end

endmodule