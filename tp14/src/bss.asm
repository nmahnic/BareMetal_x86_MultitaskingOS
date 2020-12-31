USE32
SECTION .bssT nobits         ;nobits no lo ensambla en ROM (deja en la cabecera del bin para hacerlo en ram)
							;lo importante es que estén inicializadas en 0.

; Scheduler
GLOBAL timerFlag
GLOBAL new_stack
GLOBAL status_tarea
GLOBAL timerT1	

; SIMD
GLOBAL status_SIMD

; Scheduler
timerFlag 					DD 0
new_stack					DD 0
new_stack_seg				DD 0
status_tarea				DD 0
timerT1						DD 0

; SIMD
status_SIMD					DD 0


;-------------------------------------------------------------------------------------------------------------
USE32
SECTION .bssT1 nobits

; Teclado
GLOBAL offsetCB
GLOBAL CircularBuffer
GLOBAL offsetKB
GLOBAL hexa
GLOBAL SumaFlagT1

;Scheduler
GLOBAL status_T1

; Teclado
offsetCB 					DD 0
CircularBuffer TIMES 0x10 	DD 0
offsetKB 					DD 0
hexa 						DD 0
SumaFlagT1					DD 0

;Scheduler
status_T1					DD 0

;-------------------------------------------------------------------------------------------------------------
USE32
SECTION .bssT2 nobits

;Scheduler
GLOBAL status_T2

;App
GLOBAL SumaFlagT2
GLOBAL hexaT2
GLOBAL offsetKBT2

;Scheduler
status_T2					DD 0

;App
SumaFlagT2					DD 0
hexaT2						DD 0
offsetKBT2					DD 0
;-------------------------------------------------------------------------------------------------------------
USE32
SECTION .bssT3 nobits

;Scheduler
GLOBAL status_T3

;Scheduler
status_T3					DD 0
