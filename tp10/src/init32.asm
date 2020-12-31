USE32
SECTION .start32

%include "inc/processor-flags.h"

EXTERN DS_SEL
EXTERN __STACK_END_32
EXTERN __STACK_START_32
EXTERN __STACK_SIZE_32
EXTERN CS_SEL_32
EXTERN kernel32_init
EXTERN __VIDEO
EXTERN __SysTable
EXTERN __KeyboardbyPolling
EXTERN __SYS_TABLE_VMA
EXTERN __SYS_TABLE_LMA
EXTERN __systable_size

EXTERN __set_dir_page_table_entry
EXTERN __set_page_table_entry
EXTERN __codigo_kernel32_size
EXTERN __fast_memcopy
EXTERN kernel32_code_size
EXTERN __KERNEL_32_VMA
EXTERN __KERNEL_32_LMA
EXTERN __ISR_size
EXTERN __ISR_LMA
EXTERN __ISR_VMA
EXTERN __TEXT1_VMA
EXTERN __TEXT1_LMA
EXTERN __TEXT1_size

EXTERN __handlers_32_size
EXTERN __HANDLERS_32_VMA
EXTERN __HANDLERS_32_LMA

EXTERN __data_size
EXTERN __DATA_VMA
EXTERN __DATA_LMA

EXTERN EXCEPTION_DE           ; Tipo 0
EXTERN EXCEPTION_DB           ; Tipo 1
EXTERN EXCEPTION_NMI          ; Tipo 2
EXTERN EXCEPTION_BE           ; Tipo 3
EXTERN EXCEPTION_OF           ; Tipo 4
EXTERN EXCEPTION_BR           ; Tipo 5
EXTERN EXCEPTION_UD           ; Tipo 6
EXTERN EXCEPTION_NM           ; Tipo 7
EXTERN EXCEPTION_DF           ; Tipo 8
EXTERN EXCEPTION_CoS          ; Tipo 9
EXTERN EXCEPTION_TS           ; Tipo 10
EXTERN EXCEPTION_NP           ; Tipo 11
EXTERN EXCEPTION_SS           ; Tipo 12
EXTERN EXCEPTION_GP           ; Tipo 13
EXTERN EXCEPTION_PF           ; Tipo 14
EXTERN EXCEPTION_MF           ; Tipo 16
EXTERN EXCEPTION_AC           ; Tipo 17
EXTERN EXCEPTION_MC           ; Tipo 18
EXTERN EXCEPTION_XM           ; Tipo 19
EXTERN INTERRUPT_TIMER        ;Tipo 21
EXTERN INTERRUPT_KeyBoard     ;Tipo 21

EXTERN __set_idt_entry
EXTERN __IDT
EXTERN idtr

EXTERN __DTP                  ; Directorios de Tablas de Pagina

ATTR_EXC EQU 0x0000008F
ATTR_INT EQU 0x0000008E

__TP    EQU __DTP + 0x1000

__TP1    EQU __DTP + 0x1000
__TP2    EQU __DTP + 0x2000
__TP3    EQU __DTP + 0x3000


GLOBAL start32_launcher

 ;-------------------------------------------------------------------------------------------
 ;                                    Si hay un error halteo
 ;-------------------------------------------------------------------------------------------
 guard:
    xchg bx,bx
    hlt
    jmp guard

 ;-------------------------------------------------------------------------------------------
 ;                             Inicio  de Kernel Modo Protegido
 ;-------------------------------------------------------------------------------------------

