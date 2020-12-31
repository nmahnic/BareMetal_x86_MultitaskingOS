USE32
SECTION .handlers_32

%include "inc/processor-flags.h"

GLOBAL EXCEPTION_DE             ; Tipo 0
GLOBAL EXCEPTION_DB             ; Tipo 1
GLOBAL EXCEPTION_NMI            ; Tipo 2
GLOBAL EXCEPTION_BE             ; Tipo 3
GLOBAL EXCEPTION_OF             ; Tipo 4
GLOBAL EXCEPTION_BR             ; Tipo 5
GLOBAL EXCEPTION_UD             ; Tipo 6
GLOBAL EXCEPTION_NM             ; Tipo 7
GLOBAL EXCEPTION_DF             ; Tipo 8
GLOBAL EXCEPTION_CoS            ; Tipo 9
GLOBAL EXCEPTION_TS             ; Tipo 10
GLOBAL EXCEPTION_NP             ; Tipo 11
GLOBAL EXCEPTION_SS             ; Tipo 12
GLOBAL EXCEPTION_GP             ; Tipo 13
GLOBAL EXCEPTION_PF             ; Tipo 14
GLOBAL EXCEPTION_MF             ; Tipo 16
GLOBAL EXCEPTION_AC             ; Tipo 17
GLOBAL EXCEPTION_MC             ; Tipo 18
GLOBAL EXCEPTION_XM             ; Tipo 19
GLOBAL INTERRUPT_TIMER          ; Tipo 0x20
GLOBAL INTERRUPT_KeyBoard       ; Tipo 0x21
GLOBAL SYSTEM_CALL              ; Tipo 0x80

EXTERN offsetCB
EXTERN CircularBuffer
EXTERN offsetKB
EXTERN offsetKBT2
EXTERN timerFlag
EXTERN SumaFlagT1
EXTERN SumaFlagT2
EXTERN timer_ticks

EXTERN __VIDEO_lineal

EXTERN __guardarDigito
EXTERN __recorrerBuffer
EXTERN __KeyboardbyPolling
EXTERN __limpiarBuffer
EXTERN __cleanLine
EXTERN __crear_pag_din

EXTERN msgPF_len
EXTERN msgPF
EXTERN msgGP_len
EXTERN msgGP
EXTERN __DTPK
EXTERN __myprintfXY

EXTERN __TSS1_VMA
EXTERN __TSS2_VMA
EXTERN __TSS3_VMA
EXTERN __MMX1_VMA
EXTERN __MMX2_VMA

EXTERN status_SIMD

EXTERN __STACK_END_32
EXTERN __STACKT1_END_VMA
EXTERN __STACKT2_END_VMA
EXTERN __STACKT3_END_VMA

EXTERN tareaSum1
EXTERN tareaSum2
EXTERN tareaHLT
EXTERN CS_SEL_KER
EXTERN CS_SEL_USR
EXTERN DS_SEL_USR

EXTERN status_T1
EXTERN status_T2
EXTERN status_T3
EXTERN status_tarea

EXTERN __DTP_T1
EXTERN __DTP_T2
EXTERN __DTP_T3

EXTERN new_stack

EXTERN res_suma_T1
EXTERN ope_suma_T1
EXTERN VIDEO_T1

EXTERN res_suma_T2
EXTERN ope_suma_T2
EXTERN VIDEO_T2

PRINT   EQU 2
HALT    EQU 1
READ1   EQU 3
READ2   EQU 4

EXCEPTION_DE:                   ; Divide Error Exception
    mov eax, 0x00
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_DE
    iret

EXCEPTION_DB:                   ; Debug Exception
    mov eax, 0x01
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_DB
    iret

EXCEPTION_NMI:                  ; Non maskable interrupt
    mov eax, 0x02
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_NMI
    iret

EXCEPTION_BE:                   ; Breakpoint Exception
    mov eax, 0x03
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_BE
    iret

EXCEPTION_OF:                   ; Overflow Exception
    mov eax, 0x04
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_OF
    iret

EXCEPTION_BR:                   ; Bound Range Exception
    mov eax, 0x05
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_BR
    iret

EXCEPTION_UD:                   ; Invalid Opcode Exception
    mov eax, 0x06
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_UD
    iret

