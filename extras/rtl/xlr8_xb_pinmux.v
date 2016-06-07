/////////////////////////////////
// Filename    : xlr8_xb_pinmux.v
// Author      : Matt Weber
// Description : For XBs that control pins, this module muxes them
//                all together then sends the result to the module
//                that is muxing all the AVR functions together. This
//                separation makes it easier to add/drop Xcelerator
//                Blocks without impacting the standard AVR logic.
//               XBs can control the IO direction (input vs output),
//                and, for outputs, the value to drive. If multiple
//                XBs try to drive the same pin, the output is
//                undefined.
//
// Copyright 2015, Superion Technology Group. All Rights Reserved
/////////////////////////////////

module xlr8_xb_pinmux
  #(parameter NUM_PINS = 20, // Default is Arduino Uno Digital 0-13 + Analog 0-5
    parameter NUM_XBS = 3)
   (input                          clk, // Just use by assertions
    input                          rstn,// Just use by assertions
    input [NUM_XBS-1:0][NUM_PINS-1:0] xbs_ddoe, // override data direction
    input [NUM_XBS-1:0][NUM_PINS-1:0] xbs_ddov, // data direction value if overridden (1=out)
    input [NUM_XBS-1:0][NUM_PINS-1:0] xbs_pvoe, // override output value
    input [NUM_XBS-1:0][NUM_PINS-1:0] xbs_pvov, // output value if overridden
    output logic [NUM_PINS-1:0]       xb_ddoe,  // override data direction
    output logic [NUM_PINS-1:0]       xb_ddov,  // data direction value if overridden (1=output)
    output logic [NUM_PINS-1:0]       xb_pvoe,  // override output value
    output logic [NUM_PINS-1:0]       xb_pvov   // output value if overridden
  );

/////////////////////////////////
// Signals
/////////////////////////////////
`ifdef STGI_ASSERT_ON
  logic zero_one_hot_error_ddoe;
  logic zero_one_hot_error_pvoe;
`endif  

/////////////////////////////////
// Main Code
/////////////////////////////////
  always_comb begin
`ifdef STGI_ASSERT_ON
    zero_one_hot_error_ddoe = 1'h0;
    zero_one_hot_error_pvoe = 1'h0;
`endif      
    /*AUTORESET*/
    // Beginning of autoreset for uninitialized flops
    xb_ddoe = {NUM_PINS{1'b0}};
    xb_ddov = {NUM_PINS{1'b0}};
    xb_pvoe = {NUM_PINS{1'b0}};
    xb_pvov = {NUM_PINS{1'b0}};
    // End of automatics
    for (int i=0;i<NUM_XBS;i++) begin
`ifdef STGI_ASSERT_ON
      // If more than one XB is trying to drive a pin detect
      //  it by seeing if output bit was already set.
      zero_one_hot_error_ddoe = |(xb_ddoe & xbs_ddoe[i]);
      zero_one_hot_error_pvoe = |(xb_pvoe & xbs_pvoe[i]);
`endif      
      xb_ddoe = xb_ddoe | xbs_ddoe[i];
      xb_ddov = xb_ddov | (xbs_ddoe[i] & xbs_ddov[i]);
      xb_pvoe = xb_pvoe | xbs_pvoe[i];
      xb_pvov = xb_pvov | (xbs_pvoe[i] & xbs_pvov[i]);
    end
  end
  
/////////////////////////////////
// Assertions
/////////////////////////////////

`ifdef STGI_ASSERT_ON
 `ifndef VERILATOR
  ERROR_undefined_rstn: assert property
   (@(posedge clk)
    !$isunknown(rstn));
  ERROR_undefined_xbs_ddoe: assert property
   (@(posedge clk) disable iff (!rstn)
    !$isunknown(xbs_ddoe));
  ERROR_undefined_xbs_ddov: assert property
   (@(posedge clk) disable iff (!rstn)
    !$isunknown(xbs_ddov));
  ERROR_undefined_xbs_pvoe: assert property
   (@(posedge clk) disable iff (!rstn)
    !$isunknown(xbs_pvoe));
  ERROR_undefined_xbs_pvov: assert property
   (@(posedge clk) disable iff (!rstn)
    !$isunknown(xbs_pvov));

  ERROR_onehot_xbs_ddoe: assert property
   (@(posedge clk) disable iff (!rstn)
    (!zero_one_hot_error_ddoe))
    else $error("ERROR: Multiple XBs driving pin direction");
  ERROR_onehot_xbs_pvoe: assert property
   (@(posedge clk) disable iff (!rstn)
    (!zero_one_hot_error_pvoe))
    else $error("ERROR: Multiple XBs driving pin value");
   
 `endif
`endif

/////////////////////////////////
// Cover Points
/////////////////////////////////

`ifdef SUP_COVER_ON
`endif

endmodule
