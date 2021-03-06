.PHONY : clean

BINPATH =./bin/
DOCPATH =./doc/
INCPATH =./inc/
LIBPATH =./lib/
SRCPATH =./src/
SUPPATH =./sup/

AC					= nasm
CC					= gcc
AFLAGS				= -f elf32
CFLAGS				= -c -m32 -fno-stack-protector -fno-asynchronous-unwind-tables -Wall -fno-PIC
# -f elf64
LDFLAGS				= -z max-page-size=0x01000 --oformat=binary -m elf_i386
# -m elf_x86_64 -s
LDSCRIPT			= linker.ld
ODFLAGS				= -CprsSx --prefix-addresses
OBJS				= $(BINPATH)init32.elf $(BINPATH)reset.elf $(BINPATH)sys_tables.elf $(BINPATH)a20.elf $(BINPATH)init16.elf $(BINPATH)main.elf $(BINPATH)functions_rom.elf
SRC_NAME = mibios  

all: $(BINPATH)$(SRC_NAME).bin $(BINPATH)$(SRC_NAME).elf
	mkdir -p doc
	hexdump -C $(BINPATH)$(SRC_NAME).bin > $(DOCPATH)$(SRC_NAME)_hexdump.txt
	objdump $(ODFLAGS) $(BINPATH)$(SRC_NAME).elf > $(DOCPATH)$(SRC_NAME)_objdump.txt
	readelf -a $(BINPATH)$(SRC_NAME).elf > $(DOCPATH)$(SRC_NAME)_readelf.txt

$(BINPATH)$(SRC_NAME).bin : $(OBJS)
	ld $(LDFLAGS) -T $(LDSCRIPT) $(OBJS) -o $@ -Map $(SRC_NAME).Map

$(BINPATH)$(SRC_NAME).elf : $(OBJS)
	ld -z max-page-size=0x01000 -m elf_i386 -T $(LDSCRIPT) $(OBJS) -o $@

$(BINPATH)a20.elf : $(SRCPATH)a20.asm
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst

$(BINPATH)functions_rom.elf : $(SRCPATH)functions_rom.c
	mkdir -p bin
	$(CC) $(CFLAGS) $< -o $@

$(BINPATH)init16.elf : $(SRCPATH)init16.asm
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst

$(BINPATH)init32.elf : $(SRCPATH)init32.asm
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst

$(BINPATH)main.elf : $(SRCPATH)main.asm
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst

$(BINPATH)reset.elf : $(SRCPATH)reset.asm
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst

$(BINPATH)sys_tables.elf : $(SRCPATH)sys_tables.asm
	mkdir -p bin
	$(AC) $(AFLAGS) $< -o $@ -l $@.lst

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