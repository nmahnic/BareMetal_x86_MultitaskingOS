;-------------------------------------------------------------------------------------------
;                                   TAREA suma 1
;-------------------------------------------------------------------------------------------
USE32
SECTION .tarea1

GLOBAL tareaSum1

EXTERN __VIDEO_lineal
EXTERN __KeyboardbyPolling
EXTERN hexa
EXTERN offsetKB
EXTERN SumaFlagT1
EXTERN msgT1

tareaSum1:
;xchg bx,bx 
;   mov eax,[0x1000]
;   mov eax,[0x2000]
;   mov eax,[0x4000]

    mov eax, 1
    mov ebx, 1
    mov ecx, 1
    mov edx, 1

    mov ecx,15
    mov esi, __VIDEO_lineal+((80*2)*6)      ; Puntero
    mov eax, msgT1
    mov edx, [eax]
    mov [esi], dl                   ; Escribo caracter en pantalla
    mov BYTE [esi+1],0x07           ; Escribo atributo en pantalla
 T1_1:
    add esi,2
    inc eax
    mov ebx, [eax]
    mov [esi], bl                   ; Escribo caracter en pantalla
    mov BYTE [esi+1],0x07           ; Escribo atributo en pantalla
    loop T1_1

    mov eax, [SumaFlagT1]
    ;mov eax, 1                ;ACORDARSE DE SACAR LINEA
    cmp eax,1 
    je T1_3

    push ebp
    mov ebp, esp    ;enter
    push offsetKB                   ; guarda el offser de __KeyboardbyPolling
    push __KeyboardbyPolling        ; memoria  de destino
    push __KeyboardbyPolling+40     ; memoria  de origen
    call __sumaDigitosT1
    leave
    mov eax, 1
    mov [SumaFlagT1],eax

;xchg bx,bx
 T1_3:
    mov esi, __VIDEO_lineal+((80*2)*6)+34     ; Puntero
    mov eax, __KeyboardbyPolling
    mov ecx, 8
 T1_2:
    mov ebx, [eax]
    sar ebx,0x4
    and ebx,0x0000000F
    cmp bl,0xA
    jb T1_a
    add bl,0x7
 T1_a:
    add bl,0x30
    mov [esi], bl                   ; Escribo caracter en pantalla
    mov BYTE [esi+1],0x07           ; Escribo atributo en pantalla
    add esi,2                       ; Incremento el puntero

    mov ebx, [eax]
    and ebx,0x0000000F
    cmp bl,0xA
    jb T1_b
    add bl,0x7
 T1_b:
    add bl,0x30
    mov [esi], bl                   ; Escribo caracter en pantalla
    mov BYTE [esi+1],0x07           ; Escribo atributo en pantalla
    add esi,4                       ; Incremento el puntero

    inc eax
    loop T1_2
;xchg bx,bx
    jmp tareaSum1
ret

__sumaDigitosT1:
	 enter 0,0

    mov  eax,[ebp+8]  ; origen
    mov  ebx,[ebp+16] ; offsetKBT1
    mov  ecx,[ebx]
    sub  ecx, 0x10
    add eax,ecx
    movq mm0,[eax]
    mov  eax,[ebp+12] ; destino
    movq mm1,[eax]
    paddq mm0,mm1
    movq [eax],mm0

	 leave
ret
;-------------------------------------------------------------------------------------------
;                                   TAREA suma 2
;-------------------------------------------------------------------------------------------
USE32
SECTION .tarea2

GLOBAL tareaSum2

%include "inc/processor-flags.h"

EXTERN __VIDEO_lineal
EXTERN __KeyboardbyPolling
EXTERN hexaT2
EXTERN SumaFlagT2
EXTERN offsetKBT2

EXTERN msgT2

tareaSum2:
;xchg bx,bx
    mov eax, 2
    mov ebx, 2
    mov ecx, 2
    mov edx, 2

    mov ecx,15                              ; msgT2_len <- No se guarda con EQU
    mov esi, __VIDEO_lineal+((80*2)*7)      ; Puntero
    mov eax, msgT2
    mov edx, [eax]
    mov [esi], dl                   ; Escribo caracter en pantalla
    mov BYTE [esi+1],0x07           ; Escribo atributo en pantalla
T2_1:
    add esi,2
    inc eax
    mov ebx, [eax]
    mov [esi], bl                   ; Escribo caracter en pantalla
    mov BYTE [esi+1],0x07           ; Escribo atributo en pantalla
    loop T2_1

    mov eax, [SumaFlagT2]
    ;mov eax, 1                ;ACORDARSE DE SACAR LINEA
    cmp eax,1 
    je T2_3
 
    push ebp
    mov ebp, esp    ;enter
    push offsetKBT2                 ; guarda el offser de __KeyboardbyPolling
    push __KeyboardbyPolling+20     ; memoria  de destino
    push __KeyboardbyPolling+40     ; memoria  de origen 
    call __sumaDigitosT2
    leave
    mov eax, 1
    mov [SumaFlagT2],eax

 T2_3:
    mov esi, __VIDEO_lineal+((80*2)*7)+34     ; Puntero
    mov eax, __KeyboardbyPolling+20

    mov ecx, 2
 T2_2:
    mov ebx,[eax]
    and ebx,0x000000F0
    sar ebx,0x4
    cmp bl,0xA
    jb T2_a
    add bl,0x7
 T2_a:
    add bl,0x30
    mov [esi], bl                   ; Escribo caracter en pantalla
    mov BYTE [esi+1],0x07           ; Escribo atributo en pantalla
    add esi,2                       ; Incremento el puntero

    mov ebx,[eax]
    and ebx,0x0000000F
    cmp bl,0xA
    jb T2_b
    add bl,0x7
 T2_b:
    add bl,0x30
    mov [esi], bl                   ; Escribo caracter en pantalla
    mov BYTE [esi+1],0x07           ; Escribo atributo en pantalla
    add esi,2                       ; Incremento el puntero

    mov ebx,[eax]
    and ebx,0x0000F000
    sar ebx,0x0C
    cmp bl,0xA
    jb T2_c
    add bl,0x7
 T2_c:
    add bl,0x30
    mov [esi], bl                   ; Escribo caracter en pantalla
    mov BYTE [esi+1],0x07           ; Escribo atributo en pantalla
    add esi,2                       ; Incremento el puntero

    mov ebx,[eax]
    and ebx,0x00000F00
    sar ebx,0x08
    cmp bl,0xA
    jb T2_d
    add bl,0x7
 T2_d:
    add bl,0x30
    mov [esi], bl                   ; Escribo caracter en pantalla
    mov BYTE [esi+1],0x07           ; Escribo atributo en pantalla
    add esi,4                       ; Incremento el puntero

    add eax,0x2
    loop T2_2

    jmp tareaSum2
    
ret

__sumaDigitosT2:
	enter 0,0

   mov  eax,[ebp+8]  ; origen
   mov  ebx,[ebp+16] ; offsetKBT2
   mov  ecx,[ebx]
   sub  ecx, 0x10
   add eax,ecx
   movd mm0,[eax]
	paddusw mm0,[eax+4]
   mov  eax,[ebp+12] ; destino
   movd mm1,[eax]
   paddusw mm0,mm1
   movd [eax],mm0

	leave
ret
;-------------------------------------------------------------------------------------------
;                                   TAREA halt 3
;-------------------------------------------------------------------------------------------
USE32
SECTION .tarea3

GLOBAL tareaHLT

tareaHLT:
;xchg bx, bx
    hlt
    hlt
    hlt
    hlt
    jmp tareaHLT
ret