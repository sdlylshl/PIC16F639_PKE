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
	extern AFE.ConfMap
	extern AFE.Buffer
	extern AFE.LoadCfg, AFE.SafeCfg, AFE.ReadCfg, AFE.WriteCfg, AFE.WriteRegister, AFE.ReadRegister, AFE.WriteNVerifyRegister
	extern AFE.CalcColumnParity
	#define	AFE.Alert			PORTC,2		; SPI Clock Output
	#define	AFE.CMDClampOn		B'00000000'
	#define AFE.CMDClampOff		B'00100000'
	#define AFE.CMDSleep		B'01000000'
	#define AFE.CMDAGCOn		B'01100000'
	#define AFE.CMDAGCOff		B'10000000'
	#define	AFE.CMDSR			B'10100000'
	#define AFE.ModDepth12		B'00110000'
	#define AFE.ModDepth25		B'00100000'
	#define AFE.ModDepth75		B'00010000'
	#define AFE.ModDepth50		B'00000000'
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.Init()                                                                |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro initialises the AFE                                            |
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.Init macro
	call AFE.LoadCfg
	call AFE.WriteCfg
;	call AFE.ReadCfg
	AFE.SendCMDSoftReset
	banksel	PORTA			;just debugging
	btfss	AFE.Alert
	goto	$-1
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.SendCMDClampON()                                                      |
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
;    SPI.Write                                                                 |
;                                                                              |
;                                                                              |
;    Stacklevel: 1                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE.SendCMDClampOn                                                        |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sends the command                                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.SendCMDClampON macro
	banksel SPI.BufferH
	movlw	AFE.CMDClampOn
	movwf	SPI.BufferH
	call	SPI.Write
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.SendCMDClampOFF()                                                     |
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
;    SPI.Write                                                                 |
;                                                                              |
;                                                                              |
;    Stacklevel: 1                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE.SendCMDClampOff                                                       |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sends the command                                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.SendCMDClampOFF macro
	banksel SPI.BufferH
	movlw	AFE.CMDClampOff
	movwf	SPI.BufferH
	call	SPI.Write
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.SendCMDSleep()                                                        |
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
;    SPI.Write                                                                 |
;                                                                              |
;                                                                              |
;    Stacklevel: 1                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE.SendCMDSleep                                                          |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sends the command                                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.SendCMDSleep macro
	banksel SPI.BufferH
	movlw	AFE.CMDSleep
	movwf	SPI.BufferH
	call	SPI.Write
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.SendCMDAGCPresON()                                                    |
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
;    SPI.Write                                                                 |
;                                                                              |
;                                                                              |
;    Stacklevel: 1                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE.SendCMDAGCPresON                                                      |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sends the command                                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.SendCMDAGCPresON macro
	banksel SPI.BufferH
	movlw	AFE.CMDAGCOn
	movwf	SPI.BufferH
	call	SPI.Write
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.SendCMDAGCPresOFF()                                                   |
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
;    SPI.Write                                                                 |
;                                                                              |
;                                                                              |
;    Stacklevel: 1                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE.SendCMDAGCPresOFF                                                     |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sends the command                                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.SendCMDAGCPresOFF macro
	banksel SPI.BufferH
	movlw	AFE.CMDAGCOff
	movwf	SPI.BufferH
	call	SPI.Write
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.SendCMDSoftReset()                                                    |
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
;    SPI.Write                                                                 |
;                                                                              |
;                                                                              |
;    Stacklevel: 1                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE.SendCMDSoftReset                                                      |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sends the command                                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.SendCMDSoftReset macro
	banksel SPI.BufferH
	movlw	AFE.CMDSR
	movwf	SPI.BufferH
	call	SPI.Write
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.EnableChannelX()                                                      |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro enables the LF Channel X at the AFE.                           |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: FSR                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE.WriteRegister                                                         |
;        AFE.CalcParity                                                        |
;        SPI.Write                                                             |
;    AFE.updateColumnParity                                                    |
;        AFE.WriteRegister                                                     |
;            AFE.CalcParity                                                    |
;            SPI.Write                                                         |
;        AFE.CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE.EnableChannelX                                                        |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This enables Channel X                                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.EnableChannelX macro
	banksel	AFE.ConfMap
	movf	AFE.ConfMap,w
	andlw	b'11111110'
	movwf	AFE.ConfMap
	movlw	0x00
	call	AFE.WriteRegister
	AFE.updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.EnableChannelY()                                                      |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro enables the LF Channel Y at the AFE.                           |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: FSR                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE.WriteRegister                                                         |
