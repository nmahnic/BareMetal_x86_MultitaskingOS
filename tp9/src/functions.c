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
    dword i;
    byte j;
    dword aux = 0;
    *puntCB = 0;
    for (i = 0; (i < *puntero) ; i++){
        ++dst;
    }
    //asm("xchg %bx,%bx");
    for(j=0; j < 0x04 ; j++){
        for (i = 0; (i < 0x04) ; i++){
            aux |= *CB << (8*i) ;
            ++CB;
        }
        *dst = aux;
        ++dst;
        ++*puntero;
        aux = 0;
    }
    
    /*  // Si la lista Nueva es mas corta que la anterior los valores no pisan la anterior
        // debería luego de cada ENTER limpiar la lista circular
    for (i = 0; (i < 0x10) ; i++){
        *CB = 0;
        ++*CB;
       
    }*/
    //asm("xchg %bx,%bx");
    return(*puntero);
}

__attribute__(( section(".functions"))) byte __recorrerBuffer(dword *pressedKey, dword *dst, dword *puntero){
    dword i;
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

__attribute__(( section(".functions"))) byte __sumaDigitos(dword *src,dword *dst, dword *limite){
    //*limite = 31;
    //asm("xchg %bx,%bx");
    src = src + *limite - 4;
    //asm("xchg %bx,%bx");
    byte valores[] = {(byte)*src , (byte)(*src >> 8) , (byte)(*src >> 16) , (byte)(*src >> 24) };
    
    dword res = *dst;
    byte i,j;

    for (i = 0; (i < 0x4) ; i++){
        for (j = 0; (j < 0x4) ; j++){
            if(valores[j] < 0x30){
                valores[j] = 0x30;
            }
            res += (valores[j] - 0x30);
        }
        src++;
        valores[0] = (byte)*src;
        valores[1] = (byte)(*src >> 8);
        valores[2] = (byte)(*src >> 16);
        valores[3] = (byte)(*src >> 24);
    }

    *dst = res;
    //asm("xchg %bx,%bx");
    return 1;
}