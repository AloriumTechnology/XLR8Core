//=================================================================
//  Copyright(c) Alorium Technology Group Inc., 2016
//  ALL RIGHTS RESERVED
//  $Id:  $
//=================================================================
//
// File name:  : xlr8_top.v
// Author      : Matt Weber
// Contact     : support@aloriumtech.com
// Description : Simulation model of components on the XLR8
//                board that we'd like to simulate, most importantly
//                the XLR8 chip, but also various pullups and
//                enables
//
//=================================================================
///////////////////////////////////////////////////////////////////

module xlr8_board  
  #(
    parameter DESIGN_CONFIG = 
    {25'd0, // [31:14] :  reserved
     8'h8,  // [13:6] :  MAX10 Size,  ex: 0x8 = M08, 0x32 = M50
     1'b0,  //   [5]  :  ADC_SWIZZLE, 0 = XLR8,            1 = Sno
     1'b0,  //   [4]  :  PLL Speed,   0 = 16MHz PLL,       1 = 50Mhz PLL
     1'b1,  //   [3]  :  PMEM Size,   0 = 8K (Sim Kludge), 1 = 16K
     2'd0,  //  [2:1] :  Clock Speed, 0 = 16MHZ,           1 = 32MHz, 2 = 64MHz, 3=na
     1'b0   //   [0]  :  FPGA Image,  0 = CFM Application, 1 = CFM Factory
     },
    parameter DMEM_SIZE = 4, // Size of DMEM in KB
    parameter APP_XB0_ENABLE = 32'hffff_ffff // for APPLICATION design, each bit [i]  enables XB[i]
//sjp    parameter APP_XB0_ENABLE = 32'h0 // for APPLICATION design, each bit [i]  enables XB[i]
    )
   (
    //Clock and Reset
    input        Clock, // 16MHz
    input        RESET_N,
    //Arduino I/Os
    inout wire   SCL,
    inout wire   SDA,
    inout [13:0] Digital, // Name to match names in original testbench
    inout [5:0]  Ana_Dig  // Name to match names in original testbench
    );

   wire          PIN13LED;
   // We can disconnect Ana_Dig from ADC inputs if necessary (don't know if it is) by driving
   //   OE low. Else leave OE as high-Z (don't drive it high).
   wire [5:0]    DIG_IO;
   wire [5:0]    DIG_IO_OE;
   wire          ANA_UP; // Choose ADC ref between AREF pin and regulated 3.3V             
   wire          I2C_ENABLE; // More importantly; disable pullups when doing analog read on A4/A5
   // JTAG connector reused as digial IO. On that connector, pin 4 is power, pins 2&10 are ground
   //   and pin 8 selects between gpio (low) and jtag (high) modes and has a pulldown.
`ifdef JTAG_PIN_SHARE 
   wire          JT9; // external pullup. JTAG function is TDI
   wire          JT7; // no JTAG function
   wire          JT6; // no JTAG function
   wire          JT5; // external pullup. JTAG function is TMS
   wire          JT3; // JTAG function TDO
   wire          JT1; // external pulldown, JTAG function is TCK
`else
   // For now, we haven't enabled JTAG pin sharing, so JTAGEN is available as a GPIO and JT7 and
   //   JT6 are the only other pins available
   wire          JTAGEN; // not being used for JTAG function
   wire          JT7; // no JTAG function
   wire          JT6; // no JTAG function
   //wire      JT67; // Use JT6 and JT7 as differential pair?