start32_launcher:             ;Sigo estado en ROM
;xchg bx,bx
    ; --> Inicializar el selector de datos <--
    mov ax, DS_SEL
    mov ds, ax
    mov es, ax
    mov gs, ax
    mov fs, ax

 ;----------------------------------------------------------------------------------------
 ;                                 Inicializo Pila de Kernel
 ;----------------------------------------------------------------------------------------
    ; --> Inicializar la pila <--
    mov ss, ax
    mov esp, __STACK_END_32
    xor eax,eax

    ; --> Limpio la pila <--
    mov ecx, __STACK_SIZE_32
    .stack_init:
        push eax
        loop .stack_init
    mov esp, __STACK_END_32

 ;----------------------------------------------------------------------------------------
 ;                 A partir de ahora puedo usar el Stack y tengo Paginación
 ;                            Cargo interupciones y Memcopeo codigo
 ;----------------------------------------------------------------------------------------
 ; --> Programo los PICs <--
    ;xchg bx,bx
    
    push ebp
    mov ebp,esp
    call ReprogramarPICs       ; No le paso parametros. (La uso desde ROM)
    leave

    push ebp
    mov ebp,esp
    call TIMER_init            ; No le paso parametros. (La uso desde ROM)
    leave

    ; --> Desempaquetamiento de la ROM (primero los handlers) <--
    push ebp
    mov ebp, esp    ;enter
    push __ISR_size
    push __ISR_VMA
    push __ISR_LMA
    call __fast_memcopy
    leave
    cmp eax, 1      ;Analizo el valor de retorno (1 Exito / -1 Fallo)
    jne guard

    ;xchg bx,bx

    ; --> Desempaquetamiento de la ROM (ahora el kernel) <--
    push ebp
    mov ebp, esp    ;enter
    push __codigo_kernel32_size
    push __KERNEL_32_VMA
    push __KERNEL_32_LMA
    call __fast_memcopy
    leave
    cmp eax, 1      ;Analizo el valor de retorno (1 Exito / -1 Fallo)
    jne guard

    ; --> Desempaquetamiento de la ROM (ahora el kernel) <--
    push ebp
    mov ebp, esp    ;enter
    push __TEXT1_size
    push __TEXT1_VMA
    push __TEXT1_LMA
    call __fast_memcopy
    leave
    cmp eax, 1      ;Analizo el valor de retorno (1 Exito / -1 Fallo)
    jne guard

        ; --> Desempaquetamiento de la ROM (ahora el kernel) <--
    push ebp
    mov ebp, esp    ;enter
    push __data_size
    push __DATA_VMA
    push __DATA_LMA
    call __fast_memcopy
    leave
    cmp eax, 1      ;Analizo el valor de retorno (1 Exito / -1 Fallo)
    jne guard
    
 ;----------------------------------------------------------------------------------------
 ;                                        Paginación
 ;----------------------------------------------------------------------------------------
    mov edi, __DTP
    mov ecx, 4*0x400             ; Limpio 16K (4 paginas) que usaré
    xor eax,eax                  ; 1 para DTP y 3 para TPs
    rep stosd                    ; de tablas de paginas (necesito minimo 2)

;xchg bx,bx
   ; Creo una pagina de 4M para la ROM (luego cambiar) ESTO ES UNA PRUEBA
    ;mov dword [__DTP + 0x000],0x00000083;Apuntar a la RAM
    ;mov dword [__DTP + 0x1FC],0x1FC00083;Apuntar Pila
    ;mov dword [__DTP + 0xFFC],0xFFC00083;Apuntar a la ROM

