/*Linker Básico*/

ENTRY (reset)       /* Le indica al linke por donde se entra al codigo, esta etiquera esta en reset.asm*/

        __EH_FRAME              = 0x00060000;       /* Se suele usar en C y C++ ExceptionHandling */
        __DATA_NO_INIT          = 0x00050000;       /* No se acuerda que hace */

        __STACK_START_16        = 0x00009000;
        __STACK_END_16          = 0x00009FFF;

        __STACK_START_32        = 0x1FF08000;/**/
        __STACK_END_32          = 0x1FF08FFF;/**/
        /*__STACK_START_32        = 0x00008000;/*0x1FF08000;*/
        /*__STACK_END_32          = 0x00008FFF;/*0x1FF08FFF;*/       /* 4KB de espacio para el STACK */
        __STACK_SIZE_32         = ((__STACK_END_32 - __STACK_START_32) / 4); /* 32b word o doubleWords */

        __IDT                   = 0x00001000;       /* Para la IDT dsp lo hardcodeó */

        /*---------------VMA---------------*/
        __FUNCTIONS_VMA         = 0x00000000;       /* A donde serán copiadas y ejecutadas */
        __KERNEL_32_VMA         = 0x00200000;       /* A donde serán copiadas y ejecutadas */
        __KeyboardbyPolling     = 0x00210000;       /* Tabla de digitos polleados 64K*/
        __HANDLERS_32_VMA       = 0x00202000;       /* A donde serán copiadas y ejecutadas */

        __INIT_16_VMA           = 0xFFFF0000;       /* En donde ejecutadas en ROM */
        __INIT_32_VMA           = 0xFFFFF800;       /* En donde ejecutadas en ROM */
        __FUNCTIONS_ROM_VMA     = 0xFFFFFC00;       /* En donde ejecutadas en ROM */
        __SYS_TABLE_VMA         = 0xFFFFFD00;       /* En donde ejecutadas en ROM */
        __RESET_VMA             = 0xFFFFFFF0;       /* En donde ejecutadas en ROM */

        /*---------------LMA---------------*/
        __FUNCTIONS_LMA         = 0xFFFF1000;       /* En donde son cargadas en ROM */
        __KERNEL_32_LMA         = 0xFFFF2000;       /* En donde son cargadas en ROM */
        __HANDLERS_32_LMA       = 0xFFFF3000;       /* En donde son cargadas en ROM */

        __INIT_16_LMA           = 0xFFFF0000;       /* En donde son cargadas en ROM */
        __INIT_32_LMA           = 0xFFFFF800;       /* En donde son cargadas en ROM */
        __FUNCTIONS_ROM_LMA     = 0xFFFFFC00;       /* En donde son cargadas en ROM */
        __SYS_TABLE_LMA         = 0xFFFFFD00;       /* En donde son cargadas en ROM */
        __RESET_LMA             = 0xFFFFFFF0;       /* En donde son cargadas en ROM */
        __SYS_TABLE             = 0x000FFD00;       /* Shadow */


MEMORY
{
    ram (!x) : ORIGIN = 0x00000000, LENGTH = 0xFFFF0000 /* 2^32 (4GB) 2^16 (64KB) */
    rom (r) : ORIGIN = 0xFFFF0000, LENGTH = 0xFFFF
}
SECTIONS
{
    /* Las seccion .kernel32 y las que agregue si es que lo hago.. se compilaran en el binario en una unica sección */
    /* .codigo_kernel32 las cuales estaran guardadas en __KERNEL_32_LMA y se ejecutaran en __KERNEL_32_VMA */
    .codigo_kernel32 __KERNEL_32_VMA :
        AT( __KERNEL_32_LMA )
        { *(.kernel32); } > ram                           /* Esta sección no  puede escaparse de MEMORY ram */
    __codigo_kernel32_size = SIZEOF(.codigo_kernel32);

    /* __codigo_kernel32_size es una variable que se puede usar en el código */ 
    /* (hay que declararla comos EXTERN */

    .functions __FUNCTIONS_VMA :
        AT( __FUNCTIONS_LMA )
            {*(.functions .KB_enable);} > ram                          /* Esta sección no  puede escaparse de MEMORY ram */
    __functions_size = SIZEOF(.functions);

    /* __functions_size es una variable que se puede usar en el código */ 
    /* (hay que declararla comos EXTERN */

    .handlers __HANDLERS_32_VMA :
        AT( __HANDLERS_32_LMA )
            {*(.handlers_32);} > ram                   /* Esta sección no  puede escaparse de MEMORY ram */
    __handlers_32_size = SIZEOF(.handlers);

    /* __handlers_size es una variable que se puede usar en el código */ 
    /* (hay que declararla comos EXTERN */

    /* Las de arriba son aquellas que serán copiadas, las variables __function_size */ 
    /* son usadas para indicarle a memcopy cuanto tiene que copiar */

    .codigo_init16 __INIT_16_VMA :
        AT( __INIT_16_LMA )
            {*(.ROM_init .A20_enable);} > rom                           /* Esta sección no  puede escaparse de MEMORY rom */

    .codigo_init32 __INIT_32_VMA :
        AT( __INIT_32_LMA )
            {*(.start32);} > rom                            /* Esta sección no  puede escaparse de MEMORY rom */

    .functions_rom __FUNCTIONS_ROM_VMA :
        AT( __FUNCTIONS_ROM_LMA )
            {*(.functions_rom*);} > rom                     /* Esta sección no  puede escaparse de MEMORY rom */

    .data __SYS_TABLE_VMA :
        AT( __SYS_TABLE_LMA )
            {*(.sys_tables*);} > rom

    .codigo_reset __RESET_VMA :
        AT( __RESET_LMA )
            {*(.resetVector*);} > rom


    /************ suple al aling 16 ************/
    .fill_rom :
        { FILL(0x90);
            . = ORIGIN(rom)+ LENGTH(rom)-1;
            BYTE(0x90);                         /* NOPs */
        } > rom

    /* El ld no permite escribir en la última posición de MEMORY, por lo que para tener la ROM alineada debo agregar */
    /* este último NOM a mano, sino me quedaría la posición 0xFFFE de la ROM (64K) vacia y el BOCHS no inicial correctamente */
    .end_rom 0xFFFFFFFF:
        AT( 0xFFFFFFFF )
        { BYTE(0x90);}

}
