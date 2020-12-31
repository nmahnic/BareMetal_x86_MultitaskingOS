USE32
SECTION .start32

%include "inc/processor-flags.h"

EXTERN __STACK_END_32
EXTERN __STACK_START_32
EXTERN __STACK_SIZE_32

EXTERN __STACKTX_KERNEL_END_VMA

EXTERN __STACKT1_KERNEL_START_phy 
       
EXTERN __STACKT1_START_phy
EXTERN __STACKT1_END_phy
EXTERN __STACKT1_SIZE
EXTERN __STACKT1_END_VMA

EXTERN __STACKT2_KERNEL_START_phy 

EXTERN __STACKT2_START_phy
EXTERN __STACKT2_END_phy
EXTERN __STACKT2_SIZE
EXTERN __STACKT2_END_VMA

EXTERN __STACKT3_KERNEL_START_phy

EXTERN __STACKT3_START_phy
EXTERN __STACKT3_END_phy
EXTERN __STACKT3_SIZE
EXTERN __STACKT3_END_VMA

EXTERN DS_SEL_KER
EXTERN CS_SEL_KER

EXTERN kernel32_init
EXTERN __VIDEO

EXTERN msgPag
EXTERN msgPag_len

EXTERN __fast_memcopy
EXTERN __myprintfXY
EXTERN __init_myTSS

EXTERN __KeysPhy

EXTERN __SysTable
EXTERN __SYS_TABLE_LMA
EXTERN __systable_size

EXTERN __codigo_kernel32_size
EXTERN __Kernel_phy
EXTERN __KERNEL_32_LMA

EXTERN __ISR_size
EXTERN __ISR_LMA
EXTERN __ISR_VMA

EXTERN __TEXT1_phy
EXTERN __TEXT1_LMA
EXTERN __TEXT1_size

EXTERN __BSST1_phy

EXTERN __dataT1_size
EXTERN __DATAT1_phy
EXTERN __DATAT1_LMA

EXTERN __TEXT2_phy
EXTERN __TEXT2_LMA
EXTERN __TEXT2_size

EXTERN __BSST2_phy

EXTERN __dataT2_size
EXTERN __DATAT2_phy
EXTERN __DATAT2_LMA

EXTERN __TEXT3_phy
EXTERN __TEXT3_LMA
EXTERN __TEXT3_size

EXTERN __BSST3_phy

EXTERN __data_size
EXTERN __DATA_phy
EXTERN __DATA_LMA

EXTERN __BSS_phy

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
EXTERN INTERRUPT_TIMER        ; Tipo 0x20
EXTERN INTERRUPT_KeyBoard     ; Tipo 0x21
EXTERN SYSTEM_CALL            ; Tipo 0x80

EXTERN _gdtrVMA

EXTERN tareaSum1
EXTERN tareaSum2
EXTERN tareaHLT

EXTERN __TSS1_VMA
EXTERN __TSS2_VMA
EXTERN __TSS3_VMA

EXTERN __set_idt_entry
EXTERN __set_idt_entry_asm
EXTERN __IDT
EXTERN idtr

EXTERN __DTPK                  ; Directorios de Tablas de Pagina
EXTERN __TSS_BASICA
EXTERN TSS_SEL

ATTR_EXC_KER EQU 0x0000008F
ATTR_INT_KER EQU 0x0000008E
ATTR_INT_USR EQU 0x000000EE

__TP1    EQU __DTPK + 0x1000        ; 64K de ROM
__TP2    EQU __DTPK + 0x2000        ; Pila de Sistema
__TP3    EQU __DTPK + 0x3000        ; Primeros 4M de la RAM
__TP4    EQU __DTPK + 0x4000        ; El 5to 4M de la RAM 
__TP5    EQU __DTPK + 0x5000        ;
__CR3_KERNEL EQU __DTPK

EXTERN __DTP_T1
__TP2_T1    EQU __DTP_T1 + 0x2000
__TP3_T1    EQU __DTP_T1 + 0x3000
__TP4_T1    EQU __DTP_T1 + 0x4000
__TP5_T1    EQU __DTP_T1 + 0x1000
__TP6_T1    EQU __DTP_T1 + 0x5000
__CR3_T1    EQU __DTP_T1            ; 0x0130 3000

EXTERN __DTP_T2
__TP2_T2    EQU __DTP_T2 + 0x2000
__TP3_T2    EQU __DTP_T2 + 0x3000
__TP4_T2    EQU __DTP_T2 + 0x4000
__TP5_T2    EQU __DTP_T2 + 0x1000
__TP6_T2    EQU __DTP_T2 + 0x5000
__CR3_T2    EQU __DTP_T2            ; 0x0131 3000

EXTERN __DTP_T3
__TP2_T3    EQU __DTP_T3 + 0x2000
__TP3_T3    EQU __DTP_T3 + 0x3000
__TP4_T3    EQU __DTP_T3 + 0x4000
__TP5_T3    EQU __DTP_T3 + 0x1000
__TP6_T3    EQU __DTP_T3 + 0x5000
__CR3_T3    EQU __DTP_T3            ; 0x0132 3000

SS_SEL_KER  EQU DS_SEL_KER
ES_SEL_KER  EQU DS_SEL_KER
FS_SEL_KER  EQU DS_SEL_KER
GS_SEL_KER  EQU DS_SEL_KER

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
    mov ax, DS_SEL_KER
    mov ds, ax
    mov es, ax
    mov gs, ax
    mov fs, ax

 ;----------------------------------------------------------------------------------------
 ;                                 Inicializo Pila del Kernel
 ;----------------------------------------------------------------------------------------
    ; --> Inicializar la pila <--
;xchg bx,bx
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
 ;                                  Inicializo perisfericos
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

    push ebp
    mov ebp,esp
    call Keyboard_Init       ; No le paso parametros. (La uso desde ROM)
    leave

 ;----------------------------------------------------------------------------------------
 ;                                      Memcopeo codigo
 ;----------------------------------------------------------------------------------------
