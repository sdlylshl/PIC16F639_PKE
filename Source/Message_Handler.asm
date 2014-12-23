;------------------------------------------------------------------------------+
;                                                                              |
;    Module Message_Handler                                                    |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
; Message_Handler.asm                                                          |
;    Jan Ornter                                                                |
;    DATE:   11-9-2005                                                         |
;    VER.:   1.0                                                               |
;    This class handles the incoming messages                                  |
;    The function MESSAGE_HANDLER will be called, everytime the rx line goes   |
;    high.                                                                     |
;    After it is called, the REC_EVENTS will be disabled.                      |
;    To ensure that the function is been called at the right time, the         |
;    rx line should still be high, if not the function will end without        |
;    trying to receive more bits. When this is not the case, LF.Receive8       |
;    will be called, to receive the command from the base station.             |
;    The received byte will be interpreted as a command and the command        |
;    specific code will be executeted. For a more detailed description of      |
;    the function, see the flow chart below or refer to the source code.       |
;    At last the REC_EVENT will be enabled and the subroutine ends.            |
;                                                                              |
;                                                                              |
;     Basestation first hand shake                                             |
;            |<   LF-Header        >|< 10-bits  = command(ID)+ Parity + 1 stop |
;            bit  >|                                                           |
;             __________   ____      _   _                                     |
;        ____|          |_|    |____| |_|                                      |
;        |_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX                           |
;------------------------------------------------------------------------------+
#include	Project.inc
#include	PIC16F639.inc
#include	LF.inc
#include	RF.inc
#include	EEPROM.inc
#include	Delay.inc
#include	AFE_639.inc
	global	MESSAGE_HANDLER
	udata
COUNTER		res	1
MOD_DEPTH	res 1
LF_CMD		res 1
;------------------------------------
CSR0	res	1		; 64-bit transmission buffer
CSR1	res	1
CSR2	res	1
CSR3	res	1
CSR4	res	1
CSR5	res	1
CSR6	res	1
CSR7	res	1
DAT0	res	1		; 32-bit data buffer
DAT1	res	1
DAT2	res	1
DAT3	res	1
SER0	res	1		; 32-bit Serial number buffer
SER1	res	1
SER2	res	1
SER3	res	1
	code
	
;------------------------------------------------------------------------------+
;                                                                              |
;    MESSAGE_HANDLER()                                                         |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This function is called by the main routine, whenever an incoming         |
;    LF-Message is detected.                                                   |
;    iT is responsible for receiving, interpreting and if necassary answering  |
;    the message.                                                              |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: OPTION_REG INTCON Delay.Returned EECON1 EEADR, EEDATA, TMR0    |
;    PORTC                                                                     |
;      ,                                                                       |
;     _w_x_50u                                                                 |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    LF.Receive8                                                               |
;    EEPROM.Write                                                              |
;    EEPROM.Read                                                               |
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
;    RF.Send_Header                                                            |
;        Delay.start                                                           |
;        Delay.wait                                                            |
;    RF.Send_Data                                                              |
;        Delay.start                                                           |
;        Delay.wait                                                            |
;    LF.ReadBuffer                                                             |
;        AFE.Receive8                                                          |
;    RF.SendBuffer                                                             |
;    Delay.wait_w_x_50u                                                        |
;    _w_x_50u                                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 4                                                             |
;                                                                              |
;------------------------------------------------------------------------------+
MESSAGE_HANDLER
	banksel	IOCA
	bcf		IOCA,REC_EVENT		; Disabling further message events, while current message is beeing received
	banksel	TRISC
	movlw	b'11001110'			; Set LFDATA,ALERT, and CS as inputs 
	movwf	TRISC
	banksel PORTA
	bcf		CommsLED			; Indicate LF Comms Activity
	movlw	0x02				; Filter short spikes
	banksel	COUNTER
	movwf	COUNTER
NOISE
	banksel	COUNTER
	decf	COUNTER,f
	btfsc	STATUS,Z
	goto	M_END_IMMEDIATE		; Prevent deadlocks because of noise on the line
	banksel	PORTC
	btfss	LFDATA				; Data still high?
	goto	NOISE				; Event happened too long ago. Wait for next event
	Call	LF.Receive8			; Receive Byte From Basestation
	btfsc	STATUS,Z
	goto	M_Failed
	banksel LF_CMD
	movwf	LF_CMD				; Store Command
; ****** LF Command Handler *****************************
	movlw	0x5A			; Check for IFF Command
	xorwf	LF_CMD,w		; Compare with received command byte
	btfsc	STATUS,Z		; Equal?
	goto	IFF_CMD			; ... Yes, then execute IFF Command
	movlw	0x69			; Check for Read Serial Number Command
	xorwf	LF_CMD,w		; Compare with received command byte
	btfsc	STATUS,Z		; Equal?
	goto	READ_SERIAL		; ... Yes, then execute Get Serial Number Command
	movlw	0x7E			; Check for RSSI Command
	xorwf	LF_CMD,w		; Compare with received command byte
	btfsc	STATUS,Z		; Equal?
	goto	RSSI_CMD			; ... Yes, then execute Get RSSI Reading Command
	movlw	0x9C			; USER EEPROM Read Command
	xorwf	LF_CMD,w		; Compare with received command byte
	andlw	0xFC			; Mask out Address bits
	btfsc	STATUS,Z		; Equal?
	goto	READ_USR		; ... Yes, then execute READ_USR Command
