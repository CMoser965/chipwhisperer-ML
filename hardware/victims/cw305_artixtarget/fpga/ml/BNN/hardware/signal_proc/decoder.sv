module image_stream_decoder (
    input   [7:0]       slice_i,
    input   [2:0]       sel,
    input               en,
    input               clk,
    input               rst,
    output  [7:0][7:0]  image_o
);

reg [7:0] slice_sel;

always begin : stream_selection
    case(sel) 
        3'b000  : image_o[0] = slice_sel;
        3'b001  : image_o[1] = slice_sel;
        3'b010  : image_o[2] = slice_sel;
        3'b011  : image_o[3] = slice_sel;
        3'b100  : image_o[4] = slice_sel;
        3'b101  : image_o[5] = slice_sel;
        3'b110  : image_o[6] = slice_sel;
        3'b101  : image_o[7] = slice_sel;
    endcase
end

flopenr #(8) reg0 (clk, rst, en, slice_i, slice_sel);

endmodule

module flopenr #(parameter WIDTH = 8) (
    input logic clk, reset, en,
    input logic [WIDTH-1:0] d,
    input logic[WIDTH-1:0] q
);

always_ff @(posedge clk) begin
    if (reset) q <= WIDTH'b0;
    else if(en) q <= d;
end

endmodule