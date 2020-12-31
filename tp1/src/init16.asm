BITS 16
GLOBAL Init16
EXTERN Init32

SECTION .Init16
Init16:
    hlt
    jmp Init32