USE16
SECTION .resetVector

GLOBAL reset
EXTERN start16

reset:                  ; 0xFFFFFFF0 // linea 3 del linker y aparece tambien en LINKER_ENTRY_POINT
    cli                 ; apaga las interrupciones
    cld                 ; clear direction
    jmp start16         ; salta al archivo inict16.asm a start16

;********* HALTED*******;
halted:                 ; si no salta (no debería pasar) se haltea el procesador
    hlt
    jmp halted

   ; align 16           ; no es necesario ya que en el linker.ld 
                        ; en la linea 80 se remplaza esta instrucción.
end: