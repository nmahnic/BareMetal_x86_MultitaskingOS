/*Linker Básico*/

ENTRY (reset)       /* Le indica al linke por donde se entra al codigo, esta etiquera esta en reset.asm*/

        __EH_FRAME              = 0x00060000;       /* Se suele usar en C y C++ ExceptionHandling */
        __DATA_NO_INIT          = 0x00050000;       /* No se acuerda que hace */

        __STACK_START_16        = 0x00009000;
        __STACK_END_16          = 0x00009FFF;

        __STACK_START_32        = 0x1FF08000;
        __STACK_END_32          = 0x1FF08FFF;
        __STACK_SIZE_32         = ((__STACK_END_32 - __STACK_START_32) / 4); /* 32b word o doubleWords */

        __STACKT1_START_VMA     = 0x00713000; 
            __STACKT1_START_phy = 0x1FFFF000;  
        __STACKT1_END_VMA       = 0x00713FFF;
            __STACKT1_END_phy   = 0x1FFFFFFF;  
        __STACKT1_SIZE          = ((__STACKT1_END_VMA - __STACKT1_START_VMA) / 4); /* 32b word o doub */ 

        __STACKT2_START_VMA     = 0x00713000;  
            __STACKT2_START_phy = 0x1FFFE000; 
        __STACKT2_END_VMA       = 0x00713FFF;
            __STACKT2_END_phy   = 0x1FFFEFFF; 
        __STACKT2_SIZE          = ((__STACKT2_END_VMA - __STACKT2_START_VMA) / 4); /* 32b word o doub */

        __STACKT3_START_VMA     = 0x00713000; 
            __STACKT3_START_phy = 0x1FFFD000; 
        __STACKT3_END_VMA       = 0x00713FFF;
            __STACKT3_END_phy   = 0x1FFFDFFF; 
        __STACKT3_SIZE          = ((__STACKT3_END_VMA - __STACKT3_START_VMA) / 4); /* 32b word o doub */


        /*__IDT                   = 0x00001000;       /* Para la IDT dsp lo hardcodeó */

        /*---------------VMA---------------*/
        __ISR_VMA               = 0x00000000;       /* A donde serán copiadas y ejecutadas */
        __VIDEO                 = 0x000B8000;
            __VIDEO_lineal      = 0x00010000;
        __SysTable              = 0x00100000;
            __IDT               = 0x00100100;
        __DTPK                  = 0x00110000;       /*Tabla de Directorios*/
        __KERNEL_32_VMA         = 0x01200000;       /* A donde serán copiadas y ejecutadas */
            __Kernel_phy        = 0x00200000;
        __KeyboardbyPolling     = 0x01210000;       /* Tabla de digitos polleados 64K*/
            __KeysPhy           = 0x00210000;
        __DATA_VMA              = 0x01202000;       /* A donde serán copiadas y ejecutadas */
            __DATA_phy          = 0x00202000;       /* A donde serán copiadas y ejecutadas */
        __BSS_VMA               = 0x01203000;  
            __BSS_phy           = 0x00203000;  
        

        __TEXT1_VMA             = 0x01300000;
        __BSST1_VMA             = 0x01301000;       /*BSS no es ensablamda en ROM*/
        __DATAT1_VMA            = 0x01302000;       /* A donde serán copiadas y ejecutadas */
        __DTP_T1                = 0x01303000;       /*Tabla de Directorios*/
            __TEXT1_phy         = 0x00300000;
            __BSST1_phy         = 0x00301000;       /*BSS no es ensablamda en ROM*/
            __DATAT1_phy        = 0x00302000;       /* A donde serán copiadas y ejecutadas */

        __TEXT2_VMA             = 0x01310000;
        __BSST2_VMA             = 0x01311000;       /*BSS no es ensablamda en ROM*/
        __DATAT2_VMA            = 0x01312000;       /* A donde serán copiadas y ejecutadas */
        __DTP_T2                = 0x01313000;       /*Tabla de Directorios*/
            __TEXT2_phy         = 0x00310000;
            __BSST2_phy         = 0x00311000;       /*BSS no es ensablamda en ROM*/
            __DATAT2_phy        = 0x00312000;       /* A donde serán copiadas y ejecutadas */

        __TEXT3_VMA             = 0x01320000;
        __BSST3_VMA             = 0x01321000;       /*BSS no es ensablamda en ROM*/
        __DATAT3_VMA            = 0x01322000;       /* A donde serán copiadas y ejecutadas */
        __DTP_T3                = 0x01323000;       /*Tabla de Directorios*/
            __TEXT3_phy         = 0x00320000;
            __BSST3_phy         = 0x00321000;       /*BSS no es ensablamda en ROM*/
            __DATAT3_phy        = 0x00322000;       /* A donde serán copiadas y ejecutadas */
        
        __TSS_BASICA            = 0x01400000;
        /*__TSS0_VMA              = 0x01400100;*/
        __TSS1_VMA              = 0x01400100;
        __TSS2_VMA              = 0x01400200;
        __TSS3_VMA              = 0x01400300;
        __MMX1_VMA              = 0x01400400;
        __MMX2_VMA              = 0x01400500;

        __INIT_16_VMA           = 0xFFFF0000;       /* En donde ejecutadas en ROM */
        __INIT_32_VMA           = 0xFFFFF000;       /* En donde ejecutadas en ROM */
        __FUNCTIONS_ROM_VMA     = 0xFFFFFD00;       /* En donde ejecutadas en ROM */
        __SYS_TABLE_VMA         = 0xFFFFFE00;       /* En donde ejecutadas en ROM */
        __RESET_VMA             = 0xFFFFFFF0;       /* En donde ejecutadas en ROM */

        /*---------------LMA---------------*/
        __KERNEL_32_LMA         = 0xFFFF2000;       /* En donde son cargadas en ROM */
        __DATA_LMA              = 0xFFFF4000;       /* En donde son cargadas en ROM */
        __ISR_LMA               = 0xFFFF5000;       
        __TEXT1_LMA             = 0xFFFF6000;
        __DATAT1_LMA            = 0xFFFF7000;       /* En donde son cargadas en ROM */
        __TEXT2_LMA             = 0xFFFF8000;
        __DATAT2_LMA            = 0xFFFF9000;       /* En donde son cargadas en ROM */
        __TEXT3_LMA             = 0xFFFFA000;
        __DATAT3_LMA            = 0xFFFFB000;       /* En donde son cargadas en ROM */


        __INIT_16_LMA           = 0xFFFF0000;       /* En donde son cargadas en ROM + init VIDEO */
        __INIT_32_LMA           = 0xFFFFF000;       /* En donde son cargadas en ROM */
        __FUNCTIONS_ROM_LMA     = 0xFFFFFD00;       /* En donde son cargadas en ROM */
        __SYS_TABLE_LMA         = 0xFFFFFE00;       /* En donde son cargadas en ROM */
        __RESET_LMA             = 0xFFFFFFF0;       /* En donde son cargadas en ROM */
        __SYS_TABLE             = 0x000FFD00;       /* Shadow */


