module stimulus();

    reg clk = 1'b1;
    wire buf_clk;

    clocks DUT(
        .usb_clk(clk),
        .usb_clk_buf(buf_clk)
    );
    
    always clk = #5 ~clk;

    initial begin
        $dumpfile("clocks.vcd");
        $dumpvars(0, stimulus);
        #200 $finish();
    end

endmodule
