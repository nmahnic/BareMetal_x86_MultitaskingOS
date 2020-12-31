|Alumno|TP|
| ------------- | ------------- |
| **Nicolás MAHNIC** | **TP 14** |

# SIMD
## Para realizar dos sumas diferentes con los mismos datos utilicé los siguientes algoritmos:
### Suma1
Suma segun las posiciones ingresadas con la suma acumulada (no es una suma saturada)
ej: "Input: 12345678" -> Suma1: 0x 01 02 03 04 05 06 07 08
la suma la acumula entonces si luego se ingresa
ej: "Input: 10000000" -> Suma1: 0x 02 02 03 04 05 06 07 08
### Suma2
Suma segun las posiciones ingresadas, siendo una suma hexadecimal de 4 digitos
del quinto  digito  al octavo forman otra palabra de 4 digitos hexadecimal.
ej: "Input: 12345678" -> Suma1: 0x 0608 0A0C (0x1234+0x5678)