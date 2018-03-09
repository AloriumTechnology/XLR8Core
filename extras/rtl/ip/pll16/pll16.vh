//===========================================================================
//  Copyright(c) Alorium Technology Group Inc., 2018
//  ALL RIGHTS RESERVED
//===========================================================================
//
// File name:  : pll16.vh
// Author      : Steve Phillips
// Contact     : support@aloriumtech.com
// Description : 
// 
//===========================================================================

// avr_adr_pack

`ifdef PLL16_INCLUDE_FILE
// If PLL16_INCLUDE_FILE is already define, then don't read the rest of this
// file because we've already read one elsewhere
`else
// OK, we haven't read a file like this already, since PLL16_INCLUDE_FILE 
// isn't defined, so lets define it now to prevent any other one from being 
// read
`define PLL16_INCLUDE_FILE
// And now red the rest of the file
//---------------------------------------------------------------------------
localparam XLR8_PLL_CLK2_DIVIDE_BY = 1;
localparam XLR8_PLL_CLK2_DUTY_CYCLE = 50;
localparam XLR8_PLL_CLK2_MULTIPLY_BY = 4;
localparam XLR8_PLL_CLK2_PHASE_SHIFT = "1953";

localparam XLR8_PLL_CLK4_DIVIDE_BY = 1;
localparam XLR8_PLL_CLK4_DUTY_CYCLE = 50;
localparam XLR8_PLL_CLK4_MULTIPLY_BY = 2;
localparam XLR8_PLL_CLK4_PHASE_SHIFT = "1953";
`endif // !`ifdef PLL16_INCLUDE_FILE
