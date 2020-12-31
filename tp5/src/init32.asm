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

GLOBAL start32_launcher

start32_launcher:
    xchg bx,bx
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

    xchg bx,bx

    ; --> Desempaquetamiento de la ROM (primero las funciones) <--
    push ebp
    mov ebp, esp    ;enter
    push __functions_size
    push __FUNCTIONS_VMA
    push __FUNCTIONS_LMA
    call __fast_memcopy

    xchg bx,bx 

    leave
    cmp eax, 1      ;Analizo el valor de retorno (1 Exito / -1 Fallo)
    jne .guard

    xchg bx,bx

    ; --> Desempaquetamiento de la ROM (ahora el kernel) <--
    push ebp
    mov ebp, esp    ;enter
    push __codigo_kernel32_size
    push __KERNEL_32_VMA
    push __KERNEL_32_LMA
    call __fast_memcopy

    xchg bx,bx 

    leave
    cmp eax, 1      ;Analizo el valor de retorno (1 Exito / -1 Fallo)
    jne .guard

    xchg bx,bx
    jmp CS_SEL_32:kernel32_init

.guard:
    hlt