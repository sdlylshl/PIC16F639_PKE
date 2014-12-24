#ifndef AFE_639_INC
#define AFE_639_INC



#include SPI.inc


;------------------------------------------------------------------------------+
;                                                                              |
;    Module AFE_639                                                            |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This class provides access to the Analog Front End.                       |
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
    extern AFE_ConfMap
    extern AFE_Buffer
    extern AFE__LoadCfg, AFE__SafeCfg, AFE__ReadCfg, AFE__WriteCfg, AFE__WriteRegister, AFE__ReadRegister, AFE__WriteNVerifyRegister
    extern AFE__CalcColumnParity
	
#define	AFE__Alert			PORTC,2		; SPI Clock Output
#define	AFE__CMDClampOn		B'00000000'
#define AFE__CMDClampOff		B'00100000'
#define AFE__CMDSleep		B'01000000'
#define AFE__CMDAGCOn		B'01100000'
#define AFE__CMDAGCOff		B'10000000'
#define	AFE__CMDSR			B'10100000'
#define AFE__ModDepth12		B'00110000'
#define AFE__ModDepth25		B'00100000'
#define AFE__ModDepth75		B'00010000'
#define AFE__ModDepth50		B'00000000'
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__Init()                                                                |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro initialises the AFE                                            |
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__Init macro
	call AFE__LoadCfg
	call AFE__WriteCfg
;	call AFE__ReadCfg
	AFE__SendCMDSoftReset
	banksel	PORTA			;just debugging
	btfss	AFE__Alert
	;goto	$-1				;执行从当前地址往后偏移1个或3个地址的指令
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__SendCMDClampON()                                                      |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro sends a clamp on command to the AFE by using the SPI-Bus.      |
;    The clamp on command switches the transistor at the LF-Input to low       |
;    resistance.                                                               |
;    So use this macro for LF-Talkback.                                        |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs:                                                                |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    SPI__Write                                                                 |
;                                                                              |
;                                                                              |
;    Stacklevel: 1                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE__SendCMDClampOn                                                        |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sends the command                                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__SendCMDClampON macro
	banksel SPI_BufferH
	movlw	AFE__CMDClampOn
	movwf	SPI_BufferH
	call	SPI__Write
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__SendCMDClampOFF()                                                     |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro sends a clamp off command to the AFE by using the SPI-Bus.     |
;    The clamp on command switches the transistor at the LF-Input to high      |
;    resistance.                                                               |
;    So use this macro for LF-Talkback.                                        |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs:                                                                |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    SPI__Write                                                                 |
;                                                                              |
;                                                                              |
;    Stacklevel: 1                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE__SendCMDClampOff                                                       |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sends the command                                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__SendCMDClampOFF macro
	banksel SPI_BufferH
	movlw	AFE__CMDClampOff
	movwf	SPI_BufferH
	call	SPI__Write
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__SendCMDSleep()                                                        |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro sends a Sleep command to the AFE by using the SPI-Bus.         |
;    The AFE will enter the sleep mode.                                        |
;    It will wake up by the next transmission over the SPI-Bus.                |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs:                                                                |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    SPI__Write                                                                 |
;                                                                              |
;                                                                              |
;    Stacklevel: 1                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE__SendCMDSleep                                                          |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sends the command                                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__SendCMDSleep macro
	banksel SPI_BufferH
	movlw	AFE__CMDSleep
	movwf	SPI_BufferH
	call	SPI__Write
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__SendCMDAGCPresON()                                                    |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro sends a AGC Preserve On command to the AFE by using the        |
;    SPI-Bus.                                                                  |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs:                                                                |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    SPI__Write                                                                 |
;                                                                              |
;                                                                              |
;    Stacklevel: 1                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE__SendCMDAGCPresON                                                      |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sends the command                                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__SendCMDAGCPresON macro
	banksel SPI_BufferH
	movlw	AFE__CMDAGCOn
	movwf	SPI_BufferH
	call	SPI__Write
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__SendCMDAGCPresOFF()                                                   |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro sends a AGC Preserve Off command to the AFE by using the       |
;    SPI-Bus.                                                                  |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs:                                                                |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    SPI__Write                                                                 |
;                                                                              |
;                                                                              |
;    Stacklevel: 1                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE__SendCMDAGCPresOFF                                                     |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sends the command                                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__SendCMDAGCPresOFF macro
	banksel SPI_BufferH
	movlw	AFE__CMDAGCOff
	movwf	SPI_BufferH
	call	SPI__Write
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__SendCMDSoftReset()                                                    |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro sends a SoftReset on command to the AFE by using the SPI-Bus.  |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs:                                                                |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    SPI__Write                                                                 |
;                                                                              |
;                                                                              |
;    Stacklevel: 1                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE__SendCMDSoftReset                                                      |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sends the command                                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__SendCMDSoftReset macro
	banksel SPI_BufferH
	movlw	AFE__CMDSR
	movwf	SPI_BufferH
	call	SPI__Write
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__EnableChannelX()                                                      |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro enables the LF Channel X at the AFE__                           |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: FSR                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE__WriteRegister                                                         |
;        AFE__CalcParity                                                        |
;        SPI__Write                                                             |
;    AFE__updateColumnParity                                                    |
;        AFE__WriteRegister                                                     |
;            AFE__CalcParity                                                    |
;            SPI__Write                                                         |
;        AFE__CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE__EnableChannelX                                                        |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This enables Channel X                                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__EnableChannelX macro
	banksel	AFE_ConfMap
	movf	AFE_ConfMap,W
	andlw	b'11111110'
	movwf	AFE_ConfMap
	movlw	0x00
	call	AFE__WriteRegister
	AFE__updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__EnableChannelY()                                                      |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro enables the LF Channel Y at the AFE__                           |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: FSR                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE__WriteRegister                                                         |
