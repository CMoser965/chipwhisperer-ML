module stimulus();

reg clk = 1'b1;

reg[7:0] results;

logic MOSI;
wire MISO;
logic CS = 1'b0;
logic reset = 1'b0;

always @(posedge(clk)) begin
    results <= {results[6:0], MISO};
    MOSI <= 1'b1;
end


always clk = #5 ~clk;

SPI_Slave DUT(
    .rst(reset),
    .MOSI(clk),
    .MISO(MISO),
    .SCLK(clk),
    .CS(CS)
);

initial begin
    $dumpfile("spi_slave_bench.wvs");
    $dumpvars(0, stimulus);
    #80 $display(results);
    #100 reset = 1'b1;
    #120 reset = 1'b0;

    #200 $finish;

end

endmodule