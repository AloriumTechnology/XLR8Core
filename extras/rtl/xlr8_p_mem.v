//************************************************************************************************
// PM RAM for AVR Core
// Version 0.2
// Designed by Ruslan Lepetenok
// Modified 18.06.2007
//************************************************************************************************

`timescale 1 ns / 1 ns

module xlr8_p_mem
  (input logic        clk,
   input logic         rst_flash_n,

   input logic [15:0]  pm_core_rd_addr,
   output logic [15:0] pm_core_rd_data,
   input logic         pm_ce,
   input logic         pm_wr,
   input logic [15:0]  pm_wr_data,
   input logic [15:0]  pm_addr,
   output logic [15:0] pm_rd_data

   );

  // pm_size: logical pmem memory size
  // pm_real_size: how big is the real memory.
  // normallY: pm_size == pm_real_size
  // uno: pm_size = 16, pm_real_size=16.  Normal memory mode: 16Kx16
  // debug:     pm_size = 16, pm_real_size=8.  Memory: 8Kx16.
  //   *intended for SignalTap to free up 16 M9K to use for signal storage.
  //   *0..4K-1: Normal memory map.
  //   *4K..8K-1: is aliased in hardware.  (4K+n) same as (8K+n) same as (12K+n)
  //    Sane usage:
  //        **4K..(8K-257): Application memory.  Application must be less than 12K-256 bytes.  There is no protection for this!
  //        **8K-256..8K-1: boot code (optiboot).
  // half-uno: 8K instruction memory
  parameter pm_size = 16;          // PM size 1..64 KWords
  parameter PM_REAL_SIZE = pm_size;
  localparam PM_DEPTH = PM_REAL_SIZE * 1024;
  localparam PM_ADDR_W = $clog2(PM_DEPTH);
  localparam  C_ADR_WIDTH = (pm_size < 2)    ? 0 + 10 :
                            (pm_size < 4)    ? 1 + 10 :
                            (pm_size < 8)    ? 2 + 10 :
                            (pm_size < 16)   ? 3 + 10 :
                            (pm_size < 32)   ? 4 + 10 :
                            (pm_size < 64)   ? 5 + 10 :
                            (pm_size < 128)  ? 6 + 10 :
                            (pm_size == 128) ? 7 + 10 : 0;
  
  
  wire                 _unused_ok = &{1'b0,
                                      pm_addr[15:C_ADR_WIDTH],
                                      1'b0};


`ifdef STRINGIFY
 `undef STRINGIFY
`endif

`define STRINGIFY(x) `"x`"

   // just model the ram so we don't have to worry about technology specific models
   localparam memdepth = 1 << C_ADR_WIDTH;


  //condition two read addresses for debug mode
  logic [15:0]         core_rd_addr;
  logic [15:0]         rw_addr;
  always_comb begin
    core_rd_addr = pm_core_rd_addr; // defaults
    rw_addr = pm_addr;            // defaults

    core_rd_addr[PM_ADDR_W-1] = pm_core_rd_addr[PM_ADDR_W-1] | pm_core_rd_addr[C_ADR_WIDTH-1];
    rw_addr[PM_ADDR_W-1] = pm_addr[PM_ADDR_W-1] | pm_addr[C_ADR_WIDTH-1];
  end // always_comb
  
    
`ifdef P_MEM_SIM_MODEL
  reg [15:0]            mem_data[PM_DEPTH-1:0];
  logic [15:0]          mem_data0;
  logic [15:0]          mem_data1;
  always_comb begin
    mem_data0 = mem_data[0];
    mem_data1 = mem_data[1];
  end

  always @(posedge clk) begin
    pm_core_rd_data <= mem_data[core_rd_addr[PM_ADDR_W-1:0]];
    if (pm_ce) begin
      if (pm_wr) begin
        mem_data[rw_addr[PM_ADDR_W-1:0]] <= pm_wr_data;
      end
      else begin
        pm_rd_data <= mem_data[rw_addr[PM_ADDR_W-1:0]];
      end
    end // if (pm_ce)
  end // always @ (posedge clk)

`else // !`ifdef P_MEM_SIM_MODEL
  generate
    if (PM_REAL_SIZE == 16) begin: ram16k
      ram2p16384x16   ram2p16384x16_inst 
        (
         .address_a ( pm_addr[C_ADR_WIDTH-1:0] ),
         .address_b ( pm_core_rd_addr[C_ADR_WIDTH-1:0] ),
         .clock ( clk ),
         .data_a ( pm_wr_data ),
         .data_b ( '0),             // unuaws
         .wren_a ( pm_wr ),
         .wren_b ( 1'b0 ),       // unused
         .q_a ( pm_rd_data ),
         .q_b ( pm_core_rd_data )
         );
    end: ram16k
    else begin: ram8k
      ram2p8192x16   ram2p8192x16_inst 
        (
         .address_a ( rw_addr[PM_ADDR_W-1:0] ),
         .address_b ( core_rd_addr[PM_ADDR_W-1:0] ),
         .clock ( clk ),
         .data_a ( pm_wr_data ),
         .data_b ( '0),             // unuaws
         .wren_a ( pm_wr ),
         .wren_b ( 1'b0 ),       // unused
         .q_a ( pm_rd_data ),
         .q_b ( pm_core_rd_data )
         );  
    end: ram8k
  endgenerate
`endif // !`ifdef P_MEM_SIM_MODEL
  
 `ifdef P_MEM_SIM_MODEL
   initial begin
 `ifdef P_MEM_SIM_MEMINIT
     $display("INFO %m @ %5t: Using %s to load SRAM",$time,`STRINGIFY(`P_MEM_SIM_MEMINIT));
     $readmemh(`STRINGIFY(`P_MEM_SIM_MEMINIT), mem_data);
 `else
     $display("INFO %m @ %5t: Leaving pmem unitialized.  Data will be loaded from flash (UFM) or serial load",$time);
     // FIXME: maybe put all 0s for NOP?
   `endif
   end // initial begin
  `endif //  `ifdef P_MEM_SIM_MODEL



`ifdef STGI_ASSERT_ON
  //===================== ASSERTIONS ======================
  //
  //-------------------------------------------------------

   ovl_range #(.msg ("ERROR: Program Memory address out of range"),
               .width(16),
               .min(0),
               .max(pm_size * 1024 - 1), // haven't check this value yet
               .coverage_level (4'b1111),
               .reset_polarity (1'b1))
     wgm1_value (.clock      (clk),
                 .reset      (!rst_flash_n),
                 .enable     (pm_ce),
                 .test_expr  (pm_addr),
                 .fire       ());
  ovl_range #(.msg ("ERROR: Program Memory address out of range"),
               .width(16),
               .min(0),
               .max(pm_size * 1024 - 1 + 1), // haven't check this value yet
               .coverage_level (4'b1111),
               .reset_polarity (1'b1))
     wgm2_instr_fetch (.clock      (clk),
                 .reset      (!rst_flash_n),
                 .enable     (1'b1),
                 .test_expr  (pm_core_rd_addr),
                 .fire       ());
  //=======================================================
`endif // STGI_ASSERT_ON


endmodule



