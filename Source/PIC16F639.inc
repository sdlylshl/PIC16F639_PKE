
#define CommsLED	PORTC,0		; LED D4
#define ErrorLED	PORTA,5		; LED D5



#define	LFDATA		PORTC,3		; Low Frequency Data IN

#define	REC_EVENT	4
#define	IDLE		6
#define	RF_START	7
#define	RF_Button	0


	ifndef MSG_INTERRUPT
	#define	MSG_INTERRUPT	(1<<REC_EVENT)
	endif


	ifndef BUTTON_MASK
	#define	BUTTON_MASK		B'00000001'
	endif


;------------------------------------------------------------------------------+
;                                                                              |
;    Module PIC16F639                                                          |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This module implements the top level entity or main program loop.         |
;    The decision, whether to compute a certain event or not are made here.    |
;    When such an event needs to be interpreted, the correct handler function  |
;    will be called.                                                           |
;    Currently implemented events and their corresponding handlers:            |
;    REC_EVENT - Whenever the RX line goes high, such an event will be         |
;    generated                                                                 |
;    MESSAGE_HANDLER - The handler function for REC_EVENTS                     |
;    BUTTON_EVENTS - These events are generated, when a button                 |
;        changes it's state (internally debounced)                             |
;    Button_Handler - The handler function for button events                   |
;    IDLE - This event will be generated, after a certain amount               |
;        of time (adjustable with the TIMEOUT constant), if no other event was |
;        generated                                                             |
;    BED(internally) - The handler for IDLE events                             |
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
	extern	EVENT_REG
;------------------------------------------------------------------------------+
;                                                                              |
;    Field Button_old                                                          |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    This register is a copy of PORTA, when the last button event occured      |
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
	extern	Button_old
;------------------------------------------------------------------------------+
;                                                                              |
;    Field EE_DATA                                                             |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    Referrence to the DATA in the EEPROM__                                     |
;    The first four bytes are the Serial number                                |
;    The next eight bytes are the Encryption Key                               |
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
	extern	EE_DATA
;------------------------------------------------------------------------------+
;                                                                              |
;    Field EE_USER                                                             |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    Referrence to the beginning of userspace EEPROM memory.                   |
;    The following 8 bytes are reserved for that purpose.                      |
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
	extern	EE_USER
	extern	BUTTON_DELAY
