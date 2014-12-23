#ifndef EEPROM_INC
#define EEPROM_INC

	#define EEPROM.RamAddress

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
	extern EEPROM.ADDRESS
	extern EEPROM.ByteCount
	extern EEPROM.Write, EEPROM.WriteBytes, EEPROM.Read, EEPROM.ReadBytes
;------------------------------------------------------------------------------+
;                                                                              |
;    EEPROM.Init()                                                             |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This macro initialises the EEPROM module                                  |
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
;    EEPROM.Init     ;initialises the EEPROM module                            |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        That's it                                                             |
;                                                                              |
;------------------------------------------------------------------------------+
EEPROM.Init	macro
	banksel	EEADR
	CLRF	EEDAT
	CLRF	EEADR
	CLRF	EECON1
	CLRF	EECON2
	endm
#endif