;        AFE.CalcParity                                                        |
;        SPI.Write                                                             |
;    AFE.updateColumnParity                                                    |
;        AFE.WriteRegister                                                     |
;            AFE.CalcParity                                                    |
;            SPI.Write                                                         |
;        AFE.CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE.EnableChannelY                                                        |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This enables Channel Y                                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.EnableChannelY macro
	banksel	AFE.ConfMap
	movf	AFE.ConfMap,w
	andlw	b'11111101'
	movwf	AFE.ConfMap
	movlw	0x00
	call	AFE.WriteRegister
	AFE.updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.EnableChannelZ()                                                      |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro enables the LF Channel Z at the AFE.                           |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: FSR                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE.WriteRegister                                                         |
;        AFE.CalcParity                                                        |
;        SPI.Write                                                             |
;    AFE.updateColumnParity                                                    |
;        AFE.WriteRegister                                                     |
;            AFE.CalcParity                                                    |
;            SPI.Write                                                         |
;        AFE.CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE.EnableChannelZ                                                        |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This enables Channel Z                                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.EnableChannelZ macro
	banksel	AFE.ConfMap
	movf	AFE.ConfMap,w
	andlw	b'11111011'
	movwf	AFE.ConfMap
	movlw	0x00
	call	AFE.WriteRegister
	AFE.updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.DisableChannelX()                                                     |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro disables the LF Channel X at the AFE.                          |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: FSR                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE.WriteRegister                                                         |
;        AFE.CalcParity                                                        |
;        SPI.Write                                                             |
;    AFE.updateColumnParity                                                    |
;        AFE.WriteRegister                                                     |
;            AFE.CalcParity                                                    |
;            SPI.Write                                                         |
;        AFE.CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE.EnableChannelX                                                        |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This enables Channel X                                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.DisableChannelX macro
	banksel	AFE.ConfMap
	movf	AFE.ConfMap,w
	iorlw	0x01
	movwf	AFE.ConfMap
	movlw	0x00
	call	AFE.WriteRegister
	AFE.updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.AGCActive()                                                           |
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
;    AFE.WriteRegister                                                         |
;        AFE.CalcParity                                                        |
;        SPI.Write                                                             |
;    AFE.updateColumnParity                                                    |
;        AFE.WriteRegister                                                     |
;            AFE.CalcParity                                                    |
;            SPI.Write                                                         |
;        AFE.CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE.EnableChannelX                                                        |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This enables Channel X                                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.AGCActive macro
	banksel	AFE.ConfMap
	movf	AFE.ConfMap+6,w
	iorlw	0x10
	movwf	AFE.ConfMap+6
	movlw	0x06
	call	AFE.WriteRegister
	AFE.updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.AGCDeactive()                                                         |
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
;    AFE.WriteRegister                                                         |
;        AFE.CalcParity                                                        |
;        SPI.Write                                                             |
;    AFE.updateColumnParity                                                    |
;        AFE.WriteRegister                                                     |
;            AFE.CalcParity                                                    |
;            SPI.Write                                                         |
;        AFE.CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE.EnableChannelX                                                        |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This enables Channel X                                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.AGCDeactive macro
	banksel	AFE.ConfMap
	movf	AFE.ConfMap+6,w
	andlw	0xef
	movwf	AFE.ConfMap+6
	movlw	0x06
	call	AFE.WriteRegister
	AFE.updateColumnParity
	endm
	
	
	
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.DisableChannelY()                                                     |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro disables the LF Channel Y at the AFE.                          |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: FSR                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE.WriteRegister                                                         |
;        AFE.CalcParity                                                        |
;        SPI.Write                                                             |
;    AFE.updateColumnParity                                                    |
;        AFE.WriteRegister                                                     |
;            AFE.CalcParity                                                    |
;            SPI.Write                                                         |
;        AFE.CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE.EnableChannelY                                                        |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This enables Channel Y                                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.DisableChannelY macro
	banksel	AFE.ConfMap
	movf	AFE.ConfMap,w
	iorlw	0x02
	movwf	AFE.ConfMap
	movlw	0x00
	call	AFE.WriteRegister
	AFE.updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.DisableChannelZ()                                                     |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro disables the LF Channel Z at the AFE.                          |
