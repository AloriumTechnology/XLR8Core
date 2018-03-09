//************************************************************************************************
// DM RAM for AVR Core
// Version 0.1
// Modified 18.06.2007
// Designed by Ruslan Lepetenok
// cpuwait,ireset was removed 
//************************************************************************************************

`timescale 1 ns / 1 ns

module xlr8_d_mem(
   cp2,
   ce,
   address,
   din,
   dout,
   we
);

   parameter              dm_size = 1;          // DM size 1..64 K
   
   input                  cp2;
   input                  ce;
   input [15:0]           address;
   input [7:0]            din;
   output [7:0]           dout;
   input                  we;
   
   localparam             c_adr_width = (dm_size < 2)    ? 0 + 10 :
                                        (dm_size < 4)    ? 1 + 10 :  
                                        (dm_size < 8)    ? 2 + 10 :  
                                        (dm_size < 16)   ? 3 + 10 :  
                                        (dm_size < 32)   ? 4 + 10 :  
                                        (dm_size < 64)   ? 5 + 10 :  
                                        (dm_size == 64)  ? 6 + 10 : 0;  

   
   wire [c_adr_width-1:0] addr_tmp;
   
   wire                   cp2_tmp;
      
   assign addr_tmp = address[c_adr_width-1:0];
   
   
   
`ifdef D_MEM_SIM_MODEL
   // just model the ram so we don't have to worry about technology specific models
   reg [c_adr_width-1:0]  addr_tmp_d;
   reg [7:0]              mem_data [(1 << c_adr_width)-1:0];
   always @(posedge cp2) begin
      addr_tmp_d <= addr_tmp;
      if (we) mem_data[addr_tmp] <= din;
   end
   assign dout = mem_data[addr_tmp_d];
`else
   // Altera memory
   altsyncram #(.clock_enable_input_a ("NORMAL"),
                .clock_enable_output_a ("BYPASS"),
                .intended_device_family ("MAX 10"),
                .lpm_hint ("ENABLE_RUNTIME_MOD=NO"),
                .lpm_type ("altsyncram"),
                .numwords_a (dm_size * 1024),
                .operation_mode ("SINGLE_PORT"),
                .outdata_aclr_a ("NONE"),
                .outdata_reg_a ("UNREGISTERED"),
                .power_up_uninitialized ("FALSE"),
                .ram_block_type ("M9K"),
                .read_during_write_mode_port_a ("DONT_CARE"),
                .widthad_a (c_adr_width),
                .width_a (8),
                .width_byteena_a (1))
        altsyncram_inst (.address_a (addr_tmp),
                         .clock0 (cp2),
                         .clocken0 (ce),
                         .data_a (din),
                         .wren_a (we),
                         .q_a (dout),
                         .aclr0 (1'b0),
                         .aclr1 (1'b0),
                         .address_b (1'b1),
                         .addressstall_a (1'b0),
                         .addressstall_b (1'b0),
                         .byteena_a (1'b1),
                         .byteena_b (1'b1),
                         .clock1 (1'b1),
                         .clocken1 (1'b1),
                         .clocken2 (1'b1),
                         .clocken3 (1'b1),
                         .data_b (1'b1),
                         .eccstatus (),
                         .q_b (),
                         .rden_a (1'b1),
                         .rden_b (1'b1),
                         .wren_b (1'b0));
`endif
   
  wire _unused_ok = &{1'b0,
                      address[15:c_adr_width],
                      ce,  // currently unused, perhaps hook up later for power savings?
                      1'b0};

      
endmodule
                                                                                        
