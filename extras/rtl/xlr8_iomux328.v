/////////////////////////////////
// Filename    : xlr8_iomux328.v
// Author      : Matt Weber
// Description : I/O muxing to match tables 14-4 to 14-11 and figure 14-5
//                 in the ATmega328p  spec
//               Note we create the puoe and puov signals here to control
//                 the internal pullup resistors, but those may not actually
//                 be controllable.
//
// Copyright 2015, Superion Technology Group. All Rights Reserved
/////////////////////////////////

module xlr8_iomux328
   // #(parameter declaration)
   (input         clk,
    input logic   core_rstn, // for assertions
    
    // The actual I/O pads
    inout [5:0]   portb_pads,
    inout [5:0]   portc_pads,
    inout [7:0]   portd_pads,
    inout         SDA,
    inout         SCL,
`ifdef SNO_BOARD
    // For the Sno board, RX and TX are now seperate pins, so they have 
    // thier own outputs from iomux and are not on shared pins anymore.
    input         RX, // Dedicated pin now
    output        TX, // Dedicated pin now
`endif    
    // Control that applies to all ports
    input         PUD, // pullup-disable
    input         SLEEP, // power down input buffers
    input [5:0]   ADCD, // When set, corresponding PIN register on port C always reads 0
    // The general port inputs/outputs
    input [5:0]   portb_portx, // [7:6] unused because in Arduino they are always oscillator in
    input [5:0]   portb_ddrx,
    output [5:0]  portb_pinx,
    input [5:0]   portc_portx, // [6] usused because in Arduino it is always reset in
    input [5:0]   portc_ddrx,
    output [5:0]  portc_pinx,
    input [7:0]   portd_portx,
    input [7:0]   portd_ddrx,
    output [7:0]  portd_pinx,
    // Xcelerator Blocks controlling pins. Arduino Uno digital 0-13 and analog 0-5
    input [19:0]  xb_ddoe, // override data direction
    input [19:0]  xb_ddov, // data direction value if overridden (1=output)
    input [19:0]  xb_pvoe, // override output value
    input [19:0]  xb_pvov, // override value if overrriden
    output [19:0] xb_pinx, // data from pad to xb
    // Pin change interrupts
    input [23:0]  pcint_irq, // pcint mask
    input         pcie0, // pc int enable
    input         pcie1,
    input         pcie2,
    output [23:0] pcint_rcv, //pcint from pin to ext_int logic
    // Functions overloaded on port B
    input         spe,
    input         spimaster,
    input         scko,
    input         misoo,
    input         mosio,
    output        scki,
    output        misoi,
    output        mosii,
    output        ss_b,
    input         OC2A_enable,
    input         OC2A_pin,
    input         OC1B_enable,
    input         OC1B_pin,
    input         OC1A_enable,
    input         OC1A_pin,
    output        ICP1_pin,
    output        PIN13LED,
    // Functions overloaded on port C
    input         twen,
    output        sdain,
    input         sdaout,
    output        sclin,
    input         sclout,
    output        I2C_ENABLE,
    // Functions overloaded on port D
    input         UMSEL,
    input         xcko,
    output        xck_rcv,
    output        T1_pin,
    output        T0_pin,
    input         OC2B_enable,
    input         OC2B_pin,
    input         OC0B_enable,
    input         OC0B_pin,
    input         OC0A_enable,
    input         OC0A_pin,
    input         INT1_enable,
    output        INT1_rcv,
    input         INT0_enable,
    output        INT0_rcv,
    input         uart_tx_en,
    input         TXD,
    input         uart_rx_en,
    output        RXD_rcv
   );

/////////////////////////////////
// Signals
/////////////////////////////////
  /*AUTOREG*/
  /*AUTOWIRE*/ 
   wire [5:0] portb_puoe;
   wire [5:0] portb_puov;
   wire [5:0] portb_ddoe;
   wire [5:0] portb_ddov;
   wire [5:0] portb_pvoe;
   wire [5:0] portb_pvov;
   wire [5:0] portb_dieoe;
   wire [5:0] portb_dieov;
   wire [5:0] portb_pue;
   wire [5:0] portb_oe;
   wire [5:0] portb_dout;
   wire [5:0] portb_ie;

   wire [5:0] portc_puoe;
   wire [5:0] portc_puov;
   wire [5:0] portc_ddoe;
   wire [5:0] portc_ddov;
   wire [5:0] portc_pvoe;
   wire [5:0] portc_pvov;
   wire [5:0] portc_dieoe;
   wire [5:0] portc_dieov;
   wire [5:0] portc_pue;
   wire [5:0] portc_oe;
   wire [5:0] portc_dout;
   wire [5:0] portc_ie;

   wire [7:0] portd_puoe;
   wire [7:0] portd_puov;
   wire [7:0] portd_ddoe;
   wire [7:0] portd_ddov;
   wire [7:0] portd_pvoe;
   wire [7:0] portd_pvov;
   wire [7:0] portd_dieoe;
   wire [7:0] portd_dieov;
   wire [7:0] portd_pue;
   wire [7:0] portd_oe;
   wire [7:0] portd_dout;
   wire [7:0] portd_ie;

