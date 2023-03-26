BUILD_DIR = ./build
SRC_DIR = ./src
SCRIPT_DIR = ./script
BOCHS_DIR = ./bochs
MOUNT_DIR = ./hddir
ENTRY_POINT = 0x200000
CC = gcc
AS = nasm
LD = ld
LIB = -l src/
AFLAGS = -f elf32
CFLAGS = -Wall $(LIB) -m32 -c -fno-stack-protector -W -Wstrict-prototypes \
		 		 -Wmissing-prototypes -fno-builtin 

LDFLAGS = -m elf_i386 -Ttext $(ENTRY_POINT) -e _start -Map $(BUILD_DIR)/kernel.map

OBJS = $(BUILD_DIR)/boot.o $(BUILD_DIR)/print.o $(BUILD_DIR)/stdio.o $(BUILD_DIR)/main.o $(BUILD_DIR)/string.o $(BUILD_DIR)/gdt.o

#$(BUILD_DIR)/boot.o: $(SRC_DIR)/boot.s
#	$(AS) $(AFLAGS) $< -o $@ 

$(BUILD_DIR)/boot.o: $(SRC_DIR)/boot.S $(SRC_DIR)/multiboot2.h
	$(CC) $(CFLAGS) $< -o $@ 

$(BUILD_DIR)/gdt.o: $(SRC_DIR)/gdt.s
	$(AS) $(AFLAGS) $< -o $@ 

$(BUILD_DIR)/print.o: $(SRC_DIR)/print.s
	$(AS) $(AFLAGS) $< -o $@ 

$(BUILD_DIR)/stdio.o: $(SRC_DIR)/stdio.c $(SRC_DIR)/stdio.h $(SRC_DIR)/print.h $(SRC_DIR)/stdint.h $(SRC_DIR)/string.h
	$(CC) $(CFLAGS) $< -o $@ 

$(BUILD_DIR)/string.o: $(SRC_DIR)/string.c $(SRC_DIR)/string.h $(SRC_DIR)/stdint.h
	$(CC) $(CFLAGS) $< -o $@ 

$(BUILD_DIR)/main.o: $(SRC_DIR)/main.c $(SRC_DIR)/stdio.h $(SRC_DIR)/print.h $(SRC_DIR)/stdint.h
	$(CC) $(CFLAGS) $< -o $@ 

$(BUILD_DIR)/runkernel.bin: $(OBJS)
	$(LD) $(LDFLAGS) $^ -o $@

build_dir:
	mkdir build

build: build_dir $(BUILD_DIR)/runkernel.bin

install:
	$(SCRIPT_DIR)/format_hd.sh $(BUILD_DIR)/runkernel.bin ./grub.cfg ./grub $(BOCHS_DIR) $(MOUNT_DIR)
run:
	bochs -f ./bochs/bochsrc.disk

all: build install run

clean:
	rm -rf $(BUILD_DIR)
	rm -rf hd80M.img
.PHONY: runkernel.bin clean install run
