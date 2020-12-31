|Alumno|TP|
| ------------- | ------------- |
| **Nicolás MAHNIC** | **TP 2** |

# Inicialización Básica utilizando solo Assembler con acceso a 1MB
## Consigna
Escribir un programa que se ejecute en una ROM de 64kB y permita copiarse 
a si mismo en cualquier zona de memoria. A tal fin se deberá implementar la funcion

`void *td3_memcopy(void *destino, const *origen, unsigned int num_bytes);`

Para validar el correcto funcionamiento del programa, el mismo deberá copiarse en
las direcciones indicadas a continuación y mediante Bochs verificar que la memoria
se haya escrito correctamente.
 1. 0x000000000
 2. 0x0000F0000

## Objetivos Conceptuales
1. Familiarizarse con el ASM y las herramientas asociadas (NASM)
2. Familiarizarse con las herramientas de depuración provistas por el Bochs.
3. Comprender el mapa de memoria del procesador.
4. Identificar todos los registros y datos que utiliza el procesador para acceder
a cada instrucción de código y datos 
