SECTION .handlers_32

GLOBAL EXCEPTION_DE             ; Tipo 0
GLOBAL EXCEPTION_DB             ; Tipo 1
GLOBAL EXCEPTION_NMI            ; Tipo 2
GLOBAL EXCEPTION_BE             ; Tipo 3
GLOBAL EXCEPTION_OF             ; Tipo 4
GLOBAL EXCEPTION_BR             ; Tipo 5
GLOBAL EXCEPTION_UD             ; Tipo 6
GLOBAL EXCEPTION_NM             ; Tipo 7
GLOBAL EXCEPTION_DF             ; Tipo 8
GLOBAL EXCEPTION_CoS            ; Tipo 9
GLOBAL EXCEPTION_TS             ; Tipo 10
GLOBAL EXCEPTION_NP             ; Tipo 11
GLOBAL EXCEPTION_SS             ; Tipo 12
GLOBAL EXCEPTION_GP             ; Tipo 13
GLOBAL EXCEPTION_PF             ; Tipo 14
GLOBAL EXCEPTION_MF             ; Tipo 16
GLOBAL EXCEPTION_AC             ; Tipo 17
GLOBAL EXCEPTION_MC             ; Tipo 18
GLOBAL EXCEPTION_XM             ; Tipo 19
GLOBAL INTERRUPT_TIMER          ; Tipo 20
GLOBAL INTERRUPT_KeyBoard       ; Tipo 21

EXTERN offsetCB
EXTERN CircularBuffer
;EXTERN offsetKB
EXTERN timerFlag
EXTERN keyboardFlag
EXTERN cont

EXTERN __VIDEO_lineal

EXTERN __guardarDigito
EXTERN __recorrerBuffer
EXTERN __KeyboardbyPolling
EXTERN __limpiarBuffer
EXTERN __cleanLine
EXTERN __crear_pag_din

EXTERN msgPF_len
EXTERN msgPF
EXTERN msgGP_len
EXTERN msgGP
EXTERN __DTPK
EXTERN __myprintfXY

EXTERN tareaTeclado
EXTERN tareaVideo


EXCEPTION_DE:                   ; Divide Error Exception
    mov eax, 0x00
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_DE
    iret

EXCEPTION_DB:                   ; Debug Exception
    mov eax, 0x01
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_DB
    iret

EXCEPTION_NMI:                  ; Non maskable interrupt
    mov eax, 0x02
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_NMI
    iret

EXCEPTION_BE:                   ; Breakpoint Exception
    mov eax, 0x03
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_BE
    iret

EXCEPTION_OF:                   ; Overflow Exception
    mov eax, 0x04
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_OF
    iret

EXCEPTION_BR:                   ; Bound Range Exception
    mov eax, 0x05
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_BR
    iret

EXCEPTION_UD:                   ; Invalid Opcode Exception
    mov eax, 0x06
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_UD
    iret

EXCEPTION_NM:                   ; Device Not Available Exception
    mov eax, 0x07
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_NM
    iret

EXCEPTION_DF:                   ; Double Fault Exception
    mov eax, 0x08
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_DF
    iret

EXCEPTION_CoS:                   ; Coprocessor Segment Overrun Exception
    mov eax, 0x09
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_CoS
    iret

EXCEPTION_TS:                   ; Invalid TSS Exception
    mov eax, 0x0A
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_TS
    iret

EXCEPTION_NP:                   ; No Present Segment Exception
    mov eax, 0x0B
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_NP
    iret

EXCEPTION_SS:                   ; Stack Fault Exception
    mov eax, 0x0C
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_SS
    iret

EXCEPTION_GP:                   ; General Protection Fault Exception
    mov eax, 0x0D
    mov edx, eax

    push ebp
    mov ebp, esp    ;enter
    push 6
    push 6
    push msgGP_len
    push msgGP
    call __myprintfXY
    leave

    xchg bx,bx
    xchg bx,bx
    xchg bx,bx
    xchg bx,bx
    hlt
    jmp EXCEPTION_GP
    iret

EXCEPTION_PF:                   ; Page Fault Exception
    mov eax, 0x0E
    mov edx, eax

    ; Escribo en pantalla Fallo de página
    push ebp
    mov ebp, esp    ;enter
    push 6
    push 6
    push msgPF_len
    push msgPF
    call __myprintfXY
    leave
; TP13 pide deshabilitar la generación dinámica de páginas.
;;xchg bx,bx
;    ;Aca debo realizar agregar la página dinámica desde la 0x0800 0000
;    push ebp
;    mov ebp, esp    ;enter
;    mov eax,cr2
;    push eax
;    push __DTPK
;    call __crear_pag_din
;    leave
;;xchg bx,bx
;    ; Borro la linea de Fallo de Pagina de la pantalla
;    push ebp
;    mov ebp, esp    ;enter
;    push 6
;    push __VIDEO_lineal
;    call __cleanLine
;    leave
;;xchg bx,bx
;    pop eax
;    iret

    xchg bx,bx
    xchg bx,bx
    hlt
    jmp EXCEPTION_PF
    iret

EXCEPTION_MF:                   ; FPU Floating Point Error Exception
    mov eax, 0x10
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_MF
    iret

EXCEPTION_AC:                   ; Aligment Check Exception
    mov eax, 0x11
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_AC
    iret

EXCEPTION_MC:                   ; Machine Check Exception
    mov eax, 0x12
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_MC
    iret

EXCEPTION_XM:                   ; SIMD Floating Point Exception
    mov eax, 0x13
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_XM
    iret

INTERRUPT_TIMER:
    pushad                  ;salvo los registros de uso general
    mov ax, 1
    mov byte[timerFlag],al

 scheduler:

    mov al,0x20             ;envio end of interrupt al PIC
    out 0x20, al
    popad                   ;Restauro registros de uso general
    iret

INTERRUPT_KeyBoard:
; Revisa que la tecla no sea ENTER, si lo es termina.
; Guarda la tecla presionada en un buffer circular.
; Si ingresa por una tecla soltada, no hace nada y termina.

    pushad                  ;salvo los registros de uso general
    mov eax, 0x21           ; Guardo el tipo de interrupción
    mov edx, eax
    ;xchg bx,bx

    in al,0x60              ;leer tecla del buffer de teclado
    mov ebx,eax             ; Muevo el caracter a ebx

    cmp ax,(0x1C)               ; Si la tecla es ENTER
    je guardar                  ; Salta a guardar todo en memoria

    and al,al
    js fin_int20             ;termina si se suelta la tecla
  
    push ebp
    mov ebp, esp    ;enter
    push offsetCB
    push CircularBuffer         ; destino
    push eax                    ; caracter
    call __recorrerBuffer
    mov [offsetCB],eax                 ; guardo el destino siguiente
    leave
    xor eax,eax                 ; Limpio eax

 fin_int20:
    mov al,0x20             ;envio end of interrupt al PIC
    out 0x20,al

    popad
    iret

 guardar:
    ;xchg bx,bx
    mov ax,[keyboardFlag]
    inc ax
    mov [keyboardFlag],ax
    jmp fin_int20