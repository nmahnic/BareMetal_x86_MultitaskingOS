    xor eax, eax
    mov eax, __TP + 0xC00
    mov esi, eax               ;Apuntar a la tabla C00
    mov ecx,64
    mov eax, 0xFFFF0003
 ciclo:
    mov [esi],eax              ;Inicializar entrada del directorio.
    add esi,4                  ;Apuntar a la siguiente entrada.
    add eax,0x00000400         ;Calcular siguiente valor.
    loop ciclo


 ;------- Pagina de la Pila ------
    mov eax, __TP                   ; Esta tabla está en __DTP + 0x1000
    or eax, 0x1000
    or eax, 0x3
    mov dword [__DTP + 0x1FF], eax  ;Apuntar a tabla de pags al finl del espacio direccionable.
    xor eax, eax
    mov eax, __TP + 0x1FF
    mov esi, eax                    ;Apuntar a la tabla C00
    mov eax, 0x00000003
    mov [esi],eax                   ;Inicializar entrada del directorio.








    ;-> Inicializo entrada 0 de la DPT (para ISR, SYSTABLES)
xchg bx,bx
    push ebp
    mov ebp, esp
    push PAG_P_YES
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(__DTP+0x2000)           ; <- Tabla num 2
    push 0x00                          ; <- Offset dentro de la tabla
    push dword(__DTP)
    call __set_dir_page_table_entry
    leave

    push ebp
    mov ebp, esp
    push PAG_P_YES
    push PAG_RW_W
    push PAG_US_SUP
    push PAG_PWT_NO
    push PAG_PCD_NO
    push PAG_A
    push PAG_PS_4K
    push dword(0x0000)                 ; <- Pagina num 0
    push 0x00                          ; <- Offset dentro de la tabla
    push dword(__DTP+0x2000)           ; <- Tabla num 2
    call __set_page_table_entry    
    leave


;+++++++++
    ;------- 14va Pagina de la RAM (Pila 16bits = 0x0000 9000) ------
    ; Contenido de DTP
    mov eax, __TP                    ; Esta tabla está en __DTP + 0x3000 (tabla num 3)
    add eax, 0x1000*2                ; <- 3ra tabla de paginas
    add eax, 0x3                     ; ATTR de la TP
    ; Apunto al DTPE y le cargo su contenido
    mov dword [__DTP + 0x000*4], eax 
    ; Apunto a PTE y le cargo su contenido
    mov ebx, __TP + 0x1000*2 + 0x009*4
    mov eax, 0x00009003             ; Dir de la pagina + ATTR  
    mov [ebx], eax 

    ;------- 15va Pagina de la RAM (HANDLRES? = 0xFEC0 0000) ------
    ; Contenido de DTP
    mov eax, __TP                    ; Esta tabla está en __DTP + 0x3000 (tabla num 3)
    add eax, 0x1000*3                ; <- 4ta tabla de paginas
    add eax, 0x3                     ; ATTR de la TP
    ; Apunto al DTPE y le cargo su contenido
    mov dword [__DTP + 0x3FB*4], eax 
    ; Apunto a PTE y le cargo su contenido
    mov ebx, __TP + 0x1000*3 + 0x000*4
    mov eax, 0xFEC00003             ; Dir de la pagina + ATTR  
    mov [ebx], eax 
;+++++++++
;/**
;-----------------------------
;\fn ReprogamarPICs
;\brief Reprograma la base de interrupciones de los PICs
;\details Corre la base de los tipos de interrupci�n de ambos PICs 8259A de la PC a los 8 tipos consecutivos a partir de los valores base que recibe en BH para el PIC#1 y BL para el PIC#2.A su retorno las Interrupciones de ambos PICs est�n deshabilitadas.
;\author Alejandro Furfaro afurfaro@electron.frba.utn.edu.ar
;\date 2012-07-05
;------------------------------
;*/

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
  mov     al,0xFD	;0x11111101
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
  
  ret

;******************************************************************************
;
;FUNCIONES DE ACCESO AL RTC PARA ESTABLECER FECHA Y HORA
;
;******************************************************************************

;/**
;--------------------------------
;\fn hora
;\brief Obtiene la hora del sistema desde el RTC
;\args: Nada
;\return:	AL: Segundos
;		AH: Minutos
;		DL: Hora
;\author Alejandro Furfaro afurfaro@electron.frba.utn.edu.ar
;\date 2012-07-05
;--------------------------------
;*/
hora:
		call	RTC_disponible	;//asegura que no est� actualiz�ndose el RTC
		mov	al,4
		out	70h,al		;//Selecciona Registro de Hora
		in	al,71h		;//lee la hora desde el registro
		mov	dl,al
		
		mov	al,2
		out	70h,al		;//Selecciona Registro de Minutos
		in	al,71h		;//lee los minutos desde el registro
		mov	ah,al
		
		xor	al,al
		out	70h,al		;//Selecciona Registro de Segundos
		in	al,71h		;//lee los segundos desde el registro
		
		ret

;/**
;--------------------------------
;\fn fecha
;\brief Obtiene la fecha del sistema desde el RTC
;\args: Nada
;\return:	AL: Dia de la Semana
;		AH: Fecha del Mes
;		DL: Mes
;		DH: A�o
;\author Alejandro Furfaro afurfaro@electron.frba.utn.edu.ar
;\date 2012-07-05
;--------------------------------
;*/
fecha:
		call	RTC_disponible	;//asegura que no est� actualiz�ndose el RTC
		mov	al,9
		out	70h,al		;//Selecciona Registro de A�o
		in	al,71h		;//lee el a�o desde el registro
		mov	dh,al
		
		mov	al,8
		out	70h,al		;//Selecciona Registro de Mes
		in	al,71h		;//lee el mes desde el registro
		mov	dl,al
		
		mov	al,7
		out	70h,al		;//Selecciona Registro de Fecha
		in	al,71h		;//lee la Fecha del mes desde el registro
		mov	ah,al
		
		mov	al,6
		out	70h,al		;//Selecciona Registro de D�a 
		in	al,71h		;/lee el d�a de la semana desde el registro
		
		ret

;/**
;--------------------------------
;\fn RTC_disponible
;\brief Verifica en el Status Register A que el RTC no est� actualizando fecha y hora. Retorna cuando el RTC est� disponible.
;\args : Nada
;\return: Nada
;\author Alejandro Furfaro afurfaro@electron.frba.utn.edu.ar
;\date 2012-07-05
;--------------------------------

RTC_disponible:
		mov	al,0Ah
		out	70h,al	;//Selecciona registro de status A
wait_for_free:
		in	al,71h	;//lee Status
		test	al,80h	;//El bit 7 indica si est� en 1 que el RTC se est� actualizando
		jnz	wait_for_free
		ret


 ; --> Cargar la IDT con Debug Exception #DB (TIPO 1)<--
    push ebp
    mov ebp, esp    ;enter
    push IDT
    push ATTR_EXC
    push dword(EXCEPTION_DB)
    push CS_SEL_32
    push 0x01
    call __set_idt_entry