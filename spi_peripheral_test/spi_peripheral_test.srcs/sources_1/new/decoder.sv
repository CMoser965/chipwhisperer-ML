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
    
    logic [59:0] BRAM = 60'b0;
    logic [3:0] outs;
    integer temp_addr = 0;

    
    
    always @(cmd) begin
        BRAM[temp_addr +: 8] = cmd;
        case(cmd)
            8'hB1: temp_addr = 16;
            8'hB2: temp_addr = 20;
            8'hB3: temp_addr = 36;
            8'h00: temp_addr = 0;
            default: temp_addr = temp_addr + 8;
        endcase
    end
    
    always @(outs) begin
        BRAM[55:52] = outs; 
        Results = BRAM[59:52]; 
    end

    BNN_INPUT inputs(BRAM[19:16]);

    BNN_WEIGHTS weights(BRAM[35:20]);

    BNN_BIAS bias(BRAM[51:36]);

    BNN_MLP bnn(outs);
    
endmodule