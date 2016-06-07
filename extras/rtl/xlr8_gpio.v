///////////////////////////////////////////////////////////////////
//=================================================================
//  Copyright(c) Superion Technology Group Inc., 2016
//  ALL RIGHTS RESERVED
//  $Id:  $
//=================================================================
//
// File name:  : xlr8_gpio.v
// Author      : Matt Weber
// Description : AVR GPIO registers as well as four read-only registers
//                that can be used to pass version or other synthesis
//                time configuration information to the software.
//                The read-only registers are optional. They only get
//                implemented if the address parameter passed in is
//                non-zero.
//
//=================================================================
///////////////////////////////////////////////////////////////////

module xlr8_gpio
  #(parameter DESIGN_CONFIG = {28'd0, // 31:4: reserved
                               1'b1, //  [3]  :   1 = 16K Instruction, 0 = 8K instruction
                               2'd0, // [2:1]:   clock speed[1:0]
                               1'b1}, // [0] = CFM FACTORY (1), CFM APPLICATION (0)
    parameter APP_XB0_ENABLE = 32'hffff_ffff, // for APPLICATION design, each bit [i]  enables XB[i]
    parameter CLKSPD_ADDR = 6'h29,
    parameter GPIOR0_ADDR     = 6'h0,
    parameter GPIOR1_ADDR     = 6'h0,
    parameter GPIOR2_ADDR     = 6'h0,
    parameter READREG0_ADDR   = 6'h0,
    parameter READREG1_ADDR   = 6'h0,
    parameter READREG2_ADDR   = 6'h0,
    parameter READREG3_ADDR   = 6'h0,
    parameter READREG0_VAL    = 8'h0,
    parameter READREG1_VAL    = 8'h0,
    parameter READREG2_VAL    = 8'h0,
    parameter READREG3_VAL    = 8'h0)
  (// clks/resets - - - - - -
   input              clk,
   input              rstn,
   input              clken, // used to power off the function
  // Register access for registers in first 64
   input [5:0]        adr,
   input [7:0]        dbus_in,
   output logic [7:0] dbus_out,
   input              iore,
   input              iowe,
   output logic       io_out_en,
   // Register access for registers not in first 64
   input wire [7:0]   ramadr,
   input wire         ramre,
   input wire         ramwe,
   input wire         dm_sel,
   // Use clkspd register to control sending internal osc to pin
   output logic     intosc_div1024_en
);

   //-------------------------------------------------------
   // Local Parameters
   //-------------------------------------------------------
   // Registers in I/O address range x0-x3F (memory addresses -x20-0x5F)
   //  use the adr/iore/iowe inputs. Registers in the extended address
   //  range (memory address 0x60 and above) use ramadr/ramre/ramwe
   localparam  GPIOR0_DM_LOC      = (GPIOR0_ADDR >= 16'h60) ? 1 : 0;
   localparam  GPIOR1_DM_LOC      = (GPIOR1_ADDR >= 16'h60) ? 1 : 0;
   localparam  GPIOR2_DM_LOC      = (GPIOR2_ADDR >= 16'h60)  ? 1 : 0;
   localparam  READREG0_DM_LOC    = (READREG0_ADDR >= 16'h60) ? 1 : 0;
   localparam  READREG1_DM_LOC    = (READREG1_ADDR >= 16'h60) ? 1 : 0;
   localparam  READREG2_DM_LOC    = (READREG2_ADDR >= 16'h60)  ? 1 : 0;
   localparam  READREG3_DM_LOC    = (READREG3_ADDR >= 16'h60)  ? 1 : 0;
   localparam  CLKSPD_DM_LOC  = (CLKSPD_ADDR >= 16'h60)  ? 1 : 0;

   //-------------------------------------------------------
   // Reg/Wire Declarations
   //-------------------------------------------------------
   /*AUTOWIRE*/
   /*AUTOREG*/
   wire gpior0_sel;
   wire gpior1_sel;
   wire gpior2_sel;
   wire readreg0_sel;
   wire readreg1_sel;
   wire readreg2_sel;
   wire readreg3_sel;
   wire gpior0_we ;
   wire gpior1_we ;
   wire gpior2_we ;
   wire gpior0_re ;
   wire gpior1_re ;
   wire gpior2_re ;
   wire readreg0_re ;
   wire readreg1_re ;
   wire readreg2_re ;
   wire readreg3_re ;
   reg [7:0]   GPIOR0;
   reg [7:0]   GPIOR1;
   reg [7:0]   GPIOR2;


  //-------------------------------------------------------
  // Functions and Tasks
  //-------------------------------------------------------

  //-------------------------------------------------------
  // Main Code
  //-------------------------------------------------------

   assign gpior0_sel = GPIOR0_DM_LOC ?  (dm_sel && ramadr == GPIOR0_ADDR ) : (adr[5:0] == GPIOR0_ADDR );
   assign gpior1_sel = GPIOR1_DM_LOC ?  (dm_sel && ramadr == GPIOR1_ADDR ) : (adr[5:0] == GPIOR1_ADDR );
   assign gpior2_sel  = GPIOR2_DM_LOC  ?  (dm_sel && ramadr == GPIOR2_ADDR )  : (adr[5:0] == GPIOR2_ADDR );
   assign readreg0_sel = (READREG0_ADDR != 6'h0) && (READREG0_DM_LOC ?  (dm_sel && ramadr == READREG0_ADDR ) : (adr[5:0] == READREG0_ADDR ));
   assign readreg1_sel = (READREG1_ADDR != 6'h0) && (READREG1_DM_LOC ?  (dm_sel && ramadr == READREG1_ADDR ) : (adr[5:0] == READREG1_ADDR ));
   assign readreg2_sel = (READREG2_ADDR != 6'h0) && (READREG2_DM_LOC  ?  (dm_sel && ramadr == READREG2_ADDR )  : (adr[5:0] == READREG2_ADDR ));
   assign readreg3_sel = (READREG3_ADDR != 6'h0) && (READREG3_DM_LOC  ?  (dm_sel && ramadr == READREG3_ADDR )  : (adr[5:0] == READREG3_ADDR ));

   assign gpior0_we = gpior0_sel && (GPIOR0_DM_LOC ?  ramwe : iowe);
   assign gpior1_we = gpior1_sel && (GPIOR1_DM_LOC ?  ramwe : iowe);
   assign gpior2_we = gpior2_sel && (GPIOR2_DM_LOC ?  ramwe : iowe);
   assign gpior0_re = gpior0_sel && (GPIOR0_DM_LOC ?  ramre : iore);
   assign gpior1_re = gpior1_sel && (GPIOR1_DM_LOC ?  ramre : iore);
   assign gpior2_re = gpior2_sel && (GPIOR2_DM_LOC ?  ramre : iore);
   assign readreg0_re  = readreg0_sel && (READREG0_DM_LOC ?  ramre : iore);
   assign readreg1_re  = readreg1_sel && (READREG1_DM_LOC ?  ramre : iore);
   assign readreg2_re  = readreg2_sel  && (READREG2_DM_LOC  ?  ramre : iore);
   assign readreg3_re  = readreg3_sel  && (READREG3_DM_LOC  ?  ramre : iore);

  logic        clkspd_sel;
  logic        clkspd_we;
  logic        clkspd_re;
  always_comb begin
    clkspd_sel  = CLKSPD_DM_LOC  ?  (dm_sel && ramadr == CLKSPD_ADDR )  : (adr[5:0] == CLKSPD_ADDR );
    clkspd_we = clkspd_sel && (CLKSPD_DM_LOC ?  ramwe : iowe);
    clkspd_re = clkspd_sel && (CLKSPD_DM_LOC ?  ramre : iore);
  end
   always @(posedge clk or negedge rstn) begin
      if (!rstn)  intosc_div1024_en <= 1'h0;
      else if (clken && clkspd_we) intosc_div1024_en <= dbus_in[0];
   end

   always @(posedge clk or negedge rstn) begin
      if (!rstn)  GPIOR0 <= 8'h0;
      else if (clken && gpior0_we) GPIOR0 <= dbus_in;
   end
   always @(posedge clk or negedge rstn) begin
      if (!rstn)  GPIOR1 <= 8'h0;
      else if (clken && gpior1_we) GPIOR1 <= dbus_in;
   end
   always @(posedge clk or negedge rstn) begin
      if (!rstn)  GPIOR2 <= 8'h0;
      else if (clken && gpior2_we) GPIOR2 <= dbus_in;
   end

  always_comb begin: calc_read
    logic [7:0] clkspd;

    case (DESIGN_CONFIG[2:1])
      2'b00: clkspd = 8'h10;    // fosc = 16MHz
      2'b01: clkspd = 8'h22;    // fosc = 32MHz
      2'b10: clkspd = 8'h44;
      default: clkspd = 8'h10;
    endcase // case (DESIGN_CONFIG[2:1])
  
    dbus_out =  ({8{gpior0_sel}} & GPIOR0) |
                ({8{gpior1_sel}} & GPIOR1) |
                ({8{gpior2_sel}} & GPIOR2) |
                ({8{readreg0_sel}} & READREG0_VAL) |
                ({8{readreg1_sel}} & READREG1_VAL) |
                ({8{readreg2_sel}} & READREG2_VAL) |
                ({8{readreg3_sel}} & READREG3_VAL) |
                ({8{clkspd_sel}} & clkspd)
                  ;
    io_out_en = gpior0_re ||
                gpior1_re ||
                gpior2_re ||
                readreg0_re ||
                readreg1_re ||
                readreg2_re ||
                readreg3_re ||
                clkspd_re;
    
  end: calc_read
  
 


`ifdef STGI_ASSERT_ON
  //===================== ASSERTIONS ======================
  //
  //-------------------------------------------------------


  //=======================================================
`endif // STGI_ASSERT_ON


`ifdef STGI_COVER_ON
  //====================== COVERAGE =======================
  // COVERAGE PROPERTIES:
  //-------------------------------------------------------
  //  // COVER: check for something
  //  <covername>: cover property
  //    (@(posedge clk) ~rst throughout
  //      (<expression>));
  //=======================================================
`endif // STGI_COVER_ON

endmodule
// Local Variables:
// verilog-auto-inst-param-value:t
// End:
