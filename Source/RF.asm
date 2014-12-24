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
#ifndef RF__PIN
	#define RF__PIN		5		; RF Modulation Output
	#define RF__PORT		PORTC
#endif
RF_ovr	udata_ovr
RF_COUNTER		res 1
RF_Byte_Counter	res 1
RF_Data_REG		res 1
Parity			res 1

	ifndef RF__T_HDR_INIT
;------------------------------------------------------------------------------+
;                                                                              |
;    Constant RF__T_HDR_INIT                                                    |
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
#define RF__T_HDR_INIT .4100
	endif
	ifndef RF__T_HDR_GAP
;------------------------------------------------------------------------------+
;                                                                              |
;    Constant RF__T_HDR_GAP                                                     |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    The time of the gap between the initial high time and the filter-sequence.|
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
#define RF__T_HDR_GAP .550
	endif
	ifndef RF__T_HDR_HIGH
;------------------------------------------------------------------------------+
;                                                                              |
;    Constant RF__T_HDR_HIGH                                                    |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    The high time of the filter-sequence.                                     |
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
#define RF__T_HDR_HIGH .2100
	endif
	ifndef RF__T_HDR_LOW
;------------------------------------------------------------------------------+
;                                                                              |
;    Constant RF__T_HDR_LOW                                                     |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    The low time of the filter-sequence.                                      |
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
#define RF__T_HDR_LOW .2100
	endif
	ifndef RF__T_STEP
;------------------------------------------------------------------------------+
;                                                                              |
;    Constant RF__T_STEP                                                        |
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
#define RF__T_STEP .250
	endif
	
	
	
	
	global RF__Send_Header, RF__Send_Data, RF__SendBuffer
	code
;------------------------------------------------------------------------------+
;                                                                              |
;    RF__SendBuffer( w  FSR )                                                   |
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
;    movlw   AFE__ConfData                                                      |
;    movwf   FSR                                                               |
;    movlw   0x07                                                              |
;    call    RF__SendBuffer                                                     |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sends 7 bytes of the buffer "AFE_ConfMap" to the air             |
;                                                                              |
;------------------------------------------------------------------------------+
RF__SendBuffer
	banksel	RF_Byte_Counter
	movwf	RF_Byte_Counter
	call	RF__Send_Header
RF__SendBuffer.loop
	bankisel	PORTA
	movf	INDF,W
	call	RF__Send_Data
	incf	FSR,F
	banksel RF_Byte_Counter
	decfsz	RF_Byte_Counter,F
	goto	RF__SendBuffer.loop
	return
	
;----------------------------------------------------
;	Send UHF Data Byte
;	Data format: 
; ---------------------------------------------------
;------------------------------------------------------------------------------+
;                                                                              |
;    RF__Send_Data( w )                                                         |
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
;    DELAY__start                                                               |
;    DELAY__wait                                                                |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    movlw   0xf0                                                              |
;    call    RF__Send_Data                                                      |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sends 0xf0 over the RF antenna                                   |
;                                                                              |
;------------------------------------------------------------------------------+
RF__Send_Data
	banksel RF_Data_REG
	movwf	RF_Data_REG		; Load Data to Send
	clrf	Parity
	; Send Byte using UHF transmitter
Transmit8	
	banksel RF_COUNTER
	movlw	.8
	movwf	RF_COUNTER	; initialize count register
TransmitNext
	banksel RF_Data_REG
	rrf		RF_Data_REG, f		; rotate receive register
	btfsc	STATUS, C		; test bit to be transmited
	goto	SendOne			; send high value
SendZero
	call 	DELAY__Wait
	banksel RF__PORT
	bsf		RF__PORT,RF__PIN	; rf modulation on
	movlw	((2*RF__T_STEP)/.50)
	call 	DELAY__start
	call 	DELAY__Wait
	banksel RF__PORT
	bcf		RF__PORT,RF__PIN	; rf modulation off
	movlw	(RF__T_STEP/.50)
	call 	DELAY__start
	goto	SendNextBit		; send next bit
SendOne
	call 	DELAY__Wait
	banksel RF__PORT
	bsf		RF__PORT,RF__PIN	; rf modulation on
	movlw	(RF__T_STEP/.50)
	call 	DELAY__start
	call 	DELAY__Wait
	banksel RF__PORT
	bcf		RF__PORT,RF__PIN	; rf modulation off
	movlw	((2*RF__T_STEP)/.50)
	call 	DELAY__start
	banksel	Parity
	incf	Parity,F
;	goto	SendNextBit		; send next bit
SendNextBit	
	banksel RF_COUNTER
	movf	RF_COUNTER,F
	btfsc	STATUS,Z
	goto	EndTX
	decfsz	RF_COUNTER, f	; decrement counter register
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
	call 	DELAY__Wait
	retlw	0x00			; return to main routine
;----------------------------------------------------
;	Same as the LF data
;	Data format: (4ms + 500us + 2ms + 2ms) 
; ---------------------------------------------------
;------------------------------------------------------------------------------+
;                                                                              |
;    RF__Send_Header()                                                          |
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
;    DELAY__start                                                               |
;    DELAY__wait                                                                |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    call    RF__Send_Header                                                    |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sends the header                                                 |
;                                                                              |
;------------------------------------------------------------------------------+
RF__Send_Header
	banksel	RF__PORT
	bsf		RF__PORT,RF__PIN	; modulation data for rf
	movlw	(RF__T_HDR_INIT/.50)
	call	DELAY__start
	call	DELAY__Wait
	banksel	RF__PORT
	bcf		RF__PORT,RF__PIN	; turn off modulation data for rf
	movlw	(RF__T_HDR_GAP/.50)
	call	DELAY__start
	call	DELAY__Wait
	banksel	RF__PORT
	bsf		RF__PORT,RF__PIN	; modulation data for rf
	MOVLW	(RF__T_HDR_HIGH/.50)
	call	DELAY__start
	call	DELAY__Wait
	banksel	RF__PORT
	bcf		RF__PORT,RF__PIN	; turn off modulation data for rf
	movlw	(RF__T_HDR_LOW/.50)
	call	DELAY__start
	return	
;****************************************************** 
;	END OF FILE : UHF_TX.ASM
;******************************************************	
	END
