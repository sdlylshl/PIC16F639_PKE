;------------------------------------------------------------------------------
;	Transponder_PIC16F639_Demo.ASM ---
;	
;	jan Ornter
;	DATE:	3-17-2005
;	VER.:	1.0
;
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;		LEGAL NOTICE
;
;  The information contained in this document is proprietary and 
;  confidential information of Microchip Technology Inc.  Therefore all 
;  parties are required to sign a non-disclosure agreement before  
;  receiving this document.
;
;  The information contained in this Application Note is for suggestion 
;  only.  It is your responsibility to ensure that your application meets 
;  with your specifications.  No representation or warranty is given and 
;  no liability is assumed by Microchip Technology Incorporated with 
;  respect to the accuracy or use of such information or infringement of 
;  patents or other intellectual property arising from such use or 
;  otherwise.
;
;		 Software License Agreement
;
; The software supplied herewith by Microchip Technology Incorporated 
; (the "Company") for its PICmicro� Microcontroller is intended and 
; supplied to you, the Company's customer, for use solely and 
; exclusively on Microchip PICmicro Microcontroller products. The 
; software is owned by the Company and/or its supplier, and is 
; protected under applicable copyright laws. All rights are reserved. 
;  Any use in violation of the foregoing restrictions may subject the 
; user to criminal sanctions under applicable laws, as well as to 
; civil liability for the breach of the terms and conditions of this 
; license.
;
; THIS SOFTWARE IS PROVIDED IN AN "AS IS" CONDITION. NO WARRANTIES, 
; WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT NOT LIMITED 
; TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
; PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. THE COMPANY SHALL NOT, 
; IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL OR 
; CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.

;------------------------------------------------------------------------------

;------------------------------------------------------------------------------+
;                                                                              |
;    Module Transponder_PIC16F639_Demo                                         |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This module implements the top level entity or main program loop.         |
;    The decision, whether to compute a certain event or not are made here.    |
;    When such an event needs to be interpreted, the correct handler function  |
;    will be called.                                                           |
;    Currently implemented events and their corresponding handlers:            |
;    REC_EVENT - Whenever the RX line goes high, such an event will be         |
;    generated                                                                 |
;    MESSAGE_HANDLER - The handler function for REC_EVENTS                     |
;    BUTTON_EVENTS - These events are generated, when a button                 |
;        changes it's state (internally debounced)                             |
;    Button_Handler - The handler function for button events                   |
;    IDLE - This event will be generated, after a certain amount               |
;        of time (adjustable with the TIMEOUT constant), if no other event was |
;        generated                                                             |
;    BED(internally) - The handler for IDLE events                             |
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
#include Project.inc
#include Delay.inc
#include RF.inc
#include EEPROM.inc
#include SPI.inc
#include AFE_639.inc
#include Massage_Handler.inc
#include Button_Handler.inc
   	__CONFIG _FOSC_INTOSCIO & _WDTE_OFF & _PWRTE_ON & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_ON & _FCMEN_ON & _WURE_OFF
    __idlocs	0x1234
;-----------------------------------------|
;
#define		BANK0	banksel	0X00	; SELECT BANK0
#define		BANK1	banksel	0X80	; SELECT BANK1
#define		BANK2	banksel	0100	; SELECT BANK2	; for KeeLoq
; ----------------------------------------|
; RA0 --> Sw input for RF modulation
; RA1 --> Sw input for LF Talk-back
; RA2 --> input/output, SCLK/Alert interrupt input and output SCLK for SPI, 
;		  connected with RC2
; (not implemented) RA3 --> Sw input to set modulation depth = 75 %  
; RA4 --> LFDATA interrupt input, connected with RC3
; RA5 --> LED output for receiving correct LFDATA
; RC0 --> LED output to indicate power state
; RC1 --> Channel selection Input for SPI command
; RC2 --> Input/output for SCLK/Alert tied to RA2
; RC3 --> Input/Output for LFDATA tied to RA4
; RC4 --> RF Enable Output
; RC5 --> RF Mod Output  	 
;#define ValidLED	PORTA,1		; LED D6 
#define CommsLED	PORTC,0		; LED D4
#define ErrorLED	PORTA,5		; LED D5
;#define RFEnable	PORTC,4		; RF Enable Output
#define	AFECS		PORTC,1		; Chip select output
#define	LFDATA		PORTC,3		; Low Frequency Data IN
;#define LFDATA_INT	PORTA,4
; '1' to enable Button on this Pin, otherwise '0'
	ifndef BUTTON_MASK
	#define	BUTTON_MASK		B'00000001'
	endif
