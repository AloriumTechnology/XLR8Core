//////////////////////////////////////////////////////////////////
//=================================================================
//  Copyright(c) Superion Technology Group Inc., 2017
//  ALL RIGHTS RESERVED
//=================================================================
//
// File name:  : xlr8_snoedge_gpio.v
// Author      : Steve Phillips
// Description : Ports for the gpio pins on Sno Edge
//
//      D Num        Pinx    Ports
//   ----------  ---------  -----------
//    [  7:  0]  [  7:  0]  PORTD[7:0]       
//    [ 13:  8]  [ 13:  8]  PORTB[5:0]    
//    [ 19: 14]  [ 19: 14]  PORTC[5:0]     
//    [ 27: 22]  [ 25: 20]  PORTA[5:0]
//    [ 33: 28]  [ 31: 26]  PORTE[5:0]
//    [ 41: 34]  [ 39: 32]  PORTG[7:0]
//    [ 49: 42]  [ 47: 40]  PORTJ0[7:0]
//    [ 57: 50]  [ 55: 48]  PORTJ1[7:0]
//    [ 65: 58]  [ 63: 56]  PORTJ2[7:0]
//    [ 73: 66]  [ 71: 64]  PORTJ3[7:0]
//    [ 81: 74]  [ 79: 72]  PORTK0[7:0]
//    [ 89: 82]  [ 87: 80]  PORTK1[7:0]
//    [ 97: 90]  [ 95: 88]  PORTK2[7:0]
//    [105: 98]  [103: 96]  PORTK3[7:0]
//    [109:106]  [107:104]  PORTPL[5:0]
//
//=================================================================
///////////////////////////////////////////////////////////////////

  
module xlr8_snoedge_gpio
  #(
    parameter NUM_PINS       = 118,
    parameter NUM_SNO_PINS   = 42,    // 20 for D, B, and C, plus 20 for A, E, G
    parameter PINPL_Address  = 8'h8C, // Input Pins         Port PL
    parameter DDRPL_Address  = 8'h8D, // Data Direction Reg Port PL
    parameter PORTPL_Address = 8'h8E, // Data Register      Port PL
    parameter MSKPL_Address  = 8'h8F, // Interrupt Mask     Port PL
    parameter PINJ0_Address  = 8'h90, // Input Pins         Port J0
    parameter DDRJ0_Address  = 8'h91, // Data Direction Reg Port J0
    parameter PORTJ0_Address = 8'h92, // Data Register      Port J0
    parameter MSKJ0_Address  = 8'h93, // Interrupt Mask     Port J0
    parameter PINJ1_Address  = 8'h94, // Input Pins         Port J1
    parameter DDRJ1_Address  = 8'h95, // Data Direction Reg Port J1
    parameter PORTJ1_Address = 8'h96, // Data Register      Port J1
    parameter MSKJ1_Address  = 8'h97, // Interrupt Mask     Port J1
    parameter PINJ2_Address  = 8'h98, // Input Pins         Port J2
    parameter DDRJ2_Address  = 8'h99, // Data Direction Reg Port J2
    parameter PORTJ2_Address = 8'h9A, // Data Register      Port J2
    parameter MSKJ2_Address  = 8'h9B, // Interrupt Mask     Port J2
    parameter PINJ3_Address  = 8'h9C, // Input Pins         Port J3
    parameter DDRJ3_Address  = 8'h9D, // Data Direction Reg Port J3
    parameter PORTJ3_Address = 8'h9E, // Data Register      Port J3
    parameter MSKJ3_Address  = 8'h9F, // Interrupt Mask     Port J3
    parameter PINK0_Address  = 8'hA0, // Input Pins         Port K0
    parameter DDRK0_Address  = 8'hA1, // Data Direction Reg Port K0
    parameter PORTK0_Address = 8'hA2, // Data Register      Port K0
    parameter MSKK0_Address  = 8'hA3, // Interrupt Mask     Port K0
    parameter PINK1_Address  = 8'hA4, // Input Pins         Port K1
    parameter DDRK1_Address  = 8'hA5, // Data Direction Reg Port K1
    parameter PORTK1_Address = 8'hA6, // Data Register      Port K1
    parameter MSKK1_Address  = 8'hA7, // Interrupt Mask     Port K1
    parameter PINK2_Address  = 8'hA8, // Input Pins         Port K2
    parameter DDRK2_Address  = 8'hA9, // Data Direction Reg Port K2
    parameter PORTK2_Address = 8'hAA, // Data Register      Port K2
    parameter MSKK2_Address  = 8'hAB, // Interrupt Mask     Port K2
    parameter PINK3_Address  = 8'hAC, // Input Pins         Port K3
    parameter DDRK3_Address  = 8'hAD, // Data Direction Reg Port K3
    parameter PORTK3_Address = 8'hAE, // Data Register      Port K3
    parameter MSKK3_Address  = 8'hAF // Interrupt Mask     Port K3
    )
   (
    input                                  clk,
    input                                  rstn,
    // Standard dbus stuff
    input [5:0]                            adr,
    input [7:0]                            dbus_in,
    output [7:0]                           dbus_out,
    input                                  iore,
    input                                  iowe,
    output                                 io_out_en,
    // DM
    input [7:0]                            ramadr,
    input                                  ramre,
    input                                  ramwe,
    input                                  dm_sel,
    // Inputs
    input [NUM_PINS-1:NUM_SNO_PINS]        xb_ddoe,
    input [NUM_PINS-1:NUM_SNO_PINS]        xb_ddov,
    input [NUM_PINS-1:NUM_SNO_PINS]        xb_pvoe,
    input [NUM_PINS-1:NUM_SNO_PINS]        xb_pvov,
    // Outputs
    // port_pads goes to the top level module I/O ports, ie: the chip pins
    inout [NUM_PINS-1:NUM_SNO_PINS]        port_pads,
    // xb_pinx is the pin value for use by the XBs
    output logic [NUM_PINS-1:NUM_SNO_PINS] xb_pinx,
    // Pin Change Interrupts to xlr8_pcint module
    output logic [2:0]                     pcint
    );
   
   // Bit ranges within the big bus for the various ports. See chart in header
   localparam PORTJ0_HI =   49; // Port J0[7:0]
   localparam PORTJ0_LO =   42;
   localparam PORTJ1_HI =   57; // Port J1[7:0]
   localparam PORTJ1_LO =   50;
   localparam PORTJ2_HI =   65; // Port J2[7:0]
   localparam PORTJ2_LO =   58;
   localparam PORTJ3_HI =   73; // Port J3[3:0]
   localparam PORTJ3_LO =   66;
   localparam PORTK0_HI =   81; // Port K0[7:0]
   localparam PORTK0_LO =   74;
   localparam PORTK1_HI =   89; // Port K1[7:0]
   localparam PORTK1_LO =   82;
   localparam PORTK2_HI =   97; // Port K2[7:0]
   localparam PORTK2_LO =   90;
   localparam PORTK3_HI =  105; // Port K3[7:0]
   localparam PORTK3_LO =   98;
   localparam PORTPL_HI =  109; // Port PL[5:0]
   localparam PORTPL_LO =  106;

   // These connect between the port and the portmux
   logic [NUM_PINS-1:NUM_SNO_PINS]         port_portx;
   logic [NUM_PINS-1:NUM_SNO_PINS]         port_ddrx;
   logic [NUM_PINS-1:NUM_SNO_PINS]         port_pinx;

   // Pin Change Interrupts
   logic                                   pl_pcifr_set;
   logic [3:0]                             j_pcifr_set;
   logic [3:0]                             k_pcifr_set;
   
   // dbus_out enables for each port
   logic                        pl_io_out_en;
   logic                        j0_io_out_en;
   logic                        j1_io_out_en;
   logic                        j2_io_out_en;
   logic                        j3_io_out_en;
   logic                        k0_io_out_en;
   logic                        k1_io_out_en;
   logic                        k2_io_out_en;
   logic                        k3_io_out_en;

   // dbus_out data for each port
   logic [7:0]                  pl_dbus_out;
   logic [7:0]                  j0_dbus_out;
   logic [7:0]                  j1_dbus_out;
   logic [7:0]                  j2_dbus_out;
   logic [7:0]                  j3_dbus_out;
   logic [7:0]                  k0_dbus_out;
   logic [7:0]                  k1_dbus_out;
   logic [7:0]                  k2_dbus_out;
   logic [7:0]                  k3_dbus_out;
   
   // Combine the dbus_outs before sending back up to tthe top level
   assign dbus_out  = pl_io_out_en ? pl_dbus_out :
                      j0_io_out_en ? j0_dbus_out :
                      j1_io_out_en ? j1_dbus_out :
                      j2_io_out_en ? j2_dbus_out :
                      j3_io_out_en ? j3_dbus_out :
                      k0_io_out_en ? k0_dbus_out :
                      k1_io_out_en ? k1_dbus_out :
                      k2_io_out_en ? k2_dbus_out :
                      k3_io_out_en ? k3_dbus_out :
                      8'h00;

   assign io_out_en = pl_io_out_en || 
                      j0_io_out_en || 
                      j1_io_out_en || 
                      j2_io_out_en || 
                      j3_io_out_en || 
                      k0_io_out_en || 
                      k1_io_out_en || 
                      k2_io_out_en || 
                      k3_io_out_en;

   assign pcint = {pl_pcifr_set,(|k_pcifr_set),(|j_pcifr_set)};

   // === PORT PL === PORT PL === PORT PL === PORT PL === PORT PL === PORT PL ===

   //----------------------------------------------------------------------
   // Instance Name:  portmux_pl_inst
   // Module Type:    xlr8_portmux
   //
   //----------------------------------------------------------------------
   xlr8_portmux 
     #(
       .WIDTH        (4)
       )
   portmux_pl_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      // Inputs
      .port_portx  (port_portx[PORTPL_HI:PORTPL_LO]),// From xlr8_avr_port module
      .port_ddrx   (port_ddrx[PORTPL_HI:PORTPL_LO]), // From xlr8_avr_port module
      .xb_ddoe     (xb_ddoe[PORTPL_HI:PORTPL_LO]),   // pin direction control enable from XBs
      .xb_ddov     (xb_ddov[PORTPL_HI:PORTPL_LO]),   // pin direction value from XBs
      .xb_pvoe     (xb_pvoe[PORTPL_HI:PORTPL_LO]),   // pin output enable from XBs
      .xb_pvov     (xb_pvov[PORTPL_HI:PORTPL_LO]),   // pin output value from XBs
      // Outputs
      .port_pads   (port_pads[PORTPL_HI:PORTPL_LO]), // inout to parent module
      .port_pinx   (port_pinx[PORTPL_HI:PORTPL_LO]), // pin values to xlr8_avr_port module
      .xb_pinx     (xb_pinx[PORTPL_HI:PORTPL_LO])    // output to parent module
      );

   //----------------------------------------------------------------------
   // Instance Name:  port_pl_inst
   // Module Type:    xlr8_avr_port
   //
   //----------------------------------------------------------------------
   xlr8_avr_port 
     #(
       .PORTX_ADDR   (PORTPL_Address),
       .DDRX_ADDR    (DDRPL_Address),
       .PINX_ADDR    (PINPL_Address),
       .PCMSK_ADDR   (MSKPL_Address),
       .WIDTH        (4)
       )
   port_pl_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      .clken       (1'b1),
      // I/O
      .adr         (adr),
      .dbus_in     (dbus_in),
      .dbus_out    (pl_dbus_out),
      .iore        (iore),
      .iowe        (iowe),
      .io_out_en   (pl_io_out_en),
      // DM
      .ramadr      (ramadr),
      .ramre       (ramre),
      .ramwe       (ramwe),
      .dm_sel      (dm_sel),
      // External connection
      .portx       (port_portx[PORTPL_HI:PORTPL_LO]), // To portmux module
      .ddrx        (port_ddrx[PORTPL_HI:PORTPL_LO]),  // To portmux module
      .pinx        (port_pinx[PORTPL_HI:PORTPL_LO]),   // From portmux module
      .pcifr_set   (pl_pcifr_set) //                     Pin Change Int to xlr8_pcint
      );
   

   // === PORT J0 === PORT J0 === PORT J0 === PORT J0 === PORT J0 === PORT J0 ===

   //----------------------------------------------------------------------
   // Instance Name:  portmux_j0_inst
   // Module Type:    xlr8_portmux
   //
   //----------------------------------------------------------------------
   xlr8_portmux 
     #(
       .WIDTH        (8)
       )
   portmux_j0_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      // Inputs
      .port_portx  (port_portx[PORTJ0_HI:PORTJ0_LO]),// From xlr8_avr_port module
      .port_ddrx   (port_ddrx[PORTJ0_HI:PORTJ0_LO]), // From xlr8_avr_port module
      .xb_ddoe     (xb_ddoe[PORTJ0_HI:PORTJ0_LO]),   // pin direction control enable from XBs
      .xb_ddov     (xb_ddov[PORTJ0_HI:PORTJ0_LO]),   // pin direction value from XBs
      .xb_pvoe     (xb_pvoe[PORTJ0_HI:PORTJ0_LO]),   // pin output enable from XBs
      .xb_pvov     (xb_pvov[PORTJ0_HI:PORTJ0_LO]),   // pin output value from XBs
      // Outputs
      .port_pads   (port_pads[PORTJ0_HI:PORTJ0_LO]), // inout to parent module
      .port_pinx   (port_pinx[PORTJ0_HI:PORTJ0_LO]), // pin values to xlr8_avr_port module
      .xb_pinx     (xb_pinx[PORTJ0_HI:PORTJ0_LO])    // output to parent module
      );

   //----------------------------------------------------------------------
   // Instance Name:  port_j0_inst
   // Module Type:    xlr8_avr_port
   //
   //----------------------------------------------------------------------
   xlr8_avr_port 
     #(
       .PORTX_ADDR   (PORTJ0_Address),
       .DDRX_ADDR    (DDRJ0_Address),
       .PINX_ADDR    (PINJ0_Address),
       .PCMSK_ADDR   (MSKJ0_Address),
       .WIDTH        (8)
       )
   port_j0_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      .clken       (1'b1),
      // I/O
      .adr         (adr),
      .dbus_in     (dbus_in),
      .dbus_out    (j0_dbus_out),
      .iore        (iore),
      .iowe        (iowe),
      .io_out_en   (j0_io_out_en),
      // DM
      .ramadr      (ramadr),
      .ramre       (ramre),
      .ramwe       (ramwe),
      .dm_sel      (dm_sel),
      // External connection
      .portx       (port_portx[PORTJ0_HI:PORTJ0_LO]), // To portmux module
      .ddrx        (port_ddrx[PORTJ0_HI:PORTJ0_LO]), //  To portmux module
      .pinx        (port_pinx[PORTJ0_HI:PORTJ0_LO]), //  From portmux module
      .pcifr_set   (j_pcifr_set[0]) //                     Pin Change Int to xlr8_pcint
      );
   


   // === PORT J1 === PORT J1 === PORT J1 === PORT J1 === PORT J1 === PORT J1 ===

   //----------------------------------------------------------------------
   // Instance Name:  portmux_j1_inst
   // Module Type:    xlr8_portmux
   //
   //----------------------------------------------------------------------
   xlr8_portmux 
     #(
       .WIDTH        (8)
       )
   portmux_j1_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      // Inputs
      .port_portx  (port_portx[PORTJ1_HI:PORTJ1_LO]),// From xlr8_avr_port module
      .port_ddrx   (port_ddrx[PORTJ1_HI:PORTJ1_LO]), // From xlr8_avr_port module
      .xb_ddoe     (xb_ddoe[PORTJ1_HI:PORTJ1_LO]),   // pin direction control enable from XBs
      .xb_ddov     (xb_ddov[PORTJ1_HI:PORTJ1_LO]),   // pin direction value from XBs
      .xb_pvoe     (xb_pvoe[PORTJ1_HI:PORTJ1_LO]),   // pin output enable from XBs
      .xb_pvov     (xb_pvov[PORTJ1_HI:PORTJ1_LO]),   // pin output value from XBs
      // Outputs
      .port_pads   (port_pads[PORTJ1_HI:PORTJ1_LO]), // inout to parent module
      .port_pinx   (port_pinx[PORTJ1_HI:PORTJ1_LO]), // pin values to xlr8_avr_port module
      .xb_pinx     (xb_pinx[PORTJ1_HI:PORTJ1_LO])    // output to parent module
      );

   //----------------------------------------------------------------------
   // Instance Name:  port_j1_inst
   // Module Type:    xlr8_avr_port
   //
   //----------------------------------------------------------------------
   xlr8_avr_port 
     #(
       .PORTX_ADDR   (PORTJ1_Address),
       .DDRX_ADDR    (DDRJ1_Address),
       .PINX_ADDR    (PINJ1_Address),
       .PCMSK_ADDR   (MSKJ1_Address),
       .WIDTH        (8)
       )
   port_j1_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      .clken       (1'b1),
      // I/O
      .adr         (adr),
      .dbus_in     (dbus_in),
      .dbus_out    (j1_dbus_out),
      .iore        (iore),
      .iowe        (iowe),
      .io_out_en   (j1_io_out_en),
      // DM
      .ramadr      (ramadr),
      .ramre       (ramre),
      .ramwe       (ramwe),
      .dm_sel      (dm_sel),
      // External connection
      .portx       (port_portx[PORTJ1_HI:PORTJ1_LO]), // To portmux module
      .ddrx        (port_ddrx[PORTJ1_HI:PORTJ1_LO]), //  To portmux module
      .pinx        (port_pinx[PORTJ1_HI:PORTJ1_LO]), //  From portmux module
      .pcifr_set   (j_pcifr_set[1]) //                     Pin Change Int to xlr8_pcint
      );
   


   // === PORT J2 === PORT J2 === PORT J2 === PORT J2 === PORT J2 === PORT J2 ===

   //----------------------------------------------------------------------
   // Instance Name:  portmux_j2_inst
   // Module Type:    xlr8_portmux
   //
   //----------------------------------------------------------------------
   xlr8_portmux 
     #(
       .WIDTH        (8)
       )
   portmux_j2_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      // Inputs
      .port_portx  (port_portx[PORTJ2_HI:PORTJ2_LO]),// From xlr8_avr_port module
      .port_ddrx   (port_ddrx[PORTJ2_HI:PORTJ2_LO]), // From xlr8_avr_port module
      .xb_ddoe     (xb_ddoe[PORTJ2_HI:PORTJ2_LO]),   // pin direction control enable from XBs
      .xb_ddov     (xb_ddov[PORTJ2_HI:PORTJ2_LO]),   // pin direction value from XBs
      .xb_pvoe     (xb_pvoe[PORTJ2_HI:PORTJ2_LO]),   // pin output enable from XBs
      .xb_pvov     (xb_pvov[PORTJ2_HI:PORTJ2_LO]),   // pin output value from XBs
      // Outputs
      .port_pads   (port_pads[PORTJ2_HI:PORTJ2_LO]), // inout to parent module
      .port_pinx   (port_pinx[PORTJ2_HI:PORTJ2_LO]), // pin values to xlr8_avr_port module
      .xb_pinx     (xb_pinx[PORTJ2_HI:PORTJ2_LO])    // output to parent module
      );

   //----------------------------------------------------------------------
   // Instance Name:  port_j2_inst
   // Module Type:    xlr8_avr_port
   //
   //----------------------------------------------------------------------
   xlr8_avr_port 
     #(
       .PORTX_ADDR   (PORTJ2_Address),
       .DDRX_ADDR    (DDRJ2_Address),
       .PINX_ADDR    (PINJ2_Address),
       .PCMSK_ADDR   (MSKJ2_Address),
       .WIDTH        (8)
       )
   port_j2_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      .clken       (1'b1),
      // I/O
      .adr         (adr),
      .dbus_in     (dbus_in),
      .dbus_out    (j2_dbus_out),
      .iore        (iore),
      .iowe        (iowe),
      .io_out_en   (j2_io_out_en),
      // DM
      .ramadr      (ramadr),
      .ramre       (ramre),
      .ramwe       (ramwe),
      .dm_sel      (dm_sel),
      // External connection
      .portx       (port_portx[PORTJ2_HI:PORTJ2_LO]), // To portmux module
      .ddrx        (port_ddrx[PORTJ2_HI:PORTJ2_LO]), //  To portmux module
      .pinx        (port_pinx[PORTJ2_HI:PORTJ2_LO]), //  From portmux module
      .pcifr_set   (j_pcifr_set[2]) //                     Pin Change Int to xlr8_pcint
      );
   


   // === PORT J3 === PORT J3 === PORT J3 === PORT J3 === PORT J3 === PORT J3 ===

   //----------------------------------------------------------------------
   // Instance Name:  portmux_j3_inst
   // Module Type:    xlr8_portmux
   //
   //----------------------------------------------------------------------
   xlr8_portmux 
     #(
       .WIDTH        (8)
       )
   portmux_j3_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      // Inputs
      .port_portx  (port_portx[PORTJ3_HI:PORTJ3_LO]),// From xlr8_avr_port module
      .port_ddrx   (port_ddrx[PORTJ3_HI:PORTJ3_LO]), // From xlr8_avr_port module
      .xb_ddoe     (xb_ddoe[PORTJ3_HI:PORTJ3_LO]),   // pin direction control enable from XBs
      .xb_ddov     (xb_ddov[PORTJ3_HI:PORTJ3_LO]),   // pin direction value from XBs
      .xb_pvoe     (xb_pvoe[PORTJ3_HI:PORTJ3_LO]),   // pin output enable from XBs
      .xb_pvov     (xb_pvov[PORTJ3_HI:PORTJ3_LO]),   // pin output value from XBs
      // Outputs
      .port_pads   (port_pads[PORTJ3_HI:PORTJ3_LO]), // inout to parent module
      .port_pinx   (port_pinx[PORTJ3_HI:PORTJ3_LO]), // pin values to xlr8_avr_port module
      .xb_pinx     (xb_pinx[PORTJ3_HI:PORTJ3_LO])    // output to parent module
      );

   //----------------------------------------------------------------------
   // Instance Name:  port_j3_inst
   // Module Type:    xlr8_avr_port
   //
   //----------------------------------------------------------------------
   xlr8_avr_port 
     #(
       .PORTX_ADDR   (PORTJ3_Address),
       .DDRX_ADDR    (DDRJ3_Address),
       .PINX_ADDR    (PINJ3_Address),
       .PCMSK_ADDR   (MSKJ3_Address),
       .WIDTH        (8)
       )
   port_j3_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      .clken       (1'b1),
      // I/O
      .adr         (adr),
      .dbus_in     (dbus_in),
      .dbus_out    (j3_dbus_out),
      .iore        (iore),
      .iowe        (iowe),
      .io_out_en   (j3_io_out_en),
      // DM
      .ramadr      (ramadr),
      .ramre       (ramre),
      .ramwe       (ramwe),
      .dm_sel      (dm_sel),
      // External connection
      .portx       (port_portx[PORTJ3_HI:PORTJ3_LO]), // To portmux module
      .ddrx        (port_ddrx[PORTJ3_HI:PORTJ3_LO]), //  To portmux module
      .pinx        (port_pinx[PORTJ3_HI:PORTJ3_LO]), //  From portmux module
      .pcifr_set   (j_pcifr_set[3]) //                     Pin Change Int to xlr8_pcint
      );
   


   // === PORT K0 === PORT K0 === PORT K0 === PORT K0 === PORT K0 === PORT K0 ===

   //----------------------------------------------------------------------
   // Instance Name:  portmux_k0_inst
   // Module Type:    xlr8_portmux
   //
   //----------------------------------------------------------------------
   xlr8_portmux 
     #(
       .WIDTH        (8)
       )
   portmux_k0_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      // Inputs
      .port_portx  (port_portx[PORTK0_HI:PORTK0_LO]),// From xlr8_avr_port module
      .port_ddrx   (port_ddrx[PORTK0_HI:PORTK0_LO]), // From xlr8_avr_port module
      .xb_ddoe     (xb_ddoe[PORTK0_HI:PORTK0_LO]),   // pin direction control enable from XBs
      .xb_ddov     (xb_ddov[PORTK0_HI:PORTK0_LO]),   // pin direction value from XBs
      .xb_pvoe     (xb_pvoe[PORTK0_HI:PORTK0_LO]),   // pin output enable from XBs
      .xb_pvov     (xb_pvov[PORTK0_HI:PORTK0_LO]),   // pin output value from XBs
      // Outputs
      .port_pads   (port_pads[PORTK0_HI:PORTK0_LO]), // inout to parent module
      .port_pinx   (port_pinx[PORTK0_HI:PORTK0_LO]), // pin values to xlr8_avr_port module
      .xb_pinx     (xb_pinx[PORTK0_HI:PORTK0_LO])    // output to parent module
      );

   //----------------------------------------------------------------------
   // Instance Name:  port_k0_inst
   // Module Type:    xlr8_avr_port
   //
   //----------------------------------------------------------------------
   xlr8_avr_port 
     #(
       .PORTX_ADDR   (PORTK0_Address),
       .DDRX_ADDR    (DDRK0_Address),
       .PINX_ADDR    (PINK0_Address),
       .PCMSK_ADDR   (MSKK0_Address),
       .WIDTH        (8)
       )
   port_k0_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      .clken       (1'b1),
      // I/O
      .adr         (adr),
      .dbus_in     (dbus_in),
      .dbus_out    (k0_dbus_out),
      .iore        (iore),
      .iowe        (iowe),
      .io_out_en   (k0_io_out_en),
      // DM
      .ramadr      (ramadr),
      .ramre       (ramre),
      .ramwe       (ramwe),
      .dm_sel      (dm_sel),
      // External connection
      .portx       (port_portx[PORTK0_HI:PORTK0_LO]), // To portmux module
      .ddrx        (port_ddrx[PORTK0_HI:PORTK0_LO]), //  To portmux module
      .pinx        (port_pinx[PORTK0_HI:PORTK0_LO]), //  From portmux module
      .pcifr_set   (k_pcifr_set[0]) //                     Pin Change Int to xlr8_pcint
      );
   


   // === PORT K1 === PORT K1 === PORT K1 === PORT K1 === PORT K1 === PORT K1 ===

   //----------------------------------------------------------------------
   // Instance Name:  portmux_k1_inst
   // Module Type:    xlr8_portmux
   //
   //----------------------------------------------------------------------
   xlr8_portmux 
     #(
       .WIDTH        (8)
       )
   portmux_k1_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      // Inputs
      .port_portx  (port_portx[PORTK1_HI:PORTK1_LO]),// From xlr8_avr_port module
      .port_ddrx   (port_ddrx[PORTK1_HI:PORTK1_LO]), // From xlr8_avr_port module
      .xb_ddoe     (xb_ddoe[PORTK1_HI:PORTK1_LO]),   // pin direction control enable from XBs
      .xb_ddov     (xb_ddov[PORTK1_HI:PORTK1_LO]),   // pin direction value from XBs
      .xb_pvoe     (xb_pvoe[PORTK1_HI:PORTK1_LO]),   // pin output enable from XBs
      .xb_pvov     (xb_pvov[PORTK1_HI:PORTK1_LO]),   // pin output value from XBs
      // Outputs
      .port_pads   (port_pads[PORTK1_HI:PORTK1_LO]), // inout to parent module
      .port_pinx   (port_pinx[PORTK1_HI:PORTK1_LO]), // pin values to xlr8_avr_port module
      .xb_pinx     (xb_pinx[PORTK1_HI:PORTK1_LO])    // output to parent module
      );

   //----------------------------------------------------------------------
   // Instance Name:  port_k1_inst
   // Module Type:    xlr8_avr_port
   //
   //----------------------------------------------------------------------
   xlr8_avr_port 
     #(
       .PORTX_ADDR   (PORTK1_Address),
       .DDRX_ADDR    (DDRK1_Address),
       .PINX_ADDR    (PINK1_Address),
       .PCMSK_ADDR   (MSKK1_Address),
       .WIDTH        (8)
       )
   port_k1_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      .clken       (1'b1),
      // I/O
      .adr         (adr),
      .dbus_in     (dbus_in),
      .dbus_out    (k1_dbus_out),
      .iore        (iore),
      .iowe        (iowe),
      .io_out_en   (k1_io_out_en),
      // DM
      .ramadr      (ramadr),
      .ramre       (ramre),
      .ramwe       (ramwe),
      .dm_sel      (dm_sel),
      // External connection
      .portx       (port_portx[PORTK1_HI:PORTK1_LO]), // To portmux module
      .ddrx        (port_ddrx[PORTK1_HI:PORTK1_LO]), //  To portmux module
      .pinx        (port_pinx[PORTK1_HI:PORTK1_LO]), //  From portmux module
      .pcifr_set   (k_pcifr_set[1]) //                     Pin Change Int to xlr8_pcint
      );
   


   // === PORT K2 === PORT K2 === PORT K2 === PORT K2 === PORT K2 === PORT K2 ===

   //----------------------------------------------------------------------
   // Instance Name:  portmux_k2_inst
   // Module Type:    xlr8_portmux
   //
   //----------------------------------------------------------------------
   xlr8_portmux 
     #(
       .WIDTH        (8)
       )
   portmux_k2_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      // Inputs
      .port_portx  (port_portx[PORTK2_HI:PORTK2_LO]),// From xlr8_avr_port module
      .port_ddrx   (port_ddrx[PORTK2_HI:PORTK2_LO]), // From xlr8_avr_port module
      .xb_ddoe     (xb_ddoe[PORTK2_HI:PORTK2_LO]),   // pin direction control enable from XBs
      .xb_ddov     (xb_ddov[PORTK2_HI:PORTK2_LO]),   // pin direction value from XBs
      .xb_pvoe     (xb_pvoe[PORTK2_HI:PORTK2_LO]),   // pin output enable from XBs
      .xb_pvov     (xb_pvov[PORTK2_HI:PORTK2_LO]),   // pin output value from XBs
      // Outputs
      .port_pads   (port_pads[PORTK2_HI:PORTK2_LO]), // inout to parent module
      .port_pinx   (port_pinx[PORTK2_HI:PORTK2_LO]), // pin values to xlr8_avr_port module
      .xb_pinx     (xb_pinx[PORTK2_HI:PORTK2_LO])    // output to parent module
      );

   //----------------------------------------------------------------------
   // Instance Name:  port_k2_inst
   // Module Type:    xlr8_avr_port
   //
   //----------------------------------------------------------------------
   xlr8_avr_port 
     #(
       .PORTX_ADDR   (PORTK2_Address),
       .DDRX_ADDR    (DDRK2_Address),
       .PINX_ADDR    (PINK2_Address),
       .PCMSK_ADDR   (MSKK2_Address),
       .WIDTH        (8)
       )
   port_k2_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      .clken       (1'b1),
      // I/O
      .adr         (adr),
      .dbus_in     (dbus_in),
      .dbus_out    (k2_dbus_out),
      .iore        (iore),
      .iowe        (iowe),
      .io_out_en   (k2_io_out_en),
      // DM
      .ramadr      (ramadr),
      .ramre       (ramre),
      .ramwe       (ramwe),
      .dm_sel      (dm_sel),
      // External connection
      .portx       (port_portx[PORTK2_HI:PORTK2_LO]), // To portmux module
      .ddrx        (port_ddrx[PORTK2_HI:PORTK2_LO]), //  To portmux module
      .pinx        (port_pinx[PORTK2_HI:PORTK2_LO]), //  From portmux module
      .pcifr_set   (k_pcifr_set[2]) //                     Pin Change Int to xlr8_pcint
      );
   


   // === PORT K3 === PORT K3 === PORT K3 === PORT K3 === PORT K3 === PORT K3 ===

   //----------------------------------------------------------------------
   // Instance Name:  portmux_k3_inst
   // Module Type:    xlr8_portmux
   //
   //----------------------------------------------------------------------
   xlr8_portmux 
     #(
       .WIDTH        (8)
       )
   portmux_k3_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      // Inputs
      .port_portx  (port_portx[PORTK3_HI:PORTK3_LO]),// From xlr8_avr_port module
      .port_ddrx   (port_ddrx[PORTK3_HI:PORTK3_LO]), // From xlr8_avr_port module
      .xb_ddoe     (xb_ddoe[PORTK3_HI:PORTK3_LO]),   // pin direction control enable from XBs
      .xb_ddov     (xb_ddov[PORTK3_HI:PORTK3_LO]),   // pin direction value from XBs
      .xb_pvoe     (xb_pvoe[PORTK3_HI:PORTK3_LO]),   // pin output enable from XBs
      .xb_pvov     (xb_pvov[PORTK3_HI:PORTK3_LO]),   // pin output value from XBs
      // Outputs
      .port_pads   (port_pads[PORTK3_HI:PORTK3_LO]), // inout to parent module
      .port_pinx   (port_pinx[PORTK3_HI:PORTK3_LO]), // pin values to xlr8_avr_port module
      .xb_pinx     (xb_pinx[PORTK3_HI:PORTK3_LO])    // output to parent module
      );

   //----------------------------------------------------------------------
   // Instance Name:  port_k3_inst
   // Module Type:    xlr8_avr_port
   //
   //----------------------------------------------------------------------
   xlr8_avr_port 
     #(
       .PORTX_ADDR   (PORTK3_Address),
       .DDRX_ADDR    (DDRK3_Address),
       .PINX_ADDR    (PINK3_Address),
       .PCMSK_ADDR   (MSKK3_Address),
       .WIDTH        (8)
       )
   port_k3_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      .clken       (1'b1),
      // I/O
      .adr         (adr),
      .dbus_in     (dbus_in),
      .dbus_out    (k3_dbus_out),
      .iore        (iore),
      .iowe        (iowe),
      .io_out_en   (k3_io_out_en),
      // DM
      .ramadr      (ramadr),
      .ramre       (ramre),
      .ramwe       (ramwe),
      .dm_sel      (dm_sel),
      // External connection
      .portx       (port_portx[PORTK3_HI:PORTK3_LO]), // To portmux module
      .ddrx        (port_ddrx[PORTK3_HI:PORTK3_LO]), //  To portmux module
      .pinx        (port_pinx[PORTK3_HI:PORTK3_LO]), //  From portmux module
      .pcifr_set   (k_pcifr_set[3]) //                     Pin Change Int to xlr8_pcint
      );
   

   
endmodule // xlr8_snoedge_gpio



