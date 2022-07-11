## Generated SDC file "uc_top_vlog.out.sdc"

## Copyright (C) 1991-2015 Altera Corporation. All rights reserved.
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, the Altera Quartus II License Agreement,
## the Altera MegaCore Function License Agreement, or other 
## applicable license agreement, including, without limitation, 
## that your use is for the sole purpose of programming logic 
## devices manufactured by Altera and sold by Altera or its 
## authorized distributors.  Please refer to the applicable 
## agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 14.1.1 Build 190 01/19/2015 SJ Full Version"

## DATE    "Wed Apr 29 13:24:20 2015"

##
## DEVICE  "10M50DAF256C8G"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************
if {[info exists base_clk_period]} {
  ## already set by another sdc file
} else {
  set base_clk_period 62.5
}

# core clock
#create_clock -name {Clock} -period $base_clk_period -waveform [list 0.000 [expr $base_clk_period / 2 ] ] [get_ports {Clock}]
derive_pll_clocks -create_base_clocks

# for SPI:
#create_clock -name clk_scki -period $base_clk_period [get_ports Digital\[13\]]
create_clock -name clk_scki -period $base_clk_period  [get_pins {uc_top_wrp_vlog_inst|clk_scki_buffer|combout}]


# for IO
create_clock -name clk_virtual -period $base_clk_period


#**************************************************************
# Create Generated Clock
#**************************************************************

# "clock" created in altera flash IP. The flash sdc file doesn't
#  define it as a clock, but timequest reports an error about
#  it being an undefined clock, so we'll try to do the right thing.
#create_generated_clock -name undefined_altera_flash_read_state_clock -source [get_ports {Clock}] -divide_by 2 [get_pins {uc_top_wrp_vlog_inst|flashload_inst|flash_inst|onchip_flash_0|altera_onchip_flash_block|ufm_block|se}]
#{|xlr8_alorium_top|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|ufm_block|SE}]
#create_generated_clock -name undefined_altera_flash_read_state_clock -source {uc_top_wrp_vlog_inst|flashload_inst|flash_inst|onchip_flash_0|avmm_data_controller|read_state.READ_STATE_SETUP|clk} -divide_by 2 [get_pins {uc_top_wrp_vlog_inst|flashload_inst|flash_inst|onchip_flash_0|altera_onchip_flash_block|ufm_block|se}]
create_generated_clock -name undefined_altera_flash_read_state_clock -source {uc_top_wrp_vlog_inst|flashload_inst|flash_inst|onchip_flash_0|avmm_data_controller|read_state.READ_STATE_SETUP|clk} -divide_by 2 [get_pins {uc_top_wrp_vlog_inst|flashload_inst|flash_inst|onchip_flash_0|avmm_data_controller|read_state.READ_STATE_SETUP|q}]



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -to [get_clocks {Clock}] 0.5
set_clock_uncertainty -to [get_clocks {clk_scki}] 0.5
set_clock_uncertainty -to [get_clocks {clk_virtual}] 0.5
set_clock_uncertainty -rise_from [get_clocks {Clock}] -rise_to [get_clocks {Clock}]  0.500  
set_clock_uncertainty -rise_from [get_clocks {Clock}] -fall_to [get_clocks {Clock}]  0.500  
set_clock_uncertainty -fall_from [get_clocks {Clock}] -rise_to [get_clocks {Clock}]  0.500  
set_clock_uncertainty -fall_from [get_clocks {Clock}] -fall_to [get_clocks {Clock}]  0.500  
derive_clock_uncertainty
#set_clock_uncertainty -to [get_clocks {int_osc_clk}] 0.5
#set_clock_uncertainty -to [get_clocks {uc_top_wrp_vlog_inst|flashload_inst|flash_inst|onchip_flash_0|altera_onchip_flash_block|ufm_block|osc}] 0.5
#set_clock_uncertainty -to [get_clocks {clocks_inst|pll_inst|altpll_component|auto_generated|pll1|clk[0]}] 0.5
#set_clock_uncertainty -to [get_clocks {clocks_inst|pll_inst|altpll_component|auto_generated|pll1|clk[1]}] 0.5
#set_clock_uncertainty -to [get_clocks {clocks_inst|pll_inst|altpll_component|auto_generated|pll1|clk[2]}] 0.5
#set_clock_uncertainty -to [get_clocks {clocks_inst|pll_inst|altpll_component|auto_generated|pll1|clk[3]}] 0.5
#set_clock_uncertainty -to [get_clocks {clocks_inst|pll_inst|altpll_component|auto_generated|pll1|clk[4]}] 0.5
#set_clock_uncertainty -to [get_clocks {undefined_altera_flash_read_state_clock}] 0.5

#**************************************************************
# Fix timing error due to Quartus bug
#**************************************************************
# The following constraint should fix the unconstrained clock error from the max10flash IP block. See the following SR for details -
# https://www.altera.com/support/support-resources/knowledge-base/tools/2016/warning--332060---node---alteraonchipflash-onchipflash-alteraonc.html

  create_generated_clock -name flash_se_neg_reg -divide_by 2 -source [get_pins -compatibility_mode { *altera_onchip_flash:*onchip_flash_0|altera_onchip_flash_avmm_data_controller:avmm_data_controller|flash_se_neg_reg|clk }] [get_pins -compatibility_mode { *altera_onchip_flash:*onchip_flash_0|altera_onchip_flash_avmm_data_controller:avmm_data_controller|flash_se_neg_reg|q } ]


#**************************************************************
# Set Input Delay
#**************************************************************
# limited by the ext_int path (combinational logic in the path)
#set dig_inp_dly 56.0
set dig_inp_dly [expr $base_clk_period/2.0 - 6.5]
set dig10_inp_dly $dig_inp_dly
#set dig11_inp_dly 52.0
set dig11_inp_dly [expr $base_clk_period/2.0 - 10.5]
set dig12_inp_dly $dig10_inp_dly

set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports RESET_N]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports SCL]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports SDA]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {RX}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {TX}]

set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D0}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D1}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D2}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D3}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D4}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D5}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D6}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D7}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D8}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D9}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D13}]

set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports A0]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports A1]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports A2]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports A3]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports A4]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports A5]

# pcint sync limitted  -2.8 @ 60
set_input_delay -clock [get_clocks {Clock}] $dig10_inp_dly [get_ports {D10}]

# spi miso: no clk_scki path
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig12_inp_dly [get_ports {D12}]

# ext_int limitted -5.5 @ 60
set_input_delay -clock [get_clocks {Clock}]  $dig11_inp_dly [get_ports {D11}]

# spi ss: constraint done in set_max_delay.  need to set to specify input delay to scki to make
# set_max_delay work (need a relative clock to register a max delay!) :-(
set_input_delay -add_delay -clock [get_clocks {clk_scki}] 0 [get_ports {D10}]

# spi mosi: done in set_max_delay
set_input_delay -add_delay -clock [get_clocks {clk_scki}] 0 [get_ports {D11}]


set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D22}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D23}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D24}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D25}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D26}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D27}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D28}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D29}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D30}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D31}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D32}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D33}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D34}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D35}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D36}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D37}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D38}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D49}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D40}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D41}]

set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[0]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[1]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[2]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[3]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[4]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[5]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[6]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[7]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[8]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[9]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[10]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[11]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[12]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[13]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[14]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[15]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[16]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[17]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[18]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[19]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[20]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[21]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[22]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[23]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[24]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[25]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[26]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[27]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[28]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[29]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[30]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {J[31]}]

set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[0]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[1]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[2]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[3]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[4]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[5]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[6]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[7]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[8]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[9]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[10]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[11]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[12]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[13]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[14]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[15]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[16]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[17]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[18]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[19]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[20]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[21]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[22]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[23]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[24]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[25]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[26]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[27]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[28]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[29]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[30]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {K[31]}]

set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {PL[0]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {PL[1]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {PL[2]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {PL[3]}]

#**************************************************************
# Set Output Delay
#**************************************************************
# worst case path: timer_counter*->Digital: -1.4ns @ 54ns.
# default digital input delay
#set dig_out_dly 51.0
set dig_out_dly [expr $base_clk_period - 11.5]
set dig12_out_dly $dig_out_dly

set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {RX}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {TX}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {PIN13LED}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports SCL]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports SDA]

set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D0}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D1}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D2}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D3}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D4}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D5}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D6}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D7}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D8}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D9}]
set_output_delay -add_delay  -clock [get_clocks {Clock}]  $dig_out_dly [get_ports {D10}]
set_output_delay -add_delay  -clock [get_clocks {Clock}]  $dig_out_dly [get_ports {D11}]
set_output_delay -add_delay  -clock [get_clocks {Clock}]  $dig_out_dly [get_ports {D12}]
set_output_delay -add_delay  -clock [get_clocks {Clock}]  $dig_out_dly [get_ports {D13}]

# spi delays: done in set_max_delay
#set_output_delay -add_delay  -clock_fall -clock [get_clocks {clk_scki}]  62.000 [get_ports {D12}]
set_output_delay -add_delay  -clock [get_clocks {clk_scki}]  0.000 [get_ports {D10}]
set_output_delay -add_delay  -clock [get_clocks {clk_scki}]  0.000 [get_ports {D11}]
set_output_delay -add_delay  -clock [get_clocks {clk_scki}]  0.000 [get_ports {D12}]
set_output_delay -add_delay  -clock [get_clocks {clk_scki}]  0.000 [get_ports {D13}]

set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports A0]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports A1]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports A2]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports A3]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports A4]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports A5]

set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D22}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D23}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D24}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D25}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D26}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D27}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D28}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D29}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D30}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D31}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D32}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D33}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D34}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D35}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D36}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D37}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D38}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D39}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D40}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {D41}]

set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[4]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[5]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[6]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[7]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[8]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[9]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[10]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[11]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[12]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[13]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[14]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[15]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[16]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[17]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[18]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[19]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[20]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[21]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[22]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[23]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[24]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[25]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[26]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[27]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[28]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[29]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[30]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {J[31]}]

set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[4]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[5]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[6]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[7]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[8]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[9]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[10]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[11]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[12]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[13]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[14]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[15]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[16]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[17]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[18]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[19]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[20]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[21]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[22]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[23]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[24]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[25]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[26]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[27]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[28]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[29]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[30]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {K[31]}]

set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {PL[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {PL[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {PL[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {PL[3]}]

#**************************************************************
# Set Clock Groups
#**************************************************************
# for slave SPI mode: scki comes in on D13
set_clock_groups -exclusive -group [get_clocks {Clock}] -group [get_clocks {clk_scki}]


#**************************************************************
# Set False Path
#**************************************************************
set_false_path -from {xlr8_clocks:clocks_inst|clkcnt_intosc[9]} -to {D8}
set_false_path -from {D13} -to {PIN13LED}
# Will need to change when we put real logic behind the JTAG pins

# these look like a bogus paths in the Altera Flash model that are being
#  reported as hold failures. Set false path node to node so we don't
#  accidentally false path anything extra that shouldn't be.
post_message -type warning "Setting false path on altera_onchip_flash_block|drdout"
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[0]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[0]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[1]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[1]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[2]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[2]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[3]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[3]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[4]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[4]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[5]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[5]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[6]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[6]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[7]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[7]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[8]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[8]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[9]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[9]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[10]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[10]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[11]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[11]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[12]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[12]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[13]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[13]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[14]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[14]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[15]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[15]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[16]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[16]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[17]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[17]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[18]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[18]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[19]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[19]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[20]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[20]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[21]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[21]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[22]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[22]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[23]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[23]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[24]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[24]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[25]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[25]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[26]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[26]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[27]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[27]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[28]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[28]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[29]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[29]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[30]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[30]}
set_false_path -from {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[31]} -to {xlr8_atmega328clone:uc_top_wrp_vlog_inst|xlr8_flashload:flashload_inst|max10flash:flash_inst|altera_onchip_flash:onchip_flash_0|altera_onchip_flash_block:altera_onchip_flash_block|drdout[31]}

#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************
set_max_delay -from [get_ports {D10}] -to [get_registers *avr_spi_sckd:u_sckd*] 3.0
set_max_delay -from [get_ports {D11}] -to [get_registers *avr_spi_sckd:u_sckd*] 3.0
set_max_delay -from [get_clocks {clk_scki}] -to [get_ports {RX TX D2 D3 D4 D5 D6 D7 D8 D9 D10 D11 D12 D13}] 11.000

# spi ss reset path
set_max_delay -from [get_ports {D10}] -to [get_pins {uc_top_wrp_vlog_inst|spi_inst|u_sckd|misoo_cpha0_fall|clrn uc_top_wrp_vlog_inst|spi_inst|u_sckd|misoo_cpha0_rise|clrn uc_top_wrp_vlog_inst|spi_inst|u_sckd|misoo_cpha1_fall|clrn uc_top_wrp_vlog_inst|spi_inst|u_sckd|misoo_cpha1_rise|clrn uc_top_wrp_vlog_inst|spi_inst|u_sckd|scki_div2_fall|clrn uc_top_wrp_vlog_inst|spi_inst|u_sckd|scki_div2_rise|clrn uc_top_wrp_vlog_inst|spi_inst|u_sckd|xfer0_fall|clrn uc_top_wrp_vlog_inst|spi_inst|u_sckd|xfer0_rise|clrn uc_top_wrp_vlog_inst|spi_inst|u_sckd|xfer_cnt[0]|clrn uc_top_wrp_vlog_inst|spi_inst|u_sckd|xfer_cnt[1]|clrn uc_top_wrp_vlog_inst|spi_inst|u_sckd|xfer_cnt[2]|clrn uc_top_wrp_vlog_inst|spi_inst|u_sckd|xfer_cnt_zero|clrn}] 12.000

# data delay was 6.974.  Plus Plus skew: 7.5 ns.  
set dig10_to_dig12_data_dly 9
set_max_delay -from [get_ports {D10}] -to [get_ports {D12}] [expr $dig10_inp_dly + $dig12_out_dly + $dig10_to_dig12_data_dly]

#**************************************************************
# Set Minimum Delay
#**************************************************************


#**************************************************************
# Set Input Transition
#**************************************************************

