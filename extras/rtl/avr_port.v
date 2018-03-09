///////////////////////////////////////////////////////////////////
//=================================================================
//  Copyright(c) Superion Technology Group Inc., 2015
//  ALL RIGHTS RESERVED
//  $Id:  $
//=================================================================
//
// File name:  : avr_port.v
// Author      : Matt Weber
// Description : I/O port based on ATmega328p
//
//=================================================================
///////////////////////////////////////////////////////////////////

module avr_port(/*AUTOARG*/
   // Outputs
   dbus_out, io_out_en, portx, ddrx,
   // Inputs
   rstn, clk, clken, adr, dbus_in, iore, iowe, ramadr, ramre, ramwe, dm_sel,
   pinx
   );
   parameter  PORTX_ADDR = 0;
   parameter  DDRX_ADDR  = 0;
   parameter  PINX_ADDR  = 0;
   parameter  WIDTH      = 8;
   
   // Clock and Reset
   input                     rstn;
   input                     clk;
   input                     clken;
   // I/O 
   input [5:0]               adr;
   input [7:0]               dbus_in;
   output [7:0]              dbus_out;
   input                     iore;
   input                     iowe;
   output                    io_out_en;
   // DM
   input [7:0]               ramadr;
   input                     ramre;
   input                     ramwe;
   input                     dm_sel;
   // External connection
   output [WIDTH-1:0]   portx;
   output [WIDTH-1:0]   ddrx;
   input [WIDTH-1:0]    pinx;
   
  localparam PORTX_DM_LOC = (PORTX_ADDR >= 16'h60) ? 1 : 0;
  localparam DDRX_DM_LOC  = (DDRX_ADDR  >= 16'h60) ? 1 : 0;
  localparam PINX_DM_LOC  = (PINX_ADDR  >= 16'h60) ? 1 : 0;
  
  logic portx_sel; 
  logic ddrx_sel ;
  logic pinx_sel ;
  logic portx_we; 
  logic ddrx_we ;
  logic pinx_we ; 
  logic portx_re; 
  logic ddrx_re ;
  logic pinx_re ;
  logic [WIDTH-1:0] pinx_sync;
  logic [WIDTH-1:0] pinx_sync_no_x;
  logic [WIDTH-1:0] portx;
  logic [WIDTH-1:0] ddrx; 

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   assign portx_sel = PORTX_DM_LOC ?  (dm_sel && ramadr == PORTX_ADDR ) : (adr[5:0] == PORTX_ADDR ); 
   assign ddrx_sel  = DDRX_DM_LOC  ?  (dm_sel && ramadr == DDRX_ADDR )  : (adr[5:0] == DDRX_ADDR );
   assign pinx_sel  = PINX_DM_LOC  ?  (dm_sel && ramadr == PINX_ADDR )  : (adr[5:0] == PINX_ADDR ); 
   assign portx_we = portx_sel && (PORTX_DM_LOC ?  ramwe : iowe); 
   assign ddrx_we  = ddrx_sel  && (DDRX_DM_LOC  ?  ramwe : iowe);
   assign pinx_we  = pinx_sel  && (PINX_DM_LOC  ?  ramwe : iowe); 
   assign portx_re = portx_sel && (PORTX_DM_LOC ?  ramre : iore); 
   assign ddrx_re  = ddrx_sel  && (DDRX_DM_LOC  ?  ramre : iore);
   assign pinx_re  = pinx_sel  && (PINX_DM_LOC  ?  ramre : iore);
   assign dbus_out =  ({8{portx_sel}} & portx) | 
                      ({8{ddrx_sel}} & ddrx) |
                      ({8{pinx_sel}} & pinx_sync_no_x);
   assign io_out_en = portx_re || 
                      ddrx_re ||
                      pinx_re;
   
   always @(posedge clk or negedge rstn) begin
      if (!rstn)  begin
         /*AUTORESET*/
         // Beginning of autoreset for uninitialized flops
         ddrx <= {WIDTH{1'b0}};
         // End of automatics
      end else if (clken && ddrx_we) begin
         ddrx <= dbus_in[WIDTH-1:0];
      end
   end // always @ (posedge clk or negedge rstn)
   always @(posedge clk or negedge rstn) begin
      if (!rstn)  begin
         /*AUTORESET*/
         // Beginning of autoreset for uninitialized flops
         portx <= {WIDTH{1'b0}};
         // End of automatics
      end else if (clken && portx_we) begin
         portx <= dbus_in[WIDTH-1:0];
      end else if (clken && pinx_we) begin // toggle function from spec 14.2.2
         portx <= portx ^ dbus_in[WIDTH-1:0];
      end
   end // always @ (posedge clk or negedge rstn)

  // Synchronizer is latch followed by flop as shown in ATmega328p spec figures 14-2 and 14-5
  // Our device doesn't have latches, so we instead use negedge flop followed by posedge flop
  //   and that should have the same timing.
  synch Tn_sync[WIDTH-1:0] (.dout       (pinx_sync),
                            .clk        (clk),
                            .din        (pinx));
  // It is entirely reasonable (typical even) to run with some IOs unconnected. When reading
  //  the pin register for IOs that are being used, the unconnected ones that don't have 
  //  pullups would be X in simulation and cause assertion failures. Work around that by
  //  converting Xs to random values.
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
   
endmodule // avr_port
