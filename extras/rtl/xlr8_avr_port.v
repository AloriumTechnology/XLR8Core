///////////////////////////////////////////////////////////////////
//=================================================================
//  Copyright(c) Superion Technology Group Inc., 2017
//  ALL RIGHTS RESERVED
//  $Id:  $
//=================================================================
//
// File name:  : xlr8_avr_port.v
// Author      : Steve Phillips
// Description :
//
// Modified version of the avr_port module that allows for different
// reset values other that all zeros for the portx and ddrx regs. The
// default values are still zeros, but alternative values can be
// passed in via parameters when instantiating the module. 
//
// It also incorporates pin change detection and generates an IRQ
// signal back up to the parent module. The mask reg is controlled by
// software using the MASK_ADDR address and will prevent pin change
// interupts unless the mask bit is cleared on a per pin basis. 
//
//=================================================================
///////////////////////////////////////////////////////////////////

module xlr8_avr_port
  #(
    parameter  PORTX_ADDR    = 0,
    parameter  DDRX_ADDR     = 0,
    parameter  PINX_ADDR     = 0,
    parameter  PCMSK_ADDR    = 0,
    parameter  WIDTH         = 8,
    parameter  PORTX_RST_VAL = 0,
    parameter  DDRX_RST_VAL  = 0, 
    parameter  PCMSK_RST_VAL  = 8'h0 
   )
   (
    // Clock and Reset
    input                    rstn,
    input                    clk,
    input                    clken,
    // I/O 
    input [5:0]              adr,
    input [7:0]              dbus_in,
    output logic [7:0]       dbus_out,
    input                    iore,
    input                    iowe,
    output logic             io_out_en,
    // DM
    input [7:0]              ramadr,
    input                    ramre,
    input                    ramwe,
    input                    dm_sel,
    // External connection
    output logic [WIDTH-1:0] portx, //    Value for output pin
    output logic [WIDTH-1:0] ddrx, //     Control direction of pin
    input [WIDTH-1:0]        pinx, //     Values of input pins
    output logic             pcifr_set // Signal to upper level that a pin change has occrured
    );
   
   
   localparam PORTX_DM_LOC  = (PORTX_ADDR >= 16'h60) ? 1 : 0;
   localparam DDRX_DM_LOC   = (DDRX_ADDR  >= 16'h60) ? 1 : 0;
   localparam PINX_DM_LOC   = (PINX_ADDR  >= 16'h60) ? 1 : 0;
   localparam PCMSK_DM_LOC  = (PCMSK_ADDR >= 16'h60) ? 1 : 0;
   
   logic               portx_sel; 
   logic               ddrx_sel;
   logic               pinx_sel;
   logic               pcmsk_sel;
   logic               portx_we; 
   logic               ddrx_we ;
   logic               pinx_we ; 
   logic               pcmsk_we; 
   logic               portx_re; 
   logic               ddrx_re ; 
   logic               pinx_re ;
   logic               pcmsk_re;
   logic [WIDTH-1:0]   pcmsk;
   logic [WIDTH-1:0]   pinx_sync;
   logic [WIDTH-1:0]   pinx_sync_no_x;
   logic [WIDTH-1:0]   portx_rst_val;
   logic [WIDTH-1:0]   ddrx_rst_val;
   logic [WIDTH-1:0]   pcifr_set_vector; //TEMP VARIABLE
   
   //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   assign portx_sel = PORTX_DM_LOC ?  (dm_sel && ramadr == PORTX_ADDR) : 
                                      (adr[5:0] == PORTX_ADDR ); 
   assign ddrx_sel  = DDRX_DM_LOC  ?  (dm_sel && ramadr == DDRX_ADDR) : 
                                      (adr[5:0] == DDRX_ADDR );
   assign pinx_sel  = PINX_DM_LOC  ?  (dm_sel && ramadr == PINX_ADDR) : 
                                      (adr[5:0] == PINX_ADDR ); 
   assign pcmsk_sel = PCMSK_DM_LOC ?  (dm_sel && ramadr == PCMSK_ADDR) : 
                                      (adr[5:0] == PCMSK_ADDR ); 

   assign portx_we = portx_sel && (PORTX_DM_LOC ?  ramwe : iowe); 
   assign ddrx_we  = ddrx_sel  && (DDRX_DM_LOC  ?  ramwe : iowe);
   assign pinx_we  = pinx_sel  && (PINX_DM_LOC  ?  ramwe : iowe); 
   assign pcmsk_we = pcmsk_sel && (PCMSK_DM_LOC ?  ramwe : iowe); 

   assign portx_re = portx_sel && (PORTX_DM_LOC ?  ramre : iore); 
   assign ddrx_re  = ddrx_sel  && (DDRX_DM_LOC  ?  ramre : iore);
   assign pinx_re  = pinx_sel  && (PINX_DM_LOC  ?  ramre : iore);
   assign pcmsk_re = pcmsk_sel && (PCMSK_DM_LOC ?  ramre : iore);

   assign dbus_out =  ({8{portx_sel}} & portx) | 
                      ({8{ddrx_sel}} & ddrx) |
                      ({8{pinx_sel}} & pinx_sync_no_x) |
                      ({8{pcmsk_sel}} & pcmsk);

   assign io_out_en = portx_re || 
                      ddrx_re ||
                      pinx_re ||
                      pcmsk_re;
   
   assign portx_rst_val = PORTX_RST_VAL;
   assign ddrx_rst_val   = DDRX_RST_VAL;
   
   always @(posedge clk or negedge rstn) begin
      if (!rstn)  begin
         /*AUTORESET*/
         // Beginning of autoreset for uninitialized flops
         ddrx <= ddrx_rst_val;
         // End of automatics
      end else if (clken && ddrx_we) begin
         ddrx <= dbus_in[WIDTH-1:0];
      end
   end // always @ (posedge clk or negedge rstn)
   always @(posedge clk or negedge rstn) begin
      if (!rstn)  begin
         /*AUTORESET*/
         // Beginning of autoreset for uninitialized flops
         portx <= portx_rst_val; 
         // End of automatics
      end else if (clken && portx_we) begin
         portx <= dbus_in[WIDTH-1:0];
      end else if (clken && pinx_we) begin // toggle function from spec 14.2.2
         portx <= portx ^ dbus_in[WIDTH-1:0];
      end
   end // always @ (posedge clk or negedge rstn)
   
   // Synchronizer is latch followed by flop as shown in ATmega328p
   // spec figures 14-2 and 14-5 Our device doesn't have latches, so
   // we instead use negedge flop followed by posedge flop and that
   // should have the same timing.

   synch Tn_sync[WIDTH-1:0] (.dout       (pinx_sync),
                             .clk        (clk),
                             .din        (pinx));

   // It is entirely reasonable (typical even) to run with some IOs
   // unconnected. When reading the pin register for IOs that are
   // being used, the unconnected ones that don't have pullups would
   // be X in simulation and cause assertion failures. Work around
   // that by converting Xs to random values.

   always @(pinx_sync or pinx_re) begin
      int i;
      for (i=0;i<WIDTH;i++) begin
         if ((pinx_sync[i] == 1'b1 || pinx_sync[i] == 1'b0)) begin
            pinx_sync_no_x[i] = pinx_sync[i];
         end else begin
`ifdef PINX_NO_X_FOR_SIM
            pinx_sync_no_x[i] = $random;
`else
            pinx_sync_no_x[i] = pinx_sync[i];
`endif
         end
      end
   end

   // Pin change interrupt generation
   //
   // The pcmsk control
   always @(posedge clk or negedge rstn) begin
      if (!rstn)  begin
         pcmsk <= PCMSK_RST_VAL; 
      end else if (clken && pcmsk_we) begin
         pcmsk <= dbus_in[WIDTH-1:0];
      end
   end
   
   // Look for edges on any pin in the port
   assign pcifr_set_vector = ((pinx_sync_no_x ^ pinx) & pcmsk);
   assign pcifr_set = |pcifr_set_vector;
   
endmodule // xlr8_avr_port
