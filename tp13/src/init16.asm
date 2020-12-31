%include "inc/processor-flags.h"

USE16                           ; Modo 16 bits USE16 = BITS 16 es para compatibilidad de compiladores
SECTION .ROM_init               ; El contenido siguiente integrado en la sección .ROM_init

EXTERN CS_SEL_32
EXTERN _gdtrLMA
EXTERN start32_launcher
EXTERN A20_Enable_No_Stack
EXTERN __STACK_END_16
EXTERN __STACK_START_16

GLOBAL start16
GLOBAL A20_Enable_No_Stack_return

start16:
%include "inc/init_pci.inc"
    test eax, 0x0;                   ; Hace un test del registro EAX
    jne fault_end                   ; si hubo un errot salta a un halted y muere el programa
                                    ; porque nada lo puede sacar del halt porque no hay excepciones definidas.

    ; ->Hablitiltar A20 Gate<-
    jmp A20_Enable_No_Stack         ; Salta al archivo a20.asm, no se puede hacer con CALL
                                    ; por que no hay STACK

A20_Enable_No_Stack_return:

    ;xchg bx, bx                      ; Magic Breakpoint para saltar el A20

    xor eax, eax                     ; limpia eax (eax = 0)
    mov cr3, eax                     ; Invaliadar TLB (se usará para paginación y cache)

    ; --> Setear stact de 16 bits <--
    mov ax, cs
    mov ds, ax
    mov ax, __STACK_START_16
    mov ss, ax
    mov sp, __STACK_END_16

    ; --> Deshabilitar cache <--
    mov eax, cr0
    or eax, (X86_CR0_NW | X86_CR0_CD)
    mov cr0, eax
    wbinvd                            ; Write back and invalidates cache

    ;xchg bx, bx
    o32 lgdt [cs:_gdtrLMA]                      ;Carga lo apuntado por esa direccion de memoria en la GDT

    ; --> Habilito el Modo Protegido <--
    smsw ax
    or   ax, X86_CR0_PE
    lmsw ax

    ;xchg bx, bx
    
    jmp DWORD CS_SEL_32:start32_launcher

fault_end:
halted:
    hlt
    jmp halted