;        AFE__CalcParity                                                        |
;        SPI__Write                                                             |
;    AFE__updateColumnParity                                                    |
;        AFE__WriteRegister                                                     |
;            AFE__CalcParity                                                    |
;            SPI__Write                                                         |
;        AFE__CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE__EnableChannelY                                                        |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This enables Channel Y                                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__EnableChannelY macro
	banksel	AFE_ConfMap
	movf	AFE_ConfMap,W
	andlw	b'11111101'
	movwf	AFE_ConfMap
	movlw	0x00
	call	AFE__WriteRegister
	AFE__updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__EnableChannelZ()                                                      |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro enables the LF Channel Z at the AFE__                           |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: FSR                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE__WriteRegister                                                         |
;        AFE__CalcParity                                                        |
;        SPI__Write                                                             |
;    AFE__updateColumnParity                                                    |
;        AFE__WriteRegister                                                     |
;            AFE__CalcParity                                                    |
;            SPI__Write                                                         |
;        AFE__CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE__EnableChannelZ                                                        |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This enables Channel Z                                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__EnableChannelZ macro
	banksel	AFE_ConfMap
	movf	AFE_ConfMap,W
	andlw	b'11111011'
	movwf	AFE_ConfMap
	movlw	0x00
	call	AFE__WriteRegister
	AFE__updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__DisableChannelX()                                                     |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro disables the LF Channel X at the AFE__                          |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: FSR                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE__WriteRegister                                                         |
;        AFE__CalcParity                                                        |
;        SPI__Write                                                             |
;    AFE__updateColumnParity                                                    |
;        AFE__WriteRegister                                                     |
;            AFE__CalcParity                                                    |
;            SPI__Write                                                         |
;        AFE__CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE__EnableChannelX                                                        |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This enables Channel X                                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__DisableChannelX macro
	banksel	AFE_ConfMap
	movf	AFE_ConfMap,W
	iorlw	0x01
	movwf	AFE_ConfMap
	movlw	0x00
	call	AFE__WriteRegister
	AFE__updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__AGCActive()                                                           |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro disables the signals below AGC-active level.                   |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: FSR                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE__WriteRegister                                                         |
