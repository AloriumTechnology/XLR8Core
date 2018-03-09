///////////////////////////////////////////////////////////////////
//=================================================================
//  Copyright(c) Superion Technology Group Inc., 2015
//  ALL RIGHTS RESERVED
//  $Id:  $
//=================================================================
//
// File name:  : synch.v
// Author      : Matt Weber
// Description : synchronizer used in ATmega328p is latch followed
//                by flop
//
//=================================================================
///////////////////////////////////////////////////////////////////

module synch (input clk,
              input  din,
              output reg dout);

  //reg                din_latch;
  //always_latch begin
  //   if (clk) din_latch <= din;
  //end
  //always @(posedge clk) dout <= din_latch;

  // Max10 device doesn't have latches, so use flop instead
  reg                din_flop;
  always @(negedge clk) din_flop <= din;
  always @(posedge clk) dout <= din_flop;
endmodule // synch

