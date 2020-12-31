.PHONY:clean code bless bochs

LINKER_SCRIPTS=linker.ld
ALL_DEPENDENCIES =  mibios.elf mibios.bin
OBJ_DEPENDENCIES =  init16 init32 reset a20 main sys_tables functions_rom functions handlers tareasASM data bss functionsA
LINKER_SCRIPTS=linker.ld
LINKER_ENTRY_POINT= reset				#etiqueta de ingreso al programa 

OUTPUT_BIN=bin/mibios.bin

AFLAGS		= -f elf32
CFLAGS		= -c -m32 -fno-stack-protector -fno-asynchronous-unwind-tables -Wall -fno-PIC
OBJSinit	= obj/init32.elf obj/reset.elf obj/sys_tables.elf obj/a20.elf obj/init16.elf obj/handlers.elf
OBJSmain	= obj/main.elf obj/functions_rom.elf obj/functions.elf obj/tareasASM.elf obj/data.elf obj/bss.elf obj/functionsA.elf
ODFLAGS		= -CprsSx --prefix-addresses


all: $(ALL_DEPENDENCIES)
	mkdir -p doc
	@echo Generando $(OUTPUT_BIN)
	hexdump -C $(OUTPUT_BIN) > doc/mibios_hexdump.txt
	objdump $(ODFLAGS) obj/mibios.elf > doc/mibios_objdump.txt
	readelf -a obj/mibios.elf > doc/mibios_readelf.txt

	#hexdump -C obj/functions_rom.elf > doc/functions_rom_hexdump.txt
	#objdump $(ODFLAGS) obj/functions_rom.elf > doc/functions_rom_objdump.txt
	#readelf -a obj/functions_rom.elf > doc/functions_rom_readelf.txt



mibios.bin : $(OBJ_DEPENDENCIES)
	ld -z max-page-size=0x01000 --oformat=binary -m elf_i386 -T $(LINKER_SCRIPTS) -e $(LINKER_ENTRY_POINT) $(OBJSmain) $(OBJSinit) -o $(OUTPUT_BIN)

mibios.elf : $(OBJ_DEPENDENCIES)
	ld -z max-page-size=0x01000 -m elf_i386 -T $(LINKER_SCRIPTS) $(OBJSmain) $(OBJSinit) -o obj/$@


a20: src/a20.asm
	@echo Generando $@.asm...

	nasm $(AFLAGS) src/$@.asm -o obj/$@.elf -l sup/$@.lst

init16: src/init16.asm
	make clean
	@echo Generando $@.asm...
	mkdir -p bin
	mkdir -p sup
	mkdir -p obj
	
	nasm $(AFLAGS) src/$@.asm -o obj/$@.elf -l sup/$@.lst

init32: src/init32.asm
	@echo Generando $@.asm...
	
	nasm $(AFLAGS) src/$@.asm -o obj/$@.elf -l sup/$@.lst

main: src/main.asm
	@echo Generando $@.asm...
	
	nasm $(AFLAGS) src/$@.asm -o obj/$@.elf -l sup/$@.lst

reset: src/reset.asm 				#Si el archivo reset.asm se modifica se ejecuta la regla reset
	@echo Generando $@.asm...j
	
	nasm $(AFLAGS) src/$@.asm -o obj/$@.elf -l sup/$@.lst

sys_tables: src/sys_tables.asm
	@echo Generando $@.asm...
	
	nasm $(AFLAGS) src/$@.asm -o obj/$@.elf -l sup/$@.lst


handlers: src/handlers.asm
	@echo Generando $@.asm...
	
	nasm $(AFLAGS) src/$@.asm -o obj/$@.elf -l sup/$@.lst

tareasASM: src/tareasASM.asm
	@echo Generando $@.asm...
	
	nasm $(AFLAGS) src/$@.asm -o obj/$@.elf -l sup/$@.lst

data: src/data.asm
	@echo Generando $@.asm...
	
	nasm $(AFLAGS) src/$@.asm -o obj/$@.elf -l sup/$@.lst

bss: src/bss.asm
	@echo Generando $@.asm...
	
	nasm $(AFLAGS) src/$@.asm -o obj/$@.elf -l sup/$@.lst

functionsA: src/functionsA.asm
	@echo Generando $@.asm...
	
	nasm $(AFLAGS) src/$@.asm -o obj/$@.elf -l sup/$@.lst

functions_rom: src/functions_rom.c
	@echo Generando $@.c...
	
	gcc $(CFLAGS) src/$@.c -o obj/$@.elf

functions: src/functions.c
	@echo Generando $@.c...
	
	gcc $(CFLAGS) src/$@.c -o obj/$@.elf

bochs:
	make all
	bochs -qf bochsrc

clean:
	rm -R -f bin
	rm -R -f obj
	rm -R -f sup
	rm -R -f doc
	rm -f *ini

bless:
	bless $(OUTPUT_BIN)

code: 													#Abre el VSCode con toda las carpetas
	code .