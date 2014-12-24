;------------------------------------------------------------------------------
;	Transponder_AFE__ASM 
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
; (the "Company") for its PICmicro� Microcontroller is intended and 
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
;    Module Transponder_AFE                                                    |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This class provides access to the Analog Front End.                       |
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
#include Project.inc
#include Delay.inc
#include SPI.inc
#include EEPROM.inc
;equ 相当于 #define
AFE_READCMD			equ	0xC0
AFE_WRITECMD		equ	0xE0
;
AFE_ovr	udata
COUNTER		res 1
TEMP		res 1
TEMP1		res 1
TEMP2		res 1
TEMP3		res 1
AFE_Buffer	res 1
AFE_ConfMap	res 8

	global AFE_ConfMap, AFE_Buffer,flag
	global AFE__LoadCfg, AFE__SafeCfg, AFE__ReadCfg, AFE__WriteCfg, AFE__WriteRegister, AFE__ReadRegister, AFE__WriteNVerifyRegister
	global AFE__CalcColumnParity
flag_ovr	udata_ovr
flag	res	1		;using bit 2
;-------------------------------------------
; Default Configuration stored in EEPROM
;-------------------------------------------
EE_SEC	code 
AFE_EEConfig0	DE	b'10100000'	; Wakeup => High = 2ms, Low = 2ms
AFE_EEConfig1	DE	b'00000000'	; Demodulator output
AFE_EEConfig2	DE	b'00000000'
AFE_EEConfig3	DE	b'00000000'
AFE_EEConfig4	DE	b'00000000'
AFE_EEConfig5	DE	b'00000000'	; modulation depth = 50 % for new device
AFE_EEConfig6	DE	b'01011111'	; column parity at defalt mode (50%)
	code
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__LoadCfg()                                                             |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This function loads the default configuration from the EEPROM and stores  |
;    it in the RAM.                                                            |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: FSR     , EEADR, EEDATA, EECON1                                |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    EEPROM__ReadBytes                                                          |
;                                                                              |
;                                                                              |
;    Stacklevel: 1                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;        call    AFE__LoadCfg                                                   |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        Now the configuration(RAM) has been reatored from the Backup in your  |
;        data EEPROM                                                           |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__LoadCfg
	bankisel	AFE_ConfMap
	movlw	AFE_ConfMap
	movwf	FSR
	movlw	AFE_EEConfig0
	banksel EEPROM_ADDRESS
	movwf	EEPROM_ADDRESS
	movlw	0x7
	call	EEPROM__ReadBytes
	return
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__SafeCfg()                                                             |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This function saves the configuration from the RAM into the EEPROM__       |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: EECON1 FSR     , EEDATA, EEADR, ,                              |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    EEPROM__WriteBytes                                                         |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;        call    AFE__SafeCfg                                                   |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        Now you have a copy of the configuration(RAM) in the data EEPROM of   |
;        your device                                                           |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__SafeCfg
	bankisel	AFE_ConfMap
	movlw	AFE_ConfMap
	movwf	FSR
	movlw	AFE_EEConfig0
	banksel EEPROM_ADDRESS
	movwf	EEPROM_ADDRESS
	movlw	0x7
	call	EEPROM__WriteBytes
	return
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__WriteRegister( w  AFE_ConfMap[x] )                                    |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This function writes to one register file in the AFE__                     |
;    The row parity will be calculated internally.                             |
;    The column parity will be written to the configuration map in RAM.        |
;    NOT to the device.                                                        |
;                                                                              |
;                                                                              |
;    Parameters:                                                               |
;    w - The AFE-Register to write                                             |
;    AFE_ConfMap[x] - The value that should be written to the AFE-Register     |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs:  FSR                                                           |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE__CalcParity                                                            |
;    SPI__Write                                                                 |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;        movlw   0xff                        ;move value to AFE_Buffer         |
;        banksel AFE_ConfMap                                                   |
;        movwf   AFE_ConfMap+4                                                 |
;        movlw   0x04                        ;move register address to w       |
;        call    AFE__WriteRegister           ;writes the register              |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This example sets the Sensitivity Conrol Bits of Channel X and Channel|
;         Y (Register 4)to the maximum.                                        |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__WriteRegister
	banksel	TEMP
	movwf	TEMP
	addlw	AFE_ConfMap
	movwf	FSR
	rlf		TEMP,W
	addlw	AFE_WRITECMD
	banksel SPI_BufferH
	movwf	SPI_BufferH
	bankisel	AFE_ConfMap
	rlf		INDF,W
	banksel SPI_BufferH
	btfss	STATUS,C		
	bcf		SPI_BufferH,0		
	btfsc	STATUS,C		
	bsf		SPI_BufferH,0
	bankisel	AFE_ConfMap
	rlf		INDF,W
	banksel	SPI_BufferH
	movwf	SPI_BufferL
	bcf		SPI_BufferL,0
	bankisel	AFE_ConfMap
	movf	INDF,W
	call	AFE__CalcParity
	banksel	SPI_BufferH
	iorwf	SPI_BufferL,F
	call	SPI__Write
	retlw	0x00				;Debug only
;------------------------------------------------------------------------------+
;                                                                              |
;     w  AFE_ConfMap[x] AFE__ReadRegister( w )                                  |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This function reads one register file in the AFE__                         |
;                                                                              |
;                                                                              |
;    Parameters:                                                               |
;    w - The address of the register to be read                                |
;                                                                              |
;                                                                              |
;    Returns:                                                                  |
;    w - The value in the register (without parity)                            |
;        AFE_ConfMap[x]  Writes - the value to the configuration map in RAM    |
;                                                                              |
;                                                                              |
;    Used SFRs:  FSR                                                           |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    SPI__Read                                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;        movlw   0x04                ;load address of AFE register to w        |
;        call    AFE__ReadRegister    ;read register                            |
;        ;now the value of the register is in w                                |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This example reads the Sensitivity control of Channel X and Y         |
;        (Register 4) to w                                                     |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__ReadRegister
	banksel	TEMP
	movwf	TEMP
	addlw	AFE_ConfMap
	movwf	FSR
	rlf		TEMP,W
	addlw	AFE_READCMD
	banksel	SPI_BufferH
	movwf	SPI_BufferH
	call	SPI__Read
	banksel	SPI_BufferH
	rrf		SPI_BufferH,W	;Shift bit 0 in Carry
	rrf		SPI_BufferL,W
	bankisel	AFE_ConfMap
	movwf	INDF			;synchronizing memory map with device
	return
;------------------------------------------------------------------------------+
;                                                                              |
;     w AFE__WriteNVerifyRegister( w  AFE_ConfMap[x] )                          |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This function writes and verifies one register file in the AFE__           |
;                                                                              |
;                                                                              |
;    Parameters:                                                               |
;    w - The AFE-Register to write                                             |
;    AFE_ConfMap[x] - The value that should be written to the AFE-Register     |
;                                                                              |
;                                                                              |
;    Returns:                                                                  |
;    w - 0 if succesfull, 1 otherwise                                          |
;                                                                              |
;                                                                              |
;    Used SFRs: FSR                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE__WriteRegister                                                         |
;        AFE__CalcParity                                                        |
;        SPI__Write                                                             |
;    AFE__ReadRegister                                                          |
;        SPI__Read                                                              |
;                                                                              |
;                                                                              |
;    Stacklevel: 3                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;        movlw   0xff                        ;move value to AFE_Buffer         |
;        banksel AFE_Buffer                                                    |
;        movwf   AFE_Buffer                                                    |
;        movlw   0x04                        ;move register address to w       |
;        call    AFE__WriteNVerifyRegister    ;writes and verifies the register |
;        andlw   0xff                        ;update status register           |
;        btfss   STATUS,Z                    ;was there an error               |
;        goto    errorOccured                ;yes, the goto error handler      |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This example sets the Sensitivity Conrol Bits of Channel X and Channel|
;         Y (Register 4)to the maximum.                                        |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__WriteNVerifyRegister
	banksel	TEMP2
	movwf	TEMP2
	call	AFE__WriteRegister
	movf	INDF,W
	banksel AFE_Buffer
	movwf	AFE_Buffer
	banksel	TEMP2
	movf	TEMP2,W
	call	AFE__ReadRegister
	banksel AFE_Buffer
	xorwf	AFE_Buffer,W
	btfss	STATUS,Z
	retlw	0x01
	banksel	flag
	btfsc	flag,2
	goto	return_write_cfg
	return
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__WriteCfg()                                                            |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This function writes and verifies the whole register map in the RAM to the|
;     AFE__                                                                     |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: FSR                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE__WriteNVerifyRegister                                                  |
;        AFE__WriteRegister                                                     |
;            AFE__CalcParity                                                    |
;            SPI__Write                                                         |
;        AFE__ReadRegister                                                      |
;            SPI__Read                                                          |
;                                                                              |
;                                                                              |
;    Stacklevel: 3                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;        call    AFE__writeCfg                                                  |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        Now the configuration has been written from your RAM to the AFE       |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__WriteCfg
	call	AFE__CalcColumnParity		;Ensure parity bits are correct
	banksel	flag
	bsf		flag,2
	banksel TEMP3
	movlw	0x07
	movwf	TEMP3
