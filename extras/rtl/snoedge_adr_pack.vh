//===========================================================================
//  Copyright(c) Alorium Technology Group Inc., 2015
//  ALL RIGHTS RESERVED
//===========================================================================
//
// File name:  : sno_adr_pack.vh
// Author      : Steve Phillips
// Contact     : support@aloriumtech.com
// Description : 
// 
// AVR address constants (localparams) for Sno board
//
// **************************************************************************
// Designed by Ruslan Lepetenok
// **************************************************************************
//===========================================================================

//---------------------------------------------------------------------------
// ATMega328 Registers 
//---------------------------------------------------------------------------
//
// Register addresses that are not specific to the Sno board are
// commented out. Those that are not commented out are specific
// addresses required for the Sno board.
//
// Some that are commented out are used by the Base Arduino and XLR8
// functionality. These will have a description of thier use and the
// actual uncommented localparam statement for them can be found in
// the avr_adr_pack.vh file
//
// The rest that are commented out are marked UNUSED or
// RESERVED. These can be used for XBs but the localparam statements
// for those should be in the xb_adr_pack.vh file
//
//---------------------------------------------------------------------------
localparam PINA_Address          = 8'h00; // Input Pins           Port A ------------------------------SNO
localparam DDRA_Address          = 8'h01; // Data Direction Regis Port A ------------------------------SNO
localparam PORTA_Address         = 8'h02; // Data Register        Port A-------------------------------SNO
// localparam PINB_Address       = 6'h03; // Input Pins           Port B
// localparam DDRB_Address       = 6'h04; // Data Direction Regis Port B
// localparam PORTB_Address      = 6'h05; // Data Register        Port B
// localparam PINC_Address       = 6'h06; // Input Pins           Port C
// localparam DDRC_Address       = 6'h07; // Data Direction Regis Port C
// localparam PORTC_Address      = 6'h08; // Data Register        Port C
// localparam PIND_Address       = 6'h09; // Input Pins           Port D
// localparam DDRD_Address       = 6'h0A; // Data Direction Regis Port D
// localparam PORTD_Address      = 6'h0B; // Data Register        Port D
localparam PINE_Address          = 8'h0C; // Input Pins           Port E placeholder ------------------SNO
localparam DDRE_Address          = 8'h0D; // Data Direction Regis Port E placeholde -------------------SNO
localparam PORTE_Address         = 8'h0E; // Data Register        Port E placeholder ------------------SNO
// localparam UNUSED             = 6'h0F; // --UNUSED--
// localparam STGI_XF_CTRL_ADR   = 6'h10; // XLR8 FLoating Point XB Control ---------------------------XLR8
// localparam STGI_XF_STATUS_ADR = 6'h11; // XLR8 Floating Point XB Status ----------------------------XLR8
localparam PING_Address          = 8'h12; // Input Pins           Port G ------------------------------SNO
localparam DDRG_Address          = 8'h13; // Data Direction Regis Port G ------------------------------SNO
localparam PORTG_Address         = 8'h14; // Data Register        Port G ------------------------------SNO
// localparam TIFR0_Address      = 6'h15; // Timer/Counter Interrupt Flag Register
// localparam TIFR1_Address      = 6'h16; // Timer/Counter Interrupt Flag Register
// localparam TIFR2_Address      = 6'h17; // Timer/Counter Interrupt Flag Register
// localparam TIFR3_Address      = 6'h18; // TIFR3 (reserved in spec but unused) 
// localparam TIFR4_Address      = 6'h19; // TIFR4 (reserved in spec but unused)
// localparam UNUSED             = 6'h1A; // --UNUSED--
// localparam PCIFR_Address      = 6'h1B; // Pin Change Interrupt Flag Register
// localparam EIFR_Address       = 6'h1C; // External Interrupt Flag Register
// localparam EIMSK_Address      = 6'h1D; // External Interrupt Mask Register
// localparam GPIOR0_Address     = 6'h1E; // General Purpose I/O Register
// localparam EECR_Address       = 6'h1F; // EEPROM Control Register
// localparam EEDR_Address       = 6'h20; // EEPROM Data Register
// localparam EEARL_Address      = 6'h21; // EEPROM Address Register(Low)
// localparam EEARH_Address      = 6'h22; // EEPROM Address Register(High)
// localparam GTCCR_Address      = 6'h23; // GTCCR
// localparam TCCR0A_Address     = 6'h24; // Timer/Counter 0 Control Register
// localparam TCCR0B_Address     = 6'h25; // Timer/Counter 0 Control Register
// localparam TCNT0_Address      = 6'h26; // Timer/Counter 0
// localparam OCR0A_Address      = 6'h27; // Timer/Counter 0 Output Compare Register
// localparam OCR0B_Address      = 6'h28; // Timer/Counter 0 Output Compare Register
// localparam CLKSPD_ADDR        = 6'h29; // XLR8 desired speed select for UART
// localparam GPIOR1_Address     = 6'h2A; // General Purpose I/O Register
// localparam GPIOR2_Address     = 6'h2B; // General Purpose I/O Register
// localparam SPCR_Address       = 6'h2C; // SPI Control Register
// localparam SPSR_Address       = 6'h2D; // SPI Status Register
// localparam SPDR_Address       = 6'h2E; // SPI I/O Data Register
// localparam RESERVED           = 6'h2F; // --RESERVED (328PB)--
// localparam ACSR_Address       = 6'h30; // Analog Comparator Control and Status Register
localparam MSKA_Address          = 8'h31; // SNO: Port A Interrupt Mask -------------------------------SNO
localparam MSKE_Address          = 8'h32; // SNO: Port E Interrupt Mask -------------------------------SNO
localparam MSKG_Address          = 8'h33; // SNO: Port G Interrupt Mask -------------------------------SNO
// localparam MCUSR_Address      = 6'h34; // MCU general Control and Status Register
// localparam MCUCR_Address      = 6'h35; // MCU general Control Register
// localparam UNUSED             = 6'h36; // --UNUSED--
// localparam SPMCSR_Address     = 6'h37; // Store Program Memory Control and Status Register
// localparam STGI_XF_R0_ADR     = 6'h38; // XLR8 Floating Point XB Result, Byte 0 (low order) --------XLR8
// localparam STGI_XF_R1_ADR     = 6'h39; // XLR8 Floating Point XB Result, Byte 1 --------------------XLR8
// localparam STGI_XF_R2_ADR     = 6'h3A; // XLR8 Floating Point XB Result, Byte 2 --------------------XLR8
// localparam STGI_XF_R3_ADR     = 6'h3B; // XLR8 Floating Point XB Result, Byte 3 (hi order)----------XLR8
// localparam EIND_Address       = 6'h3C; // EIND - Reserved for larger PMEM space
// localparam SPL_Address        = 6'h3D; // Stack Pointer(Low)
// localparam SPH_Address        = 6'h3E; // Stack Pointer(High)
// localparam SREG_Address       = 6'h3F; // Status Register

