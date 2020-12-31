|Alumno|TP|
| ------------- | ------------- |
| **Nicolás MAHNIC** | **TP 6** |

# Teclado por Polling  
## Consigna
Modificar el ejercicio anterior implementando las siguientes funcionalidades
1. Almacenar en una tabla de 64KB las teclas presionadas que corresponden a dígitos decimales. A tal fin se debe realizar una rutina que encueste el buffer de teclado (dirección de E/S 0x60 datos y 0x64 estado/comado) en forma periódica. Al llegar al final de la tabla se sobreciben los valores iniciales.
2. Al presionar "F" el programa finaliza estableciendo al procesador en estado **halted** en forma permanente.
3. Establezca todos los datos del programa en Datos

El mapa de memoria propuesto

|**Sección**|**Dirección Inicial**|
| ----- | --------------- |
|Rutina de teclado|0x00000000|
|Nucleo|0x00200000|
|Tabla de dígitos|0x00210000|
|Datos|0x00202000|
|Pila|0x1FF08000|
|Secuencia inicialización ROM|0xFFFF0000|
|Vector de Reset|0xFFFFFFF0|

## Objetivos Conceptuales
1. Identificar el esquema de direccionamiento de los perisfericos (E/S, Memoria).