;	ifndef MSG_INTERRUPT
;	#define	MSG_INTERRUPT	B'00010000'
;	endif
#define RF_Button	0
#define	REC_EVENT	4		; The number of the PORTA pin the LFDATA output is connected to
#define	IDLE		6
#define START_RF	7
    ifndef TIMEOUT
    #define	TIMEOUT		0x30
    endif
    ifndef MSG_INTERRUPT
    #define	MSG_INTERRUPT	(1<<REC_EVENT)
    endif

;uninitialized data
u_3	udata
PORTA_LAST		res 1
PORTA_NOW		res 1
Button_Counter	res 1
Button_old		res 1
Button_new		res 1
;shared uninitialized data
u_1	udata_shr
W_TEMP			res 1
STATUS_TEMP		res 1
PCLATH_TEMP		res 1
FSR_TEMP		res 1

EVENT_REG		res 1
IDLE_COUNTER	res 1
BUTTON_DELAY	res 1
;overlayed uninitialized data
flag_ovr	udata_ovr
flag	res 1			;using bit 4

	global	EVENT_REG, Button_old, BUTTON_DELAY
	global	EE_DATA, EE_USER
; ***********************************************************************
; RESET
; ***********************************************************************
RESET  code		0x00
	GOTO	MAIN
; ***********************************************************************
; INTERRUPT
; ***********************************************************************
INT	code	0x04
	movwf   W_TEMP	        ; Save off current W register contents
	movf	STATUS,W
	clrf	STATUS			; Force to page0
	movwf	STATUS_TEMP									 
	movf	PCLATH,W
	movwf	PCLATH_TEMP		; Save PCLATH
	movf	FSR,W
	movwf	FSR_TEMP		; Save FSR
	GOTO	INTERRUPT_SERVICE_ROUTINE
	code
;------------------------------------------------------------------------------+
;                                                                              |
;    INTERRUPT_SERVICE_ROUTINE()                                               |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This routine generates button, idle and message events.                   |
;                                                                              |
;                                                                              |
;                                                                              |
;    Stacklevel: 1                                                             |
;                                                                              |
;------------------------------------------------------------------------------+
INTERRUPT_SERVICE_ROUTINE
TIMER0_INT		
	btfss	INTCON,T0IE		;[1]TM0 Check if TMR0 Interrupt Enabled
	goto	TIMER1_INT		; ... No, then continue search
	btfss	INTCON,T0IF		; Check if TMR0 Interrupt Flag Set
	goto	TIMER1_INT		; ... No, then continue search
	
	DELAY__Isr				;Do delay interrupt service routine
	
	bcf		INTCON,T0IF		;clear Timer 0 interrupt flag
	goto	EndIsr			;end interrupt (to ensure maximum precision delay)
TIMER1_INT
	banksel	PIE1			
	btfss	PIE1,TMR1IE			;[2]TM1 Check if Timer1 Interrupt Enabled
	goto	PORTA_INT			;[3]PA ... No, then continue search
	banksel	PIR1
	btfss	PIR1,TMR1IF			; Check if Timer 1 Interrupt Flag Set?
	goto	PORTA_INT			; ... No, then continue search
	decf	IDLE_COUNTER,F		; decrement Idle counter
	btfsc	STATUS,Z			; idle counter == 0 ?
	bsf		EVENT_REG,IDLE		; yes, then set idle event
	banksel	flag
	btfss	flag,4				; is debounce event set?
	goto	BUTTON_TIMER1		; no, then finalize Timer 1 interrupt
	banksel	Button_Counter		; Debouncing button (32-64ms), if button event occured
	decfsz	Button_Counter,F	; decrement debounce counter, is counter 0?
	goto	BUTTON_TIMER1		; no, then finalize interrupt
	banksel	PORTA				; yes, then compute button events
	movf	PORTA,W				; read port A
	banksel	Button_new
	movwf	Button_new			; save to register (to prevent loss of button changes)
	xorwf	Button_old,W		; compare with old value
	andwf	Button_old,W		; Compute falling edges only
	andlw	BUTTON_MASK			; Mask pins not of interrest
	iorwf	EVENT_REG,F			; Set events (should be cleared in the handler routines)
	btfsc	STATUS,Z			; was there an event?
	goto	$+3					; no, then don't reset IDLE_COUNTER
	movlw	TIMEOUT				; yes, then reset IDLE_COUNTER
	movwf	IDLE_COUNTER
	movf	Button_new,W		; move new button value to old button value (for next event check)
	movwf	Button_old
	banksel flag
	bcf		flag,4				; clear debounce flag
BUTTON_TIMER1
	decfsz	BUTTON_DELAY,F
	goto	END_TIMER1
	bsf		EVENT_REG, START_RF
END_TIMER1
	banksel PIR1
	bcf		PIR1,TMR1IF			; clear interrupt flag
	goto	PORTA_INT
PORTA_INT
	btfss	INTCON,RAIE						; Check if PORTA Interrupt Enabled
	goto	EndIsr							; ... No, then end search
	btfss	INTCON,RAIF						; Check if PORTA Interrupt Flag Set
	goto	EndIsr							; ... No, then end search
	banksel PORTA
	movf	PORTA,W							; store Port A value (to prevent missing events)
	andlw	(BUTTON_MASK | MSG_INTERRUPT)	; Masking floating or unused (input) port pins
	banksel	PORTA_NOW
	movwf	PORTA_NOW
	xorwf	PORTA_LAST,W					; compare current value of Port A with Last value
	andlw	(~MSG_INTERRUPT)				; was there another change, than the Rx line?
	btfss	STATUS,Z
	goto	IS_BUTTON						; yes, then check whether it was an button
	btfss	PORTA_NOW,REC_EVENT						; no, then is RX line high?
	goto	END_PORTA						; no, then finalize PORTA interrupt 
	bsf		EVENT_REG,REC_EVENT				; yes, then set the receive event
	goto	END_PORTA						; and finalize Port A interrupt
IS_BUTTON
	movlw	0x02							; set debounce counter to 2 (32-64 ms)
	banksel Button_Counter					
	movwf	Button_Counter
	banksel	flag
	bsf		flag,4							; set debounce flag
END_PORTA
	banksel PORTA_NOW
	movf	PORTA_NOW,W
	movwf	PORTA_LAST						; write new value to last value
	movlw	TIMEOUT							
	movwf	IDLE_COUNTER					;reset idle counter
	bcf		INTCON,RAIF						;clear interrupt flag 
	goto	EndIsr
; *** End of Interrupt Handler -- Recover Registers *************
EndIsr	
	clrf	STATUS			;Select Bank0
	movf	FSR_TEMP,W
	movwf	FSR				;Restore FSR
	movf	PCLATH_TEMP,W
	movwf	PCLATH			;Restore PCLATH
	movf	STATUS_TEMP,W
	movwf	STATUS			;Restore STATUS
	swapf	W_TEMP,F			  
	swapf	W_TEMP,W		;Restore W without corrupting STATUS bits
	RETFIE
;------------------------------------------------------------------------------+
;                                                                              |
;    MAIN()                                                                    |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This routine calls the event handlers for the various events.             |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: OPTION_REG INTCON DELAY_Returned EECON1 EEADR, EEDATA, TMR0    |
;      PORTC                                                                   |
;      ,                                                                       |
;     _w_x_50u                                                                 |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    MESSAGE_HANDLER                                                           |
;        LF__Receive8                                                          |
;        EEPROM__Write                                                         |
;        EEPROM__Read                                                          |
;        LF__Send8                                                             |
;            LF__Send_Clamp_One                                                |
;                AFE__SendCMDClampON                                           |
;                    SPI__Write                                                |
;                DELAY__WaitFor                                                |
;                AFE__SendCMDClampOFF                                          |
;                    SPI__Write                                                |
;            LF__Send_Clamp_Zero                                               |
;                AFE__SendCMDClampON                                           |
;                    SPI__Write                                                |
;                DELAY__WaitFor                                                |
;                AFE__SendCMDClampOFF                                          |
;                    SPI__Write                                                |
;        RF__Send_Header                                                       |
;            DELAY__start                                                      |
;            DELAY__wait                                                       |
;        RF__Send_Data                                                         |
;            DELAY__start                                                      |
;            DELAY__wait                                                       |
;        LF__ReadBuffer                                                        |
;            AFE__Receive8                                                     |
;        RF__SendBuffer                                                        |
;        DELAY__wait_w_x_50us                                                  |
;        _w_x_50u                                                              |
;    Button_Handler                                                            |
;                                                                              |
;                                                                              |
;    Stacklevel: 4                                                             |
;                                                                              |
;------------------------------------------------------------------------------+
MAIN
	BANK0
	CLRF	INTCON	
	CLRF	PORTC		 
	CLRF	PCLATH
	CLRF	WDTCON
	CLRF	CMCON1	
	BANK1
	CLRF	OPTION_REG
	CLRF	TRISA
	CLRF	TRISC
	CLRF	PIE1
	CLRF	PCON
	CLRF	OSCTUNE
	CLRF	LVDCON
	; Enable PORTA Pullups as needed (not needed on standard board)
	movlw	0x00
	movwf	WPUDA      
	movwf	WDA	
	CLRF	VRCON
	BANK2
	banksel	OSCCON
	movlw	b'01110001'		; internal 8 MHz //b'01110001'
	movwf	OSCCON		
	banksel	PORTA
	movlw	B'0001000'
	movwf 	PORTA
	MOVLW	b'00000111'		; disable analog sections-->move to all digitial
	movwf	CMCON0	
