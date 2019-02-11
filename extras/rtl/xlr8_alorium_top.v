//===========================================================================
//  Copyright(c) Alorium Technology Group Inc., 2015
//  ALL RIGHTS RESERVED
//===========================================================================
//
// File name:  : xlr8_alorium_top.v
// Author      : Matt Weber, Steve Phillips
// Contact     : support@aloriumtech.com
// Description : 
// 
//   Top module for ATMega328 clone with FPGA fabric
//
//   Components include: 
//     -  IO muxing
//     -  Data Memory (SRAM)
//     -  Program Memory (Flash)
//     -  Power on Reset generation
//     -  AVR core 
//
//   (modified from version 0.61 09.06.2012, written by Ruslan 
//    Lepetenok and downloaded from Opencores)
//
//===========================================================================


`include "synth_ctrl_pack.vh"
`include "avr_adr_pack.vh"

// Define XLR8_BOARD if no other board defined
`ifdef SNO_BOARD
`include "sno_adr_pack.vh"
`else
 `ifdef HINJ_BOARD
  `include "hinj_adr_pack.vh"
 `else
  `define XLR8_BOARD
 `endif
`endif

module xlr8_alorium_top
  #(
    parameter DESIGN_CONFIG = 520,
    //    {
    //     10'd0, // [31:22] - reserved
    //     8'h2,  // [21:14] - reserved for DMEM size
    //     8'h8,  // [13:6]  - MAX10 Size,  ex: 0x8 = M08, 0x32 = M50
    //     1'b0,  //   [5]   - ADC_SWIZZLE, 0 = XLR8,            1 = Sno
    //     1'b0,  //   [4]   - PLL Speed,   0 = 16MHz PLL,       1 = 50Mhz PLL
    //     1'b1,  //   [3]   - PMEM Size,   0 = 8K (Sim Kludge), 1 = 16K
    //     2'd0,  //  [2:1]  - Clock Speed, 0 = 16MHZ,           1 = 32MHz, 2 = 64MHz, 3=na
    //     1'b0   //   [0]   - FPGA Image,  0 = CFM Application, 1 = CFM Factory
    //     },

    // Specify the size of the DMEM
    parameter DMEM_SIZE       = 2,  // DMem Size, in KB, Valid range is 2 thru 64,
    
    // for APPLICATION design, each bit [i]  enables XB[i]
    parameter APP_XB0_ENABLE  = 0, // Should be zero to match Core QXP 

    // Set default values for unmbers of XBs
    parameter NUM_NEOPIXELS   = 15, //  Digital 1-13, plus A0 and A1
    parameter NUM_SERVOS      = 12, // As many as will fit with Floating Point
    parameter NUM_QUADRATURES = 6,  // 4 wheels and a robotic arm
    parameter NUM_PIDS        = 6   // 4 wheels and a robotic arm
    )
   (
`ifdef HINJ_BOARD
    // Include Hinj I/O definitions from another file
 `include "xlr8_alorium_top_io_hinj.vh"
`elsif DE10LITE_BOARD
    // Include DE10-Lite I/O definitions from another file
 `include "xlr8_alorium_top_io_de10lite.vh"
`else
    // Continue with the standard XLR8/Sno I/O definitions
   
    //Arduino I/Os
    inout       SCL,
    inout       SDA,
    // The D13..D2,TX,RX go through level shift on board before getting to pins
    inout       D13,D12,D11,D10,D9,D8, // Port B
 `ifdef SNO_BOARD
    inout       D7,D6,D5,D4,D3,D2,D1,D0, // Port D
    inout       RX,TX,
    inout       D22,D23,D24,D25,D26,D27, // Port A
    inout       D28,D29,D30,D31,D32,D33, // Port E
    inout       D34,D35,D36,D37,D38,D39, // Port G
 `else // XLR8 Board
    inout       D7,D6,D5,D4,D3,D2,TX,RX, // Port D
 `endif 
    // A5..A0 are labeled DIG_IO_5-0 on schematic
    inout       A5,A4,A3,A2,A1,A0, // Some stuff on board between here and the actual header pins
    output      PIN13LED,
    // We can disconnect Ana_Dig from ADC inputs if necessary (don't know if it is) by driving
    //   OE low. Else leave OE as high-Z (don't drive it high).
    inout [5:0] DIG_IO_OE,
    output      ANA_UP, // Choose ADC ref between 1=AREF pin and 0=regulated 3.3V
    output      I2C_ENABLE, // 0=disable pullups on sda/scl, 1=enable pullups
    // Interface to EEPROM or other device in SOIC-8 spot on the board
    inout       SOIC7, // WP in the case of an 24AA128SM EEPROM
    inout       SOIC6, // SCL in the case of an 24AA128SM EEPROM
    inout       SOIC5, // SDA in the case of an 24AA128SM EEPROM
    inout       SOIC3, // A2 in the case of an 24AA128SM EEPROM
    inout       SOIC2, // A1 in the case of an 24AA128SM EEPROM
    inout       SOIC1,  // A0 in the case of an 24AA128SM EEPROM
    // JTAG connector reused as digial IO. On that connector, pin 4 is power, pins 2&10 are ground
    //   and pin 8 selects between gpio (low) and jtag (high) modes and has a pulldown.

    inout       JT9, // external pullup. JTAG function is TDI
    inout       JT7, // no JTAG function
    inout       JT6, // no JTAG function
    inout       JT5, // external pullup. JTAG function is TMS
    inout       JT3, // JTAG function TDO
    inout       JT1, // external pulldown, JTAG function is TCK

    //Clock and Reset
    input       Clock, // 16MHz
    input       RESET_N
`endif
    );

   // FIXME: Eliminate any of these that aren't used
   localparam pm_size             = `c_pm_size;
   localparam DM_SIZE             = (DMEM_SIZE <= 2) ? 2 : DMEM_SIZE;
   localparam PM_REAL_SIZE        = DESIGN_CONFIG[3] ? pm_size : 8;
   localparam dm_int_sram_read_ws = `c_dm_int_sram_read_ws;
   localparam UFM_ADR_WIDTH = 13; // (For 32KB pmem = 16KInstructions = 8K 32-bit accesses = 13 bit address)
   localparam UFM_BC_WIDTH = 4;
   localparam NUM_UNO_PINS   = 20; // A[5:0] and D[13:0]
`ifdef HINJ_BOARD
   localparam NUM_PINS   = 122; // A[5:0],D[13:0] and Hinj Specific GPIO
`elsif SNO_BOARD
   localparam NUM_PINS   = 38; // A[5:0],D[13:0] and D[39:22]
`else
   localparam NUM_PINS   = 20; // A[5:0] and D[13:0]
`endif   
   localparam NUM_XBS    = 4; // Number of XB inputs to xb_pinmux
   localparam CLOCK_SELECT = DESIGN_CONFIG[2:1]; // 2 bits. 0=16MHZ, 1=32MHz, 2=64MHz, 3=reserved
   localparam PLL_SELECT   = DESIGN_CONFIG[4];  // 1=50MHz PLL, 0=16MHz PLL
   localparam USE_FP_UNIT        = APP_XB0_ENABLE[0];
   localparam USE_SERVO_UNIT     = APP_XB0_ENABLE[1];
   localparam USE_NEOPIXEL_UNIT  = APP_XB0_ENABLE[2];
   localparam USE_QUADRATURE_UNIT     = APP_XB0_ENABLE[3];
   localparam USE_PID_UNIT       = APP_XB0_ENABLE[4];
   localparam DC_FILLER = DESIGN_CONFIG[9:0]; // trying to work around Quartus QXP issue
