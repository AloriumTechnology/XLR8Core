//////////////////////////////////////////////////////////////////
//=================================================================
//  Copyright(c) Superion Technology Group Inc., 2017
//  ALL RIGHTS RESERVED
//  $Id:  $
//=================================================================
//
// File name:  : xlr8_portmux.v
// Author      : Steve Phillips
// Description : Mux control and data for add on avr_ports
//=================================================================
///////////////////////////////////////////////////////////////////


module xlr8_portmux
  #(
    parameter  PORTX_ADDR = 0,
    parameter  DDRX_ADDR  = 0,
    parameter  PINX_ADDR  = 0,
    parameter  WIDTH      = 8
    )
   (
    input                    clk,
    input                    rstn,
    // Inputs
    input [WIDTH-1:0]        port_portx,
    input [WIDTH-1:0]        port_ddrx,
    input [WIDTH-1:0]        xb_ddoe,
    input [WIDTH-1:0]        xb_ddov,
    input [WIDTH-1:0]        xb_pvoe,
    input [WIDTH-1:0]        xb_pvov,
    
    // Outputs
    inout        [WIDTH-1:0] port_pads, // Attach actual pin names here
    output logic [WIDTH-1:0] port_pinx,
    output logic [WIDTH-1:0] xb_pinx
    );

   logic [WIDTH-1:0]        tpads;
   logic [WIDTH-1:0]        port_data;
   logic [WIDTH-1:0]        port_oe;
   logic [WIDTH-1:0]        port_dout;
   logic [WIDTH-1:0]        port_ie;
   int                      i;
   
   // Below are two different implementations,

   // This one works best. Use a temporary variable, tpads, to go 
   // through the tri-state trinary operator since VCS won't allow
   // the use of an inout port in that context. Then assign the
   // temprary variable to port_pads.
   always_comb begin
      port_oe   = ( xb_ddoe & xb_ddov)    |
                  (~xb_ddoe & port_ddrx);
      port_dout = ( xb_pvoe & xb_pvov)    |
                  (~xb_pvoe & port_portx);
      port_ie   = {WIDTH{1'b1}}; // could just delete port_ie?
      
      for (i=0; i<WIDTH; i++) begin
         tpads[i] = port_oe[i] ? port_dout[i] : 1'bZ;
      end

      port_pinx = port_pads & port_ie;
      xb_pinx   = port_pads;
   end
   assign port_pads = tpads;


/*   
   // This one doesn't work becuase Zs don't propogate correctly 
   // through the trinary operator. Need to do it a bit at a time.
 
   // Implementing logic from IOMUX
   assign port_oe   = ( xb_ddoe & xb_ddov)    |
                   (~xb_ddoe & port_ddrx);
   assign port_dout = ( xb_pvoe & xb_pvov)    |
                   (~xb_pvoe & port_portx);
   assign port_ie   = {WIDTH{1'b1}}; // could just delete port_ie?
   
   assign port_pads  = port_oe  ? port_dout  : 1'bZ;
   
   assign port_pinx = port_pads & port_ie;
   assign xb_pinx   = port_pads;
*/
   
endmodule // xlr8_portmux