;xchg bx,bx

 ;------- 16 Paginas de 4K = 64K de ROM (ROM = 0xFFFF 0000) ------
    mov eax, __TP1                  ; Esta es la 1er tabla, está en __DTP + 0x1000 (tabla num 1)
    or eax, 0x3                     ; ATTR del DTE
    mov dword [__DTP + 0xFFC], eax  ;Apuntar a tabla de pags al finl del espacio direccionable.
    xor eax, eax
    mov eax, __TP1 + 0xFC0
    mov esi, eax                    ;Apuntar a la tabla C00
    mov ecx,0x10
    mov eax, 0xFFFF0003             ; Dir de la pagina + ATTR
 ciclo:
    mov [esi],eax                   ;Inicializar entrada del directorio.
    add esi,4                       ;Apuntar a la siguiente entrada.
    add eax,0x00001000              ;Calcular siguiente valor.
    loop ciclo

 ;------- Pagina de la Pila (Stack = 0x 1FF0 8000)------
    ; Contenido de DTP
    mov eax, __TP2                   ; Esta tabla está en __DTP + 0x2000 (tabla num 2)
    or eax, 0x3                     ; ATTR de la DTE
    ; Apunto al DPE y le cargo su contenido
    mov dword [__DTP + 0x07F*4], eax 
    ; Apunto a PTE y le cargo su contenido
    mov ebx, __TP2 + 0x308*4
    mov eax, __STACK_START_32
    or eax, 0x003             ; Dir de la pagina + ATTR   
    mov [ebx], eax     

 ;------- 1er Pagina de la RAM (ISR = 0x0000 0000) ------
    ; Contenido de DTP
    mov eax, __TP3                  ; Esta tabla está en __DTP + 0x3000 (tabla num 3)
    or eax, 0x3                     ; ATTR de la DTE
    ; Apunto al DPE y le cargo su contenido
    mov dword [__DTP + 0x000*4], eax 
    ; Apunto a PTE y le cargo su contenido
    mov ebx, __TP3 + 0x000*4
    mov eax, __ISR_VMA
    or eax, 0x003             ; Dir de la pagina + ATTR  
    mov [ebx], eax  

 ;------- 2da Pagina de la RAM (VIDEO = 0x000B 8000) ------
    ; Contenido de DTP
    mov eax, __TP3                  ; Esta tabla está en __DTP + 0x3000 (tabla num 3)
    or eax, 0x3                     ; ATTR del DPE
    ; Apunto al DTPE y le cargo su contenido
    mov dword [__DTP + 0x000*4], eax 
    ; Apunto a PTE y le cargo su contenido
    mov ebx, __TP3 + 0x0B8*4
    mov eax, __VIDEO                ; Dir de la pagina + ATTR  
    or eax, 0x003
    mov [ebx], eax     

 ;------- 3ra Pagina de la RAM (SYSTABLES = 0x0010 0000) ------
    ; Contenido de DTP
    mov eax, __TP3                    ; Esta tabla está en __DTP + 0x3000 (tabla num 3)
    or eax, 0x3                     ; ATTR de la DPE
    ; Apunto al DTPE y le cargo su contenido
    mov dword [__DTP + 0x000*4], eax 
    ; Apunto a PTE y le cargo su contenido
    mov ebx, __TP3 + 0x100*4
    mov eax, __SYS_TABLE_VMA             ; Dir de la pagina + ATTR  
    or eax, 0x003
    mov [ebx], eax      

 ;------- 4ta a 7ma Pagina de la RAM (PAGETABLES = 0x0011 0000) ------
    ; Contenido de DTP
    mov eax, __TP3                   ; Esta tabla está en __DTP + 0x3000 (tabla num 3)
    add eax, 0x3                     ; ATTR de la DPE
    ; Apunto al DTPE y le cargo su contenido
    mov dword [__DTP + 0x000*4], eax 
    ; Apunto a PTE y le cargo su contenido
    mov ebx, __TP3 + 0x110*4
    mov eax, __DTP                  ; Dir de la pagina + ATTR  
    or eax, 0x003
    mov esi, ebx                    ;Apuntar a la tabla C00
    mov ecx,0x5
 ciclo1:
    mov [esi],eax                   ;Inicializar entrada del directorio.
    add esi,4                       ;Apuntar a la siguiente entrada.
    add eax,0x1000              ;Calcular siguiente valor.
    loop ciclo1      

 ;------- 8va Pagina de la RAM (KENEL = 0x0020 0000) ------
    ; Contenido de DTP
    mov eax, __TP3                    ; Esta tabla está en __DTP + 0x3000 (tabla num 3)
    add eax, 0x3                     ; ATTR de la TP
    ; Apunto al DTPE y le cargo su contenido
    mov dword [__DTP + 0x000*4], eax 
    ; Apunto a PTE y le cargo su contenido
    mov ebx, __TP3 + 0x200*4
    mov eax, __KERNEL_32_VMA             ; Dir de la pagina + ATTR  
    or eax, 0x003
    mov [ebx], eax    

 ;------- 9na Pagina de la RAM (DATOS = 0x0020 2000) ------
    ; Contenido de DTP
    mov eax, __TP3                    ; Esta tabla está en __DTP + 0x3000 (tabla num 3)
    add eax, 0x3                     ; ATTR de la TP
    ; Apunto al DTPE y le cargo su contenido
    mov dword [__DTP + 0x000*4], eax 
    ; Apunto a PTE y le cargo su contenido
    mov ebx, __TP3 + 0x202*4
    mov eax, __DATA_VMA              ; Dir de la pagina + ATTR  
    or eax, 0x003
    mov [ebx], eax    

 ;------- 10ma Pagina de la RAM (Digitos = 0x0021 0000) ------
    ; Contenido de DTP
    mov eax, __TP3                   ; Esta tabla está en __DTP + 0x3000 (tabla num 3)
    add eax, 0x3                     ; ATTR de la TP
    ; Apunto al DTPE y le cargo su contenido
    mov dword [__DTP + 0x000*4], eax 
    ; Apunto a PTE y le cargo su contenido
    mov ebx, __TP3 + 0x210*4
    mov eax, __KeyboardbyPolling     ; Dir de la pagina + ATTR  
    or eax, 0x003
    mov [ebx], eax 

 ;------- 11va a 13va Tarea 1 (PAGETABLES = 0x0030 0000) ------
    ; Contenido de DTP
    mov eax, __TP3                    ; Esta tabla está en __DTP + 0x3000 (tabla num 3)
    add eax, 0x3                     ; ATTR de la TP
    ; Apunto al DTPE y le cargo su contenido
    mov dword [__DTP + 0x000*4], eax 
    ; Apunto a PTE y le cargo su contenido
    mov ebx, __TP3 + 0x300*4
    mov eax, __TEXT1_VMA             ; Dir de la pagina + ATTR  
    or eax, 0x003
    mov esi, ebx                    ;Apuntar a la tabla C00
    mov ecx,0x4
 ciclo2:
    mov [esi],eax                   ;Inicializar entrada del directorio.
    add esi,4                       ;Apuntar a la siguiente entrada.
    add eax,0x00001000              ;Calcular siguiente valor.
    loop ciclo2     

   ;mov dword [__DTP + 0x000],0x00000083;Apuntar a la RAM
