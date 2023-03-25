module PISO_Register(
    input wire clk,
    input wire load,
    input wire [7:0] pi,
    output wire so,
    input wire en_L,
    input wire rst
);

reg [7:0] tmp = 8'b0;
reg so_r = 1'b0;

always @(posedge load) begin
    tmp = pi;
end

always @(posedge clk & ~en_L) begin
    if (load)
        tmp <= pi;
    else 
        begin
        so_r <= tmp[7];
        tmp <= {tmp[6:0], 1'b0};
    end
end

assign so = so_r;

endmodule