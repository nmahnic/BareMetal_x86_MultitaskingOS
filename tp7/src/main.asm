USE32
SECTION .kernel32

GLOBAL kernel32_code_size
GLOBAL kernel32_init

GLOBAL idtr

EXTERN __IDT
EXTERN __KeyBoard_Enable

kernel32_code_size EQU (kernel32_end - kernel32_init)

idtr  dw (20*8)-1
      dd __IDT  

kernel32_init:

    lidt [idtr]

    ;xchg bx,bx

    push ebp
    mov ebp, esp    ;enter
    call __KeyBoard_Enable
    leave

    xchg bx,bx

.guard:
    xchg bx,bx
    hlt
    jmp .guard

kernel32_end: