module counter #(
    parameter count = 8 
) (
    input wire clk,
    input wire en_L,
    output wire done
);

reg[count:0] count_r = 1'b1;
reg done_r = 1'b0;

assign done = done_r;

always @(posedge clk & ~done & ~en_L) begin
    if(~|count_r) begin
        done_r <= 1'b1;
    end
    else begin
        count_r <= count_r << 1;
    end
end

endmodule