//   It's not immediately obvious, but addresses above here are
//   in the I/O Address space 0x0-0x3F (which is data address space
//   0x20-0x5F) while addresses below here are the extended I/O registers
//   in the data address space.
// localparam WDTCSR_Address     = 8'h60; // Watchdog Timer Control Register
// localparam XICR_Address       = 8'h61; // XLR8 IRQ Control reg -------------------------------------XLR8
// localparam XIFR_Address       = 8'h62; // XLR8 IRQ Flag reg ----------------------------------------XLR8
// localparam XMSK_Address       = 8'h63; // XLR8 IRQ Mask reg ----------------------------------------XLR8
// localparam PRR_ADDR           = 8'h64;
// localparam XACK_Address       = 8'h65; // XLR8 ACK Holding reg -------------------------------------XLR8
// localparam OX8ICR_Address     = 8'h66; // OpenXLR8 Pin Control Interrupt Control Reg ---------------XLR8
// localparam OX8IFR_Address     = 8'h67; // OpenXLR8 Pin Control Interrupt Flag Reg ------------------XLR8
// localparam PCICR_Address      = 8'h68; //Pin Change Interrupt Control Register
// localparam EICRA_Address      = 8'h69; // External Interrupt Control Register A
// localparam OX8MSK_Address     = 8'h6A; // OpenXLR8 Pin Control Interrupt Mask Reg ------------------XLR8
// localparam PCMSK0_Address     = 8'h6B; // Pin Change Mask Register 0
// localparam PCMSK1_Address     = 8'h6C; // Pin Change Mask Register 1
// localparam PCMSK2_Address     = 8'h6D; // Pin Change Mask Register 2
// localparam TIMSK0_Address     = 8'h6E; // Timer/Counter Interrupt Mask Register
// localparam TIMSK1_Address     = 8'h6F; // Timer/Counter Interrupt Mask Register
// localparam TIMSK2_Address     = 8'h70; // Timer/Counter Interrupt Mask Register
localparam SPCICR_Address        = 8'h71; // Sno Pin Change Interrupt Control reg ---------------------SNO
localparam SPCIFR_Address        = 8'h72; // Sno Pin Change Interrupt Flag reg ------------------------SNO
localparam SPCIMSK_Address       = 8'h73; // Sno Pin Change Interrupt Mask reg ------------------------SNO
//localparam UNUSED              = 8'h74; // --UNUSED-- 
//localparam UNUSED              = 8'h75; // --UNUSED--
//localparam UNUSED              = 8'h76; // --UNUSED--
//localparam UNUSED              = 8'h77; // --UNUSED--
// localparam ADCL_ADDR          = 8'h78; // ADC Data register(Low)
// localparam ADCH_ADDR          = 8'h79; // ADC Data register(High)
// localparam ADCSRA_ADDR        = 8'h7A; // ADC Control and Status Register
// localparam ADCSRB_ADDR        = 8'h7B;
// localparam ADMUX_ADDR         = 8'h7C; // ADC Multiplexer Selection Register
// localparam XLR8ADCR_ADDR      = 8'h7D; // ADC Control Register -------------------------------------XLR8
// localparam DIDR0_ADDR         = 8'h7E;
// localparam DIDR1_ADDR         = 8'h7F;
// localparam TCCR1A_Address     = 8'h80; // Timer/Counter 1 Control Register A
// localparam TCCR1B_Address     = 8'h81; // Timer/Counter 1 Control Register B
// localparam TCCR1C_Address     = 8'h82; // Timer/Counter 1 Control Register C
// localparam UNUSED             = 6'h83; // --UNUSED--
// localparam TCNT1L_Address     = 8'h84; // Timer/Counter 1 Register(Low)
// localparam TCNT1H_Address     = 8'h85; // Timer/Counter 1 Register(High)
// localparam ICR1L_Address      = 8'h86; // Timer/Counter 1 Input Capture Register(Low)
// localparam ICR1H_Address      = 8'h87; // Timer/Counter 1 Input Capture Register(High)
// localparam OCR1AL_Address     = 8'h88; // Timer/Counter 1 Output Compare Register A(Low)
// localparam OCR1AH_Address     = 8'h89; // Timer/Counter 1 Output Compare Register A(High)
// localparam OCR1BL_Address     = 8'h8A; // Timer/Counter 1 Output Compare Register B(Low)
// localparam OCR1BH_Address     = 8'h8B; // Timer/Counter 1 Output Compare Register B(High)

