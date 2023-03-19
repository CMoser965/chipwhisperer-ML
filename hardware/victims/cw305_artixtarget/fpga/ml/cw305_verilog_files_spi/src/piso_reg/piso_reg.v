module PISO_Register(
    input wire clk,
    input wire load,
    input wire [7:0] pi,
    output reg so
);

reg [7:0] tmp;

always @(posedge clk) begin
    if (load)
        tmp <= pi;
    else
    begin
        so <= tmp[7];
        tmp <= {tmp[6:0], 1'b0};
    end
end
endmodule