;        AFE__CalcParity                                                        |
;        SPI__Write                                                             |
;    AFE__updateColumnParity                                                    |
;        AFE__WriteRegister                                                     |
;            AFE__CalcParity                                                    |
;            SPI__Write                                                         |
;        AFE__CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE__EnableChannelX                                                        |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This enables Channel X                                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__AGCActive macro
	banksel	AFE_ConfMap
	movf	AFE_ConfMap+6,W
	iorlw	0x10
	movwf	AFE_ConfMap+6
	movlw	0x06
	call	AFE__WriteRegister
	AFE__updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__AGCDeactive()                                                         |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro disables the signals below AGC-active level.                   |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: FSR                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE__WriteRegister                                                         |
;        AFE__CalcParity                                                        |
;        SPI__Write                                                             |
;    AFE__updateColumnParity                                                    |
;        AFE__WriteRegister                                                     |
;            AFE__CalcParity                                                    |
;            SPI__Write                                                         |
;        AFE__CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE__EnableChannelX                                                        |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This enables Channel X                                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__AGCDeactive macro
	banksel	AFE_ConfMap
	movf	AFE_ConfMap+6,W
	andlw	0xef
	movwf	AFE_ConfMap+6
	movlw	0x06
	call	AFE__WriteRegister
	AFE__updateColumnParity
	endm
	
	
	
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__DisableChannelY()                                                     |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro disables the LF Channel Y at the AFE__                          |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: FSR                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE__WriteRegister                                                         |
;        AFE__CalcParity                                                        |
;        SPI__Write                                                             |
;    AFE__updateColumnParity                                                    |
;        AFE__WriteRegister                                                     |
;            AFE__CalcParity                                                    |
;            SPI__Write                                                         |
;        AFE__CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE__EnableChannelY                                                        |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This enables Channel Y                                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__DisableChannelY macro
	banksel	AFE_ConfMap
	movf	AFE_ConfMap,W
	iorlw	0x02
	movwf	AFE_ConfMap
	movlw	0x00
	call	AFE__WriteRegister
	AFE__updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__DisableChannelZ()                                                     |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro disables the LF Channel Z at the AFE__                          |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: FSR                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE__WriteRegister                                                         |
;        AFE__CalcParity                                                        |
;        SPI__Write                                                             |
;    AFE__updateColumnParity                                                    |
;        AFE__WriteRegister                                                     |
;            AFE__CalcParity                                                    |
;            SPI__Write                                                         |
;        AFE__CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE__EnableChannelZ                                                        |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This enables Channel Z                                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__DisableChannelZ macro	;save some code with bsf :)
	banksel	AFE_ConfMap
	movf	AFE_ConfMap,W
	iorlw	0x04
	movwf	AFE_ConfMap
	movlw	0x00
	call	AFE__WriteRegister
	AFE__updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__setOutputData()                                                       |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro sets the LFData output to data mode.                           |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: FSR                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE__WriteRegister                                                         |
;        AFE__CalcParity                                                        |
;        SPI__Write                                                             |
;    AFE__updateColumnParity                                                    |
;        AFE__WriteRegister                                                     |
;            AFE__CalcParity                                                    |
;            SPI__Write                                                         |
;        AFE__CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE__setOutputData                                                         |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sets the LFData output to data mode                              |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__setOutputData	macro
	banksel AFE_ConfMap
	bcf		(AFE_ConfMap+1),7
	bcf		(AFE_ConfMap+1),6
	movlw	0x01
	call	AFE__WriteRegister
	AFE__updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__setOutputClk()                                                        |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro sets the LFData output to clock mode.                          |
