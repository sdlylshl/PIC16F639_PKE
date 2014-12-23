
;------------------------------------------------------------------------------+
;                                                                              |
;    Module Button_Handler                                                     |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    Button_Handler.asm                                                        |
;    This class handles button events                                          |
;    Jan Ornter                                                                |
;    DATE:   11-9-2005                                                         |
;    VER.:   1.0                                                               |
;    A simple sample implemantation is the following:                          |
;    Implement the Button_Handler function (this is the function which         |
;    is been called from the main routine. Disable the REC_EVENT (setting      |
;    the correct bit in IOCA to zero). As the basestation may block            |
;    RF-Communication, any RF-Message should be transmitted several times.     |
;    This is done by adding a counter in this handler routine and counter in   |
;    the interrupt service routine of Timer0, as this is counting the IDLE time|
;    anyway. When EVENT_REG,0 is one (falling edge on RA0 occurred)            |
;    then send (for example) an open door command over the RF interface.       |
;    When the repeat counter has finished, clear the Button events.            |
;    Enable REC_EVENT and return.                                              |
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
#include Project.inc
#include PIC16F639.inc
#include RF.inc

	global Button_Handler, Button_Handler_Init

#define Delay	0x03
#define Retry	0x0f

Button_Handler_VAR	udata
Counter		res 1
	code
	
;------------------------------------------------------------------------------+
;                                                                              |
;    Button_Handler_Init()                                                     |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    Initilizes needed registers for the BUTTON_HANDLER                        |
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
Button_Handler_Init
	banksel Counter
	clrf	Counter
	clrf	BUTTON_DELAY
	return
	
;------------------------------------------------------------------------------+
;                                                                              |
;    Module Button_Handler                                                     |
;                                                                              |
;------------------------------------------------------------------------------+
;                                                                              |
;    Button_Handler.asm                                                        |
;    This class handles button events                                          |
;    Jan Ornter                                                                |
;    DATE:   11-9-2005                                                         |
;    VER.:   1.0                                                               |
;    A simple sample implemantation is the following:                          |
;    Implement the Button_Handler function (this is the function which         |
;    is been called from the main routine. Disable the REC_EVENT (setting      |
;    the correct bit in IOCA to zero). As the basestation may block            |
;    RF-Communication, any RF-Message should be transmitted several times.     |
;    This is done by adding a counter in this handler routine and counter in   |
;    the interrupt service routine of Timer0, as this is counting the IDLE time|
;    anyway. When EVENT_REG,0 is one (falling edge on RA0 occurred)            |
;    then send (for example) an open door command over the RF interface.       |
;    When the repeat counter has finished, clear the Button events.            |
;    Enable REC_EVENT and return.                                              |
;                                                                              |
;                                                                              |
;------------------------------------------------------------------------------+
Button_Handler
	banksel	Counter
	movf	Counter,F
	btfss	STATUS,Z				; is counter zero?
	goto	Button_Count			; no, then count down
	movlw	Retry					; yes, then load counter (first call after button has been pressed)
	movwf	Counter
	movlw	Delay					; load delay counter again
	movwf	BUTTON_DELAY
Button_Count
	btfss	EVENT_REG, RF_START
	goto	END_BUTTON_HANDLER
	decfsz	Counter,F				; is Counter one?
	goto	Button_Exec				; no, then transmit RF
	movlw	(~BUTTON_MASK)			; yes, then clear all button events
	andwf	EVENT_REG,F
	goto	END_BUTTON_HANDLER
Button_Exec
	movlw	Delay					; load delay counter again
	movwf	BUTTON_DELAY
	bcf		EVENT_REG, RF_START		; clear delay flag
	
	
	;The action on a pressed button
BOOT_BTN
	btfss	EVENT_REG, RF_Button	; was the button on RA0 pressed?
	goto	MIDDLE_BTN				; no, then end (the only used button)
	call	RF__Send_Header			; yes, then send a data packet over the RF-Interface
	movlw	0x64
	call	RF__Send_Data			;Send a command
MIDDLE_BTN	
;	btfss	EVENT_REG, 2			; was the button on RA2 pressed?
;	goto	LOCK_BTN				; no, then end (the only used button)
;	call	RF__Send_Header			; yes, then send a data packet over the RF-Interface
;	movlw	0x65
;	call	RF__Send_Data			;Send a command
	
LOCK_BTN
;	btfss	EVENT_REG, 3			; was the button on RA3 pressed?
;	goto	UNLOCK_BTN				; no, then end (the only used button)
;	call	RF__Send_Header			; yes, then send a data packet over the RF-Interface
;	movlw	0x66
;	call	RF__Send_Data			;Send a command
	
UNLOCK_BTN
;	btfss	EVENT_REG, 4			; was the button on RA4 pressed?
;	goto	ALERT_BTN				; no, then end (the only used button)
;	call	RF__Send_Header			; yes, then send a data packet over the RF-Interface
;	movlw	0x67
;	call	RF__Send_Data			;Send a command
	
ALERT_BTN
;	btfss	EVENT_REG, 5			; was the button on RA5 pressed?
;	goto	END_BUTTON_HANDLER		; no, then end (the only used button)
;	call	RF__Send_Header			; yes, then send a data packet over the RF-Interface
;	movlw	0x68
;	call	RF__Send_Data			;Send a command
	
	
END_BUTTON_HANDLER
	return
	
	END