localparam PINPL_Address          = 8'h8C; // Input Pins         Port PL ---------------------------SNOEDGE
localparam DDRPL_Address          = 8'h8D; // Data Direction Reg Port PL ---------------------------SNOEDGE
localparam PORTPL_Address         = 8'h8E; // Data Register      Port PL ---------------------------SNOEDGE
localparam MSKPL_Address          = 8'h8F; // Interrupt Mask     Port PL ---------------------------SNOEDGE

localparam PINJ0_Address          = 8'h90; // Input Pins         Port J0 ---------------------------SNOEDGE
localparam DDRJ0_Address          = 8'h91; // Data Direction Reg Port J0 ---------------------------SNOEDGE
localparam PORTJ0_Address         = 8'h92; // Data Register      Port J0 ---------------------------SNOEDGE
localparam MSKJ0_Address          = 8'h93; // Interrupt Mask     Port J0 ---------------------------SNOEDGE

localparam PINJ1_Address          = 8'h94; // Input Pins         Port J1 ---------------------------SNOEDGE
localparam DDRJ1_Address          = 8'h95; // Data Direction Reg Port J1 ---------------------------SNOEDGE
localparam PORTJ1_Address         = 8'h96; // Data Register      Port J1 ---------------------------SNOEDGE
localparam MSKJ1_Address          = 8'h97; // Interrupt Mask     Port J1 ---------------------------SNOEDGE

