  //----------------------------------------------------------------------
  // 1.) Parameters

  #(
    parameter DESIGN_CONFIG = 8,
    //    {
    //     25'd0, // [31:14] - reserved
    //     8'h8,  // [13:6]  - MAX10 Size,  ex: 0x8 = M08, 0x32 = M50
    //     1'b0,  //   [5]   - ADC_SWIZZLE, 0 = XLR8,            1 = Sno
    //     1'b0,  //   [4]   - PLL Speed,   0 = 16MHz PLL,       1 = 50Mhz PLL
    //     1'b1,  //   [3]   - PMEM Size,   0 = 8K (Sim Kludge), 1 = 16K
    //     2'd0,  //  [2:1]  - Clock Speed, 0 = 16MHZ,           1 = 32MHz, 2 = 64MHz, 3=na
    //     1'b0   //   [0]   - FPGA Image,  0 = CFM Application, 1 = CFM Factory
    //     },
    
    parameter NUM_PINS = 20,// Default is Arduino Uno Digital 0-13 + Analog 0-5
    // NUM_PINS should be 20 for the XLR8 board, ?? for the Sno board
    
    parameter OX8ICR_Address = 8'h31,
    parameter OX8IFR_Address = 8'h32,
    parameter OX8MSK_Address = 8'h33
    // The OX8*_Address parameters are used to control the interrupt module
    
    )
   //----------------------------------------------------------------------
   
   //----------------------------------------------------------------------
   // 2.) Inputs and Outputs
   (
    // Clock and Reset
    // The clk input is the CPU core frequency, which could be 16, 32 or 64MHZ 
    // depending on how the image was built
    input                       clk, //       Clock
    input                       rstn, //      Reset 
    // These three clocks are always the stated frequency, regardless of the CPU 
    // core frequency
    input                       clk_64mhz, // 64MHz clock
    input                       clk_32mhz, // 32MHz clock
    input                       clk_16mhz, // 16MHz clock
    input                       clk_option2, // Default: 64MHz, 45 degrees phase
    input                       clk_option4, // Default: 32MHz, 22.5 degrees phase
    // These enables have one shot pulses at the stated intrevals 
    input                       en16mhz, //   Enable for  16MHz timer
    input                       en1mhz, //    Enable for   1MHz timer
    input                       en128khz, //  Enable for 128KHz timer
    // I/O 
    input [5:0]                 adr, //       Reg Address
    input [7:0]                 dbus_in, //   Data Bus Input
    output [7:0]                dbus_out, //  Data Bus Output
    output                      io_out_en, // IO Output Enable
    input                       iore, //      IO Reade Enable
    input                       iowe, //      IO Write Enable
    // DM
    input [7:0]                 ramadr, //    RAM Address
    input                       ramre, //     RAM Read Enable
    input                       ramwe, //     RAM Write Enable
    input                       dm_sel, //    DM Select
    input [7:0]                 dm_dout_rg,// dout held during cpuwait, for UART

    // Other
    input [255:0]               gprf, //      Direct RO access to Reg File
    input [NUM_PINS-1:0]        xb_pinx, //   pin inputs
    inout                       JT9, //       JTAG pin
    inout                       JT7, //       JTAG pin
    inout                       JT6, //       JTAG pin
    inout                       JT5, //       JTAG pin
    inout                       JT3, //       JTAG pin
    inout                       JT1, //       JTAG pin
    // For iomux
    output logic [NUM_PINS-1:0] xb_ddoe, //   override data direction
    output logic [NUM_PINS-1:0] xb_ddov, //   data direction value if 
                                         //     overridden (1=output)
    output logic [NUM_PINS-1:0] xb_pvoe, //   override output value
    output logic [NUM_PINS-1:0] xb_pvov, //    output value if overridden
    // Interrupts
    output logic                xb_irq //    To core
    );
