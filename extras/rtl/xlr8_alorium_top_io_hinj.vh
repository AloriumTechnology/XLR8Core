//===========================================================================
//  Copyright(c) Alorium Technology Group Inc., 2017
//  ALL RIGHTS RESERVED
//===========================================================================
//
// File name:  : xlr8_alorium_top_io_hinj.vh 
// Author      : Stebe Phillips
// Contact     : support@aloriumtech.com
// Description : 
//
//   Module I/O definitions for Hinj board version of the 
//   xlr8_alorium_top module. Included by `ifdef HINJ_BOARD in 
//   xlr8_alorium_top
//
//===========================================================================

//module xlr8_alorium_top // COMMENT THIS LINE OUT! Only uncomment for auto-indenting
//  (                     // COMMENT THIS LINE OUT! Only uncomment for auto-indenting
    //Arduino I/Os
    inout              SCL,
    inout              SDA,
    // The D13..D2,TX,RX go through level shift on board before getting to pins
    inout              D13,D12,D11,D10,D9,D8, // Port B
    inout              D7,D6,D5,D4,D3,D2,D1,D0, // Port D
    output             PIN13LED,
    // A[5:0] are not used as Digital outputs on Hinj and these are
    // not connected to pins in the hinj_top.qsf
    inout              A5,A4,A3,A2,A1,A0,
    // The JT signals are not connected to pins on Hinj
    inout              JT9, // external pullup. JTAG function is TDI
    inout              JT7, // no JTAG function
    inout              JT6, // no JTAG function
    inout              JT5, // external pullup. JTAG function is TMS
    inout              JT3, // JTAG function TDO
    inout              JT1, // external pulldown, JTAG function is TCK