/////////////////////////////////
// Functions and Tasks
/////////////////////////////////

/////////////////////////////////
// Main Code
/////////////////////////////////

// Port B, table 14-4 and 14-5
   assign portb_puoe[5] = spe && ~spimaster;
   assign portb_puov[5] = portb_portx[5] && ~PUD;
   assign portb_ddoe[5] = spe && ~spimaster;
   assign portb_ddov[5] = 1'b0;
   assign portb_pvoe[5] = spe && spimaster;
   assign portb_pvov[5] = scko;
   assign portb_dieoe[5] = pcint_irq[5] && pcie0;
   assign portb_dieov[5] = 1'b1;
   assign portb_puoe[4] = spe && spimaster;
   assign portb_puov[4] = portb_portx[4] && ~PUD;
   //assign portb_ddoe[4] = spe && spimaster;
   //assign portb_ddov[4] = 1'b0;
   // Although above 2 lines match table 14-4, page 161 says
   //   "When configured as a Slave, the SPI interface will
   //    remain sleeping with MISO tri-stated as long as the
   //    SS pin is driven high." So we modify the logic accordingly.
   assign portb_ddoe[4] = spe;
   assign portb_ddov[4] = spimaster ? 1'b0 : (portb_ddrx[4] && ~ss_b);
   assign portb_pvoe[4] = spe && ~spimaster;
   assign portb_pvov[4] = misoo;
   assign portb_dieoe[4] = pcint_irq[4] && pcie0;
   assign portb_dieov[4] = 1'b1;
   assign portb_puoe[3] = spe && ~spimaster;
   assign portb_puov[3] = portb_portx[3] && ~PUD;
   assign portb_ddoe[3] = spe && ~spimaster;
   assign portb_ddov[3] = 1'b0;
   assign portb_pvoe[3] = spe && spimaster || OC2A_enable;
   assign portb_pvov[3] = (spe && mosio) || OC2A_pin;
   assign portb_dieoe[3] = pcint_irq[3] && pcie0;
   assign portb_dieov[3] = 1'b1;
   assign portb_puoe[2] = spe && ~spimaster;
   assign portb_puov[2] = portb_portx[2] && ~PUD;
   assign portb_ddoe[2] = spe && ~spimaster;
   assign portb_ddov[2] = 1'b0;
   assign portb_pvoe[2] = OC1B_enable;
   assign portb_pvov[2] = OC1B_pin;
   assign portb_dieoe[2] = pcint_irq[2] && pcie0;
   assign portb_dieov[2] = 1'b1;
   assign portb_puoe[1] = 1'b0;
   assign portb_puov[1] = 1'b0;
   assign portb_ddoe[1] = 1'b0;
   assign portb_ddov[1] = 1'b0;
   assign portb_pvoe[1] = OC1A_enable;
   assign portb_pvov[1] = OC1A_pin;
   assign portb_dieoe[1] = pcint_irq[1] && pcie0;
   assign portb_dieov[1] = 1'b1;
   assign portb_puoe[0] = 1'b0;
   assign portb_puov[0] = 1'b0;
   assign portb_ddoe[0] = 1'b0;
   assign portb_ddov[0] = 1'b0;
   assign portb_pvoe[0] = 1'b0;
   assign portb_pvov[0] = 1'b0;
   assign portb_dieoe[0] = pcint_irq[0] && pcie0;
   assign portb_dieov[0] = 1'b1;
   assign portb_pue = ( portb_puoe & portb_puov) |  // pullup enable (currently unused)
                      (~portb_puoe & ({6{~PUD}} & ~portb_ddrx[5:0] & portb_portx[5:0]));
   assign portb_oe  = ( xb_ddoe[13:8] & xb_ddov[13:8]) |
                      ( portb_ddoe & portb_ddov) |
                      (~(xb_ddoe[13:8] | portb_ddoe) & portb_ddrx[5:0]);  // muxes built with bitwise and-or
   assign portb_dout= ( xb_pvoe[13:8] & xb_pvov[13:8]) |
                      ( portb_pvoe & portb_pvov) |
                      (~(xb_pvoe[13:8] | portb_pvoe) & portb_portx[5:0]);
   assign portb_ie  = ( portb_dieoe & portb_dieov) | // input enable (negated compared to Fig 14-5)
                      (~portb_dieoe & {6{~SLEEP}});
   assign portb_pads[5] = portb_oe[5] ? portb_dout[5] : 1'bZ;
   assign portb_pads[4] = portb_oe[4] ? portb_dout[4] : 1'bZ;
   assign portb_pads[3] = portb_oe[3] ? portb_dout[3] : 1'bZ;
   assign portb_pads[2] = portb_oe[2] ? portb_dout[2] : 1'bZ;
   assign portb_pads[1] = portb_oe[1] ? portb_dout[1] : 1'bZ;
   assign portb_pads[0] = portb_oe[0] ? portb_dout[0] : 1'bZ;
   assign portb_pinx[5:0] = portb_pads & portb_ie;
   assign {scki,misoi,mosii,ss_b} =  {portb_pinx[5:2]};
   assign ICP1_pin = portb_pinx[0];
   assign PIN13LED = portb_pads[5];

   assign xb_pinx[13:8] = portb_pads[5:0]; //XXX - may want ie override and value

