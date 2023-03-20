module peripheral_controller(
    input wire clk,
    input wire i_serial_input,
    output wire o_serial_out,
    
    input wire sclk,
    input wire pico,
    input wire cs,
    output wire poci
);

reg[7:0]  tx_r;
reg[7:0]  rx_r;
reg       rst_r;

wire[7:0] tx;
wire[7:0] rx;
wire      rst = 1'b0;
wire      done;
reg      tx_dv;

integer i;

initial begin
    i = 32'b0;
    tx_dv = 1'b0;
end

SIPO_Register input_r(
    .clk(clk),
    .si(pico),
    .po(tx),
    .en_L(~tx_dv)
);

always @(posedge clk) begin
    if(i < 32'd8 & ~done) begin
        i <= i+1;
    end
    else if (done) begin
        i <= i-1;
    end else if (i >= 32'd8 & ~done) begin
        tx_dv <= 1;
    end
end

wire pico2;

PISO_Register readthrough(
    .clk(clk),
    .load(tx_dv),
    .pi(tx),
    .so(pico2),
    .en_L(tx_dv)
);

SPI_Peripheral #(.SPI_MODE(0)) spi_proc (
    .i_Rst_L(rst),
    .i_Clk(clk),
    .o_RX_DV(done),
    .o_RX_Byte(rx),
    .i_TX_DV(tx_dv),
    .i_TX_Byte(tx), 
   
    // SPI Interface
    .i_SPI_Clk(sclk),
    .o_SPI_MISO(poci),
    .i_SPI_MOSI(pico2),
    .i_SPI_CS_n(cs)        // active low
    );

PISO_Register output_r (
    .clk(clk),
    .load(done),
    .pi(rx_r),
    .so(o_serial_out)
);


endmodule