//   localparam DESIGN_CONFIG_WITH_DMEM = {DC_FILLER[9:0],DM_SIZE[7:0],DESIGN_CONFIG[13:0]};
   localparam DESIGN_CONFIG_WITH_DMEM = {DM_SIZE,DESIGN_CONFIG[13:0]};

   logic        RXD_rcv;
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   logic        TXD;                    // To iomux328_inst of xlr8_iomux328.v
   //sjp//  logic [31:0]          xb_info;                // To uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   // End of automatics

   /*AUTOLOGIC*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   logic [5:0]  ADCD;                   // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic        ICP1_pin;               // From iomux328_inst of xlr8_iomux328.v
   logic        INT0_rcv;               // From iomux328_inst of xlr8_iomux328.v
   logic        INT1_rcv;               // From iomux328_inst of xlr8_iomux328.v
   logic        OC0A_enable;            // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic        OC0A_pin;               // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic        OC0B_enable;            // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic        OC0B_pin;               // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic        OC1A_enable;            // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic        OC1A_pin;               // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic        OC1B_enable;            // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic        OC1B_pin;               // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic        OC2A_enable;            // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic        OC2A_pin;               // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic        OC2B_enable;            // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic        OC2B_pin;               // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic        T0_pin;                 // From iomux328_inst of xlr8_iomux328.v
   logic        T1_pin;                 // From iomux328_inst of xlr8_iomux328.v
   logic        clk_adcref;             // From clocks_inst of xlr8_clocks.v
   logic        clk_64mhz;              // From clocks_inst of xlr8_clocks.v
   logic        clk_32mhz;              // From clocks_inst of xlr8_clocks.v
   logic        clk_16mhz;              // From clocks_inst of xlr8_clocks.v
   logic        clk_option2;            // From clocks_inst of xlr8_clocks.v
   logic        clk_option4;            // From clocks_inst of xlr8_clocks.v
   logic        clk_cpu;                // From clocks_inst of xlr8_clocks.v
   logic        clk_io;                 // From clocks_inst of xlr8_clocks.v
   logic [7:0]  core_ramadr_lo8;        // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic        core_rstn;              // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic [23:0] debug_bus;              // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic [15:0] dm_adr;                 // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic        dm_ce;                  // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic [7:0]  dm_dout;                // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic        dm_we;                  // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic [7:0]  dm_dout_rg;             // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic [1:0]  eimsk;                  // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic        en128khz;               // From clocks_inst of xlr8_clocks.v
   logic        en16mhz;                // From clocks_inst of xlr8_clocks.v
   logic        en1mhz;                 // From clocks_inst of xlr8_clocks.v
   logic [255:0] gprf;                   // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic         intosc_div1024;         // From clocks_inst of xlr8_clocks.v
   logic         intosc_div1024_en;      // From gpio_inst of xlr8_gpio.v
   logic         locked_adcref;          // From clocks_inst of xlr8_clocks.v
   logic         misoi;                  // From iomux328_inst of xlr8_iomux328.v
   logic         misoo;                  // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic         mosii;                  // From iomux328_inst of xlr8_iomux328.v
   logic         mosio;                  // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic [7:0]   msts_dbusout;           // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic [NUM_NEOPIXELS:1] neopixel_en;          // From neopixel_inst of xlr8_neopixel.v
   logic                   neopixel_out;           // From neopixel_inst of xlr8_neopixel.v
   logic [2:0]             pcie;                   // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic [23:0]            pcint_rcv;              // From iomux328_inst of xlr8_iomux328.v
   logic [23:0]            pcmsk;                  // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic [15:0]            pm_addr;                // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic                   pm_ce;                  // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic [15:0]            pm_core_rd_addr;        // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic [15:0]            pm_core_rd_data;        // From p_mem_inst of xlr8_p_mem.v
   logic [15:0]            pm_rd_data;             // From p_mem_inst of xlr8_p_mem.v
   logic                   pm_wr;                  // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic [15:0]            pm_wr_data;             // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic [5:0]             portb_ddrx;             // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic [5:0]             portb_pinx;             // From iomux328_inst of xlr8_iomux328.v
   logic [5:0]             portb_portx;            // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic [5:0]             portc_ddrx;             // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic [5:0]             portc_pinx;             // From iomux328_inst of xlr8_iomux328.v
   logic [5:0]             portc_portx;            // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic [7:0]             portd_ddrx;             // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic [7:0]             portd_pinx;             // From iomux328_inst of xlr8_iomux328.v
   logic [7:0]             portd_portx;            // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
`ifdef SNO_BOARD
   logic [5:0]             porta_pads;
   logic [5:0]             porta_ddrx;
   logic [5:0]             porta_pinx;
   logic [5:0]             porta_portx;
   logic                   porta_pcint;
   logic [5:0]             porte_pads;
   logic [5:0]             porte_ddrx;
   logic [5:0]             porte_pinx;
   logic [5:0]             porte_portx;
   logic                   porte_pcint;
   logic [5:0]             portg_pads;
   logic [5:0]             portg_ddrx;
   logic [5:0]             portg_pinx;
   logic [5:0]             portg_portx;
   logic                   portg_pcint;
`endif
   logic                   pwr_on_nrst;            // From clocks_inst of xlr8_clocks.v
   logic                   rst_flash_n;            // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic                   scki;                   // From iomux328_inst of xlr8_iomux328.v
   logic                   scko;                   // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic [NUM_SERVOS-1:0]  servos_en;             // From servo_inst of xlr8_servo.v
   logic [NUM_SERVOS-1:0]  servos_out;            // From servo_inst of xlr8_servo.v
   logic [NUM_QUADRATURES-1:0] quadratures_in_a; // to quadrature_inst of xlr8_quadrature.v
   logic [NUM_QUADRATURES-1:0] quadratures_in_b; // to quadrature_inst of xlr8_quadrature.v
   logic                       spe;                    // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic                       spimaster;              // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic                       ss_b;                   // From iomux328_inst of xlr8_iomux328.v
   logic [7:0]                 stgi_xf_neopixel_dbusout;// From neopixel_inst of xlr8_neopixel.v
   logic                       stgi_xf_neopixel_out_en;// From neopixel_inst of xlr8_neopixel.v
   logic [7:0]                 stgi_xf_servo_dbusout;  // From servo_inst of xlr8_servo.v
   logic                       stgi_xf_servo_out_en;   // From servo_inst of xlr8_servo.v
   logic [7:0]                 stgi_xf_quadrature_dbusout;  // From quadrature_inst of xlr8_quadrature.v
   logic                       stgi_xf_quadrature_out_en;   // From quadrature_inst of xlr8_quadrature.v
   logic [7:0]                 stgi_xf_pid_dbusout;    // From pid_inst of xlr8_pid.v
   logic                       stgi_xf_pid_out_en;     // From pid_inst of xlr8_pid.v
   logic                       twen;                   // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic                       uart_rx_en;             // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic                       uart_tx_en;             // From uc_top_wrp_vlog_inst of `XLR8_AVR_CORE_MODULE_NAME.v
   logic [NUM_PINS-1:0]        xb_ddoe;                // From xb_pinmux_inst of xlr8_xb_pinmux.v
   logic [NUM_PINS-1:0]        xb_ddov;                // From xb_pinmux_inst of xlr8_xb_pinmux.v
   logic [NUM_PINS-1:0]        xb_pvoe;                // From xb_pinmux_inst of xlr8_xb_pinmux.v
   logic [NUM_PINS-1:0]        xb_pvov;                // From xb_pinmux_inst of xlr8_xb_pinmux.v
   logic [NUM_PINS-1:0]        xb_pinx;                // To   xb_pinmux_inst of xlr8_xb_pinmux.v
   logic                       xck_rcv;                // From iomux328_inst of xlr8_iomux328.v
   logic [7:0]                 xlr8_clocks_dbusout;    // From clocks_inst of xlr8_clocks.v
   logic                       xlr8_clocks_out_en;     // From clocks_inst of xlr8_clocks.v
   logic [7:0]                 xlr8_gpio_dbusout;      // From gpio_inst of xlr8_gpio.v
   logic                       xlr8_gpio_out_en;       // From gpio_inst of xlr8_gpio.v
   logic [7:0]                 xb_openxlr8_dbusout;    // From gpio_inst of xlr8_gpio.v
   logic                       xb_openxlr8_out_en;     // From gpio_inst of xlr8_gpio.v
   // End of automatics
   
   wire [23:0]                 pcint_irq;
   wire                        PUD, SLEEP;
   wire [15:0]                 pm_din;
   wire [7:0]                  dm_din;
   reg                         reset_n_r;
   reg                         reset_n_rr;
   wire                        OC0_PWM0;
   wire                        OC1A_PWM1A;
   wire                        OC1B_PWM1B;
   wire                        OC2_PWM2;
   wire [7:0]                  interrupts;
   wire                        sdain,sclin,msdain,msclin;
   wire                        sdaout,sclout,msdaout,msclout;
   wire                        sdaen,sclen,msdaen,msclen;
   // XLR8 Interrupts
   wire [1:0]                  xlr8_irq; //        From xlr8_irq to core
   wire [1:0]                  xlr8_irq_ack; //    To xlr8_irq from core
   wire                        xb_openxlr8_irq; // From openxlr8 to xlr8_irq 
   wire                        xlr8_bi_irq; //     From builtin stuff to xlr8_irq
   //FP interface
   wire [5:0]                  io_arb_mux_adr;
   wire                        io_arb_mux_iore;
   wire                        io_arb_mux_iowe;
   wire [7:0]                  io_arb_mux_dbusout;
   wire [7:0]                  xlr8_irq_io_slv_dbusout;
   wire                        xlr8_irq_io_slv_out_en;
`ifdef HINJ_BOARD
   wire [7:0]                  hinj_gpio_io_slv_dbusout;
   wire                        hinj_gpio_io_slv_out_en;
   wire [7:0]                  hinj_bixb_io_slv_dbusout;
   wire                        hinj_bixb_io_slv_out_en;
   wire [7:0]                  hinj_pcint_io_slv_dbusout;
   wire                        hinj_pcint_io_slv_out_en;
   logic [5:0]                 hinj_gpio_pcint;
   logic [7:0]                 hinj_bi_pinx;
   logic                       hinj_bixb_pcint;
`endif
`ifdef SNO_BOARD
   wire [7:0]                  pport_a_io_slv_dbusout;
   wire [7:0]                  pport_e_io_slv_dbusout;
   wire [7:0]                  pport_g_io_slv_dbusout;
   wire                        pport_a_io_slv_out_en;
   wire                        pport_e_io_slv_out_en;
   wire                        pport_g_io_slv_out_en;
`endif
   wire [7:0]                  stgi_xf_io_slv_dbusout;
   wire                        stgi_xf_io_slv_out_en;
   wire [7:0]                  stgi_xf_float_dbusout;
   wire                        stgi_xf_float_out_en;
   wire [7:0]                  core_ramadr;
   wire                        core_ramre;
   wire                        core_ramwe;
   wire                        core_dm_sel;
   // connections for stgi_xf ports
   wire [31:0]                 xf_dataa;
   wire [31:0]                 xf_datab;
   wire [7:0]                  xf_en;
   wire [31:0]                 xf_p0_result;
   wire [31:0]                 xf_p1_result;
   wire [31:0]                 xf_p2_result;
   wire [31:0]                 xf_p3_result;
   wire [31:0]                 xf_p4_result;
   wire [31:0]                 xf_p5_result;
   wire [31:0]                 xf_p6_result;
   wire [31:0]                 xf_p7_result;
   logic [NUM_PINS-1:0]        xb_openxlr8_ddoe;
   logic [NUM_PINS-1:0]        xb_openxlr8_ddov;
   logic [NUM_PINS-1:0]        xb_openxlr8_pvoe;
   logic [NUM_PINS-1:0]        xb_openxlr8_pvov;
   logic [NUM_XBS-1:0][NUM_PINS-1:0] xbs_ddoe; // override data direction
   logic [NUM_XBS-1:0][NUM_PINS-1:0] xbs_ddov; // data direction value if overridden (1=out)
   logic [NUM_XBS-1:0][NUM_PINS-1:0] xbs_pvoe; // override output value
   logic [NUM_XBS-1:0][NUM_PINS-1:0] xbs_pvov; // output value if overridden

   //----------------------------------------------------------------------
   // Instance Name:  clocks_inst
   // Module Type:     xlr8_clocks
   //
   //----------------------------------------------------------------------
   xlr8_clocks #(
                 .CLOCK_SELECT           (CLOCK_SELECT),
                 .PRR_ADDR               (PRR_ADDR),
                 .PLL_SELECT             (PLL_SELECT))
   clocks_inst (// Not using these clock domains yet
                // Outputs
                .clk_io                  (clk_io),
                .clk_usart0              (),
                .clk_spi                 (),
                .clk_tim1                (),
                .clk_intosc              (),
                .clk_tim0                (),
                .clk_tim2                (),
                .clk_twi                 (),
                /*AUTOINST*/
                // Outputs
                .pwr_on_nrst             (pwr_on_nrst),
                .dbus_out                (xlr8_clocks_dbusout[7:0]), // Templated
                .io_out_en               (xlr8_clocks_out_en),    // Templated
                .locked_adcref           (locked_adcref),
                .clk_cpu                 (clk_cpu),
                .clk_adcref              (clk_adcref),
                .clkx4                   (clk_64mhz),
                .clkx2                   (clk_32mhz),
                .clkx1                   (clk_16mhz),
                .clk_option2             (clk_option2),
                .clk_option4             (clk_option4),
                .intosc_div1024          (intosc_div1024),
                .en16mhz                 (en16mhz),
                .en1mhz                  (en1mhz),
                .en128khz                (en128khz),
                // Inputs
                .Clock                   (Clock),
                .core_rstn               (core_rstn),
                .adr                     (io_arb_mux_adr[5:0]),   // Templated
                .dbus_in                 (io_arb_mux_dbusout[7:0]), // Templated
                .iore                    (io_arb_mux_iore),       // Templated
                .iowe                    (io_arb_mux_iowe),       // Templated
                .ramadr                  (core_ramadr_lo8[7:0]),  // Templated
                .ramre                   (core_ramre),            // Templated
                .ramwe                   (core_ramwe),            // Templated
                .dm_sel                  (core_dm_sel));          // Templated
   
   // IOs
   // On this board, the analog pins are inputs only and go right to the
   //   ADC; They don't have the other functions that ATMega328 has muxed to them
   assign PUD = 1'b0; // FIXME: should come from MCUCR register
   assign SLEEP = 1'b0; // FIXME: Add this
   wire                              pcie0,pcie1,pcie2,UMSEL,xcko,INT1_enable,INT0_enable;
   assign {UMSEL,xcko} = 2'h0;
   //ext and pinchange interrupt enables and masks (sourced from stgi_ext_int in uc_top)
   assign {pcie0,pcie1,pcie2} = pcie;
   assign {INT1_enable,INT0_enable} = eimsk;
   
   // Mux Xcelerator Block control of pins and send result into AVR io mux
   //   Intosc
   assign xbs_ddoe[0] = intosc_div1024_en << 8; // put intosc on PB0 so ICP function can measure it accurately
   assign xbs_ddov[0] = {NUM_PINS{1'b1}}; // force to be outputs
   assign xbs_pvoe[0] = xbs_ddoe[0];
   assign xbs_pvov[0] = intosc_div1024 << 8; // put intosc on PB0 so ICP function can measure it accurately
   //   Servo
   assign xbs_ddoe[1] = {NUM_PINS{1'b0}}; // Library still sets the data direction
   assign xbs_ddov[1] = {NUM_PINS{1'b0}};
   assign xbs_pvoe[1] = {{(NUM_PINS-NUM_SERVOS){1'b0}},servos_en[NUM_SERVOS-1:0]};
   assign xbs_pvov[1] = {{(NUM_PINS-NUM_SERVOS){1'b0}},servos_out[NUM_SERVOS-1:0]};
   //   NeoPixel
   assign xbs_ddoe[2] = {NUM_PINS{1'b0}}; // Library still sets the data direction
   assign xbs_ddov[2] = {NUM_PINS{1'b0}};
   assign xbs_pvoe[2] = {{(NUM_PINS-NUM_UNO_PINS){1'b0}},4'h0,neopixel_en[15:1],1'b0}; // currently support neopixels on pins 1-13, A0 & A1
   assign xbs_pvov[2] = {NUM_PINS{neopixel_out}};
   //   OpenXLR8
   assign xbs_ddoe[NUM_XBS-1] = xb_openxlr8_ddoe;
   assign xbs_ddov[NUM_XBS-1] = xb_openxlr8_ddov;
   assign xbs_pvoe[NUM_XBS-1] = xb_openxlr8_pvoe;
   assign xbs_pvov[NUM_XBS-1] = xb_openxlr8_pvov;
   
   // Currently do not have pullups on A0-A5, so no need to disconnect
   //  them when doing ADC read
   assign DIG_IO_OE = 6'hZ; // 0=disconnected, high-Z=connected
   //assign DIG_IO_OE[0] = adc_active[0] ? 1'b0 : 1'bz;
   //assign DIG_IO_OE[1] = adc_active[1] ? 1'b0 : 1'bz;
   //assign DIG_IO_OE[2] = adc_active[2] ? 1'b0 : 1'bz;
   //assign DIG_IO_OE[3] = adc_active[3] ? 1'b0 : 1'bz;
   //assign DIG_IO_OE[4] = adc_active[4] ? 1'b0 : 1'bz;
   //assign DIG_IO_OE[5] = adc_active[5] ? 1'b0 : 1'bz;

   // Temporarily just send some debug signals out
   assign JT9    = RESET_N;
   assign JT7    = core_rstn;
   assign JT6    = locked_adcref;
   assign JT5    = pwr_on_nrst;
   assign JT3    = rst_flash_n;
   assign JT1    = clk_cpu;
   // FIXME: these aren't hooked up yet
   assign SOIC7  = 1'bZ;
   assign SOIC6  = 1'bZ;
   assign SOIC5  = 1'bZ;
   assign SOIC3  = 1'bZ;
   assign SOIC2  = 1'bZ;
   assign SOIC1  = 1'bZ;


   //----------------------------------------------------------------------
   // Instance Name:  xb_pinmux_inst
   // Module Type:    xlr8_xb_pinmux
   //
   //----------------------------------------------------------------------
   xlr8_xb_pinmux #(.NUM_PINS           (NUM_PINS), // Digital 0-13 and AnaDig 0-5
                    .NUM_XBS            (NUM_XBS))  // Number of XB inputs to xb_pinmux
   xb_pinmux_inst (.clk            (clk_cpu), // clock is just used for assertions
                   .rstn           (rst_flash_n), // reset is just for assertions, logic works all the time
                   /*AUTOINST*/
                   // Outputs
                   .xb_ddoe        (xb_ddoe[NUM_PINS-1:0]),
                   .xb_ddov        (xb_ddov[NUM_PINS-1:0]),
                   .xb_pvoe        (xb_pvoe[NUM_PINS-1:0]),
                   .xb_pvov        (xb_pvov[NUM_PINS-1:0]),
                   // Inputs
                   .xbs_ddoe       (xbs_ddoe/*[NUM_XBS-1:0][NUM_PINS-1:0]*/),
                   .xbs_ddov       (xbs_ddov/*[NUM_XBS-1:0][NUM_PINS-1:0]*/),
                   .xbs_pvoe       (xbs_pvoe/*[NUM_XBS-1:0][NUM_PINS-1:0]*/),
                   .xbs_pvov       (xbs_pvov/*[NUM_XBS-1:0][NUM_PINS-1:0]*/));



   //----------------------------------------------------------------------
   // Instance Name:  xlr8_irq__inst
   // Module Type:    xlr8_irq
   //
   //----------------------------------------------------------------------
   xlr8_irq
     #(
       .XICR_Address (XICR_Address),
       .XIFR_Address (XIFR_Address),
       .XMSK_Address (XMSK_Address),
       .XACK_Address (XACK_Address),
       .WIDTH        (2)
       )
   xlr8_irq_inst
     (
      // Clock and Reset
      .rstn        (core_rstn),
      .clk         (clk_io),
      // I/O
      .adr         (io_arb_mux_adr),
      .dbus_in     (io_arb_mux_dbusout),
      .dbus_out    (xlr8_irq_io_slv_dbusout),
      .iore        (io_arb_mux_iore),
      .iowe        (io_arb_mux_iowe),
      .out_en      (xlr8_irq_io_slv_out_en),
      // DM
      .ramadr      (core_ramadr_lo8[7:0]),
      .ramre       (core_ramre),
      .ramwe       (core_ramwe),
      .dm_sel      (core_dm_sel),
      // IRQ stuff
      .x_int_in    ({xb_openxlr8_irq, xlr8_bi_irq}),
      .x_irq       (xlr8_irq),
      .x_irq_ack   (xlr8_irq_ack)
      );     

   //----------------------------------------------------------------------
   // Instance Name:  iomux328_inst
   // Module Type:    xlr8_iomux328
   //
   //----------------------------------------------------------------------
   xlr8_iomux328 iomux328_inst (// Inouts
                                .portb_pads     ({D13,D12,D11,D10,D9,D8}),
                                .portc_pads     ({A5,A4,A3,A2,A1,A0}),
`ifdef HINJ_BOARD
                                .portd_pads     ({D7,D6,D5,D4,D3,D2,D1,D0}),
`elsif SNO_BOARD
                                .portd_pads     ({D7,D6,D5,D4,D3,D2,D1,D0}),
                                .TX             (TX),
                                .RX             (RX),
`else // XLR8 Board
                                .portd_pads     ({D7,D6,D5,D4,D3,D2,TX,RX}),
`endif
                                .clk            (clk_cpu), // run this regardless of any sleep
                                // Inouts
                                .SDA            (SDA),
                                .SCL            (SCL),
                                /*AUTOINST*/
                                // Outputs
                                .portb_pinx     (portb_pinx[5:0]),
                                .portc_pinx     (portc_pinx[5:0]),
                                .portd_pinx     (portd_pinx[7:0]),
                                .pcint_rcv      (pcint_rcv[23:0]),
                                .scki           (scki),
                                .misoi          (misoi),
                                .mosii          (mosii),
                                .ss_b           (ss_b),
                                .ICP1_pin       (ICP1_pin),
                                .PIN13LED       (PIN13LED),
                                .sdain          (sdain),
                                .sclin          (sclin),
                                .I2C_ENABLE     (I2C_ENABLE),
                                .xck_rcv        (xck_rcv),
                                .T1_pin         (T1_pin),
                                .T0_pin         (T0_pin),
                                .INT1_rcv       (INT1_rcv),
                                .INT0_rcv       (INT0_rcv),
                                .RXD_rcv        (RXD_rcv),
                                // Inputs
                                .core_rstn      (core_rstn),
                                .PUD            (PUD),
                                .SLEEP          (SLEEP),
                                .ADCD           (ADCD[5:0]),
                                .portb_portx    (portb_portx[5:0]),
                                .portb_ddrx     (portb_ddrx[5:0]),
                                .portc_portx    (portc_portx[5:0]),
                                .portc_ddrx     (portc_ddrx[5:0]),
                                .portd_portx    (portd_portx[7:0]),
                                .portd_ddrx     (portd_ddrx[7:0]),
                                .xb_ddoe        (xb_ddoe[19:0]),
                                .xb_ddov        (xb_ddov[19:0]),
                                .xb_pvoe        (xb_pvoe[19:0]),
                                .xb_pvov        (xb_pvov[19:0]),
                                .xb_pinx        (xb_pinx[19:0]),
                                .pcint_irq      (pcmsk[23:0]),   // Templated
                                .pcie0          (pcie0),
                                .pcie1          (pcie1),
                                .pcie2          (pcie2),
                                .spe            (spe),
                                .spimaster      (spimaster),
                                .scko           (scko),
                                .misoo          (misoo),
                                .mosio          (mosio),
                                .OC2A_enable    (OC2A_enable),
                                .OC2A_pin       (OC2A_pin),
                                .OC1B_enable    (OC1B_enable),
                                .OC1B_pin       (OC1B_pin),
                                .OC1A_enable    (OC1A_enable),
                                .OC1A_pin       (OC1A_pin),
                                .twen           (twen),
                                .sdaout         (sdaout),
                                .sclout         (sclout),
                                .UMSEL          (UMSEL),
                                .xcko           (xcko),
                                .OC2B_enable    (OC2B_enable),
                                .OC2B_pin       (OC2B_pin),
                                .OC0B_enable    (OC0B_enable),
                                .OC0B_pin       (OC0B_pin),
                                .OC0A_enable    (OC0A_enable),
                                .OC0A_pin       (OC0A_pin),
                                .INT1_enable    (INT1_enable),
                                .INT0_enable    (INT0_enable),
                                .uart_tx_en     (uart_tx_en),
                                .TXD            (TXD),
                                .uart_rx_en     (uart_rx_en));


   //----------------------------------------------------------------------
   // Instance Name:  d_mem_inst
   // Module Type:    xlr8_d_mem
   //
   //----------------------------------------------------------------------
   // Data Memory (SRAM)
   xlr8_d_mem #(.dm_size(DM_SIZE))
   d_mem_inst(
              .cp2     (clk_cpu),
              .ce      (dm_ce),
              .address (dm_adr),
              .din     (dm_dout),
              .dout    (dm_din),
              .we      (dm_we)
              );


   //----------------------------------------------------------------------
   // Instance Name:  p_mem_inst
   // Module Type:    xlr8_p_mem
   //
   //----------------------------------------------------------------------
   // program memory

   xlr8_p_mem #(.pm_size(pm_size))
   p_mem_inst
     (
      .clk     (clk_cpu),
      /*AUTOINST*/
      // Outputs
      .pm_core_rd_data                     (pm_core_rd_data[15:0]),
      .pm_rd_data                          (pm_rd_data[15:0]),
      // Inputs
      .rst_flash_n                         (rst_flash_n),
      .pm_core_rd_addr                     (pm_core_rd_addr[15:0]),
      .pm_ce                               (pm_ce),
      .pm_wr                               (pm_wr),
      .pm_wr_data                          (pm_wr_data[15:0]),
      .pm_addr                             (pm_addr[15:0])
      );


   //sjp// Delete to try passing as a parameter   
       //sjp//   assign xb_info = APP_XB0_ENABLE[31:0];


   //----------------------------------------------------------------------
   // Instance Name:  uc_top_wrp_vlog_inst
   // Module Type:    xlr8_atmega328clone
   //
   //----------------------------------------------------------------------

`ifndef XLR8_AVR_CORE_MODULE_NAME
 `define XLR8_AVR_CORE_MODULE_NAME xlr8_atmega328clone
`endif
   
   `XLR8_AVR_CORE_MODULE_NAME
     #(/*AUTOINSTPARAM*/
       // Parameters
       .DESIGN_CONFIG        (DESIGN_CONFIG),
       .UFM_ADR_WIDTH        (UFM_ADR_WIDTH),
       .PM_REAL_SIZE         (PM_REAL_SIZE),
       .UFM_BC_WIDTH         (UFM_BC_WIDTH))
   
   uc_top_wrp_vlog_inst
     (
      .nrst        (RESET_N),
      .clk         (clk_cpu ),
      .param_app_xb0_enable (APP_XB0_ENABLE),
`ifdef HINJ_BOARD
      // Feed in the Wifi GPIO pins for Port C
      .pcint_rcv   ({pcint_rcv[23:16], 2'b00, hinj_bi_pinx[5:0], pcint_rcv[7:0]}),
`else // For XLR8 One and Sno
      .pcint_rcv   (pcint_rcv[23:0]),
`endif
      // UART related
      .rxd         (RXD_rcv),
      .txd         (TXD),
      /*AUTOINST*/
      // Outputs
      .core_rstn            (core_rstn),
      .rst_flash_n          (rst_flash_n),
      .portb_portx          (portb_portx[5:0]),
      .portb_ddrx           (portb_ddrx[5:0]),
      .portc_portx          (portc_portx[5:0]),
      .portc_ddrx           (portc_ddrx[5:0]),
      .portd_portx          (portd_portx[7:0]),
      .portd_ddrx           (portd_ddrx[7:0]),
      .ADCD                 (ADCD[5:0]),
      .ANA_UP               (ANA_UP),
      .OC0A_pin             (OC0A_pin),
      .OC0B_pin             (OC0B_pin),
      .OC1A_pin             (OC1A_pin),
      .OC1B_pin             (OC1B_pin),
      .OC2A_pin             (OC2A_pin),
      .OC2B_pin             (OC2B_pin),
      .OC0A_enable          (OC0A_enable),
      .OC0B_enable          (OC0B_enable),
      .OC1A_enable          (OC1A_enable),
      .OC1B_enable          (OC1B_enable),
      .OC2A_enable          (OC2A_enable),
      .OC2B_enable          (OC2B_enable),
      .uart_rx_en           (uart_rx_en),
      .uart_tx_en           (uart_tx_en),
      .misoo                (misoo),
      .mosio                (mosio),
      .scko                 (scko),
      .spe                  (spe),
      .spimaster            (spimaster),
      .twen                 (twen),
      .sdaout               (sdaout),
      .sclout               (sclout),
      .pcmsk                (pcmsk[23:0]),
      .pcie                 (pcie[2:0]),
      .eimsk                (eimsk[1:0]),
      .xlr8_irq             (xlr8_irq), //     From xlr8_irq
      .xlr8_irq_ack         (xlr8_irq_ack), // To xlr8_irq
      .pm_ce                (pm_ce),
      .pm_wr                (pm_wr),
      .pm_wr_data           (pm_wr_data[15:0]),
      .pm_addr              (pm_addr[15:0]),
      .pm_core_rd_addr      (pm_core_rd_addr[15:0]),
      .dm_adr               (dm_adr[15:0]),
      .dm_dout              (dm_dout[7:0]),
      .dm_ce                (dm_ce),
      .dm_we                (dm_we),
      .dm_dout_rg           (dm_dout_rg[7:0]),
      .core_ramadr_lo8      (core_ramadr_lo8[7:0]),
      .core_ramre           (core_ramre),
      .core_ramwe           (core_ramwe),
      .core_dm_sel          (core_dm_sel),
      .io_arb_mux_adr       (io_arb_mux_adr[5:0]),
      .io_arb_mux_iore      (io_arb_mux_iore),
      .io_arb_mux_iowe      (io_arb_mux_iowe),
      .io_arb_mux_dbusout   (io_arb_mux_dbusout[7:0]),
      .msts_dbusout         (msts_dbusout[7:0]),
      .gprf                 (gprf[8*32-1:0]),
      .debug_bus            (debug_bus[23:0]),
      // Inputs
      .en16mhz              (en16mhz),
      .en128khz             (en128khz),
      .clk_adcref           (clk_adcref),
      .locked_adcref        (locked_adcref),
      .pwr_on_nrst          (pwr_on_nrst),
      .portb_pinx           (portb_pinx[5:0]),
      .portc_pinx           (portc_pinx[5:0]),
      .portd_pinx           (portd_pinx[7:0]),
      .T0_pin               (T0_pin),
      .T1_pin               (T1_pin),
      .ICP1_pin             (ICP1_pin),
      .misoi                (misoi),
      .mosii                (mosii),
      .scki                 (scki),
      .ss_b                 (ss_b),
      .sdain                (sdain),
      .sclin                (sclin),
      .pm_rd_data           (pm_rd_data[15:0]),
      .pm_core_rd_data      (pm_core_rd_data[15:0]),
      .dm_din               (dm_din[7:0]),
      .stgi_xf_io_slv_dbusout(stgi_xf_io_slv_dbusout[7:0]),
      //sjp// Change the following lines becuase I'm trying to pass APP0 as parameter
      //sjp//                          .stgi_xf_io_slv_out_en(stgi_xf_io_slv_out_en),
      //sjp//                          .xb_info              (xb_info[31:0]));
      .stgi_xf_io_slv_out_en(stgi_xf_io_slv_out_en)
      );
   


   assign stgi_xf_io_slv_dbusout = stgi_xf_float_out_en      ? stgi_xf_float_dbusout      :
                                   stgi_xf_neopixel_out_en   ? stgi_xf_neopixel_dbusout   :
                                   stgi_xf_servo_out_en      ? stgi_xf_servo_dbusout      :
                                   stgi_xf_quadrature_out_en ? stgi_xf_quadrature_dbusout :
                                   stgi_xf_pid_out_en        ? stgi_xf_pid_dbusout        :
                                   xb_openxlr8_out_en        ? xb_openxlr8_dbusout        :
                                   xlr8_clocks_out_en        ? xlr8_clocks_dbusout        :
                                   xlr8_irq_io_slv_out_en    ? xlr8_irq_io_slv_dbusout    :
`ifdef HINJ_BOARD
                                   hinj_gpio_io_slv_out_en   ? hinj_gpio_io_slv_dbusout   :
                                   hinj_bixb_io_slv_out_en   ? hinj_bixb_io_slv_dbusout   :
                                   hinj_pcint_io_slv_out_en  ? hinj_pcint_io_slv_dbusout  :
`endif
`ifdef SNO_BOARD
                                   pport_a_io_slv_out_en     ? pport_a_io_slv_dbusout     :
                                   pport_e_io_slv_out_en     ? pport_e_io_slv_dbusout     :
                                   pport_g_io_slv_out_en     ? pport_g_io_slv_dbusout     :
`endif
                                   xlr8_gpio_dbusout;

   assign stgi_xf_io_slv_out_en  = stgi_xf_float_out_en      ||
                                   stgi_xf_neopixel_out_en   || 
                                   stgi_xf_servo_out_en      ||
                                   stgi_xf_quadrature_out_en || 
                                   stgi_xf_pid_out_en        || 
                                   xb_openxlr8_out_en        ||
                                   xlr8_clocks_out_en        || 
                                   xlr8_irq_io_slv_out_en    || 
`ifdef HINJ_BOARD
                                   hinj_gpio_io_slv_out_en   ||
                                   hinj_bixb_io_slv_out_en   ||
                                   hinj_pcint_io_slv_out_en   ||
`endif
`ifdef SNO_BOARD
                                   pport_a_io_slv_out_en     || 
                                   pport_e_io_slv_out_en     ||
                                   pport_g_io_slv_out_en     ||
`endif
                                   xlr8_gpio_out_en;


   //----------------------------------------------------------------------
   // Instance Name:  gpio_inst
   // Module Type:    xlr8_gpio
   //
   //----------------------------------------------------------------------
   // GPIO module has the AVR gpio registers as well as a few optional
   //  read only registers that could be used to pass configuration
   //  information to the software. Setting address to zero eliminates
   //  the register

   xlr8_gpio #(.GPIOR0_ADDR             (GPIOR0_Address),
               .GPIOR1_ADDR             (GPIOR1_Address),
               .GPIOR2_ADDR             (GPIOR2_Address),
               .READREG0_ADDR           (6'h0),
               .READREG1_ADDR           (6'h0),
               .READREG2_ADDR           (6'h0),
               .READREG3_ADDR           (6'h0),
               .READREG0_VAL            (8'h0),
               .READREG1_VAL            (8'h0),
               .READREG2_VAL            (8'h0),
               .READREG3_VAL            (8'h0),
               /*AUTOINSTPARAM*/
               // Parameters
               .DESIGN_CONFIG             (DESIGN_CONFIG_WITH_DMEM),
               .APP_XB0_ENABLE            (APP_XB0_ENABLE),
               .CLKSPD_ADDR               (CLKSPD_ADDR))
   gpio_inst (/*AUTOINST*/
              // Outputs
              .dbus_out                  (xlr8_gpio_dbusout[7:0]), // Templated
              .io_out_en                 (xlr8_gpio_out_en),      // Templated
              .intosc_div1024_en         (intosc_div1024_en),
              // Inputs
              .clk                       (clk_cpu),               // Templated
              .rstn                      (core_rstn),             // Templated
              .clken                     (1'b1),                  // Templated
              .adr                       (io_arb_mux_adr[5:0]),   // Templated
              .dbus_in                   (io_arb_mux_dbusout[7:0]), // Templated
              .iore                      (io_arb_mux_iore),       // Templated
              .iowe                      (io_arb_mux_iowe),       // Templated
              .ramadr                    (core_ramadr_lo8[7:0]),  // Templated
              .ramre                     (core_ramre),            // Templated
              .ramwe                     (core_ramwe),            // Templated
              .dm_sel                    (core_dm_sel));          // Templated
   
`ifdef SNO_BOARD

   // ======================= START of Extra Sno Board Ports ======================

   // porta_pads = {D27,D26,D25,D24,D23,D22};
   // porte_pads = {D33,D32,D31,D30,D29,D28};
   // portg_pads = {D39,D38,D37,D36,D35,D34};
   
   // === PORT A === PORT A === PORT A === PORT A === PORT A === PORT A ===
   
   // Although ATMega328p has 8 bit registers for portA,
   //  we'll just implement 6 bit registers

   //----------------------------------------------------------------------
   // Instance Name:  portmux_a_inst
   // Module Type:    xlr8_portmux
   //
   //----------------------------------------------------------------------
   xlr8_portmux 
     #(
       .WIDTH        (6)
       )
   portmux_a_inst
     (
      // Clock and Reset
      .rstn        (core_rstn),
      .clk         (clk_io),
      // Inputs
      .port_portx  (porta_portx),
      .port_ddrx   (porta_ddrx),
      .xb_ddoe     (xb_ddoe[25:20]),
      .xb_ddov     (xb_ddov[25:20]),
      .xb_pvoe     (xb_pvoe[25:20]),
      .xb_pvov     (xb_pvov[25:20]),
      // Outputs
      .port_pads   ({D27,D26,D25,D24,D23,D22}),
      .port_pinx   (porta_pinx),
      .xb_pinx     (xb_pinx[25:20])
      );

   //----------------------------------------------------------------------
   // Instance Name:  pport_a_inst
   // Module Type:    xlr8_avr_port
   //
   //----------------------------------------------------------------------
   xlr8_avr_port 
     #(
       .PORTX_ADDR   (PORTA_Address),
       .DDRX_ADDR    (DDRA_Address),
       .PINX_ADDR    (PINA_Address),
       .PCMSK_ADDR   (MSKA_Address),
       .WIDTH        (6))
   pport_a_inst
     (
      // Clock and Reset
      .rstn        (core_rstn),
      .clk         (clk_io),
      .clken       (1'b1),
      // I/O
      .adr         (io_arb_mux_adr),
      .dbus_in     (io_arb_mux_dbusout),
      .dbus_out    (pport_a_io_slv_dbusout),
      .iore        (io_arb_mux_iore),
      .iowe        (io_arb_mux_iowe),
      .io_out_en   (pport_a_io_slv_out_en),
      // DM
      .ramadr      (core_ramadr_lo8[7:0]),
      .ramre       (core_ramre),
      .ramwe       (core_ramwe),
      .dm_sel      (core_dm_sel),
      // External connection
      .portx       (porta_portx),
      .ddrx        (porta_ddrx),
      .pinx        (porta_pinx),
      .pcifr_set   (porta_pcint) //                     Pin Change Int to xlr8_pcint
      );
   
   // === PORT E === PORT E === PORT E === PORT E === PORT E === PORT E ===
   
   // Although ATMega328p has 8 bit registers for portE,
   //  we'll just implement 6 bit registers

   //----------------------------------------------------------------------
   // Instance Name:  portmux_e_inst
   // Module Type:    xlr8_portmux
   //
   //----------------------------------------------------------------------
   xlr8_portmux 
     #(
       .WIDTH        (6)
       )
   portmux_e_inst
     (
      // Clock and Reset
      .rstn        (core_rstn),
      .clk         (clk_io),
      // Inputs
      .port_portx  (porte_portx),
      .port_ddrx   (porte_ddrx),
      .xb_ddoe     (xb_ddoe[31:26]),
      .xb_ddov     (xb_ddov[31:26]),
      .xb_pvoe     (xb_pvoe[31:26]),
      .xb_pvov     (xb_pvov[31:26]),
      // Outputs
      .port_pads   ({D33,D32,D31,D30,D29,D28}),
      .port_pinx   (porte_pinx),
      .xb_pinx     (xb_pinx[31:26])
      );

   //----------------------------------------------------------------------
   // Instance Name:  pport_e_inst
   // Module Type:    xlr8_avr_port
   //
   //----------------------------------------------------------------------
   xlr8_avr_port 
     #(
       .PORTX_ADDR   (PORTE_Address),
       .DDRX_ADDR    (DDRE_Address),
       .PINX_ADDR    (PINE_Address),
       .PCMSK_ADDR   (MSKE_Address),
       .WIDTH        (6))
   pport_e_inst
     (
      // Clock and Reset
      .rstn        (core_rstn),
      .clk         (clk_io),
      .clken       (1'b1),
      // I/O
      .adr         (io_arb_mux_adr),
      .dbus_in     (io_arb_mux_dbusout),
      .dbus_out    (pport_e_io_slv_dbusout),
      .iore        (io_arb_mux_iore),
      .iowe        (io_arb_mux_iowe),
      .io_out_en   (pport_e_io_slv_out_en),
      // DM
      .ramadr      (core_ramadr_lo8[7:0]),
      .ramre       (core_ramre),
      .ramwe       (core_ramwe),
      .dm_sel      (core_dm_sel),
      // External connection
      .portx       (porte_portx),
      .ddrx        (porte_ddrx),
      .pinx        (porte_pinx),
      .pcifr_set   (porte_pcint) //                     Pin Change Int to xlr8_pcint
      );
   
   // === PORT G === PORT G === PORT G === PORT G === PORT G === PORT G ===
   
   // Although ATMega328p has 8 bit registers for portG,
   //  we'll just implement 6 bit registers

   //----------------------------------------------------------------------
   // Instance Name:  portmux_g_inst
   // Module Type:    xlr8_portmux
   //
   //----------------------------------------------------------------------
   xlr8_portmux 
     #(
       .WIDTH        (6)
       )
   portmux_g_inst
     (
      // Clock and Reset
      .rstn        (core_rstn),
      .clk         (clk_io),
      // Inputs
      .port_portx  (portg_portx),
      .port_ddrx   (portg_ddrx),
      .xb_ddoe     (xb_ddoe[37:32]),
      .xb_ddov     (xb_ddov[37:32]),
      .xb_pvoe     (xb_pvoe[37:32]),
      .xb_pvov     (xb_pvov[37:32]),
      // Outputs
      .port_pads   ({D39,D38,D37,D36,D35,D34}),
      .port_pinx   (portg_pinx),
      .xb_pinx     (xb_pinx[37:32])
      );

   //----------------------------------------------------------------------
   // Instance Name:  pport_g_inst
   // Module Type:    xlr8_avr_port
   //
   //----------------------------------------------------------------------
   xlr8_avr_port 
     #(
       .PORTX_ADDR   (PORTG_Address),
       .DDRX_ADDR    (DDRG_Address),
       .PINX_ADDR    (PING_Address),
       .PCMSK_ADDR   (MSKG_Address),
       .WIDTH        (6))
   pport_g_inst
     (
      // Clock and Reset
      .rstn        (core_rstn),
      .clk         (clk_io),
      .clken       (1'b1),
      // I/O
      .adr         (io_arb_mux_adr),
      .dbus_in     (io_arb_mux_dbusout),
      .dbus_out    (pport_g_io_slv_dbusout),
      .iore        (io_arb_mux_iore),
      .iowe        (io_arb_mux_iowe),
      .io_out_en   (pport_g_io_slv_out_en),
      // DM
      .ramadr      (core_ramadr_lo8[7:0]),
      .ramre       (core_ramre),
      .ramwe       (core_ramwe),
      .dm_sel      (core_dm_sel),
      // External connection
      .portx       (portg_portx),
      .ddrx        (portg_ddrx),
      .pinx        (portg_pinx),
      .pcifr_set   (portg_pcint) //                     Pin Change Int to xlr8_pcint
      );
   
   //----------------------------------------------------------------------
   // Instance Name:  sno_pcint_inst
   // Module Type:    xlr8_pcint
   //
   //----------------------------------------------------------------------
   xlr8_pcint
     #(
       .XICR_Address (SPCICR_Address),
       .XIFR_Address (SPCIFR_Address),
       .XMSK_Address (SPCIMSK_Address),
       .WIDTH        (3)
       )
   sno_pcint_inst
     (
      // Clock and Reset
      .rstn         (core_rstn),
      .clk          (clk_io),
      // I/O
      .adr          (io_arb_mux_adr),
      .dbus_in      (io_arb_mux_dbusout),
      .dbus_out     (sno_pcint_io_slv_dbusout),
      .iore         (io_arb_mux_iore),
      .iowe         (io_arb_mux_iowe),
      .out_en       (sno_pcint_io_slv_out_en),
      // DM
      .ramadr       (core_ramadr_lo8[7:0]),
      .ramre        (core_ramre),
      .ramwe        (core_ramwe),
      .dm_sel       (core_dm_sel),
      // 
      .x_int_in     ({portg_pcint,porte_pcint,porta_pcint}),
      .x_irq        (xlr8_bi_irq),
      .x_irq_ack    (3'h0) // Don't use acks here
      );
   

`endif //  `ifdef SNO_BOARD
   // ======================= END of Extra Sno Board Ports ======================
   
   
   // ======================= START of Extra Hinj Board Ports ======================
`ifdef HINJ_BOARD
   //----------------------------------------------------------------------
   // Instance Name:  hinj_gpio_inst
   // Module Type:    xlr8_hinj_gpio
   //
   //----------------------------------------------------------------------
   xlr8_hinj_gpio 
     #(
       .NUM_PINS       (NUM_PINS),
       .NUM_UNO_PINS   (NUM_UNO_PINS),
       .PORTBT_Address (PORTBT_Address),
       .DDRBT_Address  (DDRBT_Address),
       .PINBT_Address  (PINBT_Address),
       .PORTX1_Address (PORTX1_Address),
       .DDRX1_Address  (DDRX1_Address),
       .PINX1_Address  (PINX1_Address),
       .PORTX0_Address (PORTX0_Address),
       .DDRX0_Address  (DDRX0_Address),
       .PINX0_Address  (PINX0_Address),
       .PORTSW_Address (PORTSW_Address),
       .DDRSW_Address  (DDRSW_Address),
       .PINSW_Address  (PINSW_Address),
       .PORTLD_Address (PORTLD_Address),
       .DDRLD_Address  (DDRLD_Address),
       .PINLD_Address  (PINLD_Address),
       .PORTG4_Address (PORTG4_Address),
       .DDRG4_Address  (DDRG4_Address),
       .PING4_Address  (PING4_Address),
       .PORTG3_Address (PORTG3_Address),
       .DDRG3_Address  (DDRG3_Address),
       .PING3_Address  (PING3_Address),
       .PORTG2_Address (PORTG2_Address),
       .DDRG2_Address  (DDRG2_Address),
       .PING2_Address  (PING2_Address),
       .PORTG1_Address (PORTG1_Address),
       .DDRG1_Address  (DDRG1_Address),
       .PING1_Address  (PING1_Address),
       .PORTG0_Address (PORTG0_Address),
       .DDRG0_Address  (DDRG0_Address),
       .PING0_Address  (PING0_Address),
       .PORTPD_Address (PORTPD_Address),
       .DDRPD_Address  (DDRPD_Address),
       .PINPD_Address  (PINPD_Address),
       .PORTPC_Address (PORTPC_Address),
       .DDRPC_Address  (DDRPC_Address),
       .PINPC_Address  (PINPC_Address),
       .PORTPB_Address (PORTPB_Address),
       .DDRPB_Address  (DDRPB_Address),
       .PINPB_Address  (PINPB_Address),
       .PORTPA_Address (PORTPA_Address),
       .DDRPA_Address  (DDRPA_Address),
       .PINPA_Address  (PINPA_Address),
       .MSKX1_Address  (MSKX1_Address),
       .MSKX0_Address  (MSKX0_Address),
       .MSKG4_Address  (MSKG4_Address),
       .MSKG3_Address  (MSKG3_Address),
       .MSKG2_Address  (MSKG2_Address),
       .MSKG1_Address  (MSKG1_Address),
       .MSKG0_Address  (MSKG0_Address),
       .MSKPD_Address  (MSKPD_Address),
       .MSKPC_Address  (MSKPC_Address),
       .MSKPB_Address  (MSKPB_Address),
       .MSKPA_Address  (MSKPA_Address)
       )
   hinj_gpio_inst 
     (
      // Clock and Reset
      .rstn        (core_rstn),
      .clk         (clk_io),
      // I/O
      .adr         (io_arb_mux_adr),
      .dbus_in     (io_arb_mux_dbusout),
      .dbus_out    (hinj_gpio_io_slv_dbusout),
      .iore        (io_arb_mux_iore),
      .iowe        (io_arb_mux_iowe),
      .io_out_en   (hinj_gpio_io_slv_out_en),
      // DM
      .ramadr      (core_ramadr_lo8[7:0]),
      .ramre       (core_ramre),
      .ramwe       (core_ramwe),
      .dm_sel      (core_dm_sel),
      .xb_ddoe     (xb_ddoe[NUM_PINS-1:NUM_UNO_PINS]),
      .xb_ddov     (xb_ddov[NUM_PINS-1:NUM_UNO_PINS]),
      .xb_pvoe     (xb_pvoe[NUM_PINS-1:NUM_UNO_PINS]),
      .xb_pvov     (xb_pvov[NUM_PINS-1:NUM_UNO_PINS]),
      // Outputs
      .port_pads   ({b[2:1], //                     PORTBT
                     xbee_d04,xbee_d07,xbee_d09, // PORTX1
                     xbee_d05,xbee_d06,xbee_d03,xbee_d02,xbee_d01,
                     xbee_d00,xbee_d08, //          PORTX0
                     xbee_d11,xbee_d10,xbee_resetn,xbee_d12,xbee_d14,xbee_d13,
                     sw[7:0], //                    PORTSW
                     led[7:0], //                   PORTLD
                     g[38:3], //                    PORTG[4-0]
                     p8[4:1],p7[4:1], //            PORTPD
                     p6[4:1],p5[4:1], //            PORTPC
                     p4[4:1],p3[4:1], //            PORTPB
                     p2[4:1],p1[4:1] //             PORTPA
                     }),
      .xb_pinx     (xb_pinx[NUM_PINS-1:NUM_UNO_PINS]),
      .pcint       (hinj_gpio_pcint) // Hinj GPIO Pin Change Interrupts to hinj_pcint
      );

   
   //----------------------------------------------------------------------
   // Instance Name:  hinj_bixb_inst
   // Module Type:    xlr8_hinj_bixb
   //
   //----------------------------------------------------------------------
   xlr8_hinj_bixb 
     #(
       .DESIGN_CONFIG  (DESIGN_CONFIG_WITH_DMEM),
       .WIFI_SPCR_ADDR (WIFI_SPCR_ADDR),
       .WIFI_SPSR_ADDR (WIFI_SPSR_ADDR),
       .WIFI_SPDR_ADDR (WIFI_SPDR_ADDR),
       .PORTBI_Address (PORTBI_Address),
       .DDRBI_Address  (DDRBI_Address),
       .PINBI_Address  (PINBI_Address),
       .ETH_SPCR_ADDR  (ETH_SPCR_ADDR),
       .ETH_SPSR_ADDR  (ETH_SPSR_ADDR),
       .ETH_SPDR_ADDR  (ETH_SPDR_ADDR),
       .SD_SPCR_ADDR   (SD_SPCR_ADDR),
       .SD_SPSR_ADDR   (SD_SPSR_ADDR),
       .SD_SPDR_ADDR   (SD_SPDR_ADDR),
       .MSKBI_Address  (MSKBI_Address)
       )
   hinj_bixb_inst 
     (
      // Clock and Reset
      .rstn         (core_rstn),
      .clk          (clk_io),
      // I/O
      .adr          (io_arb_mux_adr),
      .dbus_in      (io_arb_mux_dbusout),
      .dbus_out     (hinj_bixb_io_slv_dbusout),
      .iore         (io_arb_mux_iore),
      .iowe         (io_arb_mux_iowe),
      .io_out_en    (hinj_bixb_io_slv_out_en),
      // DM
      .ramadr       (core_ramadr_lo8[7:0]),
      .ramre        (core_ramre),
      .ramwe        (core_ramwe),
      .dm_sel       (core_dm_sel),
      .wf_port_pads ({wifi_sck,wifi_ss,wifi_mosi,wifi_miso,wifi_irq,wifi_txd,
                     wifi_rxd,wifi_sda,wifi_scl,wifi_io1,wifi_io3,wifi_io4,
                     wifi_io5,wifi_io6,wifi_enable,wifi_wake,wifi_resetn,wifi_cfg}),
      .et_port_pads ({eth_sck,eth_ss,eth_mosi,eth_miso,eth_int,eth_resetn}),
      .sd_port_pads ({sd_sck,sd_ss,sd_mosi,sd_miso}),
      .bi_pinx      (hinj_bi_pinx), // to core/ext_int module in place of port C
      .pcint        (hinj_bixb_pcint)
      );

   //----------------------------------------------------------------------
   // Instance Name:  hinj_pcint_inst
   // Module Type:    xlr8_pcint
   //
   //----------------------------------------------------------------------
   xlr8_pcint
     #(
       .XICR_Address (HPCICR_Address),
       .XIFR_Address (HPCIFR_Address),
       .XMSK_Address (HPCIMSK_Address),
       .WIDTH        (7)
       )
   hinj_pcint_inst
     (
      // Clock and Reset
      .rstn         (core_rstn),
      .clk          (clk_io),
      // I/O
      .adr          (io_arb_mux_adr),
      .dbus_in      (io_arb_mux_dbusout),
      .dbus_out     (hinj_pcint_io_slv_dbusout),
      .iore         (io_arb_mux_iore),
      .iowe         (io_arb_mux_iowe),
      .out_en       (hinj_pcint_io_slv_out_en),
      // DM
      .ramadr       (core_ramadr_lo8[7:0]),
      .ramre        (core_ramre),
      .ramwe        (core_ramwe),
      .dm_sel       (core_dm_sel),
      // 
      .x_int_in     ({hinj_bixb_pcint,hinj_gpio_pcint}),
      .x_irq        (xlr8_bi_irq),
      .x_irq_ack    (7'h0) // Don't use acks here
      );
   
     
`endif
   
   // ======================= END of Extra Hinj Board Ports ======================
   
   
   generate
      if (USE_SERVO_UNIT) begin: u_xb_servo
         //----------------------------------------------------------------------
         // Instance Name:  servo_inst
         // Module Type:    xlr8_servo
         //
         //----------------------------------------------------------------------
         xlr8_servo #(.NUM_SERVOS             (NUM_SERVOS),
                      .SVCR_ADDR              (SVCR_ADDR),
                      .SVPWL_ADDR             (SVPWL_ADDR),
                      .SVPWH_ADDR             (SVPWH_ADDR))
         servo_inst (/*AUTOINST*/
                     // Outputs
                     .dbus_out              (stgi_xf_servo_dbusout[7:0]), // Templated
                     .io_out_en             (stgi_xf_servo_out_en),  // Templated
                     .servos_en             (servos_en[NUM_SERVOS-1:0]),
                     .servos_out            (servos_out[NUM_SERVOS-1:0]),
                     // Inputs
                     .clk                   (clk_cpu),               // Templated
                     .en1mhz                (en1mhz),
                     .rstn                  (core_rstn),             // Templated
                     .adr                   (io_arb_mux_adr[5:0]),   // Templated
                     .dbus_in               (io_arb_mux_dbusout[7:0]), // Templated
                     .iore                  (io_arb_mux_iore),       // Templated
                     .iowe                  (io_arb_mux_iowe),       // Templated
                     .ramadr                (core_ramadr_lo8[7:0]),  // Templated
                     .ramre                 (core_ramre),            // Templated
                     .ramwe                 (core_ramwe),            // Templated
                     .dm_sel                (core_dm_sel));          // Templated
      end else begin : no_xb_servo
         assign stgi_xf_servo_dbusout = 8'h0;
         assign stgi_xf_servo_out_en = 1'b0;
         assign servos_en = {NUM_SERVOS{1'b0}};
         assign servos_out = {NUM_SERVOS{1'b0}};
      end
   endgenerate

   genvar iii;
   generate
      if (USE_QUADRATURE_UNIT) begin: u_xb_quadrature
         for (iii=0; iii < NUM_QUADRATURES; iii = iii + 1)
           begin : u_xb_quadrature_for
              assign quadratures_in_a[iii]   = xb_pinx[(iii+1)*2];
              assign quadratures_in_b[iii]   = xb_pinx[(iii+1)*2+1];
           end

         //----------------------------------------------------------------------
         // Instance Name:  quadrature_inst
         // Module Type:    xlr8_quadrature
         //
         //----------------------------------------------------------------------
         xlr8_quadrature #(.NUM_QUADRATURES         (NUM_QUADRATURES),
                           .QECR_ADDR               (QECR_ADDR),
                           .QECNT0_ADDR             (QECNT0_ADDR),
                           .QECNT1_ADDR             (QECNT1_ADDR),
                           .QECNT2_ADDR             (QECNT2_ADDR),
         //                .QECNT3_ADDR             (QECNT3_ADDR),
                           .QERAT0_ADDR             (QERAT0_ADDR),
                           .QERAT1_ADDR             (QERAT1_ADDR))
         //                .QERAT2_ADDR             (QERAT2_ADDR),
         //                .QERAT3_ADDR             (QERAT3_ADDR))
         quadrature_inst (/*AUTOINST*/
                          // Outputs
                          .dbus_out              (stgi_xf_quadrature_dbusout[7:0]), // Templated
                          .io_out_en             (stgi_xf_quadrature_out_en),  // Templated
                          .quadratures_en        (),                      // currently unused - pinmux
                          .quad_in_a               (quadratures_in_a[NUM_QUADRATURES-1:0]),
                          .quad_in_b               (quadratures_in_b[NUM_QUADRATURES-1:0]),
                          // Inputs
                          .clk                   (clk_cpu),               // Templated
                          .en1mhz                (en1mhz),
                          .rstn                  (core_rstn),             // Templated
                          .adr                   (io_arb_mux_adr[5:0]),   // Templated
                          .dbus_in               (io_arb_mux_dbusout[7:0]), // Templated
                          .iore                  (io_arb_mux_iore),       // Templated
                          .iowe                  (io_arb_mux_iowe),       // Templated
                          .ramadr                (core_ramadr_lo8[7:0]),  // Templated
                          .ramre                 (core_ramre),            // Templated
                          .ramwe                 (core_ramwe),            // Templated
                          .dm_sel                (core_dm_sel));          // Templated
      end else begin : no_xb_quadrature
         assign stgi_xf_quadrature_dbusout = 8'h0;
         assign stgi_xf_quadrature_out_en = 1'b0;
         // assign quadratures_in_a = {NUM_QUADRATURES{1'b0}};
         // assign quadratures_in_b = {NUM_QUADRATURES{1'b0}};
      end
   endgenerate

   generate
      if (USE_PID_UNIT) begin: u_xb_pid

         //----------------------------------------------------------------------
         // Instance Name:  pid_inst
         // Module Type:    xlr8_pid
         //
         //----------------------------------------------------------------------
         xlr8_pid #(.NUM_PIDS             (NUM_PIDS),
                    .PIDCR_ADDR           (PIDCR_ADDR),
                    .PID_KD_H_ADDR        (PID_KD_H_ADDR),
                    .PID_KD_L_ADDR        (PID_KD_L_ADDR),
                    .PID_KI_H_ADDR        (PID_KI_H_ADDR),
                    .PID_KI_L_ADDR        (PID_KI_L_ADDR),
                    .PID_KP_H_ADDR        (PID_KP_H_ADDR),
                    .PID_KP_L_ADDR        (PID_KP_L_ADDR),
                    .PID_SP_H_ADDR        (PID_SP_H_ADDR),
                    .PID_SP_L_ADDR        (PID_SP_L_ADDR),
                    .PID_PV_H_ADDR        (PID_PV_H_ADDR),
                    .PID_PV_L_ADDR        (PID_PV_L_ADDR),
                    .PID_OP_H_ADDR        (PID_OP_H_ADDR),
                    .PID_OP_L_ADDR        (PID_OP_L_ADDR))
         pid_inst (/*AUTOINST*/
                   // Outputs
                   .dbus_out              (stgi_xf_pid_dbusout[7:0]), // Templated
                   .io_out_en             (stgi_xf_pid_out_en),  // Templated
                   .pids_en               (),                      // currently unused - pinmux
                   // Inputs
                   .clk                   (clk_cpu),               // Templated
                   .en1mhz                (en1mhz),
                   .rstn                  (core_rstn),             // Templated
                   .adr                   (io_arb_mux_adr[5:0]),   // Templated
                   .dbus_in               (io_arb_mux_dbusout[7:0]), // Templated
                   .iore                  (io_arb_mux_iore),       // Templated
                   .iowe                  (io_arb_mux_iowe),       // Templated
                   .ramadr                (core_ramadr_lo8[7:0]),  // Templated
                   .ramre                 (core_ramre),            // Templated
                   .ramwe                 (core_ramwe),            // Templated
                   .dm_sel                (core_dm_sel));          // Templated
      end else begin : no_xb_pid
         assign stgi_xf_pid_dbusout = 8'h0;
         assign stgi_xf_pid_out_en = 1'b0;
      end
   endgenerate


   generate
      if (USE_NEOPIXEL_UNIT) begin: u_xb_neopixel

         //----------------------------------------------------------------------
         // Instance Name:  neopixel_inst
         // Module Type:    xlr8_neopixel
         //
         //----------------------------------------------------------------------
         xlr8_neopixel #(.NUM_NEOPIXELS         (NUM_NEOPIXELS),
                         .NEOCR_ADDR            (NEOCR_ADDR),
                         .NEOD2_ADDR            (NEOD2_ADDR),
                         .NEOD1_ADDR            (NEOD1_ADDR),
                         .NEOD0_ADDR            (NEOD0_ADDR))
         neopixel_inst (/*AUTOINST*/
                        // Outputs
                        .dbus_out           (stgi_xf_neopixel_dbusout[7:0]), // Templated
                        .io_out_en          (stgi_xf_neopixel_out_en), // Templated
                        .neopixel_en        (neopixel_en[NUM_NEOPIXELS:1]),
                        .neopixel_out       (neopixel_out),
                        // Inputs
                        .clk                (clk_cpu),               // Templated
                        .en16mhz            (en16mhz),
                        .rstn               (core_rstn),             // Templated
                        .adr                (io_arb_mux_adr[5:0]),   // Templated
                        .dbus_in            (io_arb_mux_dbusout[7:0]), // Templated
                        .iore               (io_arb_mux_iore),       // Templated
                        .iowe               (io_arb_mux_iowe),       // Templated
                        .ramadr             (core_ramadr_lo8[7:0]),  // Templated
                        .ramre              (core_ramre),            // Templated
                        .ramwe              (core_ramwe),            // Templated
                        .dm_sel             (core_dm_sel));          // Templated
      end else begin : no_xb_neopixel
         assign stgi_xf_neopixel_dbusout = 8'h0;
         assign stgi_xf_neopixel_out_en = 1'b0;
         assign neopixel_en = {NUM_NEOPIXELS{1'b0}};
         assign neopixel_out = 1'b0;
      end
   endgenerate

   generate
      if (USE_FP_UNIT) begin: u_xb_float
         //----------------------------------------------------------------------
         // Instance Name:  xf_inst
         // Module Type:    xlr8_xf
         //
         //----------------------------------------------------------------------
         xlr8_xf #(// Parameters
                   .STGI_XF_PRELOAD_DELTA     (8'd3), // operands are set at least this many cycle before cmd is sent
                   .STGI_XF_P0_LATENCY        (8'd0), // compare latency=1, 0=not implemented
                   .STGI_XF_P1_LATENCY        (8'd1), // add latency
                   .STGI_XF_P2_LATENCY        (8'd2), // mult latency
                   .STGI_XF_P3_LATENCY        (8'd32),// div latency
                   .STGI_XF_P4_LATENCY        (8'd0), // 0=not implemented
                   .STGI_XF_P5_LATENCY        (8'd0), // sqrt latency=6, 0=not implemented
                   .STGI_XF_P6_LATENCY        (8'd0), // fix2float latency=1, 0=not implemented
                   .STGI_XF_P7_LATENCY        (8'd0), // float2fix latency=1, 0=not implemented
                   /*AUTOINSTPARAM*/
                   // Parameters
                   .STGI_XF_CTRL_ADR          (STGI_XF_CTRL_ADR),
                   .STGI_XF_STATUS_ADR        (STGI_XF_STATUS_ADR),
                   .STGI_XF_R0_ADR            (STGI_XF_R0_ADR),
                   .STGI_XF_R1_ADR            (STGI_XF_R1_ADR),
                   .STGI_XF_R2_ADR            (STGI_XF_R2_ADR),
                   .STGI_XF_R3_ADR            (STGI_XF_R3_ADR))
         xf_inst(.ireset       (core_rstn),
                 .cp2          (clk_cpu),
                 // AVR Control
                 .adr          (io_arb_mux_adr),
                 .dbus_in      (io_arb_mux_dbusout),
                 .dbus_out     (stgi_xf_float_dbusout),
                 .iore         (io_arb_mux_iore),
                 .iowe         (io_arb_mux_iowe),
                 .out_en       (stgi_xf_float_out_en),
                 .core_ramadr  (core_ramadr_lo8),
                 .core_ramre   (core_ramre),
                 .core_ramwe   (core_ramwe),
                 .core_dm_sel  (core_dm_sel),
                 .gprf         (gprf),
                 .xf_dataa     (xf_dataa),
                 .xf_datab     (xf_datab),
                 .xf_en        (xf_en),
                 .xf_p0_result (xf_p0_result),
                 .xf_p1_result (xf_p1_result),
                 .xf_p2_result (xf_p2_result),
                 .xf_p3_result (xf_p3_result),
                 .xf_p4_result (xf_p4_result),
                 .xf_p5_result (xf_p5_result),
                 .xf_p6_result (xf_p6_result),
                 .xf_p7_result (xf_p7_result)
                 );

         //-------------------------------------------------------
         // Instantiate the Altera Floating Point functional units
         //-------------------------------------------------------
         
         assign xf_p0_result = 8'h0;
         
         //----------------------------------------------------------------------
         // Instance Name:  float_add_inst
         // Module Type:    xlr8_float_add1
         //
         //----------------------------------------------------------------------
         // FP ADD/SUB
         xlr8_float_add1
           float_add_inst (
                           .clk (clk_cpu),
                           .areset (!core_rstn),
                           .a (xf_dataa),
                           .b (xf_datab),
                           .en (1'b1),
                           .q (xf_p1_result)
                           );

         //----------------------------------------------------------------------
         // Instance Name:  float_mult_inst
         // Module Type:    xlr8_float_mult2
         //
         //----------------------------------------------------------------------
         // FP MULT
         xlr8_float_mult2
           float_mult_inst (
                            .clk ( clk_cpu ),
                            .areset (!core_rstn),
                            .en (1'b1),
                            .a (xf_dataa),
                            .b (xf_datab),
                            .q (xf_p2_result)
                            );

         //----------------------------------------------------------------------
         // Instance Name:  fdiv_inst
         // Module Type:    xlr8_fdiv
         //
         //----------------------------------------------------------------------
         // FP DIV
         xlr8_fdiv
           fdiv_inst (
                      .clk ( clk_cpu ),
                      .rst_n (core_rstn),
                      .clken (1'b1),
                      .start (xf_en[3]),
                      .numer (xf_dataa),
                      .denom (xf_datab),
                      .q_out (xf_p3_result)
                      );

         assign xf_p4_result = 8'h0; // placeholder for ???
         assign xf_p5_result = 8'h0; // placeholder for sqrt
         assign xf_p6_result = 8'h0; // placeholder for convert2float
         assign xf_p7_result = 8'h0; // placeholder for convert2fixed
      end else begin : no_xb_float
         assign stgi_xf_float_dbusout = 8'h0;
         assign stgi_xf_float_out_en = 1'b0;
      end
   endgenerate

   //----------------------------------------------------------------------
   // Instance Name:  xb_openxlr8_inst
   // Module Type:    openxlr8
   //
   // The xb_openxlr8_inst provides a place for users to add thier own XBs
   // without having to edit the xlr8_top, which can be intimidating
   // and dangerous.
   //
   //----------------------------------------------------------------------
   openxlr8
     #(
       .DESIGN_CONFIG     (DESIGN_CONFIG_WITH_DMEM),
       .NUM_PINS          (NUM_PINS),
       .OX8ICR_Address    (OX8ICR_Address),
       .OX8IFR_Address    (OX8IFR_Address),
       .OX8MSK_Address    (OX8MSK_Address)       
       )
   xb_openxlr8_inst 
     (// Clock and reset
      .clk                (clk_cpu),            
      .rstn               (core_rstn),          
      .clk_64mhz          (clk_64mhz),
      .clk_32mhz          (clk_32mhz),
      .clk_16mhz          (clk_16mhz),
      .clk_option2        (clk_option2),
      .clk_option4        (clk_option4),
      .en16mhz            (en16mhz),
      .en1mhz             (en1mhz),
      .en128khz           (en128khz),
      // I/O
      .adr                (io_arb_mux_adr[5:0]),
      .dbus_in            (io_arb_mux_dbusout[7:0]),
      .dbus_out           (xb_openxlr8_dbusout[7:0]),
      .io_out_en          (xb_openxlr8_out_en), 
      .iore               (io_arb_mux_iore),     
      .iowe               (io_arb_mux_iowe),     
      // DM
      .ramadr             (core_ramadr_lo8[7:0]),
      .ramre              (core_ramre),
      .ramwe              (core_ramwe),
      .dm_sel             (core_dm_sel),
      .dm_dout_rg         (dm_dout_rg),
      // Others
      .gprf               (gprf),
      .xb_pinx            (xb_pinx),
      .JT9                (JT9),
      .JT7                (JT7),
      .JT6                (JT6),
      .JT5                (JT5),
      .JT3                (JT3),
      .JT1                (JT1),
      // For iomux
      .xb_ddoe            (xb_openxlr8_ddoe),
      .xb_ddov            (xb_openxlr8_ddov),
      .xb_pvoe            (xb_openxlr8_pvoe),
      .xb_pvov            (xb_openxlr8_pvov),
      // Interrupts
      .xb_irq             (xb_openxlr8_irq)
      );

`ifdef STGI_ASSERT_ON
   ERROR_running_slow_d_mem_latency: assert property
   (@(posedge clk_cpu) disable iff (!rst_flash_n)
    !dm_int_sram_read_ws);
`endif

endmodule: xlr8_alorium_top

// Local Variables:
// verilog-library-flags:("-y ../core/ -y ../../rtl/top/ -y ../../rtl/xb/xlr8_float -y ../../rtl/xb/xlr8_servo -y ../../rtl/xb/xlr8_quadrature -y ../../rtl/xb/xlr8_neopixel -y ../../ip/int_osc/int_osc/synthesis")
// eval:(verilog-read-defines)
// End:
