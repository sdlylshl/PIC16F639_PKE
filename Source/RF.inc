
#ifndef	RF_INC
#define RF_INC


#ifndef RF.PIN
	#define RF.PIN		5		; RF Modulation Output
	#define RF.PORT		PORTC
#endif
	extern RF.Send_Header, RF.Send_Data, RF.SendBuffer



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
RF.Init	macro
	banksel TRISA
	bcf		RF.PORT,RF.PIN
	endm
#endif
