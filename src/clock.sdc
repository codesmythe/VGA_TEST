
create_clock -name "CLOCK_50" -period 20.000ns [get_ports {clk50M}]
#create_generated_clock -name clk25M -source [get_ports clk50M] -divide_by 2 [get_pins hvsync/clk]
derive_clock_uncertainty