;xchg bx,bx 
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

    ; --> Desempaquetamiento de la ROM (ahora el kernel) <--
    push ebp
    mov ebp, esp    ;enter
    push __codigo_kernel32_size
    push __Kernel_phy
    push __KERNEL_32_LMA
    call __fast_memcopy
    leave
   cmp eax, 1      ;Analizo el valor de retorno (1 Exito / -1 Fallo)
    jne guard

   ; --> Desempaquetamiento de la ROM (ahora el kernel) <--
    push ebp
    mov ebp, esp    ;enter
    push __data_size
    push __DATA_phy
    push __DATA_LMA
    call __fast_memcopy
    leave
    cmp eax, 1      ;Analizo el valor de retorno (1 Exito / -1 Fallo)
    jne guard

        ; --> Desempaquetamiento de la ROM (ahora el kernel) <--
    push ebp
    mov ebp, esp    ;enter
    push __systable_size
    push __SysTable
    push __SYS_TABLE_LMA
    call __fast_memcopy
    leave
    cmp eax, 1      ;Analizo el valor de retorno (1 Exito / -1 Fallo)
    jne guard

    ; --> Desempaquetamiento de la ROM (ahora el kernel) <--
    push ebp
    mov ebp, esp    ;enter
    push __TEXT1_size
    push __TEXT1_phy
    push __TEXT1_LMA
    call __fast_memcopy
    leave
    cmp eax, 1      ;Analizo el valor de retorno (1 Exito / -1 Fallo)
    jne guard

    ; --> Desempaquetamiento de la ROM (ahora el kernel) <--
    push ebp
    mov ebp, esp    ;enter
    push __dataT1_size
    push __DATAT1_phy
    push __DATAT1_LMA
    call __fast_memcopy
    leave
    cmp eax, 1      ;Analizo el valor de retorno (1 Exito / -1 Fallo)
    jne guard

    ; --> Desempaquetamiento de la ROM (ahora el kernel) <--
    push ebp
    mov ebp, esp    ;enter
    push __TEXT2_size
    push __TEXT2_phy
    push __TEXT2_LMA
    call __fast_memcopy
    leave
    cmp eax, 1      ;Analizo el valor de retorno (1 Exito / -1 Fallo)
    jne guard

    ; --> Desempaquetamiento de la ROM (ahora el kernel) <--
    push ebp
    mov ebp, esp    ;enter
    push __dataT2_size
    push __DATAT2_phy
    push __DATAT2_LMA
    call __fast_memcopy
    leave
    cmp eax, 1      ;Analizo el valor de retorno (1 Exito / -1 Fallo)
    jne guard

    ; --> Desempaquetamiento de la ROM (ahora el kernel) <--
    push ebp
    mov ebp, esp    ;enter
    push __TEXT3_size
    push __TEXT3_phy
    push __TEXT3_LMA
    call __fast_memcopy
    leave
    cmp eax, 1      ;Analizo el valor de retorno (1 Exito / -1 Fallo)
    jne guard

 ;----------------------------------------------------------------------------------------
 ;                                        Paginación
 ;----------------------------------------------------------------------------------------
