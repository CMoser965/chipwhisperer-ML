module SPI_Slave (
    input logic rst,
    input logic MOSI,
    input logic SCLK,
    input logic CS,
    output logic MISO,
    output logic[7:0] command
);

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