// FIXME: The below section has been temporarily commented out until
//        functionality for it is created

    // Additional interfaces required for Hinj Dev Board
    // WiFi Interface 
    inout              wifi_irq, //    WiFi SPI Interrupt
    inout              wifi_sck, //    WiFi SPI Clock
    inout              wifi_ss, //     WiFi SPI Slave Select
    inout              wifi_mosi, //   WiFi SPI Data Out
    inout              wifi_miso, //   WiFi SPI Data In
    inout              wifi_txd, //    WiFi UART TX
    inout              wifi_rxd, //    WiFi UART RX
    inout              wifi_sda, //    WiFi I2C SDA
    inout              wifi_scl, //    WiFi I2C SCL
    inout              wifi_io1, //    WiFi IO1
    inout              wifi_io3, //    WiFi IO3
    inout              wifi_io4, //    WiFi IO4
    inout              wifi_io5, //    WiFi IO5
    inout              wifi_io6, //    WiFi IO6
    inout              wifi_enable, // WiFi Enable
    inout              wifi_wake, //   WiFi Wake
    inout              wifi_resetn, // WiFi Reset
    inout              wifi_cfg, //    WiFi Config
    // Ethernet Interface
    inout              eth_int, //    Ethernet SPI Interrupt
    inout              eth_sck, //    Ethernet SPI SCK
    inout              eth_ss, //     Ethernet SPI Slave Select (eth_ncs on board schematics)
    inout              eth_mosi, //   Ethernet SPI Data Out
    inout              eth_miso, //   Ethernet SPI Data In
    inout              eth_resetn, // Ethernet SPI reset
    // SD Card Interface
    inout              sd_sck, //  SD SPI Clock
    inout              sd_ss, //   SD Card SPI Slave Select (sd_cs on board schematics)
    inout              sd_mosi, // SD Card SPI Data Out
    inout              sd_miso, // SD Card SPI Data In
    // GPIO Connector
    inout [38:3]       g, // pins 1,2,39,40 are power/gnd
    // PMOD A Interface
    inout  [4:1]  p1, // Physical PMOD: Connector A, Row 1, Pin 1-4;  Logical: PMOD 1, Pin 1-4
    //                 GND // Physical PMOD: Connector A, Row 1, Pin 5;    Logical: PMOD 1, Pin 5
    //                 VDD // Physical PMOD: Connector A, Row 1, Pin 6;    Logical: PMOD 1, Pin 6
    inout  [4:1]  p2, // Physical PMOD: Connector A, Row 2, Pin 7-10; Logical: PMOD 2, Pin 1-4
    //                 GND // Physical PMOD: Connector A, Row 2, Pin 11;   Logical: PMOD 2, Pin 5
    //                 VDD // Physical PMOD: Connector A, Row 2, Pin 12;   Logical: PMOD 2, Pin 6

    // PMOD B Interface
    inout  [4:1]  p3, // Physical PMOD: Connector B, Row 1, Pin 1-4;  Logical: PMOD 3, Pin 1-4
    //                 GND // Physical PMOD: Connector B, Row 1, Pin 5;    Logical: PMOD 3, Pin 5
    //                 VDD // Physical PMOD: Connector B, Row 1, Pin 6;    Logical: PMOD 3, Pin 6
    inout  [4:1]  p4, // Physical PMOD: Connector B, Row 2, Pin 7-10; Logical: PMOD 4, Pin 1-4
    //                 GND // Physical PMOD: Connector B, Row 2, Pin 11;   Logical: PMOD 4, Pin 5
    //                 VDD // Physical PMOD: Connector B, Row 2, Pin 12;   Logical: PMOD 4, Pin 6

    // PMOD C Interface
    inout  [4:1]  p5, // Physical PMOD: Connector C, Row 1, Pin 1-4;  Logical: PMOD 5, Pin 1-4
    //                 GND // Physical PMOD: Connector C, Row 1, Pin 5;    Logical: PMOD 5, Pin 5
    //                 VDD // Physical PMOD: Connector C, Row 1, Pin 6;    Logical: PMOD 5, Pin 6
    inout  [4:1]  p6, // Physical PMOD: Connector C, Row 2, Pin 7-10; Logical: PMOD 6, Pin 1-4
    //                 GND // Physical PMOD: Connector C, Row 2, Pin 11;   Logical: PMOD 6, Pin 5
    //                 VDD // Physical PMOD: Connector C, Row 2, Pin 12;   Logical: PMOD 6, Pin 6

    // PMOD D Interface
    inout  [4:1]  p7, // Physical PMOD: Connector D, Row 1, Pin 1-4;  Logical: PMOD 7, Pin 1-4
    //                 GND // Physical PMOD: Connector D, Row 1, Pin 5;    Logical: PMOD 7, Pin 5
    //                 VDD // Physical PMOD: Connector D, Row 1, Pin 6;    Logical: PMOD 7, Pin 6
    inout  [4:1]  p8, // Physical PMOD: Connector D, Row 2, Pin 7-10; Logical: PMOD 8, Pin 1-4
    //                 GND // Physical PMOD: Connector D, Row 2, Pin 11;   Logical: PMOD 8, Pin 5
    //                 VDD // Physical PMOD: Connector D, Row 2, Pin 12;   Logical: PMOD 8, Pin 6

    // XBee Interface 
    //                           //     Pin  1: VCC
    inout              xbee_d13, //     Pin  2: DIO13/DOUT
    inout              xbee_d14, //     Pin  3: DIO14/DIN/nCONFIG
    inout              xbee_d12, //     Pin  4: DIO12/SPI_MISO
    inout              xbee_resetn, //  Pin  5: nRESET  
    inout              xbee_d10, //     Pin  6: DIO10/RSSI PWM/PWM0
    inout              xbee_d11, //     Pin  7: DIO11/PWM1
    //                                  Pin  8: Reserved
    inout              xbee_d08, //     Pin  9: DIO8/nDTR/SLEEP_RQ
    //                                  Pin 10: GND
    inout              xbee_d04, //     Pin 11: DIO4/SPI_MOSI
    inout              xbee_d07, //     Pin 12: DIO7/nCTS
    inout              xbee_d09, //     Pin 13: DIO9/ON_nSLEEP
    //                                  Pin 14: VREF
    inout              xbee_d05, //     Pin 15: DIO5/ASSOCIATE
    inout              xbee_d06, //     Pin 16: DIO6/nRTS
    inout              xbee_d03, //     Pin 17: DIO3/AD3/SPI_nSSEL
    inout              xbee_d02, //     Pin 18: DIO2/ad2/SPI_CLK 
    inout              xbee_d01, //     Pin 19: DIO1/AD1/SPI_nATTN
    inout              xbee_d00, //     Pin 20: DIO0/AD0/CB
    // Switches
    inout [7:0]        sw,
    // LEDs
    inout [7:0]        led,
    // Buttons
    inout [2:1]        b,

// FIXME: The above section has been temporarily commented out until
//        functionality for it is created

                       
     //Clock and Reset
    input              Clock, // 16MHz
    input              RESET_N
//    );    // COMMENT THIS LINE OUT! Only uncomment for auto-indenting
//endmodule // COMMENT THIS LINE OUT! Only uncomment for auto-indenting






                       

