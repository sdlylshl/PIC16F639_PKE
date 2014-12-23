	ifndef SPI_INC
#define	SPI_INC

;------------------------------------------------------------------------------+
;                                                                              |
;    Module SPI                                                                |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    SPI.asm                                                                   |
;    Jan Ornter                                                                |
;    DATE:   11-9-2005                                                         |
;    VER.:   1.0                                                               |
;    This class provides functions for the modified physical SPI-Layer         |
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
	extern SPI.BufferH
;------------------------------------------------------------------------------+
;                                                                              |
;    Field SPI.BufferL                                                         |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    Stores the least significant Byte                                         |
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
	extern SPI.BufferL
	extern SPI.Read, SPI.Write
	;extern SPI.ShiftOutBuffer, SPI.ShiftInBuffer
;------------------------------------------------------------------------------+
;                                                                              |
;    SPI.Init()                                                                |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro initialises the SPI module                                     |
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
SPI.Init macro
	banksel TRISC
	movlw	b'11001110'		; Set LFDATA,ALERT, and CS as inputs 
	movwf	TRISC			; 
	banksel	PORTC
	bsf		AFECS			; Take AFE CS Line high
	endm
;
;	This macro shifts data out of the MCU through the SPI-Interface.
;
;
;	@param SPI.BufferH The most significant Byte of the Data
;	@param SPI.BufferL The least significant Byte of the Data
;
;	@example
;	pagesel SPI.BufferH
;	movlw	0xf0
;	movwf	SPI.BufferH
;	movlw	0x0f
;	movwf	SPI.BufferL
;	call	SPI.Write
;	@end-ex
;	@ex-desc This sends 0xf00f over the SPI-Bus
;
;	@status Written
;
;	@stacklevel +1
;
;
;
;SPI.Write macro
;	call	SPI.ShiftOutBuffer
;	endm
;
;	This macro reads two Bytes from the SPI-Bus.
;	Put the Read command and the address in the SPI.BufferH and SPI.BufferL Registers.
;	Then call SPI.Read.
;	Then read the returned values in SPI.BufferH and SPI.BufferL.
;
;
;	@param SPI.BufferH The most significant Byte of the Data
;	@param SPI.BufferL The least significant Byte of the Data
;
;
;	@return SPI.BufferH The most significant Byte of the Data
;	@return SPI.BufferL The least significant Byte of the Data
;
;	@example
;	pagesel SPI.BufferH
;	movlw	0xf0
;	movwf	SPI.BufferH
;	movlw	0x0f
;	movwf	SPI.BufferL
;	call	SPI.Read
;	@end-ex
;	@ex-desc This sends 0xf00f over the SPI-Bus, and reads the answer to SPI.BufferH and SPI.BufferL.
;
;	@status Written
;
;	@stacklevel +1
;
;
;
;SPI.Read macro
;	call	SPI.ShiftOutBuffer
;	call	SPI.ShiftInBuffer
;	endm
	endif
