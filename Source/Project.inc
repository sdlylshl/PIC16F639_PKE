

	list p=16F639				; list directive to define processor
	#include <p16f639.inc>      ; processor specific variable definitions

	ERRORLEVEL 0,-302,-312	; Messages, Warnings and Errors Printed
                        		; Ignore [301] => Processor Mismatch. 
                        		; Ignore [302] => Register in operand not in bank 0. 
								; Ignore [312] => Pagesel not needed for Device
