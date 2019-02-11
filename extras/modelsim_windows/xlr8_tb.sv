///////////////////////////////////////////////////////////////////
//=================================================================
//  Copyright(c) Superion Technology Group Inc., 2016
//  ALL RIGHTS RESERVED
//  $Id:  $
//=================================================================
//
// File name:  : xlr8_tb.sv
// Author      : Stephen Fraleigh
//  
//=================================================================
///////////////////////////////////////////////////////////////////

// Top-level testbench for XLR8 board.

module xlr8_tb;

   //-------------------------------------------------------
   // Local Parameters
   //-------------------------------------------------------
   `include "avr_adr_pack.vh"

   //-------------------------------------------------------
   // Reg/Wire Declarations
   //-------------------------------------------------------
   wire [13:0] Digital;
   wire [5:0]  Ana_Dig;
   wire        A_Result; // from analog compare
   wire        RXD;
   wire        TXD;
   wire        SDA;
   wire        SCL;
   reg         RESET_N;                // To xlr8_inst0 of top.v
   reg         Clock;


   //-------------------------------------------------------
   // save simulation time by not doing boot restore
   //-------------------------------------------------------
   initial force xlr8_inst0.xlr8_top_inst.uc_top_wrp_vlog_inst.boot_restore_n = 1'b1;

   //-------------------------------------------------------
   // Generate clock
   //-------------------------------------------------------
   initial begin
     Clock = 1'b0;
     forever begin
       #31.25; // 16MHz
       Clock = !Clock;
     end
   end

   //-------------------------------------------------------
   // Drive reset
   //-------------------------------------------------------
   initial begin
      RESET_N = 1'b0;
      repeat(5) @(posedge Clock);
      RESET_N = 1'b1;
   end

   //-------------------------------------------------------
   // flash initialization
   //-------------------------------------------------------
`ifdef STRINGIFY
   `undef STRINGIFY
`endif
`define STRINGIFY(str) `"str`"

`ifdef USE_AVR_C_MODEL  
  // C model gets the program directly from sketch.dat and isn't able to have different inst0 vs inst1
`else    
   defparam xlr8_inst0.xlr8_top_inst.uc_top_wrp_vlog_inst.flashload_inst.flash_inst.onchip_flash_0.INIT_FILENAME_SIM = `STRINGIFY(`FLASH0_UFM_DAT);
   initial begin
      $display("INFO %m @ %t: Loading %s into flash",$time, `STRINGIFY(`FLASH0_UFM_DAT));
   end
`endif

   //-------------------------------------------------------
   // Instantiate DUT
   //-------------------------------------------------------

   // Initial release only supports simulation of one configuration: 16MHz core, factory image.
   localparam INST0_DESIGN_CONFIG = {25'd0, // [31:14] :  reserved
                                     8'h8,  // [13:6] :  MAX10 Size,  ex: 0x8 = M08, 0x32 = M50
                                     1'b0,  //   [5]  :  ADC_SWIZZLE, 0 = XLR8,            1 = Sno
                                     1'b0,  //   [4]  :  PLL Speed,   0 = 16MHz PLL,       1 = 50Mhz PLL
                                     1'b1,  //   [3]  :  PMEM Size,   0 = 8K (Sim Kludge), 1 = 16K
                                     2'b0,  //  [2:1] :  Clock Speed, 0 = 16MHZ,           1 = 32MHz, 2 = 64MHz, 3=na
                                     1'b0  //   [0]  :  FPGA Image,  0 = CFM Application, 1 = CFM Factory
                                     };

   xlr8_board    #(// Parameters
                     .DESIGN_CONFIG      (INST0_DESIGN_CONFIG) )
   xlr8_inst0 
     (.Digital        (Digital),
      .Ana_Dig        (Ana_Dig),
      // Inouts
      .SDA            (SDA),
      .SCL            (SCL),
      .RESET_N        (RESET_N),
      .Clock          (Clock)
      );

   //-------------------------------------------------------
   // Bind the simulation support module to the GPIO registers
   //-------------------------------------------------------
   bind xlr8_gpio xlr8_sim_support xlr8_sim_support_inst(.*);
   // tell xlr8 register that we are in simulation mode.
   // Software can read this reg to detect if
   // it is running in a simulation (1) or on the hardware (0).
   initial force xlr8_inst0.xlr8_top_inst.gpio_inst.GPIOR0[0] = 1'b1;
   
endmodule // xlr8_tb
