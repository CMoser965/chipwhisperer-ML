module cw305 (

    input logic clk,
    input logic MOSI,
    input logic MISO,
    input logic CS,
    input logic reset,

    output logic led1,
    output logic led2,        
    output logic led3
);

reg[7:0] command;

SPI_Slave DUT(
    .rst(reset),
    .SCLK(clk),
    .MOSI(MOSI),
    .MISO(MISO),
    .CS(CS),
    .data(command)
);

always_comb begin
    
    case(command)
        8'h01: begin
            led1 = 1'b1;
            led2 = 1'b0;
            led3 = 1'b0;
        end
        8'h02: begin
            led1 = 1'b1;
            led2 = 1'b1;
            led3 = 1'b0;
        end
        8'h03: begin
            led1 = 1'b1;
            led2 = 1'b0;
            led3 = 1'b1;
        end
        default: begin
            led1 = 1'b1;
            led2 = 1'b1;
            led3 = 1'b1;
        end

    endcase

end



endmodule