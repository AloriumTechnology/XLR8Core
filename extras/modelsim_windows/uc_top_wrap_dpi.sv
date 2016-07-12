//=================================================================
//  Copyright(c) Superion Technology Group Inc., 2016
//  ALL RIGHTS RESERVED
//  $Id:  $
//=================================================================
//
// File name:  : uc_top_wrap_dpi.sv
// Author      : Stephen Fraleigh
// Description : 
//   This is the bottom-most verilog representation of the Verilated AVR core. It has the same interface as
//   the verilog core, except it removes the parameters that control the synthesis of the core. Those
//   parameters are set when the AVR is compiled with Verilator. 
//
//=================================================================
///////////////////////////////////////////////////////////////////

`ifndef UC_TOP_WRAP_DPI_SV
`define UC_TOP_WRAP_DPI_SV

`include "uc_top_wrap_dpi.svh"

module uc_top_wrap_dpi
  #(
/* -----\/----- EXCLUDED -----\/-----
                         parameter FACTORY_IMAGE = 1,       // use default image
                         parameter tech                = 4, // !!! `c_tech,
                         parameter synth_on            = `c_synth_on,
                         parameter pm_size             = `c_pm_size,
                         parameter dm_size             = `c_dm_size,

                         parameter bm_use_ext_tmr      = `c_bm_use_ext_tmr,
                         parameter dm_mst_num          = `c_dm_mst_num,
                         parameter dm_slv_num          = `c_dm_slv_num,
                         parameter use_rst             = `c_use_rst,
                         parameter irqs_width          = `c_irqs_width,
                         parameter pc22b_core          = `c_pc22b_core,
                         parameter io_slv_num          = `c_io_slv_num,
                         parameter sram_chip_num       = `c_sram_chip_num,
                         parameter impl_synth_core     = `c_impl_synth_core,
                         parameter impl_jtag_ocd_prg   = `c_impl_jtag_ocd_prg,
                         parameter impl_usart          = `c_impl_usart,
                         parameter impl_ext_dbg_sys    = `c_impl_ext_dbg_sys,
                         parameter impl_smb            = `c_impl_smb,
                         parameter impl_spi            = `c_impl_spi,
                         parameter impl_wdt            = `c_impl_wdt,
                         parameter impl_srctrl         = `c_impl_srctrl,
                         parameter impl_hw_bm          = `c_impl_hw_bm,
                         parameter rst_act_high        = `c_rst_act_high,
                         parameter old_pm              = `c_old_pm,
                         // Added 31.12.11
                         parameter dm_int_sram_read_ws = `c_dm_int_sram_read_ws,  // DM access(read) wait stait is inserted
                         parameter impl_mul            = 1, // ???
 -----/\----- EXCLUDED -----/\----- */
                         parameter UFM_ADR_WIDTH      = 13,
                         parameter UFM_BC_WIDTH       = 4 // 1..8???
                         )

  (
   input                            nrst,
   input                            clk,
   input                            en16mhz, // clock enable at 16MHz rate
   input                            en128khz,
   input                            clk_adcref,
   input                            locked_adcref,

   input                            pwr_on_nrst,
   output logic                           core_rstn, // includes all reset sources
   output logic                     rst_flash_n, // reset domain for flash+pmem
   // PORT related
   output logic [5:0]                     portb_portx, // [6:7] unused for port B, used for XTAL
   output logic [5:0]                     portb_ddrx,
   input [5:0]                      portb_pinx,
   output logic [5:0]                     portc_portx, // [6] unused for port C, used for RESET
   output logic [5:0]                     portc_ddrx,
   input [5:0]                      portc_pinx,
   output logic [7:0]                     portd_portx,
   output logic [7:0]                     portd_ddrx,
   input [7:0]                      portd_pinx,
   output logic [5:0]                     ADCD, // When set, corresponding PIN register on port c always reads 0
   output logic                           ANA_UP, // Choose ADC ref between AREF pin (1) and regulated 3.3V (0)

   // Timer related
   input                            T0_pin,
   input                            T1_pin,
   input                            ICP1_pin,
   output logic                           OC0A_pin,
   output logic                           OC0B_pin,
   output logic                           OC1A_pin,
   output logic                           OC1B_pin,
   output logic                           OC2A_pin,
   output logic                           OC2B_pin,
   output logic                           OC0A_enable,
   output logic                           OC0B_enable,
   output logic                           OC1A_enable,
   output logic                           OC1B_enable,
   output logic                           OC2A_enable,
   output logic                           OC2B_enable,

   // UART related
   input                            rxd,
   output logic                           uart_rx_en,
   output logic                           txd,
   output logic                           uart_tx_en,

   // SPI related
   input                            misoi,
   input                            mosii,
   input                            scki,
   input                            ss_b,

   output logic                      misoo,
   output logic                      mosio,
   output logic                      scko,
   output logic                      spe,
   output logic                      spimaster,

   //I2C related
   output logic                      twen,
   input                            sdain,
   output logic                      sdaout,
   input                            sclin,
   output logic                      sclout,

   // Interrupts
   input [23:0]                     pcint_rcv,
   output logic [23:0]                    pcmsk,
   output logic [2:0]                     pcie,
   output logic [1:0]                     eimsk,

   // PM interface
   output logic                     pm_ce,
   output logic                     pm_wr,
   output logic [15:0]              pm_wr_data,
   output logic [15:0]              pm_addr,
   input logic [15:0]               pm_rd_data,

   output logic [15:0]              pm_core_rd_addr,
   input logic [15:0]               pm_core_rd_data,

   // DM interface
   output logic [15:0]               dm_adr,
   output logic [7:0]                dm_dout,
   input [7:0]                      dm_din,
   output logic                      dm_ce,
   output logic                      dm_we,

   // Core Ram Interface
   output logic [7:0]                     core_ramadr_lo8,
   output logic                           core_ramre,
   output logic                           core_ramwe,
   output logic                           core_dm_sel,
   // FP Interface
   output logic [5:0]                     io_arb_mux_adr,
   output logic                           io_arb_mux_iore,
   output logic                           io_arb_mux_iowe,
   output logic [7:0]                     io_arb_mux_dbusout,
   input [7:0]                      stgi_xf_io_slv_dbusout,
   input                            stgi_xf_io_slv_out_en,
   output logic [7:0]                     msts_dbusout,
   output logic [8*32-1:0]                gprf,

   input logic  [23:0]              xb_info,
   output logic [23:0]              debug_bus
                        );


   uc_wrap_inputs_sv_t  in;
   uc_wrap_outputs_sv_t out;


   initial uc_top_wrap_wrap_init();
   final   uc_top_wrap_wrap_final();
   
   always @( clk ) begin

      // Assign inputs
      in.nrst = nrst;
      in.clk = clk;
      in.en16mhz = en16mhz;
      in.en128khz = en128khz;
      in.clk_adcref = clk_adcref;
      in.locked_adcref = locked_adcref;
      in.pwr_on_nrst = pwr_on_nrst;
      in.portb_pinx = portb_pinx;
      in.portc_pinx = portc_pinx;
      in.portd_pinx = portd_pinx;
      in.T0_pin = T0_pin;
      in.T1_pin = T1_pin;
      in.ICP1_pin = ICP1_pin;
      in.rxd = rxd;
      in.misoi = misoi;
      in.mosii = mosii;
      in.scki = scki;
      in.ss_b = ss_b;
      in.sdain = sdain;
      in.sclin = sclin;
      in.pcint_rcv = pcint_rcv;
      in.pm_rd_data = pm_rd_data;
      in.pm_core_rd_data = pm_core_rd_data;
      in.dm_din = dm_din;
      in.stgi_xf_io_slv_dbusout = stgi_xf_io_slv_dbusout;
      in.stgi_xf_io_slv_out_en = stgi_xf_io_slv_out_en;
      in.xb_info = xb_info;

      // Call the model
      uc_top_wrap_wrap_run( in, out );
      
      // Copy outputs
      core_rstn <= out.core_rstn;
      rst_flash_n <= out.rst_flash_n;
      portb_portx <= out.portb_portx;
      portb_ddrx <= out.portb_ddrx;
      portc_portx <= out.portc_portx;
      portc_ddrx <= out.portc_ddrx;
      portd_portx <= out.portd_portx;
      portd_ddrx <= out.portd_ddrx;
      ADCD <= out.ADCD;
      ANA_UP <= out.ANA_UP;
      OC0A_pin <= out.OC0A_pin;
      OC0B_pin <= out.OC0B_pin;
      OC1A_pin <= out.OC1A_pin;
      OC1B_pin <= out.OC1B_pin;
      OC2A_pin <= out.OC2A_pin;
      OC2B_pin <= out.OC2B_pin;
      OC0A_enable <= out.OC0A_enable;
      OC0B_enable <= out.OC0B_enable;
      OC1A_enable <= out.OC1A_enable;
      OC1B_enable <= out.OC1B_enable;
      OC2A_enable <= out.OC2A_enable;
      OC2B_enable <= out.OC2B_enable;
      uart_rx_en <= out.uart_rx_en;
      txd <= out.txd;
      uart_tx_en <= out.uart_tx_en;
      misoo <= out.misoo;
      mosio <= out.mosio;
      scko <= out.scko;
      spe <= out.spe;
      spimaster <= out.spimaster;
      twen <= out.twen;
      sdaout <= out.sdaout;
      sclout <= out.sclout;
      pcmsk <= out.pcmsk;
      pcie <= out.pcie;
      eimsk <= out.eimsk;
      pm_ce <= out.pm_ce;
      pm_wr <= out.pm_wr;
      pm_wr_data <= out.pm_wr_data;
      pm_addr <= out.pm_addr;
      pm_core_rd_addr <= out.pm_core_rd_addr;
      dm_adr <= out.dm_adr;
      dm_dout <= out.dm_dout;
      dm_ce <= out.dm_ce;
      dm_we <= out.dm_we;
      core_ramadr_lo8 <= out.core_ramadr_lo8;
      core_ramre <= out.core_ramre;
      core_ramwe <= out.core_ramwe;
      core_dm_sel <= out.core_dm_sel;
      io_arb_mux_adr <= out.io_arb_mux_adr;
      io_arb_mux_iore <= out.io_arb_mux_iore;
      io_arb_mux_iowe <= out.io_arb_mux_iowe;
      io_arb_mux_dbusout <= out.io_arb_mux_dbusout;
      msts_dbusout <= out.msts_dbusout;
      gprf <= { out.gprf7, out.gprf6, out.gprf5, out.gprf4, out.gprf3, out.gprf2, out.gprf1, out.gprf0 };
      debug_bus <= out.debug_bus;
      
   end
   
endmodule // uc_top_wrap_dpi

`endif //  `ifndef UC_TOP_WRAP_DPI_SV
