|Alumno|TP|
| ------------- | ------------- |
| **Nicolás MAHNIC** | **TP 3** |

# Inicialización Básica utilizando solo Assembler con acceso a 4GB
## Consigna
Activar el mecanismo conocido como **A20 GATE** para acceder al mapa completo de memoria
del procesador en modo real.

Adicionalmente agregar el código necesario a fin de que el programa pueda:
1. Copiarse a sí mismo en la dirección 0x00000000 y ejecutarse desde dicha ubicación
2. Copiarse a 0x00300000 y finalizar estableciendo al procesador en estado **halted**
en forma permanente
3. Establecer la pila en 0x1FFFA000


## Objetivos Conceptuales
1. Familiarizarse con el ASM y las herramientas asociadas (NASM)
2. Familiarizarse con las herramientas de depuración provistas por el Bochs.
3. Comprender el mapa de memoria de la PC y las restricciones historicas.
4. Identificar todos los registros y datos que utiliza el procesador para acceder
a cada instrucción de código, datos y pila
