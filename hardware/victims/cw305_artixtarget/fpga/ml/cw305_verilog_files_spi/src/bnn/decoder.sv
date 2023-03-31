//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2023 01:32:08 AM
// Design Name: 
// Module Name: decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module decoder(
    input logic[7:0] cmd,
    output logic[3:0] Results
    );
    
    logic [39:0] BRAM = 40'b0;
    logic [3:0] outs;
    logic [2:0] temp_addr = 0;

    
    
    always @(cmd) begin
        case(temp_addr) 
            32'd0: BRAM[3:0]   <= cmd[3:0];
            32'd1: BRAM[11:4]  <= cmd;
            32'd2: BRAM[19:12] <= cmd;
            32'd3: BRAM[27:20] <= cmd;
            32'd4: BRAM[35:28] <= cmd;
            default: temp_addr <= 0;
        endcase
        $display("ITER %d: %b",temp_addr, cmd);
        temp_addr <= temp_addr + 1;
        
        
        $display("BRAM: %b", BRAM);
    end
    
    always @(outs) begin
        BRAM[39:36] = outs; 
        Results = BRAM[39:36]; 
    end

    BNN_MLP bnn(Results);
    BNN_INPUT inputs(BRAM[3:0]);
    BNN_WEIGHTS weights(BRAM[19:4]);
    BNN_BIAS bias(BRAM[35:20]);

    
endmodule