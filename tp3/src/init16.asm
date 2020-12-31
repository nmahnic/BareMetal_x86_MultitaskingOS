BITS 16
GLOBAL Init16
EXTERN Init32

SEL_1raUBICACION EQU 0x000
SEL_2daUBICACION EQU 0xF00          ;Esta es el SELECTOR que se multiplica por 16

RADICANDO EQU 0x300
RAIZ      EQU 0x304

SECTION .Init16
Init16:
;1ra Copia del Programa Principal
    mov ax,SEL_1raUBICACION   
    mov es,ax                       ;ES tiene dir base en SEL_PROG_PRINCIPAL

    mov si,inicio_prog_principal    ;Puntero origen
    mov di,0                        ;Puntero destino

    mov cx,fin_prog_principal - inicio_prog_principal
    rep cs movsb                    ;Efectual copia
    ;copia lo apuntado por SI en lo apuntado por DI
    ;se incrementan los indices SI, DI y decrementa cx
    ;esto se hace hasta que cx vale 0 ya que en este se guardaba
    ;el largo del programa a copiar.
    ;el CS en el medio indica el Segmento origne (el codigo del programa)

;2da Copia del Programa Principal
    mov ax,SEL_2daUBICACION   
    mov es,ax                       ;ES tiene dir base en SEL_PROG_PRINCIPAL

    mov si,inicio_prog_principal    ;Puntero origen
    mov di,0                        ;Puntero destino

    mov cx,fin_prog_principal - inicio_prog_principal
    rep cs movsb                    ;Efectual copia

    jmp SEL_1raUBICACION:0        ;Aca hacemos un salto FAR
    ;Desde ROM a RAM

inicio_prog_principal:
    mov ax,0
    mov ss,ax
    mov ds,ax
    mov sp,0x8000
    
    mov eax,76              ;Cargo valor a calcular Raiz
    mov [RADICANDO],eax     ;Guarda el valor en la posición de mem asociada a RADICANDO
    
    call raiz_cuadrada

colgarse:
    jmp colgarse
    jmp Init32

raiz_cuadrada:              ;Inicializacion de la SubRutina
    mov eax,[RADICANDO]
    xor ecx,ecx
    inc ecx
    mov dx,0

    xchg bx,bx              ;MAGIC BREAKPOINT
ciclo_raiz:
    sub eax,ecx
    jc raiz_hallada         ;Salta si eax es negativo
    add ecx,2
    inc dx
    jmp ciclo_raiz
raiz_hallada:
    xchg bx,bx              ;MAGIC BREAKPOINT
    mov [RAIZ],dx
    ret

fin_prog_principal: