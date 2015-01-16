;------------------------------------------------------------------------------
;	DELAYS.ASM --- PIC16F636/9 EEPROM Functions
;	Jan Ornter
;
;	DATE:	11-9-2005
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
; (the "Company") for its PICmicro® Microcontroller is intended and 
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

; ***********************************************************************
; * Delay routines  													*
; ***********************************************************************

;------------------------------------------------------------------------------+
;                                                                              |
;    Module DELAY                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This class provides some usefull delay routines.                          |
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
#include "Project.inc"
#define DELAY_Returned	DELAY_flag,3
wait macro Cyc
	local tmp = Cyc
	while tmp > .0
	nop
tmp -= .1
	endw
	endm
	
	global DELAY_flag, DELAY_Counter
	global DELAY__wait_w_x_50us, DELAY__start, DELAY__Wait
	
Delay_ovr	udata_ovr	;May do some overlay
DELAY_Counter	res 1
DELAY_TEMP1	res 1
DELAY_TEMP2	res 1

flag_ovr	udata_ovr
DELAY_flag	res	1			;using bit 3 set true to define timeout
;------------------------------------------------------------------------------+
;                                                                              |
;    DELAY__wait_w_x_50us( w )                                                  |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This function waits for the value in w multiplied with 50 us.             |
;    The movlw instruction needed befor every call is already included in the  |
;    50us.                                                                     |
;    This function is intended to run at 8 MHz.                                |
;    If running other speeds, use the parameters in the source code to adjust  |
;    values.                                                                   |
;                                                                              |
;                                                                              |
;    Parameters:                                                               |
;    w - The multiplicator                                                     |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs:  DELAY_Returned                                                |
;                                                                              |
;                                                                              |
;    Stacklevel: 0                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    banksel PORTB                                                             |
;    bsf     PORTB,0                                                           |
;    movlw   .10                                                               |
;    call    DELAY__wait_w_x_50us                                               |
;    banksel PORTB                                                             |
;    bcf     PORTB,0                                                           |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sets Pin RB0 high for approx. 500 us                             |
;                                                                              |
;------------------------------------------------------------------------------+
	code
DELAY__wait_w_x_50us					
;time = ( 9[11] - n + TEMP2 * ( 12 + n + m + TEMP1 * 3 ) ) * ( 4 / Fosc(M) )
;so set n equal to constant part (10[12]) depending on the bankselection code for Delay_Returned (see disassembly for exact values)
;use m to get an int, when dividing by 3.
									;2 Cycles for call		(1)
									;+ 1 Cycle for movlw	(1)
	banksel DELAY_flag				;0-2 Cycles				(1)
	bcf		DELAY_Returned			;1 Cycle				(1)
	banksel	DELAY_TEMP2				;[2] Cycle
	movwf	DELAY_TEMP2				;1 Cycle				(1)
BaseDelay
	call	Delay40us				;see Delay40us
	movlw	0x01					;1 Cycle				(TEMP2)
	subwf	DELAY_TEMP2,W			;1 Cycle				(TEMP2)
	btfsc	STATUS,Z				;1 Cycle				(TEMP2)
									;2 Cycles				(TEMP2-1)
	goto	lastloop				;2 Cycles				(1)
	wait 	.11						;n Cycles				(TEMP2-1)
lastloop
	wait 	.2						;m Cycles				(TEMP2)
	decfsz	DELAY_TEMP2,F			;1 Cycle				(TEMP2)
	goto	BaseDelay				;2 Cycles				(TEMP2)
	banksel	DELAY_flag				;[2] Cycle
	bsf		DELAY_Returned			;1 Cycle  + 1 Cycle nop	(1)
	return							;2 Cycles				(1)
						
Delay40us							; time=((X*3)+6)*(1/(Fosc/4))		
	movlw	.25						; 1 cycle + 2 cycles for CALL		(TEMP2)
	movwf	DELAY_TEMP1				; 1 cycle							(TEMP2)
	decfsz	DELAY_TEMP1, f			; 1 cycle							(TEMP1*TEMP2)
	goto	$-1						; 2 cycles							((TEMP1-1)*TEMP2)
	return							; 2 cycles + 1 cyclec for DECFSZ	(TEMP2)
;------------------------------------------------------------------------------+
;                                                                              |
;    DELAY__start( w )                                                          |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This function starts a counter an initializes it with value in w          |
;    multiplied with 50 us.                                                    |
;    To wait for the counter to finish call DELAY__Wait                         |
;    This function is intended to run at 8 MHz.                                |
;    If running other speeds, use the parameters in the source code to adjust  |
;    values.                                                                   |
;                                                                              |
;                                                                              |
;    Parameters:                                                               |
;    w - The multiplicator                                                     |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs:  INTCON OPTION_REG                                             |
;                                                                              |
;                                                                              |
;    Stacklevel: 1                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    banksel PORTB                                                             |
;    bsf     PORTB,0                                                           |
;    movlw   .10                                                               |
;    call    DELAY__start     ;starts the counter                               |
;    call    DELAY__Wait      ;waits till the 500us are over                    |
;    banksel PORTB                                                             |
;    bcf     PORTB,0                                                           |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sets Pin RB0 high for approx. 500 us                             |
;                                                                              |
;------------------------------------------------------------------------------+
DELAY__start
	banksel DELAY_Counter		;2Cycles	1
	movwf	DELAY_Counter		;1Cycle		1
	banksel	OPTION_REG			;2Cycles	1	;setting prescaler to 1:2
	clrf	OPTION_REG			;1Cycles	1
	banksel	TMR0				;2Cycles	1
	movlw	0xEA				;1Cycles	1	;0x100 - 0x32 (50u) + 0x06 (static offset) + 0x07(Interrupt) + 0x0F (n first cycle)= 0xEA to compenste static Offsets
	movwf	TMR0				;1Cycles	1
	bcf		INTCON,T0IF			;this and below: dont't care timer already started
	bsf		INTCON,T0IE
	banksel	DELAY_flag
	bcf		DELAY_Returned
	return
;------------------------------------------------------------------------------+
;                                                                              |
;    DELAY__Wait( w )                                                           |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This function waits for the Counter to finish.                            |
;                                                                              |
;                                                                              |
;    Parameters:                                                               |
;    w - The multiplicator                                                     |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs:  INTCON                                                        |
;                                                                              |
;                                                                              |
;    Stacklevel: 1                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    banksel PORTB                                                             |
;    bsf     PORTB,0                                                           |
;    movlw   .10                                                               |
;    call    DELAY__start     ;starts the counter                               |
;    call    DELAY__Wait      ;waits till the 500us are over                    |
;    banksel PORTB                                                             |
;    bcf     PORTB,0                                                           |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sets Pin RB0 high for approx. 500 us                             |
;                                                                              |
;------------------------------------------------------------------------------+
DELAY__Wait
	banksel	DELAY_flag
	btfss	DELAY_Returned
	goto	$-1				;at least 2 Cycles	1
	bcf		INTCON,T0IE		;1Cycle				1
	return
	END
