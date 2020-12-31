#define dword   long
#define byte    char
#define sword   short
#define EOT   0x04          //Fin de transmisión

extern __VIDEO_lineal;
extern msgDir;
extern msgDir_len;
extern msgIn;
extern msgIn_len;

//----------------------------------------------------------------------------------------
//                                       FUNCTIONS 
//----------------------------------------------------------------------------------------
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

__attribute__(( section(".functions"))) byte __guardarDigito(dword *puntCB, dword puntero, dword *CB, dword *dst){
    dword i;
    byte j;
    dword aux = 0;
    *puntCB = 0;
    for (i = 0; (i < puntero) ; i++){
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
        ++puntero;
        aux = 0;
    }
    
    return(puntero);
}

__attribute__(( section(".functions"))) byte __recorrerBuffer(dword *pressedKey, dword *dst, dword *puntero){
    dword i;
    dword aux = 0;
    dword aux2 = 0;
    byte carc = 0;
    for (i = 0; (i < *puntero) ; i++){
        *dst++;
    }
    if((dword)pressedKey < 0x0B){                  // pregunta si es '0'
        *dst = (dword)pressedKey - 0x01;     // asigna caracteres ASCII a los numeros '1'-'9'
        carc = *dst + 0x30;
        ++*puntero;
    }else if((dword)pressedKey == 0x0B){
        *dst = (dword)0x00;                         // asigna caracter ASCII al '0'
        carc = *dst + 0x30;
        ++*puntero;
    }else if (0x18 == (dword)pressedKey){               // Si es 'o'
        carc = 'o';                     // TIPO 13 0xD
        WriteCharacter(&__VIDEO_lineal,'o',0,5);
        //asm("xchg %bx,%bx");            
                                        // #GP (General Protection Fault Exception)
        asm("mov $0xFFFF0000,%eax");    //cargarle '1' en registros reservados
        asm("mov %eax,%cr4");  
    }else if (0x19 == (dword)pressedKey){               // Si es 'p'
        carc = 'p';
        WriteCharacter(&__VIDEO_lineal,'p',0,5);
        asm("mov %eax,0x00001000");
        asm("mov %eax,0x00002000");
        asm("mov %eax,0x00004000");
        asm("mov %eax,0x10000000");
        //asm("mov %eax,0x20000000"); <- 512MB 
    }else if (0x1e == (dword)pressedKey){               // Si es 'a'
        *dst = 0xA;                         // asigna caracter ASCII al '0'
        carc = 'A';
        ++*puntero;
    }else if (0x30 == (dword)pressedKey){               // Si es 'b'
        *dst = 0xB;                         // asigna caracter ASCII al '0'
        carc = 'B';
        ++*puntero;
    }else if (0x2e == (dword)pressedKey){               // Si es 'c'
        *dst = 0xC;                         // asigna caracter ASCII al '0'
        carc = 'C';
        ++*puntero;
    }else if (0x20 == (dword)pressedKey){               // Si es 'd'
        *dst = 0xD;                         // asigna caracter ASCII al '0'
        carc = 'D';
        ++*puntero;
    }else if (0x12 == (dword)pressedKey){               // Si es 'e'
        *dst = 0xE;                         // asigna caracter ASCII al '0'
        carc = 'E';
        ++*puntero;
    }else if (0x21 == (dword)pressedKey){               // Si es 'f'
        *dst = 0xF;                         // asigna caracter ASCII al '0'
        carc = 'F';
        ++*puntero;
    }
    if(*puntero == 0x10){
        *puntero = 0;
    }
    //asm("xchg %bx,%bx");
    __myprintfY(&msgIn,&msgIn_len,24);
    aux = *puntero;
    aux2 = &msgIn_len;
    aux += aux2; 

    WriteCharacter(&__VIDEO_lineal,carc,(aux),24);
    return(*puntero);
}

__attribute__(( section(".functions"))) void __limpiarBuffer(dword *dst){
    //asm("xchg %bx,%bx");
    byte i;
    for (i = 0; (i < 0x10) ; i++){
        *dst = 0x0;
        dst++;
    }
    __cleanLine(&__VIDEO_lineal,24);
}

__attribute__(( section(".functions"))) void __cleanLine(dword *src, dword y){
    dword i;
    //asm("xchg %bx,%bx");
    for(i=0 ; i<=(y*40)-1 ; i++){ //80 filas, 20 columnas, 2 bytes cada caracter (como escribo de a dwords / 4)
        src++;
    }
    for(i=0 ; i<=60 ; i++){ //80 filas, 20 columnas, 2 bytes cada caracter (como escribo de a dwords / 4)
        *src = 0;
        src++;
    }
}

__attribute__(( section(".functions"))) void WriteCharacter(dword *init, dword puntero, dword x, dword y){
    sword aux;
    if( (x&0x0001) == 0 ){        
        aux = ((byte)(*init & 0x0000FF00));
        init += (x+(y*80))/2; 
        *init = ((((puntero)|(0x7<<8))) | (aux));
    }else if(x == 1)
    {   
        init += (x-1+(y*40)); 
        aux = ((sword)*init);
        *init = aux;
        *init = ((((puntero)|(0x7<<8))<<16) | (aux));
    }else{
        init += ((x/2)+(y*40)); 
        aux = ((sword)*init);
        *init = aux;
        *init = ((((puntero)|(0x7<<8))<<16) | (aux));
    }
}

