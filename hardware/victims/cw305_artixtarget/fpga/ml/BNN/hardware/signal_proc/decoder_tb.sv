module stimulus ();
    reg [7:0][7:0] image_construction;
    logic [7:0][7:0] image_test = {
        8'hFF,
        8'hFF,
        8'hFF,
        8'hFF,
        8'hFF,
        8'hFF,
        8'hFF,
        8'hFF
    };
    logic [2:0] sel = 3'b0;
    logic clk = 1'b0;
    logic en = 1'b1;
    logic rst = 1'b0;

    always #5 clk = ~clk;

    reg[7:0] selection_vector = 8'b0;

    image_stream_decoder DUT (
        .slice_i(selection_vector),
        .sel(sel),
        .en(en),
        .rst(rst),
        .clk(clk),
        .image_o(image_construction)
    );

    initial begin

        #0  rst = 1'b1;
        
        // slice 1
        #10 rst = 1'b0;
        #0 en = 1'b1;
        #0 selection_vector = image_test[0];
        #0 sel = 3'b000;

        // slice 2
        #10 selection_vector = image_test[1];
        #0 sel = 3'b001;

        // slice 3
        #10 selection_vector = image_test[2];
        #0 sel = 3'b010;

        // slice 4
        #10 selection_vector = image_test[3];
        #0 sel = 3'b011;

        // slice 5
        #10 selection_vector = image_test[4];
        #0 sel = 3'b100;

        // slice 6
        #10 selection_vector = image_test[5];
        #0 sel = 3'b101;

        // slice 7
        #10 selection_vector = image_test[6];
        #0 sel = 3'b110;

        // slice 8
        #10 selection_vector = image_test[7];
        #0 sel = 3'b111;

        #10 $display("Output image construction:");
        #10 $display(image_construction);
        // $finish();
    end

endmodule