;------------------------------------------------------------------------------+
;                                                                              |
;    Module LF_pwm                                                             |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    LF_PWM.asm                                                                |
;    Jan Ornter                                                                |
;    DATE:   11-9-2005                                                         |
;    VER.:   1.0                                                               |
;    This class implements the LF transmission protocoll.                      |
;    It uses the commands of the AFE to modulate the data via LF-Talkback on   |
;    the carrier signal.                                                       |
;    The following diagrams visualize the coding of the data.                  |
;                                                                              |
;                                                                              |
;     A coded '0'                                                              |
;         |<  T_STEP  >|<        2*T_STEP        >|                            |
;          ____________                                                        |
;        _|            |__________________________|                            |
;------------------------------------------------------------------------------+
#include Project.inc
#include Delay.inc
#include SPI.inc
#include AFE_639.inc
	ifndef LF__PORT
;------------------------------------------------------------------------------+
;                                                                              |
;    Constant LF__PORT                                                          |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    The port, the LF data input is connected to.                              |
;    You may override the default value by either defining the same constant   |
;    in your Project.inc file or by changing the default value in the module's |
;    source.                                                                   |
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
#define LF__PORT		PORTC
	endif
	ifndef LF__PIN
;------------------------------------------------------------------------------+
;                                                                              |
;    Constant LF__PIN                                                           |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    The pin, the LF data input is connected to.                               |
;    You may override the default value by either defining the same constant   |
;    in your Project.inc file or by changing the default value in the module's |
;    source.                                                                   |
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
#define LF__PIN		3
	endif
#define	LFDATA		LF__PORT,LF__PIN		; Low Frequency Data IN
	ifndef LF__T_PERIOD_MAX
;------------------------------------------------------------------------------+
;                                                                              |
;    Constant LF__T_PERIOD_MAX                                                  |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    The maximum period of one bit - the period of a '0' - in multiples of 100 |
;    ns.                                                                       |
;    You may override the default value by either defining the same constant   |
;    in your Project.inc file or by changing the default value in the module's |
;    source.                                                                   |
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
#define LF__T_PERIOD_MAX	.8000
	endif
	ifndef LF__T_INST
;------------------------------------------------------------------------------+
;                                                                              |
;    Constant LF__T_INST                                                        |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    The instruction time in multiples of 100 ns.                              |
;    You may override the default value by either defining the same constant   |
;    in your Project.inc file or by changing the default value in the module's |
;    source.                                                                   |
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
#define LF__T_INST		.5
	endif
	ifndef LF__T_NOISE_MAX
;------------------------------------------------------------------------------+
;                                                                              |
;    Constant LF__T_NOISE_MAX                                                   |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    The maximum time of spikes, that should be surpressed, in multiples of 100|
;     ns.                                                                      |
;    You may override the default value by either defining the same constant   |
;    in your Project.inc file or by changing the default value in the module's |
;    source.                                                                   |
;                                                                              |
;                                                                              |
;     Example                                                                  |
;          |< Noise (t<T_NOISE_MAX) >|      |<      Edge (t>T_NOISE_MAX)       |
;           >|                                                                 |
;           _________________________                                          |
;           _______________________________________                            |
;        __|                         |______|                                  |
;------------------------------------------------------------------------------+
#define LF__T_NOISE_MAX	.200
	endif
	ifndef LF__T_STEP
;------------------------------------------------------------------------------+
;                                                                              |
;    Constant LF__T_STEP                                                        |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This time adjusts the bitrate of transferred data.                        |
;    The value is in micro seconds and has to be a multiple of 50.             |
;    You may override the default value by either defining the same constant   |
;    in your Project.inc file or by changing the default value in the module's |
;    source.                                                                   |
;                                                                              |
;                                                                              |
;     A coded '0'                                                              |
;         |<  T_STEP  >|<        2*T_STEP        >|                            |
;          ____________                                                        |
;        _|            |__________________________|                            |
;------------------------------------------------------------------------------+
#define LF__T_STEP		.250
	endif
	udata
LF_Parity		res 1
LF_Buffer		res 1
LF_COUNTER		res 1
LF_TEMP			res 1
Counter			res 1
Time			res 1
	global	LF__Send8, LF__Receive8, LF__ReadBuffer, LF__SendBuffer
	variable PRE_BITS = B'00000000'
	variable TMP_PRESCALER = ( LF__T_PERIOD_MAX / (.220 * LF__T_INST) ) + .1
	variable PRESCALER = .2
	if ( TMP_PRESCALER == .1)
