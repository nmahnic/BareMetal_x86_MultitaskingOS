 ;------- 1er Pagina de la RAM (ISR = 0x0000 0000) ------
    ; Contenido de DTP
    mov eax, __TP                    ; Esta tabla está en __DTP + 0x3000 (tabla num 3)
    add eax, 0x1000*2                ; <- 3ra tabla de paginas
    add eax, 0x3                     ; ATTR de la TP
    ; Apunto al DTPE y le cargo su contenido
    mov dword [__DTP + 0x000*4], eax 
    ; Apunto a PTE y le cargo su contenido
    mov ebx, __TP + 0x1000*2 + 0x000*4
    mov eax, 0x00000003             ; Dir de la pagina + ATTR  
    mov [ebx], eax  

 ;------- 2da Pagina de la RAM (VIDEO = 0x000B 8000) ------
    ; Contenido de DTP
    mov eax, __TP                    ; Esta tabla está en __DTP + 0x3000 (tabla num 3)
    add eax, 0x1000*2                ; <- 3ra tabla de paginas
    add eax, 0x3                     ; ATTR de la TP
    ; Apunto al DTPE y le cargo su contenido
    mov dword [__DTP + 0x000*4], eax 
    ; Apunto a PTE y le cargo su contenido
    mov ebx, __TP + 0x1000*2 + 0x0B8*4
    mov eax, 0x000B8003             ; Dir de la pagina + ATTR  
    mov [ebx], eax     

 ;------- 3ra Pagina de la RAM (SYSTABLES = 0x0010 0000) ------
    ; Contenido de DTP
    mov eax, __TP                    ; Esta tabla está en __DTP + 0x3000 (tabla num 3)
    add eax, 0x1000*2                ; <- 3ra tabla de paginas
    add eax, 0x3                     ; ATTR de la TP
    ; Apunto al DTPE y le cargo su contenido
    mov dword [__DTP + 0x000*4], eax 
    ; Apunto a PTE y le cargo su contenido
    mov ebx, __TP + 0x1000*2 + 0x100*4
    mov eax, 0x00100003             ; Dir de la pagina + ATTR  
    mov [ebx], eax      

 ;------- 4ta a 7ma Pagina de la RAM (PAGETABLES = 0x0011 0000) ------
    ; Contenido de DTP
    mov eax, __TP                    ; Esta tabla está en __DTP + 0x3000 (tabla num 3)
    add eax, 0x1000*2                ; <- 3ra tabla de paginas
    add eax, 0x3                     ; ATTR de la TP
    ; Apunto al DTPE y le cargo su contenido
    mov dword [__DTP + 0x000*4], eax 
    ; Apunto a PTE y le cargo su contenido
    mov ebx, __TP + 0x1000*2 + 0x110*4
    mov eax, 0x00110003             ; Dir de la pagina + ATTR  
    mov esi, ebx                    ;Apuntar a la tabla C00
    mov ecx,0x5
ciclo1:
    mov [esi],eax                   ;Inicializar entrada del directorio.
    add esi,4                       ;Apuntar a la siguiente entrada.
    add eax,0x00001000              ;Calcular siguiente valor.
    loop ciclo1      

 ;------- 8va Pagina de la RAM (KENEL = 0x0020 0000) ------
    ; Contenido de DTP
    mov eax, __TP                    ; Esta tabla está en __DTP + 0x3000 (tabla num 3)
    add eax, 0x1000*2                ; <- 3ra tabla de paginas
    add eax, 0x3                     ; ATTR de la TP
    ; Apunto al DTPE y le cargo su contenido
    mov dword [__DTP + 0x000*4], eax 
    ; Apunto a PTE y le cargo su contenido
    mov ebx, __TP + 0x1000*2 + 0x200*4
    mov eax, 0x00200003             ; Dir de la pagina + ATTR  
    mov [ebx], eax    

 ;------- 9na Pagina de la RAM (DATOS = 0x0020 2000) ------
    ; Contenido de DTP
    mov eax, __TP                    ; Esta tabla está en __DTP + 0x3000 (tabla num 3)
    add eax, 0x1000*2                ; <- 3ra tabla de paginas
    add eax, 0x3                     ; ATTR de la TP
    ; Apunto al DTPE y le cargo su contenido
    mov dword [__DTP + 0x000*4], eax 
    ; Apunto a PTE y le cargo su contenido
    mov ebx, __TP + 0x1000*2 + 0x202*4
    mov eax, 0x00202003             ; Dir de la pagina + ATTR  
    mov [ebx], eax    

 ;------- 10ma Pagina de la RAM (Digitos = 0x0021 0000) ------
    ; Contenido de DTP
    mov eax, __TP                    ; Esta tabla está en __DTP + 0x3000 (tabla num 3)
    add eax, 0x1000*2                ; <- 3ra tabla de paginas
    add eax, 0x3                     ; ATTR de la TP
    ; Apunto al DTPE y le cargo su contenido
    mov dword [__DTP + 0x000*4], eax 
    ; Apunto a PTE y le cargo su contenido
    mov ebx, __TP + 0x1000*2 + 0x210*4
    mov eax, 0x00210003             ; Dir de la pagina + ATTR  
    mov [ebx], eax 

 ;------- 11va a 13va Tarea 1 (PAGETABLES = 0x0030 0000) ------
    ; Contenido de DTP
    mov eax, __TP                    ; Esta tabla está en __DTP + 0x3000 (tabla num 3)
    add eax, 0x1000*2                ; <- 3ra tabla de paginas
    add eax, 0x3                     ; ATTR de la TP
    ; Apunto al DTPE y le cargo su contenido
    mov dword [__DTP + 0x000*4], eax 
    ; Apunto a PTE y le cargo su contenido
    mov ebx, __TP + 0x1000*2 + 0x300*4
    mov eax, 0x00300003             ; Dir de la pagina + ATTR  
    mov esi, ebx                    ;Apuntar a la tabla C00
    mov ecx,0x4