;                                                                              |
;                                                                              |
;                                                                              |
;    Used SFRs: FSR                                                            |
;                                                                              |
;                                                                              |
;    Calls subroutines:                                                        |
;    AFE.WriteRegister                                                         |
;        AFE.CalcParity                                                        |
;        SPI.Write                                                             |
;    AFE.updateColumnParity                                                    |
;        AFE.WriteRegister                                                     |
;            AFE.CalcParity                                                    |
;            SPI.Write                                                         |
;        AFE.CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE.EnableChannelZ                                                        |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This enables Channel Z                                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.DisableChannelZ macro	;save some code with bsf :)
	banksel	AFE.ConfMap
	movf	AFE.ConfMap,w
	iorlw	0x04
	movwf	AFE.ConfMap
	movlw	0x00
	call	AFE.WriteRegister
	AFE.updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.setOutputData()                                                       |
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
;    AFE.WriteRegister                                                         |
;        AFE.CalcParity                                                        |
;        SPI.Write                                                             |
;    AFE.updateColumnParity                                                    |
;        AFE.WriteRegister                                                     |
;            AFE.CalcParity                                                    |
;            SPI.Write                                                         |
;        AFE.CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE.setOutputData                                                         |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sets the LFData output to data mode                              |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.setOutputData	macro
	banksel AFE.ConfMap
	bcf		(AFE.ConfMap+1),7
	bcf		(AFE.ConfMap+1),6
	movlw	0x01
	call	AFE.WriteRegister
	AFE.updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.setOutputClk()                                                        |
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
;    AFE.WriteRegister                                                         |
;        AFE.CalcParity                                                        |
;        SPI.Write                                                             |
;    AFE.updateColumnParity                                                    |
;        AFE.WriteRegister                                                     |
;            AFE.CalcParity                                                    |
;            SPI.Write                                                         |
;        AFE.CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE.setOutputClk                                                          |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sets the LFData output to clock mode                             |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.setOutputClk	macro
	banksel AFE.ConfMap
	bcf		(AFE.ConfMap+1),7
	bsf		(AFE.ConfMap+1),6
	movlw	0x01
	call	AFE.WriteRegister
	AFE.updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.setOutputRSSI()                                                       |
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
;    AFE.WriteRegister                                                         |
;        AFE.CalcParity                                                        |
;        SPI.Write                                                             |
;    AFE.updateColumnParity                                                    |
;        AFE.WriteRegister                                                     |
;            AFE.CalcParity                                                    |
;            SPI.Write                                                         |
;        AFE.CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE.setOutputRSSI                                                         |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sets the LFData output to RSSI mode                              |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.setOutputRSSI	macro
	banksel AFE.ConfMap
	bsf		(AFE.ConfMap+1),7
	movlw	0x01
	call	AFE.WriteRegister
	AFE.updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.setXTuningCap( w )                                                    |
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
;    AFE.WriteRegister                                                         |
;        AFE.CalcParity                                                        |
;        SPI.Write                                                             |
;    AFE.updateColumnParity                                                    |
;        AFE.WriteRegister                                                     |
;            AFE.CalcParity                                                    |
;            SPI.Write                                                         |
;        AFE.CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    movlw   D'33'                                                             |
;    AFE.setXTuningCap                                                         |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sets the tuning capacitor of channel X to 33pF(typ)              |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.setXTuningCap	macro	;make function out of it? Let's have a look at the running Code. The Stacklevel may be more critical
	banksel AFE.Buffer
	movwf	AFE.Buffer
	movf	(AFE.ConfMap+1),w
	andlw	B'11000000'
	iorwf	AFE.Buffer,w
	movwf	(AFE.ConfMap+1)
	movlw	0x01
	call	AFE.WriteRegister
	AFE.updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.setYTuningCap( w )                                                    |
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
;    AFE.WriteRegister                                                         |
;        AFE.CalcParity                                                        |
;        SPI.Write                                                             |
;    AFE.updateColumnParity                                                    |
;        AFE.WriteRegister                                                     |
;            AFE.CalcParity                                                    |
;            SPI.Write                                                         |
;        AFE.CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    movlw   D'33'                                                             |
;    AFE.setYTuningCap                                                         |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sets the tuning capacitor of channel Y to 33pF(typ)              |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.setYTuningCap	macro
	banksel AFE.Buffer
	movwf	AFE.Buffer
	movf	(AFE.ConfMap+2),w
	andlw	B'11000000'
	iorwf	AFE.Buffer,w
	movwf	(AFE.ConfMap+2)
	movlw	0x02
	call	AFE.WriteRegister
	AFE.updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.setZTuningCap( w )                                                    |
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
;    AFE.WriteRegister                                                         |
;        AFE.CalcParity                                                        |
;        SPI.Write                                                             |
;    AFE.updateColumnParity                                                    |
;        AFE.WriteRegister                                                     |
;            AFE.CalcParity                                                    |
;            SPI.Write                                                         |
;        AFE.CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    movlw   D'33'                                                             |
;    AFE.setZTuningCap                                                         |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sets the tuning capacitor of channel Z to 33pF(typ)              |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.setZTuningCap	macro
	banksel AFE.Buffer
	movwf	AFE.Buffer
	movf	(AFE.ConfMap+3),w
	andlw	B'11000000'
	iorwf	AFE.Buffer,w
	movwf	(AFE.ConfMap+3)
	movlw	0x03
	call	AFE.WriteRegister
	AFE.updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.setXSensitivity( w )                                                  |
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
;    AFE.WriteRegister                                                         |
;        AFE.CalcParity                                                        |
;        SPI.Write                                                             |
;    AFE.updateColumnParity                                                    |
;        AFE.WriteRegister                                                     |
;            AFE.CalcParity                                                    |
;            SPI.Write                                                         |
;        AFE.CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    movlw   D'12'                                                             |
;    AFE.setXSensitivity                                                       |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sets the attenuation for channel X to 24dB                       |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.setXSensitivity	macro
	banksel AFE.Buffer
	movwf	AFE.Buffer
	swapf	AFE.Buffer,f
	movf	(AFE.ConfMap+4),w
	andlw	B'00001111'
	iorwf	AFE.Buffer,w
	movwf	(AFE.ConfMap+4)
	movlw	0x04
	call	AFE.WriteRegister
	AFE.updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.setYSensitivity( w )                                                  |
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
;    AFE.WriteRegister                                                         |
;        AFE.CalcParity                                                        |
;        SPI.Write                                                             |
;    AFE.updateColumnParity                                                    |
;        AFE.WriteRegister                                                     |
;            AFE.CalcParity                                                    |
;            SPI.Write                                                         |
;        AFE.CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    movlw   D'12'                                                             |
;    AFE.setYSensitivity                                                       |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sets the attenuation for channel Y to 24dB                       |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.setYSensitivity	macro
	banksel AFE.Buffer
	movwf	AFE.Buffer
	movf	(AFE.ConfMap+4),w
	andlw	B'11110000'
	iorwf	AFE.Buffer,w
	movwf	(AFE.ConfMap+4)
	movlw	0x04
	call	AFE.WriteRegister
	AFE.updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.setZSensitivity( w )                                                  |
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
;    AFE.WriteRegister                                                         |
;        AFE.CalcParity                                                        |
;        SPI.Write                                                             |
;    AFE.updateColumnParity                                                    |
;        AFE.WriteRegister                                                     |
;            AFE.CalcParity                                                    |
;            SPI.Write                                                         |
;        AFE.CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    movlw   D'12'                                                             |
;    AFE.setZSensitivity                                                       |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sets the attenuation for channel Z to 24dB                       |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.setZSensitivity	macro
	banksel AFE.Buffer
	movwf	AFE.Buffer
	movf	(AFE.ConfMap+5),w
	andlw	B'11110000'
	iorwf	AFE.Buffer,w
	movwf	(AFE.ConfMap+5)
	movlw	0x05
	call	AFE.WriteRegister
	AFE.updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.setModDepth( w )                                                      |
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
;    AFE.WriteRegister                                                         |
;        AFE.CalcParity                                                        |
;        SPI.Write                                                             |
;    AFE.updateColumnParity                                                    |
;        AFE.WriteRegister                                                     |
;            AFE.CalcParity                                                    |
;            SPI.Write                                                         |
;        AFE.CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    movlw   AFE.ModDepth50                                                    |
;    AFE.setModDepth                                                           |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sets the modulation depth to 50%.                                |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.setModDepth macro
	banksel AFE.Buffer
	movwf	AFE.Buffer
	swapf	AFE.Buffer,f
	movf	(AFE.ConfMap+5),w
	andlw	B'11001111'
	iorwf	AFE.Buffer,w
	movwf	(AFE.ConfMap+5)
	movlw	0x05
	call	AFE.WriteRegister
	AFE.updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;    AFE.confOEFilter( TOEH  TOEL )                                            |
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
;    AFE.WriteRegister                                                         |
;        AFE.CalcParity                                                        |
;        SPI.Write                                                             |
;    AFE.updateColumnParity                                                    |
;        AFE.WriteRegister                                                     |
;            AFE.CalcParity                                                    |
;            SPI.Write                                                         |
;        AFE.CalcColumnParity                                                  |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE.confOEFilter    2,2                                                   |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This sets the high and low time to 2 ms                               |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.confOEFilter macro	TOEH, TOEL
	banksel AFE.ConfMap
	movf	AFE.ConfMap,w
	andlw	B'00001111'
	iorlw	(((TOEH<<6)&&B'11000000')||((TOEL<<4)&&B'00110000'))	;ensure that he does what I want
	movwf	AFE.ConfMap
	movlw	0x00
	call	AFE.WriteRegister
	AFE.updateColumnParity
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;     w AFE.getStatus()                                                        |
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
;    AFE.ReadRegister                                                          |
;        SPI.Read                                                              |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    AFE.getStatus           ;get status register of AFE                       |
;    andlw 0x01              ;mask parity error bit                            |
;    btfss   STATUS,Z        ;error occured?                                   |
;    call    AFE.writeCfg    ;write back RAM Map to AFE (Parity will be        |
;    calculated)                                                               |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This example checks whether a parity error occured or not.            |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.getStatus	macro
	movlw	0x07
	call	AFE.ReadRegister
	banksel	AFE.ConfMap
	movf	(AFE.ConfMap+7),w
	endm
;------------------------------------------------------------------------------+
;                                                                              |
;     w AFE.updateColumnParity()                                               |
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
;    AFE.WriteRegister                                                         |
;        AFE.CalcParity                                                        |
;        SPI.Write                                                             |
;    AFE.CalcColumnParity                                                      |
;                                                                              |
;                                                                              |
;    Stacklevel: 2                                                             |
;                                                                              |
;                                                                              |
;    Example:                                                                  |
;    movlw   0x03                                                              |
;    call    AFE.WriteRegister                                                 |
;    AFE.updateColumnParity                                                    |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        This example writes the new column parity to the AFE.ConfMap and to   |
;        the device                                                            |
;                                                                              |
;------------------------------------------------------------------------------+
AFE.updateColumnParity	macro
	call	AFE.CalcColumnParity
	movlw	0x06
	call	AFE.WriteRegister
	endm
#endif