localparam PINJ2_Address          = 8'h98; // Input Pins         Port J2 ---------------------------SNOEDGE
localparam DDRJ2_Address          = 8'h99; // Data Direction Reg Port J2 ---------------------------SNOEDGE
localparam PORTJ2_Address         = 8'h9A; // Data Register      Port J2 ---------------------------SNOEDGE
localparam MSKJ2_Address          = 8'h9B; // Interrupt Mask     Port J2 ---------------------------SNOEDGE

localparam PINJ3_Address          = 8'h9C; // Input Pins         Port J3 ---------------------------SNOEDGE
localparam DDRJ3_Address          = 8'h9D; // Data Direction Reg Port J3 ---------------------------SNOEDGE
localparam PORTJ3_Address         = 8'h9E; // Data Register      Port J3 ---------------------------SNOEDGE
localparam MSKJ3_Address          = 8'h9F; // Interrupt Mask     Port J3 ---------------------------SNOEDGE

localparam PINK0_Address          = 8'hA0; // Input Pins         Port K0 ---------------------------SNOEDGE
localparam DDRK0_Address          = 8'hA1; // Data Direction Reg Port K0 ---------------------------SNOEDGE
localparam PORTK0_Address         = 8'hA2; // Data Register      Port K0 ---------------------------SNOEDGE
localparam MSKK0_Address          = 8'hA3; // Interrupt Mask     Port K0 ---------------------------SNOEDGE

localparam PINK1_Address          = 8'hA4; // Input Pins         Port K1 ---------------------------SNOEDGE
localparam DDRK1_Address          = 8'hA5; // Data Direction Reg Port K1 ---------------------------SNOEDGE
localparam PORTK1_Address         = 8'hA6; // Data Register      Port K1 ---------------------------SNOEDGE
localparam MSKK1_Address          = 8'hA7; // Interrupt Mask     Port K1 ---------------------------SNOEDGE

localparam PINK2_Address          = 8'hA8; // Input Pins         Port K2 ---------------------------SNOEDGE
localparam DDRK2_Address          = 8'hA9; // Data Direction Reg Port K2 ---------------------------SNOEDGE
localparam PORTK2_Address         = 8'hAA; // Data Register      Port K2 ---------------------------SNOEDGE
localparam MSKK2_Address          = 8'hAB; // Interrupt Mask     Port K2 ---------------------------SNOEDGE

localparam PINK3_Address          = 8'hAC; // Input Pins         Port K3 ---------------------------SNOEDGE
localparam DDRK3_Address          = 8'hAD; // Data Direction Reg Port K3 ---------------------------SNOEDGE
localparam PORTK3_Address         = 8'hAE; // Data Register      Port K3 ---------------------------SNOEDGE
localparam MSKK3_Address          = 8'hAF; // Interrupt Mask     Port K3 ---------------------------SNOEDGE