;xchg bx,bx
   ; --> Activo Paginación <--
    mov eax,__DTP
    mov cr3,eax                ;Apuntar a directorio de paginas.
    mov eax,cr4                ;Activar el bit Page Size Enable (bit 4
    or al,0x10                 ;de CR4) para habilitar las paginas grandes.
    mov cr4,eax
    mov eax,cr0                ;Activar paginacion encendiendo el
    or eax,0x80000000          ;bit 31 de CR0.
    mov cr0,eax
;xchg bx,bx

 ;----------------------------------------------------------------------------------------
 ;                           Cargo Excepciones e Interrupciones
 ;----------------------------------------------------------------------------------------
 ; --> Cargar la IDT con Divide Error Exception #DE (TIPO 0) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC)            ; Atributos
    push dword(EXCEPTION_DE)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_32)           ; Segmento de la función que atiende la excepción
    push dword(0x00)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con Debug #DB (TIPO 1) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC)            ; Atributos
    push dword(EXCEPTION_DB)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_32)           ; Segmento de la función que atiende la excepción
    push dword(0x01)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con ? #NMI (TIPO 2) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC)            ; Atributos
    push dword(EXCEPTION_NMI)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_32)           ; Segmento de la función que atiende la excepción
    push dword(0x02)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con ? #BE (TIPO 3) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC)            ; Atributos
    push dword(EXCEPTION_BE)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_32)           ; Segmento de la función que atiende la excepción
    push dword(0x03)                ; Numero de excepción
    call __set_idt_entry
    leave
 
 ; --> Cargar la IDT con ? #OF (TIPO 4) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC)            ; Atributos
    push dword(EXCEPTION_OF)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_32)           ; Segmento de la función que atiende la excepción
    push dword(0x04)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con Rango de instrucción BOUND excedido #BR (TIPO 5) <--
    push ebp
    mov ebp, esp    ;enter

    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC)            ; Atributos
    push dword(EXCEPTION_BR)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_32)           ; Segmento de la función que atiende la excepción
    push dword(0x05)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con Invalid Opcode #UD (TIPO 6) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC)            ; Atributos
    push dword(EXCEPTION_UD)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_32)           ; Segmento de la función que atiende la excepción
    push dword(0x06)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con Device not found #NM (TIPO 7) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC)            ; Atributos
    push dword(EXCEPTION_NM)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_32)           ; Segmento de la función que atiende la excepción
    push dword(0x07)                ; Numero de excepción
    call __set_idt_entry
    leave

  ; --> Cargar la IDT con Double Fault Exception #DF (TIPO 8) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC)            ; Atributos
    push dword(EXCEPTION_DF)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_32)           ; Segmento de la función que atiende la excepción
    push dword(0x08)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con Divide Error Exception #DB (TIPO 9) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC)            ; Atributos
    push dword(EXCEPTION_CoS)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_32)           ; Segmento de la función que atiende la excepción
    push dword(0x09)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con TSS invalido #TS (TIPO 10) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC)            ; Atributos
    push dword(EXCEPTION_TS)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_32)           ; Segmento de la función que atiende la excepción
    push dword(0x0A)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con Segmento no presente #NP (TIPO 11) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC)            ; Atributos
    push dword(EXCEPTION_NP)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_32)           ; Segmento de la función que atiende la excepción
    push dword(0x0B)                ; Numero de excepción
    call __set_idt_entry
    leave
 
 ; --> Cargar la IDT con Stack Fault Exception #SS (TIPO 12) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC)            ; Atributos
    push dword(EXCEPTION_SS)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_32)           ; Segmento de la función que atiende la excepción
    push dword(0x0C)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con General Protection Exception #GP (TIPO 13) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC)            ; Atributos
    push dword(EXCEPTION_GP)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_32)           ; Segmento de la función que atiende la excepción
    push dword(0x0D)                ; Numero de excepción
    call __set_idt_entry
    leave
