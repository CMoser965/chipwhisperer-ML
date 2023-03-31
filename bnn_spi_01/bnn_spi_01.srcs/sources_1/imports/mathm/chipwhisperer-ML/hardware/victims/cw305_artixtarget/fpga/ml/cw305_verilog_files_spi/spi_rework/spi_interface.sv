module SPI_Slave (
    input logic rst,
    input logic MOSI,
    input logic SCLK,
    input logic CS,
    output logic MISO,
    output logic[7:0] data
);

reg[7:0] command;

initial begin
    assign data = command;
end

always @(posedge SCLK & ~CS | rst) begin
    if(rst) begin
        command <= 8'b0;
    end
    else begin
        command <= {command[6:0], MOSI};
        MISO <= MOSI;    
    end
    
end

    
endmodule