; disabled to prevent accidenial writes
;	movlw	0x6C			; USER EEPROM Write Command
;	xorwf	LF_CMD,w		; Compare with received command byte
;	andlw	0xFC			; Mask out Address bits
;	btfsc	STATUS,Z		; Equal?
;	goto	WRITE_USR		; ... Yes, then execute WRITE_USR Command
	goto	M_Failed	
M_END
	;Code to indicate correct reception may be placed here
M_END_IMMEDIATE
	; Reset the device, to cancel noise and apply output filter again (not necessary)
	AFE.SendCMDSoftReset
	banksel	IOCA
	bsf		IOCA,REC_EVENT		; Enable Rx Line interrupt on change
	banksel	PORTA
	bcf		EVENT_REG,REC_EVENT	; Remove current message from event list
	bsf		CommsLED			; Turn D5 LED Off
	return
M_Failed
;	You may switch some options to improve signal here
;	AFE.SendCMDAGCPresON 
;	banksel MOD_DEPTH
;	decf	MOD_DEPTH,f
;	swapf	MOD_DEPTH,w
;	andlw	0x30
;	AFE.setModDepth
;	AFE.AGCActive
;	movlw	0x0f
;	AFE.setXSensitivity
	goto	M_END_IMMEDIATE
; ***********************************************************************
; WRITE_USR()
; ***********************************************************************
WRITE_USR
; ******* Receive 16-bit LF data from Base-station ******
WRITE_USR2
	Call	LF.Receive8			; Receive Byte From Basestation
	btfsc	STATUS,Z
	goto	M_Failed
	BANKSEL DAT0
	movwf	DAT0
	Call	LF.Receive8			; Receive Byte From Basestation
	btfsc	STATUS,Z
	goto	M_Failed
	BANKSEL DAT1
	movwf	DAT1
; ******* Calculate EEPROM Offset & Write 16-bits ********
WRITE_USR3
	banksel LF_CMD
	movf	LF_CMD,w			; Get LF Command Byte
	andlw	0x3					; Mask Lower 2 bits = Address
	addlw	EE_USER				; Add to User Memory Offset
	banksel	EEPROM.ADDRESS			
	movwf	EEPROM.ADDRESS		; Load offset into ADDRESS register
	banksel DAT0
	movf	DAT0,w
	nop
	Call	EEPROM.Write		; Write byte to EEPROM
	banksel DAT1
	movf	DAT1,w			
	nop
	Call	EEPROM.Write		; Write byte to EEPROM
; ******* Calculate EEPROM Offset & Read 16-bits ********
WRITE_USR4
	banksel LF_CMD
	movf	LF_CMD,w			; Get LF Command Byte
	andlw	0x3					; Mask Lower 2 bits = Address
	addlw	EE_USER				; Add to User Memory Offset
	banksel	EEPROM.ADDRESS			
	movwf	EEPROM.ADDRESS		; Load offset into ADDRESS register
	Call	EEPROM.Read			; Read byte from EEPROM
	banksel DAT0
	movwf	DAT0
	nop			
	Call	EEPROM.Read			; Read byte from EEPROM
	banksel DAT1
	movwf	DAT1
	pagesel Delay.wait_w_x_50u
	Delay.WaitFor .1,'m'
	
; ******  Send LF Data Transmission back to Basestation ********
;WRITE_USR5
;	movfw	DAT0
;	Call	LF.Send8			; Transmit byte using LF Clamping
;	banksel DAT1
;	movfw	DAT1
;	Call	LF.Send8			; Transmit byte using LF Clamping
;	call	waitForLFEnd
; ******  Send RF Data Transmission back to Basestation ********
WRITE_USR6
	Call	RF.Send_Header		; Send transmission header
	banksel DAT0
	movfw	DAT0
	Call	RF.Send_Data		; Transmit byte using UHF transmitter
	banksel DAT1
	movfw	DAT1
	Call	RF.Send_Data		; Transmit byte using UHF transmitter
	goto	M_END
; ***********************************************************************
; READ_USR()
; ***********************************************************************
READ_USR
	banksel LF_CMD
	movf	LF_CMD,w			; Get LF Command Byte
	andlw	0x3					; Mask Lower 2 bits = Address
	addlw	EE_USER				; Add to User Memory Offset
	banksel	EEPROM.ADDRESS			
	movwf	EEPROM.ADDRESS		; Load offset into ADDRESS register
	Call	EEPROM.Read			; Read byte from EEPROM
	banksel DAT0
	movwf	DAT0			
	Call	EEPROM.Read			; Read byte from EEPROM
	banksel DAT1
	movwf	DAT1
	
	
	pagesel Delay.wait_w_x_50u
	Delay.WaitFor .1,'m'
; ******  Send LF Data Transmission back to Basestation ********
;READ_USR1
;	movfw	DAT0
;	Call	LF.Send8			; Transmit byte using LF Clamping
;	banksel DAT1
;	movfw	DAT1
;	Call	LF.Send8			; Transmit byte using LF Clamping
;	call	waitForLFEnd
; ******  Send RF Data Transmission back to Basestation
READ_USR2
	Call	RF.Send_Header		; Send transmission header
	banksel DAT0
	movfw	DAT0
	Call	RF.Send_Data		; Transmit byte using UHF transmitter
	banksel DAT1
	movfw	DAT1
	Call	RF.Send_Data		; Transmit byte using UHF transmitter
	goto	M_END
; ***********************************************************************
; IFF_CMD()
; ***********************************************************************
IFF_CMD
; ******* Receive 32-bit LF data from Base-station ******
IFF_CMD1
	movlw	DAT0
	movwf	FSR
	movlw	0x04
	call	LF.ReadBuffer		; Receive challenge from Basestation and store it to DAT
	btfsc	STATUS,Z
	goto	M_Failed
	pagesel Delay.wait_w_x_50u
	Delay.WaitFor .1,'m'		; Wait 1ms for end of LF data transmission
; ******* Calculate 32-bit KeeLoq response ****************
IFF_CMD2
	;; Add Call to KeeLoq Code here !!!!
; ******  Send LF Data Transmission back to Basestation ********
IFF_CMD3
	;movlw	DAT0
	;movwf	FSR
	;movlw	0x04
	;call	AFE.SendBuffer
;	banksel DAT0
;	movfw	DAT0
;	Call	LF.Send8		; Transmit byte using LF Clamping
;	banksel DAT1
;	movfw	DAT1
;	Call	LF.Send8		; Transmit byte using LF Clamping
;	banksel DAT2
;	movfw	DAT2
;	Call	LF.Send8		; Transmit byte using LF Clamping	
;	banksel DAT3
;	movfw	DAT3
;	Call	LF.Send8		; Transmit byte using LF Clamping
;	call	waitForLFEnd
; ******  Send UHF Transmission back to Basestation ********
IFF_CMD4
	movlw	DAT0
	movwf	FSR
	movlw	0x04
	call	RF.SendBuffer	; Read response from DAT and send it back using the RF Transmitter
	goto	M_END
; ***********************************************************************
; RSSI_CMD()
; ***********************************************************************
RSSI_CMD
; ******  Send LF Data Transmission back to Basestation ********
RSSI_CMD1
	movlw	0x69
	Call	LF.Send8		; Transmit byte using LF Clamping
; ******  Send RF Data Transmission back to Basestation ********
RSSI_CMD2
	Call	RF.Send_Header	; Send transmission header
	movlw	0x69
	Call	RF.Send_Data	; Transmit byte using UHF transmitter
	goto	M_END
; ***********************************************************************
; READ_SERIAL()
; ***********************************************************************
READ_SERIAL
	banksel	EEPROM.ADDRESS
	movlw	EE_DATA				; Set EEPROM Adress Offset for Serial Number
	movwf	EEPROM.ADDRESS
	movlw	SER0
	movwf	FSR
	movlw	0x04
	call	EEPROM.ReadBytes	; Read Serialnumber to SER
	pagesel Delay.wait_w_x_50u
	Delay.WaitFor .1,'m'
; ******  Send LF Data Transmission back to Basestation ********
;READ_SERIAL1
;	banksel DAT0
;	movfw	DAT0
;	Call	LF.Send8		; Transmit byte using LF Clamping
;	banksel DAT1
;	movfw	DAT1
;	Call	LF.Send8		; Transmit byte using LF Clamping
;	banksel DAT2
;	movfw	DAT2
;	Call	LF.Send8		; Transmit byte using LF Clamping	
;	banksel DAT3
;	movfw	DAT3
;	Call	LF.Send8		; Transmit byte using LF Clamping
;	call	waitForLFEnd
	;pagesel Delay.wait_w_x_50u
	;Delay.WaitFor .10,'m'
	;Call	Delay10ms		; Wait 10ms for end of LF data transmission
; ******  Send RF Data Transmission back to Basestation ********
READ_SERIAL2
	movlw	SER0
	movwf	FSR
	movlw	0x04
	call	RF.SendBuffer	; Transmitt SER
	goto	M_END
	
;waitForLFEnd
;	movlw	0xFF
;	banksel COUNTER
;	movwf	COUNTER
;waitForLFEndNoC
;	btfsc	LF.DATAIN
;	goto	waitForLFEnd
;	decfsz	COUNTER,f
;	goto	waitForLFEndNoC
;	return
	
	
	END