;    The clock signal of the carrier frequency will now drive the LFdata pin.  |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: FSR                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE__WriteRegister                                                         |
;        AFE__CalcParity                                                        |
;        SPI__Write                                                             |
;    AFE__updateColumnParity                                                    |
;        AFE__WriteRegister                                                     |
;            AFE__CalcParity                                                    |
;            SPI__Write                                                         |
;        AFE__CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE__setOutputClk                                                          |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sets the LFData output to clock mode                             |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__setOutputClk	macro
	banksel AFE_ConfMap
	bcf		(AFE_ConfMap+1),7
	bsf		(AFE_ConfMap+1),6
	movlw	0x01
	call	AFE__WriteRegister
	AFE__updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__setOutputRSSI()                                                       |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro sets the LFData output to RSSI mode.                           |
;    The LFdata pin will put out a current proportional to the signal strength |
;    of the LF-Field.                                                          |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: FSR                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE__WriteRegister                                                         |
;        AFE__CalcParity                                                        |
;        SPI__Write                                                             |
;    AFE__updateColumnParity                                                    |
;        AFE__WriteRegister                                                     |
;            AFE__CalcParity                                                    |
;            SPI__Write                                                         |
;        AFE__CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE__setOutputRSSI                                                         |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sets the LFData output to RSSI mode                              |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__setOutputRSSI	macro
	banksel AFE_ConfMap
	bsf		(AFE_ConfMap+1),7
	movlw	0x01
	call	AFE__WriteRegister
	AFE__updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__setXTuningCap( w )                                                    |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro sets the value for the tuning capacitors at channel X.         |
;    The input value must not exceed 63.                                       |
;                                                                              |
;                                                                              |
;    Parameters:                                                               |
;    w - The value of the tuning capacitor                                     |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: FSR                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE__WriteRegister                                                         |
;        AFE__CalcParity                                                        |
;        SPI__Write                                                             |
;    AFE__updateColumnParity                                                    |
;        AFE__WriteRegister                                                     |
;            AFE__CalcParity                                                    |
;            SPI__Write                                                         |
;        AFE__CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    movlw   D'33'                                                             |
;    AFE__setXTuningCap                                                         |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sets the tuning capacitor of channel X to 33pF(typ)              |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__setXTuningCap	macro	;make function out of it? Let's have a look at the running Code. The Stacklevel may be more critical
	banksel AFE_Buffer
	movwf	AFE_Buffer
	movf	(AFE_ConfMap+1),w
	andlw	B'11000000'
	iorwf	AFE_Buffer,W
	movwf	(AFE_ConfMap+1)
	movlw	0x01
	call	AFE__WriteRegister
	AFE__updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__setYTuningCap( w )                                                    |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro sets the value for the tuning capacitors at channel Y.         |
;    The input value must not exceed 63.                                       |
;                                                                              |
;                                                                              |
;    Parameters:                                                               |
;    w - The value of the tuning capacitor                                     |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: FSR                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE__WriteRegister                                                         |
;        AFE__CalcParity                                                        |
;        SPI__Write                                                             |
;    AFE__updateColumnParity                                                    |
;        AFE__WriteRegister                                                     |
;            AFE__CalcParity                                                    |
;            SPI__Write                                                         |
;        AFE__CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    movlw   D'33'                                                             |
;    AFE__setYTuningCap                                                         |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sets the tuning capacitor of channel Y to 33pF(typ)              |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__setYTuningCap	macro
	banksel AFE_Buffer
	movwf	AFE_Buffer
	movf	(AFE_ConfMap+2),w
	andlw	B'11000000'
	iorwf	AFE_Buffer,W
	movwf	(AFE_ConfMap+2)
	movlw	0x02
	call	AFE__WriteRegister
	AFE__updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__setZTuningCap( w )                                                    |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro sets the value for the tuning capacitors at channel Z.         |