;xchg bx,bx
 ; --> Cargar la IDT con Page Fault Exception #PF (TIPO 14) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC)            ; Atributos
    push dword(EXCEPTION_PF)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_32)           ; Segmento de la función que atiende la excepción
    push dword(0x0E)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con Error matemarico x87 #MF (TIPO 16) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC)            ; Atributos
    push dword(EXCEPTION_MF)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_32)           ; Segmento de la función que atiende la excepción
    push dword(0x10)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con Error de alineación #AC (TIPO 17) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC)            ; Atributos
    push dword(EXCEPTION_AC)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_32)           ; Segmento de la función que atiende la excepción
    push dword(0x11)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con ? #MC (TIPO 18) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC)            ; Atributos
    push dword(EXCEPTION_MC)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_32)           ; Segmento de la función que atiende la excepción
    push dword(0x12)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con Exception float SIMD #XM (TIPO 19) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC)            ; Atributos
    push dword(EXCEPTION_XM)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_32)           ; Segmento de la función que atiende la excepción
    push dword(0x13)                ; Numero de excepción
    call __set_idt_entry
    leave

 ;==================================== INTERRUPCIONES ======================================
  ; --> Cargar la IDT con TIMER (TIPO 0x20) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_INT)            ; Atributos
    push dword(INTERRUPT_TIMER)  ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_32)           ; Segmento de la función que atiende la excepción
    push dword(0x20)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con Teclado (TIPO 0x21) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_INT)            ; Atributos
    push dword(INTERRUPT_KeyBoard)  ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_32)           ; Segmento de la función que atiende la excepción
    push dword(0x21)                ; Numero de excepción
    call __set_idt_entry
    leave

    lidt [idtr]

;xchg bx,bx
    jmp CS_SEL_32:kernel32_init

;-------------------------------------------------------------------------------------------
;                                   Progamación de ambos PICs
;-------------------------------------------------------------------------------------------
ReprogramarPICs:

;// Inicializaci�n PIC N�1
  ;//ICW1:
  mov     al,0x11;//Establece IRQs activas x flanco, Modo cascada, e ICW4
  out     0x20,al
  ;//ICW2:
  mov     al,0x20	;//Establece para el PIC#1 el valor base del Tipo de INT que recibi� en el registro BH = 0x20
  out     0x21,al
  ;//ICW3:
  mov     al,0x04;//Establece PIC#1 como Master, e indica que un PIC Slave cuya Interrupci�n ingresa por IRQ2
  out     0x21,al
  ;//ICW4
  mov     al,0x01;// Establece al PIC en Modo 8086
  out     0x21,al
 ;//Antes de inicializar el PIC N�2, deshabilitamos las Interrupciones del PIC1
  ;mov     al,0xFD	   ;(0b11111101) deja el teclado habilitado
  mov     al,0xFC	   ;(0b11111100) deja el timer y teclado habilitado
  ;mov     al,0xFE	   ;(0b11111110) deja el timer habilitado 
  out     0x21,al
 ;//Ahora inicializamos el PIC N�2
  ;//ICW1
  mov     al,0x11;//Establece IRQs activas x flanco, Modo cascada, e ICW4
  out     0xA0,al
  ;//ICW2
  mov     al,0x28	 ;//Establece para el PIC#2 el valor base del Tipo de INT que recibi� en el registro BL = 0x28
  out     0xA1,al
  ;//ICW3
  mov     al,0x02;//Establece al PIC#2 como Slave, y le indca que ingresa su Interrupci�n al Master por IRQ2
  out     0xA1,al
  ;//ICW4
  mov     al,0x01;// Establece al PIC en Modo 8086
  out     0xA1,al
 ;Enmascaramos el resto de las Interrupciones (las del PIC#2)
  mov     al,0xFF
  out     0xA1,al

  ;xchg bx,bx
  sti    ; hay que habilitar las interrupciones.

  ret


;-------------------------------------------------------------------------------------------
;                                   Inicializo el Timer
;-------------------------------------------------------------------------------------------
TIMER_init:
  ;Inicializar timer para que interrumpa cada 54.9ms
   mov al, 00110100b       ; canal cero, byte bajo y luego byte alto-
   out 0x43, al
   mov al, 0               ;Dividir 1193181hz por 65536. Eso da 18,2Hz aprox
                           ;es lo máximo que se puede dividir.
   out 0x40,al             ;programa byte bajo del timer de 16 bits
   out 0x40,al             ;programa alto del timer de 16 bits
   ret