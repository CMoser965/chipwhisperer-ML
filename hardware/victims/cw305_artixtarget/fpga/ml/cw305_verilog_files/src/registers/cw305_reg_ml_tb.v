module stimulus();

    reg usb_clk = 1'b1;
    wire clk;
    assign clk = usb_clk;
    reg reg_read = 1'b0;
    reg reg_write = 1'b0;
    wire reg_addrvalid = 1'b1;

    wire [7-1:0] reg_bytecnt = 1'b0;
    reg [21 - 7 - 1:0] reg_address;
    reg [7:0] write_data = 1'b1;
    wire [7:0] read_data; // out

    wire [4-1:0]  inputs = 4'b0001;
    wire [16-1:0]  bias = 16'b0;
    wire [16-1:0]  weights = 16'b1111_1111_1111_1111;
    wire [4-1:0]  outputs; 
    
    cw305_reg_ml #(
        .pADDR_WIDTH(21), 
        .pBYTECNT_SIZE(7), 
        .pWEIGHTCNT(16), 
        .pINPUTCNT(4),
        .pBIASCNT(16),
        .pOUTPUTCNT(4)) registers(
            .usb_clk(clk),                  //in  
            .reg_address(reg_address),      //in  
            .reg_bytecnt(reg_bytecnt),      //in  
            .read_data(read_data),          //out 
            .write_data(write_data),        //in  
            .reg_read(reg_read),            //in  
            .reg_write(reg_write),          //in  
            .reg_addrvalid(reg_addrvalid)   //in  
        );

    always usb_clk = #4 ~clk;
    initial begin
        $dumpfile("regs.vcd");
        $dumpvars(0, stimulus);
        reg_write = 1'b1;
        reg_address = 'h04;
        write_data = inputs;
        reg_write = 1'b0;
        reg_read = 1'b1;
        #5 $display("waiting. . .");
        #5 $display("Address: %h", reg_address);
        #5 $display("Data to read: %b", read_data);
        #5 $display("Data to write: %b", write_data);
        reg_read = 1'b0;
        reg_write = 1'b1;
        reg_address = 'h05;
        write_data = weights;
        #5 $display("waiting. . .");
        reg_bytecnt = 1'b1;
        #1 reg_write = 1'b0;
        reg_bytecnt = 1'b0;
        #5 $display("Address: %h", reg_address);
        reg_read = 1'b1;
        #5 $display("Data to read: %b", read_data);
        #5 $display("Data to write: %b", write_data);
        #5 reg_address = 'h06;
        write_data = bias;
        #5 $display("waiting. . .");
        #5 $display("Address: %h", reg_address);
        #5 $display("Data to read: %b", read_data);
        #5 $display("Data to write: %b", write_data);
        #5 reg_address = 'h07;
        #5 $display("waiting. . .");
        #5 $display("Address: %h", reg_address);
        #5 $display("Outputs: %b", read_data);
        // #5 $display("Data to write: %b", write_data);
        #5 $finish();
    end


endmodule