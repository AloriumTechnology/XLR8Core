//===========================================================================
//  Copyright(c) Alorium Technology Group Inc., 2017
//  ALL RIGHTS RESERVED
//===========================================================================
//
// File name:  : xlr8_alorium_top_io_snodge.vh 
// Author      : Stebe Phillips
// Contact     : support@aloriumtech.com
// Description : 
//
//   Module I/O definitions for Sno Edge board version of the 
//   xlr8_alorium_top module. Included by `ifdef SNOEDGE_BOARD in 
//   xlr8_alorium_top
//
//===========================================================================

// The Dxx pin have been extended to additional ports A, E, G, and H
inout    D7,  D6,  D5,  D4,  D3,  D2,  D1,  D0, // Port D
inout   D13, D12, D11, D10,  D9,  D8,           // Port B
inout    A5,  A4,  A3,  A2,  A1,  A0,           // Port C, Correspond to D19:D14

// == Numbering ports by "D" number ==
inout   D22, D23, D24, D25, D26, D27,           // Port A
inout   D28, D29, D30, D31, D32, D33,           // Port E
inout   D34, D35, D36, D37, D38, D39, D40, D41, // Port G

// == Numbering ports by Port Letter ==
//inout  [5:0] C,  // Port C, see [A5:A0] above
//inout  [5:0] A,  // Port A         
//inout  [5:0] E,  // Port E
//inout  [7:0] G,  // Port G
inout  [3:0] PL, // Port PL
inout  [31:0] J, // Port J
inout  [31:0] K, // Port K

// PIN13LED does not go to edge connector
output PIN13LED,
         
// Dedicated I2C pins
inout  SCL,SDA,

// Dedicated UART pins, Connected to onboard FTDI
//inout  RX,TX,
input  RX,
output  TX,
//Clock and Reset
input  Clock, // 16MHz
input  RESET_N
                        
                        
