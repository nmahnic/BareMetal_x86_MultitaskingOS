SECTION .sys_tables progbits ; que es progbits

EXTERN EXCEPTION_DUMMY
;EXTERN __SYS_TABLE
EXTERN __SYS_TABLE_LMA
GLOBAL CS_SEL_32
GLOBAL DS_SEL
GLOBAL _gdtr

GDT:
NULL_SEL    EQU $-GDT               ; Primer descriptor de la GDT va vacio
    dq 0x0

CS_SEL_32   EQU $-GDT
; Base 0x00000000 - Limite 0xFFFFFFFF -Atributos 0b1100 |Limite| 0b10011001
    dw  0xFFFF      ; Limite 15-0
    dw  0x0000      ; Base   15-0
    db  0x00        ; Base   23-16
    db  10011001b   ;Atributos:
                    ; P = 1
                    ; DPL = 00
                    ; S = 1
                    ; D/C = 1
                    ; ED/C = 0
                    ; R/W  = 0
                    ; A = 1
    db  11001111b   ; Atrubutos + Limit 19-6 0xF
                    ; G = 1
                    ; D/B = 1
                    ; L = 0
                    ; AVL = 0
    db 0x00         ; Base 31-24
DS_SEL      EQU $-GDT
; Base 0x00000000 - Limite 0xFFFFFFFF -Atributos 0b1100 |Limite| 0b10011001
    dw  0xFFFF      ; Limite 15-0
    dw  0x0000      ; Base   15-0
    db  0x00        ; Base   23-16
    db  10010010b   ;Atributos:
                    ; P = 1
                    ; DPL = 00
                    ; S = 1
                    ; D/C = 0
                    ; ED/C = 0
                    ; R/W  = 1
                    ; A = 0
    db  11001111b   ; Limit 19-6 + Atributos
                    ; G = 1
                    ; D/B = 1
                    ; L = 0
                    ; AVL = 0
    db 0x00         ; Base 31-24
GDT_LENGTH      EQU $-GDT


_gdtr:
    dw GDT_LENGTH - 1
    dd __SYS_TABLE_LMA
    ;dd __SYS_TABLE      ; 0x000FFD00 es un shadow de la __SYS_TABLE_LMA
                        ; la GDT está en ROM. La idea es pasarla a RAM