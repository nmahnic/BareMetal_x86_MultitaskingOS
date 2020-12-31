#define dword   long
#define byte    char
#define sword   short
#define EOT   0x04          //Fin de transmisión

extern __IDT;
extern idtr;
extern CS_SEL_32;
extern EXCEPTION_DE;


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
    //low = 0x00008E00;
    low = (0xFFFF & ((dword)attr)<<0x8);

    *idt_dir = high|low;
    
    return 1;
}

__attribute__(( section(".functions"))) byte __guardarCaracter(dword *pressedKey, dword *dst){
    
    if((dword)pressedKey < 0x0B){                  // pregunta si es '0'
            *dst = (dword)pressedKey + 0x30 - 0x01;     // asigna caracteres ASCII a los numeros '1'-'9'
    }else if((dword)pressedKey == 0x0B){
        *dst = (dword)0x30;                         // asigna caracter ASCII al '0'

    // Aca asigna el ASCII a cada letra minuscula
    }else if(0x10 == (dword)pressedKey){                      // Si es 'q'
        *dst = 'q';
    }else if (0x11 == (dword)pressedKey){               // Si es 'w'
        *dst = 'w';
    }else if (0x12 == (dword)pressedKey){               // Si es 'e'
        *dst = 'e';
    }else if (0x13 == (dword)pressedKey){               // Si es 'r'
        *dst = 'r';
    }else if (0x14 == (dword)pressedKey){               // Si es 't'
        *dst = 't';
    }else if (0x15 == (dword)pressedKey){               // Si es 'y'
        *dst = 'y';                     // TIPO 0 0x00
        byte a = 0;                     // #DE (Divide Error Exception) 
        a /= 0;
    }else if (0x16 == (dword)pressedKey){               // Si es 'u'
        *dst = 'u';                     // TIPO 6 0x06
        asm("UD2");                     // #UD (Invalid Opcode Exception) 

    }else if (0x17 == (dword)pressedKey){               // Si es 'i'
        *dst = 'i';                     // TIPO 8 0x08
        asm("xchg %bx,%bx");
                                        // #DF (Double Fault Exception)
        asm("mov $0x0F,%eax");          //ATTR_EXC   con P='0'
        asm("mov %eax,(__IDT+5)");
        byte a = 0;                   
        a /= 0;
    }else if (0x18 == (dword)pressedKey){               // Si es 'o'
        *dst = 'o';                     // TIPO 13 0xD
        asm("xchg %bx,%bx");            
                                        // #GP (General Protection Fault Exception)
        asm("mov $0xFFFF0000,%eax");    //cargarle '1' en registros reservados
        asm("mov %eax,%cr4");  
    }else if (0x19 == (dword)pressedKey){               // Si es 'p'
        *dst = 'p';
    }else if (0x1e == (dword)pressedKey){               // Si es 'a'
        *dst = 'a';
    }else if (0x1f == (dword)pressedKey){               // Si es 's'
        *dst = 's';
    }else if (0x20 == (dword)pressedKey){               // Si es 'd'
        *dst = 'd';
    }else if (0x21 == (dword)pressedKey){               // Si es 'f'
        *dst = 'f';
    }else if (0x22 == (dword)pressedKey){               // Si es 'g'
        *dst = 'g';
    }else if (0x23 == (dword)pressedKey){               // Si es 'h'
        *dst = 'h';
    }else if (0x24 == (dword)pressedKey){               // Si es 'j'
        *dst = 'j';
    }else if (0x25 == (dword)pressedKey){               // Si es 'k'
        *dst = 'k';
    }else if (0x26 == (dword)pressedKey){               // Si es 'l
        *dst = 'l';
    }else if (0x2c == (dword)pressedKey){               // Si es 'z'
        *dst = 'z';
    }else if (0x2d == (dword)pressedKey){               // Si es 'x'
        *dst = 'x';
    }else if (0x2e == (dword)pressedKey){               // Si es 'c'
        *dst = 'c';
    }else if (0x2f == (dword)pressedKey){               // Si es 'v'
        *dst = 'v';
    }else if (0x30 == (dword)pressedKey){               // Si es 'b'
        *dst = 'b';
    }else if (0x31 == (dword)pressedKey){               // Si es 'n'
        *dst = 'n';
    }else if (0x32 == (dword)pressedKey){               // Si es 'm'
        *dst = 'm';
    }else{
        *dst = EOT;
    }

    return((dword)dst);
}