EXCEPTION_NM:                   ; Device Not Available Exception
    pushad
    mov eax, 0x07
    mov edx, eax 
;xchg bx,bx
    clts                                ; Limpia el CR0.TS

    mov ebx, [status_SIMD]              ; Quien fue el último que lo uso?
    mov eax, cr3                        ; Quien lo quiere usar ahora
    cmp eax, ebx                        ; Si el último uso y el actual es la misma tarea
    je no_guardo                        ; no guardo ni cargo MMX
    cmp eax,__DTP_T1                    ; Si el último uso y el actual son diferentes tareas guardo
    je SIMD_T1                          

 SIMD_T2:
    mov eax,cr3
    mov [status_SIMD], eax              ; Cargo uso actual Tarea2
    ; Guardo SIMD_T1
    mov eax, __MMX1_VMA
    movq [eax], mm0
    add eax,0x10
    movq [eax], mm1
    add eax,0x10
    movq [eax], mm2
    add eax,0x10
    movq [eax], mm3

    ; Cargo SIMD_T2
    mov eax, __MMX2_VMA
    movq mm0, [eax]
    add eax,0x10
    movq mm1, [eax]
    add eax,0x10
    movq mm2, [eax]
    add eax,0x10
    movq mm3, [eax]

    popad
    iret
 SIMD_T1:
    mov eax,cr3
    mov [status_SIMD], eax              ; Cargo uso actual Tarea1
    ; Guardo SIMD_T2
    mov eax, __MMX2_VMA
    movq [eax], mm0
    add eax,0x10
    movq [eax], mm1
    add eax,0x10
    movq [eax], mm2
    add eax,0x10
    movq [eax], mm3

    ; Cargo SIMD_T1
    mov eax, __MMX1_VMA
    movq mm0, [eax]
    add eax,0x10
    movq mm1, [eax]
    add eax,0x10
    movq mm2, [eax]
    add eax,0x10
    movq mm3, [eax]

    popad
    iret

no_guardo:
    popad
    iret

EXCEPTION_DF:                   ; Double Fault Exception
xchg bx,bx
    mov eax, 0x08
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_DF
    iret

EXCEPTION_CoS:                   ; Coprocessor Segment Overrun Exception
    mov eax, 0x09
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_CoS
    iret

EXCEPTION_TS:                   ; Invalid TSS Exception
    mov eax, 0x0A
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_TS
    iret

EXCEPTION_NP:                   ; No Present Segment Exception
    mov eax, 0x0B
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_NP
    iret

EXCEPTION_SS:                   ; Stack Fault Exception
xchg bx,bx
    mov eax, 0x0C
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_SS
    iret

EXCEPTION_GP:                   ; General Protection Fault Exception
;xchg bx,bx
    mov eax, 0x0D
    mov edx, eax

    push ebp
    mov ebp, esp    ;enter
    push 5
    push 5
    push msgGP_len
    push msgGP
    call __myprintfXY
    leave

    xchg bx,bx
    xchg bx,bx
    xchg bx,bx
    xchg bx,bx
    hlt
    jmp EXCEPTION_GP
    iret

EXCEPTION_PF:                   ; Page Fault Exception
;xchg bx,bx
    mov eax, 0x0E
    mov edx, eax
    ; Escribo en pantalla Fallo de página
    push ebp
    mov ebp, esp    ;enter
    push 5
    push 5
    push msgPF_len
    push msgPF
    call __myprintfXY
    leave
; TP13 pide deshabilitar la generación dinámica de páginas.
; Funciona si el fallo lo provaca el kernel, 
; las tareas solo realizan sumas no acceden a memoria dinamica.
    push ebp
    mov ebp, esp    ;enter
    mov eax,cr2
    push eax
    mov eax,cr3
    push eax
    call __crear_pag_din
    leave
xchg bx,bx
    ; Borro la linea de Fallo de Pagina de la pantalla
    push ebp
    mov ebp, esp    ;enter
    push 5
    push __VIDEO_lineal
    call __cleanLine
    leave
;xchg bx,bx
    pop eax
    iret

EXCEPTION_MF:                   ; FPU Floating Point Error Exception
    mov eax, 0x10
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_MF
    iret

EXCEPTION_AC:                   ; Aligment Check Exception
    mov eax, 0x11
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_AC
    iret

EXCEPTION_MC:                   ; Machine Check Exception
    mov eax, 0x12
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_MC
    iret

EXCEPTION_XM:                   ; SIMD Floating Point Exception
    mov eax, 0x13
    mov edx, eax
    xchg bx,bx
    hlt
    jmp EXCEPTION_XM
    iret

INTERRUPT_TIMER:
;xchg bx,bx
    push eax                    ; <- Guardo el estado de los reg de prop gral
    push ebx                    ;    Para luego  guardar los contextos
    push ecx                    ;    Esto se hace en la pila de Kernel
    push edx 
    push esi 
    push edi

    ;Setear el flag CR0.TS=1
    push eax
    smsw ax
    or ax, X86_CR0_TS
    lmsw ax
    pop eax

    mov eax,[timerFlag]
    cmp eax,0                   ; <- Es la primera vez que entra??
    ja save_context             ; Si es la primera vez sigue a first_entry sino a save_context

 first_entry:
;xchg bx,bx
    inc eax
    mov [timerFlag],eax         ; No volverá a entrar en first entry
    
    pop edi                     ; Popea porque no los va a guardar
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax

    mov eax, status_T3          ; Va a empezar ejecutando la Tarea3
    mov [status_tarea], eax
    
    mov eax, __TSS3_VMA
    mov ebx,__DTP_T3            ; Cargo TSS3 y DTP
    mov cr3,ebx

 load_context:                 
;xchg bx,bx
    mov ebx, [eax + 0]      ; <- Recupero EBX
    mov ecx, [eax + 4]      ; <- Recupero ECX
    mov edx, [eax + 16]     ; <- Recupero ESI
    mov esi, edx
    mov edx, [eax + 20]     ; <- Recupero EDI
    mov edi, edx
    mov edx, [eax + 24]     ; <- Recupero EBP
    mov ebp, edx
    mov edx, [eax + 32]     ; <- Recupero GS
    mov gs, edx    
    mov edx, [eax + 36]     ; <- Recupero FS
    mov fs, edx    
    mov edx, [eax + 44]     ; <- Recupero ES
    mov es, edx    
    mov edx, [eax + 48]     ; <- Recupero DS
    mov ds, edx 
;    -> Seteo el stack de kernel de la tarea a la cual voy a saltar
;    -> Cargo Stack Kernel
    mov edx, [eax + 60]     ; <- Recupero ESP0
    mov [new_stack], edx    
    mov edx, [eax + 64]     ; <- Recupero SS0
    mov [new_stack + 4], edx
    lss esp, [new_stack]
;    -> Cargo el stack correctamente para retornar del Scheduler
    mov edx, [eax + 40]      ; <- Recupero SS3   RPL = 3
    push edx
    mov edx, [eax + 28]      ; <- Recupero ESP3
    push edx
    mov edx, [eax + 72]     ; <- Recupero EFLAGS
    push edx
    mov edx, [eax + 56]     ; <- Recupero CS3   RPL = 3
    push edx
    mov edx, [eax + 68]     ; <- Recupero EIP
    push edx

    mov edx, [eax + 8]      ; <- Recupero EDX
    mov eax, [eax + 12]     ; <- Recupero EAX
    
    push eax
    push ebx
    mov al,0x20             ;envio end of interrupt al PIC
    out 0x20, al
;xchg bx,bx
    mov eax,[timer_ticks]       ; <- Primera entrada es 0
    inc eax
    cmp eax, 21
    jne no_limpio_timertick
    mov eax,1
 no_limpio_timertick:
    mov [timer_ticks], eax      ; <- Se incrementa y se guarda

    mov eax, [status_tarea] ; Va a revisar cual está en ejecución
    mov ebx, IDLE           ; status_T1, status_T2 o status_T3
    mov [eax],ebx           ; A alguna de las 3 le pondrá IDLE
    pop ebx
    pop eax
;xchg bx,bx
    iret                    ; Va a recuperar la tarea en su estado de ejecución

save_context:
    mov eax, [status_tarea]               ; Revisa que tarea se ejecutó ultima
;xchg bx,bx
    cmp eax, status_T1                    
    je TASK1_s
    cmp eax, status_T2
    je TASK2_s
    cmp eax, status_T3
    je TASK3_s

 TASK1_s:
    mov eax, __TSS1_VMA
    jmp salvo
 TASK2_s:
    mov eax, __TSS2_VMA
    jmp salvo
 TASK3_s:
    mov eax, __TSS3_VMA
 salvo:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    
    mov [eax + 0], ebx           ; <- Guardo ebx
    mov [eax + 4], ecx           ; <- Guardo ecx
    mov [eax + 8], edx           ; <- Guardo edx
    pop ebx
    mov [eax + 12], ebx          ; <- Guardo eax
    mov [eax + 16], esi          ; <- Guardo esi
    mov [eax + 20], edi          ; <- Guardo edi
    mov [eax + 24], ebp          ; <- Guardo ebp
    mov ebx, esp
    mov [eax + 28], ebx          ; <- Guardo ESP3

    mov ebx, cr3    
    mov [eax + 52], ebx          ; <- Guardo cr3

    mov ebx,[esp+4]
    mov [eax + 56], ebx          ; <- Guardo cs

    mov ebx,[esp]
    mov [eax + 68], ebx          ; <- Guardo eip

    mov ebx,[esp+8]
    mov [eax + 72], ebx          ; <- Guardo eflags

checkear:
;xchg bx,bx
    mov ebx,__DTPK              ; Cambio de CR3
    mov cr3,ebx                 ; Para ver todas las variables

    mov eax,[timer_ticks]       ; <- Primera entrada es 0
    cmp eax,1
    je preg_status_1
    cmp eax,2
    je preg_status_2
    cmp eax,10
    je preg_status_1
    jmp TASK3

 preg_status_1:
    mov ebx,[status_T1]         ; Si Task1 está en WAITING es porque tiene recursos
    cmp ebx,WAITING             ; timerticks era 1 ya que WAITING tambien vale 1 y RUNNING_T1 vale 3
    je TASK1
    jmp TASK3
 preg_status_2:
    mov ebx,[status_T2]         ; Si Task1 está en WAITING es porque tiene recursos
    cmp ebx,WAITING             ; timerticks era 2 ya que WAITING vale 1 y RUNNING_T2 vale 3    
    je TASK2                    
                                ; <- Sino hace la Task3
TASK3:                          ; Si no hay ninguna ejecuto la TASK3 SIEMPRE ESTÁ READY
    mov eax, status_T3
    mov [status_tarea],eax
    mov eax, __TSS3_VMA
    mov ebx,__DTP_T3            ; Cambio de CR3
    mov cr3,ebx
    jmp load_context
                  
TASK1:
    mov eax, status_T1
    mov [status_tarea],eax
    mov eax, __TSS1_VMA
    mov ebx,__DTP_T1            ; Cambio de CR3
    mov cr3,ebx
    jmp load_context
TASK2:
    mov eax, status_T2
    mov [status_tarea],eax
    mov eax, __TSS2_VMA
    mov ebx,__DTP_T2            ; Cambio de CR3
    mov cr3,ebx
    jmp load_context

INTERRUPT_KeyBoard:
; Revisa que la tecla no sea ENTER, si lo es termina.
; Guarda la tecla presionada en un buffer circular.
; Si ingresa por una tecla soltada, no hace nada y termina.
;xchg bx,bx
    pushad                  ;salvo los registros de uso general
    mov edx, cr3            ;Guardo CR3 de tarea N
    mov ebx,__DTPK          ;Cambio de CR3 de Kernel
    mov cr3,ebx
    mov eax, esp
    mov esp, __STACK_END_32
    push edx                ; CR3 de tareaN
    push eax                ; Stack de TareaN

    mov eax, 0x21           ; Guardo el tipo de interrupción
    mov edx, eax

    in al,0x60              ;leer tecla del buffer de teclado
    mov ebx,eax             ; Muevo el caracter a ebx

    cmp ax,(0x1C)               ; Si la tecla es ENTER
    je guardar                  ; Salta a guardar todo en memoria

    and al,al
    js fin_int20             ;termina si se suelta la tecla
;xchg bx,bx
    push ebp
    mov ebp, esp    ;enter
    push offsetCB
    push CircularBuffer         ; destino
    push eax                    ; caracter
    call __recorrerBuffer
    mov [offsetCB],eax                 ; guardo el destino siguiente
    leave
    xor eax,eax                 ; Limpio eax

 fin_int20:
;xchg bx,bx
    mov al,0x20             ;envio end of interrupt al PIC
    out 0x20,al
    
    pop eax
    pop edx
    mov esp, eax
    mov cr3, edx
    popad
    iret

 guardar:
;xchg bx,bx
    mov eax, WAITING
    mov [status_T1],eax
    mov [status_T2],eax

    mov eax, 0
    mov [SumaFlagT1],eax
    mov [SumaFlagT2],eax
    

    push ebp
    mov ebp, esp    ;enter
    push __KeyboardbyPolling+40 ; memoria  de destino 
                                ;(el +20 es porque en las posiciones +0,+4,+8,+12,+16 estan ocupadas por datos de visualización)
                                ; de +4 a +16 están los digitos BCD de la suma de digitos
                                ; en +0 está el resultado suma propiamente dicha
    push CircularBuffer         ; Lista Circular
;xchg bx,bx
    mov eax, [offsetKB]
    sar eax, 2 
    push eax                    ; guarda el offser de __KeyboardbyPolling
    push offsetCB
    call __guardarDigito
    ;xchg bx,bx
    cmp eax,0x1000               
    jb rstoffsetKB              ; Si ya llené 4K vuelvo empezar
    mov eax,0
 rstoffsetKB:    
;xchg bx,bx
    sal eax, 2                  ; Incrementa un qWord multiplicando 4*4
    mov [offsetKB],eax          ; guardo el destino siguiente
    mov [offsetKBT2],eax        ; guardo el destino siguiente
    leave

    push ebp
    mov ebp, esp    ;enter
    push CircularBuffer
    call __limpiarBuffer
    leave
    xor eax,eax                 ; Limpio eax
;xchg bx,bx

    jmp fin_int20

SYSTEM_CALL:
;xchg bx,bx
    push ebp
    mov ebp, esp    ;enter
;    mov eax, [ebp+16]
    cmp eax, HALT
    je halteo_tarea
    cmp eax, PRINT
    je imprimo_buffer
    cmp eax, READ1
    je leo_T1
    cmp eax, READ2
    je leo_T2
    
halteo_tarea:
    sti
    hlt
    leave
iret

imprimo_buffer:
    mov esi, [ebx]     ; A partir de donde escribir
    mov eax, edx     ; Buffer a imprimir
 T1_2:
    mov ebx, [eax]
    sar ebx,0x4
    and ebx,0x0000000F
    cmp bl,0xA
    jb T1_a
    add bl,0x7
 T1_a:
    add bl,0x30
    mov [esi], bl                   ; Escribo caracter en pantalla
    mov BYTE [esi+1],0x07           ; Escribo atributo en pantalla
    add esi,2                       ; Incremento el puntero

    mov ebx, [eax]
    and ebx,0x0000000F
    cmp bl,0xA
    jb T1_b
    add bl,0x7
 T1_b:
    add bl,0x30
    mov [esi], bl                   ; Escribo caracter en pantalla
    mov BYTE [esi+1],0x07           ; Escribo atributo en pantalla
    add esi,4                       ; Incremento el puntero

    inc eax
    loop T1_2

    leave
iret

leo_T1:
;xchg bx,bx   
    mov ecx, [offsetKB]                   ; guarda el offser de __KeyboardbyPolling
    sub ecx, 0x10
    mov eax, __KeyboardbyPolling+40     ; memoria  de origen
    add eax,ecx
    mov ebx, ope_suma_T1
    mov ecx, [eax]
    mov [ebx], ecx
    add eax,4
    add ebx,4
    mov ecx, [eax]
    mov [ebx], ecx
        
    mov eax, __VIDEO_lineal+((80*2)*7)+34
    mov ebx, VIDEO_T1
    mov [ebx], eax
    leave
iret

leo_T2:
;xchg bx,bx   
    mov ecx, [offsetKBT2]               ; guarda el offser de __KeyboardbyPolling
    sub ecx, 0x10
    mov eax, __KeyboardbyPolling+40     ; memoria  de origen
    add eax,ecx
    mov ebx, ope_suma_T2
    mov ecx, [eax]
    mov [ebx], ecx
    add eax,4
    add ebx,4
    mov ecx, [eax]
    mov [ebx], ecx

    mov eax, __VIDEO_lineal+((80*2)*8)+34
    mov ebx, VIDEO_T2
    mov [ebx], eax
    leave
iret