/////////////////////////////////////////////////////////////////////////////                       
// NOTE: The followig are the old Style declarations for the
// PMOD. Just putting here in case we decide to change back to them for
// some reason. If you see these here sometime in the future, feel
// free to delete them.
//                       
//    // PMOD A Interface
//    inout              p1_1, // Physical PMOD: Connector A, Row 1, Pin 1;   Logical: PMOD 1, Pin  1
//    inout              p1_2, // Physical PMOD: Connector A, Row 1, Pin 2;   Logical: PMOD 1, Pin  2
//    inout              p1_3, // Physical PMOD: Connector A, Row 1, Pin 3;   Logical: PMOD 1, Pin  3
//    inout              p1_4, // Physical PMOD: Connector A, Row 1, Pin 4;   Logical: PMOD 1, Pin  4
//    inout              p2_1, // Physical PMOD: Connector A, Row 2, Pin 7;   Logical: PMOD 2, Pin  1
//    inout              p2_2, // Physical PMOD: Connector A, Row 2, Pin 8;   Logical: PMOD 2, Pin  2
//    inout              p2_3, // Physical PMOD: Connector A, Row 2, Pin 9;   Logical: PMOD 2, Pin  3
//    inout              p2_4, // Physical PMOD: Connector A, Row 2, Pin 10;  Logical: PMOD 2, Pin  4
//    // PMOD B Interface
//    inout              p3_1, // Physical PMOD: Connector B, Row 1, Pin 1;   Logical: PMOD 3, Pin  1
//    inout              p3_2, // Physical PMOD: Connector B, Row 1, Pin 2;   Logical: PMOD 3, Pin  2
//    inout              p3_3, // Physical PMOD: Connector B, Row 1, Pin 3;   Logical: PMOD 3, Pin  3
//    inout              p3_4, // Physical PMOD: Connector B, Row 1, Pin 4;   Logical: PMOD 3, Pin  4
//    //                 GND   // Physical PMOD: Connector B, Row 1, Pin 5;   Logical: PMOD 3, Pin  5
//    //                 VDD   // Physical PMOD: Connector B, Row 1, Pin 6;   Logical: PMOD 3, Pin  6
//    inout              p4_1, // Physical PMOD: Connector B, Row 2, Pin 7;   Logical: PMOD 4, Pin  1
//    inout              p4_2, // Physical PMOD: Connector B, Row 2, Pin 8;   Logical: PMOD 4, Pin  2
//    inout              p4_3, // Physical PMOD: Connector B, Row 2, Pin 9;   Logical: PMOD 4, Pin  3
//    inout              p4_4, // Physical PMOD: Connector B, Row 2, Pin 10;  Logical: PMOD 4, Pin  4
//    //                 GND   // Physical PMOD: Connector B, Row 2, Pin 11;  Logical: PMOD 4, Pin  5
//    //                 VDD   // Physical PMOD: Connector B, Row 2, Pin 12;  Logical: PMOD 4, Pin  6
//    // PMOD C Interface
//    inout              p5_1, // Physical PMOD: Connector C, Row 1, Pin 1;   Logical: PMOD 5, Pin  1
//    inout              p5_2, // Physical PMOD: Connector C, Row 1, Pin 2;   Logical: PMOD 5, Pin  2
//    inout              p5_3, // Physical PMOD: Connector C, Row 1, Pin 3;   Logical: PMOD 5, Pin  3
//    inout              p5_4, // Physical PMOD: Connector C, Row 1, Pin 4;   Logical: PMOD 5, Pin  4
//    //                 GND   // Physical PMOD: Connector C, Row 1, Pin 5;   Logical: PMOD 5, Pin  5
//    //                 VDD   // Physical PMOD: Connector C, Row 1, Pin 6;   Logical: PMOD 5, Pin  6
//    inout              p6_1, // Physical PMOD: Connector C, Row 2, Pin 7;   Logical: PMOD 6, Pin  1
//    inout              p6_2, // Physical PMOD: Connector C, Row 2, Pin 8;   Logical: PMOD 6, Pin  2
//    inout              p6_3, // Physical PMOD: Connector C, Row 2, Pin 9;   Logical: PMOD 6, Pin  3
//    inout              p6_4, // Physical PMOD: Connector C, Row 2, Pin 10;  Logical: PMOD 6, Pin  4
//    //                 GND   // Physical PMOD: Connector C, Row 2, Pin 11;  Logical: PMOD 6, Pin  5
//    //                 VDD   // Physical PMOD: Connector C, Row 2, Pin 12;  Logical: PMOD 6, Pin  6
//    // PMOD D Interface
//    inout              p7_1, // Physical PMOD: Connector D, Row 1, Pin 1;   Logical: PMOD 7, Pin  1
//    inout              p7_2, // Physical PMOD: Connector D, Row 1, Pin 2;   Logical: PMOD 7, Pin  2
//    inout              p7_3, // Physical PMOD: Connector D, Row 1, Pin 3;   Logical: PMOD 7, Pin  3
//    inout              p7_4, // Physical PMOD: Connector D, Row 1, Pin 4;   Logical: PMOD 7, Pin  4
//    //                 GND   // Physical PMOD: Connector D, Row 1, Pin 5;   Logical: PMOD 7, Pin  5
//    //                 VDD   // Physical PMOD: Connector D, Row 1, Pin 6;   Logical: PMOD 7, Pin  6
//    inout              p8_1, // Physical PMOD: Connector D, Row 2, Pin 7;   Logical: PMOD 8, Pin  1
//    inout              p8_2, // Physical PMOD: Connector D, Row 2, Pin 8;   Logical: PMOD 8, Pin  2
//    inout              p8_3, // Physical PMOD: Connector D, Row 2, Pin 9;   Logical: PMOD 8, Pin  3
//    inout              p8_4, // Physical PMOD: Connector D, Row 2, Pin 10;  Logical: PMOD 8, Pin  4
//    //                 GND   // Physical PMOD: Connector D, Row 2, Pin 11;  Logical: PMOD 8, Pin  5
//    //                 VDD   // Physical PMOD: Connector D, Row 2, Pin 12;  Logical: PMOD 8, Pin  6
//    //
