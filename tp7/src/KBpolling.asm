USE32
SECTION .KB_enable

GLOBAL __KeyBoard_Enable
EXTERN __KeyboardbyPolling
EXTERN __guardarCaracter

;///////////////////////////////////////////////////////////////////////////////
;                   Funciones para habilitar el A20 Gate
;///////////////////////////////////////////////////////////////////////////////
%define     PORT_A_8042         0x60        ;Puerto A de E/S del 8042
%define     CTRL_PORT_8042      0x64        ;Puerto de Estado del 8042
%define     KEYB_DIS            0xAD        ;Deshabilita teclado con Command Byte / no espera nada
%define     KEYB_EN             0xAE        ;Habilita teclado con Command Byte / no espera nada
; OUT es el buffer de datos que espera ser leido por el OS              <- Los nombres parecen estar cruzados porque está pensado desde
; IN el el buffer de datos que espera ser atendidos por el 8042            el punto de vista del dispositivo que se conecta, no del OS 
%define     READ_OUT_8042       0xD0        ;Copia en 0x60 el estado de OUT / espera Controller Output Port
%define     WRITE_OUT_8042      0xD1        ;Escribe en OUT lo almacenado en 0x60 (check if output buffer is empty first) /no espera nada
%define     TEST_PS2_CONTROLLER 0xAA        ;Espera un 0x55 success o 0xFC failled

;------------------------------------------------------------------------------
;| Título: KBpolling                                                          |
;| Versión:       1.0                     Fecha:   26/04/2020                 |
;| Autor:         NicoMahnic              Modelo:  IA-32 (32bits)             |
;| ------------------------------------------------------------------------   |
;| Descripción:                                                               |
;|    Habilita la puerta A20 sin utilizacion de la pila.                      |
;|    Referencia https://wiki.osdev.org/"8042"_PS/2_Controller                |
;| ------------------------------------------------------------------------   |
;| Recibe:                                                                    |
;|    Nada                                                                    |
;|                                                                            |
;| Retorna:                                                                   |
;|    Nada                                                                    |
;| ------------------------------------------------------------------------   |
;| Revisiones:                                                                |
;|    1.0 | 26/04/2020 | NicoMahnic | Original                                |
;------------------------------------------------------------------------------

;-------------------------------------------
;|IO Port |	Access Type | 	   Purpose     |
;-------------------------------------------
;| 0x60   |	Read/Write  |	Data Port      |           <_-- En nuestro caso solo lectura
;| 0x64   |   Read 	    | Status Register  |
;| 0x64   |   Write 	| Command Register |
;-------------------------------------------

__KeyBoard_Enable:

; --> Habilita el teclado <--
    push ebp
    mov ebp, esp                ; enter
    ;pushf                       ;Desplaza las banderas actuales a la pila
    ;sub esp, 0x010              ; se reserva 16bytes para variables locales

.8042_kbrd_en:
    mov al, KEYB_EN             ; Le cargo 0xAE al puerto 0x64
    out CTRL_PORT_8042, al      ; Habilito el teclado

    ;xchg bx,bx

; --> Espero que el buffer OUT se vacie <--
    mov eax, __KeyboardbyPolling
    mov edi, eax

LECTURA:
    xor cx, cx
    mov cx, 0x02
    xor eax, eax

L1:
    mov bx, ax
.empty_8042_out:  
    in al, CTRL_PORT_8042       ; Lee port de estado del 8042
    and al, 00000001b           ; Enmascara todos los demás bits, 
    cmp al, 00000001b           ; buffer de salida este vacio
    jne .empty_8042_out

    ;Si el Buffer OUT tiene algo, lo guardo en bx

    in al, PORT_A_8042

    loop L1

    ;xchg bx,bx

    push ebp
    mov ebp, esp    ;enter

    push edi                ; destino
    push ebx                 ; caracter
    call __guardarCaracter
    add eax,1                   ; avanzo en 1 la dirección.
    mov edi,eax                 ; guardo el destino siguiente
    leave
    xor eax,eax                 ; Limpio eax 

    mov ax,bx
    cmp ax,0x21
    jne LECTURA

    ;xchg bx,bx

    ;popf                        ; Coloca las viejas banderas en su lugar
    leave
    ret