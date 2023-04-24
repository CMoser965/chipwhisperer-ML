module image_stream_decoder (
    input       [7:0]       slice_i,
    input logic [2:0]       sel,
    input                   en,
    input                   clk,
    input                   rst,
    output reg [7:0][7:0]  image_o
);

reg [7:0] slice_sel;

always_comb begin
    case(sel) 
        3'b000  : image_o[0][7:0] = slice_sel;
        3'b001  : image_o[1][7:0] = slice_sel;
        3'b010  : image_o[2][7:0] = slice_sel;
        3'b011  : image_o[3][7:0] = slice_sel;
        3'b100  : image_o[4][7:0] = slice_sel;
        3'b101  : image_o[5][7:0] = slice_sel;
        3'b110  : image_o[6][7:0] = slice_sel;
        3'b111  : image_o[7][7:0] = slice_sel;
        default : break;
    endcase
end

flopenr #(8) reg0 (clk, rst, en, slice_i, slice_sel);

endmodule

module flopenr #(parameter WIDTH = 8) (
    input  logic clk, reset, en,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);

always_ff @(posedge clk) begin
    if (reset) q  <= 0;
    else if(en) q <= d;
end

endmodule