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
	extern SPI_BufferH
;------------------------------------------------------------------------------+
;                                                                              |
;    Field SPI_BufferL                                                         |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    Stores the least significant Byte                                         |
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
	extern SPI_BufferL
	extern SPI__Read, SPI__Write
	;extern SPI__ShiftOutBuffer, SPI__ShiftInBuffer
;------------------------------------------------------------------------------+
;                                                                              |
;    SPI__Init()                                                                |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro initialises the SPI module                                     |
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
SPI__Init macro
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
;	@param SPI_BufferH The most significant Byte of the Data
;	@param SPI_BufferL The least significant Byte of the Data
;
;	@example
;	banksel SPI_BufferH
;	movlw	0xf0
;	movwf	SPI_BufferH
;	movlw	0x0f
;	movwf	SPI_BufferL
;	call	SPI__Write
;	@end-ex
;	@ex-desc This sends 0xf00f over the SPI-Bus
;
;	@status Written
;
;	@stacklevel +1
;
;
;
;SPI__Write macro
;	call	SPI__ShiftOutBuffer
;	endm
;
;	This macro reads two Bytes from the SPI-Bus.
;	Put the Read command and the address in the SPI_BufferH and SPI_BufferL Registers.
;	Then call SPI__Read.
;	Then read the returned values in SPI_BufferH and SPI_BufferL.
;
;
;	@param SPI_BufferH The most significant Byte of the Data
;	@param SPI_BufferL The least significant Byte of the Data
;
;
;	@return SPI_BufferH The most significant Byte of the Data
;	@return SPI_BufferL The least significant Byte of the Data
;
;	@example
;	banksel SPI_BufferH
;	movlw	0xf0
;	movwf	SPI_BufferH
;	movlw	0x0f
;	movwf	SPI_BufferL
;	call	SPI__Read
;	@end-ex
;	@ex-desc This sends 0xf00f over the SPI-Bus, and reads the answer to SPI_BufferH and SPI_BufferL.
;
;	@status Written
;
;	@stacklevel +1
;
;
;
;SPI__Read macro
;	call	SPI__ShiftOutBuffer
;	call	SPI__ShiftInBuffer
;	endm
	endif