// Port C, table 14-7 and 14-8
   assign portc_puoe[5] = twen;
   assign portc_puov[5] = portc_portx[5] && ~PUD;
   assign portc_ddoe[5] = 1'b0; // SCL on dedicated pin, no longer on PC5
   assign portc_ddov[5] = 1'b0; // SCL on dedicated pin, no longer on PC5
   assign portc_pvoe[5] = 1'b0; // SCL on dedicated pin, no longer on PC5
   assign portc_pvov[5] = 1'b0;
   assign portc_dieoe[5] = pcint_irq[13] && pcie1 || ADCD[5];
   assign portc_dieov[5] = pcint_irq[13] && pcie1;
   assign portc_puoe[4] = twen;
   assign portc_puov[4] = portc_portx[4] && ~PUD;
   assign portc_ddoe[4] = 1'b0; // SDA on dedicated pin, no longer on PC4
   assign portc_ddov[4] = 1'b0; // SDA on dedicated pin, no longer on PC4
   assign portc_pvoe[4] = 1'b0; // SDA on dedicated pin, no longer on PC4
   assign portc_pvov[4] = 1'b0;
   assign portc_dieoe[4] = pcint_irq[12] && pcie1 || ADCD[4];
   assign portc_dieov[4] = pcint_irq[12] && pcie1;
   assign portc_puoe[3:0] = 4'h0;
   assign portc_puov[3:0] = 4'h0;
   assign portc_ddoe[3:0] = 4'h0;
   assign portc_ddov[3:0] = 4'h0;
   assign portc_pvoe[3:0] = 4'h0;
   assign portc_pvov[3:0] = 4'h0;
   assign portc_dieoe[3] = pcint_irq[11] && pcie1 || ADCD[3];
   assign portc_dieov[3] = pcint_irq[11] && pcie1;
   assign portc_dieoe[2] = pcint_irq[10] && pcie1 || ADCD[2];
   assign portc_dieov[2] = pcint_irq[10] && pcie1;
   assign portc_dieoe[1] = pcint_irq[9 ] && pcie1 || ADCD[1];
   assign portc_dieov[1] = pcint_irq[9 ] && pcie1;
   assign portc_dieoe[0] = pcint_irq[8 ] && pcie1 || ADCD[0];
   assign portc_dieov[0] = pcint_irq[8 ] && pcie1;
   assign portc_pue = ( portc_puoe & portc_puov) |  // pullup enable (currently unused)
                      (~portc_puoe & ({6{~PUD}} & ~portc_ddrx[5:0] & portc_portx[5:0]));
   assign portc_oe  = ( xb_ddoe[19:14] & xb_ddov[19:14]) |
                      ( portc_ddoe & portc_ddov) |
                      (~(xb_ddoe[19:14] | portc_ddoe) & portc_ddrx[5:0]);  // muxes built with bitwise and-or
   assign portc_dout= ( xb_pvoe[19:14] & xb_pvov[19:14]) |
                      ( portc_pvoe & portc_pvov) |
                      (~(xb_pvoe[19:14] | portc_pvoe) & portc_portx[5:0]);
   assign portc_ie  = ( portc_dieoe & portc_dieov) | // input enable (negated compared to Fig 14-5)
                      (~portc_dieoe & {6{~SLEEP}});
   assign portc_pads[5] = portc_oe[5] ? portc_dout[5] : 1'bZ;
   assign portc_pads[4] = portc_oe[4] ? portc_dout[4] : 1'bZ;
   assign portc_pads[3] = portc_oe[3] ? portc_dout[3] : 1'bZ;
   assign portc_pads[2] = portc_oe[2] ? portc_dout[2] : 1'bZ;
   assign portc_pads[1] = portc_oe[1] ? portc_dout[1] : 1'bZ;
   assign portc_pads[0] = portc_oe[0] ? portc_dout[0] : 1'bZ;
   assign portc_pinx[5:0] = portc_pads & portc_ie;

   assign xb_pinx[19:14] = portc_pads[5:0]; //XXX - may want ie override and value

   // Arduino has SDA/SCL tied to A4/A5, so I2C could be used in either
   //  (or both) locations. We've dropped I2C support on the A4/A5 pins
   //  so that A4/A5 can be used as inputs (either analog or digital)
   //  even while I2C is running. Note we can't currently use A4/A5 as
   //  digital outputs while I2C is running because we're still using
   //  the PORTC register to enable/disable the I2C pullups. 
   assign SDA = (twen && !sdaout) ? 1'b0 : 1'bz;
   assign SCL = (twen && !sclout) ? 1'b0 : 1'bz;
   assign sdain = SDA;
   assign sclin = SCL;
   // I2C pullups enabled when pullups are enabled when PUD is low, 
   //    TWEN is high, and both PORTC4 and PORTC5 are high
   // 0=no pullups, 1=enable pullups
   assign I2C_ENABLE = twen && ~PUD && &portc_portx[5:4];
  
