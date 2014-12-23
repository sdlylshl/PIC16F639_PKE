;------------------------------------------------------------------------------
;	EEPROM.ASM --- PIC16F636/9 EEPROM Functions
;
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


;------------------------------------------------------------------------------+
;                                                                              |
;    Module EEPROM                                                             |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This class provides commonly used methods for the built-in EEPROM         |
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
#include Project.inc
	udata
EEPROM.ADDRESS		res 1
EEPROM.ByteCount	res 1
	global EEPROM.ADDRESS, EEPROM.ByteCount
	global EEPROM.Write, EEPROM.WriteBytes, EEPROM.Read, EEPROM.ReadBytes
	
flag_ovr	udata_ovr
flag res 1		;using bit 1 of flag register
;------------------------------------------------------------------------------+
;                                                                              |
;    EEPROM.Write( w  EEPROM.ADDRESS )                                         |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This function writes one byte of data to the EEPROM.                      |
;                                                                              |
;                                                                              |
;    Parameters:                                                               |
;    w - The byte of data                                                      |
;    EEPROM.ADDRESS - The address in the EEPROM memory                         |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: EECON1  EEDATA, EEADR, ,                                       |
;                                                                              |
;                                                                              |
;    Stacklevel: 0                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    movlw   0x00                                                              |
;    banksel EEPROM.ADDRESS                                                    |
;    movwf   EEPROM.ADDRESS                                                    |
;    movlw   0x12                                                              |
;    call    EEPROM.Write                                                      |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This writes 0x12 to the address 0x00 in the EEPROM                    |
;                                                                              |
;------------------------------------------------------------------------------+
	code
EEPROM.Write
	banksel	EEDATA
	MOVWF	EEDATA			; Data value to write
	banksel	EEPROM.ADDRESS
	movfw	EEPROM.ADDRESS	; GET EEPROM ADDRESS
	
	banksel	EEADR
	MOVWF	EEADR			; Data memory to write
EEWRITE2
	BSF		EECON1,WREN		; Command Write Enable
	MOVLW	55H
	MOVWF	EECON2			; Write 55H
	MOVLW	0AAH
	MOVWF	EECON2			; Write AAH
	BSF		EECON1,WR		; Command Write
WR_WAIT
	CLRWDT
	BTFSC	EECON1,WR		; Wait for write to complete
	GOTO	WR_WAIT
; ******* EEPROM WRITE DISABLE ****************
EEWRITE3
	BCF		EECON1,WREN			; Disable writes
	banksel	EEPROM.ADDRESS
	INCF	EEPROM.ADDRESS,F	; Auto-increase Address Pointer
	banksel	flag
	btfss	flag,1
	RETLW	0H
	goto	return_write
;------------------------------------------------------------------------------+
;                                                                              |
;    EEPROM.WriteBytes( w  EEPROM.ADDRESS  FSR )                               |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This function writes several bytes of data to the EEPROM.                 |
;    The buffer has to be within bank0 or bank1.                               |
;                                                                              |
;                                                                              |
;    Parameters:                                                               |
;    w - The the number of bytes                                               |
;    EEPROM.ADDRESS - The first address in the EEPROM memory                   |
;    FSR - The first address of the data in your RAM                           |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: EECON1  FSR, EEDATA, EEADR, ,                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 1                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    movlw   0x70                                                              |
;    movwf   FSR                                                               |
;    movlw   0x00                                                              |
;    banksel EEPROM.ADDRESS                                                    |
;    movwf   EEPROM.ADDRESS                                                    |
;    movlw   0x2                                                               |
;    call    EEPROM.WriteBytes                                                 |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This writes the data in 0x70 to the address 0x00 in the EEPROM. And   |
;        the data in 0x71 to the address 0x01 in EEPROM.                       |
;                                                                              |
;------------------------------------------------------------------------------+
EEPROM.WriteBytes
	banksel	flag
	bsf		flag,1
	banksel EEPROM.ByteCount
	movwf	EEPROM.ByteCount
EEPROM.WriteBytes.loop
	bankisel	PORTA
	movf 	INDF,w
	goto	EEPROM.Write
return_write
	incf	FSR,f
	banksel	EEPROM.ByteCount
	decfsz	EEPROM.ByteCount,f
	goto	EEPROM.WriteBytes.loop
	banksel	flag
	bcf		flag,1
	return
;------------------------------------------------------------------------------+
;                                                                              |
;     w EEPROM.Read( EEPROM.ADDRESS )                                          |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This function reads one byte of data from the EEPROM.                     |
;                                                                              |
;                                                                              |
;    Parameters:                                                               |
;    EEPROM.ADDRESS - The Address of the EEPROM Memory                         |
;                                                                              |
;                                                                              |
;    Returns:                                                                  |
;    w - The Byte of Data                                                      |
;                                                                              |
;                                                                              |
;    Used SFRs:  EEADR, EEDATA, EECON1                                         |
;                                                                              |
;                                                                              |
;    Stacklevel: 0                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    movlw   0x00                                                              |
;    banksel EEPROM.ADDRESS                                                    |
;    movwf   EEPROM.ADDRESS                                                    |
;    movlw   0x12                                                              |
;    call    EEPROM.Read                                                       |
;    movwf   Register                                                          |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This reads the Address 0x00 in the EEPROM and stores the Data in      |
;        Register                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
EEPROM.Read
	banksel	EEPROM.ADDRESS
    MOVFW   EEPROM.ADDRESS
	banksel	EEADR
	MOVWF	EEADR				; Data memory address to read
	BSF		EECON1,RD			; Command read
	MOVF	EEDATA,W			; Get data
	banksel	EEPROM.ADDRESS
	INCF	EEPROM.ADDRESS,F	; Auto-increase Address Pointer
	banksel	flag
	btfss	flag,1
	RETURN						; Return without changing w-register
	goto	return_read
;------------------------------------------------------------------------------+
;                                                                              |
;    EEPROM.ReadBytes( EEPROM.ADDRESS  FSR  w )                                |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This function reads one byte of data from the EEPROM.                     |
;    The buffer has to be within bank0 or bank1.                               |
;                                                                              |
;                                                                              |
;    Parameters:                                                               |
;    EEPROM.ADDRESS - The address of the EEPROM memory                         |
;    FSR - The address in the RAM, that should be written                      |
;    w - The number of bytes to read                                           |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs:  FSR, EEADR, EEDATA, EECON1                                    |
;                                                                              |
;                                                                              |
;    Stacklevel: 0                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    movlw   0x70                                                              |
;    movwf   FSR                                                               |
;    movlw   0x00                                                              |
;    banksel EEPROM.ADDRESS                                                    |
;    movwf   EEPROM.ADDRESS                                                    |
;    movlw   0x2                                                               |
;    call    EEPROM.WriteBytes                                                 |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This reads the address 0x00 in the EEPROM and stores the data in 0x70.|
;         The data of 0x01 will be stored in 0x71 in the EEPROM.               |
;                                                                              |
;------------------------------------------------------------------------------+
EEPROM.ReadBytes
	banksel	flag
	bsf		flag,1
	banksel EEPROM.ByteCount
	movwf	EEPROM.ByteCount
EEPROM.ReadBytes.loop
	goto	EEPROM.Read
return_read
	bankisel	PORTA
	movwf 	INDF
	incf	FSR,f
	banksel	EEPROM.ByteCount
	decfsz	EEPROM.ByteCount,f
	goto	EEPROM.ReadBytes.loop
	banksel	flag
	bcf		flag,1
	return
;****************************************************** 
;	END OF FILE : EEPROM.ASM
;******************************************************	
	END