PRE_BITS = B'00001000'
PRESCALER = .1
	else
PRE_BITS = B'00000000'
		while(PRESCALER < TMP_PRESCALER)
PRE_BITS+=.1
PRESCALER*=.2
		endw
		if(PRE_BITS>0x07)
			error Can not setup correct prescaler
		endif
	endif
	messg Setting Prescaler value of #v(PRESCALER) #v(PRE_BITS)
	code
; ***********************************************************************	
; Send_Clamp_One()
; ***********************************************************************
;------------------------------------------------------------------------------+
;                                                                              |
;    LF__Send_Clamp_One()                                                       |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This method sends a one over the LF antenna.                              |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs:                                                                |
;    DELAY_Returned                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE__SendCMDClampON                                                        |
;        SPI__Write                                                             |
;    DELAY__WaitFor                                                             |
;    AFE__SendCMDClampOFF                                                       |
;        SPI__Write                                                             |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;------------------------------------------------------------------------------+
LF__Send_Clamp_One
	AFE__SendCMDClampON
	DELAY__WaitFor LF__T_STEP,'u'
	AFE__SendCMDClampOFF
	DELAY__WaitFor LF__T_STEP, 'u'
	return
; ***********************************************************************	
; Send_Clamp_Zero()
; ***********************************************************************
;------------------------------------------------------------------------------+
;                                                                              |
;    LF__Send_Clamp_Zero()                                                      |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This method sends a zero over the LF antenna.                             |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs:                                                                |
;    DELAY_Returned                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE__SendCMDClampON                                                        |
;        SPI__Write                                                             |
;    DELAY__WaitFor                                                             |
;    AFE__SendCMDClampOFF                                                       |
;        SPI__Write                                                             |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;------------------------------------------------------------------------------+
LF__Send_Clamp_Zero
	AFE__SendCMDClampON
	DELAY__WaitFor LF__T_STEP, 'u'
	AFE__SendCMDClampOFF
	DELAY__WaitFor 2*LF__T_STEP, 'u'
	return
; ***********************************************************************
; * AFE Receive Routine 												*
; ***********************************************************************
;------------------------------------------------------------------------------+
;                                                                              |
;     w LF__Receive8()                                                          |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This method receives one byte over the LF-AFE                             |
;                                                                              |
;                                                                              |
;    Returns:                                                                  |
;    w - The received data byte                                                |
;                                                                              |
;                                                                              |
;    Used SFRs: TMR0  PORTC                                                    |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;------------------------------------------------------------------------------+
LF__Receive8
	banksel	OPTION_REG
	movlw	PRE_BITS		; SET UP FOR TMR0'S PRESCALER VALUE TO 1:8
							; (RAPU, bit7) = 0 to enable weak pull-up for PortA also 
	MOVWF	OPTION_REG
	
	
	banksel TMR0
	clrf	TMR0			; Rising edge detected, Reset Timer 
	banksel	LF_Buffer
	clrf	LF_Buffer		; clear receive register
	clrf	LF_Parity
	
	bcf		INTCON,T0IF		; Reset Timer #0 Interrupt Flag
	movlw	.8				; number of bits to receive
	movwf	LF_COUNTER		; load number of bits into counter register
	
ReceiveNext
	call	LF__DetectFalling
	btfsc	STATUS,Z
	retlw	0x00
	
ReceiveNext2
	call	LF__DetectRising
	btfsc	STATUS,Z
	goto	Return.Fail
	btfsc	INTCON,T0IF
	goto	Return.Fail
	movlw	(3*LF__T_PERIOD_MAX)/(4*PRESCALER*LF__T_INST);0x9C			; Determine Bit value Time>156, then Zero else One
	subwf	Time,W
	banksel LF_Buffer	
	movf	LF_COUNTER,W
	btfsc	STATUS,Z
	goto	ParityCheck
	btfsc	STATUS,C
	incf	LF_Parity,F
	rrf		LF_Buffer,F		; Rotate bit received bit, now in carry, into receive buffer
;	banksel LF_COUNTER
	decf	LF_COUNTER, f		; Decrement receive count register by one
	goto	ReceiveNext		; ... no, then receive next bit
