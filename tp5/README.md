|Alumno|TP|
| ------------- | ------------- |
| **Nicolás MAHNIC** | **TP 5** |

# Modo Protegido 32 bits  
## Consigna
En base al ejercicio anterior adecuarlo para que el mismo se ejecute en modo protegido 32bits. 
1. Crear una estructura GDT mínima con modelo de segmentación FLAT
2. En la zona denominada Núcleo solo debe copiarse código.
3. Definir una pila dentro del segmento de datos e inicializar el par de registros SS:ESP adecuadamente. 
Realice la definición de forma dinámica de modo que pueda modificarse su tamaño y ubicación de manera simple.

El mapa de memoria propuesto

|**Sección**|**Dirección Inicial**|
| ----- | --------------- |
|Rutinas|0x00000000|
|Nucleo|0x00200000|
|Pila|0x1FF08000|
|Secuencia inicialización ROM|0xFFFF0000|
|Vector de Reset|0xFFFFFFF0|

## Objetivos Conceptuales
1. Comprender los requerimientos necesarios para que un programa pueda ejecutarse en modo protegido.
2. Identificar todos los registros y datos que utiliza el procesador para acceder a cada instrucción de código, dato y pila.
3. Analizar el esquema de direccionamiento entre modo protegido y real, identificando diferencias y similitudes
4. Comprender el significado y la implicancia de cada campo de las tablas de descriptores y los mecanismos de protección que activan.

### Condiciones Generales
A partir de este punto la guía se recomienda fuertemente plantear el ejercicio con el siguiente esquema de ficheros:
- **Makefile o make.sh:** comando necesarios para construir el binario
- **linker.lds:** script para el linker
- **bochs.cfg:** configuración utilizada para el Bochs en cada ejercicio
- **init.s:** solo el código necesario para inicializar al procesador en modo protegido y en ejercicios posteriores la paginación.
- **main.s:** funcionalidad solicitada en cada ejercicio
- **functions.s:** funciones auxiliares y/o frecuentemente implementadas en ensamblador
- **functions.c:** funciones auxiliares y/o frecuentemente implementadas en C
- **sys_tables.s:** tablas de sistema.