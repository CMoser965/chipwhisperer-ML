module SIPO_Register(
    input wire clk,
    input wire si,
    output wire [7:0] po
);

reg[7:0] tmp;

always @(posedge clk) begin
    tmp = {tmp[6:0], si};    
end

assign po = tmp;

endmodule