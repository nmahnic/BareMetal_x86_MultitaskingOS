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

EXTERN res_suma_T1
EXTERN ope_suma_T1
EXTERN VIDEO_T1

PRINT    EQU 2
HALT     EQU 1
READ1    EQU 3

tareaSum1:
;xchg bx,bx

    mov eax, [SumaFlagT1]
    cmp eax,1 
    je T1_3

    mov eax, READ1                      ; Lee de la tabla de digitos y guarda en res_suma_T1 y ope_suma_T1
    int 0x80

    push ebp
    mov ebp, esp    ;enter
    push res_suma_T1                    ; memoria  de destino
    push ope_suma_T1                    ; memoria  de origen
    call __sumaDigitosT1
    leave
    mov eax, 1
    mov [SumaFlagT1],eax

 T1_3:
    mov edx, res_suma_T1
    mov ecx, 8
    mov ebx, VIDEO_T1     ; Puntero
    mov eax, PRINT
    int 0x80

    mov eax, HALT
    int 0x80

    jmp tareaSum1
ret

__sumaDigitosT1:
	 enter 0,0

    mov  eax,[ebp+8]  ; origen
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

EXTERN res_suma_T2
EXTERN ope_suma_T2
EXTERN VIDEO_T2

;PRINT    EQU 2               ; Están definidas en T1 y el NASM ya reemplaza la etiqueta por su valor
;HALT     EQU 1               ; Una etiqueta no puede estar 2 veces definidas en un archivo
READ2    EQU 4

tareaSum2:
;xchg bx,bx

    mov eax, [SumaFlagT2]
    cmp eax,1 
    je T2_3

    mov eax, READ2                      ; Lee de la tabla de digitos y guarda en res_suma_T2 y ope_suma_T2
    int 0x80
 
    push ebp
    mov ebp, esp    ;enter
    push res_suma_T2                    ; memoria  de destino
    push ope_suma_T2                    ; memoria  de origen
    call __sumaDigitosT2
    leave
    mov eax, 1
    mov [SumaFlagT2],eax

 T2_3:
    mov edx, res_suma_T2
    mov ecx, 4
    mov ebx, VIDEO_T2     ; Puntero
    mov eax, PRINT
    int 0x80

    mov eax, HALT
    int 0x80

    jmp tareaSum2
    
ret

__sumaDigitosT2:
	enter 0,0

   mov  eax,[ebp+8]  ; origen
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
;xchg bx,bx
    mov eax, HALT
    int 0x80
    jmp tareaHLT
ret