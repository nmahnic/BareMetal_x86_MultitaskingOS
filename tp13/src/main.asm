USE32
SECTION .kernel32

GLOBAL kernel32_code_size
GLOBAL kernel32_init

GLOBAL idtr
GLOBAL __IDT

EXTERN __KeyBoard_Enable

EXTERN tareaVideo
EXTERN tareaTeclado
EXTERN tareaNPagina
EXTERN tareaSum1
EXTERN tareaSum2
EXTERN tareaHLT

EXTERN timerFlag

;-------------------------------------------------------------------------------------------
;                              Defino el espacio para la IDT
;-------------------------------------------------------------------------------------------
__IDT:
    TIMES ((0x20*8)+(0x2*8)) DD 0
    
idtr  dw ((0x20*8)+(0x2*8))-1
      dd __IDT  

;-------------------------------------------------------------------------------------------
;                                          MAIN
;-------------------------------------------------------------------------------------------
kernel32_init:

Ciclo_Principal:
    ;xchg bx,bx
    mov al,byte[timerFlag]
    cmp al,1
    je planifico
vuelvoCP:    
    hlt
    jmp Ciclo_Principal

planifico:
    ;xchg bx,bx
    mov al,0
    mov byte[timerFlag],al
    call tareaVideo
    call tareaTeclado
    call tareaNPagina
    call tareaSum1
    call tareaSum2
    call tareaHLT
    jmp vuelvoCP