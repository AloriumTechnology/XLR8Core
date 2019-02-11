

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

set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {RX}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {TX}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D2}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D3}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D4}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D5}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D6}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D7}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D8}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D9}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {D13}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {DIG_IO_OE[0]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {DIG_IO_OE[1]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {DIG_IO_OE[2]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {DIG_IO_OE[3]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {DIG_IO_OE[4]}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {DIG_IO_OE[5]}]
#set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {JTAGEN}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {JT9}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {JT7}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {JT6}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {JT5}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {JT3}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {JT1}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {SOIC7}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {SOIC6}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {SOIC5}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {SOIC3}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {SOIC2}]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports {SOIC1}]

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


set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports A0]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports A1]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports A2]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports A3]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports A4]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports A5]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports RESET_N]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports SCL]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports SDA]

set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports D0]          
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports D1]          
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports b[1]]        
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports b[2]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports eth_miso]    
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports eth_ss]  
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[3]]
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[4]]        
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[5]]        
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[6]]        
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[7]]        
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[8]]        
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[9]]        
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[10]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[11]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[12]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[13]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[14]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[15]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[16]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[17]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[18]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[19]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[20]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[21]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[22]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[23]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[24]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[25]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[26]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[27]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[28]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[29]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[30]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[31]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[32]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[33]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[34]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[35]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[36]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[37]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports g[38]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports led[0]]      
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports led[1]]      
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports led[2]]      
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports led[3]]      
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports led[4]]      
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports led[5]]      
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports led[6]]      
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports led[7]]      
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p1[1]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p1[2]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p1[3]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p1[4]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p2[1]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p2[2]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p2[3]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p2[4]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p3[1]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p3[2]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p3[3]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p3[4]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p4[1]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p4[2]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p4[3]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p4[4]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p5[1]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p5[2]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p5[3]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p5[4]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p6[1]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p6[2]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p6[3]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p6[4]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p7[1]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p7[2]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p7[3]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p7[4]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p8[1]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p8[2]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p8[3]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports p8[4]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports sd_miso]     
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports sd_ss]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports sw[0]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports sw[1]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports sw[2]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports sw[3]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports sw[4]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports sw[5]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports sw[6]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports sw[7]]       
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports wifi_cfg]    
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports wifi_enable] 
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports wifi_irq]    
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports wifi_miso]   
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports wifi_resetn] 
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports wifi_ss]     
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports wifi_wake]   
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports xbee_d00]    
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports xbee_d01]    
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports xbee_d02]    
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports xbee_d03]    
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports xbee_d04]    
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports xbee_d05]    
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports xbee_d06]    
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports xbee_d07]    
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports xbee_d08]    
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports xbee_d09]    
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports xbee_d10]    
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports xbee_d11]    
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports xbee_d12]    
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports xbee_d13]    
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports xbee_d14]    
set_input_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_inp_dly [get_ports xbee_resetn] 

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
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {PIN13LED}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {DIG_IO_OE[0]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {DIG_IO_OE[1]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {DIG_IO_OE[2]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {DIG_IO_OE[3]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {DIG_IO_OE[4]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {DIG_IO_OE[5]}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {ANA_UP}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {I2C_ENABLE}]
#set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {JTAGEN}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {JT9}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {JT7}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {JT6}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {JT5}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {JT3}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {JT1}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {SOIC7}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {SOIC6}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {SOIC5}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {SOIC3}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {SOIC2}]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports {SOIC1}]

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
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports SCL]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports SDA]

set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports D0]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports D1]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports b[1]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports b[2]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports eth_miso]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports eth_mosi]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports eth_sck]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports eth_ss]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[3]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[4]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[5]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[6]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[7]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[8]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[9]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[10]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[11]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[12]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[13]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[14]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[15]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[16]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[17]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[18]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[19]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[20]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[21]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[22]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[23]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[24]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[25]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[26]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[27]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[28]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[29]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[30]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[31]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[32]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[33]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[34]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[35]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[36]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[37]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports g[38]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports led[0]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports led[1]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports led[2]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports led[3]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports led[4]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports led[5]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports led[6]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports led[7]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p1[1]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p1[2]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p1[3]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p1[4]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p2[1]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p2[2]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p2[3]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p2[4]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p3[1]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p3[2]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p3[3]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p3[4]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p4[1]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p4[2]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p4[3]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p4[4]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p5[1]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p5[2]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p5[3]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p5[4]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p6[1]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p6[2]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p6[3]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p6[4]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p7[1]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p7[2]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p7[3]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p7[4]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p8[1]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p8[2]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p8[3]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports p8[4]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports sd_miso]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports sd_mosi]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports sd_sck]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports sd_ss]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports sw[0]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports sw[1]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports sw[2]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports sw[3]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports sw[4]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports sw[5]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports sw[6]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports sw[7]]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports wifi_cfg]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports wifi_enable]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports wifi_irq]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports wifi_miso]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports wifi_mosi]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports wifi_resetn]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports wifi_sck]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports wifi_ss]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports wifi_wake]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports xbee_d00]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports xbee_d01]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports xbee_d02]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports xbee_d03]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports xbee_d04]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports xbee_d05]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports xbee_d06]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports xbee_d07]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports xbee_d08]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports xbee_d09]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports xbee_d10]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports xbee_d11]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports xbee_d12]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports xbee_d13]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports xbee_d14]
set_output_delay -add_delay  -clock [get_clocks {clk_virtual}]  $dig_out_dly [get_ports xbee_resetn]

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
set_false_path -from {Clock} -to {JT1}
set_false_path -from {RESET_N} -to {JT9}

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

#**************************************************************
# Read OpenXLR8 XB Specific Constraints 
#**************************************************************
read_sdc ../../../XLR8Build/extras/quartus/xlr8_top.sdc