// Port D, table 14-10 and 14-11
   assign portd_puoe[7:2] = 6'h0;
   assign portd_puov[7:2] = 6'h0;
   assign portd_ddoe[7:2] = 6'h0;
   assign portd_ddov[7:2] = 6'h0;
   assign portd_pvoe[7]  = 1'h0;
   assign portd_pvov[7]  = 1'h0;
   assign portd_dieoe[7] = pcint_irq[23] && pcie2;
   assign portd_dieov[7:0] = 8'hFF;
   assign portd_pvoe[6] = OC0A_enable;
   assign portd_pvov[6] = OC0A_pin;
   assign portd_dieoe[6] = pcint_irq[22] && pcie2;
   assign portd_pvoe[5] = OC0B_enable;
   assign portd_pvov[5] = OC0B_pin;
   assign portd_dieoe[5] = pcint_irq[21] && pcie2;
   assign portd_pvoe[4] = UMSEL;
   assign portd_pvov[4] = xcko;
   assign portd_dieoe[4] = pcint_irq[20] && pcie2;
   assign portd_pvoe[3] = OC2B_enable;
   assign portd_pvov[3] = OC2B_pin;
   assign portd_dieoe[3] = pcint_irq[19] && pcie2 || INT1_enable;
   assign portd_pvoe[2]  = 1'h0;
   assign portd_pvov[2]  = 1'h0;
   assign portd_dieoe[2] = pcint_irq[18] && pcie1 || INT0_enable; // FIXME : using pcie1 matches spec, but does it make sense?

`ifdef SNO_BOARD
   // On the Sno FPGA the RX/TX signals have dedicated pins and no 
   // longer share pins with D0/D1. The following portd*[1:0] 
   // assignments are simplified to remove the RX/TX functionality.
   assign portd_puoe[1] = 1'b0; // No longer sharing with RX/TX
   assign portd_puov[1] = 1'b0;
   assign portd_ddoe[1] = 1'b0; // No longer sharing with RX/TX
   assign portd_ddov[1] = 1'b1;
   assign portd_pvoe[1] = 1'b0; // No longer sharing with RX/TX
   assign portd_pvov[1] = 1'b0; // No longer sharing with RX/TX
   assign portd_dieoe[1] = pcint_irq[17] && pcie2;

   assign portd_puoe[0] = 1'b0; // No longer sharing with RX/TX
   assign portd_puov[0] = portd_portx[0] && ~PUD;
   assign portd_ddoe[0] = 1'b0; // No longer sharing with RX/TX
   assign portd_ddov[0] = 1'b0;
   assign portd_pvoe[0] = 1'b0;
   assign portd_pvov[0] = 1'b0;
   assign portd_dieoe[0] = pcint_irq[16] && pcie2;

`else // XLR8 Board

   assign portd_puoe[1] = uart_tx_en;
   assign portd_puov[1] = 1'b0;
   assign portd_ddoe[1] = uart_tx_en;
   assign portd_ddov[1] = 1'b1;
   assign portd_pvoe[1] = uart_tx_en;
   assign portd_pvov[1] = TXD;
   assign portd_dieoe[1] = pcint_irq[17] && pcie2;

   assign portd_puoe[0] = uart_rx_en;
   assign portd_puov[0] = portd_portx[0] && ~PUD;
   assign portd_ddoe[0] = uart_rx_en;
   assign portd_ddov[0] = 1'b0;
   assign portd_pvoe[0] = 1'b0;
   assign portd_pvov[0] = 1'b0;
   assign portd_dieoe[0] = pcint_irq[16] && pcie2;

