// Copyright (C) 2017  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details.

// VENDOR "Altera"
// PROGRAM "Quartus Prime"
// VERSION "Version 17.1.0 Build 590 10/25/2017 SJ Standard Edition"

// DATE "02/25/2018 18:49:19"

// 
// Device: Altera 10M08SAU169C8G Package UFBGA169
// 

// 
// This greybox netlist file is for third party Synthesis Tools
// for timing and resource estimation only.
// 


module int_osc (
	clkout,
	oscena)/* synthesis synthesis_greybox=0 */;
output 	clkout;
input 	oscena;

wire gnd;
wire vcc;
wire unknown;

assign gnd = 1'b0;
assign vcc = 1'b1;
// unknown value (1'bx) is not needed for this tool. Default to 1'b0
assign unknown = 1'b0;

wire \int_osc_0|wire_clkout ;
wire \oscena~_wirecell_combout ;
wire \oscena~input_o ;


int_osc_altera_int_osc int_osc_0(
	.clkout(\int_osc_0|wire_clkout ),
	.oscena(\oscena~_wirecell_combout ));

fiftyfivenm_lcell_comb \oscena~_wirecell (
	.dataa(\oscena~input_o ),
	.datab(gnd),
	.datac(gnd),
	.datad(gnd),
	.cin(gnd),
	.combout(\oscena~_wirecell_combout ),
	.cout());
defparam \oscena~_wirecell .lut_mask = 16'h5555;
defparam \oscena~_wirecell .sum_lutc_input = "datac";

assign \oscena~input_o  = oscena;

assign clkout = \int_osc_0|wire_clkout ;

endmodule

module int_osc_altera_int_osc (
	clkout,
	oscena)/* synthesis synthesis_greybox=0 */;
output 	clkout;
input 	oscena;

wire gnd;
wire vcc;
wire unknown;

assign gnd = 1'b0;
assign vcc = 1'b1;
// unknown value (1'bx) is not needed for this tool. Default to 1'b0
assign unknown = 1'b0;



fiftyfivenm_oscillator oscillator_dut(
	.oscena(!oscena),
	.clkout(clkout),
	.clkout1());
defparam oscillator_dut.clock_frequency = "116";
defparam oscillator_dut.device_id = "08";

endmodule