AFE__WriteCfg.loop
	banksel	TEMP3
	bankisel	AFE_ConfMap
	decf	TEMP3,W
	goto	AFE__WriteNVerifyRegister	;reducing stacklevel
return_write_cfg
	banksel	TEMP3
	andlw	0xff
	btfss	STATUS,Z
	retlw	0x01
	decfsz	TEMP3,F
	goto	AFE__WriteCfg.loop
	bcf		flag,2
	
	retlw	0x00
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__ReadCfg()                                                             |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This function reads the whole register map from the AFE to the RAM.       |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs:      FSR                                                       |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE__ReadRegister                                                          |
;        SPI__Read                                                              |
;                                                                              |
;                                                                              |
;    Stacklevel: 3                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;        call AFE__ReadConfig                                                   |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        That's it. The configuration is now in your RAM at the address        |
;        AFE_ConfMap                                                           |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__ReadCfg
	banksel TEMP3
	movlw	0x07
	movwf	TEMP3
AFE__ReadCfg.loop
	decf	TEMP3,W
	call	AFE__ReadRegister
	banksel TEMP3
	decfsz	TEMP3,F
	goto	AFE__ReadCfg.loop
	
	return
;------------------------------------------------------------------------------+
;                                                                              |
;     w AFE__CalcParity( w )                                                    |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This calculates the odd parity of a Byte.                                 |
;                                                                              |
;                                                                              |
;    Parameters:                                                               |
;    w - The byte to calculate odd parity from                                 |
;                                                                              |
;                                                                              |
;    Returns:                                                                  |
;    w - The parity bit                                                        |
;                                                                              |
;                                                                              |
;    Stacklevel: 1                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;        movlw   0x02                    ;move the byte the parity should be   |
;        calculated from in w                                                  |
;        call    AFE__CalcParity      ;returns the paritybit in w               |
;        andlw   0xff                ;setting the STATUS register              |
;        banksel TransmitBuffer                                                |
;        btfss   STATUS,Z            ;next if Parity is one                    |
;        bsf     TransmitBuffer,0    ;set Parity Bit(suggested it is Bit 0 in  |
;        TransmitBuffer)                                                       |
;        btfsc   STATUS,Z            ;next if Parity is zero                   |
;        bcf     TransmitBuffer,0    ;clear Parity Bit                         |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        Calculates the odd parity of 0x02 and sets the parity bit             |
;        (TransmitBuffer,0) appropriate                                        |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__CalcParity
	banksel	TEMP1
	movwf	TEMP1
	movlw	0x00
	movwf	TEMP
	movlw	0x08
	movwf	COUNTER
BeginParityCalc
	rrf		TEMP1,F
	btfsc	STATUS,C
	incf	TEMP,F
	decfsz	COUNTER,F
	goto 	BeginParityCalc
	btfsc	TEMP,0
	retlw	0x00
	retlw	0x01
;------------------------------------------------------------------------------+
;                                                                              |
;     w AFE__CalcColumnParity()                                                |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This calculates the odd column parity of the configuration register.      |
;                                                                              |
;                                                                              |
;    Returns:                                                                  |
;    w - The parity byte                                                       |
;                                                                              |
;                                                                              |
;    Stacklevel: 1                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;        call    AFE__CalcColumnParity        ;Calculate the column parity     |
;        banksel AFE_Buffer                                                   |
;        movwf   AFE_Buffer          ;move parity to transmitbuffer           |
;        movlw   0x6                 ;move address of column parity register to|
;         w                                                                    |
;        call    AFE__WriteRegister   ;write the column parity to the AFE      |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        Calculates the odd parity of 0x02 and sets the parity bit             |
;        (TransmitBuffer,0) appropriate                                        |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__CalcColumnParity
	banksel AFE_ConfMap
	movf	AFE_ConfMap,W
	xorwf	(AFE_ConfMap+1),w
	xorwf	(AFE_ConfMap+2),w
	xorwf	(AFE_ConfMap+3),w
	xorwf	(AFE_ConfMap+4),w
	xorwf	(AFE_ConfMap+5),w
	xorlw	0xff				;��λȡ��
	movwf	(AFE_ConfMap+6)
	return
;****************************************************** 
;	END OF FILE : AFE_639.ASM
;******************************************************	
	END
