;----------------------------------------------------------------------------------------
;                                           FUNCIONES
;----------------------------------------------------------------------------------------
USE32
SECTION .functions

GLOBAL __fillall
GLOBAL __init_myTSS
GLOBAL __set_idt_entry_asm

EXTERN __VIDEO_lineal
EXTERN msg1
EXTERN msg1_len
EXTERN DS_SEL_KER
EXTERN CS_SEL_KER
EXTERN DS_SEL_USR
EXTERN CS_SEL_USR

__init_myTSS:
    mov [eax], dword(0)                     ; <- EBX
    mov [eax + 4], dword(0)                 ; <- ECX
    mov [eax + 8], dword(0)                 ; <- EDX
    mov [eax + 12], dword(0)                ; <- EAX
    mov [eax + 16], dword(0)                ; <- ESI
    mov [eax + 20], dword(0)                ; <- EDI
    mov [eax + 24], dword(ecx)              ; <- EBP
    mov [eax + 28], dword(ecx)              ; <- ESP3
    mov [eax + 32], dword(DS_SEL_USR + 3)   ; <- GS
    mov [eax + 36], dword(DS_SEL_USR + 3)   ; <- FS
    mov [eax + 40], dword(DS_SEL_USR + 3)   ; <- SS3
    mov [eax + 44], dword(DS_SEL_USR + 3)   ; <- ES
    mov [eax + 48], dword(DS_SEL_USR + 3)   ; <- DS
    mov [eax + 52], dword(ebx)              ; <- CR3
    mov [eax + 56], dword(CS_SEL_USR + 3)   ; <- CS
    mov [eax + 60], dword(edx)              ; <- ESP0
    mov [eax + 64], dword(DS_SEL_KER)       ; <- SS0
    mov [eax + 68], dword(esi)              ; <- EIP
    mov [eax + 72], dword(0x0202)           ; <- EFLAGS
    
    ret

__set_idt_entry_asm:
    push ebp
    mov ebp, esp    ;enter
    mov eax, [ebp+8]            ;slot entry 0x80
    sal eax, 3
    add eax, [ebp+24]           ; __IDT
    mov ebx, [ebp+12]           ; selector de CS
    sal ebx, 0x10
    or ebx, [ebp+16]           ; Dir de SYSTEM CALL
    mov [eax], ebx
    add eax,4
    mov ebx, [ebp+20]           ; ATTR_INT + DPL
    sal ebx, 0x8
    mov [eax],ebx
    leave
ret

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

;----------------------------------------------------------------------------------------
;                                FUNCIONES DE HANDLERS
;----------------------------------------------------------------------------------------

USE32
SECTION .handlers_32

GLOBAL __addPageTables
EXTERN __DTPK

__TP3    EQU __DTPK + 0x3000

 ;------- 4ta a 7ma Pagina de la RAM (PAGETABLES = 0x0011 0000 identity mapping) ------
    ; Contenido de DTP
__addPageTables:
    push ebp
    mov ebp, esp    ;enter

    mov eax,[esp+8];
    mov ecx, eax
    mov eax, __TP3                   ; Esta tabla está en __DTPK + 0x3000 (tabla num 3)
    add eax, 0x3                     ; ATTR de la DPE
    ; Apunto al DTPE y le cargo su contenido
    mov dword [__DTPK + 0x000*4], eax 
    ; Apunto a PTE y le cargo su contenido
    mov ebx, __TP3 + 0x110*4
    mov eax, __DTPK                  ; Dir de la pagina + ATTR  
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