// localparam TCCR2A_Address     = 8'hB0; // Timer/Counter 2 Control Register
// localparam TCCR2B_Address     = 8'hB1; // Timer/Counter 2 Control Register
// localparam TCNT2_Address      = 8'hB2; // Timer/Counter 2
// localparam OCR2A_Address      = 8'hB3; // Timer/Counter 2 Output Compare Register
// localparam OCR2B_Address      = 8'hB4; // Timer/Counter 2 Output Compare Register
// localparam UNUSED             = 8'hB5; // --UNUSED--
// localparam ASSR_Address       = 8'hB6; // Asynchronous mode Status Register
// localparam UNUSED             = 8'hB7; // --UNUSED--
// localparam TWBR_ADDR          = 8'hB8; // TWI Bit Rate Register
// localparam TWSR_ADDR          = 8'hB9; // TWI Status Register  
// localparam TWAR_ADDR          = 8'hBA; // TWI Address Register 
// localparam TWDR_ADDR          = 8'hBB; // TWI Data Register    
// localparam TWCR_ADDR          = 8'hBC; // TWI Control Register 
// localparam TWAMR_ADDR         = 8'hBD;
// localparam UNUSED             = 8'hBE; // --UNUSED--
// localparam UNUSED             = 8'hBF; // --UNUSED--
// localparam UCSR0A_Address     = 8'hC0; // USART0 Control and Status Register A
// localparam UCSR0B_Address     = 8'hC1; // USART0 Control and Status Register B
// localparam UCSR0C_Address     = 8'hC2; // USART0 Control and Status Register C
// localparam RESERVED           = 8'hC3; // --RESERVED (328PB)--
// localparam UBRR0L_Address     = 8'hC4; // USART0 Baud Rate Register Low
// localparam UBRR0H_Address     = 8'hC5; // USART0 Baud Rate Register HIGH
// localparam UDR0_Address       = 8'hC6; // USART0 I/O Data Register
// localparam UNUSED             = 8'hC7; // --UNUSED--
// localparam RESERVED           = 8'hC8; // --RESERVED (328PB)--
// localparam RESERVED           = 8'hC9; // --RESERVED (328PB)--
// localparam RESERVED           = 8'hCA; // --RESERVED (328PB)--
// localparam RESERVED           = 8'hCB; // --RESERVED (328PB)--
// localparam RESERVED           = 8'hCC; // --RESERVED (328PB)--
// localparam RESERVED           = 8'hCD; // --RESERVED (328PB)--
// localparam RESERVED           = 8'hCE; // --RESERVED (328PB)--
// localparam FCFG_CID_ADDR      = 8'hCF; // XLR8 flash config: chip id (64b FIFO) --------------------XLR8
// localparam FCFG_CTL_ADDR      = 8'hD0; // XLR8 flash config: flash programming ---------------------XLR8
// localparam FCFG_STS_ADDR      = 8'hD1; // XLR8 flash config: status --------------------------------XLR8
// localparam FCFG_DAT_ADDR      = 8'hD2; // XLR8 flash config: flash programming  data.  Write only --XLR8
// localparam UNUSED             = 8'hD3; // --UNUSED--
// localparam XLR8VERL_ADDR      = 8'hD4; // XLR8 hardware version (Low) ------------------------------XLR8
// localparam XLR8VERH_ADDR      = 8'hD5; // XLR8 hardware version (High) -----------------------------XLR8
// localparam XLR8VERT_ADDR      = 8'hD6; // XLR8 hardware version (Type) -----------------------------XLR8
// localparam UNUSED             = 8'hD7; // --UNUSED--
// localparam RESERVED           = 8'hD8; // --RESERVED (328PB)--
// localparam RESERVED           = 8'hD9; // --RESERVED (328PB)--
// localparam RESERVED           = 8'hDA; // --RESERVED (328PB)--
// localparam RESERVED           = 8'hDB; // --RESERVED (328PB)--
// localparam RESERVED           = 8'hDC; // --RESERVED (328PB)--
// localparam RESERVED           = 8'hDD; // --RESERVED (328PB)--
// localparam UNUSED             = 8'hDE; // --UNUSED--
// localparam UNUSED             = 8'hDF; // --UNUSED--
// localparam QECR_ADDR          = 8'hE0; // XLR8 Quadrature XB Control Reg ---------------------------XLR8  
// localparam UNUSED             = 8'hE1; // --UNUSED--
// localparam QECNT0_ADDR        = 8'hE2; // XLR8 Quadrature XB Count 0 Reg ---------------------------XLR8
// localparam QECNT1_ADDR        = 8'hE3; // XLR8 Quadrature XB Count 1 Reg ---------------------------XLR8
// localparam QECNT2_ADDR        = 8'hE4; // XLR8 Quadrature XB Count 2 Reg ---------------------------XLR8
// localparam QECNT3_ADDR        = 8'hE5; // XLR8 Quadrature XB Count 3 Reg ---------------------------XLR8
// localparam QERAT0_ADDR        = 8'hE6; // XLR8 Quadrature XB Rate 0 Reg ----------------------------XLR8
// localparam QERAT1_ADDR        = 8'hE7; // XLR8 Quadrature XB Rate 1 Reg ----------------------------XLR8
// localparam QERAT2_ADDR        = 8'hE8; // XLR8 Quadrature XB Rate 2 Reg ----------------------------XLR8
// localparam QERAT3_ADDR        = 8'hE9; // XLR8 Quadrature XB Rate 3 Reg ----------------------------XLR8
// localparam PIDCR_ADDR         = 8'hEA; // XLR8 PID XB Control Reg ----------------------------------XLR8
// localparam PID_KD_H_ADDR      = 8'hEB; // XLR8 PID XB KD H Reg -------------------------------------XLR8
// localparam PID_KD_L_ADDR      = 8'hEC; // XLR8 PID XB KD L Reg  ------------------------------------XLR8
// localparam PID_KI_H_ADDR      = 8'hED; // XLR8 PID XB KI H Reg -------------------------------------XLR8
// localparam PID_KI_L_ADDR      = 8'hEE; // XLR8 PID XB KI L Reg -------------------------------------XLR8
// localparam PID_KP_H_ADDR      = 8'hEF; // XLR8 PID XB KP H Reg -------------------------------------XLR8
// localparam PID_KP_L_ADDR      = 8'hF0; // XLR8 PID XB KP L Reg -------------------------------------XLR8
// localparam PID_SP_H_ADDR      = 8'hF1; // XLR8 PID XB SP H Reg -------------------------------------XLR8
// localparam PID_SP_L_ADDR      = 8'hF2; // XLR8 PID XB SP L Reg -------------------------------------XLR8
// localparam PID_PV_H_ADDR      = 8'hF3; // XLR8 PID XB PV H Reg -------------------------------------XLR8
// localparam PID_PV_L_ADDR      = 8'hF4; // XLR8 PID XB PV L Reg -------------------------------------XLR8
// localparam PID_OP_H_ADDR      = 8'hF5; // XLR8 PID XB OP H Reg -------------------------------------XLR8
// localparam PID_OP_L_ADDR      = 8'hF6; // XLR8 PID XB OP L Reg -------------------------------------XLR8
// localparam NEOCR_ADDR         = 8'hF7; // XLR8 NeoPixel XB Control Reg -----------------------------XLR8
// localparam NEOD0_ADDR         = 8'hF8; // XLR8 NeoPixel XB Data 0 Reg ------------------------------XLR8
// localparam NEOD1_ADDR         = 8'hF9; // XLR8 NeoPixel XB Data 1 Reg ------------------------------XLR8
// localparam NEOD2_ADDR         = 8'hFA; // XLR8 NeoPixel XB Data 2 Reg ------------------------------XLR8
// localparam SVCR_ADDR          = 8'hFB; // XLR8 Servo XB Control Reg --------------------------------XLR8
// localparam SVPWL_ADDR         = 8'hFC; // XLR8 Servo XB Pulse Width Low  Reg - ---------------------XLR8
// localparam SVPWH_ADDR         = 8'hFD; // XLR8 Servo XB Pulse Width High Reg -----------------------XLR8
// localparam UNUSED             = 8'hFE; // --UNUSED--
// localparam UNUSED             = 8'hFF; // --UNUSED--


//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
