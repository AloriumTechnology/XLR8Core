///////////////////////////////////////////////////////////////////
//=================================================================
//  Copyright(c) Alorium Technology Group Inc., 2016
//  ALL RIGHTS RESERVED
//=================================================================
//
// File name:  : xlr8_clocks.v
// Author      : Matt Weber  support@aloriumtech.com
// Contact     :  info@aloriumtech.com
// Description : GPIO registers as well as version registers
//
// DEFINES
//     SIM_FAST_WATCHDOG: get a watchdog every SIM_FAST_WATCHDOG cycles for simulation
//
//=================================================================
///////////////////////////////////////////////////////////////////

module xlr8_clocks  
  #(parameter CLOCK_SELECT = 2'h0, // 0=16MHz, 1=32MHz, 2=64MHz, 3=reserved 
    parameter PRR_ADDR   = 6'h0,
    parameter PRADC_BIT  = 0,
    parameter PRUSART0_BIT  = 1,
    parameter PRSPI_BIT  = 2,
    parameter PRTIM1_BIT  = 3,
    parameter PRINTOSC_BIT  = 4, // XLR8 specific
    parameter PRTIM0_BIT  = 5,
    parameter PRTIM2_BIT  = 6,
    parameter PRTWI_BIT  = 7,
    parameter PLL_SELECT = 0  //1=50MHz PLL, 0=16MHz PLL
    )
   (// clks/resets - - - - - -
    input            Clock, // from I/O
    input            core_rstn,
    output logic     pwr_on_nrst, // set by pll lock/unlock
    // Register access for registers in first 64
    input [5:0]      adr,
    input [7:0]      dbus_in,
    output [7:0]     dbus_out,
    input            iore,
    input            iowe,
    output wire      io_out_en,
    // Register access for registers not in first 64
    input wire [7:0] ramadr,
    input wire       ramre,
    input wire       ramwe,
    input wire       dm_sel,
    // output clocks, most are placeholders for future use
    output logic     locked_adcref,
    output logic     clk_cpu, //    Selected clock (16, 32 or 64)
    output logic     clk_io, //     Same as clk_cpu
    output logic     clk_adcref, //  2MHz clock from PLL
    output logic     clkx4, //      64MHz clock from PLL
    output logic     clkx2, //      32MHz clock from PLL
    output logic     clkx1, //      16MHz clock
    output logic     clk_option2, // Default: 64MHz with 45 degrees phase shift
    output logic     clk_option4, // Default: 32MHz with 22.5 degrees phase shift
    output logic     clk_usart0, // Same as clk_cpu
    output logic     clk_spi,
    output logic     clk_tim1,
    output logic     clk_intosc,
    output logic     clk_tim0,
    output logic     clk_tim2,
    output logic     clk_twi,
    output logic     intosc_div1024,
    output logic     en16mhz,
    output logic     en1mhz,
    output logic     en128khz
    );
   
   //-------------------------------------------------------
   // Local Parameters
   //-------------------------------------------------------
   // Registers in I/O address range x0-x3F (memory addresses -x20-0x5F)
   //  use the adr/iore/iowe inputs. Registers in the extended address
   //  range (memory address 0x60 and above) use ramadr/ramre/ramwe
   localparam  PRR_DM_LOC    = (PRR_ADDR >= 16'h60) ? 1 : 0;
   localparam CLKCNT_WIDTH = CLOCK_SELECT+4; // counter needed to get from clock speed down to 1MHz
   
   //-------------------------------------------------------
   // Reg/Wire Declarations
   //-------------------------------------------------------
   /*AUTOWIRE*/
   /*AUTOREG*/
   logic             prr_sel;
   logic             prr_we ;
   logic             prr_re ;
   logic [7:0]       prr_rdata;
   logic             PRADC;
   logic             PRUSART0;
   logic             PRSPI;
   logic             PRTIM1;
   logic             PRINTOSC;
   logic             PRTIM0;
   logic             PRTIM2;
   logic             PRTWI;
   
   logic             clkx2p,clkx4p;
   logic [CLKCNT_WIDTH-1:0] clkcnt;
   logic [6:0]              clkcnt125;
   logic [9:0]              clkcnt_intosc;
   logic                    reset_n_r;
   logic                    locked_sync;
   logic                    locked_prev;
   
   //-------------------------------------------------------
   // Functions and Tasks
   //-------------------------------------------------------
   
   //-------------------------------------------------------
   // Main Code
   //-------------------------------------------------------
   
   assign prr_sel = PRR_DM_LOC ?  (dm_sel && ramadr == PRR_ADDR ) : (adr[5:0] == PRR_ADDR ); 
   assign prr_we = prr_sel && (PRR_DM_LOC ?  ramwe : iowe); 
   assign prr_re = prr_sel && (PRR_DM_LOC ?  ramre : iore);
   assign dbus_out =  ({8{prr_sel}} & prr_rdata); 
   assign io_out_en = prr_re; 
   
   // Control Registers
   always @(posedge clk_cpu or negedge core_rstn) begin
      if (!core_rstn)  begin
         /*AUTORESET*/
         // Beginning of autoreset for uninitialized flops
         PRADC <= 1'h0;
         PRINTOSC <= 1'h0;
         PRSPI <= 1'h0;
         PRTIM0 <= 1'h0;
         PRTIM1 <= 1'h0;
         PRTIM2 <= 1'h0;
         PRTWI <= 1'h0;
         PRUSART0 <= 1'h0;
         // End of automatics
      end else if (prr_we) begin
         // tie off most of these until we're ready to use them
         PRADC    <= dbus_in[PRADC_BIT] && 1'b0;
         PRUSART0 <= dbus_in[PRUSART0_BIT] && 1'b0;
         PRSPI    <= dbus_in[PRSPI_BIT] && 1'b0;
         PRTIM1   <= dbus_in[PRTIM1_BIT] && 1'b0;
         PRINTOSC <= dbus_in[PRINTOSC_BIT]; // XLR8 specific
         PRTIM0   <= dbus_in[PRTIM0_BIT] && 1'b0;
         PRTIM2   <= dbus_in[PRTIM2_BIT] && 1'b0;
         PRTWI    <= dbus_in[PRTWI_BIT] && 1'b0;
      end
   end // always @ (posedge clk_cpu or negedge core_rstn)
   
   assign prr_rdata = ({7'h0,PRADC}     << PRADC_BIT) |
                      ({7'h0,PRUSART0}  << PRUSART0_BIT) |
                      ({7'h0,PRSPI}     << PRSPI_BIT) |
                      ({7'h0,PRTIM1}    << PRTIM1_BIT) |
                      ({7'h0,PRINTOSC}  << PRINTOSC_BIT) |
                      ({7'h0,PRTIM0}    << PRTIM0_BIT) |
                      ({7'h0,PRTIM2}    << PRTIM2_BIT) |
                      ({7'h0,PRTWI}     << PRTWI_BIT);
   
   // ADC needs to get its clock from PLL
   //  Have PLL do a divide by 8 to give the ADC 2MHz clock
`ifdef PLL_SIM_MODEL
   // In simulation, skip pll model and just do a div by 16
   reg                  locked_reg;
   wire                 Clock_dly;
   initial locked_reg = 1'b0;
   always @(posedge Clock) locked_reg <= 1'b1;
   assign locked_adcref = locked_reg;
   reg [3:0]            clockdiv;
   initial clockdiv = 4'h0;
   always @(posedge Clock) clockdiv <= clockdiv + 4'h1;
   assign clk_adcref = clockdiv[3];
   assign #15.625ns Clock_dly = Clock;
   assign clkx2 = Clock ^ Clock_dly;
   assign #7.812ns clkx2p = clkx2; // might not be same phase pll gives but should be okay in simulation
   assign clkx4 = clkx2 ^ clkx2p;
   assign #3.906ns clkx4p = clkx4; // might not be same phase pll gives but should be okay in simulation
`else
   generate if (PLL_SELECT == 1)
     //choose which pll to use 
     pll50 pll_inst (
                     .inclk0 ( Clock ),
                     .c0 ( clk_adcref ),
                     .c1 ( clkx1 ), //  16MHz
                     .c2 ( clkx4 ), // 64Mhz
                     .c3 ( clkx2  ), // 32MHz
                     .locked ( locked_adcref )
                     );
   else 
     pll16 pll_inst (
                     .inclk0 ( Clock ),
                     .c0 ( clk_adcref ),
                     .c1 ( clkx4  ), // input x4 = 64MHz
                     .c2 ( clkx4p ), // plus phase shift which perhaps would be used by memories
                     .c3 ( clkx2  ), // x2 = 32MHz
                     .c4 ( clkx2p ), // x2 plus phase shift
                     .locked ( locked_adcref )
                     );
   endgenerate
`endif // !`ifdef PLL_SIM_MODEL
   // create enables for 16MHz, 1MHz, 128kHz timers
   generate 
      if (CLOCK_SELECT == 2) begin: CS2
         assign clk_cpu = clkx4; // 64MHz
         assign clkx1 = Clock;
     end 
      else if (CLOCK_SELECT == 1) begin: CS1
         assign clk_cpu = clkx2;
         assign clkx1 = Clock;
     end 
      else if (PLL_SELECT == 1) begin
        assign clk_cpu = clkx1;
     end 
      else begin: CS_whatever
         assign clk_cpu = Clock; // skip the PLL
      end
   endgenerate
   always @(posedge clk_cpu) begin
      if (clkcnt != {CLKCNT_WIDTH{1'b0}}) begin
         clkcnt  <= clkcnt - 1;
         en1mhz  <= 1'b0;
      end else begin // in simulation, initial X on clkcnt should fall through to here
         clkcnt  <= {CLKCNT_WIDTH{1'b1}};
          en1mhz  <= 1'b1;
       end
   end // always @ (posedge clk_cpu)
   generate if (CLKCNT_WIDTH < 5)
     begin: CCW5
        assign en16mhz = 1'b1;
     end else begin: not_CCW5
        always @(posedge clk_cpu) en16mhz <= ~|clkcnt[CLKCNT_WIDTH-5:0];
     end
   endgenerate
   
`ifdef SIM_FAST_WATCHDOG
   localparam [6:0] CLKCNT125_MAX = `SIM_FAST_WATCHDOG - 1; // one every SIM_FAST_WATCHDOG cycles for simulation
`else
   localparam [6:0] CLKCNT125_MAX = 7'd124;
`endif
   
   
   always @(posedge clk_cpu or negedge core_rstn) begin
      if (!core_rstn) begin
         clkcnt125   <=  7'd0;
         en128khz    <= 1'b0;
      end else if (en16mhz) begin
         clkcnt125   <= ~|clkcnt125 ? CLKCNT125_MAX : (clkcnt125 - 7'd1); // 
         en128khz    <= ~|clkcnt125;  // signal every 128kHz cycle   (1/125 of 16MHz)
      end else begin
         en128khz    <= 1'b0;
      end
   end // always @ (posedge clk or negedge core_rstn)
   
   always_comb clk_io = clk_cpu;
   always_comb clk_usart0 = clk_cpu;
   always_comb clk_spi = clk_cpu;
   always_comb clk_tim1 = clk_cpu;
   always_comb clk_tim0 = clk_cpu;
   always_comb clk_tim2 = clk_cpu;
   always_comb clk_twi = clk_cpu;

   always_comb clk_option2 = clkx4p;
   always_comb clk_option4 = clkx2p;
   
   //      clkgate_altclkctrl_0 altclkctrl_0 (
   //              .inclk  (inclk),  //  altclkctrl_input.inclk
   //              .ena    (ena),    //                  .ena
   //              .outclk (outclk)  // altclkctrl_output.outclk
   //      );
   
   // Max10 has an internal oscillator that can give us up to
   //  116MHz. For now just divide it down and sent it to a
   //  pin so we can measure it.
   int_osc int_osc_inst (.clkout(clk_intosc),
                         .oscena(!PRINTOSC)); // clock domain crossing here, assume it's okay
   
   always @(posedge clk_intosc) begin
      if (clkcnt_intosc <= 10'h3FF) begin
         clkcnt_intosc  <= clkcnt_intosc + 10'h1;
      end else begin // simulation X will fall through
         clkcnt_intosc  <= 10'h0;
      end
   end // always @ (posedge clk_cpu)
   always_comb begin
      if (clkcnt_intosc[9]) intosc_div1024 = 1'b1;
      else intosc_div1024 = 1'b0; // X falls through to here
   end
   
   // Filter the pll lock signal. In high noise environments it
   //  can glitch low while the clock coming out of the pll is still
   //  good enough to use. On a logic analyzer the glitch low appears
   //  to be around 2.7us wide. 63 cycles at 16MHz would be just under 4us.
   // Altera documentation says "The lock signal is an asynchronous
   //  output of the PLL", so we first synchronize it
   synch lock_sync (.dout     (locked_sync),
                    .clk      (Clock),
                    .din      (locked_adcref));
   // Altera Max 10 documentation says "Registers in the device
   //  core always power up to a low (0) logic level". We're relying
   //  on that for these two
   reg [CLKCNT_WIDTH+1:0] lock_count = {(CLKCNT_WIDTH+2){1'b0}};
   reg                    pll_lock_filtered = 1'b0;
   always @(posedge Clock) begin
      locked_prev <= locked_sync;
      if (locked_prev == locked_sync) begin
         if (&lock_count) begin // after 63 cycles of same level, use it
            pll_lock_filtered <= locked_sync;
         end else begin
            lock_count <= lock_count + 1;
         end
      end else begin
         lock_count <= 0;
      end
   end
   
   // Power on Reset generator
   //always @(posedge Clock or negedge locked_adcref) begin
   always @(posedge Clock or negedge pll_lock_filtered) begin
      if (!pll_lock_filtered) begin
         reset_n_r <= 1'b0;
         pwr_on_nrst <= 1'b0;
      end else begin
         reset_n_r <= 1'b1;
         pwr_on_nrst <= reset_n_r;
      end
   end
   
   
   
`ifdef SIM_FAST_WATCHDOG
   initial begin
      $display("INFO %m @ %t: Running SIM_FAST_WATCHDOG mode.  Incrementing watchdog count every %d cycles",$time, `SIM_FAST_WATCHDOG);
   end
`endif //  `ifdef FAST_WATCHDOG
   
   //                         
`ifdef STGI_ASSERTS_ON
   //===================== ASSERTIONS ======================
   //
   //-------------------------------------------------------
   
   
   //=======================================================
`endif // STGI_ASSERTS_ON
   
   
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
// verilog-library-flags:("-y ../ip/int_osc/int_osc/synthesis")
// End:
