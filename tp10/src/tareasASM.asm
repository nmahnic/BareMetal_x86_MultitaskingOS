;-------------------------------------------------------------------------------------------
;                                   TAREA TECLADO 1
;-------------------------------------------------------------------------------------------

USE32
SECTION .tarea1

GLOBAL tareaTeclado
GLOBAL tareaVideo

EXTERN __guardarDigito
EXTERN __KeyboardbyPolling
EXTERN __limpiarBuffer
EXTERN __sumaDigitos
EXTERN offsetCB
EXTERN CircularBuffer
EXTERN offsetKB

EXTERN keyboardFlag

tareaTeclado:           ;GUARDA SI APRETAN ENTER 
    mov al, byte[keyboardFlag]
    cmp al,0
    je mevoy

    ;xchg bx,bx
    mov al, 0x0
    mov [keyboardFlag], al

    push ebp
    mov ebp, esp    ;enter

    push __KeyboardbyPolling+20    ; memoria  de destino
    push CircularBuffer         ; Lista Circular
    push offsetKB               ; guarda el offser de __KeyboardbyPolling
    push offsetCB
    call __guardarDigito
    ;xchg bx,bx
    cmp eax,0x1000               
    jb rstoffsetKB                     ; Si ya llené 4K vuelvo empezar
    mov eax,0
    rstoffsetKB:    
    mov [offsetKB],eax                 ; guardo el destino siguiente
    leave

    ;xchg bx,bx

    push ebp
    mov ebp, esp    ;enter
    push offsetKB                   ; guarda el offser de __KeyboardbyPolling
    push __KeyboardbyPolling        ; memoria  de destino
    push __KeyboardbyPolling+20     ; memoria  de origen
    call __sumaDigitos
    leave

    push ebp
    mov ebp, esp    ;enter
    push CircularBuffer
    call __limpiarBuffer
    leave
    xor eax,eax                 ; Limpio eax
    ;xchg bx,bx
    ret

mevoy:
    ret

;-------------------------------------------------------------------------------------------
;                                   TAREA VIDEO 2
;-------------------------------------------------------------------------------------------
USE32
SECTION .tarea2

EXTERN msg
EXTERN msg_len
EXTERN __KeyboardbyPolling

tareaVideo:
    ;xchg bx,bx
    mov ebx, msg 			        ; esi apunta al buffer donde está el texto (buffer)  
    mov cx, msg_len	-1	            ; edx tiene la cantidad de bytes de la cadena de texto (cant)
    
    mov esi, 0xB8000                ; Puntero

linea1:
    mov al, [ebx]
    mov [esi],   al                   ; Escribo caracter en pantalla
    mov BYTE [esi+1],0x07           ; Escribo atributo en pantalla
    add esi,2                       ; Incremento el puntero
    inc ebx
    loop linea1

    mov eax, [__KeyboardbyPolling]
    cmp eax,0
    je sigo
    ;xchg bx,bx 
    call HEXtoBCD

sigo:
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