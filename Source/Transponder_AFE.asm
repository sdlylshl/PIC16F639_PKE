;------------------------------------------------------------------------------
;	Transponder_AFE.ASM 
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
AFE.ReadCMD			equ	0xC0
AFE.WriteCMD		equ	0xE0
AFE_ovr	udata
AFE.ConfMap	res 8
COUNTER		res 1
TEMP		res 1
TEMP1		res 1
TEMP2		res 1
TEMP3		res 1
AFE.Buffer	res 1
	global AFE.ConfMap, AFE.Buffer
	global AFE.LoadCfg, AFE.SafeCfg, AFE.ReadCfg, AFE.WriteCfg, AFE.WriteRegister, AFE.ReadRegister, AFE.WriteNVerifyRegister
	global AFE.CalcColumnParity
flag_ovr	udata_ovr
flag	res	1		;using bit 2
;-------------------------------------------
; Default Configuration stored in EEPROM
;-------------------------------------------
EE_SEC	code 
AFE.EEConfig0	DE	b'10100000'	; Wakeup => High = 2ms, Low = 2ms
AFE.EEConfig1	DE	b'00000000'	; Demodulator output
AFE.EEConfig2	DE	b'00000000'
AFE.EEConfig3	DE	b'00000000'
AFE.EEConfig4	DE	b'00000000'
AFE.EEConfig5	DE	b'00000000'	; modulation depth = 50 % for new device
AFE.EEConfig6	DE	b'01011111'	; column parity at defalt mode (50%)
	code
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.LoadCfg()                                                             |
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
;    EEPROM.ReadBytes                                                          |
;                                                                              |
;                                                                              |
;    Stacklevel: 1                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;        call    AFE.LoadCfg                                                   |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        Now the configuration(RAM) has been reatored from the Backup in your  |
;        data EEPROM                                                           |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.LoadCfg
	bankisel	AFE.ConfMap
	movlw	AFE.ConfMap
	movwf	FSR
	movlw	AFE.EEConfig0
	banksel EEPROM.ADDRESS
	movwf	EEPROM.ADDRESS
	movlw	0x7
	call	EEPROM.ReadBytes
	return
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.SafeCfg()                                                             |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This function saves the configuration from the RAM into the EEPROM.       |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: EECON1 FSR     , EEDATA, EEADR, ,                              |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    EEPROM.WriteBytes                                                         |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;        call    AFE.SafeCfg                                                   |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        Now you have a copy of the configuration(RAM) in the data EEPROM of   |
;        your device                                                           |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.SafeCfg
	bankisel	AFE.ConfMap
	movlw	AFE.ConfMap
	movwf	FSR
	movlw	AFE.EEConfig0
	banksel EEPROM.ADDRESS
	movwf	EEPROM.ADDRESS
	movlw	0x7
	call	EEPROM.WriteBytes
	return
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.WriteRegister( w  AFE.ConfMap[x] )                                    |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This function writes to one register file in the AFE.                     |
;    The row parity will be calculated internally.                             |
;    The column parity will be written to the configuration map in RAM.        |
;    NOT to the device.                                                        |
;                                                                              |
;                                                                              |
;    Parameters:                                                               |
;    w - The AFE-Register to write                                             |
;    AFE.ConfMap[x] - The value that should be written to the AFE-Register     |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs:  FSR                                                           |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE.CalcParity                                                            |
;    SPI.Write                                                                 |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;        movlw   0xff                        ;move value to AFE.Buffer         |
;        banksel AFE.ConfMap                                                   |
;        movwf   AFE.ConfMap+4                                                 |
;        movlw   0x04                        ;move register address to w       |
;        call    AFE.WriteRegister           ;writes the register              |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This example sets the Sensitivity Conrol Bits of Channel X and Channel|
;         Y (Register 4)to the maximum.                                        |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.WriteRegister
	banksel	TEMP
	movwf	TEMP
	addlw	AFE.ConfMap
	movwf	FSR
	rlf		TEMP,w
	addlw	AFE.WriteCMD
	banksel SPI.BufferH
	movwf	SPI.BufferH
	bankisel	AFE.ConfMap
	rlf		INDF,w
	banksel SPI.BufferH
	btfss	STATUS,C		
	bcf		SPI.BufferH,0		
	btfsc	STATUS,C		
	bsf		SPI.BufferH,0
	bankisel	AFE.ConfMap
	rlf		INDF,w
	banksel	SPI.BufferH
	movwf	SPI.BufferL
	bcf		SPI.BufferL,0
	bankisel	AFE.ConfMap
	movf	INDF,w
	call	AFE.CalcParity
	banksel	SPI.BufferH
	iorwf	SPI.BufferL,f
	call	SPI.Write
	retlw	0x00				;Debug only
;------------------------------------------------------------------------------+
;                                                                              |
;     w  AFE.ConfMap[x] AFE.ReadRegister( w )                                  |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This function reads one register file in the AFE.                         |
;                                                                              |
;                                                                              |
;    Parameters:                                                               |
;    w - The address of the register to be read                                |
;                                                                              |
;                                                                              |
;    Returns:                                                                  |
;    w - The value in the register (without parity)                            |
;        AFE.ConfMap[x]  Writes - the value to the configuration map in RAM    |
;                                                                              |
;                                                                              |
;    Used SFRs:  FSR                                                           |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    SPI.Read                                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;        movlw   0x04                ;load address of AFE register to w        |
;        call    AFE.ReadRegister    ;read register                            |
;        ;now the value of the register is in w                                |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This example reads the Sensitivity control of Channel X and Y         |
;        (Register 4) to w                                                     |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.ReadRegister
	banksel	TEMP
	movwf	TEMP
	addlw	AFE.ConfMap
	movwf	FSR
	rlf		TEMP,w
	addlw	AFE.ReadCMD
	banksel	SPI.BufferH
	movwf	SPI.BufferH
	call	SPI.Read
	banksel	SPI.BufferH
	rrf		SPI.BufferH,w	;Shift bit 0 in Carry
	rrf		SPI.BufferL,w
	bankisel	AFE.ConfMap
	movwf	INDF			;synchronizing memory map with device
	return
;------------------------------------------------------------------------------+
;                                                                              |
;     w AFE.WriteNVerifyRegister( w  AFE.ConfMap[x] )                          |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This function writes and verifies one register file in the AFE.           |
;                                                                              |
;                                                                              |
;    Parameters:                                                               |
;    w - The AFE-Register to write                                             |
;    AFE.ConfMap[x] - The value that should be written to the AFE-Register     |
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
;    AFE.WriteRegister                                                         |
;        AFE.CalcParity                                                        |
;        SPI.Write                                                             |
;    AFE.ReadRegister                                                          |
;        SPI.Read                                                              |
;                                                                              |
;                                                                              |
;    Stacklevel: 3                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;        movlw   0xff                        ;move value to AFE.Buffer         |
;        banksel AFE.Buffer                                                    |
;        movwf   AFE.Buffer                                                    |
;        movlw   0x04                        ;move register address to w       |
;        call    AFE.WriteNVerifyRegister    ;writes and verifies the register |
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
AFE.WriteNVerifyRegister
	banksel	TEMP2
	movwf	TEMP2
	call	AFE.WriteRegister
	movf	INDF,w
	banksel AFE.Buffer
	movwf	AFE.Buffer
	banksel	TEMP2
	movf	TEMP2,w
	call	AFE.ReadRegister
	banksel AFE.Buffer
	xorwf	AFE.Buffer,w
	btfss	STATUS,Z
	retlw	0x01
	banksel	flag
	btfsc	flag,2
	goto	return_write_cfg
	return
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.WriteCfg()                                                            |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This function writes and verifies the whole register map in the RAM to the|
;     AFE.                                                                     |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: FSR                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE.WriteNVerifyRegister                                                  |
;        AFE.WriteRegister                                                     |
;            AFE.CalcParity                                                    |
;            SPI.Write                                                         |
;        AFE.ReadRegister                                                      |
;            SPI.Read                                                          |
;                                                                              |
;                                                                              |
;    Stacklevel: 3                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;        call    AFE.writeCfg                                                  |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        Now the configuration has been written from your RAM to the AFE       |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.WriteCfg
	call	AFE.CalcColumnParity		;Ensure parity bits are correct
	banksel	flag
	bsf		flag,2
	banksel TEMP3
	movlw	0x07
	movwf	TEMP3
AFE.WriteCfg.loop
	banksel	TEMP3
	bankisel	AFE.ConfMap
	decf	TEMP3,w
	goto	AFE.WriteNVerifyRegister	;reducing stacklevel
return_write_cfg
	banksel	TEMP3
	andlw	0xff
	btfss	STATUS,Z
	retlw	0x01
	decfsz	TEMP3,f
	goto	AFE.WriteCfg.loop
	bcf		flag,2
	
	retlw	0x00
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.ReadCfg()                                                             |
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
;    AFE.ReadRegister                                                          |
;        SPI.Read                                                              |
;                                                                              |
;                                                                              |
;    Stacklevel: 3                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;        call AFE.ReadConfig                                                   |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        That's it. The configuration is now in your RAM at the address        |
;        AFE.ConfMap                                                           |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.ReadCfg
	banksel TEMP3
	movlw	0x07
	movwf	TEMP3
AFE.ReadCfg.loop
	decf	TEMP3,w
	call	AFE.ReadRegister
	banksel TEMP3
	decfsz	TEMP3,f
	goto	AFE.ReadCfg.loop
	
	return
;------------------------------------------------------------------------------+
;                                                                              |
;     w AFE.CalcParity( w )                                                    |
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
;        call    AFE.CalcParity      ;returns the paritybit in w               |
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
AFE.CalcParity
	banksel	TEMP1
	movwf	TEMP1
	movlw	0x00
	movwf	TEMP
	movlw	0x08
	movwf	COUNTER
BeginParityCalc
	rrf		TEMP1,f
	btfsc	STATUS,C
	incf	TEMP,f
	decfsz	COUNTER,f
	goto 	BeginParityCalc
	btfsc	TEMP,0
	retlw	0x00
	retlw	0x01
;------------------------------------------------------------------------------+
;                                                                              |
;     w AFE.CalcColumnParity()                                                 |
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
;        call    AFE.CalcColumnParity        ;Calculate the column parity      |
;        banksel AFE.Buffer                                                    |
;        movwf   AFE.Buffer          ;move parity to transmitbuffer            |
;        movlw   0x6                 ;move address of column parity register to|
;         w                                                                    |
;        call    AFE.WriteRegister   ;write the column parity to the AFE       |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        Calculates the odd parity of 0x02 and sets the parity bit             |
;        (TransmitBuffer,0) appropriate                                        |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.CalcColumnParity
	banksel AFE.ConfMap
	movf	AFE.ConfMap,w
	xorwf	(AFE.ConfMap+1),w
	xorwf	(AFE.ConfMap+2),w
	xorwf	(AFE.ConfMap+3),w
	xorwf	(AFE.ConfMap+4),w
	xorwf	(AFE.ConfMap+5),w
	xorlw	0xff
	movwf	(AFE.ConfMap+6)
	return
;****************************************************** 
;	END OF FILE : AFE_639.ASM
;******************************************************	
	END