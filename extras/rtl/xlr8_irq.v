//////////////////////////////////////////////////////////////////
//=================================================================
//  Copyright(c) Superion Technology Group Inc., 2017
//  ALL RIGHTS RESERVED
//=================================================================
//
// File name:  : xlr8_irq.v
// Author      : Steve Phillips
// Description : XLR8 Interrrupt Handler
//
// This interrupt handler is intended to interface to the interrupt
// logic in the AVR core. Each bit in this flag reg will be connected
// to the pcint_rcv input to the AVR core and will recieve an ACK back
// from the core via the pcmsk output of the AVR core.
//
// The x_int_in input receives steady state interrupt signals from
// other modules that are OR'd into the current IFR reg. The IFR bits
// are cleared by the ACK from the core. If the x_int_in bit is still
// set, then the IFR bit that was cleared will be reset the next
// cycle.
//
//////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ns


module xlr8_irq
#(
  parameter XICR_Address = 0,
  parameter XIFR_Address = 0,
  parameter XMSK_Address = 0,
  parameter XACK_Address = 0,
  parameter WIDTH        = 8
  )
   
   (// Clock and Reset
    input              rstn,
    input              clk,
    // I/O i/f
    input [5:0]        adr,
    input              iowe,
    input              iore,
    input [7:0]        dbus_in,
    output [7:0]       dbus_out,
    output             out_en,
    // DM i/f
    input [7:0]        ramadr,
    input              ramre,
    input              ramwe,
    input              dm_sel,
    
    // Interrupts
    input [WIDTH-1:0]  x_int_in, // Interrupts in
    
    // Interrupt (CPU i/f)
    output [WIDTH-1:0] x_irq, //    IRQ to AVR core
    input [WIDTH-1:0]  x_irq_ack // IRQ Ack from AVR core
    );
   
   
   //-------------------------------------------------------
   // Registers in I/O address range x0-x3F (memory addresses -x20-0x5F)
   //  use the adr/iore/iowe inputs. Registers in the extended address
   //  range (memory address 0x60 and above) use ramadr/ramre/ramwe
   localparam  XICR_DM_LOC   = (XICR_Address >= 8'h60) ? 1 : 0;
   localparam  XIFR_DM_LOC   = (XIFR_Address >= 8'h60) ? 1 : 0;
   localparam  XMSK_DM_LOC   = (XMSK_Address >= 8'h60) ? 1 : 0;
   localparam  XACK_DM_LOC   = (XMSK_Address >= 8'h60) ? 1 : 0;
   
   logic               sel_xicr;
   logic               sel_xmsk;
   logic               sel_xifr;
   logic               sel_xack;
   
   logic               xicr_we;
   logic               xmsk_we;
   logic               xifr_we;
   logic               xack_we;
   
   logic               xicr_re;
   logic               xmsk_re;
   logic               xifr_re;
   logic               xack_re;
   
   logic [WIDTH-1:0]   dbus_out_raw; // Temp dbus_out assembly
   logic [WIDTH-1:0]   xmsk; //         Interrupt Mask
   logic [WIDTH-1:0]   xicr; //         Interrupt Control Reg
   logic [WIDTH-1:0]   xifr_din; //     Flag Reg value from AVR
   
   logic [WIDTH-1:0]   x_int_in_f; //   Latched up copy of x_int_in
   logic [WIDTH-1:0]   x_int_fl_set; // Interrupt Flags to be set
   
   logic [WIDTH-1:0]   xifr; //         Interrupt Flag Reg
   logic [WIDTH-1:0]   xifr_next; //    Next Interrupt Flag Reg Value

   logic [WIDTH-1:0]   xack; //         ACK capture reg
   
   
   assign sel_xicr = XICR_DM_LOC ? (dm_sel && (ramadr[7:0] == XICR_Address)) : 
                                   (adr[5:0] == XICR_Address[5:0]);

   assign sel_xifr = XIFR_DM_LOC ? (dm_sel && (ramadr[7:0] == XIFR_Address)) : 
                                   (adr[5:0] == XIFR_Address[5:0]);

   assign sel_xmsk = XMSK_DM_LOC ? (dm_sel && (ramadr[7:0] == XMSK_Address)) : 
                                   (adr[5:0] == XMSK_Address[5:0]);

   assign sel_xack = XACK_DM_LOC ? (dm_sel && (ramadr[7:0] == XACK_Address)) : 
                                   (adr[5:0] == XACK_Address[5:0]);
   
   assign xicr_we = sel_xicr && (XICR_DM_LOC ? ramwe : iowe);
   assign xifr_we = sel_xifr && (XIFR_DM_LOC ? ramwe : iowe);
   assign xmsk_we = sel_xmsk && (XMSK_DM_LOC ? ramwe : iowe);
   assign xack_we = sel_xack && (XACK_DM_LOC ? ramwe : iowe);
   
   assign xicr_re = sel_xicr && (XICR_DM_LOC ? ramre : iore);
   assign xifr_re = sel_xifr && (XIFR_DM_LOC ? ramre : iore);
   assign xmsk_re = sel_xmsk && (XMSK_DM_LOC ? ramre : iore);
   assign xack_re = sel_xack && (XACK_DM_LOC ? ramre : iore);
   

   // *** Control and Mask registers ***   
   always @(posedge clk or negedge rstn) begin
      if (!rstn) begin
         xicr <= {WIDTH{1'b0}}; // Default is all irq disabled
         xmsk <= {WIDTH{1'b0}}; // Default is to mask all irqs
         xack <= {WIDTH{1'b0}}; // At reset clear tha XACK reg
      end
      else begin
         if (xicr_we) begin
            xicr <= dbus_in;
         end
         xicr <= xicr_we ? dbus_in : xicr;
         xmsk <= xmsk_we ? dbus_in : xmsk;
         xack <= xack_we ? (xack & ~dbus_in) : // Write 1 to clear
                           (x_irq_ack | xack); // Set ack bits  
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
            // set and the corresponding bit in the byt being written
            // by software is also set, then the xifr bit should be
            // set to zero
            xifr <= xifr & ~dbus_in[WIDTH-1:0];

         end            
         else begin // We are just updating in normal operation
            
            // Update the xifr every cycle that we are not clearing
            // bits from software. The interrupt bits from downstream
            // sources x_int_in) are simply an OR of the bits in their
            // IFR regs, so they are always set anytime anyone of thier
            // IFR bits are set. On recieving an irq_ack the
            // corresponding xifr bit is cleared and the ack is
            // captured in the xack reg, which will block further
            // interrupts until it is cleared by software 
            xifr <= x_int_in & xmsk & ~(x_irq_ack | xack); //
            
         end // if (xifr_we)
      end // else: !if(!rstn)
   end // always @ (posedge clk or negedge rstn)
   
   
   // Outputs
   assign dbus_out_raw  = (xicr_re ? xicr : {WIDTH{1'b0}}) |
                          (xmsk_re ? xmsk : {WIDTH{1'b0}}) |
                          (xifr_re ? xifr : {WIDTH{1'b0}}); 

   assign dbus_out = {{8-WIDTH{1'b0}},dbus_out_raw};

   assign out_en   = xicr_re | xmsk_re | xifr_re;
   
   assign x_irq = xifr & xicr;
   
endmodule

