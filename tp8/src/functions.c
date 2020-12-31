#define dword   long
#define byte    char
#define sword   short
#define EOT   0x04          //Fin de transmisión


__attribute__(( section(".functions"))) byte __set_idt_entry(dword *exception_num,
                                                             dword *cs, 
                                                             dword *handler,
                                                             dword *attr, 
                                                             dword *idt_dir){ 
    byte i;
    for (i = 0; i < (2 * (dword)exception_num) ; i++){
        *idt_dir++;
    }

    dword high = (((dword)cs)<<0x10);
    dword low = (0x0000FFFF&(dword)handler);

    *idt_dir = high|low;
    *idt_dir++;

    high = (0xFFFF0000&(dword)handler);
    low = (0xFFFF & ((dword)attr)<<0x8);

    *idt_dir = high|low;
    
    return 1;
}

__attribute__(( section(".functions"))) byte __guardarDigito(dword *puntCB, dword *puntero, dword *CB, dword *dst){
    byte i;
    *puntCB = 0;
    for (i = 0; (i < *puntero) ; i++){
        ++dst;
    }
    //asm("xchg %bx,%bx");
    for (i = 0; (i < 0x10) ; i++){
        *dst = *CB;
        ++dst;
        ++CB;
         ++*puntero;
    }
    /*  // Si la lista Nueva es mas corta que la anterior los valores no pisan la anterior
        // debería luego de cada ENTER limpiar la lista circular
    for (i = 0; (i < 0x10) ; i++){
        *CB = 0;
        ++*CB;
       
    }*/
    return(*puntero);
}

__attribute__(( section(".functions"))) byte __recorrerBuffer(dword *pressedKey, dword *dst, dword *puntero){
    byte i;
    for (i = 0; (i < *puntero) ; i++){
        *dst++;
    }
    if((dword)pressedKey < 0x0B){                  // pregunta si es '0'
        *dst = (dword)pressedKey + 0x30 - 0x01;     // asigna caracteres ASCII a los numeros '1'-'9'
        ++*puntero;
    }else if((dword)pressedKey == 0x0B){
        *dst = (dword)0x30;                         // asigna caracter ASCII al '0'
        ++*puntero;
    }
    if(*puntero == 0x10){
        *puntero = 0;
    }
    return(*puntero);
}

__attribute__(( section(".functions"))) byte __limpiarBuffer(dword *dst){
    //asm("xchg %bx,%bx");
    byte i;
    for (i = 0; (i < 0x10) ; i++){
        *dst = 0x0;
        dst++;
    }
}