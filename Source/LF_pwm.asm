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
	ifndef LF.PORT
;------------------------------------------------------------------------------+
;                                                                              |
;    Constant LF.PORT                                                          |
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
#define LF.PORT		PORTC
	endif
	ifndef LF.PIN
;------------------------------------------------------------------------------+
;                                                                              |
;    Constant LF.PIN                                                           |
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
#define LF.PIN		3
	endif
#define	LFDATA		LF.PORT,LF.PIN		; Low Frequency Data IN
	ifndef LF.T_PERIOD_MAX
;------------------------------------------------------------------------------+
;                                                                              |
;    Constant LF.T_PERIOD_MAX                                                  |
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
#define LF.T_PERIOD_MAX	.8000
	endif
	ifndef LF.T_INST
;------------------------------------------------------------------------------+
;                                                                              |
;    Constant LF.T_INST                                                        |
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
#define LF.T_INST		.5
	endif
	ifndef LF.T_NOISE_MAX
;------------------------------------------------------------------------------+
;                                                                              |
;    Constant LF.T_NOISE_MAX                                                   |
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
#define LF.T_NOISE_MAX	.200
	endif
	ifndef LF.T_STEP
;------------------------------------------------------------------------------+
;                                                                              |
;    Constant LF.T_STEP                                                        |
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
#define LF.T_STEP		.250
	endif
	udata
LF.Buffer		res 1
LF.COUNTER		res 1
LF.TEMP			res 1
Counter			res 1
Time			res 1
LF.Parity		res 1
	global	LF.Send8, LF.Receive8, LF.ReadBuffer, LF.SendBuffer
	variable PRE_BITS = B'00000000'
	variable TMP_PRESCALER = ( LF.T_PERIOD_MAX / (.220 * LF.T_INST) ) + .1
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
;    LF.Send_Clamp_One()                                                       |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This method sends a one over the LF antenna.                              |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs:                                                                |
;    Delay.Returned                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE.SendCMDClampON                                                        |
;        SPI.Write                                                             |
;    Delay.WaitFor                                                             |
;    AFE.SendCMDClampOFF                                                       |
;        SPI.Write                                                             |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;------------------------------------------------------------------------------+
LF.Send_Clamp_One
	AFE.SendCMDClampON
	Delay.WaitFor LF.T_STEP,'u'
	AFE.SendCMDClampOFF
	Delay.WaitFor LF.T_STEP, 'u'
	return
; ***********************************************************************	
; Send_Clamp_Zero()
; ***********************************************************************
;------------------------------------------------------------------------------+
;                                                                              |
;    LF.Send_Clamp_Zero()                                                      |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This method sends a zero over the LF antenna.                             |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs:                                                                |
;    Delay.Returned                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE.SendCMDClampON                                                        |
;        SPI.Write                                                             |
;    Delay.WaitFor                                                             |
;    AFE.SendCMDClampOFF                                                       |
;        SPI.Write                                                             |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;------------------------------------------------------------------------------+
LF.Send_Clamp_Zero
	AFE.SendCMDClampON
	Delay.WaitFor LF.T_STEP, 'u'
	AFE.SendCMDClampOFF
	Delay.WaitFor 2*LF.T_STEP, 'u'
	return
; ***********************************************************************
; * AFE Receive Routine 												*
; ***********************************************************************
;------------------------------------------------------------------------------+
;                                                                              |
;     w LF.Receive8()                                                          |
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
LF.Receive8
	banksel	OPTION_REG
	movlw	PRE_BITS		; SET UP FOR TMR0'S PRESCALER VALUE TO 1:8
							; (RAPU, bit7) = 0 to enable weak pull-up for PortA also 
	MOVWF	OPTION_REG
	
	
	banksel TMR0
	clrf	TMR0			; Rising edge detected, Reset Timer 
	banksel	LF.Buffer
	clrf	LF.Buffer		; clear receive register
	clrf	LF.Parity
	
	bcf		INTCON,T0IF		; Reset Timer #0 Interrupt Flag
	movlw	.8				; number of bits to receive
	movwf	LF.COUNTER		; load number of bits into counter register
	
ReceiveNext
	call	LF.DetectFalling
	btfsc	STATUS,Z
	retlw	0x00
	
ReceiveNext2
	call	LF.DetectRising
	btfsc	STATUS,Z
	goto	Return.Fail
	btfsc	INTCON,T0IF
	goto	Return.Fail
	movlw	(3*LF.T_PERIOD_MAX)/(4*PRESCALER*LF.T_INST);0x9C			; Determine Bit value Time>156, then Zero else One
	subwf	Time,w
	banksel LF.Buffer	
	movf	LF.COUNTER,w
	btfsc	STATUS,Z
	goto	ParityCheck
	btfsc	STATUS,C
	incf	LF.Parity,f
	rrf		LF.Buffer,f		; Rotate bit received bit, now in carry, into receive buffer
;	banksel LF.COUNTER
	decf	LF.COUNTER, f		; Decrement receive count register by one
	goto	ReceiveNext		; ... no, then receive next bit
ParityCheck
	btfss	STATUS,C
	goto	Receive.ParityZero
;	goto	Receive.ParityOne
Receive.ParityOne
	btfss	LF.Parity,0
	goto	Receive.Success
	goto	Return.Fail
Receive.ParityZero
	btfsc	LF.Parity,0
	goto	Receive.Success
	goto	Return.Fail
;	banksel LF.Buffer
Receive.Success
	movf 	LF.Buffer,w		; Move received data byte into WREG
	bcf		STATUS,Z
	return					
;------------------------------------------------------------------------------+
;                                                                              |
;    LF.ReadBuffer( w  FSR )                                                   |
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
;    AFE.Receive8                                                              |
;                                                                              |
;                                                                              |
;    Stacklevel: 1                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    movlw   InputBuffer                                                       |
;    movwf   FSR                                                               |
;    movlw   0x04                                                              |
;    call    AFE.ReadBuffer                                                    |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This reads 4 bytes from the LF-Input to the buffer "InputBuffer"      |
;                                                                              |
;------------------------------------------------------------------------------+
LF.ReadBuffer
	banksel	LF.TEMP
	movwf	LF.TEMP
	call	LF.DetectRising		;Adjusting delay of first bit
LF.ReadBuffer.loop
	call	LF.Receive8
	btfsc	STATUS,Z
	goto	Return.Fail
	bankisel	PORTA
	movwf	INDF
	incf	FSR,f
	decfsz	LF.TEMP,f
	goto	LF.ReadBuffer.loop
	bcf		STATUS,Z
	return
; ***********************************************************************
; * AFE Send Byte Routine 												*
; ***********************************************************************
;------------------------------------------------------------------------------+
;                                                                              |
;    LF.Send8()                                                                |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This method transmits one byte over the LF-AFE                            |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: Delay.Returned                                                 |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    LF.Send_Clamp_One                                                         |
;        AFE.SendCMDClampON                                                    |
;            SPI.Write                                                         |
;        Delay.WaitFor                                                         |
;        AFE.SendCMDClampOFF                                                   |
;            SPI.Write                                                         |
;    LF.Send_Clamp_Zero                                                        |
;        AFE.SendCMDClampON                                                    |
;            SPI.Write                                                         |
;        Delay.WaitFor                                                         |
;        AFE.SendCMDClampOFF                                                   |
;            SPI.Write                                                         |
;                                                                              |
;                                                                              |
;    Stacklevel: 3                                                             |
;                                                                              |
;------------------------------------------------------------------------------+
LF.Send8
	banksel	LF.Buffer
	movwf	LF.Buffer
	movlw	.8					; number of bits to receive
	movwf	LF.COUNTER			; load number of bits into counter register
SendNext
	btfsc	LF.Buffer,0			; Check if Data Bit = 1
	Call	LF.Send_Clamp_One	; ... Yes, then send LF Clamp One
	
	banksel LF.Buffer
	btfss	LF.Buffer,0			; Check if Data Bit = 0
	Call	LF.Send_Clamp_Zero	; ... Yes, then send LF Clamp Zero
	banksel LF.Buffer
	rrf		LF.Buffer,1			; Right Rotate Data Register to get next bit
	decfsz	LF.COUNTER, f		; Decrement receive count register by one
	goto	SendNext			; ... no, then receive next bit
	AFE.SendCMDClampOFF
	return					
;------------------------------------------------------------------------------+
;                                                                              |
;    LF.SendBuffer( w  FSR )                                                   |
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
;    Used SFRs: Delay.Returned                                                 |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    LF.Send8                                                                  |
;        LF.Send_Clamp_One                                                     |
;            AFE.SendCMDClampON                                                |
;                SPI.Write                                                     |
;            Delay.WaitFor                                                     |
;            AFE.SendCMDClampOFF                                               |
;                SPI.Write                                                     |
;        LF.Send_Clamp_Zero                                                    |
;            AFE.SendCMDClampON                                                |
;                SPI.Write                                                     |
;            Delay.WaitFor                                                     |
;            AFE.SendCMDClampOFF                                               |
;                SPI.Write                                                     |
;                                                                              |
;                                                                              |
;    Stacklevel: 4                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    movlw   SerialNumber    ;move start address to w                          |
;    movwf   FSR             ;write start address to fsr                       |
;    movlw   0x04            ;move number of bytes to transmit to w            |
;    call    AFE.SendBuffer  ;send it via LF-Talkback                          |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sends 4 bytes of the buffer "SerialNumber" to the air            |
;                                                                              |
;------------------------------------------------------------------------------+
LF.SendBuffer
	banksel	LF.TEMP
	movwf	LF.TEMP
LF.SendBuffer.loop
	bankisel	PORTA
	movf	INDF,w
	call	LF.Send8
	incf	FSR,f
	decfsz	LF.TEMP,f
	goto	LF.SendBuffer.loop
	return
;------------------------------------------------------------------------------+
;                                                                              |
;    LF.DetectFalling()                                                        |
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
LF.DetectFalling
		banksel Counter
		movlw	(LF.T_NOISE_MAX/(LF.T_INST*.9))+1
		movwf	Counter								; initialize debounce counter
		movlw	(.115*LF.T_PERIOD_MAX/(.100*LF.T_INST*PRESCALER))+1	; 
		banksel TMR0
		subwf	TMR0,w								; over maximum period time?
		btfsc	STATUS,C
		goto	Return.Fail							; yes, then return 0
		btfsc	INTCON,T0IF							; As there is a resonant frequency in this routine
		goto	Return.Fail							; Check also absolute timing
LF.DetectFalling.Debounce
		banksel LF.PORT
		btfsc	LFDATA								; is pin low?
		goto	LF.DetectFalling					; no, then start from beginning
		banksel Counter
		decfsz	Counter,f							; was the pin low for T_NOISE_MAX?
		goto	LF.DetectFalling.Debounce			; no, then test again
		banksel TMR0
		movf	TMR0,w								; store TMR0 value
		banksel Time
		movwf	Time
		bcf		STATUS,Z
		return
;------------------------------------------------------------------------------+
;                                                                              |
;    LF.DetectRising()                                                         |
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
LF.DetectRising
		banksel Counter
		movlw	(LF.T_NOISE_MAX/(LF.T_INST*.9))+1
		movwf	Counter								; initialize debounce counter
		movlw	(.115*LF.T_PERIOD_MAX/(.100*LF.T_INST*PRESCALER))+1	; 
		banksel TMR0
		subwf	TMR0,w								; over maximum period time?
		btfsc	STATUS,C
		goto	Return.Fail							; yes, then return 0
		btfsc	INTCON,T0IF							; As there is a resonant frequency in this routine
		goto	Return.Fail							; Check also absolute timing
LF.DetectRising.Debounce
		banksel LF.PORT
		btfss	LFDATA								; is pin low?
		goto	LF.DetectRising						; no, then start from beginning
		banksel Counter
		decfsz	Counter,f							; was the pin low for T_NOISE_MAX?
		goto	LF.DetectRising.Debounce			; no, then test again
		banksel TMR0
		movf	TMR0,w								; store TMR0 value
		clrf	TMR0
		banksel Time
		movwf	Time
		bcf		STATUS,Z
		return
Return.Fail
		bsf		STATUS,Z
		return
	END
