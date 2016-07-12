//=================================================================
//  Copyright(c) Superion Technology Group Inc., 2016
//  ALL RIGHTS RESERVED
//  $Id:  $
//=================================================================
//
// File name:  : xlr8_atmega328clone.sv
// Author      : Stephen Fraleigh
// Description : 
//   Inside here (a couple layers deep) is a C model from the AVR core.
//   This module presents the same interface as the uc_top_wrap_vlog. It has all
//   of the same parameters, though they are unused because their values are
//   determined when the C model is generated. But this layer makes it easy to
//   interchange the RTL representation and C model.
//
//=================================================================
///////////////////////////////////////////////////////////////////

`ifndef XLR8_ATMEGA328CLONE_SV
`define XLR8_ATMEGA328CLONE_SV

module xlr8_atmega328clone
 #(parameter DESIGN_CONFIG = 9,       // use default image
   parameter UFM_ADR_WIDTH      = 13,
   parameter PM_REAL_SIZE       = 16,
   parameter UFM_BC_WIDTH       = 4
   )

  (
   input                            nrst,
   input                            clk,
   input                            en16mhz, // clock enable at 16MHz rate
   input                            en128khz,
   input                            clk_adcref,
   input                            locked_adcref,

   input                            pwr_on_nrst,
   output                           core_rstn, // includes all reset sources
   output logic                     rst_flash_n, // reset domain for flash+pmem
   // PORT related
   output [5:0]                     portb_portx, // [6:7] unused for port B, used for XTAL
   output [5:0]                     portb_ddrx,
   input [5:0]                      portb_pinx,
   output [5:0]                     portc_portx, // [6] unused for port C, used for RESET
   output [5:0]                     portc_ddrx,
   input [5:0]                      portc_pinx,
   output [7:0]                     portd_portx,
   output [7:0]                     portd_ddrx,
   input [7:0]                      portd_pinx,
   output [5:0]                     ADCD, // When set, corresponding PIN register on port c always reads 0
   output                           ANA_UP, // Choose ADC ref between AREF pin (1) and regulated 3.3V (0)

   // Timer related
   input                            T0_pin,
   input                            T1_pin,
   input                            ICP1_pin,
   output                           OC0A_pin,
   output                           OC0B_pin,
   output                           OC1A_pin,
   output                           OC1B_pin,
   output                           OC2A_pin,
   output                           OC2B_pin,
   output                           OC0A_enable,
   output                           OC0B_enable,
   output                           OC1A_enable,
   output                           OC1B_enable,
   output                           OC2A_enable,
   output                           OC2B_enable,

   // UART related
   input                            rxd,
   output                           uart_rx_en,
   output                           txd,
   output                           uart_tx_en,

   // SPI related
   input                            misoi,
   input                            mosii,
   input                            scki,
   input                            ss_b,

   output wire                      misoo,
   output wire                      mosio,
   output wire                      scko,
   output wire                      spe,
   output wire                      spimaster,

   //I2C related
   output wire                      twen,
   input                            sdain,
   output wire                      sdaout,
   input                            sclin,
   output wire                      sclout,

   // Interrupts
   input [23:0]                     pcint_rcv,
   output [23:0]                    pcmsk,
   output [2:0]                     pcie,
   output [1:0]                     eimsk,

   // PM interface
   output logic                     pm_ce,
   output logic                     pm_wr,
   output logic [15:0]              pm_wr_data,
   output logic [15:0]              pm_addr,
   input logic [15:0]               pm_rd_data,

   output logic [15:0]              pm_core_rd_addr,
   input logic [15:0]               pm_core_rd_data,

   // DM interface
   output wire [15:0]               dm_adr,
   output wire [7:0]                dm_dout,
   input [7:0]                      dm_din,
   output wire                      dm_ce,
   output wire                      dm_we,

   // Core Ram Interface
   output [7:0]                     core_ramadr_lo8,
   output                           core_ramre,
   output                           core_ramwe,
   output                           core_dm_sel,
   // FP Interface
   output [5:0]                     io_arb_mux_adr,
   output                           io_arb_mux_iore,
   output                           io_arb_mux_iowe,
   output [7:0]                     io_arb_mux_dbusout,
   input [7:0]                      stgi_xf_io_slv_dbusout,
   input                            stgi_xf_io_slv_out_en,
   output [7:0]                     msts_dbusout,
   output [8*32-1:0]                gprf,

   input logic  [23:0]              xb_info,
   output logic [23:0]              debug_bus
                        );



   uc_top_wrap_dpi uc_top_wrap_dpi_inst( /*AUTOINST*/
                                        // Outputs
                                        .core_rstn      (core_rstn),
                                        .rst_flash_n    (rst_flash_n),
                                        .portb_portx    (portb_portx[5:0]),
                                        .portb_ddrx     (portb_ddrx[5:0]),
                                        .portc_portx    (portc_portx[5:0]),
                                        .portc_ddrx     (portc_ddrx[5:0]),
                                        .portd_portx    (portd_portx[7:0]),
                                        .portd_ddrx     (portd_ddrx[7:0]),
                                        .ADCD           (ADCD[5:0]),
                                        .ANA_UP         (ANA_UP),
                                        .OC0A_pin       (OC0A_pin),
                                        .OC0B_pin       (OC0B_pin),
                                        .OC1A_pin       (OC1A_pin),
                                        .OC1B_pin       (OC1B_pin),
                                        .OC2A_pin       (OC2A_pin),
                                        .OC2B_pin       (OC2B_pin),
                                        .OC0A_enable    (OC0A_enable),
                                        .OC0B_enable    (OC0B_enable),
                                        .OC1A_enable    (OC1A_enable),
                                        .OC1B_enable    (OC1B_enable),
                                        .OC2A_enable    (OC2A_enable),
                                        .OC2B_enable    (OC2B_enable),
                                        .uart_rx_en     (uart_rx_en),
                                        .txd            (txd),
                                        .uart_tx_en     (uart_tx_en),
                                        .misoo          (misoo),
                                        .mosio          (mosio),
                                        .scko           (scko),
                                        .spe            (spe),
                                        .spimaster      (spimaster),
                                        .twen           (twen),
                                        .sdaout         (sdaout),
                                        .sclout         (sclout),
                                        .pcmsk          (pcmsk[23:0]),
                                        .pcie           (pcie[2:0]),
                                        .eimsk          (eimsk[1:0]),
                                        .pm_ce          (pm_ce),
                                        .pm_wr          (pm_wr),
                                        .pm_wr_data     (pm_wr_data[15:0]),
                                        .pm_addr        (pm_addr[15:0]),
                                        .pm_core_rd_addr(pm_core_rd_addr[15:0]),
                                        .dm_adr         (dm_adr[15:0]),
                                        .dm_dout        (dm_dout[7:0]),
                                        .dm_ce          (dm_ce),
                                        .dm_we          (dm_we),
                                        .core_ramadr_lo8(core_ramadr_lo8[7:0]),
                                        .core_ramre     (core_ramre),
                                        .core_ramwe     (core_ramwe),
                                        .core_dm_sel    (core_dm_sel),
                                        .io_arb_mux_adr (io_arb_mux_adr[5:0]),
                                        .io_arb_mux_iore(io_arb_mux_iore),
                                        .io_arb_mux_iowe(io_arb_mux_iowe),
                                        .io_arb_mux_dbusout(io_arb_mux_dbusout[7:0]),
                                        .msts_dbusout   (msts_dbusout[7:0]),
                                        .gprf           (gprf[8*32-1:0]),
                                        .debug_bus      (debug_bus[23:0]),
                                        // Inputs
                                        .nrst           (nrst),
                                        .clk            (clk),
                                        .en16mhz        (en16mhz),
                                        .en128khz       (en128khz),
                                        .clk_adcref     (clk_adcref),
                                        .locked_adcref  (locked_adcref),
                                        .pwr_on_nrst    (pwr_on_nrst),
                                        .portb_pinx     (portb_pinx[5:0]),
                                        .portc_pinx     (portc_pinx[5:0]),
                                        .portd_pinx     (portd_pinx[7:0]),
                                        .T0_pin         (T0_pin),
                                        .T1_pin         (T1_pin),
                                        .ICP1_pin       (ICP1_pin),
                                        .rxd            (rxd),
                                        .misoi          (misoi),
                                        .mosii          (mosii),
                                        .scki           (scki),
                                        .ss_b           (ss_b),
                                        .sdain          (sdain),
                                        .sclin          (sclin),
                                        .pcint_rcv      (pcint_rcv[23:0]),
                                        .pm_rd_data     (pm_rd_data[15:0]),
                                        .pm_core_rd_data(pm_core_rd_data[15:0]),
                                        .dm_din         (dm_din[7:0]),
                                        .stgi_xf_io_slv_dbusout(stgi_xf_io_slv_dbusout[7:0]),
                                        .stgi_xf_io_slv_out_en(stgi_xf_io_slv_out_en),
                                        .xb_info        (xb_info[23:0]));
   
endmodule // xlr8_atmega328clone

`endif //  `ifndef XLR8_ATMEGA328CLONE_SV

// Local Variables:
// verilog-library-flags:("-y .")
// End:
