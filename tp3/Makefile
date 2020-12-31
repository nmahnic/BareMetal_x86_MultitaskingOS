.PHONY:clean code bless bochs

LINKER_OBJECTS=obj/init16.o obj/init32.o obj/reset.o
LINKER_SCRIPTS=linker.ld
LINKER_DEPENDENCIES= init16 init32 reset
LINKER_ENTRY_POINT= Reset

OUTPUT_BIN=bin/mibios.bin

all: $(LINKER_DEPENDENCIES)
	@echo Generando $(OUTPUT_BIN)
	mkdir -p obj

	ld -z max-page-size=0x01000 --oformat=binary -m elf_i386 -T $(LINKER_SCRIPTS) -e $(LINKER_ENTRY_POINT) $(LINKER_OBJECTS) -o $(OUTPUT_BIN)


init16: src/init16.asm
	@echo Generando $@.asm...
	mkdir -p bin
	mkdir -p sup
	mkdir -p obj
	
	nasm -f elf32 src/$@.asm -o obj/$@.o -l sup/$@.lst

init32: src/init32.asm
	@echo Generando $@.asm...
	mkdir -p bin
	mkdir -p sup
	mkdir -p obj
	
	nasm -f elf32 src/$@.asm -o obj/$@.o -l sup/$@.lst

reset: src/reset.asm 										#Si ese archivo se modifica se ejecuta la regla reset
	@echo Generando $@.asm...
	mkdir -p bin
	mkdir -p sup
	mkdir -p obj
	
	nasm -f elf32 src/$@.asm -o obj/$@.o -l sup/$@.lst

bochs:
	bochs -qf bochsrc

clean:
	rm -R bin
	rm -R obj
	rm -R sup
	rm *ini

bless:
	bless $(OUTPUT_BIN)

code: 													#Abre el VSCode con toda las carpetas
	code .