;xchg bx,bx
    mov edi, __DTPK
    mov ecx, 6*0x400             ; Limpio 16K (6 paginas) que usaré
    xor eax,eax                  ; 1 para DTP y 5 para TPs
    rep stosd                    

 ;------- 16 Paginas de 4K = 64K de ROM (ROM = 0xFFFF 0000) ------
    mov eax, __TP1                           ; Esta es la 1er tabla, está en __DTPK + 0x1000 (tabla num 1)
    or eax, PAG_RW_R_US_SUP                  ; ATTR del DTE
    mov dword [__DTPK + 0xFFC], eax          ;Apuntar a tabla de pags al finl del espacio direccionable.
    xor eax, eax
    mov eax, __TP1 + 0xFC0
    mov esi, eax                             ;Apuntar a la tabla C00
    mov ecx,0x10
    mov eax, 0xFFFF0000                      ; Dir de la pagina
    or  eax, PAG_RW_R_US_SUP                 ; ATTR de la PTE <- ROM
 ciclo:
    mov [esi],eax                            ;Inicializar entrada del directorio.
    add esi,4                                ;Apuntar a la siguiente entrada.
    add eax,0x00001000                       ;Calcular siguiente valor.
    loop ciclo

 ;------- Pagina de la Pila (Stack = 0x 1FF0 8000 identity mapping)------
    ; Contenido de DTP
    mov eax, __TP2                           ; Esta tabla está en __DTPK + 0x2000 (tabla num 2)
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la DTE
    ; Apunto al DPE y le cargo su contenido
    mov dword [__DTPK + 0x07F*4], eax        ; DTP entry (offset 0x07F)
    ; Apunto a PTE y le cargo su contenido
    mov ebx, __TP2 + 0x308*4                 ; TP entry (offset 0x308)
    mov eax, __STACK_START_32                ; Dir de la pagina
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la PTE  
    mov [ebx], eax  

 ;------- Pagina de la Pila NT1 (Stack = 0x 1FF0 7000 identity mapping)------
    ; Contenido de DTP
    mov eax, __TP2                           ; Esta tabla está en __DTPK + 0x2000 (tabla num 2)
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la DTE
    ; Apunto al DPE y le cargo su contenido
    mov dword [__DTPK + 0x07F*4], eax        ; DTP entry (offset 0x07F)
    ; Apunto a PTE y le cargo su contenido
    mov ebx, __TP2 + 0x307*4                 ; TP entry (offset 0x308)
    mov eax, __STACKT1_KERNEL_START_phy      ; Dir de la pagina
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la PTE  
    mov [ebx], eax  

 ;------- Pagina de la Pila NT2 (Stack = 0x 1FF0 6000 identity mapping)------
    ; Contenido de DTP
    mov eax, __TP2                           ; Esta tabla está en __DTPK + 0x2000 (tabla num 2)
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la DTE
    ; Apunto al DPE y le cargo su contenido
    mov dword [__DTPK + 0x07F*4], eax        ; DTP entry (offset 0x07F)
    ; Apunto a PTE y le cargo su contenido
    mov ebx, __TP2 + 0x306*4                 ; TP entry (offset 0x308)
    mov eax, __STACKT2_KERNEL_START_phy      ; Dir de la pagina
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la PTE  
    mov [ebx], eax  

 ;------- Pagina de la Pila NT3 (Stack = 0x 1FF0 5000 identity mapping)------
    ; Contenido de DTP
    mov eax, __TP2                           ; Esta tabla está en __DTPK + 0x2000 (tabla num 2)
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la DTE
    ; Apunto al DPE y le cargo su contenido
    mov dword [__DTPK + 0x07F*4], eax        ; DTP entry (offset 0x07F)
    ; Apunto a PTE y le cargo su contenido
    mov ebx, __TP2 + 0x305*4                 ; TP entry (offset 0x308)
    mov eax, __STACKT3_KERNEL_START_phy      ; Dir de la pagina
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la PTE  
    mov [ebx], eax  

 ;------- Pagina de la Pila T1 (Stack = 0x 1FFF F000 identity mapping)------
    mov eax, __TP2                           ; Esta tabla está en __DTPK + 0x2000 (tabla num 2)
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la DTE
    mov dword [__DTPK + 0x07F*4], eax        ; DTP entry (offset 0x07F)
    mov ebx, __TP2 + 0x3FF*4                 ; TP entry (offset 0x3FF)
    mov eax, __STACKT1_START_phy             ; Dir de la pagina
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la PTE  
    mov [ebx], eax     

 ;------- Pagina de la Pila T2 (Stack = 0x 1FFF E000 identity mapping)------
    mov eax, __TP2                           ; Esta tabla está en __DTPK + 0x2000 (tabla num 2)
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la DTE
    mov dword [__DTPK + 0x07F*4], eax        ; DTP entry (offset 0x07F)
    mov ebx, __TP2 + 0x3FE*4                 ; TP entry (offset 0x3FE)
    mov eax, __STACKT2_START_phy             ; Dir de la pagina
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la PTE  
    mov [ebx], eax 

 ;------- Pagina de la Pila T3 (Stack = 0x 1FFF D000 identity mapping)------
    mov eax, __TP2                           ; Esta tabla está en __DTPK + 0x2000 (tabla num 2)
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la DTE
    mov dword [__DTPK + 0x07F*4], eax        ; DTP entry (offset 0x07F)
    mov ebx, __TP2 + 0x3FD*4                 ; TP entry (offset 0x3FD)
    mov eax, __STACKT3_START_phy             ; Dir de la pagina
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la PTE  
    mov [ebx], eax     

 ;------- 1er Pagina de la RAM (ISR = 0x0000 0000 identity mapping) ------
    mov eax, __TP3                           ; Esta tabla está en __DTPK + 0x3000 (tabla num 3)
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la DTE
    mov dword [__DTPK + 0x000*4], eax        ; DTP entry (offset 0x000)
    mov ebx, __TP3 + 0x000*4                 ; TP entry (offset 0x000)
    mov eax, __ISR_VMA                       ; Dir de la pagina
    or eax, PAG_RW_R_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax  

 ;------- Pagina de la RAM (VIDEO_lineal = 0x0001 0000 -> VIDEO = 0x000B 8000) ------
    mov eax, __TP3                           ; Esta tabla está en __DTPK + 0x3000 (tabla num 3)
    or eax, PAG_RW_W_US_SUP                  ; ATTR del DTE
    mov dword [__DTPK + 0x000*4], eax        ; DTP entry (offset 0x000)
    mov ebx, __TP3 + 0x010*4                 ; TP entry (offset 0x010)
    mov eax, __VIDEO                         ; Dir de la pagina  
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax     

 ;------- Pagina de la RAM (SYSTABLES = 0x0010 0000 identity mapping) ------
    mov eax, __TP3                           ; Esta tabla está en __DTPK + 0x3000 (tabla num 3)
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la DTE
    mov dword [__DTPK + 0x000*4], eax        ; DTP entry (offset 0x000)
    mov ebx, __TP3 + 0x100*4                 ; TP entry (offset 0x100)
    mov eax, __SysTable                      ; Dir de la pagina  
    or eax, PAG_RW_R_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax      

 ;------- Paginas de la RAM (PAGETABLES = 0x0011 0000 identity mapping) ------
    mov eax, __TP3                           ; Esta tabla está en __DTPK + 0x3000 (tabla num 3)
    add eax, PAG_RW_W_US_SUP                 ; ATTR de la DTE
    mov dword [__DTPK + 0x000*4], eax        ; DTP entry (offset 0x000)
    mov ebx, __TP3 + 0x110*4                 ; TP entry (offset 0x110)
    mov eax, __DTPK                          ; Dir de la pagina  
    or eax, PAG_RW_R_US_SUP                  ; ATTR de la PTE
    mov esi, ebx                  
    mov ecx,0x6                              ; un DTP + 5 tablas
 ciclo1:
    mov [esi],eax                            ;Inicializar entrada del directorio.
    add esi,4                                ;Apuntar a la siguiente entrada.
    add eax,0x1000                           ;Calcular siguiente valor.
    loop ciclo1      

 ;------- Pagina de la RAM (KENEL_lineas = 0x0120 0000 -> KERNEL = 0x0020 0000) ------
    mov eax, __TP4                           ; Esta tabla está en __DTPK + 0x4000 (tabla num 4)
    add eax, PAG_RW_W_US_SUP                 ; ATTR de la DTE
    mov dword [__DTPK + 0x004*4], eax        ; DTP entry (offset 0x004)
    mov ebx, __TP4 + 0x200*4                 ; TP entry (offset 0x200)
    mov eax, __Kernel_phy                    ; Dir de la pagina  
    or eax, PAG_RW_R_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax     

 ;------- Pagina de la RAM (Datos_lineal = 0x0120 2000 -> DATOS = 0x0020 2000) ------
    mov eax, __TP4                           ; Esta tabla está en __DTPK + 0x4000 (tabla num 4)
    add eax,   PAG_RW_W_US_SUP               ; ATTR de la DTE
    mov dword [__DTPK + 0x004*4], eax        ; DTP entry (offset 0x004)
    mov ebx, __TP4 + 0x202*4                 ; TP entry (offset 0x202)
    mov eax, __DATA_phy                      ; Dir de la pagina 
    or eax, PAG_RW_W_US_SUP                  ; ATTP de la PTE
    mov [ebx], eax    

 ;------- Pagina de la RAM (BSS gral = 0x0120 3000) ------
    mov eax, __TP4                           ; Esta tabla está en __DTPK + 0x4000 (tabla num 4)
    add eax, PAG_RW_W_US_SUP                 ; ATTR de la DTE
    mov dword [__DTPK + 0x004*4], eax        ; DTP entry (offset 0x004)
    mov ebx, __TP4 + 0x203*4                 ; TP entry (offset 0x203)
    mov eax, __BSS_phy                       ; Dir de la pagina  
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax    

 ;------- Pagina de la RAM (Dig_lineal = 0x0121 0000 -> Digitos = 0x0021 0000) ------
    mov eax, __TP4                           ; Esta tabla está en __DTPK + 0x4000 (tabla num 4)
    add eax, PAG_RW_W_US_SUP                 ; ATTR de la DTE
    mov dword [__DTPK + 0x004*4], eax        ; DTP entry (offset 0x004)
    mov ebx, __TP4 + 0x210*4                 ; TP entry (offset 0x210)
    mov eax, __KeysPhy                       ; Dir de la pagina  
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax 

 ;------- Tarea 1 (Tarea1_lineal = 0x0130 0000 -> Tarea1 = 0x0030 0000) ------
    mov eax, __TP4                           ; Esta tabla está en __DTPK + 0x4000 (tabla num 4)
    add eax, PAG_RW_W_US_SUP                 ; ATTR de la DTE
    mov dword [__DTPK + 0x004*4], eax        ; DTP entry (offset 0x004)
    mov ebx, __TP4 + 0x300*4                 ; TP entry (offset 0x300)
    mov eax, __TEXT1_phy                     ; Dir de la pagina  
    or eax, PAG_RW_R_US_SUP
    mov [ebx], eax
 ;------- Tarea 1 BSS (BSS1_lineal = 0x0130 1000 -> BSS1 = 0x0030 1000) ------
    mov eax, __TP4                           ; Esta tabla está en __DTPK + 0x4000 (tabla num 4)
    add eax, PAG_RW_W_US_SUP                 ; ATTR de la DTE
    mov dword [__DTPK + 0x004*4], eax        ; DTP entry (offset 0x004)
    mov ebx, __TP4 + 0x301*4                 ; TP entry (offset 0x301)
    mov eax, __BSST1_phy                     ; Dir de la pagina  
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax
  ;------- Tarea 1 DATOS (DATA1_lineal = 0x0130 2000 -> DATOS1 = 0x0030 2000) ------
    mov eax, __TP4                           ; Esta tabla está en __DTPK + 0x4000 (tabla num 4)
    add eax, PAG_RW_W_US_SUP                 ; ATTR de la DTE
    mov dword [__DTPK + 0x004*4], eax        ; DTP entry (offset 0x004)
    mov ebx, __TP4 + 0x302*4                 ; TP entry (offset 0x302)
    mov eax, __DATAT1_phy                    ; Dir de la pagina  
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax

 ;------- Tarea 2 (Tarea2_lineal = 0x0131 0000 -> Tarea2 = 0x0031 0000) ------
    mov eax, __TP4                           ; Esta tabla está en __DTPK + 0x4000 (tabla num 4)
    add eax, PAG_RW_W_US_SUP                 ; ATTR de la DTE
    mov dword [__DTPK + 0x004*4], eax        ; DTP entry (offset 0x004)
    mov ebx, __TP4 + 0x310*4                 ; TP entry (offset 0x310)
    mov eax, __TEXT2_phy                     ; Dir de la pagina
    or eax, PAG_RW_R_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax  
 ;------- Tarea 2 BSS (BSS2_lineal = 0x0131 1000 -> BSS2 = 0x0031 1000) ------
    mov eax, __TP4                           ; Esta tabla está en __DTPK + 0x4000 (tabla num 4)
    add eax, PAG_RW_W_US_SUP                 ; ATTR de la DTE
    mov dword [__DTPK + 0x004*4], eax        ; DTP entry (offset 0x004)
    mov ebx, __TP4 + 0x311*4                 ; TP entry (offset 0x311)
    mov eax, __BSST2_phy                     ; Dir de la pagina  
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax
  ;------- Tarea 2 DATOS (DATA2_lineal = 0x0131 2000 -> DATOS2 = 0x0031 2000) ------
    mov eax, __TP4                           ; Esta tabla está en __DTPK + 0x4000 (tabla num 4)
    add eax, PAG_RW_W_US_SUP                 ; ATTR de la DTE
    mov dword [__DTPK + 0x004*4], eax        ; DTP entry (offset 0x004)
    mov ebx, __TP4 + 0x312*4                 ; TP entry (offset 0x312)
    mov eax, __DATAT2_phy                    ; Dir de la pagina  
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax

 ;------- Tarea 3 (Tarea3_lineal = 0x0132 0000 -> Tarea3 = 0x0032 0000) ------
    mov eax, __TP4                           ; Esta tabla está en __DTPK + 0x4000 (tabla num 4)
    add eax, PAG_RW_W_US_SUP                 ; ATTR de la DTE
    mov dword [__DTPK + 0x004*4], eax        ; DTP entry (offset 0x004)
    mov ebx, __TP4 + 0x320*4                 ; TP entry (offset 0x320)
    mov eax, __TEXT3_phy                     ; Dir de la pagina  
    or eax, PAG_RW_R_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax   
 ;------- Tarea 3 BSS (BSS3_lineal = 0x0132 1000 -> BSS3 = 0x0032 1000) ------
    mov eax, __TP4                           ; Esta tabla está en __DTPK + 0x4000 (tabla num 4)
    add eax, PAG_RW_W_US_SUP                 ; ATTR de la DTE
    mov dword [__DTPK + 0x004*4], eax        ; DTP entry (offset 0x004)
    mov ebx, __TP4 + 0x321*4                 ; TP entry (offset 0x321)
    mov eax, __BSST3_phy                     ; Dir de la pagina  
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax

 ;------- Pagina de la TSS (TSS_lineal = 0x0140 0000 identity mapping) ------
    mov eax, __TP5                           ; Esta tabla está en __DTPK + 0x5000 (tabla num 5)
    add eax, PAG_RW_W_US_SUP                 ; ATTR de la DTE
    mov dword [__DTPK + 0x005*4], eax        ; DTP entry (offset 0x005)
    mov ebx, __TP5 + 0x000*4                 ; TP entry (offset 0x000)
    mov eax, __TSS_BASICA                    ; Dir de la pagina 
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax 

 ; =================================Paginas para DTP_T1 ======================================
    ;------- Tarea 1 (Tarea1_lineal = 0x0130 0000 -> Tarea1 = 0x0030 0000) ------
    mov eax, __TP4_T1                        ; Esta tabla está en __DTP_T1 + 0x4000 (tabla num 4)
    add eax, PAG_RW_W_US_USR                 ; ATTR de la DTE
    mov dword [__DTP_T1 + 0x004*4], eax      ; DTP entry (offset 0x004)
    mov ebx, __TP4_T1 + 0x300*4              ; TP entry (offset 0x300)
    mov eax, __TEXT1_phy                     ; Dir de la pagina + ATTR  
    or eax, PAG_RW_R_US_USR                  ; ATTR de la PTE
    mov [ebx], eax
    ;------- BSS 1 (BSS1_lineal = 0x0130 1000 -> BSS1 = 0x0030 1000) ------
    mov eax, __TP4_T1                        ; Esta tabla está en __DTP_T1 + 0x4000 (tabla num 4)
    add eax, PAG_RW_W_US_USR                 ; ATTR de la DTE
    mov dword [__DTP_T1 + 0x004*4], eax      ; DTP entry (offset 0x004)
    mov ebx, __TP4_T1 + 0x301*4              ; TP entry (offset 0x301)
    mov eax, __BSST1_phy                     ; Dir de la pagina + ATTR  
    or eax, PAG_RW_W_US_USR                  ; ATTR de la PTE
    mov [ebx], eax
    ;------- DATOS 1 (DATO1_lineal = 0x0130 2000 -> DATO1 = 0x0030 2000) ------
    mov eax, __TP4_T1                        ; Esta tabla está en __DTP_T1 + 0x4000 (tabla num 4)
    add eax, PAG_RW_W_US_USR                 ; ATTR de la DTE
    mov dword [__DTP_T1 + 0x004*4], eax      ; DTP entry (offset 0x004)
    mov ebx, __TP4_T1 + 0x302*4              ; TP entry (offset 0x302)
    mov eax, __DATAT1_phy                    ; Dir de la pagina + ATTR  
    or eax, PAG_RW_W_US_USR                  ; ATTR de la PTE
    mov [ebx], eax

    ;------- Pagina de la RAM (BSS_lineas = 0x0120 3000 -> BSS = 0x0020 3000) ------
    mov eax, __TP4_T1                        ; Esta tabla está en __DTP_T1 + 0x4000 (tabla num 4)
    add eax, PAG_RW_W_US_USR                 ; ATTR de la DTE
    mov dword [__DTP_T1 + 0x004*4], eax      ; DTP entry (offset 0x004)
    mov ebx, __TP4_T1 + 0x203*4              ; TP entry (offset 0x203)
    mov eax, __BSS_phy                       ; Dir de la pagina 
    or eax, PAG_RW_R_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax

    ;------- Pagina de la RAM (Dig_lineal = 0x0121 0000 -> Digitos = 0x0021 0000) ------
    mov eax, __TP4_T1                        ; Esta tabla está en __DTP_T1 + 0x4000 (tabla num 4)
    add eax, PAG_RW_W_US_USR                 ; ATTR de la DTE
    mov dword [__DTP_T1 + 0x004*4], eax      ; DTP entry (offset 0x004)
    mov ebx, __TP4_T1 + 0x210*4              ; TP entry (offset 0x210)
    mov eax, __KeysPhy                       ; Dir de la pagina
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax

    ;------- Pagina de la RAM (ISR = 0x0000 0000 identity mapping) ------
    mov eax, __TP3_T1                        ; Esta tabla está en __DTP_T1 + 0x3000 (tabla num 3)
    or eax, PAG_RW_W_US_USR                  ; ATTR de la DTE
    mov dword [__DTP_T1 + 0x000*4], eax      ; DTP entry (offset 0x000)
    mov ebx, __TP3_T1 + 0x000*4              ; TP entry (offset 0x000)
    mov eax, __ISR_VMA                       ; Dir de la pagina
    or eax, PAG_RW_R_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax   

    ;------- Pagina de la RAM (VIDEO_lineal = 0x0001 0000 -> VIDEO = 0x000B 8000) ------
    mov eax, __TP3_T1                        ; Esta tabla está en __DTP_T1 + 0x3000 (tabla num 3)
    or eax, PAG_RW_W_US_USR                  ; ATTR del DTE
    mov dword [__DTP_T1 + 0x000*4], eax      ; DTP entry (offset 0x000)
    mov ebx, __TP3_T1 + 0x010*4              ; TP entry (offset 0x010)
    mov eax, __VIDEO                         ; Dir de la pagina
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax   

    ;------- Pagina de la RAM (SYSTABLES = 0x0010 0000 identity mapping) ------
    mov eax, __TP3_T1                        ; Esta tabla está en __DTP_T1 + 0x3000 (tabla num 3)
    or eax, PAG_RW_W_US_USR                  ; ATTR de la DPE
    mov dword [__DTP_T1 + 0x000*4], eax      ; DTP entry (offset 0x000)
    mov ebx, __TP3_T1 + 0x100*4              ; TP entry (offset 0x100)
    mov eax, __SysTable                      ; Dir de la pagina 
    or eax, PAG_RW_R_US_USR                  ; ATTR de la PTE
    mov [ebx], eax 

    ;------- Pagina de la TSS (TSS_lineal = 0x0140 0000 identity mapping) ------
    mov eax, __TP5_T1                        ; Esta tabla está en __DTP_T1 + 0x5000 (tabla num 5)
    add eax, PAG_RW_W_US_USR                 ; ATTR de la DTE
    mov dword [__DTP_T1 + 0x005*4], eax      ; DTP entry (offset 0x005)
    mov ebx, __TP5_T1 + 0x000*4              ; TP entry (offset 0x000)
    mov eax, __TSS_BASICA                    ; Dir de la pagina
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax 

    ;------- Pagina de la Pila T1 (Stack_T1_lineal = 0x0071 3000 -> 0x 1FFF F000)------
    mov eax, __TP2_T1                        ; Esta tabla está en __DTP_T1 + 0x2000 (tabla num 2)
    or eax, PAG_RW_W_US_USR                  ; ATTR de la DTE
    mov dword [__DTP_T1 + 0x001*4], eax      ; DTP entry (offset 0x001)
    mov ebx, __TP2_T1 + 0x313*4              ; TP entry (offset 0x313)
    mov eax, __STACKT1_START_phy             ; Dir de la pagina
    or eax, PAG_RW_W_US_USR                  ; ATTR de la PTE
    mov [ebx], eax 

 ;------- Pagina de la Pila NT1 (Stack_T1_lineal = 0x0071 4000 -> 0x 1FFF 7000)------
    ; Contenido de DTP
    mov eax, __TP2_T1                        ; Esta tabla está en __DTPK + 0x2000 (tabla num 2)
    or eax, PAG_RW_W_US_USR                  ; ATTR de la DTE
    mov dword [__DTP_T1 + 0x001*4], eax      ; DTP entry (offset 0x001)
    mov ebx, __TP2_T1 + 0x314*4              ; TP entry (offset 0x313)
    mov eax, __STACKT1_KERNEL_START_phy      ; Dir de la pagina
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la PTE  
    mov [ebx], eax

    ;------- Pagina de la Pila Kernel (Stack = 0x 1FF0 8000 identity mapping)------
    mov eax, __TP6_T1                        ; Esta tabla está en __DTP_T1 + 0x2000 (tabla num 2)
    or eax, PAG_RW_W_US_USR                  ; ATTR de la DTE
    mov dword [__DTP_T1 + 0x07F*4], eax      ; DTP entry (offset 0x001)
    mov ebx, __TP6_T1 + 0x308*4              ; TP entry (offset 0x313)
    mov eax, __STACK_START_32                ; Dir de la pagina
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax 

 ; =================================Paginas para DTP_T2 ======================================
    ;------- Tarea 2 (Tarea2_lineal = 0x0131 0000 -> Tarea1 = 0x0031 0000) ------
    mov eax, __TP4_T2                        ; Esta tabla está en __DTP_T2 + 0x4000 (tabla num 4)
    add eax, PAG_RW_W_US_USR                 ; ATTR de la DTE
    mov dword [__DTP_T2 + 0x004*4], eax      ; DTP entry (offset 0x004)
    mov ebx, __TP4_T2 + 0x310*4              ; TP entry (offset 0x310)
    mov eax, __TEXT2_phy                     ; Dir de la pagina + ATTR  
    or eax, PAG_RW_R_US_USR                  ; ATTR de la PTE
    mov [ebx], eax
    ;------- BSS 2 (BSS2_lineal = 0x0131 1000 -> BSS1 = 0x0031 1000) ------
    mov eax, __TP4_T2                        ; Esta tabla está en __DTP_T2 + 0x4000 (tabla num 4)
    add eax, PAG_RW_W_US_USR                 ; ATTR de la DTE
    mov dword [__DTP_T2 + 0x004*4], eax      ; DTP entry (offset 0x004)
    mov ebx, __TP4_T2 + 0x311*4              ; TP entry (offset 0x311)
    mov eax, __BSST2_phy                     ; Dir de la pagina + ATTR  
    or eax, PAG_RW_W_US_USR                  ; ATTR de la PTE
    mov [ebx], eax
    ;------- DATOS 2 (DATO2_lineal = 0x0131 2000 -> DATO1 = 0x0031 2000) ------
    mov eax, __TP4_T2                        ; Esta tabla está en __DTP_T2 + 0x4000 (tabla num 4)
    add eax, PAG_RW_W_US_USR                 ; ATTR de la DTE
    mov dword [__DTP_T2 + 0x004*4], eax      ; DTP entry (offset 0x004)
    mov ebx, __TP4_T2 + 0x312*4              ; TP entry (offset 0x312)
    mov eax, __DATAT2_phy                    ; Dir de la pagina + ATTR  
    or eax, PAG_RW_W_US_USR                  ; ATTR de la PTE
    mov [ebx], eax 

    ;------- Pagina de la RAM (BSS_lineas = 0x0120 3000 -> BSS = 0x0020 3000) ------
    mov eax, __TP4_T2                        ; Esta tabla está en __DTP_T2 + 0x4000 (tabla num 4)
    add eax, PAG_RW_W_US_USR                 ; ATTR de la DTE
    mov dword [__DTP_T2 + 0x004*4], eax      ; DTP entry (offset 0x004)
    mov ebx, __TP4_T2 + 0x203*4              ; TP entry (offset 0x203)
    mov eax, __BSS_phy                       ; Dir de la pagina 
    or eax, PAG_RW_R_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax 

    ;------- Pagina de la RAM (Dig_lineal = 0x0121 0000 -> Digitos = 0x0021 0000) ------
    mov eax, __TP4_T2                        ; Esta tabla está en __DTP_T2 + 0x4000 (tabla num 4)
    add eax, PAG_RW_W_US_USR                 ; ATTR de la DTE
    mov dword [__DTP_T2 + 0x004*4], eax      ; DTP entry (offset 0x004)
    mov ebx, __TP4_T2 + 0x210*4              ; TP entry (offset 0x210)
    mov eax, __KeysPhy                       ; Dir de la pagina
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax

    ;------- Pagina de la RAM (ISR = 0x0000 0000 identity mapping) ------
    mov eax, __TP3_T2                        ; Esta tabla está en __DTP_T2 + 0x3000 (tabla num 3)
    or eax, PAG_RW_W_US_USR                  ; ATTR de la DTE
    mov dword [__DTP_T2 + 0x000*4], eax      ; DTP entry (offset 0x000)
    mov ebx, __TP3_T2 + 0x000*4              ; TP entry (offset 0x000)
    mov eax, __ISR_VMA                       ; Dir de la pagina
    or eax, PAG_RW_R_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax 

    ;------- Pagina de la RAM (VIDEO_lineal = 0x0001 0000 -> VIDEO = 0x000B 8000) ------
    mov eax, __TP3_T2                        ; Esta tabla está en __DTP_T2 + 0x3000 (tabla num 3)
    or eax, PAG_RW_W_US_USR                  ; ATTR del DTE
    mov dword [__DTP_T2 + 0x000*4], eax      ; DTP entry (offset 0x000)
    mov ebx, __TP3_T2 + 0x010*4              ; TP entry (offset 0x010)
    mov eax, __VIDEO                         ; Dir de la pagina
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax 

    ;------- Pagina de la RAM (SYSTABLES = 0x0010 0000 identity mapping) ------
    mov eax, __TP3_T2                        ; Esta tabla está en __DTP_T2 + 0x3000 (tabla num 3)
    or eax, PAG_RW_W_US_USR                  ; ATTR de la DPE
    mov dword [__DTP_T2 + 0x000*4], eax      ; DTP entry (offset 0x000)
    mov ebx, __TP3_T2 + 0x100*4              ; TP entry (offset 0x100)
    mov eax, __SysTable                      ; Dir de la pagina 
    or eax, PAG_RW_R_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax 

    ;------- Pagina de la TSS (TSS_lineal = 0x0140 0000 identity mapping) ------
    mov eax, __TP5_T2                        ; Esta tabla está en __DTP_T2 + 0x5000 (tabla num 5)
    add eax, PAG_RW_W_US_USR                 ; ATTR de la DTE
    mov dword [__DTP_T2 + 0x005*4], eax      ; DTP entry (offset 0x005)
    mov ebx, __TP5_T2 + 0x000*4              ; TP entry (offset 0x000)
    mov eax, __TSS_BASICA                    ; Dir de la pagina
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax 

    ;------- Pagina de la Pila T2 (Stack_T2_lineal = 0x0071 3000 -> 0x 1FFF E000)------
    mov eax, __TP2_T2                        ; Esta tabla está en __DTP_T2 + 0x2000 (tabla num 2)
    or eax, PAG_RW_W_US_USR                  ; ATTR de la DTE
    mov dword [__DTP_T2 + 0x001*4], eax      ; DTP entry (offset 0x001)
    mov ebx, __TP2_T2 + 0x313*4              ; TP entry (offset 0x313)
    mov eax, __STACKT2_START_phy             ; Dir de la pagina
    or eax, PAG_RW_W_US_USR                  ; ATTR de la PTE
    mov [ebx], eax 

 ;------- Pagina de la Pila NT2 (Stack_T2_lineal = 0x0071 4000 -> 0x 1FFF 6000)------
    ; Contenido de DTP
    mov eax, __TP2_T2                        ; Esta tabla está en __DTP_T2 + 0x2000 (tabla num 2)
    or eax, PAG_RW_W_US_USR                  ; ATTR de la DTE
    mov dword [__DTP_T2 + 0x001*4], eax      ; DTP entry (offset 0x001)
    mov ebx, __TP2_T2 + 0x314*4              ; TP entry (offset 0x313)
    mov eax, __STACKT2_KERNEL_START_phy      ; Dir de la pagina
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la PTE  
    mov [ebx], eax

    ;------- Pagina de la Pila Kernel (Stack = 0x 1FF0 8000 identity mapping)------
    mov eax, __TP6_T2                        ; Esta tabla está en __DTP_T2 + 0x2000 (tabla num 2)
    or eax, PAG_RW_W_US_USR                  ; ATTR de la DTE
    mov dword [__DTP_T2 + 0x07F*4], eax      ; DTP entry (offset 0x001)
    mov ebx, __TP6_T2 + 0x308*4              ; TP entry (offset 0x313)
    mov eax, __STACK_START_32                ; Dir de la pagina
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax 

 ; =================================Paginas para DTP_T3 ======================================
    ;------- Tarea 3 (Tarea3_lineal = 0x0132 0000 -> Tarea3 = 0x0032 0000) ------
    mov eax, __TP4_T3                        ; Esta tabla está en __DTP_T3 + 0x4000 (tabla num 4)
    add eax, PAG_RW_W_US_USR                 ; ATTR de la DTE
    mov dword [__DTP_T3 + 0x004*4], eax      ; DTP entry (offset 0x004)
    mov ebx, __TP4_T3 + 0x320*4              ; TP entry (offset 0x310)
    mov eax, __TEXT3_phy                     ; Dir de la pagina + ATTR  
    or eax, PAG_RW_R_US_USR                  ; ATTR de la PTE
    mov [ebx], eax
    ;------- BSS 3 (BSS3_lineal = 0x0132 1000 -> BSS3 = 0x0032 1000) ------
    mov eax, __TP4_T3                        ; Esta tabla está en __DTP_T3 + 0x4000 (tabla num 4)
    add eax, PAG_RW_W_US_USR                 ; ATTR de la DTE
    mov dword [__DTP_T3 + 0x004*4], eax      ; DTP entry (offset 0x004)
    mov ebx, __TP4_T3 + 0x321*4              ; TP entry (offset 0x311)
    mov eax, __BSST3_phy                     ; Dir de la pagina + ATTR  
    or eax, PAG_RW_W_US_USR                  ; ATTR de la PTE
    mov [ebx], eax
    ;------- Pagina de la RAM (BSS_lineas = 0x0120 3000 -> BSS = 0x0020 3000) ------
    mov eax, __TP4_T3                        ; Esta tabla está en __DTP_T2 + 0x4000 (tabla num 4)
    add eax, PAG_RW_W_US_USR                 ; ATTR de la DTE
    mov dword [__DTP_T3 + 0x004*4], eax      ; DTP entry (offset 0x004)
    mov ebx, __TP4_T3 + 0x203*4              ; TP entry (offset 0x203)
    mov eax, __BSS_phy                       ; Dir de la pagina 
    or eax, PAG_RW_R_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax

    ;------- Pagina de la RAM (ISR = 0x0000 0000 identity mapping) ------
    mov eax, __TP3_T3                        ; Esta tabla está en __DTP_T3 + 0x3000 (tabla num 3)
    or eax, PAG_RW_W_US_USR                  ; ATTR de la DTE
    mov dword [__DTP_T3 + 0x000*4], eax      ; DTP entry (offset 0x000)
    mov ebx, __TP3_T3 + 0x000*4              ; TP entry (offset 0x000)
    mov eax, __ISR_VMA                       ; Dir de la pagina
    or eax, PAG_RW_R_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax   

    ;------- Pagina de la RAM (SYSTABLES = 0x0010 0000 identity mapping) ------
    mov eax, __TP3_T3                        ; Esta tabla está en __DTP_T3 + 0x3000 (tabla num 3)
    or eax, PAG_RW_W_US_USR                  ; ATTR de la DPE
    mov dword [__DTP_T3 + 0x000*4], eax      ; DTP entry (offset 0x000)
    mov ebx, __TP3_T3 + 0x100*4              ; TP entry (offset 0x100)
    mov eax, __SysTable                      ; Dir de la pagina 
    or eax, PAG_RW_R_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax

    ;------- Pagina de la TSS (TSS_lineal = 0x0140 0000 identity mapping) ------
    mov eax, __TP5_T3                        ; Esta tabla está en __DTP_T3 + 0x5000 (tabla num 5)
    add eax, PAG_RW_W_US_USR                 ; ATTR de la DTE
    mov dword [__DTP_T3 + 0x005*4], eax      ; DTP entry (offset 0x005)
    mov ebx, __TP5_T3 + 0x000*4              ; TP entry (offset 0x000)
    mov eax, __TSS_BASICA                    ; Dir de la pagina
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax 

    ;------- Pagina de la Pila T3 (Stack_T3_lineal = 0x0071 3000 -> 0x 1FFF D000)------
    mov eax, __TP2_T3                        ; Esta tabla está en __DTP_T3 + 0x2000 (tabla num 2)
    or eax, PAG_RW_W_US_USR                  ; ATTR de la DTE
    mov dword [__DTP_T3 + 0x001*4], eax      ; DTP entry (offset 0x001)
    mov ebx, __TP2_T3 + 0x313*4              ; TP entry (offset 0x313)
    mov eax, __STACKT3_START_phy             ; Dir de la pagina
    or eax, PAG_RW_W_US_USR                  ; ATTR de la PTE
    mov [ebx], eax 

 ;------- Pagina de la Pila NT3 (Stack_T3_lineal = 0x0071 4000 -> 0x 1FFF 5000)------
    ; Contenido de DTP
    mov eax, __TP2_T3                        ; Esta tabla está en __DTPK + 0x2000 (tabla num 2)
    or eax, PAG_RW_W_US_USR                  ; ATTR de la DTE
    mov dword [__DTP_T3 + 0x001*4], eax      ; DTP entry (offset 0x001)
    mov ebx, __TP2_T3 + 0x314*4              ; TP entry (offset 0x313)
    mov eax, __STACKT3_KERNEL_START_phy      ; Dir de la pagina
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la PTE  
    mov [ebx], eax

    ;------- Pagina de la Pila Kernel (Stack = 0x 1FF0 8000 identity mapping)------
    mov eax, __TP6_T3                        ; Esta tabla está en __DTP_T3 + 0x2000 (tabla num 2)
    or eax, PAG_RW_W_US_USR                  ; ATTR de la DTE
    mov dword [__DTP_T3 + 0x07F*4], eax      ; DTP entry (offset 0x001)
    mov ebx, __TP6_T3 + 0x308*4              ; TP entry (offset 0x313)
    mov eax, __STACK_START_32                ; Dir de la pagina
    or eax, PAG_RW_W_US_SUP                  ; ATTR de la PTE
    mov [ebx], eax 

 ;===============================> Activo Paginación <======================================
    mov eax,__CR3_KERNEL       ; <- __CR3_KERNEL == __DTPK
    mov cr3,eax                ;Apuntar a directorio de paginas.
    mov eax,cr0                ;Activar paginacion encendiendo el
    or eax,0x80000000          ;bit 31 de CR0.
    mov cr0,eax
