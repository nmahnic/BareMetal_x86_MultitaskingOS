;-------------------------------------------------------------------------------------------
;                                   TAREA suma 1
;-------------------------------------------------------------------------------------------
USE32
SECTION .tarea1

GLOBAL tareaSum1

EXTERN __VIDEO_lineal
EXTERN __KeyboardbyPolling
EXTERN __sumaDigitosT1
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
    cmp eax,1 
    je T1_3

    push ebp
    mov ebp, esp    ;enter
    push hexa
    push offsetKB                   ; guarda el offser de __KeyboardbyPolling
    push __KeyboardbyPolling        ; memoria  de destino
    push __KeyboardbyPolling+40     ; memoria  de origen
    call __sumaDigitosT1
    leave
    mov eax, 1
    mov [SumaFlagT1],eax

 T1_3:
    mov esi, __VIDEO_lineal+((80*2)*6)+34     ; Puntero
    mov eax, [__KeyboardbyPolling]
    cmp eax,0
    je T1_2

    call HEXtoBCD

 T1_2:
    mov al, [__KeyboardbyPolling+4]
    add al,0x30
    mov [esi], al                   ; Escribo caracter en pantalla
    mov BYTE [esi+1],0x07           ; Escribo atributo en pantalla
    add esi,2                       ; Incremento el puntero
    mov al, [__KeyboardbyPolling+8]
    add al,0x30
    mov [esi], al                   ; Escribo caracter en pantalla
    mov BYTE [esi+1],0x07           ; Escribo atributo en pantalla
    add esi,2                       ; Incremento el puntero
    mov al, [__KeyboardbyPolling+12]
    add al,0x30
    mov [esi], al                   ; Escribo caracter en pantalla
    mov BYTE [esi+1],0x07           ; Escribo atributo en pantalla
    add esi,2                       ; Incremento el puntero
    mov al, [__KeyboardbyPolling+16]
    add al,0x30
    mov [esi], al                   ; Escribo caracter en pantalla
    mov BYTE [esi+1],0x07           ; Escribo atributo en pantalla
    add esi,2                       ; Incremento el puntero

    jmp tareaSum1
ret

HEXtoBCD:
      mov      bx, 0000  
      mov      dh, 0   
 l2 :     cmp      ax, 1000     ; if ax>1000  
      jb      l4_  
      sub      ax, 1000  
      add      bx, 1000h        ; add 1000h to result 
      add      cx, 1h 
      mov [__KeyboardbyPolling+4],ecx
      jmp      l2 
 l4_: 
    mov cx,0 
 l4 :     cmp      ax, 100      ; if ax>100  
      jb      l6_  
      sub      ax, 100  
      add      bx, 100h         ; add 100h to result  
      add      cx, 1h
      mov [__KeyboardbyPolling+8],ecx
      jmp      l4 
 l6_:
    mov cx,0 
      
 l6 :     cmp      ax, 10       ; if ax>10  
      jb      l8  
      sub      ax, 10  
      add      bx, 10h          ; add 10h to result 
      add      cx, 1h          ; add 10h to result 
      mov [__KeyboardbyPolling+12],ecx
      jmp      l6  
 l8 :     add      bx, ax       ; add remainder   
                                ; to result 
      mov [__KeyboardbyPolling+16],eax
 
ret
;-------------------------------------------------------------------------------------------
;                                   TAREA suma 2
;-------------------------------------------------------------------------------------------
USE32
SECTION .tarea2

GLOBAL tareaSum2

EXTERN __VIDEO_lineal
EXTERN __KeyboardbyPolling
EXTERN __sumaDigitosT2
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
    cmp eax,1 
    je T2_3
 
    push ebp
    mov ebp, esp    ;enter
    push hexaT2
    push offsetKBT2                 ; guarda el offser de __KeyboardbyPolling
    push __KeyboardbyPolling+20     ; memoria  de destino
    push __KeyboardbyPolling+40     ; memoria  de origen 
    call __sumaDigitosT2
    leave
    mov eax, 1
    mov [SumaFlagT2],eax

 T2_3:
    mov esi, __VIDEO_lineal+((80*2)*7)+34     ; Puntero
    mov eax, [__KeyboardbyPolling+20]
    cmp eax,0
    je T2_2
 
    call HEXtoBCD_T2
;xchg bx,bx
 T2_2:
    mov al, [__KeyboardbyPolling+24]
    cmp al, 10
    ja overflow
    add al,0x30
    mov [esi], al                   ; Escribo caracter en pantalla
    mov BYTE [esi+1],0x07           ; Escribo atributo en pantalla
    add esi,2                       ; Incremento el puntero
    mov al, [__KeyboardbyPolling+28]
    add al,0x30
    mov [esi], al                   ; Escribo caracter en pantalla
    mov BYTE [esi+1],0x07           ; Escribo atributo en pantalla
    add esi,2                       ; Incremento el puntero
    mov al, [__KeyboardbyPolling+32]
    add al,0x30
    mov [esi], al                   ; Escribo caracter en pantalla
    mov BYTE [esi+1],0x07           ; Escribo atributo en pantalla
    add esi,2                       ; Incremento el puntero
    mov al, [__KeyboardbyPolling+36]
    add al,0x30
    mov [esi], al                   ; Escribo caracter en pantalla
    mov BYTE [esi+1],0x07           ; Escribo atributo en pantalla
    add esi,2                       ; Incremento el puntero
    jmp tareaSum2
    
 overflow:
    mov al,'X'
    mov [esi], al                   ; Escribo caracter en pantalla
    mov BYTE [esi+1],0x07           ; Escribo atributo en pantalla
    add esi,2                       ; Incremento el puntero
    mov [esi], al                   ; Escribo caracter en pantalla
    mov BYTE [esi+1],0x07           ; Escribo atributo en pantalla
    add esi,2                       ; Incremento el puntero
    mov [esi], al                   ; Escribo caracter en pantalla
    mov BYTE [esi+1],0x07           ; Escribo atributo en pantalla
    add esi,2                       ; Incremento el puntero
    mov [esi], al                   ; Escribo caracter en pantalla
    mov BYTE [esi+1],0x07           ; Escribo atributo en pantalla
    add esi,2                       ; Incremento el puntero

    jmp tareaSum2

ret

HEXtoBCD_T2:
    mov      bx, 0000  
    mov      dh, 0   
 T2_l2:     
    cmp      ax, 1000     ; if ax>1000  
    jb      T2_l4_  
    sub      ax, 1000  
     add      bx, 1000h        ; add 1000h to result 
    add      cx, 1h 
    mov [__KeyboardbyPolling+24],ecx
    jmp      T2_l2 
 T2_l4_: 
    mov cx,0 
 T2_l4:     
    cmp      ax, 100      ; if ax>100  
    jb      T2_l6_  
    sub      ax, 100  
    add      bx, 100h         ; add 100h to result  
    add      cx, 1h
    mov [__KeyboardbyPolling+28],ecx
    jmp      T2_l4 
 T2_l6_:
    mov cx,0 
      
 T2_l6:     
    cmp      ax, 10       ; if ax>10  
    jb      T2_l8  
    sub      ax, 10  
    add      bx, 10h          ; add 10h to result 
    add      cx, 1h          ; add 10h to result 
    mov [__KeyboardbyPolling+32],ecx
    jmp      T2_l6  
 T2_l8:     
    add      bx, ax       ; add remainder   
                                ; to result 
    mov [__KeyboardbyPolling+36],eax
 
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