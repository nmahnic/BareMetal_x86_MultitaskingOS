|Alumno|TP|
| ------------- | ------------- |
| **Nicolás MAHNIC** | **TP 4** |

# Inicialización Básica utilizando el linker
## Consigna
Modificar el código del ejercicio anterior para satisfacer los siguientes requerimientos:
1. El programa debe siturarse al inicio de la ROM (0xFFFF0000)
2. Copiarse y ejecutarse en la siguientes direcciones
    - 0x00000000
    - 0x00100000
    - Dirección a elección. En esta última debe finalizar la ejecución.

El mapa de memoria propuesto

|**Sección**|**Dirección Inicial**|
| ----- | --------------- |
|Binario copiado 1|0x00000000|
|Binario copiado 2|0x00100000|
|Binario copiado 3|0x00200000|
|Pila|0x1FF08000|
|Secuencia inicialización ROM|0xFFFF0000|
|Vector de Reset|0xFFFFFFF0|

## Objetivos Conceptuales
1. Familiarizarse con el ASM y las herramientas asociadas (NASM).
2. Familiarizarse con el 'linker', su lenguaje de 'script' y las herramientas asociadas (ld).
3. Identificar todos los registros y datos que utiliza el procesador para acceder
a cada instrucción de código, datos y pila

## Condiciones Generales
A partir de este punto la guía se recomienda fuertemente plantear el ejercicio con el siguiente esquema de ficheros:
- **Makefile o make.sh:** comando necesarios para construir el binario
- **linker.lds:** script para el linker
- **bochs.cfg:** configuración utilizada para el Bochs en cada ejercicio
- **init.s:** solo el código necesario para inicializar al procesador en modo protegido y en ejercicios posteriores la paginación.
- **main.s:** funcionalidad solicitada en cada ejercicio
- **functions.s:** funciones auxiliares y/o frecuentemente implementadas en ensamblador
- **functions.c:** funciones auxiliares y/o frecuentemente implementadas en C
- **sys_tables.s:** tablas de sistema.