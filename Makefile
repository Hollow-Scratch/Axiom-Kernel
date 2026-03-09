ARCH := x86_64

SRC_DIR := src
ASM_SRC_DIR := src/impl/$(ARCH)
TARGETS_DIR := targets/$(ARCH)
BUILD_DIR := build/$(ARCH)
DIST_DIR := dist/$(ARCH)
ISO_DIR := $(TARGETS_DIR)/iso
ISO_BOOT_DIR := $(ISO_DIR)/boot

LINKER := $(TARGETS_DIR)/linker.ld
GRUB_CFG := $(ISO_DIR)/boot/grub/grub.cfg

NASM := nasm
NASMFLAGS := -f elf64
CC := x86_64-elf-gcc
CPPFLAGS := -I$(SRC_DIR) -I$(SRC_DIR)/intf -I$(SRC_DIR)/impl/intf
CFLAGS := -ffreestanding -m64 -nostdlib -fno-stack-protector -Wall -Wextra
LD := x86_64-elf-ld
LDFLAGS := -n
GRUB_MKRESCUE := grub-mkrescue
QEMU := qemu-system-x86_64

ASM_SOURCES := $(shell find "$(ASM_SRC_DIR)" -type f -name '*.asm')
C_SOURCES := $(shell find "$(SRC_DIR)" -type f -name '*.c')
ASM_OBJECTS := $(patsubst $(ASM_SRC_DIR)/%.asm,$(BUILD_DIR)/%.o,$(ASM_SOURCES))
C_OBJECTS := $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o,$(C_SOURCES))
OBJECTS := $(ASM_OBJECTS) $(C_OBJECTS)

KERNEL_BIN := $(DIST_DIR)/kernel.bin
ISO_KERNEL := $(ISO_BOOT_DIR)/kernel.bin
KERNEL_ISO := $(DIST_DIR)/kernel.iso

.PHONY: all build run clean

all: build

build: $(KERNEL_ISO)

$(KERNEL_ISO): $(ISO_KERNEL) $(GRUB_CFG) | $(DIST_DIR)
	$(GRUB_MKRESCUE) -o "$@" "$(ISO_DIR)"

$(ISO_KERNEL): $(KERNEL_BIN) | $(ISO_BOOT_DIR)
	cp "$<" "$@"

$(KERNEL_BIN): $(OBJECTS) $(LINKER) | $(DIST_DIR)
	$(LD) $(LDFLAGS) -T "$(LINKER)" -o "$@" $(filter %.o,$^)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	mkdir -p "$(dir $@)"
	$(CC) $(CPPFLAGS) $(CFLAGS) -c "$<" -o "$@"

$(BUILD_DIR)/%.o: $(ASM_SRC_DIR)/%.asm
	mkdir -p "$(dir $@)"
	$(NASM) $(NASMFLAGS) "$<" -o "$@"

$(DIST_DIR):
	mkdir -p "$@"

$(ISO_BOOT_DIR):
	mkdir -p "$@"

run: build
	$(QEMU) -cdrom "$(KERNEL_ISO)"

clean:
	rm -rf build dist
