module spi_peripheral (
    input wire sclk,
    input wire pico,
    input wire cs,
    output wire poci,
    output wire done
);

reg [7:0] r_pico;
reg[7:0] r_poci;
reg r_data_sent;
reg r_loaded;

wire [7:0] data_byte;
wire data_proc_state;
wire data_sent;
wire data_recv;

// assign data_sent = r_data_sent;
assign done = data_sent;

initial begin
    r_loaded = 1'b0;
    r_data_sent = 1'b1;
end


always @(posedge data_proc_state) begin
    case(data_byte) 
        8'hAA:  r_poci <= 8'h11;
        8'hAB:  r_poci <= 8'h12;
        8'hAC:  r_poci <= 8'h13;
        8'hAD:  r_poci <= 8'h14;
    endcase
end

always @(negedge sclk & data_proc_state) begin
    r_loaded <= 1'b1;
end

counter #(.count(10)) piso_serialized(
    .clk(sclk),
    .en_L(~data_recv & ~data_proc_state),
    .done(data_sent)
);

counter #(.count(1)) piso_load(
    .clk(sclk),
    .en_L(~data_proc_state),
    .done(data_recv)
);

PISO_Register piso_pipe(
    .clk(sclk),
    .load(~data_recv),
    .pi(r_poci),
    .so(poci),
    .en_L(~data_proc_state & ~data_recv)
);

counter data_counter(
    .clk(sclk),
    .en_L(cs),
    .done(data_proc_state)
);

SIPO_Register sipo_pipe(
    .clk(sclk),
    .si(pico),
    .po(data_byte),
    .en_L(data_proc_state)
);

endmodule