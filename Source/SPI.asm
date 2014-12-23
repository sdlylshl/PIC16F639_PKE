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
#include Project.inc	
;	when overriding these values, you will have to change the source code
#define	AFECS		PORTC,1		; Chip select output
#define	SCK			PORTC,2		; SPI Clock Output
#define	SDIO		PORTC,3		; Serial output
	udata
SPI.BufferH res 1
SPI.BufferL res 1
SPI_ovr	udata_ovr
Count00 res 1
flag_ovr	udata_ovr
flag	res 1		;using bit 0
	global SPI.BufferH, SPI.BufferL
	global SPI.Read, SPI.Write
	code
;------------------------------------------------------------------------------+
;                                                                              |
;     SPI.BufferH  SPI.BufferL SPI.Read( SPI.BufferH  SPI.BufferL )            |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro reads two Bytes from the SPI-Bus.                              |
;    Put the Read command and the address in the SPI.BufferH and SPI.BufferL   |
;    Registers.                                                                |
;    Then call SPI.Read.                                                       |
;    Then read the returned values in SPI.BufferH and SPI.BufferL.             |
;                                                                              |
;                                                                              |
;    Parameters:                                                               |
;    SPI.BufferH - The most significant Byte of the Data                       |
;    SPI.BufferL - The least significant Byte of the Data                      |
;                                                                              |
;                                                                              |
;    Returns:                                                                  |
;    SPI.BufferH - The most significant Byte of the Data                       |
;    SPI.BufferL - The least significant Byte of the Data                      |
;                                                                              |
;                                                                              |
;    Stacklevel: 1                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    pagesel SPI.BufferH                                                       |
;    movlw   0xf0                                                              |
;    movwf   SPI.BufferH                                                       |
;    movlw   0x0f                                                              |
;    movwf   SPI.BufferL                                                       |
;    call    SPI.Read                                                          |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sends 0xf00f over the SPI-Bus, and reads the answer to           |
;        SPI.BufferH and SPI.BufferL.                                          |
;                                                                              |
;------------------------------------------------------------------------------+
SPI.Read
	banksel	flag
	bsf		flag,0
	goto	SPI.ShiftOutBuffer
;------------------------------------------------------------------------------+
;                                                                              |
;    SPI.Write( SPI.BufferH  SPI.BufferL )                                     |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro shifts data out of the MCU through the SPI-Interface.          |
;                                                                              |
;                                                                              |
;    Parameters:                                                               |
;    SPI.BufferH - The most significant Byte of the Data                       |
;    SPI.BufferL - The least significant Byte of the Data                      |
;                                                                              |
;                                                                              |
;                                                                              |
;    Stacklevel: 1                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    pagesel SPI.BufferH                                                       |
;    movlw   0xf0                                                              |
;    movwf   SPI.BufferH                                                       |
;    movlw   0x0f                                                              |
;    movwf   SPI.BufferL                                                       |
;    call    SPI.Write                                                         |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sends 0xf00f over the SPI-Bus                                    |
;                                                                              |
;------------------------------------------------------------------------------+
SPI.Write
	banksel	flag
	bcf		flag,0
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Subroutine: ShiftOutSPIBuffer
;   
; Description: This routine is used to shift data out of the microcontroller
;					onto the SPI bus.
;
;Notes:
;1.	This routine assumes 16-bit data is in SSPBufH and SSPBufL already.
;3.	Control the ports as follows:
;		Clear SCK/ALERT
;		Clear chip select
;Loop
;		Set or clear LFDATA/SDIO pin.
;		Set SCK/ALERT
;		Clear SCK/ALERT
;		Goto Loop 16 times
;		Set chip select
;Count00
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
;	This method shifts data out of the MCU through the SPI-Interface.
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
;	call	SPI.ShiftOutBuffer
;	@end-ex
;	@ex-desc This sends 0xf00f over the SPI-Bus
;
;	@status Tested
;
;	@stacklevel 1
;
;
;
SPI.ShiftOutBuffer	
	banksel TRISC
	movf	TRISC,w
	andlw	b'11110001'
	movwf	TRISC
	movlw	.16
	banksel Count00
	movwf	Count00
	banksel PORTC
	bcf		SCK
	bcf		AFECS
ShiftOutLoop
	banksel SPI.BufferH
	rlf		SPI.BufferL, f
	rlf		SPI.BufferH, f
	banksel	PORTC
	btfss	STATUS,C
	bcf		SDIO
	btfsc	STATUS,C		
	bsf		SDIO
	bsf		SCK
	nop
	nop
	bcf		SCK
;	CLRWDT
	banksel Count00
	decfsz	Count00, f
	goto	ShiftOutLoop
	banksel PORTC
	bsf		AFECS
	bsf		SCK
	banksel	flag
	btfss	flag,0
	goto	SPI.end
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Subroutine: ShiftInSPIBuffer
;   
; Description: This routine is used to shift data into the microcontroller
;					from the SPI bus.
;
;Notes:
;1.	This routine loads 16-bit data into the SSPBufH and SSPBufL registers.
;3.	Control the ports as follows:
;		Clear SCK/ALERT
;		Clear chip select
;Loop
;		Set SCK/ALERT
;		Shift in the LFDATA/SDIO pin value.
;		Clear SCK/ALERT
;		Goto Loop 16 times
;		Set chip select
;Count00
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
;	This method shifts data from the SPI-Bus into the MCU
;
;
;	@return SPI.BufferH The most significant Byte of the Data
;	@return SPI.BufferL The least significant Byte of the Data
;
;	@example
;	call	SPI.ShiftInBuffer
;	banksel SPI.BufferH
;	movf	SPI.BufferH,w
;	banksel RegH
;	movwf	RegH
;	banksel SPI.BufferH
;	movf	SPI.BufferL,w
;	banksel RegL
;	movwf	RegL
;	@end-ex
;	@ex-desc This stores the data from the SPI-Bus in RegH and RegL.
;
;	@status Tested
;
;	@stacklevel 1
;
;
SPI.ShiftInBuffer
	banksel TRISC
	bsf		TRISC,3			;Set SDIO as an input
	banksel Count00
	movlw	.16
	movwf	Count00
	banksel PORTC
	bcf		SCK
	bcf		AFECS
ShiftInLoop
	banksel PORTC
	bsf		SCK
	btfss	SDIO
	bcf		STATUS, C
	btfsc	SDIO			
	bsf		STATUS, C
	bcf		SCK
	banksel SPI.BufferL
	rlf		SPI.BufferL, f
	rlf		SPI.BufferH, f
;	CLRWDT
	banksel Count00
	decfsz	Count00, f
	goto	ShiftInLoop
	banksel PORTC
	bsf		AFECS
	bsf		SCK
SPI.end
	banksel TRISC
	movf	TRISC,w
	iorlw	b'00001110'
	movwf	TRISC	
	
	return
	END