;xchg bx,bx

    lgdt [_gdtrVMA]           ; está en data.asm que fue memcopiada a RAM

   ; Imprime texto en pantalla
    push ebp
    mov ebp, esp    ;enter
    push 0
    push 2
    push msgPag_len
    push msgPag
    call __myprintfXY
    leave
;xchg bx,bx
 ;----------------------------------------------------------------------------------------
 ;                           Cargo Excepciones e Interrupciones
 ;----------------------------------------------------------------------------------------
 ; --> Cargar la IDT con Divide Error Exception #DE (TIPO 0) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC_KER)        ; Atributos
    push dword(EXCEPTION_DE)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_KER)          ; Segmento de la función que atiende la excepción
    push dword(0x00)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con Debug #DB (TIPO 1) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC_KER)        ; Atributos
    push dword(EXCEPTION_DB)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_KER)          ; Segmento de la función que atiende la excepción
    push dword(0x01)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con ? #NMI (TIPO 2) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC_KER)        ; Atributos
    push dword(EXCEPTION_NMI)       ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_KER)          ; Segmento de la función que atiende la excepción
    push dword(0x02)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con ? #BE (TIPO 3) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC_KER)        ; Atributos
    push dword(EXCEPTION_BE)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_KER)          ; Segmento de la función que atiende la excepción
    push dword(0x03)                ; Numero de excepción
    call __set_idt_entry
    leave
 
 ; --> Cargar la IDT con ? #OF (TIPO 4) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC_KER)        ; Atributos
    push dword(EXCEPTION_OF)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_KER)          ; Segmento de la función que atiende la excepción
    push dword(0x04)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con Rango de instrucción BOUND excedido #BR (TIPO 5) <--
    push ebp
    mov ebp, esp    ;enter

    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC_KER)        ; Atributos
    push dword(EXCEPTION_BR)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_KER)          ; Segmento de la función que atiende la excepción
    push dword(0x05)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con Invalid Opcode #UD (TIPO 6) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC_KER)        ; Atributos
    push dword(EXCEPTION_UD)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_KER)          ; Segmento de la función que atiende la excepción
    push dword(0x06)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con Device not found #NM (TIPO 7) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC_KER)        ; Atributos
    push dword(EXCEPTION_NM)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_KER)          ; Segmento de la función que atiende la excepción
    push dword(0x07)                ; Numero de excepción
    call __set_idt_entry
    leave

  ; --> Cargar la IDT con Double Fault Exception #DF (TIPO 8) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC_KER)        ; Atributos
    push dword(EXCEPTION_DF)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_KER)          ; Segmento de la función que atiende la excepción
    push dword(0x08)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con Divide Error Exception #DB (TIPO 9) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC_KER)        ; Atributos
    push dword(EXCEPTION_CoS)       ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_KER)          ; Segmento de la función que atiende la excepción
    push dword(0x09)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con TSS invalido #TS (TIPO 10) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC_KER)        ; Atributos
    push dword(EXCEPTION_TS)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_KER)          ; Segmento de la función que atiende la excepción
    push dword(0x0A)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con Segmento no presente #NP (TIPO 11) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC_KER)        ; Atributos
    push dword(EXCEPTION_NP)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_KER)          ; Segmento de la función que atiende la excepción
    push dword(0x0B)                ; Numero de excepción
    call __set_idt_entry
    leave
 
 ; --> Cargar la IDT con Stack Fault Exception #SS (TIPO 12) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC_KER)        ; Atributos
    push dword(EXCEPTION_SS)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_KER)          ; Segmento de la función que atiende la excepción
    push dword(0x0C)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con General Protection Exception #GP (TIPO 13) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC_KER)        ; Atributos
    push dword(EXCEPTION_GP)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_KER)          ; Segmento de la función que atiende la excepción
    push dword(0x0D)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con Page Fault Exception #PF (TIPO 14) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC_KER)        ; Atributos
    push dword(EXCEPTION_PF)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_KER)          ; Segmento de la función que atiende la excepción
    push dword(0x0E)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con Error matemarico x87 #MF (TIPO 16) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC_KER)        ; Atributos
    push dword(EXCEPTION_MF)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_KER)          ; Segmento de la función que atiende la excepción
    push dword(0x10)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con Error de alineación #AC (TIPO 17) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC_KER)        ; Atributos
    push dword(EXCEPTION_AC)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_KER)          ; Segmento de la función que atiende la excepción
    push dword(0x11)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con ? #MC (TIPO 18) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC_KER)        ; Atributos
    push dword(EXCEPTION_MC)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_KER)          ; Segmento de la función que atiende la excepción
    push dword(0x12)                ; Numero de excepción
    call __set_idt_entry
    leave

 ; --> Cargar la IDT con Exception float SIMD #XM (TIPO 19) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_EXC_KER)        ; Atributos
    push dword(EXCEPTION_XM)        ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_KER)          ; Segmento de la función que atiende la excepción
    push dword(0x13)                ; Numero de excepción
    call __set_idt_entry
    leave

 ;==================================== INTERRUPCIONES ======================================
  ; --> Cargar la IDT con TIMER (TIPO 0x20) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_INT_KER)        ; Atributos
    push dword(INTERRUPT_TIMER)     ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_KER)          ; Segmento de la función que atiende la excepción
    push dword(0x20)                ; Numero de excepción
    call __set_idt_entry_asm
    leave

 ; --> Cargar la IDT con Teclado (TIPO 0x21) <--
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_INT_KER)        ; Atributos, DPL=0
    push dword(INTERRUPT_KeyBoard)  ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_KER)          ; Segmento de la función que atiende la excepción
    push dword(0x21)                ; Numero de excepción
    call __set_idt_entry_asm
    leave

 ; --> Cargar la IDT con SYSTEM_CALL (TIPO 0x80) <--
