`timescale 1ps/1ps

module decoder_tb(); 
    logic clk = 0;
    always clk = #5 ~clk;
    integer seed = 500;
    
    logic[7:0] cmd = 8'h11;
    logic[7:0] outs;

    decoder dec(cmd, outs);

    integer k = 0;
    always @(negedge clk) begin
        //assign Input = $urandom(seed + k)%256;
        k = k + 1;
        # 5 cmd = 8'hB2;
        # 10 cmd = 8'hB3;
    end

endmodule