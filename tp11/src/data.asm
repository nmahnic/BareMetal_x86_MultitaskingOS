USE32
SECTION .dataD


;TareasASM
GLOBAL msg
GLOBAL msg_len

EXTERN GDT_LENGTH
EXTERN __SysTable
GLOBAL _gdtrVMA

;TareasASM
msg 	db	'Cuenta Actual: ',10;Mensaje a presentar, finaliza en CR (10)
msg_len EQU	$-msg		 		;$ Es una variable en la que se almacena 
				 				;el contador de programa interno de nasm
				 				;Soportada por cualquier ensamblador

;Systable
_gdtrVMA:
    dw GDT_LENGTH - 1
    dd __SysTable