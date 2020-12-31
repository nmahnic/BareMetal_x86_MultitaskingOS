USE32
SECTION .functions

GLOBAL __fillall
EXTERN __VIDEO_lineal
EXTERN msg1
EXTERN msg1_len


__fillall:
    push ebp
    mov ebp, esp    ;enter

    mov ebx, msg1 			        ; esi apunta al buffer donde está el texto (buffer)  
    mov cx, msg1_len	-1	            ; edx tiene la cantidad de bytes de la cadena de texto (cant)
    
    mov esi, __VIDEO_lineal                ; Puntero
    ;mov esi, __VIDEO                       ; Puntero

 linea1:
    mov al, [ebx]
    mov [esi],   al                   ; Escribo caracter en pantalla
    mov BYTE [esi+1],0x07           ; Escribo atributo en pantalla
    add esi,2                       ; Incremento el puntero
    inc ebx
    loop linea1
;xchg bx,bx
    cmp esi,0x10FA0
    je sigo
    mov ebx, msg1 			        ; esi apunta al buffer donde está el texto (buffer)  
    mov cx, msg1_len	-1	            ; edx tiene la cantidad de bytes de la cadena de texto (cant)
    jmp linea1
 sigo:
    leave
    ret


USE32
SECTION .handlers_32

GLOBAL __addPageTables
EXTERN __DTP

__TP3    EQU __DTP + 0x3000

 ;------- 4ta a 7ma Pagina de la RAM (PAGETABLES = 0x0011 0000 identity mapping) ------
    ; Contenido de DTP
__addPageTables:
    push ebp
    mov ebp, esp    ;enter

    mov eax,[esp+8];
    mov ecx, eax
    mov eax, __TP3                   ; Esta tabla está en __DTP + 0x3000 (tabla num 3)
    add eax, 0x3                     ; ATTR de la DPE
    ; Apunto al DTPE y le cargo su contenido
    mov dword [__DTP + 0x000*4], eax 
    ; Apunto a PTE y le cargo su contenido
    mov ebx, __TP3 + 0x110*4
    mov eax, __DTP                  ; Dir de la pagina + ATTR  
    or eax, 0x003
    mov esi, ebx                    ;Apuntar a la tabla C00
    ;mov ecx,0x4
 ciclo1:
    mov [esi],eax                   ;Inicializar entrada del directorio.
    add esi,4                       ;Apuntar a la siguiente entrada.
    add eax,0x1000              ;Calcular siguiente valor.
    loop ciclo1      

;xchg bx,bx
    leave
    ret