
#ifndef	RF_INC
#define RF_INC


#ifndef RF__PIN
	#define RF__PIN		5		; RF Modulation Output
	#define RF__PORT		PORTC
#endif
	extern RF__Send_Header, RF__Send_Data, RF__SendBuffer



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
RF__Init	macro
	banksel TRISA
	bcf		RF__PORT,RF__PIN
	endm
#endif
