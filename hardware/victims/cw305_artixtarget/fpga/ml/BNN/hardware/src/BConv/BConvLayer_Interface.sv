module BConv_Interface #(
    parameter INPUT_H = 28,
    parameter INPUT_W = 28,
    parameter K_H = 3,
    parameter K_W = 3,    
    parameter OUTPUT_H = 26,
    parameter OUTPUT_W = 26
) (
    input  logic [INPUT_H-1:0][INPUT_W-1:0] layer_i,
    input  logic [K_H-1:0][K_W-1:0] kernel,
    input  logic clk,
    output logic  [OUTPUT_H-1:0][OUTPUT_W-1:0] layer_o
);

logic [8:0] input_slice;
logic [K_W*K_H-1:0] kernel_vect;


shift_reg #(.SIZE(INPUT_H)) layer_i_col[INPUT_W-1:0] (
    .d(layer_i[INPUT_W-1:0][INPUT_H-1:0]),
    .clk(clk),
    .en(1'b1),
    .dir(1'b1),
    .rstn(1'b1),
    .out(input_slice)
);



endmodule

module shift_reg #(parameter SIZE=8) (
    input d,
    input clk,
    input en,
    input dir,
    input rstn,
    output logic [SIZE-1:0] out
);

always @(posedge clk) begin
    if (!rstn)
    out <= 0;
    else begin
        if (en)
            case(dir)
                0: out <= {out[SIZE-2:0], d};
                1: out <= {d, out[SIZE-1:1]};
            endcase
        else 
            out <= out;
        end
end

endmodule