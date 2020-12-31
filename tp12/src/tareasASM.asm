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
EXTERN hexa

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

    push ebp
    mov ebp, esp    ;enter
    push hexa
    push offsetKB                   ; guarda el offser de __KeyboardbyPolling
    push __KeyboardbyPolling        ; memoria  de destino
    push __KeyboardbyPolling+20     ; memoria  de origen
    call __sumaDigitos
    leave

    mov eax,[hexa]
;xchg bx,bx

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
SECTION .tarea

EXTERN msg
EXTERN msg_len
EXTERN __KeyboardbyPolling
EXTERN __VIDEO_lineal
EXTERN __VIDEO
EXTERN __clean
EXTERN __fillall
EXTERN __myprintf
EXTERN __myprintfY
EXTERN __myprintfXY
EXTERN WriteCharacter

tareaVideo:
    push ebp
    mov ebp, esp    ;enter
    push 3
    push 0
    push msg_len
    push msg
    call __myprintfXY
    leave

;xchg bx,bx

    mov esi, __VIDEO_lineal+((80*2)*3)+30      ; Puntero
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

;xchg bx,bx
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
;                                   TAREA nueva pagina 3
;-------------------------------------------------------------------------------------------
USE32
SECTION .tarea2

GLOBAL tareaNPagina
EXTERN hexa

tareaNPagina:
    mov eax, [hexa];
    cmp eax, 0x0
    je mefui                ; jump if greater
    cmp eax, 0x20000000
    jg mefui1                ; jump if greater
;xchg bx,bx
    mov eax, [hexa]         ; La consigna pide leer esa dirección (si esa dir no está paginada)
                            ; saltará el PF y generará dinámicamente un página con esa dir lineal
                            ; a la dir fisica 0x08000000.
                            ; la primer dir lineal ingresada (no presente) direccionará a la 0x08000XXX
                            ; la siguiente dir lineal direccionará a la pag 0x08001XXX
    ;Esta salta a esa dir, no es necesario
    mov eax, [hexa]
    mov ebx, [eax]          ; guardo el contenido de esa dirección para pisarlo y luego volver a ponerlo
    mov [eax],byte(0xC3)    ; en esa dirección le poner el opcode de RET
    call eax                ; salta a la dirección y pushea dir de retorno a la pila
    mov [eax],ebx
    mov eax,0
    mov [hexa],eax          ;le devuelve a esa dirección su contenido que fue pisado por el RET
    jmp mefui
mefui1:
;xchg bx,bx                 ;Breakpoint si el numero es mayor a 512MB
mefui:
ret