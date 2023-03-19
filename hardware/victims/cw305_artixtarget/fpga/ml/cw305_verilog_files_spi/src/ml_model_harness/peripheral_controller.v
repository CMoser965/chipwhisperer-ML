module peripheral_controller(
    input wire clk,
    input wire i_serial_input,
    output wire o_serial_out,
    
    input wire sclk,
    input wire pico,
    input wire cs,
    output wire poci
);

reg[7:0] tx_r;
reg[7:0] rx_r;
reg rst_r;

wire[7:0] tx;
wire[7:0] rx;
wire rst;
wire done;
wire tx_dv;

integer i;

SIPO_Register input_r(
    .clk(clk),
    .si(i_serial_input),
    .po(tx)
);

always @(posedge sclk & ~cs) begin
    if(i < 4'd8 & ~done) begin
        i <= i+1;
    end
    else if (done) begin
        i <= i-1;
    end else begin
        tx_dv <= 1;
    end
end



spi_peripheral #(.SPI_MODE(0)) spi_proc (
        .i_Rst_L(rst),
        .i_Clk(clk),
        .o_RX_DV(done),
        .o_RX_Byte(rx_r),
        .i_TX_DV(tx_dv),    // Data Valid pulse to register i_TX_Byte
        .i_TX_Byte(tx_r),  // Byte to serialize to MISO.
   
    // SPI Interface
    .i_SPI_Clk(sclk),
    .o_SPI_MISO(poci),
    .i_SPI_MOSI(pico),
    .i_SPI_CS_n(cs)        // active low
    );

PISO_Register output_r (
    .clk(clk),
    .load(done),
    .pi(rx_r),
    .so(o_serial_out)
);


endmodule