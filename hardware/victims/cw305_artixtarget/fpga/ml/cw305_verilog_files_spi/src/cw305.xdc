
######## HARDWARE ON BOARD

#LEDs
set_property DRIVE 8 [get_ports led1]
set_property PACKAGE_PIN T2 [get_ports led1]

set_property DRIVE 8 [get_ports led2]
set_property PACKAGE_PIN T3 [get_ports led2]

set_property DRIVE 8 [get_ports led3]
set_property PACKAGE_PIN T4 [get_ports led3]

####### USB Connector

set_property PACKAGE_PIN F5 [get_ports usb_clk]

set_property IOSTANDARD LVCMOS33 [get_ports *]

set_property PACKAGE_PIN D5 [get_ports usb_a20]
set_property PACKAGE_PIN C4 [get_ports usb_a19]
set_property PACKAGE_PIN D6 [get_ports usb_a18]
set_property PACKAGE_PIN C6 [get_ports usb_a17]


create_clock -period 10.000 -name usb_clk -waveform {0.000 5.000} [get_nets usb_clk]