`endif // !`ifdef JTAG_PIN_SHARE
   // Interface to EEPROM or other device in SOIC-8 spot on the board
   wire          SOIC7; // WP in the case of an 24AA128SM EEPROM
   wire          SOIC6; // SCL in the case of an 24AA128SM EEPROM
   wire          SOIC5; // SDA in the case of an 24AA128SM EEPROM
   wire          SOIC3; // A2 in the case of an 24AA128SM EEPROM
   wire          SOIC2; // A1 in the case of an 24AA128SM EEPROM
   wire          SOIC1; // A0 in the case of an 24AA128SM EEPROM
   
   /* xlr8_top AUTO_TEMPLATE (.D\([0-9]*\) (Digital[\1]),
    .TX          (Digital[1]),
    .RX          (Digital[0]),
    .A\([0-9]*\) (DIG_IO[\1]),
    );*/
   
   xlr8_alorium_top #(/*AUTOINSTPARAM*/
                      // Parameters
                      .DESIGN_CONFIG            (DESIGN_CONFIG),
                      .DMEM_SIZE                (DMEM_SIZE),
                      .APP_XB0_ENABLE           (APP_XB0_ENABLE))
   xlr8_top_inst (
`ifdef JTAG_PIN_SHARE 
                  .JT9               (JT9),
                  .JT7               (JT7),
                  .JT6               (JT6),
                  .JT5               (JT5),
                  .JT3               (JT3),
                  .JT1               (JT1),
`else
                  .JTAGEN            (JTAGEN),
                  .JT7               (JT7),
                  .JT6               (JT6),
`endif
                  /*AUTOINST*/
                  // Outputs
                  .PIN13LED          (PIN13LED),
                  .ANA_UP            (ANA_UP),
                  .I2C_ENABLE        (I2C_ENABLE),
                  // Inouts
                  .SCL               (SCL),
                  .SDA               (SDA),
                  .D13               (Digital[13]),           // Templated
                  .D12               (Digital[12]),           // Templated
                  .D11               (Digital[11]),           // Templated
                  .D10               (Digital[10]),           // Templated
                  .D9                (Digital[9]),            // Templated
                  .D8                (Digital[8]),            // Templated
                  .D7                (Digital[7]),            // Templated
                  .D6                (Digital[6]),            // Templated
                  .D5                (Digital[5]),            // Templated
                  .D4                (Digital[4]),            // Templated
                  .D3                (Digital[3]),            // Templated
                  .D2                (Digital[2]),            // Templated
                  .TX                (Digital[1]),            // Templated
                  .RX                (Digital[0]),            // Templated
                  .A5                (DIG_IO[5]),             // Templated
                  .A4                (DIG_IO[4]),             // Templated
                  .A3                (DIG_IO[3]),             // Templated
                  .A2                (DIG_IO[2]),             // Templated
                  .A1                (DIG_IO[1]),             // Templated
                  .A0                (DIG_IO[0]),             // Templated
                  .DIG_IO_OE         (DIG_IO_OE[5:0]),
                  .SOIC7             (SOIC7),
                  .SOIC6             (SOIC6),
                  .SOIC5             (SOIC5),
                  .SOIC3             (SOIC3),
                  .SOIC2             (SOIC2),
                  .SOIC1             (SOIC1),
                  // Inputs
                  .Clock             (Clock),
                  .RESET_N           (RESET_N));
   
   // The digital I/Os will likely always have pullups, either
   //  on the board (current plan) or in the chip (green board
   //  prototypes).
   pullup(Digital[13]);
   pullup(Digital[12]);
   pullup(Digital[11]);
   pullup(Digital[10]);
   pullup(Digital[9]);
   pullup(Digital[8]);
   pullup(Digital[7]);
   pullup(Digital[6]);
   pullup(Digital[5]);
   pullup(Digital[4]);
   pullup(Digital[3]);
   pullup(Digital[2]);
   pullup(Digital[1]);
   pullup(Digital[0]);
   // The SDA/SCL pullups can be enabled/disabled
   // when I2C_ENABLE is high, we should get pullups,
   // when it is low, we should just set high-Z on
   // SDA/SCL
   rnmos Q19a (SDA,1'b1,I2C_ENABLE); // (r)esistive version of nmos
   rnmos Q19b (SCL,1'b1,I2C_ENABLE); // should reduce 1'b1 to pull strength
   // DIG_IO_OE are used to disconnect the digital I/O
   //  side of A5..A0 from the analog input side
   //  When DIG_IO_OE is 0 they are disconnected, when
   //   it is high-Z they are connected, when it is a
   //   1 they are also connected, but bad, or at least
   //   unintended things, could happen in the circuits
   //   because the pullups are to 5V
   pullup(DIG_IO_OE[5]);
   pullup(DIG_IO_OE[4]);
   pullup(DIG_IO_OE[3]);
   pullup(DIG_IO_OE[2]);
   pullup(DIG_IO_OE[1]);
   pullup(DIG_IO_OE[0]);
   tranif1(Ana_Dig[0],DIG_IO[0],DIG_IO_OE[0]);
   tranif1(Ana_Dig[1],DIG_IO[1],DIG_IO_OE[1]);
   tranif1(Ana_Dig[2],DIG_IO[2],DIG_IO_OE[2]);
   tranif1(Ana_Dig[3],DIG_IO[3],DIG_IO_OE[3]);
   tranif1(Ana_Dig[4],DIG_IO[4],DIG_IO_OE[4]);
   tranif1(Ana_Dig[5],DIG_IO[5],DIG_IO_OE[5]);
   
endmodule: xlr8_board
// Local Variables:
// verilog-library-flags:("-y ../../../rtl/")
// End:

