;------------------------------------------------------------------------------+
;                                                                              |
;    Module RF                                                                 |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    RF.asm                                                                    |
;    Jan Ornter                                                                |
;    DATE:   11-9-2005                                                         |
;    VER.:   1.0                                                               |
;    This class provides access to the optionally RF-Interface.                |
;    It will transmit a header (see below) and pulse with modulated data (see  |
;    below).                                                                   |
;                                                                              |
;                                                                              |
;     Transmission frame                                                       |
;           |<                 Header                   >|<        Data        |
;               >|                                                             |
;           |<  Init >|< Gap >|<   High    >|<   Low    >|                     |
;            _________         _____________              _                    |
;        ___|         |_______|             |____________|                     |
;        XXXXXXXXXXXXXXXXXXXXXXXXX____                                         |
;------------------------------------------------------------------------------+
#include "Project.inc"
#include "Delay.inc"
#ifndef RF.PIN
	#define RF.PIN		5		; RF Modulation Output
	#define RF.PORT		PORTC
#endif
RF_ovr	udata_ovr
Parity			res 1
RF.COUNTER		res 1
RF.Byte_Counter	res 1
RF.Data_REG		res 1
	ifndef RF.T_HDR_INIT
;------------------------------------------------------------------------------+
;                                                                              |
;    Constant RF.T_HDR_INIT                                                    |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    The initial high time of the header in micro seconds.                     |
;                                                                              |
;                                                                              |
;     Transmission frame                                                       |
;           |<  T_HDR_INIT >|< T_HDR_GAP >|<   T_HDR_HIGH    >|<   T_HDR_LOW   |
;            >|                                                                |
;            _______________               ___________________                 |
;               _                                                              |
;        ___|               |_____________|                                    |
;        |__________________|                                                  |
;------------------------------------------------------------------------------+
#define RF.T_HDR_INIT .4100
	endif
	ifndef RF.T_HDR_GAP
;------------------------------------------------------------------------------+
;                                                                              |
;    Constant RF.T_HDR_GAP                                                     |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    The time of the gap between the initial high time and the filter-sequence.|
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
#define RF.T_HDR_GAP .550
	endif
	ifndef RF.T_HDR_HIGH
;------------------------------------------------------------------------------+
;                                                                              |
;    Constant RF.T_HDR_HIGH                                                    |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    The high time of the filter-sequence.                                     |
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
#define RF.T_HDR_HIGH .2100
	endif
	ifndef RF.T_HDR_LOW
;------------------------------------------------------------------------------+
;                                                                              |
;    Constant RF.T_HDR_LOW                                                     |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    The low time of the filter-sequence.                                      |
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
#define RF.T_HDR_LOW .2100
	endif
	ifndef RF.T_STEP
;------------------------------------------------------------------------------+
;                                                                              |
;    Constant RF.T_STEP                                                        |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This time adjusts the bitrate of the data transmission.                   |
;                                                                              |
;                                                                              |
;     A pwm coded '1'                                                          |
;         |<   T_STEP  >|<        2*T_STEP         >|                          |
;          _____________                                                       |
;        _|             |___________________________|                          |
;------------------------------------------------------------------------------+
#define RF.T_STEP .250
	endif
	
	
	
	
	global RF.Send_Header, RF.Send_Data, RF.SendBuffer
	code
;------------------------------------------------------------------------------+
;                                                                              |
;    RF.SendBuffer( w  FSR )                                                   |
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
;    Stacklevel: 3                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    movlw   AFE.ConfData                                                      |
;    movwf   FSR                                                               |
;    movlw   0x07                                                              |
;    call    RF.SendBuffer                                                     |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sends 7 bytes of the buffer "AFE.ConfMap" to the air             |
;                                                                              |
;------------------------------------------------------------------------------+
RF.SendBuffer
	banksel	RF.Byte_Counter
	movwf	RF.Byte_Counter
	call	RF.Send_Header
RF.SendBuffer.loop
	bankisel	PORTA
	movf	INDF,w
	call	RF.Send_Data
	incf	FSR,f
	banksel RF.Byte_Counter
	decfsz	RF.Byte_Counter,f
	goto	RF.SendBuffer.loop
	return
	
;----------------------------------------------------
;	Send UHF Data Byte
;	Data format: 
; ---------------------------------------------------
;------------------------------------------------------------------------------+
;                                                                              |
;    RF.Send_Data( w )                                                         |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This function will transmit one byte of data over the RF antenna.         |
;    The value in w will be sent to the air over the RF antenna.               |
;                                                                              |
;                                                                              |
;    Parameters:                                                               |
;    w - The Byte of data to be sent                                           |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs:    INTCON OPTION_REG                                           |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    Delay.start                                                               |
;    Delay.wait                                                                |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    movlw   0xf0                                                              |
;    call    RF.Send_Data                                                      |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sends 0xf0 over the RF antenna                                   |
;                                                                              |
;------------------------------------------------------------------------------+
RF.Send_Data
	banksel RF.Data_REG
	movwf	RF.Data_REG		; Load Data to Send
	clrf	Parity
	; Send Byte using UHF transmitter
Transmit8	
	banksel RF.COUNTER
	movlw	.8
	movwf	RF.COUNTER	; initialize count register
TransmitNext
	banksel RF.Data_REG
	rrf		RF.Data_REG, f		; rotate receive register
	btfsc	STATUS, C		; test bit to be transmited
	goto	SendOne			; send high value
SendZero
	call 	Delay.Wait
	banksel RF.PORT
	bsf		RF.PORT,RF.PIN	; rf modulation on
	movlw	((2*RF.T_STEP)/.50)
	call 	Delay.start
	call 	Delay.Wait
	banksel RF.PORT
	bcf		RF.PORT,RF.PIN	; rf modulation off
	movlw	(RF.T_STEP/.50)
	call 	Delay.start
	goto	SendNextBit		; send next bit
SendOne
	call 	Delay.Wait
	banksel RF.PORT
	bsf		RF.PORT,RF.PIN	; rf modulation on
	movlw	(RF.T_STEP/.50)
	call 	Delay.start
	call 	Delay.Wait
	banksel RF.PORT
	bcf		RF.PORT,RF.PIN	; rf modulation off
	movlw	((2*RF.T_STEP)/.50)
	call 	Delay.start
	banksel	Parity
	incf	Parity,f
;	goto	SendNextBit		; send next bit
SendNextBit	
	banksel RF.COUNTER
	movf	RF.COUNTER,f
	btfsc	STATUS,Z
	goto	EndTX
	decfsz	RF.COUNTER, f	; decrement counter register
	goto	TransmitNext 	; transmit next bit
SendParity
;	btfsc	Parity,7
;	goto	EndTX
;	bsf		Parity,7
	btfss	Parity,0
	goto	SendOne
	banksel Parity
	btfsc	Parity,0
	goto	SendZero
EndTX
	call 	Delay.Wait
	retlw	0x00			; return to main routine
;----------------------------------------------------
;	Same as the LF data
;	Data format: (4ms + 500us + 2ms + 2ms) 
; ---------------------------------------------------
;------------------------------------------------------------------------------+
;                                                                              |
;    RF.Send_Header()                                                          |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This function will transmit the header over the RF antenna.               |
;    The header is used to activate the receiver.                              |
;    Data format: (4ms + 500us + 2ms + 2ms)                                    |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs:    INTCON OPTION_REG                                           |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    Delay.start                                                               |
;    Delay.wait                                                                |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    call    RF.Send_Header                                                    |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sends the header                                                 |
;                                                                              |
;------------------------------------------------------------------------------+
RF.Send_Header
	banksel	RF.PORT
	bsf		RF.PORT,RF.PIN	; modulation data for rf
	movlw	(RF.T_HDR_INIT/.50)
	call	Delay.start
	call	Delay.Wait
	banksel	RF.PORT
	bcf		RF.PORT,RF.PIN	; turn off modulation data for rf
	movlw	(RF.T_HDR_GAP/.50)
	call	Delay.start
	call	Delay.Wait
	banksel	RF.PORT
	bsf		RF.PORT,RF.PIN	; modulation data for rf
	MOVLW	(RF.T_HDR_HIGH/.50)
	call	Delay.start
	call	Delay.Wait
	banksel	RF.PORT
	bcf		RF.PORT,RF.PIN	; turn off modulation data for rf
	movlw	(RF.T_HDR_LOW/.50)
	call	Delay.start
	return	
;****************************************************** 
;	END OF FILE : UHF_TX.ASM
;******************************************************	
	END
