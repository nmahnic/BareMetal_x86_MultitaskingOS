BITS 16
GLOBAL Reset
EXTERN Init16

SECTION .Reset
Reset:                  ;0xFFFFFFF0
    cli
    jmp Init16
    align 16