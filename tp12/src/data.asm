USE32
SECTION .dataD


;TareasASM
GLOBAL msg
GLOBAL msg_len

GLOBAL msg1
GLOBAL msg1_len

GLOBAL msgPag
GLOBAL msgPag_len

GLOBAL msgIDT
GLOBAL msgIDT_len

GLOBAL endLine
GLOBAL endLine_len

GLOBAL msgDir
GLOBAL msgDir_len

GLOBAL msgIn
GLOBAL msgIn_len

GLOBAL msgPF
GLOBAL msgPF_len

GLOBAL msgGP_len
GLOBAL msgGP

EXTERN GDT_LENGTH
EXTERN __SysTable
GLOBAL _gdtrVMA

;TareasASM
msg 	db	'Cuenta Actual: ',10;Mensaje a presentar, finaliza en CR (10)
msg_len EQU	$-msg		 		;$ Es una variable en la que se almacena 
				 				;el contador de programa interno de nasm
				 				;Soportada por cualquier ensamblador

msg1     db  '11111111112222222222333333333344444444445555555555666666666677777777778888888888',10;
msg1_len EQU	$-msg1		 		;$ Es una variable en la que se almacena 
				 				;el contador de programa interno de nasm
				 				;Soportada por cualquier ensamblador

msgPag     db  '*Paginacion Completa y GDT en RAM',10
msgPag_len EQU	$-msgPag

msgIDT     db  '*Excepciones e Interrupciones Cargadas',10
msgIDT_len EQU	$-msgIDT

endLine    db  '--------------------------------------------------------------------------------',10
endLine_len EQU	$-endLine

msgDir    db  'Direccion Marcada: 0x',10
msgDir_len EQU	$-msgDir

msgIn 	  db	'Input:',10
msgIn_len	EQU $-msgIn

msgPF	db		'***Fallo de pagina***',10
msgPF_len 	EQU $-msgPF

msgGP	db		'***Fallo de General de Proteccion***',10
msgGP_len 	EQU $-msgGP

;Systable
_gdtrVMA:
    dw GDT_LENGTH - 1
    dd __SysTable