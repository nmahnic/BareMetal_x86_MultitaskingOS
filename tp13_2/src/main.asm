USE32
SECTION .kernel32

GLOBAL kernel32_code_size
GLOBAL kernel32_init

GLOBAL idtr
;GLOBAL __IDT

EXTERN __KeyBoard_Enable

EXTERN tareaVideo
EXTERN tareaTeclado
EXTERN tareaNPagina
EXTERN tareaSum1
EXTERN tareaSum2
EXTERN tareaHLT

;-------------------------------------------------------------------------------------------
;                                          MAIN
;-------------------------------------------------------------------------------------------
kernel32_init:
    sti 
Ciclo_Principal:
    hlt
    jmp Ciclo_Principal