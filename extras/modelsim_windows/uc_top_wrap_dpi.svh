//=================================================================
//  Copyright(c) Superion Technology Group Inc., 2016
//  ALL RIGHTS RESERVED
//  $Id:  $
//=================================================================
//
// File name:  : uc_top_wrap_dpi.sv
// Author      : Stephen Fraleigh
// Description : 
//   Header for the top-most verilog representation of the Verilated AVR core.
//   This describes the interface to the C model.
//
//=================================================================
///////////////////////////////////////////////////////////////////

`ifndef UC_TOP_WRP_DPI_SVH
`define UC_TOP_WRP_DPI_SVH

typedef struct {

  byte     unsigned  nrst;
  byte     unsigned  clk;
  int      unsigned  param_app_xb0_enable;
  byte     unsigned  en16mhz;
  byte     unsigned  en128khz;
  byte     unsigned  clk_adcref;
  byte     unsigned  locked_adcref;
  byte     unsigned  pwr_on_nrst;
                    
  //byte     unsigned  boot_restore_n;
  byte     unsigned  portb_pinx;
  byte     unsigned  portc_pinx;
  byte     unsigned  portd_pinx;
  byte     unsigned  T0_pin;
  byte     unsigned  T1_pin;
  byte     unsigned  ICP1_pin;
  byte     unsigned  rxd;
  byte     unsigned  misoi;
  byte     unsigned  mosii;
  byte     unsigned  scki;
  byte     unsigned  ss_b;
  byte     unsigned  sdain;
  byte     unsigned  sclin;
  int      unsigned  pcint_rcv;
  byte     unsigned  xlr8_irq;
  shortint unsigned  pm_rd_data;
  shortint unsigned  pm_core_rd_data;
  byte     unsigned  dm_din;
  byte     unsigned  stgi_xf_io_slv_dbusout;
  byte     unsigned  stgi_xf_io_slv_out_en;

} uc_wrap_inputs_sv_t;


typedef struct {

  byte     unsigned  core_rstn; // includes all reset sources
  byte     unsigned  rst_flash_n; // reset domain for flash+pmem
  byte     unsigned  portb_portx;
  byte     unsigned  portb_ddrx;
  byte     unsigned  portc_portx;
  byte     unsigned  portc_ddrx;
  byte     unsigned  portd_portx;
  byte     unsigned  portd_ddrx;
  byte     unsigned  ADCD;
  byte     unsigned  ANA_UP;
  byte     unsigned  OC0A_pin;
  byte     unsigned  OC0B_pin;
  byte     unsigned  OC1A_pin;
  byte     unsigned  OC1B_pin;
  byte     unsigned  OC2A_pin;
  byte     unsigned  OC2B_pin;
  byte     unsigned  OC0A_enable;
  byte     unsigned  OC0B_enable;
  byte     unsigned  OC1A_enable;
  byte     unsigned  OC1B_enable;
  byte     unsigned  OC2A_enable;
  byte     unsigned  OC2B_enable;
  byte     unsigned  uart_rx_en;
  byte     unsigned  txd;
  byte     unsigned  uart_tx_en;
  byte     unsigned  misoo;
  byte     unsigned  mosio;
  byte     unsigned  scko;
  byte     unsigned  spe;
  byte     unsigned  spimaster;
  byte     unsigned  twen;
  byte     unsigned  sdaout;
  byte     unsigned  sclout;
  shortint unsigned  core_reg_z;
  int      unsigned  pcmsk;
  byte     unsigned  pcie;
  byte     unsigned  eimsk;
  byte     unsigned  xlr8_irq_ack;
  byte     unsigned  pm_ce;
  byte     unsigned  pm_wr;
  shortint unsigned  pm_wr_data;
  shortint unsigned  pm_addr;
  shortint unsigned  pm_core_rd_addr;
  shortint unsigned  dm_adr;
  byte     unsigned  dm_dout;
  byte     unsigned  dm_ce;
  byte     unsigned  dm_we;
  byte     unsigned  dm_dout_rg;
  byte     unsigned  core_ramadr_lo8;
  byte     unsigned  core_ramre;
  byte     unsigned  core_ramwe;
  byte     unsigned  core_dm_sel;
  byte     unsigned  io_arb_mux_adr;
  byte     unsigned  io_arb_mux_iore;
  byte     unsigned  io_arb_mux_iowe;
  byte     unsigned  io_arb_mux_dbusout;
  byte     unsigned  msts_dbusout;
  int      unsigned  gprf0; // Inside the model, this is an array of 8 32-bit values
  int      unsigned  gprf1;
  int      unsigned  gprf2;
  int      unsigned  gprf3;
  int      unsigned  gprf4;
  int      unsigned  gprf5;
  int      unsigned  gprf6;
  int      unsigned  gprf7;
  int      unsigned  debug_bus;

} uc_wrap_outputs_sv_t;


import "DPI-C" function void uc_top_wrap_wrap_init();
import "DPI-C" function void uc_top_wrap_wrap_run( input uc_wrap_inputs_sv_t inputs, output uc_wrap_outputs_sv_t outputs );
import "DPI-C" function void uc_top_wrap_wrap_final();

`endif //  `ifndef UC_TOP_WRP_DPI_SVH