ParityCheck
	btfss	STATUS,C
	goto	Receive.ParityZero
;	goto	Receive.ParityOne
Receive.ParityOne
	btfss	LF_Parity,0
	goto	Receive.Success
	goto	Return.Fail
Receive.ParityZero
	btfsc	LF_Parity,0
	goto	Receive.Success
	goto	Return.Fail
;	banksel LF_Buffer
Receive.Success
	movf 	LF_Buffer,W		; Move received data byte into WREG
	bcf		STATUS,Z
	return					
;------------------------------------------------------------------------------+
;                                                                              |
;    LF__ReadBuffer( w  FSR )                                                   |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This method reads an specified amount of bytes from the LF-Input to a     |
;    buffer.                                                                   |
;    The buffer has to be within bank0 or bank1.                               |
;                                                                              |
;                                                                              |
;    Parameters:                                                               |
;    w - The amount of bytes to be read                                        |
;    FSR - The start address of the buffer                                     |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs:                                                                |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE__Receive8                                                              |
;                                                                              |
;                                                                              |
;    Stacklevel: 1                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    movlw   InputBuffer                                                       |
;    movwf   FSR                                                               |
;    movlw   0x04                                                              |
;    call    AFE__ReadBuffer                                                    |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This reads 4 bytes from the LF-Input to the buffer "InputBuffer"      |
;                                                                              |
;------------------------------------------------------------------------------+
LF__ReadBuffer
	banksel	LF_TEMP
	movwf	LF_TEMP
	call	LF__DetectRising		;Adjusting delay of first bit
LF__ReadBuffer.loop
	call	LF__Receive8
	btfsc	STATUS,Z
	goto	Return.Fail
	bankisel	PORTA
	movwf	INDF
	incf	FSR,F
	decfsz	LF_TEMP,F
	goto	LF__ReadBuffer.loop
	bcf		STATUS,Z
	return
; ***********************************************************************
; * AFE Send Byte Routine 												*
; ***********************************************************************
;------------------------------------------------------------------------------+
;                                                                              |
;    LF__Send8()                                                                |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This method transmits one byte over the LF-AFE                            |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: DELAY_Returned                                                 |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    LF__Send_Clamp_One                                                         |
;        AFE__SendCMDClampON                                                    |
;            SPI__Write                                                         |
;        DELAY__WaitFor                                                         |
;        AFE__SendCMDClampOFF                                                   |
;            SPI__Write                                                         |
;    LF__Send_Clamp_Zero                                                        |
;        AFE__SendCMDClampON                                                    |
;            SPI__Write                                                         |
;        DELAY__WaitFor                                                         |
;        AFE__SendCMDClampOFF                                                   |
;            SPI__Write                                                         |
;                                                                              |
;                                                                              |
;    Stacklevel: 3                                                             |
;                                                                              |
;------------------------------------------------------------------------------+
LF__Send8
	banksel	LF_Buffer
	movwf	LF_Buffer
	movlw	.8					; number of bits to receive
	movwf	LF_COUNTER			; load number of bits into counter register
SendNext
	btfsc	LF_Buffer,0			; Check if Data Bit = 1
	Call	LF__Send_Clamp_One	; ... Yes, then send LF Clamp One
	
	banksel LF_Buffer
	btfss	LF_Buffer,0			; Check if Data Bit = 0
	Call	LF__Send_Clamp_Zero	; ... Yes, then send LF Clamp Zero
	banksel LF_Buffer
	rrf		LF_Buffer,1			; Right Rotate Data Register to get next bit
	decfsz	LF_COUNTER, f		; Decrement receive count register by one
	goto	SendNext			; ... no, then receive next bit
	AFE__SendCMDClampOFF
	return					