`endif // `ifdef SNO_BOARD
  
   assign portd_pue = ( portd_puoe & portd_puov) |  // pullup enable (currently unused)
                      (~portd_puoe & ({8{~PUD}} & ~portd_ddrx[7:0] & portd_portx[7:0]));
   assign portd_oe  = ( xb_ddoe[7:0] & xb_ddov[7:0]) |
                      ( portd_ddoe & portd_ddov) |
                      (~(xb_ddoe[7:0] | portd_ddoe) & portd_ddrx[7:0]);  // muxes built with bitwise and-or
   assign portd_dout= ( xb_pvoe[7:0] & xb_pvov[7:0]) |
                      ( portd_pvoe & portd_pvov) |
                      (~(xb_pvoe[7:0] | portd_pvoe) & portd_portx[7:0]);
   assign portd_ie  = ( portd_dieoe & portd_dieov) | // input enable (negated compared to Fig 14-5)
                      (~portd_dieoe & {8{~SLEEP}});
   assign portd_pads[7] = portd_oe[7] ? portd_dout[7] : 1'bZ;
   assign portd_pads[6] = portd_oe[6] ? portd_dout[6] : 1'bZ;
   assign portd_pads[5] = portd_oe[5] ? portd_dout[5] : 1'bZ;
   assign portd_pads[4] = portd_oe[4] ? portd_dout[4] : 1'bZ;
   assign portd_pads[3] = portd_oe[3] ? portd_dout[3] : 1'bZ;
   assign portd_pads[2] = portd_oe[2] ? portd_dout[2] : 1'bZ;
   assign portd_pads[1] = portd_oe[1] ? portd_dout[1] : 1'bZ;
   assign portd_pads[0] = portd_oe[0] ? portd_dout[0] : 1'bZ;
   assign portd_pinx[7:0] = portd_pads & portd_ie;

   assign xb_pinx[7:0] = portd_pads[7:0]; //XXX - may want ie override and value

   assign T1_pin = portd_pinx[5];
   assign xck_rcv = portd_pinx[4];
   assign T0_pin = portd_pinx[4];
   assign INT1_rcv = portd_pinx[3];
   assign INT0_rcv = portd_pinx[2];

`ifdef SNO_BOARD
   // On the Sno FPGA the RX/TX signals have dedicated pins and no 
   // longer share pins with D0/D1. The following assignments are  
   // new, to implement the RX/TX
   assign TX = TXD;      // No longer sharing with portd[1]
   assign RXD_rcv  = RX; // No longer sharing with portd[0]
`else // XLR8 Board   
   assign RXD_rcv  = portd_pinx[0];
`endif // `ifdef SNO_BOARD  
   
   assign pcint_rcv[7:0] = {2'b00,portb_pinx[5:0]}; //
   assign pcint_rcv[14:8] = {1'b0,portc_pinx[5:0]};
   assign pcint_rcv[15] = 1'b0;
   assign pcint_rcv[23:16] = portd_pinx[7:0];

   wire _unused_ok = &{1'b0,
                       // Can't run-time control the pullups in MAX10
                       portb_puoe,portb_puov,portb_pue,
                       portc_puoe,portc_puov,portc_pue,
                       portd_puoe,portd_puov,portd_pue,
                       // on Arduino, portb[7:6] always used for XTAL and not GPIO
                       pcint_irq[7:6],
                       // on Arduino, portc[6] always used for RESET and not GPIO
                       pcint_irq[14],
                       // port c doesn't have a bit 7, so pcint_irq[15] and pcint_rcv[15] don't do anything
                       pcint_irq[15],
                       1'b0};


  
/////////////////////////////////
// Assertions
/////////////////////////////////

`ifdef STGI_ASSERT_ON
  ERROR_misoo_is0_if_not_spi_slave: assert property
  (@(posedge clk) disable iff (!core_rstn)
   !(spe && !spimaster) |-> !misoo);
  
`endif

/////////////////////////////////
// Cover Points
/////////////////////////////////

`ifdef SUP_COVER_ON
`endif

endmodule
