module stimulus ();
    logic [7:0][7:0] image_test = {
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

    decoder DUT (
        .slice_i(selection_vector),
        .sel(sel),
        .en(en),
        .rst(rst),
        .clk(clk),
        .image_o(selection_vector)
    );

    initial begin

        #0  rst = 1'b1;
        
        // slice 1
        #15 rst = 1'b0;
        #0 en = 1'b1;
        #0 selection_vector = image_test[0];
        #0 sel = 3'b000;

        // slice 2
        #5 selection_vector = image_test[1];
        #0 sel = 3'b001;

        // slice 3
        #5 selection_vector = image_test[2];
        #0 sel = 3'b010;

        // slice 4
        #5 selection_vector = image_test[3];
        #0 sel = 3'b011;

        // slice 5
        #5 selection_vector = image_test[4];
        #0 sel = 3'b100;

        // slice 6
        #5 selection_vector = image_test[5];
        #0 sel = 3'b101;

        // slice 7
        #5 selection_vector = image_test[6];
        #0 sel = 3'b110;

        // slice 8
        #5 selection_vector = image_test[7];
        #0 sel = 3'b101;

        // slice 2
        #5 selection_vector = image_test[0];
        #0 sel = 3'b000;
    end

endmodule