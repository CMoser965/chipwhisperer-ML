module SPI_Slave (
    input logic MOSI,
    input logic SCLK,
    input logic CS,
    output logic[7:0] command
);

always @(posedge SCLK) begin
    if(~CS) begin
        command <= {command[6:0], MOSI};
    end
end

always @(negedge CS) begin
    command <= 8'b0;
end
    
endmodule