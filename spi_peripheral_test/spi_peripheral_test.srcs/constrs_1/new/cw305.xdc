set_property IOSTANDARD LVCMOS33 [get_ports *]

# # CW305 clock and reset
# create_clock -period 10.000 -name pll_clk1 -waveform {0.000 5.000} [get_nets pll_clk1]

# # DUT input clock from PLL_CLK1:
# set_property PACKAGE_PIN N13 [get_ports pll_clk1]

# SPI interface - USB... 20, 19, 18, 17
set_property PACKAGE_PIN D5 [get_ports MOSI] 
set_property PACKAGE_PIN C4 [get_ports MISO]
set_property PACKAGE_PIN D6 [get_ports clk]
set_property PACKAGE_PIN C6 [get_ports CS]

# # SW4 button on board:
set_property PACKAGE_PIN R1 [get_ports reset]
# # LEDs

set_property DRIVE 8 [get_ports led1]
set_property DRIVE 8 [get_ports led2]
set_property DRIVE 8 [get_ports led3]
set_property PACKAGE_PIN T2 [get_ports led1]
set_property PACKAGE_PIN T3 [get_ports led2]
set_property PACKAGE_PIN T4 [get_ports led3]

# # --------------------------------------------------
# # Bitstream generation
# # --------------------------------------------------
# set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]


# set_output_delay  -clock [get_clocks slow_out_clk] -add_delay $untimed_id [get_ports led1]
# set_output_delay  -clock [get_clocks slow_out_clk] -add_delay $untimed_id [get_ports led2]
# set_output_delay  -clock [get_clocks slow_out_clk] -add_delay $untimed_id [get_ports led3]

# --------------------------------------------------
# Configuration pins
# --------------------------------------------------
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# --------------------------------------------------
# Bitstream generation
# --------------------------------------------------
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_IBUF]
