module LCD_Controller ( // https://www.openhacks.com/uploadsproductos/eone-1602a1.pdf
    input  logic [9:0][4:0] values,
    input clk,
    input rst,
    input en,
    output logic done,
    output logic RS,
    output logic RW,
    output E,
    output logic [7:0] DB
);

wire[7:0] shiftL = 8'b0000_0100;
wire[7:0] shiftR = 8'b0000_0101;
wire[7:0] shiftLC = 8'b0000_0110;
wire[7:0] shiftRC = 8'b0000_0111;


reg[3:0] counter = 5'b0;

assign E = en & ~done;

always @(rst & en) begin // clear display
    {RS, RW, DB[7:1]} <= 8'b0;
    DB[0] <= 1'b1;
end

always @(posedge clk) begin
    counter <= counter + 1;
    DB[7:4] <= 4'h3;
    DB[3:0] <= counter;
    {RS, RW} <= 2'b11;
end

always @(negedge clk) begin
    {RS, RW, DB[7:1]} <= shiftR;
end

always @(counter[3] & ~counter[2] & counter[1] & ~counter[0]) begin
    counter <= 4'b0;
    done <= 1'b1;
end


endmodule