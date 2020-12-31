USE32
SECTION .kernel32

EXTERN status_tarea
EXTERN timerFlag

EXTERN __myprintfXY
EXTERN __myprintfY

EXTERN msgIDT_len
EXTERN msgIDT
EXTERN endLine_len
EXTERN endLine
EXTERN msgPFa_len
EXTERN msgPFa
EXTERN msgGPa_len
EXTERN msgGPa
EXTERN msgT1_len
EXTERN msgT1
EXTERN msgT2_len
EXTERN msgT2
EXTERN msgInst_len
EXTERN msgInst

GLOBAL kernel32_init

;-------------------------------------------------------------------------------------------
;                                          MAIN
;-------------------------------------------------------------------------------------------
kernel32_init:
   ; Imprime texto en pantalla
    push ebp
    mov ebp, esp    ;enter
    push 1
    push 2
    push msgIDT_len
    push msgIDT
    call __myprintfXY
    leave

    push ebp
    mov ebp, esp    ;enter
    push 2
    push endLine_len
    push endLine
    call __myprintfY
    leave

    push ebp
    mov ebp, esp    ;enter
    push 3
    push msgPFa_len
    push msgPFa
    call __myprintfY
    leave

    push ebp
    mov ebp, esp    ;enter
    push 4
    push msgGPa_len
    push msgGPa
    call __myprintfY
    leave

    push ebp
    mov ebp, esp    ;enter
    push 7
    push msgT1_len
    push msgT1
    call __myprintfY
    leave

    push ebp
    mov ebp, esp    ;enter
    push 8
    push msgT2_len
    push msgT2
    call __myprintfY
    leave

    push ebp
    mov ebp, esp    ;enter
    push 23
    push msgInst_len
    push msgInst
    call __myprintfY
    leave

    xor eax,eax
    mov [timerFlag],eax             ; Reseteo Flags
    mov [status_tarea],eax

;xchg bx,bx    
    sti 
    
Ciclo_Principal:
    hlt
    jmp Ciclo_Principal