;    The input value must not exceed 63.                                       |
;                                                                              |
;                                                                              |
;    Parameters:                                                               |
;    w - The value of the tuning capacitor                                     |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: FSR                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE__WriteRegister                                                         |
;        AFE__CalcParity                                                        |
;        SPI__Write                                                             |
;    AFE__updateColumnParity                                                    |
;        AFE__WriteRegister                                                     |
;            AFE__CalcParity                                                    |
;            SPI__Write                                                         |
;        AFE__CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    movlw   D'33'                                                             |
;    AFE__setZTuningCap                                                         |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sets the tuning capacitor of channel Z to 33pF(typ)              |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__setZTuningCap	macro
	banksel AFE_Buffer
	movwf	AFE_Buffer
	movf	(AFE_ConfMap+3),w
	andlw	B'11000000'
	iorwf	AFE_Buffer,W
	movwf	(AFE_ConfMap+3)
	movlw	0x03
	call	AFE__WriteRegister
	AFE__updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__setXSensitivity( w )                                                  |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro sets the attenuation for channel X.                            |
;    The input value must not exceed 15.                                       |
;                                                                              |
;                                                                              |
;    Parameters:                                                               |
;    w - Half the value of the attenuation in dB                               |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: FSR                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE__WriteRegister                                                         |
;        AFE__CalcParity                                                        |
;        SPI__Write                                                             |
;    AFE__updateColumnParity                                                    |
;        AFE__WriteRegister                                                     |
;            AFE__CalcParity                                                    |
;            SPI__Write                                                         |
;        AFE__CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    movlw   D'12'                                                             |
;    AFE__setXSensitivity                                                       |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sets the attenuation for channel X to 24dB                       |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__setXSensitivity	macro
	banksel AFE_Buffer
	movwf	AFE_Buffer
	swapf	AFE_Buffer,F
	movf	(AFE_ConfMap+4),w
	andlw	B'00001111'
	iorwf	AFE_Buffer,W
	movwf	(AFE_ConfMap+4)
	movlw	0x04
	call	AFE__WriteRegister
	AFE__updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__setYSensitivity( w )                                                  |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro sets the attenuation for channel Y.                            |
;    The input value must not exceed 15.                                       |
;                                                                              |
;                                                                              |
;    Parameters:                                                               |
;    w - Half the value of the attenuation in dB                               |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: FSR                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE__WriteRegister                                                         |
;        AFE__CalcParity                                                        |
;        SPI__Write                                                             |
;    AFE__updateColumnParity                                                    |
;        AFE__WriteRegister                                                     |
;            AFE__CalcParity                                                    |
;            SPI__Write                                                         |
;        AFE__CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    movlw   D'12'                                                             |
;    AFE__setYSensitivity                                                       |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sets the attenuation for channel Y to 24dB                       |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__setYSensitivity	macro
	banksel AFE_Buffer
	movwf	AFE_Buffer
	movf	(AFE_ConfMap+4),w
	andlw	B'11110000'
	iorwf	AFE_Buffer,W
	movwf	(AFE_ConfMap+4)
	movlw	0x04
	call	AFE__WriteRegister
	AFE__updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__setZSensitivity( w )                                                  |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro sets the attenuation for channel Z.                            |
;    The input value must not exceed 15.                                       |
;                                                                              |
;                                                                              |
;    Parameters:                                                               |
;    w - Half the value of the attenuation in dB                               |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: FSR                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE__WriteRegister                                                         |
;        AFE__CalcParity                                                        |
;        SPI__Write                                                             |
;    AFE__updateColumnParity                                                    |
;        AFE__WriteRegister                                                     |
;            AFE__CalcParity                                                    |
;            SPI__Write                                                         |
;        AFE__CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    movlw   D'12'                                                             |
;    AFE__setZSensitivity                                                       |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sets the attenuation for channel Z to 24dB                       |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__setZSensitivity	macro
	banksel AFE_Buffer
	movwf	AFE_Buffer
	movf	(AFE_ConfMap+5),w
	andlw	B'11110000'
	iorwf	AFE_Buffer,W
	movwf	(AFE_ConfMap+5)
	movlw	0x05
	call	AFE__WriteRegister
	AFE__updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__setModDepth( w )                                                      |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro sets the modulation depth to accept incoming signals           |
;                                                                              |
;                                                                              |
;    Parameters:                                                               |
;    w - The code for the required modulation depth                            |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: FSR                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE__WriteRegister                                                         |
;        AFE__CalcParity                                                        |
;        SPI__Write                                                             |
;    AFE__updateColumnParity                                                    |
;        AFE__WriteRegister                                                     |
;            AFE__CalcParity                                                    |
;            SPI__Write                                                         |
;        AFE__CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    movlw   AFE__ModDepth50                                                    |
;    AFE__setModDepth                                                           |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sets the modulation depth to 50%.                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__setModDepth macro
	banksel AFE_Buffer
	movwf	AFE_Buffer
	swapf	AFE_Buffer,F
	movf	(AFE_ConfMap+5),w
	andlw	B'11001111'
	iorwf	AFE_Buffer,W
	movwf	(AFE_ConfMap+5)
	movlw	0x05
	call	AFE__WriteRegister
	AFE__updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE__confOEFilter( TOEH  TOEL )                                            |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro configures the modulation depth.                               |
;    Setting the TOEH and TOEL to zero, will result in disabling the Filter.   |
;                                                                              |
;                                                                              |
;    Parameters:                                                               |
;    TOEH - The time in ms the input signal has to be high                     |
;    TOEL - The time in ms the input signal has to be low                      |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: FSR                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE__WriteRegister                                                         |
;        AFE__CalcParity                                                        |
;        SPI__Write                                                             |
;    AFE__updateColumnParity                                                    |
;        AFE__WriteRegister                                                     |
;            AFE__CalcParity                                                    |
;            SPI__Write                                                         |
;        AFE__CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE__confOEFilter    2,2                                                   |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sets the high and low time to 2 ms                               |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__confOEFilter macro	TOEH, TOEL
	banksel AFE_ConfMap
	movf	AFE_ConfMap,W
	andlw	B'00001111'
	iorlw	(((TOEH<<6)&&B'11000000')||((TOEL<<4)&&B'00110000'))	;ensure that he does what I want
	movwf	AFE_ConfMap
	movlw	0x00
	call	AFE__WriteRegister
	AFE__updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;     w AFE__getStatus()                                                        |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro reads the status register of the AFE                           |
;                                                                              |
;                                                                              |
;    Returns:                                                                  |
;    w - The current value of the Status register of the AFE                   |
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
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE__getStatus           ;get status register of AFE                       |
;    andlw 0x01              ;mask parity error bit                            |
;    btfss   STATUS,Z        ;error occured?                                   |
;    call    AFE__writeCfg    ;write back RAM Map to AFE (Parity will be        |
;    calculated)                                                               |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This example checks whether a parity error occured or not.            |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__getStatus	macro
	movlw	0x07
	call	AFE__ReadRegister
	banksel	AFE_ConfMap
	movf	(AFE_ConfMap+7),w
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;     w AFE__updateColumnParity()                                               |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro reads the status register of the AFE                           |
;                                                                              |
;                                                                              |
;    Returns:                                                                  |
;    w - The current value of the Status register of the AFE                   |
;                                                                              |
;                                                                              |
;    Used SFRs:      FSR                                                       |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE__WriteRegister                                                         |
;        AFE__CalcParity                                                        |
;        SPI__Write                                                             |
;    AFE__CalcColumnParity                                                      |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    movlw   0x03                                                              |
;    call    AFE__WriteRegister                                                 |
;    AFE__updateColumnParity                                                    |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This example writes the new column parity to the AFE_ConfMap and to   |
;        the device                                                            |
;                                                                              |
;------------------------------------------------------------------------------+
AFE__updateColumnParity	macro
	call	AFE__CalcColumnParity
	movlw	0x06
	call	AFE__WriteRegister
	endm
#endif