; ***** Initialize AFE with User Settings *********************
	banksel	TRISA			
	;;        76543210
	movlw	b'11011111'		; RA1 & RA5 outputs, Reset Inputs
	movwf	TRISA			; 
	movlw	(BUTTON_MASK | MSG_INTERRUPT)
	iorwf	TRISA,F			;ensure buttons and msg interrupt are set as Input
	banksel	Button_old
	movlw	0x0f
	movwf	Button_old
	clrf	Button_Counter
	banksel flag
	clrf	flag
	EEPROM__Init
	
    movlw   0x00                                                           
    banksel EEPROM_ADDRESS                                                
    movwf   EEPROM_ADDRESS 
	
    movlw   0x12                                                           
    call    EEPROM__Write     
	
	RF__Init
	SPI__Init
	AFE__Init
	movlw	AFE__ModDepth12
	AFE__setModDepth
;	AFE__SendCMDAGCPresON 
;	AFE__DisableChannelY
;	AFE__DisableChannelZ
;	AFE__DisableChannelX
;	AFE__AGCActive
;	movlw	0x0f
;	AFE__setXSensitivity
	call	Button_Handler_Init
	banksel	PORTA
	bcf		ErrorLED		; Turn D6 LED On
	bsf		CommsLED		; Turn D4 LED Off
	banksel	T1CON
	movlw	B'00000001'
	movwf	T1CON
	clrf	PIR1
	movlw	TIMEOUT
	movwf	IDLE_COUNTER
	clrf	EVENT_REG
	banksel	IOCA
	movlw	MSG_INTERRUPT|BUTTON_MASK
	movwf	IOCA
	movlw	B'00000001'
	movwf	PIE1
	movlw	B'11001000'
	movwf	INTCON	
; ********** Main Program Loop ********************************
M_LOOP
	btfsc	EVENT_REG,REC_EVENT			; receive event occurred?
	call	MESSAGE_HANDLER				; yes, then call receive handler
	movf	EVENT_REG,W
	andlw	BUTTON_MASK					; any button event set?
	btfss	STATUS,Z					; has button event occured?
	call	Button_Handler				; yes, then call button handler
	btfsc	EVENT_REG,IDLE				; no, then is device idle?
	goto	BED							; yes, then goto bed
	goto	M_LOOP						; no, then start from beginning
BED
	bcf		EVENT_REG,IDLE
	banksel	IOCA						;ensure interrupts are enabled
	movlw	B'11001000'		
	movwf	INTCON	
	movlw	MSG_INTERRUPT|BUTTON_MASK
	movwf	IOCA
	;add additional sleep commands here (shutting down timers etc)
	banksel PORTA
	bsf		ErrorLED
	sleep
	banksel	PORTA
	bcf		ErrorLED					; Turn D5 LED On
	;add additional wake up commands here (initialize timers etc)
	goto	M_LOOP
; ***********************************************************************
; EEPROM MAP
; ***********************************************************************
;EE_MAP
EE_SEC code;		0x2100
; **** Serial Number ************
EE_DATA
	DE		0x01			; 32-bit Serial Number = 0x01234567
	DE		0x23
	DE		0x45
	DE		0x67	
; ***  KeeLoq Encryption Key ****
	DE		0x88			; 64-bit KeeLoq Encryption Key = 0x11223344-55667788
	DE		0x77	
	DE		0x66	
	DE		0x55	
	DE		0x44	
	DE		0x33	
	DE		0x22	
	DE		0x11	
; *** User Memory Locations ****
EE_USER
	DE		0xf0			; 64-bit User Memory
	DE		0x0f
	DE		0x00
	DE		0x00
	DE		0x00
	DE		0x00
	DE		0x00
	DE		0x00
; ***********************************************************************
; END OF FILE: PIC16F639.ASM
; ***********************************************************************
	END
