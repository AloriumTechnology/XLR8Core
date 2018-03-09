//////////////////////////////////////////////////////////////////
//=================================================================
//  Copyright(c) Superion Technology Group Inc., 2017
//  ALL RIGHTS RESERVED
//=================================================================
//
// File name:  : xlr8_pcint.v
// Author      : Steve Phillips
// Description : XLR8 Interrrupt Handler
//
// This interrupt handler is intended to interface to the xlr8_irq
// block which in turn interfaces to the interrupt logic in the AVR
// core. Unlike the xlr8_irq module, the XIFR in thise block sets gits
// based on pin changes and only clears bits on software writes to
// the XIFR.
//
//////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ns


module xlr8_pcint
#(
  parameter XICR_Address = 0,
  parameter XIFR_Address = 0,
  parameter XMSK_Address = 0,
  parameter WIDTH        = 8
  )
   
   (// Clock and Reset
    input             rstn,
    input             clk,
    // I/O i/f
    input [5:0]       adr,
    input             iowe,
    input             iore,
    input [7:0]       dbus_in,
    output [7:0]      dbus_out,
    output            out_en,
    // DM i/f
    input [7:0]       ramadr,
    input             ramre,
    input             ramwe,
    input             dm_sel,
    
    // Interrupts
    input [WIDTH-1:0] x_int_in, // Interrupts in
    
    // Interrupt (CPU i/f)
    output            x_irq, //    IRQ to AVR core
    input [WIDTH-1:0] x_irq_ack // IRQ Ack from AVR core
    );
   
   
   //-------------------------------------------------------
   // Registers in I/O address range x0-x3F (memory addresses -x20-0x5F)
   //  use the adr/iore/iowe inputs. Registers in the extended address
   //  range (memory address 0x60 and above) use ramadr/ramre/ramwe
   localparam  XICR_DM_LOC   = (XICR_Address >= 8'h60) ? 1 : 0;
   localparam  XIFR_DM_LOC   = (XIFR_Address >= 8'h60) ? 1 : 0;
   localparam  XMSK_DM_LOC   = (XMSK_Address >= 8'h60) ? 1 : 0;
   
   logic               sel_xicr;
   logic               sel_xmsk;
   logic               sel_xifr;
   
   logic               xicr_we;
   logic               xmsk_we;
   logic               xifr_we;
   
   logic               xicr_re;
   logic               xmsk_re;
   logic               xifr_re;
   
   logic [WIDTH-1:0]   dbus_out_raw; // Temp dbus_out assembly
   logic [WIDTH-1:0]   xmsk; //         Interrupt Mask
   logic [WIDTH-1:0]   xicr; //         Interrupt Control Reg
   logic [WIDTH-1:0]   xifr_din; //     Flag Reg value from AVR
   
   logic [WIDTH-1:0]   x_int_in_f; //   Latched up copy of x_int_in
   logic [WIDTH-1:0]   x_int_fl_set; // Interrupt Flags to be set
   
   logic [WIDTH-1:0]   xifr; //         Interrupt Flag Reg
   logic [WIDTH-1:0]   xifr_next; //    Next Interrupt Flag Reg Value

   
   // Normal DBUS input selection stuff
   assign sel_xicr = XICR_DM_LOC ? (dm_sel && (ramadr[7:0] == XICR_Address)) : 
                                   (adr[5:0] == XICR_Address[5:0]);

   assign sel_xifr = XIFR_DM_LOC ? (dm_sel && (ramadr[7:0] == XIFR_Address)) : 
                                   (adr[5:0] == XIFR_Address[5:0]);

   assign sel_xmsk = XMSK_DM_LOC ? (dm_sel && (ramadr[7:0] == XMSK_Address)) : 
                                   (adr[5:0] == XMSK_Address[5:0]);
   
   assign xicr_we = sel_xicr && (XICR_DM_LOC ? ramwe : iowe);
   assign xifr_we = sel_xifr && (XIFR_DM_LOC ? ramwe : iowe);
   assign xmsk_we = sel_xmsk && (XMSK_DM_LOC ? ramwe : iowe);
   
   assign xicr_re = sel_xicr && (XICR_DM_LOC ? ramre : iore);
   assign xifr_re = sel_xifr && (XIFR_DM_LOC ? ramre : iore);
   assign xmsk_re = sel_xmsk && (XMSK_DM_LOC ? ramre : iore);
   

   // *** Control and Mask registers ***   
   always @(posedge clk or negedge rstn) begin
      if (!rstn) begin
         xicr <= {WIDTH{1'b0}}; // Default to disabled
         xmsk <= {WIDTH{1'b0}}; // Default is to mask all ints
      end
      else begin
         if (xicr_we) begin
            xicr <= dbus_in;
         end
         xicr <= xicr_we ? dbus_in : xicr;
         xmsk <= xmsk_we ? dbus_in : xmsk;
      end
   end
   
   // XIFR
   always @(posedge clk or negedge rstn) begin
      if (!rstn) begin          //Reset
         xifr <= {WIDTH{1'b0}};
      end
      else begin
         if (xifr_we) begin // We are writing the xifr from software
            
            // Flag reg is a "Write 1 to Clear" reg. If a xifr bit is
            // set and the corresponding bit in the byte being written
            // by software is also set, then the xifr bit should be
            // set to zero
            xifr <= xifr & ~dbus_in[WIDTH-1:0];

         end            
         else begin // We are just updating in normal operation
           
           // The incoming pin change notifications are one shot
           // signals from the individual ports indicating there was a
           // change on one of thier pins, one of the enabled and
           // unmasked pins. We set the corresponding IFR flag bit if
           // it is not masked. The irq_ack will clear the
           // corresponding IFR flag, but is not used in most cases. 

           // In this flavor the incoming int_in overides the irq_ack
           xifr <= ((x_int_in | (xifr & ~x_irq_ack)) & xmsk); 
            // In this flavor the irq_ack overides the incoming int_in
            // xifr <= (((xifr | x_int_in) & ^x_irq_ack) & ~xmsk);
            
         end // if (xifr_we)
      end // else: !if(!rstn)
   end // always @ (posedge clk or negedge rstn)   
   
   // Send the irq to the xlr8_irq block if any enabled interrupt is
   // set in the IFR
   assign x_irq = |(xifr & xicr);

   
   // Normal DBUS out stuff
   assign dbus_out_raw  = (xicr_re ? xicr : {WIDTH{1'b0}}) |
                          (xmsk_re ? xmsk : {WIDTH{1'b0}}) |
                          (xifr_re ? xifr : {WIDTH{1'b0}}); 

   assign dbus_out = {{8-WIDTH{1'b0}},dbus_out_raw};

   assign out_en   = xicr_re | xmsk_re | xifr_re;

   
endmodule

