#ifndef EEPROM_INC
#define EEPROM_INC

	#define EEPROM__RamAddress

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
	extern EEPROM_ADDRESS
	extern EEPROM_ByteCount
	extern EEPROM__Write, EEPROM__WriteBytes, EEPROM__Read, EEPROM__ReadBytes
;------------------------------------------------------------------------------+
;                                                                              |
;    EEPROM__Init()                                                             |
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
;    EEPROM__Init     ;initialises the EEPROM module                            |
;                                                                              |
;                                                                              |
;    Description:                                                              |
;        That's it                                                             |
;                                                                              |
;------------------------------------------------------------------------------+
EEPROM__Init	macro
	banksel	EEADR
	CLRF	EEDAT
	CLRF	EEADR
	CLRF	EECON1
	CLRF	EECON2
	endm
#endif
