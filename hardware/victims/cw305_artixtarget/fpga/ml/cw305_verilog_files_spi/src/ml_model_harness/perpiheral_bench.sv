module stimulus();

    reg clk_r = 1'b1;
    wire clk;
    wire in_serial;
    wire serial_o;

    reg sclk_r = 1'b1;
    wire sclk;
    reg cs_r = 1'b1;
    wire cs;
    wire pico;
    wire poci;

    wire[7:0] test_unit;
    wire[7:0] result;

    reg loaded_r = 1'b1;
    wire loaded;

    wire rx_recv;

    assign cs = cs_r;
    assign clk = clk_r;
    assign sclk = sclk_r;
    assign loaded = loaded_r;
    

    PISO_Register serializer(
        .clk(clk),
        .load(loaded),
        .pi(test_unit),
        .so(pico),
        .en_L(1'b0)
    );

    spi_peripheral dut(
        .sclk(sclk),
        .pico(pico),
        .cs(cs),
        .poci(poci),
        .done(rx_recv)
    );

    SIPO_Register deserializer(
        .clk(clk),
        .si(poci),
        .po(result),
        .en_L(rx_recv)
    );

    always clk_r = #1 ~clk;
    always sclk_r = #1 ~sclk;
    assign test_unit = 8'hAC;
    initial begin
        #0 cs_r = 1'b0;
        $dumpfile("bench.vcd");
        $dumpvars(0, stimulus);
        #2 loaded_r = 1'b0;
        
        #500 $display("Entered: %h", test_unit);
        $display("Received: %h", result);
        $finish();
    end


endmodule