ciclo2:
    mov [esi],eax                   ;Inicializar entrada del directorio.
    add esi,4                       ;Apuntar a la siguiente entrada.
    add eax,0x00001000              ;Calcular siguiente valor.
    loop ciclo2     








xchg bx,bx
        ; --> Desempaquetamiento de la ROM (ahora el Systable) <--
    push ebp
    mov ebp, esp    ;enter
    push __systable_size
    push __SYS_TABLE_VMA
    push __SYS_TABLE_LMA
    call __fast_memcopy
    leave
    cmp eax, 1      ;Analizo el valor de retorno (1 Exito / -1 Fallo)
    jne guard
xchg bx,bx




 ;------- Pagina de la RAM (Digitos = 0x0006 0000) ------
    ; Contenido de DTP
    mov eax, __TP                    ; Esta tabla está en __DTP + 0x3000 (tabla num 3)
    add eax, 0x1000*2                ; <- 3ra tabla de paginas
    add eax, 0x3                     ; ATTR de la TP
    ; Apunto al DTPE y le cargo su contenido
    mov dword [__DTP + 0x000*4], eax 
    ; Apunto a PTE y le cargo su contenido
    mov ebx, __TP + 0x1000*2 + 0x060*4
    mov eax, 0x00060003             ; Dir de la pagina + ATTR  
    mov [ebx], eax 

 ;------- Pagina de la RAM (Digitos = 0x0005 0000) ------
    ; Contenido de DTP
    mov eax, __TP                    ; Esta tabla está en __DTP + 0x3000 (tabla num 3)
    add eax, 0x1000*2                ; <- 3ra tabla de paginas
    add eax, 0x3                     ; ATTR de la TP
    ; Apunto al DTPE y le cargo su contenido
    mov dword [__DTP + 0x000*4], eax 
    ; Apunto a PTE y le cargo su contenido
    mov ebx, __TP + 0x1000*2 + 0x050*4
    mov eax, 0x00050003             ; Dir de la pagina + ATTR  
    mov [ebx], eax 

 ;------- Pagina de la RAM (Digitos = 0x0009 0000) ------
    ; Contenido de DTP
    mov eax, __TP                    ; Esta tabla está en __DTP + 0x3000 (tabla num 3)
    add eax, 0x1000*2                ; <- 3ra tabla de paginas
    add eax, 0x3                     ; ATTR de la TP
    ; Apunto al DTPE y le cargo su contenido
    mov dword [__DTP + 0x000*4], eax 
    ; Apunto a PTE y le cargo su contenido
    mov ebx, __TP + 0x1000*2 + 0x090*4
    mov eax, 0x00090003             ; Dir de la pagina + ATTR  
    mov [ebx], eax 














     ;------- 14va Pagina de la RAM (gdtr = 0x000F FD00) ------
    ; Contenido de DTP
    mov eax, __TP3                   ; Esta tabla está en __DTP + 0x3000 (tabla num 3)
    add eax, 0x3                     ; ATTR de la TP
    ; Apunto al DTPE y le cargo su contenido
    mov dword [__DTP + 0x000*4], eax 
    ; Apunto a PTE y le cargo su contenido
    mov ebx, __TP3 + 0x0FF*4
    mov eax, 0x000FFD00     ; Dir de la pagina + ATTR  
    or eax, 0x003
    mov [ebx], eax 