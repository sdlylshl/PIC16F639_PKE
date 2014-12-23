#ifndef DELAY_INC
#define DELAY_INC


#define Delay.Returned	Delay.flag,3

	extern Delay.wait_w_x_50us, Delay.flag, Delay.Counter
	extern Delay.start, Delay.Wait
;
;
;	This macro initialises the delay module
;
;
;Delay.Init macro
;	banksel	OPTION_REG
;	MOVLW	b'00000000'		; SET UP FOR TMR0'S PRESCALER VALUE TO 1
;							; (RAPU, bit7) = 0 to enable weak pull-up for PortA also 
;	MOVWF	OPTION_REG		; this is used for Delay loop only
;	endm
;
;	This macro waits for up to 12 ms.
;	The time has to be a multible of 50us.
;	It is just added to enhance readability of the source code.
;	It calls Delay.wait_w_x_50us with appropriate parameters.
;	This function is intended to run at 8 MHz.
;	If running other speeds, change the Delay.wait_w_x_50us method.
;
;	@param time The value of time
;	@param unit The character corresponding to the unit of time (i.e. 'u', 'm')
;
;	@example
;	banksel PORTB
;	bsf		PORTB,0
;	Delay.waitFor .500, 'u'
;	banksel PORTB
;	bcf		PORTB,0
;	@end-ex
;	@ex-desc This sets Pin RB0 high for approx. 500 us
;
;	@status Tested
;
;	@stacklevel +1
;
;	@registers Delay.Returned
;
;*/


Delay.WaitFor macro time, unit

	if(unit == 'u')
	movlw (time/.50)
	else
		if (unit == 'm')
	movlw ((time*.1000)/.50)
		endif
	endif
	call Delay.wait_w_x_50us

	endm


;Delay.start	macro us			;build as function?	Yes, absolutely
;	banksel	OPTION_REG			;2Cycles	1	;setting prescaler to 1:2
;	clrf	OPTION_REG			;1Cycles	1
;	banksel	TMR0				;2Cycles	1
;	movlw	0xEA				;1Cycles	1	;0x100 - 0x32 (50u) + 0x06 (static offset) + 0x07(Interrupt) + 0x0F (n first cycle)= 0xEA to compenste static Offsets
;	movwf	TMR0				;1Cycles	1
;	bsf		INTCON,T0IE
;	banksel	Delay.Counter		;don't care timer already started
;	movlw	(us/.50)
;	movwf	Delay.Counter
;	banksel	Delay.flag
;	bcf		Delay.Returned
;	nop
;	endm

;Delay.Wait macro
;	banksel	Delay.flag
;	btfss	Delay.Returned
;	goto	$-1				;at least 1 Cycle
;	bcf		INTCON,T0IE
;	endm

;------------------------------------------------------------------------------+
;                                                                              |
;    Delay.Isr( w )                                                            |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro must be called within the Interrupt routine, to enable the     |
;    counter.                                                                  |
;    The Counter function is optimized for the following Interrupt routine.    |
;    If you do changes to that routine you will have to modify counter.start   |
;    function,                                                                 |
;    to compensate these instructions (or you will loose precision).           |
;                                                                              |
;                                                                              |
;    Parameters:                                                               |
;    w - The multiplicator                                                     |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs:  TMR0                                                          |
;                                                                              |
;                                                                              |
;    Stacklevel: 0                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    INT code    0x04                                                          |
;        movwf   W_TEMP          ; Save off current W register contents        |
;        movf    STATUS,w                                                      |
;        clrf    STATUS          ; Force to page0                              |
;        movwf   STATUS_TEMP                                                   |
;        movf    PCLATH,w                                                      |
;        movwf   PCLATH_TEMP     ; Save PCLATH                                 |
;        movf    FSR,w                                                         |
;        movwf   FSR_TEMP        ; Save FSR                                    |
;        GOTO    INT_SERV                                                      |
;    INT_SERV                                                                  |
;    TIMER0_INT                                                                |
;        btfss   INTCON,T0IE     ; Check if PORTA Interrupt Enabled            |
;        goto    NEXT_INT        ; ... No, then continue search                |
;        btfss   INTCON,T0IF     ; Check if TMR0 Interrupt Flag Set            |
;        goto    NEXT_INT                                                      |
;        Delay.Isr               ; Handles the delay routines                  |
;        ; *** If you want to use Timer0 for other Interrupts modify the       |
;        Delay.start function,                                                 |
;        ; *** to compensate all instructions, you place here.                 |
;        bcf     INTCON,T0IF                                                   |
;        goto    EndIsr                                                        |
;        ; ***You may place other Interrupt Handlers here***                   |
;    EndIsr                                                                    |
;        clrf    STATUS          ;Select Bank0                                 |
;        movf    FSR_TEMP,w                                                    |
;        movwf   FSR             ;Restore FSR                                  |
;        movf    PCLATH_TEMP,w                                                 |
;        movwf   PCLATH          ;Restore PCLATH                               |
;        movf    STATUS_TEMP,w                                                 |
;        movwf   STATUS          ;Restore STATUS                               |
;        swapf   W_TEMP,f                                                      |
;        swapf   W_TEMP,w        ;Restore W without corrupting STATUS bits     |
;        RETFIE                                                                |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
Delay.Isr macro
	banksel	TMR0			;2Cycles	n
	movlw	0xD8			;1Cycle		n	;so set 0x100-0x32+0x02+0x0E=0xDC
	movwf	TMR0			;1Cycle		n
	banksel	Delay.Counter	;2Cycles	1
	decfsz	Delay.Counter	;1Cycle		1
	goto	Delay.Isr.End	;2Cycle		0
	banksel	Delay.flag		;2Cycles	1
	bsf		Delay.Returned	;1Cycle		1
Delay.Isr.End
	endm
#endif