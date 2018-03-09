//////////////////////////////////////////////////////////////////
//=================================================================
//  Copyright(c) Superion Technology Group Inc., 2017
//  ALL RIGHTS RESERVED
//=================================================================
//
// File name:  : xlr8_hinj_bixb.v
// Author      : Steve Phillips
// Description : Built In XBs for the Hinj board
//
// The hinj_bixb module, pronounced "bicks bee", encapsulates the
// logic need to communicate with and control the Built IN XBs. The
// interfaces being controlled are the WiFi module, the Ethernet
// module, the SD Card and the XBee slot.
//
// The module consists mostly of instantiations of IP blocks such as
// the SPI, the AVR Port, the UART and the Portmux. The rest of the
// logic is to combine the output control and busses and interface to
// the alorium top.
//
// ------- ------- -------------  ---------------------------------
// xb_pinx wf_port Pin Name       Description
// ------- ------- -------------  ---------------------------------
//    27     17    wifi_sck       WiFi SPI Clock
//    26     16    wifi_ss        WiFi SPI Slave Select
//    25     15    wifi_mosi      WiFi SPI Data Out
//    24     14    wifi_miso      WiFi SPI Data In
//    23     13    wifi_irq       WiFi SPI Interrupt
//    22     12    wifi_txd       WiFi UART TX
//    21     11    wifi_rxd       WiFi UART RX
//    20     10    wifi_sda       WiFi I2C SDA
//    19      9    wifi_scl       WiFi I2C SCL
//    18      8    wifi_io1       WiFi IO1
//    17      7    wifi_io3       WiFi IO3
//    16      6    wifi_io4       WiFi IO4
//    15      5    wifi_io5       WiFi IO5
//    14      4    wifi_io6       WiFi IO6
//    13      3    wifi_enable    WiFi Enable
//    12      2    wifi_wake      WiFi Wake
//    11      1    wifi_resetn    WiFi Reset
//    10      0    wifi_cfg       WiFi Config
// ------- ------- -------------  ---------------------------------
// xb_pinx et_port Pin Name       Description
// ------- ------- -------------  ---------------------------------
//     9      5    eth_sck        Ethernet SPI Clock
//     8      4    eth_ss         Ethernet SPI Slave Select 
//     7      3    eth_mosi       Ethernet SPI Data Out
//     6      2    eth_miso       Ethernet SPI Data In
//     5      1    eth_int        Ethernet SPI Interrupt
//     4      0    eth_resetn     Ethernet SPI reset
// ------- ------- -------------  ---------------------------------
// xb_pinx sd_port Pin Name       Description
// ------- ------- -------------  ---------------------------------
//     3      3    sd_sck         SD SPI Clock
//     2      2    sd_ss          SD Card SPI Slave Select 
//     1      1    sd_mosi        SD Card SPI Data Out
//     0      0    sd_miso        SD Card SPI Data In
// ================================================================
//
// ///////////////////////////////////////////////////////////////////

  
module xlr8_hinj_bixb
  #(
    parameter DESIGN_CONFIG     = 8,
    parameter NUM_WIFI_PINS     = 18,
    parameter NUM_ETH_PINS      = 6,
    parameter NUM_SD_PINS       = 4,
    parameter NUM_BIXB_PINS     = NUM_WIFI_PINS + NUM_ETH_PINS + NUM_SD_PINS,
    parameter WIFI_SPCR_ADDR    = 8'hB5,
    parameter WIFI_SPSR_ADDR    = 8'hB7,
    parameter WIFI_SPDR_ADDR    = 8'hBE,
    parameter PORTBI_Address    = 8'hBF,
    parameter DDRBI_Address     = 8'hC3,
    parameter PINBI_Address     = 8'hC7,
    parameter ETH_SPCR_ADDR     = 8'hC8,
    parameter ETH_SPSR_ADDR     = 8'hC9,
    parameter ETH_SPDR_ADDR     = 8'hCA,
    parameter SD_SPCR_ADDR      = 8'hCB,
    parameter SD_SPSR_ADDR      = 8'hCC,
    parameter SD_SPDR_ADDR      = 8'hCD,
    parameter MSKBI_Address     = 8'hE7
    )
   (
    input                     clk,
    input                     rstn,
    // Standard dbus stuff
    input [5:0]               adr,
    input [7:0]               dbus_in,
    output [7:0]              dbus_out,
    input                     iore,
    input                     iowe,
    output                    io_out_en,
    // DM
    input [7:0]               ramadr,
    input                     ramre,
    input                     ramwe,
    input                     dm_sel,
    // Outputs
    // port_pads goes to the top level module I/O ports, ie: the chip pins
    inout [NUM_WIFI_PINS-1:0] wf_port_pads,
    inout [NUM_ETH_PINS-1:0]  et_port_pads,
    inout [NUM_SD_PINS-1:0]   sd_port_pads,
    // xb_pinx is the pin value for use by the XBs
    output logic [7:0]        bi_pinx,
    // Pin Change Interrupts to xlr8_pcit module
    output logic              pcint
    );

   localparam NUM_OXBS = 3;
   
   logic [NUM_BIXB_PINS-1:0]      xb_pinx;

   logic [7:0]                    wf_spi_dbus_out;
   logic                          wf_spi_out_en;
   logic                          wf_misoo, wf_mosio;
   logic                          wf_scko;
   logic                          wf_spe;
   logic                          wf_spimaster;
   logic                          wf_ss_b;
   logic                          wf_scki;  // FIXME: Going to tie this low for WiFi

   logic [NUM_WIFI_PINS-1:0]      wf_ddoe;
   logic [NUM_WIFI_PINS-1:0]      wf_ddov;
   logic [NUM_WIFI_PINS-1:0]      wf_pvoe;
   logic [NUM_WIFI_PINS-1:0]      wf_pvov;
   
   logic [NUM_WIFI_PINS-1:0]      wf_pinx;
   logic [NUM_WIFI_PINS-1:0]      wf_xb_pinx;
   
   logic [7:0]                    bi_port_dbus_out;
   logic                          bi_port_out_en;
   logic                          bi_pcifr_set;
   
   logic [7:0]                    bi_portx;
   logic [7:0]                    bi_ddrx;

   logic [7:0]                    et_spi_dbus_out;
   logic                          et_spi_out_en;
   logic                          et_misoo, et_mosio;
   logic                          et_scko;
   logic                          et_spe;
   logic                          et_spimaster;
   logic                          et_ss_b;
   logic                          et_scki;  // FIXME: Going to tie this low for WiFi

   logic [NUM_ETH_PINS-1:0]       et_ddoe;
   logic [NUM_ETH_PINS-1:0]       et_ddov;
   logic [NUM_ETH_PINS-1:0]       et_pvoe;
   logic [NUM_ETH_PINS-1:0]       et_pvov;

   logic [NUM_ETH_PINS-1:0]       et_pinx;
   logic [NUM_ETH_PINS-1:0]       et_xb_pinx;

   logic [7:0]                    sd_spi_dbus_out;
   logic                          sd_spi_out_en;
   logic                          sd_misoo, sd_mosio;
   logic                          sd_scko;
   logic                          sd_spe;
   logic                          sd_spimaster;
   logic                          sd_ss_b;
   logic                          sd_scki;  // FIXME: Going to tie this low for WiFi

   logic [NUM_SD_PINS-1:0]        sd_ddoe;
   logic [NUM_SD_PINS-1:0]        sd_ddov;
   logic [NUM_SD_PINS-1:0]        sd_pvoe;
   logic [NUM_SD_PINS-1:0]        sd_pvov;

   logic [NUM_SD_PINS-1:0]        sd_pinx;
   logic [NUM_SD_PINS-1:0]        sd_xb_pinx;

   //===========================================================================

   // Send the gpio pin change interrupt to the hinj_pcint module
