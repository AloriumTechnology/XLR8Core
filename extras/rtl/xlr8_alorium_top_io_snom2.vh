//===========================================================================
//  Copyright(c) Alorium Technology Group Inc., 2017
//  ALL RIGHTS RESERVED
//===========================================================================
//
// File name:  : xlr8_alorium_top_io_snom2.vh 
// Author      : Stebe Phillips
// Contact     : support@aloriumtech.com
// Description : 
//
//   Module I/O definitions for Sno M2 board version of the 
//   xlr8_alorium_top module. Included by `ifdef SNOM2_BOARD in 
//   xlr8_alorium_top
//
//===========================================================================

//module xlr8_alorium_top // COMMENT THIS LINE OUT! Only uncomment for auto-indenting
//  (                     // COMMENT THIS LINE OUT! Only uncomment for auto-indenting
    // The Dxx pin have been extended to additional ports A, E, G, and H
    inout  D7, D6, D5, D4, D3, D2, D1, D0, // Port D
    inout  D13,D12,D11,D10,D9, D8, // Port B
    inout  D22,D23,D24,D25,D26,D27, // Port A
    inout  D28,D29,D30,D31,D32,D33, // Port E
    inout  D34,D35,D36,D37,D38,D39,D40,D41, // Port G
    inout  D42,D43,D44,D45,D46,D47,D48,D49, // Port H
    // A5..A0 are are also connected to ADC inputs
    inout  A5,A4,A3,A2,A1,A0, // Some stuff on board between here and the actual header pins
    output PIN13LED,
    // Dedicated I2C pins
    inout  SCL,SDA,
    // Dedicated UART pins
    inout  RX,TX,
    //Clock and Reset
    input  Clock, // 16MHz
    input  RESET_N
//  );    // COMMENT THIS LINE OUT! Only uncomment for auto-indenting
//endmodule // COMMENT THIS LINE OUT! Only uncomment for auto-indenting
                        
                        