__attribute__(( section(".functions"))) void __myprintfY(dword *init_str,
                                                        dword length,
                                                        dword y){ 

    //asm("xchg %bx,%bx");
    byte valores[4];
    sword i,j;
    sword x = 0;

    for(j=0 ; j < (length/4)+1 ; j++){
        valores[0] = (byte)*init_str;
        valores[1] = (byte)(*init_str >> 8);
        valores[2] = (byte)(*init_str >> 16);
        valores[3] = (byte)(*init_str >> 24);
        for(i=0 ; i < 4 ;i++){
            // No tengo que escribir un final de linea, sigo escribiendo.
            //asm("xchg %bx,%bx");
            if(valores[i]==10)break;
            WriteCharacter(&__VIDEO_lineal,(valores[i]),x,y);
            x++;
            // Chequeo si llegue al finnal de la linea
            if(x >= 80){
                y++;
                x=0;
            }
        }
        if(valores[i]==10)break;
        init_str++;
    }
}

__attribute__(( section(".functions"))) void __myprintfXY(dword *init_str,
                                                        dword length,
                                                        dword x,
                                                        dword y){ 

    //asm("xchg %bx,%bx");
    byte valores[4];
    sword i,j;

    for(j=0 ; j < (length/4)+1 ; j++){
        valores[0] = (byte)*init_str;
        valores[1] = (byte)(*init_str >> 8);
        valores[2] = (byte)(*init_str >> 16);
        valores[3] = (byte)(*init_str >> 24);
        for(i=0 ; i < 4 ;i++){
            // No tengo que escribir un final de linea, sigo escribiendo.
            //asm("xchg %bx,%bx");
            if(valores[i]==10)break;
            WriteCharacter(&__VIDEO_lineal,(valores[i]),x,y);
            x++;
            // Chequeo si llegue al finnal de la linea
            if(x >= 80){
                y++;
                x=0;
            }
        }
        if(valores[i]==10)break;
        init_str++;
    }
}

//----------------------------------------------------------------------------------------
//                                  HANDLERS FUNCTIONS 
//----------------------------------------------------------------------------------------
__attribute__(( section(".handlers_32"))) void __crear_pag_din(dword * DTP,dword cr2){
    static byte newpagnum = 0;
    static byte newpagtablenum = 6;
    byte i;
    dword aux;
    dword * TP3 = DTP + 0xC00; // TP de los primeros 4M. Desde 0x0000 0000 a 0x0040 0000
    //dword * TP = DTP + 0x1400; // TP siguientes 4M hasta 512M.
    dword * TP = DTP; // + 0x1400; // TP siguientes 4M hasta 512M.

    dword firstP = 0x08000000;

    dword DTE = (cr2 >> 22);
    dword PTE = (0x000003FF)&(cr2 >> 12);
    if(PTE != 0){
        for(i=0; i < PTE ; i++){
                *TP3++;
        }
    }
    if(DTE == 0){
        *TP3 = firstP| (0x1000*newpagnum) | 0x3;
    }else{
        //asm("xchg %bx,%bx");
        aux = DTP;
        for(i=0; i < DTE ; i++){
            *DTP++;
        }
        if(*DTP == 0){
            __addPageTables(newpagtablenum+1);
            //asm("xchg %bx,%bx");
            aux += (0x1000 * newpagtablenum);
            *DTP = aux | 0x3;
            
            //asm("xchg %bx,%bx");
            TP = aux;
            if(PTE != 0){
                for(i=0; i < PTE ; i++){
                    *TP++;
                }
            }
            *TP = firstP| (0x1000*newpagnum) | 0x3;
            newpagtablenum++;
        }else{
            //asm("xchg %bx,%bx");
            TP = *DTP & 0xFFFFFFFC;
            if(PTE != 0){
                for(i=0; i < PTE ; i++){
                    *TP++;
                }
            }
            //asm("xchg %bx,%bx");
            *TP = firstP| (0x1000*newpagnum) | 0x3;
        }
    }
    newpagnum++;
}

//----------------------------------------------------------------------------------------
//                                  TAREAS FUNCTIONS 
//----------------------------------------------------------------------------------------
__attribute__(( section(".tarea1"))) void WriteCharacterT1(dword *init, dword puntero, dword x, dword y){
    sword aux;
    //asm("xchg %bx,%bx");
    if( (x&0x0001) == 0 ){        
        aux = ((byte)(*init & 0x0000FF00));
        init += (x+(y*80))/2; 
        *init = ((((puntero)|(0x7<<8))) | (aux));
    }else if(x == 1)
    {   
        init += (x-1+(y*40)); 
        aux = ((sword)*init);
        *init = aux;
        *init = ((((puntero)|(0x7<<8))<<16) | (aux));
    }else{
        init += ((x/2)+(y*40)); 
        aux = ((sword)*init);
        *init = aux;
        *init = ((((puntero)|(0x7<<8))<<16) | (aux));
    }
}

__attribute__(( section(".tarea2"))) void WriteCharacterT2(dword *init, dword puntero, dword x, dword y){
    sword aux;
    //asm("xchg %bx,%bx");
    if( (x&0x0001) == 0 ){        
        aux = ((byte)(*init & 0x0000FF00));
        init += (x+(y*80))/2; 
        *init = ((((puntero)|(0x7<<8))) | (aux));
    }else if(x == 1)
    {   
        //asm("xchg %bx,%bx");
        init += (x-1+(y*40)); 
        aux = ((sword)*init);
        *init = aux;
        *init = ((((puntero)|(0x7<<8))<<16) | (aux));
    }else{
        //asm("xchg %bx,%bx");
        //aux= ((x/2)+(y*40));
        //asm("xchg %bx,%bx");
        //init = init + aux;
        //asm("xchg %bx,%bx"); 
        init += ((x/2)+(y*40)); 
        aux = ((sword)*init);
        *init = aux;
        *init = ((((puntero)|(0x7<<8))<<16) | (aux));
        //asm("xchg %bx,%bx");
    }
}