//   assign pcint = bi_pcifr_set;
   assign pcint = 1'b0; // Disconnect this since we are now shipping our WiFi 
                        // pins to core/ext_int as replacements for port C
   
   


   //===========================================================================
   //
   // BIXB GPIO Port
   //
   //===========================================================================

   //----------------------------------------------------------------------
   // Instance Name:  port_bi_inst
   // Module Type:    xlr8_avr_port
   //----------------------------------------------------------------------
   //
   // Eight bit port to control the signals associated with the wifi, eth, 
   // and sd  module that need to be controlled from software. They are as 
   // follows:
   //
   // portbi[7] = SD SPI SS bit
   // portbi[6] = Eth SPI SS bit
   // portbi[5] = WiFi SPI SS bit
   // portbi[4] = Interrupt (IRQN), device interrupt
   // portbi[3] = Enable (EN or CHIP_EN), enables the module
   // portbi[2] = Wake
   // portbi[1] = Reset (RESET_N), hard reset
   // portbi[0] = Config (SPI_CFG), SPI enable
   //
   //----------------------------------------------------------------------
   xlr8_avr_port 
     #(
       .PORTX_ADDR    (PORTBI_Address),
       .DDRX_ADDR     (DDRBI_Address),
       .PINX_ADDR     (PINBI_Address),
       .PCMSK_ADDR    (MSKBI_Address),
       .DDRX_RST_VAL  (8'b00001111), // [sd:ss, et:ss, wf:ss_b,irqn,en,wake,resetn,cfg]
       .PORTX_RST_VAL (8'b00001001), // [sd:ss, et:ss, wf:ss_b,irqn,en,wake,resetn,cfg]
       .PCMSK_RST_VAL (8'hFF), //       [sd:ss, et:ss, wf:ss_b,irqn,en,wake,resetn,cfg]
       .WIDTH         (8)
       )
   port_bi_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      .clken       (1'b1),
      // I/O
      .adr         (adr),
      .dbus_in     (dbus_in),
      .dbus_out    (bi_port_dbus_out),
      .iore        (iore),
      .iowe        (iowe),
      .io_out_en   (bi_port_out_en),
      // DM
      .ramadr      (ramadr),
      .ramre       (ramre),
      .ramwe       (ramwe),
      .dm_sel      (dm_sel),
      // External connection
      .portx       (bi_portx[7:0]), // To portmux module
      .ddrx        (bi_ddrx[7:0]),  // To portmux module
      .pinx        (bi_pinx[7:0]),  // From portmux module
      .pcifr_set   (bi_pcifr_set) //   Pin Change Int to xlr8_pcint
      );

   //===========================================================================
   //
   // WIFI INTERFACE
   //
   //===========================================================================
   
   // pull out input values from pins
   assign wf_scki   = 1'b0; // we only operate in master mode
   assign wf_ss_b   = xb_pinx[26];
   assign wf_mosii  = xb_pinx[25];
   assign wf_misoi  = xb_pinx[24];
   
   //----------------------------------------------------------------------
   // Instance Name:  wifi_spi_inst
   // Module Type:    xlr8_spi
   //
   //----------------------------------------------------------------------
   avr_spi
   wifi_spi_inst
     (
      // AVR Control
      .adr        (adr),
      .dbus_in    (dbus_in),
      .dbus_out   (wf_spi_dbus_out),
      .iore       (iore),
      .iowe       (iowe),
      .out_en     (wf_spi_out_en),
      // IRQ
      .spiirq      (/* removing IRQ for extra SPI */),
      .spiack      (/* removing IRQ for extra SPI */),
      // Slave Programming Mode
      .por         (1'b0),
      .spiextload  (1'b0),
      .spidwrite   (/*Not used*/),
      .spiload     (/*Not used*/),
      
      // Outputs
      .misoo       (wf_misoo),
      .mosio       (wf_mosio),
      .scko        (wf_scko),
      .spe         (wf_spe),
      .spimaster   (wf_spimaster),
      // Inputs
      .rst_n       (rstn),             // Templated
      .clk         (clk),
      .clken       (1'b1),             // Templated
      // Former parameters converted to inputs
      .param_design_config   (DESIGN_CONFIG),
      .param_spcr_address    (WIFI_SPCR_ADDR),
      .param_spsr_address    (WIFI_SPSR_ADDR),
      .param_spdr_address    (WIFI_SPDR_ADDR),
      .clk_scki    (wf_scki),
      .misoi       (wf_misoi),       // miso is assigned to D5
      .mosii       (wf_mosii),
      .scki        (wf_scki),
      .ss_b        (wf_ss_b),
      .ramadr      (ramadr[7:0]),      // Templated
      .ramre       (ramre),            // Templated
      .ramwe       (ramwe),            // Templated
      .dm_sel      (dm_sel));          // Templated
   
   
   // Hardwire the values for sck and mosi since we are always the master
   //               { sck,    ss,                         mosi,                 miso,                      }
   assign wf_ddoe = {1'b1,    (wf_spe && ~wf_spimaster),  1'b1,                 wf_spe,                      14'h0000};
   assign wf_ddov = {1'b1,    1'b0,                       1'b1,                 (~wf_spimaster && ~wf_ss_b), 14'h0000};
   assign wf_pvoe = {1'b1,    1'b0,                       1'b1 ,                (wf_spe && ~wf_spimaster),   14'h0000};
   assign wf_pvov = {wf_scko, 1'b0,                       (wf_spe && wf_mosio), wf_misoo,                    14'h0000};
/*
//======== Original Settings =========================================
   assign wf_ddoe = {(wf_spe && ~wf_spimaster),(wf_spe && ~wf_spimaster),   (wf_spe && ~wf_spimaster), wf_spe,                      14'h0000};
   assign wf_ddov = {1'b0,                     1'b0,                        1'b0,                      (~wf_spimaster && ~wf_ss_b), 14'h0000};
   assign wf_pvoe = {(wf_spe && wf_spimaster), 1'b0,                        (wf_spe && wf_spimaster),  (wf_spe && ~wf_spimaster),   14'h0000};
   assign wf_pvov = {wf_scko,                  1'b0,                        (wf_spe && wf_mosio),      wf_misoo,                    14'h0000};
*/


   //----------------------------------------------------------------------
   // Instance Name:  portmux_wf_inst
   // Module Type:    xlr8_portmux
   //----------------------------------------------------------------------
   //
   // Combine the control from the SPI with the GPIO for the Wifi module
   // pins. Total interface is 18 bits wide, of which the upper 4 are
   // controlled by the WiFi SPI.
   //
   //----------------------------------------------------------------------
   xlr8_portmux
     #(
       .WIDTH        (NUM_WIFI_PINS)
       )
   portmux_wf_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      // Inputs
      .port_portx  ({1'h0,bi_portx[5],2'h0,bi_portx[4],9'h000,bi_portx[3:0]}), // From avr_port module
      .port_ddrx   ({1'h0,bi_ddrx[5], 2'h0,bi_ddrx[4], 9'h000,bi_ddrx[3:0] }), // From avr_port module
      .xb_ddoe     (wf_ddoe[NUM_WIFI_PINS-1:0]), // pin direction control enable from XBs
      .xb_ddov     (wf_ddov[NUM_WIFI_PINS-1:0]), // pin direction value from XBs
      .xb_pvoe     (wf_pvoe[NUM_WIFI_PINS-1:0]), // pin output enable from XBs
      .xb_pvov     (wf_pvov[NUM_WIFI_PINS-1:0]), // pin output value from XBs
      // Outputs
      .port_pads   (wf_port_pads[NUM_WIFI_PINS-1:0]), // inout to parent module
      .port_pinx   (wf_pinx[NUM_WIFI_PINS-1:0]), //      pin values to avr_port module
      .xb_pinx     (wf_xb_pinx[NUM_WIFI_PINS-1:0]) //    output to parent module
      );

   

   //===========================================================================
   //
   // ETHERNET INTERFACE
   //
   //===========================================================================
   
   assign et_scki   = 1'b0;
   assign et_ss_b   = xb_pinx[8];
   assign et_mosii  = xb_pinx[7];
   assign et_misoi  = xb_pinx[6];
   
   //----------------------------------------------------------------------
   // Instance Name:  eth_spi_inst
   // Module Type:    xlr8_spi
   //
   //----------------------------------------------------------------------
   avr_spi
   eth_spi_inst
     (
      // AVR Control
      .adr        (adr),
      .dbus_in    (dbus_in),
      .dbus_out   (et_spi_dbus_out),
      .iore       (iore),
      .iowe       (iowe),
      .out_en     (et_spi_out_en),
      // IRQ
      .spiirq      (/* removing IRQ for extra SPI */),
      .spiack      (/* removing IRQ for extra SPI */),
      // Slave Programming Mode
      .por         (1'b0),
      .spiextload  (1'b0),
      .spidwrite   (/*Not used*/),
      .spiload     (/*Not used*/),
      
      // Outputs
      .misoo       (et_misoo),
      .mosio       (et_mosio),
      .scko        (et_scko),
      .spe         (et_spe),
      .spimaster   (et_spimaster),
      // Inputs
      .rst_n       (rstn),             // Templated
      .clk         (clk),
      .clken       (1'b1),             // Templated
      // Former parameters converted to inputs
      .param_design_config   (DESIGN_CONFIG),
      .param_spcr_address    (ETH_SPCR_ADDR),
      .param_spsr_address    (ETH_SPSR_ADDR),
      .param_spdr_address    (ETH_SPDR_ADDR),
      .clk_scki    (et_scki),
      .misoi       (et_misoi),       // miso is assigned to D5
      .mosii       (et_mosii),
      .scki        (et_scki),
      .ss_b        (et_ss_b),
      .ramadr      (ramadr[7:0]),      // Templated
      .ramre       (ramre),            // Templated
      .ramwe       (ramwe),            // Templated
      .dm_sel      (dm_sel));          // Templated
   
   
   // Hardwire the values for sck and mosi since we are always the master
   //               { sck,    ss,                         mosi,                 miso,                        2'h0}
   assign et_ddoe = {1'b1,    (et_spe && ~et_spimaster),  1'b1,                 et_spe,                      2'h0};
   assign et_ddov = {1'b1,    1'b0,                       1'b1,                 (~et_spimaster && ~et_ss_b), 2'h0};
   assign et_pvoe = {1'b1,    1'b0,                       1'b1,                 (et_spe && ~et_spimaster),   2'h0};
   assign et_pvov = {et_scko, 1'b0,                       (et_spe && et_mosio), et_misoo,                    2'h0};

   

   //----------------------------------------------------------------------
   // Instance Name:  portmux_et_inst
   // Module Type:    xlr8_portmux
   //----------------------------------------------------------------------
   //
   // Combine the control from the SPI with the GPIO for the Eth module
   // pins. Total interface is 6 bits wide, of which the upper 4 are
   // controlled by the WiFi SPI.
   //
   //----------------------------------------------------------------------
   xlr8_portmux 
     #(
       .WIDTH        (NUM_ETH_PINS)
       )
   portmux_et_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      // Inputs
      .port_portx  ({1'b0,bi_portx[6],{NUM_ETH_PINS-2{1'b0}}}),// From avr_port module
      .port_ddrx   ({1'b0,bi_ddrx[6], {NUM_ETH_PINS-2{1'b0}}}), // From avr_port module
      .xb_ddoe     (et_ddoe[NUM_ETH_PINS-1:0]), // pin direction control enable from XBs
      .xb_ddov     (et_ddov[NUM_ETH_PINS-1:0]), // pin direction value from XBs
      .xb_pvoe     (et_pvoe[NUM_ETH_PINS-1:0]), // pin output enable from XBs
      .xb_pvov     (et_pvov[NUM_ETH_PINS-1:0]), // pin output value from XBs
      // Outputs
      .port_pads   (et_port_pads[NUM_ETH_PINS-1:0]), // inout to parent module
      .port_pinx   (et_pinx[NUM_ETH_PINS-1:0]), //  pin values to avr_port module
      .xb_pinx     (et_xb_pinx[NUM_ETH_PINS-1:0]) //    output to parent module
      );


   //===========================================================================
   //
   // SD CARD INTERFACE
   //
   //===========================================================================
   
   assign sd_scki   = 1'b0;
   assign sd_ss_b   = xb_pinx[2];
   assign sd_mosii  = xb_pinx[1];
   assign sd_misoi  = xb_pinx[0];

   //----------------------------------------------------------------------
   // Instance Name:  sd_spi_inst
   // Module Type:    xlr8_spi
   //
   //----------------------------------------------------------------------
   avr_spi
   sd_spi_inst
     (
      // AVR Control
      .adr        (adr),
      .dbus_in    (dbus_in),
      .dbus_out   (sd_spi_dbus_out),
      .iore       (iore),
      .iowe       (iowe),
      .out_en     (sd_spi_out_en),
      // IRQ
      .spiirq      (/* removing IRQ for extra SPI */),
      .spiack      (/* removing IRQ for extra SPI */),
      // Slave Programming Mode
      .por         (1'b0),
      .spiextload  (1'b0),
      .spidwrite   (/*Not used*/),
      .spiload     (/*Not used*/),
      
      // Outputs
      .misoo       (sd_misoo),
      .mosio       (sd_mosio),
      .scko        (sd_scko),
      .spe         (sd_spe),
      .spimaster   (sd_spimaster),
      // Inputs
      .rst_n       (rstn),
      .clk         (clk),
      .clken       (1'b1),
      // Former parameters converted to inputs
      .param_design_config   (DESIGN_CONFIG),
      .param_spcr_address    (SD_SPCR_ADDR),
      .param_spsr_address    (SD_SPSR_ADDR),
      .param_spdr_address    (SD_SPDR_ADDR),
      .clk_scki    (sd_scki), //  sd_clk_scki = sd_scki & spi_clken;
      .misoi       (sd_misoi),       // miso is assigned to D5
      .mosii       (sd_mosii),
      .scki        (sd_scki),
      .ss_b        (sd_ss_b),
      .ramadr      (ramadr[7:0]),      // Templated
      .ramre       (ramre),            // Templated
      .ramwe       (ramwe),            // Templated
      .dm_sel      (dm_sel));          // Templated
   
   
/*
   // Original Values, taken from iomux
   //               { sck,                      ss,                         mosi,                      miso,                      }
   assign sd_ddoe = {(sd_spe && ~sd_spimaster), (sd_spe && ~sd_spimaster),  (sd_spe && ~sd_spimaster), sd_spe                     };
   assign sd_ddov = {1'b0,                      1'b0,                       1'b0,                      (~sd_spimaster && ~sd_ss_b)};
   assign sd_pvoe = {(sd_spe && sd_spimaster),  1'b0,                       (sd_spe && sd_spimaster),  (sd_spe && ~sd_spimaster)  };
   assign sd_pvov = {sd_scko,                   1'b0,                       (sd_spe && sd_mosio),      sd_misoo                   };
*/
   // Hardwire the values for sck and mosi since we are always the master
   //               { sck,    ss,                         mosi,                 miso,                      }
   assign sd_ddoe = {1'b1,    (sd_spe && ~sd_spimaster),  1'b1,                 sd_spe                     };
   assign sd_ddov = {1'b1,    1'b0,                       1'b1,                 (~sd_spimaster && ~sd_ss_b)};
   assign sd_pvoe = {1'b1,    1'b0,                       1'b1,                 (sd_spe && ~sd_spimaster)  };
   assign sd_pvov = {sd_scko, 1'b0,                       (sd_spe && sd_mosio), sd_misoo                   };

   //----------------------------------------------------------------------
   // Instance Name:  portmux_sd_inst
   // Module Type:    xlr8_portmux
   //----------------------------------------------------------------------
   //
   // Combine the control from the SPI with the GPIO for the Eth module
   // pins. Total interface is 6 bits wide, of which the upper 4 are
   // controlled by the WiFi SPI.
   //
   //----------------------------------------------------------------------
   xlr8_portmux 
     #(
       .WIDTH        (NUM_SD_PINS)
       )
   portmux_sd_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      // Inputs
      .port_portx  ({1'b0,bi_portx[7],{NUM_SD_PINS-2{1'b0}}}),// From avr_port module
      .port_ddrx   ({1'b0,bi_ddrx[7],{NUM_SD_PINS-2{1'b0}}}), // From avr_port module
      .xb_ddoe     (sd_ddoe[NUM_SD_PINS-1:0]), // pin direction control enable from XBs
      .xb_ddov     (sd_ddov[NUM_SD_PINS-1:0]), // pin direction value from XBs
      .xb_pvoe     (sd_pvoe[NUM_SD_PINS-1:0]), // pin output enable from XBs
      .xb_pvov     (sd_pvov[NUM_SD_PINS-1:0]), // pin output value from XBs
      // Outputs
      .port_pads   (sd_port_pads[NUM_SD_PINS-1:0]), // inout to parent module
      .port_pinx   (sd_pinx[NUM_SD_PINS-1:0]), //  pin values to avr_port module
      .xb_pinx     (sd_xb_pinx[NUM_SD_PINS-1:0]) //    output to parent module
      );


   // Mux the dbus as usual
   assign dbus_out  = wf_spi_out_en  ? wf_spi_dbus_out : 
                      bi_port_out_en ? bi_port_dbus_out :
                      et_spi_out_en  ? et_spi_dbus_out :
                      sd_spi_out_en  ? sd_spi_dbus_out : 
                                       8'h00;

   assign io_out_en = wf_spi_out_en || 
                      bi_port_out_en ||
                      et_spi_out_en ||
                      sd_spi_out_en;

   assign xb_pinx = {wf_xb_pinx[NUM_WIFI_PINS-1:0],et_xb_pinx[NUM_ETH_PINS-1:0],sd_xb_pinx[NUM_SD_PINS-1:0]};

   // Pull out the bits we need for the GPIO portion of the port 
   assign bi_pinx[7:0] = {sd_pinx[2],    // SD SS
                          et_pinx[4],    // ET SS
                          wf_pinx[16],   // WF SS
                          wf_pinx[13],   // WF Interrupt (IRQN), device interrupt
                          wf_pinx[3],    // WF Enable (EN or CHIP_EN), enables the module
                          wf_pinx[2],    // WF Wake
                          wf_pinx[1],    // WF Reset (RESET_N), hard reset
                          wf_pinx[0]     // WF Config (SPI_CFG), SPI enable
                          };
   
   
endmodule // xlr8_hinj_bixb