MEMORY
{
    ram (!x) : ORIGIN = 0x00000000, LENGTH = 0xFFFF0000 /* 2^32 (4GB) 2^16 (64KB) */
    rom (rx) : ORIGIN = 0xFFFF0000, LENGTH = 0xFFFF
}
SECTIONS
{
 /* Las seccion .kernel32 y las que agregue si es que lo hago.. se compilaran en el binario en una unica sección */
 /* .codigo_kernel32 las cuales estaran guardadas en __KERNEL_32_LMA y se ejecutaran en __KERNEL_32_VMA */
    .codigo_kernel32 __KERNEL_32_VMA :
        AT( __KERNEL_32_LMA )
        { *(.kernel32 .functions); } > ram                           /* Esta sección no  puede escaparse de MEMORY ram */
    __codigo_kernel32_size = SIZEOF(.codigo_kernel32);

    .ISR __ISR_VMA :
        AT( __ISR_LMA )
            {*(.handlers_32);} > ram                          /* Esta sección no  puede escaparse de MEMORY ram */
    __ISR_size = SIZEOF(.ISR);

    .data __DATA_VMA :
        AT ( __DATA_LMA )  
            {*(.dataD);} > ram                          /* Esta sección no  puede escaparse de MEMORY ram */
    __data_size = SIZEOF(.data);

    .bss __BSS_VMA :  
            {*(.bss .bssT);} > ram

 /*Tarea1*/
    .bssT1 __BSST1_VMA :  
            {*(.bssT1);} > ram                          /* Esta sección no  puede escaparse de MEMORY ram */

    .TEXT1 __TEXT1_VMA : 
        AT ( __TEXT1_LMA ) 
            {*(.tarea1);} > ram                          /* Esta sección no  puede escaparse de MEMORY ram */
    __TEXT1_size = SIZEOF(.TEXT1);

    .dataT1 __DATAT1_VMA :
        AT ( __DATAT1_LMA )  
            {*(.dataT1);} > ram                          /* Esta sección no  puede escaparse de MEMORY ram */
    __dataT1_size = SIZEOF(.dataT1);

 /*Tarea2*/
    .bssT2 __BSST2_VMA :  
            {*(.bssT2);} > ram                          /* Esta sección no  puede escaparse de MEMORY ram */

    .TEXT2 __TEXT2_VMA : 
        AT ( __TEXT2_LMA ) 
            {*(.tarea2);} > ram                          /* Esta sección no  puede escaparse de MEMORY ram */
    __TEXT2_size = SIZEOF(.TEXT2);

    .dataT2 __DATAT2_VMA :
        AT ( __DATAT2_LMA )  
            {*(.dataT2);} > ram                          /* Esta sección no  puede escaparse de MEMORY ram */
    __dataT2_size = SIZEOF(.dataT2);


 /*Tarea3*/
    .bssT3 __BSST3_VMA :  
            {*(.bssT3);} > ram                          /* Esta sección no  puede escaparse de MEMORY ram */

    .TEXT3 __TEXT3_VMA : 
        AT ( __TEXT3_LMA ) 
            {*(.tarea3);} > ram                          /* Esta sección no  puede escaparse de MEMORY ram */
    __TEXT3_size = SIZEOF(.TEXT3);

    .dataT3 __DATAT3_VMA :
        AT ( __DATAT3_LMA )  
            {*(.dataT3);} > ram                          /* Esta sección no  puede escaparse de MEMORY ram */
    __dataT3_size = SIZEOF(.dataT3);


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

    .sys_tables __SYS_TABLE_VMA :
        AT( __SYS_TABLE_LMA )
            {*(.sys_tables*);} > rom                        /*Podría ser memcopiado pero la leo desde ROM*/
    __systable_size = SIZEOF(.sys_tables);

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


/*	.sys_tables 0x00100000 : 
	  AT ( LOADADDR(.init) + SIZEOF(.init) )
		{ __sys_tables_LMA = LOADADDR(.sys_tables);
		__sys_tables_start = . ; *(.sys_tables*);
		__sys_tables_end = . ;} 
*/