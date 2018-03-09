//////////////////////////////////////////////////////////////////
//=================================================================
//  Copyright(c) Superion Technology Group Inc., 2017
//  ALL RIGHTS RESERVED
//=================================================================
//
// File name:  : xlr8_hinj_gpio.v
// Author      : Steve Phillips
// Description : Ports for the gpio pins on Hinj
//
// Connector Logical    Physical       Pinx    Ports
// --------- ------- -------------  ---------  -------------------
//   B        [1:0]          [2:1]  [121:120]  PORTBT[1:0]  
//   XBEE    [15:0]  [11:13,15:19]  [119:112]  PORTX1[7:0],
//                      [20,9,7:2]  [111:104]  PORTX0[7:0]
//   SW       [7:0]          [1:8]   [103:96]  PORTSW[7:0]  
//   LED      [7:0]          [7:0]    [95:88]  PORTLD[7:0]  
//   GPIO    [35:0]        [38:35]    [87:84]  PORTG4[35:32],
//                         [34:27]    [83:76]  PORTG3[31:24],
//                         [26:19]    [75:68]  PORTG2[23:16],
//                         [18:11]    [67:60]  PORTG1[15:8],
//                          [10:3]    [59:52]  PORTG0[7:0]
//   PD(p8)   [3:0]         [10:7]    [51:48]  PORTPD[7:4]
//   PD(p7)   [3:0]          [4:1]    [47:44]  PORTPD[3:0]    
//   PC(p6)   [3:0]         [10:7]    [43:40]  PORTPC[7:4]
//   PC(p5)   [3:0]          [4:1]    [39:36]  PORTPC[3:0]    
//   PB(p4)   [3:0]         [10:7]    [35:32]  PORTPB[7:4]
//   PB(p3)   [3:0]          [4:1]    [31:28]  PORTPB[3:0]    
//   PA(p2)   [3:0]         [10:7]    [27:24]  PORTPA[7:4]
//   PA(p1)   [3:0]          [4:1]    [23:20]  PORTPA[3:0]    
//   PortC    [5:0]          [5:0]    [19:14]  PORTC[5:0]     
//   PortB    [5:0]         [13:8]     [13:8]  PORTB[5:0]    
//   PortD    [7:0]          [7:0]      [7:0]  PORTD[7:0]       
//
//=================================================================
///////////////////////////////////////////////////////////////////

  
module xlr8_hinj_gpio
  #(
    parameter       NUM_PINS = 122,
    parameter   NUM_UNO_PINS = 20,
    parameter PORTBT_Address = 8'h71,
    parameter  DDRBT_Address = 8'h72,
    parameter  PINBT_Address = 8'h73,
    parameter PORTX1_Address = 8'h74,
    parameter  DDRX1_Address = 8'h75,
    parameter  PINX1_Address = 8'h76,
    parameter PORTX0_Address = 8'h8c,
    parameter  DDRX0_Address = 8'h8d,
    parameter  PINX0_Address = 8'h8e,
    parameter PORTSW_Address = 8'h8f,
    parameter  DDRSW_Address = 8'h90,
    parameter  PINSW_Address = 8'h91,
    parameter PORTLD_Address = 8'h92,
    parameter  DDRLD_Address = 8'h93,
    parameter  PINLD_Address = 8'h94,
    parameter PORTG4_Address = 8'h95,
    parameter  DDRG4_Address = 8'h96,
    parameter  PING4_Address = 8'h97,
    parameter PORTG3_Address = 8'h98,
    parameter  DDRG3_Address = 8'h99,
    parameter  PING3_Address = 8'h9a,
    parameter PORTG2_Address = 8'h9b,
    parameter  DDRG2_Address = 8'h9c,
    parameter  PING2_Address = 8'h9d,
    parameter PORTG1_Address = 8'h9e,
    parameter  DDRG1_Address = 8'h9f,
    parameter  PING1_Address = 8'ha0,
    parameter PORTG0_Address = 8'ha1,
    parameter  DDRG0_Address = 8'ha2,
    parameter  PING0_Address = 8'ha3,
    parameter PORTPD_Address = 8'ha4,
    parameter  DDRPD_Address = 8'ha5,
    parameter  PINPD_Address = 8'ha6,
    parameter PORTPC_Address = 8'ha7,
    parameter  DDRPC_Address = 8'ha8,
    parameter  PINPC_Address = 8'ha9,
    parameter PORTPB_Address = 8'haa,
    parameter  DDRPB_Address = 8'hab,
    parameter  PINPB_Address = 8'hac,
    parameter PORTPA_Address = 8'had,
    parameter  DDRPA_Address = 8'hae,
    parameter  PINPA_Address = 8'haf,
    parameter  MSKX1_Address = 8'hdd,
    parameter  MSKX0_Address = 8'hdd,
    parameter  MSKG4_Address = 8'hde,
    parameter  MSKG3_Address = 8'hdf,
    parameter  MSKG2_Address = 8'he0,
    parameter  MSKG1_Address = 8'he1,
    parameter  MSKG0_Address = 8'he2,
    parameter  MSKPD_Address = 8'he3,
    parameter  MSKPC_Address = 8'he4,                                        
    parameter  MSKPB_Address = 8'he5,
    parameter  MSKPA_Address = 8'he6 
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
    input [NUM_PINS-1:NUM_UNO_PINS]        xb_ddoe,
    input [NUM_PINS-1:NUM_UNO_PINS]        xb_ddov,
    input [NUM_PINS-1:NUM_UNO_PINS]        xb_pvoe,
    input [NUM_PINS-1:NUM_UNO_PINS]        xb_pvov,
    // Outputs
    // port_pads goes to the top level module I/O ports, ie: the chip pins
    inout [NUM_PINS-1:NUM_UNO_PINS]        port_pads,
    // xb_pinx is the pin value for use by the XBs
    output logic [NUM_PINS-1:NUM_UNO_PINS] xb_pinx,
    // Pin Change Interrupts to xlr8_pcit module
    output logic [5:0]                     pcint
    );
   
   // Bit ranges within the big bus for the various ports. See chart in header
   localparam PORTBT_HI =  121; // Port BT[1:0]
   localparam PORTBT_LO =  120;
   localparam PORTX1_HI =  119; // Port X1[7:0]
   localparam PORTX1_LO =  112;
   localparam PORTX0_HI =  111; // Port X0[7:0]
   localparam PORTX0_LO =  104;
   localparam PORTSW_HI =  103; // Port SW[7:0]
   localparam PORTSW_LO =   96;
   localparam PORTLD_HI =   95; // Port DL[7:0]
   localparam PORTLD_LO =   88;
   localparam PORTG4_HI =   87; // Port G4[3:0]
   localparam PORTG4_LO =   84;
   localparam PORTG3_HI =   83; // Port G3[7:0]
   localparam PORTG3_LO =   76;
   localparam PORTG2_HI =   75; // Port G2[7:0]
   localparam PORTG2_LO =   68;
   localparam PORTG1_HI =   67; // Port G1[7:0]
   localparam PORTG1_LO =   60;
   localparam PORTG0_HI =   59; // Port G0[7:0]
   localparam PORTG0_LO =   52;
   localparam PORTPD_HI =   51; // Port PD[7:0]
   localparam PORTPD_LO =   44;
   localparam PORTPC_HI =   43; // Port PC[7:0]
   localparam PORTPC_LO =   36;
   localparam PORTPB_HI =   35; // Port PB[7:0]
   localparam PORTPB_LO =   28;
   localparam PORTPA_HI =   27; // Port PA[7:0]
   localparam PORTPA_LO =   20;

   // These connect between the port and the portmux
   logic [NUM_PINS-1:NUM_UNO_PINS]         port_portx;
   logic [NUM_PINS-1:NUM_UNO_PINS]         port_ddrx;
   logic [NUM_PINS-1:NUM_UNO_PINS]         port_pinx;

   // Pin Change Interrupts
   logic [1:0]                             x_pcifr_set;
   logic [4:0]                             g_pcifr_set;
   logic                                   pd_pcifr_set;
   logic                                   pc_pcifr_set;
   logic                                   pb_pcifr_set;
   logic                                   pa_pcifr_set;
   
   // dbus_out enables for each port
   logic                        bt_io_out_en;
   logic                        x1_io_out_en;
   logic                        x0_io_out_en;
   logic                        sw_io_out_en;
   logic                        ld_io_out_en;
   logic                        g4_io_out_en;
   logic                        g3_io_out_en;
   logic                        g2_io_out_en;
   logic                        g1_io_out_en;
   logic                        g0_io_out_en;
   logic                        pd_io_out_en;
   logic                        pc_io_out_en;
   logic                        pb_io_out_en;
   logic                        pa_io_out_en;
   // dbus_out data for each port
   logic [7:0]                  bt_dbus_out;
   logic [7:0]                  x1_dbus_out;
   logic [7:0]                  x0_dbus_out;
   logic [7:0]                  sw_dbus_out;
   logic [7:0]                  ld_dbus_out;
   logic [7:0]                  g4_dbus_out;
   logic [7:0]                  g3_dbus_out;
   logic [7:0]                  g2_dbus_out;
   logic [7:0]                  g1_dbus_out;
   logic [7:0]                  g0_dbus_out;
   logic [7:0]                  pd_dbus_out;
   logic [7:0]                  pc_dbus_out;
   logic [7:0]                  pb_dbus_out;
   logic [7:0]                  pa_dbus_out;
   
   // Combine the dbus_outs before sending back up to tthe top level
   assign dbus_out  = bt_io_out_en ? bt_dbus_out :
                      x1_io_out_en ? x1_dbus_out :
                      x0_io_out_en ? x0_dbus_out :
                      sw_io_out_en ? sw_dbus_out :
                      ld_io_out_en ? ld_dbus_out :
                      g4_io_out_en ? g4_dbus_out :
                      g3_io_out_en ? g3_dbus_out :
                      g2_io_out_en ? g2_dbus_out :
                      g1_io_out_en ? g1_dbus_out :
                      g0_io_out_en ? g0_dbus_out :
                      pd_io_out_en ? pd_dbus_out :
                      pc_io_out_en ? pc_dbus_out :
                      pb_io_out_en ? pb_dbus_out :
                      pa_io_out_en ? pa_dbus_out :
                      8'h00;

   assign io_out_en = bt_io_out_en || 
                      x1_io_out_en || 
                      x0_io_out_en || 
                      sw_io_out_en || 
                      ld_io_out_en || 
                      g4_io_out_en || 
                      g3_io_out_en || 
                      g2_io_out_en || 
                      g1_io_out_en || 
                      g0_io_out_en || 
                      pd_io_out_en || 
                      pc_io_out_en || 
                      pb_io_out_en || 
                      pa_io_out_en;

   assign pcint = {(|x_pcifr_set),(|g_pcifr_set),
                   pd_pcifr_set,pc_pcifr_set,pb_pcifr_set,pa_pcifr_set};

   // === PORT BT === PORT BT === PORT BT === PORT BT === PORT BT === PORT BT ===

   //----------------------------------------------------------------------
   // Instance Name:  portmux_bt_inst
   // Module Type:    xlr8_portmux
   //
   //----------------------------------------------------------------------
   xlr8_portmux 
     #(
       .WIDTH        (2)
       )
   portmux_bt_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      // Inputs
      .port_portx  (port_portx[PORTBT_HI:PORTBT_LO]),// From xlr8_avr_port module
      .port_ddrx   (port_ddrx[PORTBT_HI:PORTBT_LO]), // From xlr8_avr_port module
      .xb_ddoe     (xb_ddoe[PORTBT_HI:PORTBT_LO]),   // pin direction control enable from XBs
      .xb_ddov     (xb_ddov[PORTBT_HI:PORTBT_LO]),   // pin direction value from XBs
      .xb_pvoe     (xb_pvoe[PORTBT_HI:PORTBT_LO]),   // pin output enable from XBs
      .xb_pvov     (xb_pvov[PORTBT_HI:PORTBT_LO]),   // pin output value from XBs
      // Outputs
      .port_pads   (port_pads[PORTBT_HI:PORTBT_LO]), // inout to parent module
      .port_pinx   (port_pinx[PORTBT_HI:PORTBT_LO]), // pin values to xlr8_avr_port module
      .xb_pinx     (xb_pinx[PORTBT_HI:PORTBT_LO])    // output to parent module
      );

   //----------------------------------------------------------------------
   // Instance Name:  port_bt_inst
   // Module Type:    xlr8_avr_port
   //
   //----------------------------------------------------------------------
   xlr8_avr_port 
     #(
       .PORTX_ADDR   (PORTBT_Address),
       .DDRX_ADDR    (DDRBT_Address),
       .PINX_ADDR    (PINBT_Address),
       .WIDTH        (2)
       )
   port_bt_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      .clken       (1'b1),
      // I/O
      .adr         (adr),
      .dbus_in     (dbus_in),
      .dbus_out    (bt_dbus_out),
      .iore        (iore),
      .iowe        (iowe),
      .io_out_en   (bt_io_out_en),
      // DM
      .ramadr      (ramadr),
      .ramre       (ramre),
      .ramwe       (ramwe),
      .dm_sel      (dm_sel),
      // External connection
      .portx       (port_portx[PORTBT_HI:PORTBT_LO]), // To portmux module
      .ddrx        (port_ddrx[PORTBT_HI:PORTBT_LO]),  // To portmux module
      .pinx        (port_pinx[PORTBT_HI:PORTBT_LO])   // From portmux module
      );
   

   // === PORT X1 === PORT X1 === PORT X1 === PORT X1 === PORT X1 === PORT X1 ===

   //----------------------------------------------------------------------
   // Instance Name:  portmux_x1_inst
   // Module Type:    xlr8_portmux
   //
   //----------------------------------------------------------------------
   xlr8_portmux 
     #(
       .WIDTH        (8)
       )
   portmux_x1_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      // Inputs
      .port_portx  (port_portx[PORTX1_HI:PORTX1_LO]),// From xlr8_avr_port module
      .port_ddrx   (port_ddrx[PORTX1_HI:PORTX1_LO]), // From xlr8_avr_port module
      .xb_ddoe     (xb_ddoe[PORTX1_HI:PORTX1_LO]),   // pin direction control enable from XBs
      .xb_ddov     (xb_ddov[PORTX1_HI:PORTX1_LO]),   // pin direction value from XBs
      .xb_pvoe     (xb_pvoe[PORTX1_HI:PORTX1_LO]),   // pin output enable from XBs
      .xb_pvov     (xb_pvov[PORTX1_HI:PORTX1_LO]),   // pin output value from XBs
      // Outputs
      .port_pads   (port_pads[PORTX1_HI:PORTX1_LO]), // inout to parent module
      .port_pinx   (port_pinx[PORTX1_HI:PORTX1_LO]), // pin values to xlr8_avr_port module
      .xb_pinx     (xb_pinx[PORTX1_HI:PORTX1_LO])    // output to parent module
      );

   //----------------------------------------------------------------------
   // Instance Name:  port_x1_inst
   // Module Type:    xlr8_avr_port
   //
   //----------------------------------------------------------------------
   xlr8_avr_port 
     #(
       .PORTX_ADDR   (PORTX1_Address),
       .DDRX_ADDR    (DDRX1_Address),
       .PINX_ADDR    (PINX1_Address),
       .PCMSK_ADDR   (MSKX1_Address),
       .WIDTH        (8)
       )
   port_x1_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      .clken       (1'b1),
      // I/O
      .adr         (adr),
      .dbus_in     (dbus_in),
      .dbus_out    (x1_dbus_out),
      .iore        (iore),
      .iowe        (iowe),
      .io_out_en   (x1_io_out_en),
      // DM
      .ramadr      (ramadr),
      .ramre       (ramre),
      .ramwe       (ramwe),
      .dm_sel      (dm_sel),
      // External connection
      .portx       (port_portx[PORTX1_HI:PORTX1_LO]), // To portmux module
      .ddrx        (port_ddrx[PORTX1_HI:PORTX1_LO]),  // To portmux module
      .pinx        (port_pinx[PORTX1_HI:PORTX1_LO]),   // From portmux module
      .pcifr_set   (x_pcifr_set[1]) //                     Pin Change Int to xlr8_pcint
      );
   

   // === PORT X0 === PORT X0 === PORT X0 === PORT X0 === PORT X0 === PORT X0 ===

   //----------------------------------------------------------------------
   // Instance Name:  portmux_x0_inst
   // Module Type:    xlr8_portmux
   //
   //----------------------------------------------------------------------
   xlr8_portmux 
     #(
       .WIDTH        (8)
       )
   portmux_x0_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      // Inputs
      .port_portx  (port_portx[PORTX0_HI:PORTX0_LO]),// From xlr8_avr_port module
      .port_ddrx   (port_ddrx[PORTX0_HI:PORTX0_LO]), // From xlr8_avr_port module
      .xb_ddoe     (xb_ddoe[PORTX0_HI:PORTX0_LO]),   // pin direction control enable from XBs
      .xb_ddov     (xb_ddov[PORTX0_HI:PORTX0_LO]),   // pin direction value from XBs
      .xb_pvoe     (xb_pvoe[PORTX0_HI:PORTX0_LO]),   // pin output enable from XBs
      .xb_pvov     (xb_pvov[PORTX0_HI:PORTX0_LO]),   // pin output value from XBs
      // Outputs
      .port_pads   (port_pads[PORTX0_HI:PORTX0_LO]), // inout to parent module
      .port_pinx   (port_pinx[PORTX0_HI:PORTX0_LO]), // pin values to xlr8_avr_port module
      .xb_pinx     (xb_pinx[PORTX0_HI:PORTX0_LO])    // output to parent module
      );

   //----------------------------------------------------------------------
   // Instance Name:  port_x0_inst
   // Module Type:    xlr8_avr_port
   //
   //----------------------------------------------------------------------
   xlr8_avr_port 
     #(
       .PORTX_ADDR   (PORTX0_Address),
       .DDRX_ADDR    (DDRX0_Address),
       .PINX_ADDR    (PINX0_Address),
       .PCMSK_ADDR   (MSKX0_Address),
       .WIDTH        (8)
       )
   port_x0_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      .clken       (1'b1),
      // I/O
      .adr         (adr),
      .dbus_in     (dbus_in),
      .dbus_out    (x0_dbus_out),
      .iore        (iore),
      .iowe        (iowe),
      .io_out_en   (x0_io_out_en),
      // DM
      .ramadr      (ramadr),
      .ramre       (ramre),
      .ramwe       (ramwe),
      .dm_sel      (dm_sel),
      // External connection
      .portx       (port_portx[PORTX0_HI:PORTX0_LO]), // To portmux module
      .ddrx        (port_ddrx[PORTX0_HI:PORTX0_LO]), //  To portmux module
      .pinx        (port_pinx[PORTX0_HI:PORTX0_LO]), //  From portmux module
      .pcifr_set   (x_pcifr_set[0]) //                     Pin Change Int to xlr8_pcint
      );
   

   // === PORT SW === PORT SW === PORT SW === PORT SW === PORT SW === PORT SW ===

   //----------------------------------------------------------------------
   // Instance Name:  portmux_sw_inst
   // Module Type:    xlr8_portmux
   //
   //----------------------------------------------------------------------
   xlr8_portmux 
     #(
       .WIDTH        (8)
       )
   portmux_sw_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      // Inputs
      .port_portx  (port_portx[PORTSW_HI:PORTSW_LO]),// From xlr8_avr_port module
      .port_ddrx   (port_ddrx[PORTSW_HI:PORTSW_LO]), // From xlr8_avr_port module
      .xb_ddoe     (xb_ddoe[PORTSW_HI:PORTSW_LO]),   // pin direction control enable from XBs
      .xb_ddov     (xb_ddov[PORTSW_HI:PORTSW_LO]),   // pin direction value from XBs
      .xb_pvoe     (xb_pvoe[PORTSW_HI:PORTSW_LO]),   // pin output enable from XBs
      .xb_pvov     (xb_pvov[PORTSW_HI:PORTSW_LO]),   // pin output value from XBs
      // Outputs
      .port_pads   (port_pads[PORTSW_HI:PORTSW_LO]), // inout to parent module
      .port_pinx   (port_pinx[PORTSW_HI:PORTSW_LO]), // pin values to xlr8_avr_port module
      .xb_pinx     (xb_pinx[PORTSW_HI:PORTSW_LO])    // output to parent module
      );

   //----------------------------------------------------------------------
   // Instance Name:  port_sw_inst
   // Module Type:    xlr8_avr_port
   //
   //----------------------------------------------------------------------
   xlr8_avr_port 
     #(
       .PORTX_ADDR   (PORTSW_Address),
       .DDRX_ADDR    (DDRSW_Address),
       .PINX_ADDR    (PINSW_Address),
       .WIDTH        (8)
       )
   port_sw_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      .clken       (1'b1),
      // I/O
      .adr         (adr),
      .dbus_in     (dbus_in),
      .dbus_out    (sw_dbus_out),
      .iore        (iore),
      .iowe        (iowe),
      .io_out_en   (sw_io_out_en),
      // DM
      .ramadr      (ramadr),
      .ramre       (ramre),
      .ramwe       (ramwe),
      .dm_sel      (dm_sel),
      // External connection
      .portx       (port_portx[PORTSW_HI:PORTSW_LO]), // To portmux module
      .ddrx        (port_ddrx[PORTSW_HI:PORTSW_LO]),  // To portmux module
      .pinx        (port_pinx[PORTSW_HI:PORTSW_LO])   // From portmux module
      );
   

   // === PORT X1 === PORT LD === PORT LD === PORT LD === PORT LD === PORT LD ===

   //----------------------------------------------------------------------
   // Instance Name:  portmux_ld_inst
   // Module Type:    xlr8_portmux
   //
   //----------------------------------------------------------------------
   xlr8_portmux 
     #(
       .WIDTH        (8)
       )
   portmux_ld_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      // Inputs
      .port_portx  (port_portx[PORTLD_HI:PORTLD_LO]),// From xlr8_avr_port module
      .port_ddrx   (port_ddrx[PORTLD_HI:PORTLD_LO]), // From xlr8_avr_port module
      .xb_ddoe     (xb_ddoe[PORTLD_HI:PORTLD_LO]),   // pin direction control enable from XBs
      .xb_ddov     (xb_ddov[PORTLD_HI:PORTLD_LO]),   // pin direction value from XBs
      .xb_pvoe     (xb_pvoe[PORTLD_HI:PORTLD_LO]),   // pin output enable from XBs
      .xb_pvov     (xb_pvov[PORTLD_HI:PORTLD_LO]),   // pin output value from XBs
      // Outputs
      .port_pads   (port_pads[PORTLD_HI:PORTLD_LO]), // inout to parent module
      .port_pinx   (port_pinx[PORTLD_HI:PORTLD_LO]), // pin values to xlr8_avr_port module
      .xb_pinx     (xb_pinx[PORTLD_HI:PORTLD_LO])    // output to parent module
      );

   //----------------------------------------------------------------------
   // Instance Name:  port_ld_inst
   // Module Type:    xlr8_avr_port
   //
   //----------------------------------------------------------------------
   xlr8_avr_port 
     #(
       .PORTX_ADDR   (PORTLD_Address),
       .DDRX_ADDR    (DDRLD_Address),
       .PINX_ADDR    (PINLD_Address),
       .DDRX_RST_VAL (8'hFF), // LEDs should always be outputs
       .WIDTH        (8)
       )
   port_ld_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      .clken       (1'b1),
      // I/O
      .adr         (adr),
      .dbus_in     (dbus_in),
      .dbus_out    (ld_dbus_out),
      .iore        (iore),
      .iowe        (iowe),
      .io_out_en   (ld_io_out_en),
      // DM
      .ramadr      (ramadr),
      .ramre       (ramre),
      .ramwe       (ramwe),
      .dm_sel      (dm_sel),
      // External connection
      .portx       (port_portx[PORTLD_HI:PORTLD_LO]), // To portmux module
      .ddrx        (port_ddrx[PORTLD_HI:PORTLD_LO]),  // To portmux module
      .pinx        (port_pinx[PORTLD_HI:PORTLD_LO])   // From portmux module
      );
   

   // === PORT G4 === PORT G4 === PORT G4 === PORT G4 === PORT G4 === PORT G4 ===

   //----------------------------------------------------------------------
   // Instance Name:  portmux_g4_inst
   // Module Type:    xlr8_portmux
   //
   //----------------------------------------------------------------------
   xlr8_portmux 
     #(
       .WIDTH        (4)
       )
   portmux_g4_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      // Inputs
      .port_portx  (port_portx[PORTG4_HI:PORTG4_LO]),// From xlr8_avr_port module
      .port_ddrx   (port_ddrx[PORTG4_HI:PORTG4_LO]), // From xlr8_avr_port module
      .xb_ddoe     (xb_ddoe[PORTG4_HI:PORTG4_LO]),   // pin direction control enable from XBs
      .xb_ddov     (xb_ddov[PORTG4_HI:PORTG4_LO]),   // pin direction value from XBs
      .xb_pvoe     (xb_pvoe[PORTG4_HI:PORTG4_LO]),   // pin output enable from XBs
      .xb_pvov     (xb_pvov[PORTG4_HI:PORTG4_LO]),   // pin output value from XBs
      // Outputs
      .port_pads   (port_pads[PORTG4_HI:PORTG4_LO]), // inout to parent module
      .port_pinx   (port_pinx[PORTG4_HI:PORTG4_LO]), // pin values to xlr8_avr_port module
      .xb_pinx     (xb_pinx[PORTG4_HI:PORTG4_LO])    // output to parent module
      );

   //----------------------------------------------------------------------
   // Instance Name:  port_g4_inst
   // Module Type:    xlr8_avr_port
   //
   //----------------------------------------------------------------------
   xlr8_avr_port 
     #(
       .PORTX_ADDR   (PORTG4_Address),
       .DDRX_ADDR    (DDRG4_Address),
       .PINX_ADDR    (PING4_Address),
       .PCMSK_ADDR   (MSKG4_Address),
       .WIDTH        (4)
       )
   port_g4_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      .clken       (1'b1),
      // I/O
      .adr         (adr),
      .dbus_in     (dbus_in),
      .dbus_out    (g4_dbus_out),
      .iore        (iore),
      .iowe        (iowe),
      .io_out_en   (g4_io_out_en),
      // DM
      .ramadr      (ramadr),
      .ramre       (ramre),
      .ramwe       (ramwe),
      .dm_sel      (dm_sel),
      // External connection
      .portx       (port_portx[PORTG4_HI:PORTG4_LO]), // To portmux module
      .ddrx        (port_ddrx[PORTG4_HI:PORTG4_LO]), //  To portmux module
      .pinx        (port_pinx[PORTG4_HI:PORTG4_LO]), //  From portmux module
      .pcifr_set   (g_pcifr_set[4]) //                   Pin Change Int to xlr8_pcint
      );
   

   // === PORT G3 === PORT G3 === PORT G3 === PORT G3 === PORT G3 === PORT G3 ===

   //----------------------------------------------------------------------
   // Instance Name:  portmux_g3_inst
   // Module Type:    xlr8_portmux
   //
   //----------------------------------------------------------------------
   xlr8_portmux 
     #(
       .WIDTH        (8)
       )
   portmux_g3_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      // Inputs
      .port_portx  (port_portx[PORTG3_HI:PORTG3_LO]),// From xlr8_avr_port module
      .port_ddrx   (port_ddrx[PORTG3_HI:PORTG3_LO]), // From xlr8_avr_port module
      .xb_ddoe     (xb_ddoe[PORTG3_HI:PORTG3_LO]),   // pin direction control enable from XBs
      .xb_ddov     (xb_ddov[PORTG3_HI:PORTG3_LO]),   // pin direction value from XBs
      .xb_pvoe     (xb_pvoe[PORTG3_HI:PORTG3_LO]),   // pin output enable from XBs
      .xb_pvov     (xb_pvov[PORTG3_HI:PORTG3_LO]),   // pin output value from XBs
      // Outputs
      .port_pads   (port_pads[PORTG3_HI:PORTG3_LO]), // inout to parent module
      .port_pinx   (port_pinx[PORTG3_HI:PORTG3_LO]), // pin values to xlr8_avr_port module
      .xb_pinx     (xb_pinx[PORTG3_HI:PORTG3_LO])    // output to parent module
      );

   //----------------------------------------------------------------------
   // Instance Name:  port_g3_inst
   // Module Type:    xlr8_avr_port
   //
   //----------------------------------------------------------------------
   xlr8_avr_port 
     #(
       .PORTX_ADDR   (PORTG3_Address),
       .DDRX_ADDR    (DDRG3_Address),
       .PINX_ADDR    (PING3_Address),
       .PCMSK_ADDR   (MSKG3_Address),
       .WIDTH        (8)
       )
   port_g3_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      .clken       (1'b1),
      // I/O
      .adr         (adr),
      .dbus_in     (dbus_in),
      .dbus_out    (g3_dbus_out),
      .iore        (iore),
      .iowe        (iowe),
      .io_out_en   (g3_io_out_en),
      // DM
      .ramadr      (ramadr),
      .ramre       (ramre),
      .ramwe       (ramwe),
      .dm_sel      (dm_sel),
      // External connection
      .portx       (port_portx[PORTG3_HI:PORTG3_LO]), // To portmux module
      .ddrx        (port_ddrx[PORTG3_HI:PORTG3_LO]),  // To portmux module
      .pinx        (port_pinx[PORTG3_HI:PORTG3_LO]),  // From portmux module
      .pcifr_set   (g_pcifr_set[3]) //                   Pin Change Int to xlr8_pcint
      );
   

   // === PORT G2 === PORT G2 === PORT G2 === PORT G2 === PORT G2 === PORT G2 ===

   //----------------------------------------------------------------------
   // Instance Name:  portmux_g2_inst
   // Module Type:    xlr8_portmux
   //
   //----------------------------------------------------------------------
   xlr8_portmux 
     #(
       .WIDTH        (8)
       )
   portmux_g2_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      // Inputs
      .port_portx  (port_portx[PORTG2_HI:PORTG2_LO]),// From xlr8_port module
      .port_ddrx   (port_ddrx[PORTG2_HI:PORTG2_LO]), // From xlr8_port module
      .xb_ddoe     (xb_ddoe[PORTG2_HI:PORTG2_LO]),   // pin direction control enable from XBs
      .xb_ddov     (xb_ddov[PORTG2_HI:PORTG2_LO]),   // pin direction value from XBs
      .xb_pvoe     (xb_pvoe[PORTG2_HI:PORTG2_LO]),   // pin output enable from XBs
      .xb_pvov     (xb_pvov[PORTG2_HI:PORTG2_LO]),   // pin output value from XBs
      // Outputs
      .port_pads   (port_pads[PORTG2_HI:PORTG2_LO]), // inout to parent module
      .port_pinx   (port_pinx[PORTG2_HI:PORTG2_LO]), // pin values to xlr8_port module
      .xb_pinx     (xb_pinx[PORTG2_HI:PORTG2_LO])    // output to parent module
      );

   //----------------------------------------------------------------------
   // Instance Name:  port_g2_inst
   // Module Type:    xlr8_avr_port
   //
   //----------------------------------------------------------------------
   xlr8_avr_port 
     #(
       .PORTX_ADDR   (PORTG2_Address),
       .DDRX_ADDR    (DDRG2_Address),
       .PINX_ADDR    (PING2_Address),
       .PCMSK_ADDR   (MSKG2_Address),
       .WIDTH        (8)
       )
   port_g2_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      .clken       (1'b1),
      // I/O
      .adr         (adr),
      .dbus_in     (dbus_in),
      .dbus_out    (g2_dbus_out),
      .iore        (iore),
      .iowe        (iowe),
      .io_out_en   (g2_io_out_en),
      // DM
      .ramadr      (ramadr),
      .ramre       (ramre),
      .ramwe       (ramwe),
      .dm_sel      (dm_sel),
      // External connection
      .portx       (port_portx[PORTG2_HI:PORTG2_LO]), // To portmux module
      .ddrx        (port_ddrx[PORTG2_HI:PORTG2_LO]),  // To portmux module
      .pinx        (port_pinx[PORTG2_HI:PORTG2_LO]),  // From portmux module
      .pcifr_set   (g_pcifr_set[2]) //                   Pin Change Int to xlr8_pcint
      );
   

   // === PORT G1 === PORT G1 === PORT G1 === PORT G1 === PORT G1 === PORT G1 ===

   //----------------------------------------------------------------------
   // Instance Name:  portmux_g1_inst
   // Module Type:    xlr8_portmux
   //
   //----------------------------------------------------------------------
   xlr8_portmux 
     #(
       .WIDTH        (8)
       )
   portmux_g1_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      // Inputs
      .port_portx  (port_portx[PORTG1_HI:PORTG1_LO]),// From xlr8_avr_port module
      .port_ddrx   (port_ddrx[PORTG1_HI:PORTG1_LO]), // From xlr8_avr_port module
      .xb_ddoe     (xb_ddoe[PORTG1_HI:PORTG1_LO]),   // pin direction control enable from XBs
      .xb_ddov     (xb_ddov[PORTG1_HI:PORTG1_LO]),   // pin direction value from XBs
      .xb_pvoe     (xb_pvoe[PORTG1_HI:PORTG1_LO]),   // pin output enable from XBs
      .xb_pvov     (xb_pvov[PORTG1_HI:PORTG1_LO]),   // pin output value from XBs
      // Outputs
      .port_pads   (port_pads[PORTG1_HI:PORTG1_LO]), // inout to parent module
      .port_pinx   (port_pinx[PORTG1_HI:PORTG1_LO]), // pin values to xlr8_avr_port module
      .xb_pinx     (xb_pinx[PORTG1_HI:PORTG1_LO])    // output to parent module
      );

   //----------------------------------------------------------------------
   // Instance Name:  port_g1_inst
   // Module Type:    xlr8_avr_port
   //
   //----------------------------------------------------------------------
   xlr8_avr_port 
     #(
       .PORTX_ADDR   (PORTG1_Address),
       .DDRX_ADDR    (DDRG1_Address),
       .PINX_ADDR    (PING1_Address),
       .PCMSK_ADDR   (MSKG1_Address),
       .WIDTH        (8)
       )
   port_g1_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      .clken       (1'b1),
      // I/O
      .adr         (adr),
      .dbus_in     (dbus_in),
      .dbus_out    (g1_dbus_out),
      .iore        (iore),
      .iowe        (iowe),
      .io_out_en   (g1_io_out_en),
      // DM
      .ramadr      (ramadr),
      .ramre       (ramre),
      .ramwe       (ramwe),
      .dm_sel      (dm_sel),
      // External connection
      .portx       (port_portx[PORTG1_HI:PORTG1_LO]), // To portmux module
      .ddrx        (port_ddrx[PORTG1_HI:PORTG1_LO]),  // To portmux module
      .pinx        (port_pinx[PORTG1_HI:PORTG1_LO]),  // From portmux module
      .pcifr_set   (g_pcifr_set[1]) //                   Pin Change Int to xlr8_pcint
      );
   

   // === PORT G0 === PORT G0 === PORT G0 === PORT G0 === PORT G0 === PORT G0 ===

   //----------------------------------------------------------------------
   // Instance Name:  portmux_g0_inst
   // Module Type:    xlr8_portmux
   //
   //----------------------------------------------------------------------
   xlr8_portmux 
     #(
       .WIDTH        (8)
       )
   portmux_g0_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      // Inputs
      .port_portx  (port_portx[PORTG0_HI:PORTG0_LO]),// From xlr8_avr_port module
      .port_ddrx   (port_ddrx[PORTG0_HI:PORTG0_LO]), // From xlr8_avr_port module
      .xb_ddoe     (xb_ddoe[PORTG0_HI:PORTG0_LO]),   // pin direction control enable from XBs
      .xb_ddov     (xb_ddov[PORTG0_HI:PORTG0_LO]),   // pin direction value from XBs
      .xb_pvoe     (xb_pvoe[PORTG0_HI:PORTG0_LO]),   // pin output enable from XBs
      .xb_pvov     (xb_pvov[PORTG0_HI:PORTG0_LO]),   // pin output value from XBs
      // Outputs
      .port_pads   (port_pads[PORTG0_HI:PORTG0_LO]), // inout to parent module
      .port_pinx   (port_pinx[PORTG0_HI:PORTG0_LO]), // pin values to xlr8_avr_port module
      .xb_pinx     (xb_pinx[PORTG0_HI:PORTG0_LO])    // output to parent module
      );

   //----------------------------------------------------------------------
   // Instance Name:  port_g0_inst
   // Module Type:    xlr8_avr_port
   //
   //----------------------------------------------------------------------
   xlr8_avr_port 
     #(
       .PORTX_ADDR   (PORTG0_Address),
       .DDRX_ADDR    (DDRG0_Address),
       .PINX_ADDR    (PING0_Address),
       .PCMSK_ADDR   (MSKG0_Address),
       .WIDTH        (8)
       )
   port_g0_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      .clken       (1'b1),
      // I/O
      .adr         (adr),
      .dbus_in     (dbus_in),
      .dbus_out    (g0_dbus_out),
      .iore        (iore),
      .iowe        (iowe),
      .io_out_en   (g0_io_out_en),
      // DM
      .ramadr      (ramadr),
      .ramre       (ramre),
      .ramwe       (ramwe),
      .dm_sel      (dm_sel),
      // External connection
      .portx       (port_portx[PORTG0_HI:PORTG0_LO]), // To portmux module
      .ddrx        (port_ddrx[PORTG0_HI:PORTG0_LO]),  // To portmux module
      .pinx        (port_pinx[PORTG0_HI:PORTG0_LO]),  // From portmux module
      .pcifr_set   (g_pcifr_set[0]) //                   Pin Change Int to xlr8_pcint
      );
   


   // === PORT PD === PORT PD === PORT PD === PORT PD === PORT PD === PORT PD ===

   //----------------------------------------------------------------------
   // Instance Name:  portmux_pd_inst
   // Module Type:    xlr8_portmux
   //
   //----------------------------------------------------------------------
   xlr8_portmux 
     #(
       .WIDTH        (8)
       )
   portmux_pd_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      // Inputs
      .port_portx  (port_portx[PORTPD_HI:PORTPD_LO]),// From xlr8_avr_port module
      .port_ddrx   (port_ddrx[PORTPD_HI:PORTPD_LO]), // From xlr8_avr_port module
      .xb_ddoe     (xb_ddoe[PORTPD_HI:PORTPD_LO]),   // pin direction control enable from XBs
      .xb_ddov     (xb_ddov[PORTPD_HI:PORTPD_LO]),   // pin direction value from XBs
      .xb_pvoe     (xb_pvoe[PORTPD_HI:PORTPD_LO]),   // pin output enable from XBs
      .xb_pvov     (xb_pvov[PORTPD_HI:PORTPD_LO]),   // pin output value from XBs
      // Outputs
      .port_pads   (port_pads[PORTPD_HI:PORTPD_LO]), // inout to parent module
      .port_pinx   (port_pinx[PORTPD_HI:PORTPD_LO]), // pin values to xlr8_avr_port module
      .xb_pinx     (xb_pinx[PORTPD_HI:PORTPD_LO])    // output to parent module
      );

   //----------------------------------------------------------------------
   // Instance Name:  port_pd_inst
   // Module Type:    xlr8_avr_port
   //
   //----------------------------------------------------------------------
   xlr8_avr_port 
     #(
       .PORTX_ADDR   (PORTPD_Address),
       .DDRX_ADDR    (DDRPD_Address),
       .PINX_ADDR    (PINPD_Address),
       .PCMSK_ADDR   (MSKPD_Address),
       .WIDTH        (8)
       )
   port_pd_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      .clken       (1'b1),
      // I/O
      .adr         (adr),
      .dbus_in     (dbus_in),
      .dbus_out    (pd_dbus_out),
      .iore        (iore),
      .iowe        (iowe),
      .io_out_en   (pd_io_out_en),
      // DM
      .ramadr      (ramadr),
      .ramre       (ramre),
      .ramwe       (ramwe),
      .dm_sel      (dm_sel),
      // External connection
      .portx       (port_portx[PORTPD_HI:PORTPD_LO]), // To portmux module
      .ddrx        (port_ddrx[PORTPD_HI:PORTPD_LO]),  // To portmux module
      .pinx        (port_pinx[PORTPD_HI:PORTPD_LO]),  // From portmux module
      .pcifr_set   (pd_pcifr_set) //                     Pin Change Int to xlr8_pcint
      );
   

   // === PORT PC === PORT PC === PORT PC === PORT PC === PORT PC === PORT PC ===

   //----------------------------------------------------------------------
   // Instance Name:  portmux_pc_inst
   // Module Type:    xlr8_portmux
   //
   //----------------------------------------------------------------------
   xlr8_portmux 
     #(
       .WIDTH        (8)
       )
   portmux_pc_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      // Inputs
      .port_portx  (port_portx[PORTPC_HI:PORTPC_LO]),// From xlr8_avr_port module
      .port_ddrx   (port_ddrx[PORTPC_HI:PORTPC_LO]), // From xlr8_avr_port module
      .xb_ddoe     (xb_ddoe[PORTPC_HI:PORTPC_LO]),   // pin direction control enable from XBs
      .xb_ddov     (xb_ddov[PORTPC_HI:PORTPC_LO]),   // pin direction value from XBs
      .xb_pvoe     (xb_pvoe[PORTPC_HI:PORTPC_LO]),   // pin output enable from XBs
      .xb_pvov     (xb_pvov[PORTPC_HI:PORTPC_LO]),   // pin output value from XBs
      // Outputs
      .port_pads   (port_pads[PORTPC_HI:PORTPC_LO]), // inout to parent module
      .port_pinx   (port_pinx[PORTPC_HI:PORTPC_LO]), // pin values to xlr8_avr_port module
      .xb_pinx     (xb_pinx[PORTPC_HI:PORTPC_LO])    // output to parent module
      );

   //----------------------------------------------------------------------
   // Instance Name:  port_pc_inst
   // Module Type:    xlr8_avr_port
   //
   //----------------------------------------------------------------------
   xlr8_avr_port 
     #(
       .PORTX_ADDR   (PORTPC_Address),
       .DDRX_ADDR    (DDRPC_Address),
       .PINX_ADDR    (PINPC_Address),
       .PCMSK_ADDR   (MSKPC_Address),
       .WIDTH        (8)
       )
   port_pc_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      .clken       (1'b1),
      // I/O
      .adr         (adr),
      .dbus_in     (dbus_in),
      .dbus_out    (pc_dbus_out),
      .iore        (iore),
      .iowe        (iowe),
      .io_out_en   (pc_io_out_en),
      // DM
      .ramadr      (ramadr),
      .ramre       (ramre),
      .ramwe       (ramwe),
      .dm_sel      (dm_sel),
      // External connection
      .portx       (port_portx[PORTPC_HI:PORTPC_LO]), // To portmux module
      .ddrx        (port_ddrx[PORTPC_HI:PORTPC_LO]),  // To portmux module
      .pinx        (port_pinx[PORTPC_HI:PORTPC_LO]),  // From portmux module
      .pcifr_set   (pc_pcifr_set) //                     Pin Change Int to xlr8_pcint
      );
   

   // === PORT PB === PORT PB === PORT PB === PORT PB === PORT PB === PORT PB ===

   //----------------------------------------------------------------------
   // Instance Name:  portmux_pb_inst
   // Module Type:    xlr8_portmux
   //
   //----------------------------------------------------------------------
   xlr8_portmux 
     #(
       .WIDTH        (8)
       )
   portmux_pb_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      // Inputs
      .port_portx  (port_portx[PORTPB_HI:PORTPB_LO]),// From xlr8_avr_port module
      .port_ddrx   (port_ddrx[PORTPB_HI:PORTPB_LO]), // From xlr8_avr_port module
      .xb_ddoe     (xb_ddoe[PORTPB_HI:PORTPB_LO]),   // pin direction control enable from XBs
      .xb_ddov     (xb_ddov[PORTPB_HI:PORTPB_LO]),   // pin direction value from XBs
      .xb_pvoe     (xb_pvoe[PORTPB_HI:PORTPB_LO]),   // pin output enable from XBs
      .xb_pvov     (xb_pvov[PORTPB_HI:PORTPB_LO]),   // pin output value from XBs
      // Outputs
      .port_pads   (port_pads[PORTPB_HI:PORTPB_LO]), // inout to parent module
      .port_pinx   (port_pinx[PORTPB_HI:PORTPB_LO]), // pin values to xlr8_avr_port module
      .xb_pinx     (xb_pinx[PORTPB_HI:PORTPB_LO])    // output to parent module
      );

   //----------------------------------------------------------------------
   // Instance Name:  port_pb_inst
   // Module Type:    xlr8_avr_port
   //
   //----------------------------------------------------------------------
   xlr8_avr_port 
     #(
       .PORTX_ADDR   (PORTPB_Address),
       .DDRX_ADDR    (DDRPB_Address),
       .PINX_ADDR    (PINPB_Address),
       .PCMSK_ADDR   (MSKPB_Address),
       .WIDTH        (8)
       )
   port_pb_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      .clken       (1'b1),
      // I/O
      .adr         (adr),
      .dbus_in     (dbus_in),
      .dbus_out    (pb_dbus_out),
      .iore        (iore),
      .iowe        (iowe),
      .io_out_en   (pb_io_out_en),
      // DM
      .ramadr      (ramadr),
      .ramre       (ramre),
      .ramwe       (ramwe),
      .dm_sel      (dm_sel),
      // External connection
      .portx       (port_portx[PORTPB_HI:PORTPB_LO]), // To portmux module
      .ddrx        (port_ddrx[PORTPB_HI:PORTPB_LO]),  // To portmux module
      .pinx        (port_pinx[PORTPB_HI:PORTPB_LO]),  // From portmux module
      .pcifr_set   (pb_pcifr_set) //                     Pin Change Int to xlr8_pcint
      );
   

   // === PORT PA === PORT PA === PORT PA === PORT PA === PORT PA === PORT PA ===

   //----------------------------------------------------------------------
   // Instance Name:  portmux_pa_inst
   // Module Type:    xlr8_portmux
   //
   //----------------------------------------------------------------------
   xlr8_portmux 
     #(
       .WIDTH        (8)
       )
   portmux_pa_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      // Inputs
      .port_portx  (port_portx[PORTPA_HI:PORTPA_LO]),// From xlr8_avr_port module
      .port_ddrx   (port_ddrx[PORTPA_HI:PORTPA_LO]), // From xlr8_avr_port module
      .xb_ddoe     (xb_ddoe[PORTPA_HI:PORTPA_LO]),   // pin direction control enable from XBs
      .xb_ddov     (xb_ddov[PORTPA_HI:PORTPA_LO]),   // pin direction value from XBs
      .xb_pvoe     (xb_pvoe[PORTPA_HI:PORTPA_LO]),   // pin output enable from XBs
      .xb_pvov     (xb_pvov[PORTPA_HI:PORTPA_LO]),   // pin output value from XBs
      // Outputs
      .port_pads   (port_pads[PORTPA_HI:PORTPA_LO]), // inout to parent module
      .port_pinx   (port_pinx[PORTPA_HI:PORTPA_LO]), // pin values to xlr8_avr_port module
      .xb_pinx     (xb_pinx[PORTPA_HI:PORTPA_LO])    // output to parent module
      );

   //----------------------------------------------------------------------
   // Instance Name:  port_pa_inst
   // Module Type:    xlr8_avr_port
   //
   //----------------------------------------------------------------------
   xlr8_avr_port 
     #(
       .PORTX_ADDR   (PORTPA_Address),
       .DDRX_ADDR    (DDRPA_Address),
       .PINX_ADDR    (PINPA_Address),
       .PCMSK_ADDR   (MSKPA_Address),
       .WIDTH        (8)
       )
   port_pa_inst
     (
      // Clock and Reset
      .rstn        (rstn),
      .clk         (clk),
      .clken       (1'b1),
      // I/O
      .adr         (adr),
      .dbus_in     (dbus_in),
      .dbus_out    (pa_dbus_out),
      .iore        (iore),
      .iowe        (iowe),
      .io_out_en   (pa_io_out_en),
      // DM
      .ramadr      (ramadr),
      .ramre       (ramre),
      .ramwe       (ramwe),
      .dm_sel      (dm_sel),
      // External connection
      .portx       (port_portx[PORTPA_HI:PORTPA_LO]), // To portmux module
      .ddrx        (port_ddrx[PORTPA_HI:PORTPA_LO]),  // To portmux module
      .pinx        (port_pinx[PORTPA_HI:PORTPA_LO]),  // From portmux module
      .pcifr_set   (pa_pcifr_set) //                     Pin Change Int to xlr8_pcint
      );
   

   
endmodule // xlr8_hinj_gpio