;xchg bx,bx
    push ebp
    mov ebp, esp    ;enter
    push dword(__IDT)               ; Dirección de la IDT
    push dword(ATTR_INT_USR)        ; Atributos, DPL=3 (quien puede hacer este INT 0x80)
    push dword(SYSTEM_CALL)         ; Offset de la función que atiende la excepción (dirección)
    push dword(CS_SEL_KER)          ; Segmento de la función que atiende la excepción
    push dword(0x80)                ; Numero de excepción
    call __set_idt_entry_asm
    leave

    lidt [idtr]


 ;----------------------------------------------------------------------------------------
 ;                                 Inicializo TSS del Kernel
 ;----------------------------------------------------------------------------------------
   push ebp
   mov ebp, esp
   mov eax, __TSS1_VMA
   mov ebx, __CR3_T1
   mov ecx, __STACKT1_END_VMA
   mov edx, __STACK_END_32
   mov esi, tareaSum1
   call __init_myTSS
   leave

   push ebp
   mov ebp, esp
   mov eax, __TSS2_VMA
   mov ebx, __CR3_T2
   mov ecx, __STACKT2_END_VMA
   mov edx, __STACK_END_32
   mov esi, tareaSum2
   call __init_myTSS
   leave

   push ebp
   mov ebp, esp
   mov eax, __TSS3_VMA
   mov ebx, __CR3_T3
   mov ecx, __STACKT3_END_VMA
   mov edx, __STACK_END_32
   mov esi, tareaHLT
   call __init_myTSS
   leave

    mov eax, __TSS_BASICA
    mov [eax + 4], dword(__STACKTX_KERNEL_END_VMA)  ;<- ESP0 stack de nivel 0
    mov [eax + 8], dword(SS_SEL_KER)      ;<- SS0
    mov [eax + 12], dword(0x0)            ;<- ESP1
    mov [eax + 16], dword(0x0)            ;<- SS1
    mov [eax + 20], dword(0x0)            ;<- ESP2
    mov [eax + 24], dword(0x0)            ;<- SS2
    mov [eax + 28] ,dword(__CR3_KERNEL)   ;<- CR3
    mov [eax + 31], dword(kernel32_init)  ;<- EIP
    mov [eax + 36], dword(0x0202)         ;<- EFLAGS
    mov [eax + 40], dword(0x0)            ;<- EAX
    mov [eax + 44], dword(0x0)            ;<- ECX
    mov [eax + 48], dword(0x0)            ;<- EDX
    mov [eax + 52], dword(0x0)            ;<- EBX
    mov [eax + 56], dword(0x0)            ;<- ESP
    mov [eax + 60], dword(0x0)            ;<- EBP 
    mov [eax + 64], dword(0x0)            ;<- ESI
    mov [eax + 72], dword(ES_SEL_KER)     ;<- ES
    mov [eax + 76], dword(CS_SEL_KER)     ;<- CS
    mov [eax + 80], dword(SS_SEL_KER)     ;<- SS
    mov [eax + 84], dword(DS_SEL_KER)     ;<- DS
    mov [eax + 88], dword(FS_SEL_KER)     ;<- FS
    mov [eax + 92], dword(GS_SEL_KER)     ;<- GS 
    mov [eax + 96], dword(0x0)            ;<- LDT Segment Selector
    mov [eax + 100], dword(0x0)           ;<- Reserved

   ; Cargo el TR con el selector de TSS
    xor eax,eax
    mov ax, TSS_SEL
    ltr ax



