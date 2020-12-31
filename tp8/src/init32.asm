USE32
SECTION .start32

EXTERN DS_SEL
EXTERN __STACK_END_32
EXTERN __STACK_SIZE_32
EXTERN CS_SEL_32
EXTERN kernel32_init
EXTERN __KERNEL_32_LMA
EXTERN __codigo_kernel32_size
EXTERN __fast_memcopy
EXTERN kernel32_code_size
EXTERN __functions_size
EXTERN __FUNCTIONS_LMA
EXTERN __KERNEL_32_VMA
EXTERN __FUNCTIONS_VMA

EXTERN __handlers_32_size
EXTERN __HANDLERS_32_VMA
EXTERN __HANDLERS_32_LMA

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

ATTR_EXC EQU 0x0000008F
ATTR_INT EQU 0x0000008E

GLOBAL start32_launcher


start32_launcher:
    ; --> Inicializar el selector de datos <--
    mov ax, DS_SEL
    mov ds, ax
    mov es, ax
    mov gs, ax
    mov fs, ax

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
 ;                            A partir de ahora puedo usar el Stack
 ;----------------------------------------------------------------------------------------
 ; --> Programo los PICs <--
    ;xchg bx,bx
    
    push ebp
    mov ebp,esp
    call ReprogramarPICs            ; No le paso parametros. (La uso desde ROM)
    leave

    ;xchg bx,bx

    ; --> Desempaquetamiento de la ROM (primero las funciones) <--
    push ebp
    mov ebp, esp    ;enter
    push __functions_size
    push __FUNCTIONS_VMA
    push __FUNCTIONS_LMA
    call __fast_memcopy
    leave
    cmp eax, 1      ;Analizo el valor de retorno (1 Exito / -1 Fallo)
    jne .guard

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
    jne .guard

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


    jmp CS_SEL_32:kernel32_init

;-------------------------------------------------------------------------------------------
;                                    Si hay un error halteo
;-------------------------------------------------------------------------------------------
.guard:
   xchg bx,bx
   hlt
   jmp .guard

;-------------------------------------------------------------------------------------------
;                                   Progamación de ambos PICs
;-------------------------------------------------------------------------------------------
ReprogramarPICs:
;Inicializar timer para que interrumpa cada 54.9ms
   mov al, 00110100b       ; canal cero, byte bajo y luego byte alto-
   out 0x43, al
   mov al, 0               ;Dividir 1193181hz por 65536. Eso da 18,2Hz aprox
   out 0x40,al             ;programa byte bajo del timer de 16 bits
   out 0x40,al             ;programa byte bajo del timer de 16 bits

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