// *****************************************************************************************
// AVR synthesis control package
// Version 2.4 
// Modified 28.04.2015
// Designed by Ruslan Lepetenok
// Modified by Ma Weber
// *****************************************************************************************

// package synth_ctrl_pack is                                                   
        
`ifdef C_SYNTH_CTRL_PACK_VH     
        
        
`else

`define C_SYNTH_CTRL_PACK_VH TRUE
        
// pragma translate_off
// `define c_in_hex_file       : string := "E:\avr_tests\avr_test1.hex"
// pragma translate_on  
        
`define c_synth_on           1
`define c_pm_size            16
`define c_dm_size            2
`define c_bm_use_ext_tmr     0 
`define c_dm_mst_num         1 
`define c_dm_slv_num         1 
//`define c_dm_slv_num         3 
`define c_use_rst            1
`define c_irqs_width         26
//`define c_irqs_width         23
`define c_pc22b_core         0 
`define c_io_slv_num        16
`define c_sram_chip_num      1
`define c_impl_synth_core    1
`define c_impl_jtag_ocd_prg  0
//`define c_impl_jtag_ocd_prg  1
`define c_impl_usart         0
`define c_impl_ext_dbg_sys   1
`define c_impl_smb           1
`define c_impl_spi           1
`define c_impl_wdt           1 
`define c_impl_srctrl        0
`define c_impl_hw_bm         0

// c_tech_virtex
//`define c_tech               1
//`define c_tech               4    
`define c_tech               7    


`define c_rst_act_high       0

`define c_old_pm             0

// Added 
// `define c_dm_int_sram_read_ws 0

// following adds a wait state into d_mem read access if set.
// 0: 2 cycle LD time
// 1: 3 cycle LD time
`define c_dm_int_sram_read_ws 0

`endif

// end synth_ctrl_pack