;xchg bx,bx
    jmp CS_SEL_KER:kernel32_init


 ;-------------------------------------------------------------------------------------------
 ;                             Inicializa controlador de teclado
 ;-------------------------------------------------------------------------------------------
 Keyboard_Init:
    mov al,0xFF
    out 0x64, al            ;Enviar comando de reset al controlador de teclado
    mov ecx, 256            ; Espera que rearranque el controlador
    loop $
    mov ecx,0x10000
 ciclo5:
    in al, 0x60             ;espera que termine el reset del controlador
    test al,1
    loopz ciclo5
    mov al, 0xF4            ;habilita teclado
    out 0x64, al
    mov ecx, 0x10000
 ciclo6:
    in al,0x60              ;espera que termime el comando
    test al,1
    loopz ciclo6
    in al,0x60              ;Vaciar el buffer de teclado

    ret
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

  ;sti    ; hay que habilitar las interrupciones.

  ret

;-------------------------------------------------------------------------------------------
;                                   Inicializo el Timer
;-------------------------------------------------------------------------------------------
TIMER_init:
  ;Inicializar timer para que interrumpa cada 10ms
   mov al, 00110100b       ; Channel 0, Access mode: lobyte/hibyte, Mode 2 (rate generator)-
   out 0x43, al
   mov ax, 11932            ; 10ms (1.1932 MHz * 10ms = 11932)
                           ;Dividir 1193181hz por 65536. Eso da 18,2Hz aprox -> 54.9ms
                           ;es lo máximo que se puede dividir.
                    
   out 0x40,al             ;programa byte bajo del timer de 16 bits
   mov al,ah
   out 0x40,al             ;programa alto del timer de 16 bits
   ret