;------------------------------------------------------------------------------+
;                                                                              |
;    LF__SendBuffer( w  FSR )                                                   |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This function sends a complete data buffer to the air.                    |
;    The Buffer has to be on Bank0 or Bank1                                    |
;                                                                              |
;                                                                              |
;    Parameters:                                                               |
;    w - The amount of bytes to be sent                                        |
;    FSR - The start address of the buffer                                     |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: DELAY_Returned                                                 |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    LF__Send8                                                                  |
;        LF__Send_Clamp_One                                                     |
;            AFE__SendCMDClampON                                                |
;                SPI__Write                                                     |
;            DELAY__WaitFor                                                     |
;            AFE__SendCMDClampOFF                                               |
;                SPI__Write                                                     |
;        LF__Send_Clamp_Zero                                                    |
;            AFE__SendCMDClampON                                                |
;                SPI__Write                                                     |
;            DELAY__WaitFor                                                     |
;            AFE__SendCMDClampOFF                                               |
;                SPI__Write                                                     |
;                                                                              |
;                                                                              |
;    Stacklevel: 4                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    movlw   SerialNumber    ;move start address to w                          |
;    movwf   FSR             ;write start address to fsr                       |
;    movlw   0x04            ;move number of bytes to transmit to w            |
;    call    AFE__SendBuffer  ;send it via LF-Talkback                          |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sends 4 bytes of the buffer "SerialNumber" to the air            |
;                                                                              |
;------------------------------------------------------------------------------+
LF__SendBuffer
	banksel	LF_TEMP
	movwf	LF_TEMP
LF__SendBuffer.loop
	bankisel	PORTA
	movf	INDF,W
	call	LF__Send8
	incf	FSR,F
	decfsz	LF_TEMP,F
	goto	LF__SendBuffer.loop
	return
;------------------------------------------------------------------------------+
;                                                                              |
;    LF__DetectFalling()                                                        |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    Internal use only.                                                        |
;    This function detects a falling edge on the LF input pin.                 |
;    It will debounce this pin with the given timing constants.                |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs:  TMR0                                                          |
;                                                                              |
;                                                                              |
;    Stacklevel: 1                                                             |
;                                                                              |
;------------------------------------------------------------------------------+
LF__DetectFalling
		banksel Counter
		movlw	(LF__T_NOISE_MAX/(LF__T_INST*.9))+1
		movwf	Counter								; initialize debounce counter
		movlw	(.115*LF__T_PERIOD_MAX/(.100*LF__T_INST*PRESCALER))+1	; 
		banksel TMR0
		subwf	TMR0,W								; over maximum period time?
		btfsc	STATUS,C
		goto	Return.Fail							; yes, then return 0
		btfsc	INTCON,T0IF							; As there is a resonant frequency in this routine
		goto	Return.Fail							; Check also absolute timing
LF__DetectFalling.Debounce
		banksel LF__PORT
		btfsc	LFDATA								; is pin low?
		goto	LF__DetectFalling					; no, then start from beginning
		banksel Counter
		decfsz	Counter,F							; was the pin low for T_NOISE_MAX?
		goto	LF__DetectFalling.Debounce			; no, then test again
		banksel TMR0
		movf	TMR0,W								; store TMR0 value
		banksel Time
		movwf	Time
		bcf		STATUS,Z
		return
;------------------------------------------------------------------------------+
;                                                                              |
;    LF__DetectRising()                                                         |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    Internal use only.                                                        |
;    This function detects a rising edge on the LF input pin.                  |
;    It will debounce this pin with the given timing constants.                |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs:  TMR0                                                          |
;                                                                              |
;                                                                              |
;    Stacklevel: 1                                                             |
;                                                                              |
;------------------------------------------------------------------------------+
LF__DetectRising
		banksel Counter
		movlw	(LF__T_NOISE_MAX/(LF__T_INST*.9))+1
		movwf	Counter								; initialize debounce counter
		movlw	(.115*LF__T_PERIOD_MAX/(.100*LF__T_INST*PRESCALER))+1	; 
		banksel TMR0
		subwf	TMR0,W								; over maximum period time?
		btfsc	STATUS,C
		goto	Return.Fail							; yes, then return 0
		btfsc	INTCON,T0IF							; As there is a resonant frequency in this routine
		goto	Return.Fail							; Check also absolute timing
LF__DetectRising.Debounce
		banksel LF__PORT
		btfss	LFDATA								; is pin low?
		goto	LF__DetectRising						; no, then start from beginning
		banksel Counter
		decfsz	Counter,F							; was the pin low for T_NOISE_MAX?
		goto	LF__DetectRising.Debounce			; no, then test again
		banksel TMR0
		movf	TMR0,W								; store TMR0 value
		clrf	TMR0
		banksel Time
		movwf	Time
		bcf		STATUS,Z
		return
Return.Fail
		bsf		STATUS,Z
		return
	END
