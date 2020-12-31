USE32
SECTION .kernel32

GLOBAL kernel32_code_size
GLOBAL kernel32_init

GLOBAL idtr
GLOBAL __IDT

EXTERN __KeyBoard_Enable

EXTERN tareaVideo
EXTERN tareaTeclado

EXTERN timerFlag

kernel32_code_size EQU (kernel32_end - kernel32_init)

__IDT:
    TIMES ((0x20*8)+(0x2*8)) DD 0
    
idtr  dw ((0x20*8)+(0x2*8))-1
      dd __IDT  

kernel32_init:

    lidt [idtr]
    ;xchg bx,bx
 ;Inicializa controlador de teclado
    mov al,0xFF
    out 0x64, al            ;Enviar comando de reset al controlador de teclado
    mov ecx, 256            ; Espera que rearranque el controlador
    loop $
    mov ecx,0x10000
 ciclo1:
    in al, 0x60             ;espera que termine el reset del controlador
    test al,1
    loopz ciclo1
    mov al, 0xF4            ;habilita teclado
    out 0x64, al
    mov ecx, 0x10000
 ciclo2:
    in al,0x60              ;espera que termime el comando
    test al,1
    loopz ciclo2
    in al,0x60              ;Vaciar el buffer de teclado


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
    jmp vuelvoCP

.guard:
    xchg bx,bx
    hlt
    jmp .guard

kernel32_end: