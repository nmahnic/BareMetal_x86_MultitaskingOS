USE32
SECTION .kernel32

GLOBAL kernel32_code_size
GLOBAL kernel32_init

EXTERN __KeyBoard_Enable

kernel32_code_size EQU (kernel32_end - kernel32_init)

kernel32_init:

    push ebp
    mov ebp, esp    ;enter

    ;xchg bx,bx
    call __KeyBoard_Enable

    leave


.guard:
    xchg bx,bx
    hlt
    jmp .guard

kernel32_end: