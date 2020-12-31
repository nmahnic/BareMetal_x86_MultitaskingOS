USE32
SECTION .dataD nobits		;nobits no lo ensambla en ROM (deja en la cabecera del bin para hacerlo en ram)
							;lo importante es que estén inicializadas en 0.


;HANDLER
GLOBAL offsetCB
GLOBAL CircularBuffer
GLOBAL offsetKB
GLOBAL timerFlag
GLOBAL keyboardFlag
GLOBAL cont


;HANDLER
offsetCB DD 0
CircularBuffer TIMES 0x10 DD 0
offsetKB DD 0
timerFlag DB 0
keyboardFlag DB 0
cont DD 0