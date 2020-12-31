|      Alumno        |                TP               |
| ------------------ | ------------------------------- |
| **Nicolás MAHNIC** | **TP 15 Niveles de Privilegio** |

# Documentación
## Tabla de Contenidos
1. [Reset](#reset)
2. [Init 16](#init_16)
    1. [Modo Real](#modo_real)
    2. [Modo Protegido](#modo_progedigo)
3. [Init 32](#init_32)
    1. [Selectores](#selectores)
    2. [Pila de Kernel](#pila_de_kernel)
    3. [Perfisfericos](#perisfericos)
    4. [Memcopy](#memcopy_a_ram)
    5. [Paginación](#paginación)
        1. [Estructura_de_Paginación_Kernel](#estructura_de_paginación_kernel)
        2. [Estructura_de_Paginación_Tarea1](#estructura_de_paginación_tarea1)
        3. [Estructura_de_Paginación_Tarea2](#estructura_de_paginación_tarea2)
        4. [Estructura_de_Paginación_Tarea3](#estructura_de_paginación_tarea3)
    6. [Interrupciones](#interrupciones)
    7. [Inicializacion TSS](#tss_init)
4. [Main](#main)
5. [Handlers](#handlers)
    1. [Timer - Scheduler](#timer-scheduler)
    2. [Teclado](#teclado)
    3. [SIMD - SaveContext](#nm-simd_savecontext)
    4. [Page Fault](#page_fault)
6. [Tareas](#tareas)
    1. [Tarea 1](#tarea_1)
    2. [Tarea 2](#tarea_2)
    3. [Tarea 3](#tarea_3)
7. [Anexo de programas de depuración](#anexo)
    1. [Bochs](#bochs)
    2. [Listing](#listing)
    3. [Linker Script](#linkerscript)
    4. [READELF](#readelf)
    5. [OBJDUMP](#objdump)  
    6. [HEXDUMP](#hexdump)  
    7. [OKTETA](#okteta)

* * *
## Reset
El proceso de reset arranca desde la posición 0xFFFF0 del último mega de la memoria en donde se encuentra direccionada la ROM.
No significa que la RAM tiene 4GB menos 64KB, sino que el chip select del ultimo mega direccionable está conectado a la ROM el lugar de la RAM, dejando las direcciones 0xFFFF 0000 hasta 0xFFFF FFFF sin poder ser utilizadas.

Desde la dirección 0xFFF0 hasta el final de la ROM solo hay 16B, por ello es preciso deshabilitar las interrupciones y poner el bit DF en 0, ciertamente si el sistema arrancó correctamente estos bits del EFLAGS deben amanecer en 0. Luego de esto saltar a una posición de memoria donde se encuentre la continuación del programa de Inicialización.

El salto se produce a 0xF0000 que es la base de la ROM. A partir de ahí se encuentra toda la rutina de inicialización.

### ¿Por qué indico la direcciones 0xF0000?
Como el sistema arranca en modo real como los antiguos 8086 que solo pueden direccionar 1MB de memoria solo hay 'visibles' 20bits de addres formando 2^20 = 1MB de direcciones.

De esta manera para el procesador en modo real de 0x00000 a 0xEFFFF es RAM y de 0xF0000 a 0xFFFFF es ROM. Esto no es así y las direcciones no son direcciones físicas ya que el procesador realmente tiene 32 bits de address y la ROM se encuentra en las direcciones 0xFFFF 0000 a 0xFFFF FFFF como se mencionó anteriormente. A este apantallamiento que el procesador 80286 en adelante hacen para arrancar en modo compatibilidad con el 8086 se llama **Shadow**.

* * *
## Init_16
Hasta ahora hemos trabajado en Modo Real 16 bits, lo cual limita las capacidades de nuestro procesador a un 8086. Buscamos ahora pasar a Modo Protegido para poder utilizar Paginación, habilitar multitarea y usar Niveles diferentes de Protección para nuestro sistema.

Ni bien arrancó el sistema se realizó internamente un test del estado del procesador, registros, etc. Este test se llama **Built in Self Test**. Luego de esto el registro EAX amanece en 0x0, de caso contrario habrá habido un error de inicialización del procesador y se deberá reiniciar.

Luego se habilita el A20 gate el cual permite que una vez en modo protegido se pueda direccionar memoria por encima del bit 20 del bus de address permitiendo acceder a los 4GB (si es que los tuviese, en este caso tenemos 512MB). Esta función fue proporcionada por la cátedra y para el simulador Bochs es prescindible, pero es correcto realizar esta operación en los procesadores IA-32.

Se invalida el uso de TLB, se carga una pila para el kernel en modo real aunque no la utilizaremos. 
La parte más importante antes de habilitar modo protegido es cargar una GDT donde los segmentos de codigo y datos tengan el formato de modo protegido. Recordemos que los selectores en modo real desplazan 4 bits hacia la derecha y se le suma el offset para obtener la dirección lineal. Cabe destacar que en modo real y en modo protegido sin paginación la dirección lineal coincide con la dirección física.

### Modo_Real:
Así se calculan las direcciones físicas para un bus de address de 20 bits como el 8086. De hecho, para procesadores 80286 en adelante, la dirección base que se le suma al offset es un Shadow que aplica la *Unidad de Segmentación* de 0xFFFF 0000 cuando el procesador se encuentra en modo real.

#### 8086:
```
 PhysicalAddress = Segment * 16 + Offset     <- LogicalAddress = Segment:Offset
```
#### 80286 en adelante:
```
 PhysicalAddress = Base + Offset             <- LogicalAddress = Segment:Offset
                                                    Base = 0xFFFF 0000
```
### Modo_Progedigo:
```
 LinearAddres = Base + (Index * Scale) + Offset     <- LogicalAddress = Segment:Offset
                                                       Segment = {
                                                           Base: 0x0000 0000,
                                                           Limit: 0xFFFF FFFF,
                                                           ATTR: NNN
                                                       }
                                                       Index & Scale ~ 0
```
Se habilita el Modo Protegido cambiando el CRO.PE = 1
Por ultimo se hace un salto intersegmento desde el segmento CS de modo real 0xF000 el cual inicia siendo un shadow a la memoria para trabajar en el último mega direccionable hasta el CS_SEL_KER 0x0008 donde se especifica la base y el limite del segmento según la GDT. En cuanto al offset, se salta una posición de ROM pero usando los 32 bits.

Este salto intersegmento permite que se recarge los cache ocultos de los selectores en donde originalmente el CS tiene un shadow a la dirección base 0xFFFF 0000.
Se puede chequear antes y despues de hacer el salto indicando en el bochs 
```
    sreg
    (...)
    cs:0xF000, dh=0xFF0093FF, dl=0x0000FFFF, valid=7
    Code Segment, base=0xFFFF0000, limit=0x0000FFFF, Read/Write, Accessed
    (...)
    step [s]                                            <- *Aca realiza el salto intersegmento*
    sreg                            
    (...)
    cs:0x0008, dh=0x00CF9900, dl=0x0000FFFF, valid=1
    Code Segment, base=0x00000000, limit=0xFFFFFFFF, Execute Only, Non-Conforming, Accessed, 32bit
    (...)
```
Si por algún caso se produce un salto intersegmento o interrupción antes de pasar a modo protegido se saltará a una posición invalida, ya que, al actualizar el cache oculto donde se guarda la GDT se perderá el Shadow sobre el segmento CS con el que arranca el procesador. Es por esto que es fundamental tener el CR0.IF = 0 (interruptFlag).

* * *
## Init_32
### Selectores
Init32 sigue operando desde ROM, debe cargarse adecuadamente los demas selectores de la GDT. Los selectores DS, ES, FS, GS y SS tienen la misma configuración.

### Pila_de_Kernel
Ahora podemos cargar una Pila de Kernel modo protegido. Antes de cargarla hacemos una limpieza de los 4K que destinaremos a dicha Pila.

### Perisfericos
Ahora configuro los perisfericos que una vez habilitadas las interrupciones comenzarán a interruptir el código de forma asincrónica accediendo a los Handlers de interrupción. Los perisfericos son:
- El PIC que termine usar 3 timers del procesador, yo configuro solamente el primero que usaré de base de tiempo para la conmutación de tareas.
- El teclado que interrumpirá cuando una tecla fuera precionada o soltada proporcionado el ScanCode o el BreakCode de cada tecla.

Esta etapa se puede hacer en cualquier momento antes de habilitar las interrupciones.

### Memcopy_a_Ram
A partir de acá se realizan los memcopy, es decir que se copian a RAM las difentes partes del Kernel y las tareas que fueron compiladas en ROM. Esta operación es posible gracias a que el *Linker Script* nos permite organizar la memoria tanto de ROM como de RAM, así que se copiaran a RAM:
- Los handlers de Interrupción y Excepción
- El propio código de Kernel 
- La sección DATA del Kernel, la sección BSS no se copia ya que no fue compilada en ROM (nobits)
- La Systable que contiene la GDT.
- La tarea 1 y su sección Data
- La tarea 2 y su sección Data
- La tarea 3 y su sección Data

No se puede saltar a RAM hasta no haber terminado esta etapa ya que el programa debe ejecutarse desde RAM debido a que la velocidad de accesibilidad de la RAM es mucho mayor que la de la ROM. A su vez, la memoria no volatil no es *cacheable*, una vez en RAM habría que habilitar el cache.

Una vez pasada a la RAM todas las secciones de ejecución en runtime puede volver a cargarse la GDT, pero aquella que fue copiada en RAM, recordemos que la GDT fue cargada para pasar a modo protegido pero desde ROM. Esta acción la realizo luego de activar paginación pero podría hacerse en este punto.

### Paginación
Hay 6 grandes grupos de paginas que deben ser paginadas, la primera e indiscutible es la ROM, ya que cuando se active paginación si no está paginada la ROM habrá un bello page fault, no es necesario explicar porque. También es necesario que se paginen las Pilas que el sistema estará usando en modo Kernel, la cuales son 4, una de kernel y  otras de tareas de privilegio de kernel, a su vez estarán las estructuras de paginación de cada tarea y por ultimo debe estar paginado el kernel junto con los handlers de interrupciones.

Para ordenar la explicación dividiré esto en 4 partes, la estructura de paginación del Kernel, la estructura de paginación de la Tarea1, la de la tarea 2 y 3.

#### Estructura_de_Paginación_Kernel
|            Pagina           |     Dirección Lineal/Fisica      | Atributo Efectivo |
|-----------------------------|----------------------------------|-------------------|
|         16K para ROM        |  0xFFFF 0000 (identity mapping)  |  PAG_RW_W_US_SUP  |
|        Pila de Kernel       |  0x1FF0 8000 (identity mapping)  |  PAG_RW_W_US_SUP  |
| Pila de Nucleo de la Tarea1 |  0x1FFF 7000 (identity mapping)  |  PAG_RW_W_US_SUP  |
| Pila de Nucleo de la Tarea1 |  0x1FFF 6000 (identity mapping)  |  PAG_RW_W_US_SUP  |
| Pila de Nucleo de la Tarea1 |  0x1FFF 5000 (identity mapping)  |  PAG_RW_W_US_SUP  |
|      Pila de la Tarea1      |  0x1FFF F000 (identity mapping)  |  PAG_RW_W_US_SUP  |
|      Pila de la Tarea2      |  0x1FFF E000 (identity mapping)  |  PAG_RW_W_US_SUP  |
|      Pila de la Tarea3      |  0x1FFF D000 (identity mapping)  |  PAG_RW_W_US_SUP  |
|    Handlers de INT & EXC    |  0x0000 0000 (identity mapping)  |  PAG_RW_W_US_SUP  |
|         RAM de Video        |LIN=0x0001 0000 -> PHY=0x000B 8000|  PAG_RW_W_US_SUP  |
|           Systables         |  0x0010 0000 (identity mapping)  |  PAG_RW_W_US_SUP  |
|       Tablas de Paginas     |  0x0011 0000 (identity mapping)  |  PAG_RW_W_US_SUP  |
|            Kernel           |LIN=0x0120 0000 -> PHY=0x0020 0000|  PAG_RW_W_US_SUP  |
|          DatosKernel        |LIN=0x0120 2000 -> PHY=0x0020 2000|  PAG_RW_W_US_SUP  |
|            BSSKernel        |LIN=0x0120 3000 -> PHY=0x0020 3000|  PAG_RW_W_US_SUP  |
|        Tabla de Digitos     |LIN=0x0121 0000 -> PHY=0x0021 0000|  PAG_RW_W_US_SUP  |
|            Tarea 1          |LIN=0x0130 0000 -> PHY=0x0030 0000|  PAG_RW_W_US_SUP  |
|         Datos  Tarea 1      |LIN=0x0130 1000 -> PHY=0x0030 1000|  PAG_RW_W_US_SUP  |
|          BSS Tarea 1        |LIN=0x0130 2000 -> PHY=0x0030 2000|  PAG_RW_W_US_SUP  |
|            Tarea 2          |LIN=0x0131 0000 -> PHY=0x0031 0000|  PAG_RW_W_US_SUP  |
|         Datos  Tarea 2      |LIN=0x0131 1000 -> PHY=0x0031 1000|  PAG_RW_W_US_SUP  |
|          BSS Tarea 2        |LIN=0x0131 2000 -> PHY=0x0031 2000|  PAG_RW_W_US_SUP  |
|            Tarea 3          |LIN=0x0132 0000 -> PHY=0x0032 0000|  PAG_RW_W_US_SUP  |
|        Datos  Tarea 3       |LIN=0x0132 1000 -> PHY=0x0032 1000|  PAG_RW_W_US_SUP  |
|          BSS Tarea 3        |LIN=0x0132 2000 -> PHY=0x0032 2000|  PAG_RW_W_US_SUP  |
|             TSS             |  0x0140 0000 (identity mapping)  |  PAG_RW_W_US_SUP  |
CR0.WP = 0

#### Estructura_de_Paginación_Tarea1
|            Pagina           |     Dirección Lineal/Fisica      | Atributo Efectivo |
|-----------------------------|----------------------------------|-------------------|
|         Pila de Kernel      |  0x1FF0 8000 (identity mapping)  |  PAG_RW_W_US_SUP  |
| Pila de Nucleo de la Tarea1 |LIN=0x0071 4000 -> PHY=0x1FFF 7000|  PAG_RW_W_US_SUP  |
|        Pila de la Tarea1    |LIN=0x0071 3000 -> PHY=0x1FFF F000|  PAG_RW_W_US_USR  |
|    Handlers de INT & EXC    |  0x0000 0000 (identity mapping)  |  PAG_RW_W_US_SUP  |
|         RAM de Video        |LIN=0x0001 0000 -> PHY=0x000B 8000|  PAG_RW_W_US_SUP  |
|           Systables         |  0x0010 0000 (identity mapping)  |  PAG_RW_W_US_SUP  |
|            BSSKernel        |LIN=0x0120 3000 -> PHY=0x0020 3000|  PAG_RW_W_US_SUP  |
|        Tabla de Digitos     |LIN=0x0121 0000 -> PHY=0x0021 0000|  PAG_RW_W_US_SUP  |
|            Tarea 1          |LIN=0x0130 0000 -> PHY=0x0030 0000|  PAG_RW_W_US_USR  |
|          BSS Tarea 1        |LIN=0x0130 1000 -> PHY=0x0030 1000|  PAG_RW_W_US_USR  |
|         Datos  Tarea 1      |LIN=0x0130 2000 -> PHY=0x0030 2000|  PAG_RW_R_US_USR  |
|             TSS             |  0x0140 0000 (identity mapping)  |  PAG_RW_W_US_SUP  |
CR0.WP = 0

#### Estructura_de_Paginación_Tarea2
|            Pagina           |     Dirección Lineal/Fisica      | Atributo Efectivo |
|-----------------------------|----------------------------------|-------------------|
|         Pila de Kernel      |  0x1FF0 8000 (identity mapping)  |  PAG_RW_W_US_SUP  |
| Pila de Nucleo de la Tarea2 |LIN=0x0071 4000 -> PHY=0x1FFF 6000|  PAG_RW_W_US_SUP  |
|        Pila de la Tarea2    |LIN=0x0071 3000 -> PHY=0x1FFF E000|  PAG_RW_W_US_USR  |
|    Handlers de INT & EXC    |  0x0000 0000 (identity mapping)  |  PAG_RW_W_US_SUP  |
|         RAM de Video        |LIN=0x0001 0000 -> PHY=0x000B 8000|  PAG_RW_W_US_SUP  |
|           Systables         |  0x0010 0000 (identity mapping)  |  PAG_RW_W_US_SUP  |
|            BSSKernel        |LIN=0x0120 3000 -> PHY=0x0020 3000|  PAG_RW_W_US_SUP  |
|        Tabla de Digitos     |LIN=0x0121 0000 -> PHY=0x0021 0000|  PAG_RW_W_US_SUP  |
|            Tarea 2          |LIN=0x0131 0000 -> PHY=0x0031 0000|  PAG_RW_W_US_USR  |
|          BSS Tarea 2        |LIN=0x0131 1000 -> PHY=0x0031 1000|  PAG_RW_W_US_USR  |
|         Datos  Tarea 2      |LIN=0x0131 2000 -> PHY=0x0031 2000|  PAG_RW_R_US_USR  |
|             TSS             |  0x0140 0000 (identity mapping)  |  PAG_RW_W_US_SUP  |
CR0.WP = 0

#### Estructura_de_Paginación_Tarea3
|            Pagina           |     Dirección Lineal/Fisica      | Atributo Efectivo |
|-----------------------------|----------------------------------|-------------------|
|         Pila de Kernel      |  0x1FF0 8000 (identity mapping)  |  PAG_RW_W_US_SUP  |
| Pila de Nucleo de la Tarea3 |LIN=0x0071 4000 -> PHY=0x1FFF 5000|  PAG_RW_W_US_SUP  |
|        Pila de la Tarea3    |LIN=0x0071 3000 -> PHY=0x1FFF D000|  PAG_RW_W_US_USR  |
|    Handlers de INT & EXC    |  0x0000 0000 (identity mapping)  |  PAG_RW_W_US_SUP  |
|         RAM de Video        |LIN=0x0001 0000 -> PHY=0x000B 8000|  PAG_RW_W_US_SUP  |
|           Systables         |  0x0010 0000 (identity mapping)  |  PAG_RW_W_US_SUP  |
|            BSSKernel        |LIN=0x0120 3000 -> PHY=0x0020 3000|  PAG_RW_W_US_SUP  |
|            Tarea 3          |LIN=0x0133 0000 -> PHY=0x0033 0000|  PAG_RW_W_US_USR  |
|          BSS Tarea 3        |LIN=0x0133 2000 -> PHY=0x0033 2000|  PAG_RW_W_US_USR  |
|             TSS             |  0x0140 0000 (identity mapping)  |  PAG_RW_W_US_SUP  |
CR0.WP = 0

Se activa Paginación cargando el CR3 de Kernel y poniendo en 1 el CR0.PG.
Luego se carga el registro **GDTR** con el espacio de memoria donde fue cargada la GDT con la estructura GDT_lenght-1,GDT en RAM.

Por último imprimo por pantalla que la paginación está completa.

### Interrupciones
El vector de interrupciones se carga usando dos funciones a modo de mostrar que es independiente en que lenguaje está escrita la función. Ciertamente la escrita en ASM es mucho más corta y rápida que la implementada en C.
Las Excepciones son cargadas con la función implementada en C y las 3 interrupciones, timer, teclado y systemcall están implementadas en ASM.

Luego se carga el registro **IDTR** con el espacio de memoria donde fue cargada la IDT con la estructura IDT_lenght-1,IDT en RAM.

### TSS_init
Se inicializan las TSS "manuales" de la tarea 1,2 y 3. 
Se les pasa como parámetro el espacio de la TSS, el CR3 de la tarea, la pila de la tarea de nivel 11, la pila de kernel de nivel 00 y la dirección a la tarea.

Por otro lado, también se crea la TSS_Basica que tiene la estructura de TSS propuesta por intel, la cual el procesador utilizará para hacer el cambio de niveles de privilegios cuando ocurra una interrupción, o llamada a un callgate, en este caso no se utiliza.
Se le carga el CR3 de kernel, la pila de nucleo de tareas, y los selectores correspondientes.

Luego cuando haga el cambio de nivel de privilegio viniendo de una tarea X utilizará la pila de nucleo de dicha tarea.

Se carga el TR con el indice de la GDT en donde se encuentra el descriptor de la TSS_Basica.

Y si todo salió bien... Saltamos por fin a la RAM para ejecutar el programa principal.
El resto del analisis se realizará en los correspondientes Handlers de interrupciones ya que ellos se encargarán de ahora en más de controlar el sistema.

* * *
## Main
El salto al main es la primera vez que se empieza a ejecutar código desde RAM, de todas formas esta sección no es muy extensa, ya que, ni bien termine de imprimir en pantalla las distintas lineas que le darán al usuario indicaciónes de como usar el sistema habilitará las interrupciones y entrará en modo **HALT**.

El main es el programa principal el cual se dedica exclusivamente a no hacer nada, puesto que le entrega el control al Scheduler que será el encargado de planificar las tareas según corresponda a la **Política de Scheduler**.

El Scheduler tomará control del sistema por cada interrupción de Timer y administrará que tarea tiene las condiciones y requerimientos para planificarse, siendo la tarea IDLE, HALT o tarea3, según como se la quiera llamar la que estára la mayor parte del tiempo en ejecución.

* * *
## Handlers
### Timer-Scheduler
Al inicio del handler debido a que se desconoce previamente desde que instancia de programa interrumpió el timer (normalmente desde el procesador en estado HALT) pero en rigor se desconoce por la asincronicidad del evento, se pushean todos los registro de proposito general para que la manipulación del handler no afecte la operación que venia realizado el programa. 

En todos los casos que el handler de timer tome el control del programa se **seteará en 1 el bit CR0.TS indicando que se producirá un cambio de espacio de contexto**.

#### First_time
Al menos en una primer instancia se puede observar que la pila guarda el EIP del HALT del programa principal, el selector CS de kernel y los EFLAGS = 0x246. Esta situación no se volverá a dar, ya que, el Scheduler planificará por defecto la tarea3.

Si es la primera vez que el timer ingresa a la interrupción en lugar de guardar el contexto (halt del programa principal) procederá a cargar el estado de la tarea3 que es la de menor prioridad pero siempre READY.

Carga la variable *status_T3* y la carga en *status_tarea*. La variable *status_tarea* contendrá las direcciones de *status_T1*, *status_T2* o *status_T3* y estás en runtime indicarán si dicha tareas está IDLE, READY o RUNNING.

Luego de cargar en status_tarea quien va a planificarse, se carga el CR3 de la tarea3 y en EAX se carga el espacio de memoria de la TSS_T3.

A partir de acá arranca el proceso de load_context.

#### Load_Context
Estando EAX cargado con el espacio de memoria correspondiente a la TSS_TN a cargar.

Se pasan a cada registo los valores que tenían en la ejecución anterior, si es la primera vez, amanecerán en 0x0. El caso particular es el de los selectores.

Los selectores tanto de Código o Datos corresponderán al nivel de privilegio al que se desea saltar. 

Por ejemplo en la primer instancia se desea saltar a Tarea3 que es de privilegio 11, entonces los descriptores de código y datos que se carguen tendrán DPL = 11 y los selectores tendrán RPL=11. Si por el contrario el espacio de contexto anterior corresponde al del kernel debido a que en la planificación anterior de la tarea el procesador quedó en estado HALT mediante un SystemCall (servicio de kernel) los selectores que se cargarán serán que tienen RPL=00 y los correspondientes descriptores DPL=00 y se retornará al SystemCall correspondiente y este será el que luego retorne a la tarea cargando los selectores correspondientes. 
Es confuso, la mejor forma de verlo es con breakpoints, y tener un poco de fe.

Retomando la secuencia se hace el cambio de stack por el de la tareaN y se pushea en él SS3, ESP3, EFLAGS, CS3, EIP para que el IRET retorne al contexto de tarea anterior.

Justo antes de realizar el IRET se limpiará el PIC mandando el EOI, se incrementará el contador ticks para poder saber cada cuanto planificar la tarea, el super periodo es de 20ticks, planificandose cada 10 la tarea1, cada 20 la tarea2 y en todas las demás la tarea3 por ser la de menor privilegio y siempre READY.

#### Save_Context
Me parece interesante explicar esta sección a partir del ejemplo de la primera vez que se guarda un contexto, este es el caso de haber planificado la tare3 y que esta llamara al servicio del kernel HALT mediante INT80. Esto quiere decir que la interrupción del timer se hizo estando el procesador en modo kernel, de hecho, puntualmente en estado HALT pero el selector de código corresponde al kernel 0x08 apuntado al descriptor con DPL=00.
Para esclarecer, en esta instancia la pila de nucleo de la tarea3 se encuentra de la siguiente manera.
```
                | PiladN T3  |
                |------------|
0x0071 4FDB     | 0x0000069B | ^   <- EIP(SysCall)
0x0071 4FDF     |    0x08    | |   <- CS_Kernel
0x0071 4FE3     |    0x246   | |   <- EFLAGS
0x0071 4FE7     | 0x00713FFF | |   <- ESP
0x0071 4FEB     | 0x01320007 | |   <- EIP
0x0071 4FEF     |    0x1B    | |   <- CS3
0x0071 4FF3     |    0x202   | |   <- EFLAGS
0x0071 4FF7     | 0x00713FFF | |   <- ESP3
0x0071 4FFB     |    0x23    | |   <- SS3
```
Una vez comprendido el ejemplo de que pila es la que se usa cuando se interrumpe, que se almacena en el stack y de donde puede provenir, pasamos a detallar el proceso de guardado de contexto.

Se revisa el *status_tarea* quien tenia guardado que *status_TN* se había planficado último, en este caso status_tarea apuntará a *status_T3* entonces permitirá que se cargue el espacio de memoria destinado a guardar el contexto de la tarea3. Una vez cargado en la memoria cada uno de los registros de propósito general, pila que se está utilizando para retornar se procede a chequear quien debería ser planificado ahora.

#### Chequear
Aquí se revisa si las tareas 1,2 están READY (tienen los recursos de teclado disponibles) y si pueden pasar a RUNNING si los ticks lo permiten. 
Recordar que la tarea 1 se planifica cada 100mS (10 ticks) y la tarea2 cada 200ms (20 ticks). En cada tick se puede planificar una sola tarea y cuando esta termine se pone en estado HALT llamando a systemCall.
Si ninguna de las 2 tareas está en posición de ser planficada que planificará la tarea 3. 
Pasando a cargar su contexto.

#### Scheduler
La planificación de la tarea 1 se hace cada 100ms mientras que la tarea 2 se planifica cada 200ms.
La planificación de las mismas se realiza solo si las tareas tiene los recursos disponibles a pesar de que tengan tiempo de planificación asignado. Estos recursos son el buffer circular de teclado cargado (luego de un ENTER).

### Teclado
El teclado soporta el ingreso de números y las letras 'A', 'B', 'C', 'D', 'E', 'F' y de forma adicional la 'p' y la 'o'. Como la sumas que realizan las tareas 1 y 2 son hexadecimales los datos que se pueden ingresar por teclado también son hexadecimales. El caso de la 'p' y la 'o' es para provocar fallos intencionales en el sistema de paginación y de protección general respectivamente.

Si se presiona ENTER todos los digitos hexadecimales cargados en el buffer circular de teclado son guardados en la Tabla de Digitos, únicamente accesible desde nivel 00, por ello las tareas necesitan los servicios de Kernel llamando a SystemCall para saber que dice la memoria de digitos ingresados.

Cualquier otra tecla será ignorada.

### #NM-SIMD_SaveContext
Guarda y carga los MM0 al MM3 es decir los primero 4 registros MMX en posiciones de memorias reservadas para manipulación en nivel 00.
Esto se realiza al producirse una excepción de tipo 7 debido a que el procesador quizo ejecutar una instrucción SIMD con CR0.TS activo.
Lo primero que hace el Handler es bajar el CR0.TS y chequear cual fue la última tarea en utilizar una instrucción SIMD, usando una variable global que se setea con el CR3 de la última tarea que accedió. De esta manera salva los registros para la tarea que accedió la ultima vez y carga los registros de la tarea que provocó el handler de interrupción.

El cambio de contexto de SIMD solo se realizar si más de una tarea utiliza la FPU/SSE ya que este proceso lleva un tiempo importante realizalo. A menos que sea necesario hacer el cambio de contexto SIMD los registro SIMD no se guardan. El caso en el que esto sucedería es cuando solo 1 tarea en todo el sistema usa SIMD.

PD: Este sistema no guarda todos los registros SIMD ya que solo utiliza 2 de los mismos, para mostrar el procedimiento de guardado manual se procede a guardar los primeros 4 MMX de las tareas 1 y 2.

### Page_Fault
Si se presiona la tecla 'p' entonces se producirá un fallo intensional de página en nivel de Kernel ya que el mismo querrá acceder a la página 0x1000 la cual no se encuentra paginada. 

Precionando continuar [c] en la consola de bochs o en el entorno gráfico del simulador se procederá a paginar esta nueva pagina y se vuelve a precionar 'p' este no ocacionará error de página ya que ahora la posición 0x1000 si se encuentra paginada.

### General_Protection_Fault
Si se presiona la tecla 'o' hay un fallo general de protección por intentar cargar '1' en bits reservados del CR4. No se puede recuperar del error. Se deberá reiniciar el sistema.

* * *
## Tareas
### Tarea_1
#### Suma1
Suma segun las posiciones ingresadas con la suma acumulada (no es una suma saturada)
ej: "Input: 12345678" -> Suma1: 0x 01 02 03 04 05 06 07 08
la suma la acumula entonces si luego se ingresa
ej: "Input: 10000000" -> Suma1: 0x 02 02 03 04 05 06 07 08

### Tarea_2
#### Suma2
Suma segun las posiciones ingresadas, siendo una suma hexadecimal de 4 digitos
del quinto  digito  al octavo forman otra palabra de 4 digitos hexadecimal.
ej: "Input: 12345678" -> Suma2: 0x 06 08 0A 0C (0x1234+0x5678)

### Tarea_3
La tarea3, tarea IDLE o tareaHLT es la tarea que es planificada cuando ningún otra tiene los recursos disponibles para planificarse. Esto quiere decir que la tarea IDLE siempre está READY para planificarse pero su prioridad es la mínima posible.

Habiendo dos tareas en condición de ser planficadas, es decir su  estado es READY, la tarea IDLE será aquella que no se planifique debido a que la prioridad de esta es mínima. En el caso de este sistema la cualidad de prioridad mínima se da cuando la estructura condicional de planificación no puede planificar a nadie la salida por defualt es la tarea IDLE.

WARNING: Si IF=0 y usas HLT no podes salir de ahí sin resetear.

* * *
## Anexo
### Bochs
* [s] Step
* [c] Continue
* [F2] Muestra pila
* [F7] Muestra memoria lineal en una posición especificada. Si esa porción de memoria no está paginada tira error. 
* [regs] Muestra los registros de propósito general y EFLAGS
* [sreg] Muestra la configuración de los Segmentos, GDTR, IDTR, LDTR y TR
* [info gdt] Muestra la GDT
* [info idt] Muestra el vector de interrupciones
* [info tab] Muestra la estructura de paginación para el CR3 que esté cargado
* [page 0xNNNNNNNN] Indica la DTE y la PTE de dicha página y si está presente

### Listing
Los archivos listing muestran el código, junto con el OpCode correspondientes, también muestra la posición de memoria en la que está dichos OpCodes.
Ejemplo de como se ve un archivo listing, caso particular de reset.lst 
```
0000 0000   90  <rept>
0000 0FF0   FA  CLI
0000 0FF1   EBFD
0000 0FF3   F4  HTL
0000 0FF4   EBFD 
0000 FFF6   90 <rept>
```
Es muy útil en los comienzos pero luego cuando tenes varios archivos la memoria no está organizada, porque se hace en base a los archivos .asm y no del compilado .bin que luego ejecuta el Bochs.

### LinkerScript
El linker Script compila diferentes objetos reubicables (archivos .elf de nuestro .asm) y objetos encapsulados en librerías soportados por el standard BFD "binary file descriptor" (en nuestro caso no usamos librerías) para construir un archivo que contenga el código y los datos del programa ejecutable, más un encabezado con la información que el compilador necesita para construir su imagen en memoria (.bin).
Los achivos reubicables son linkeados en función del script definido en SECTIONS.

El compilador GCC llama nativamente a un linkerScript, de esta manera el compilador compila y linkea archivos objeto. En el sistema que estamos estructurando usaremos un linker escrito por nosotros y le pasaremos los archivos .elf generados con GCC o NASM en función del origen del archivo fuente.

Como se menciona anteriormente los archivos objeto tanto los reubicables como los encapsulados siguen el standard BFD, en el cual, cada objeto tiene un encabezado donde contiene información descriptiva, una cantidad de secciones (variable), cada una con su nombre, atributos y bloques de dato/codigo, una tabla de símbolos, entrada de relocación, etc.

Estas caracteristicas de los archivos soportados por BDF pueden ser leidas usando los programas **READELF** y **OBJDUMP**.

```
SECTIONS 
{
    . = 0xFF000;                    /*location counter del linker (es como $ para NASM)*/
    .data : {*(.data1 .data2)}      /*Junta los .dataN en la sección de salida .data*/
    . = 0xFFFF0;
    .text : {*(.resetVector)}
}
```

```
    reset_LMA   = 0xFFFFFFF0;
    ROM_LMA     = 0xFFFFF000;
SECTIONS 
{
    .resetVector: AT (reset_LMA) : {*(.resetVector)}        /*En estos casos indico en donde*/
    .ROM_init: AT (ROM_LMA) : {*(.ROM_init)}                /*LMA=VMA*/
}
```
```
    __ISR_VMA     = 0x00000000;
    __ISR_LMA     = 0xFFFF5000;
MEMORY
{
    ram (!x) : ORIGIN = 0x00000000, LENGTH = 0xFFFF0000     /* 2^32 (4GB) 2^16 (64KB) */
    rom (rx) : ORIGIN = 0xFFFF0000, LENGTH = 0xFFFF
}
SECTIONS 
{
    .ISR __ISR_VMA :
        AT( __ISR_LMA )
            {*(.handlers_32);} > ram                        /* Esta sección no  puede escaparse de MEMORY ram */
    __ISR_size = SIZEOF(.ISR);
}
```

#### Secciones
Loadable: El contenido de la secciónse carga tal como está definido en la memoria (ej: codigo)
Allocatble: Si bien no tiene un contenido especifico debe reservarse memoria para esta sección (ej: BSS)

#### Direcciones
VMA: Dir lineal que tiene una sección en el momento en que se va a ejecutar el archivo de salida.
LMA: Dir lineal en quela secicón se cargará efectivamente en memoria.


### READELF
Permit ver archivos .elf

### OBJDUMP
Permite ver archivos .elf
```
    objdump -t archivo.o
    nm archivo.o            <- No está chequeado
```
```
    objdump -s archivo.elf  <- Muestr secciones (no chequeado)
```

### HEXDUMP
Permite ver el archivo binario del .bin

### OKTETA
Permite ver archivos .bin

* * *
## Uso de pilas de Nucleo y Pila de Kernel
En la TSS_BASICA coloco la Pila de Nucleo, dado que en cada Tarea la dirección lineal es la misma cuando la TSS_BASICA hace el salto de privilegio probocado por una interrupción o excepción utiliza la dirección lineal 0x00714FFF.
Por ejemplo, si se produce un evento en el ambito de la tarea3, la TSS_BASICA al realizar el salto de privilegio lo hará usando la Pila de Nucleo de Tarea3.
Cuando se realiza el taskSwitch la Pila de Kernel se utiliza solo en operaciones de Kernel, puesto esto a cada tarea en su TSS_HARDCODE se le indica la Pila de Kernel no la de Nucleo correspondiente.
