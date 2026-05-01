ARCH := x86_64

CXX := x86_64-elf-g++
AS := nasm
GRUBMKRESCUE := grub-mkrescue

BUILD_DIR := build
BIN_DIR := bin
ISO_DIR := targets/$(ARCH)/iso
LINKER_SCRIPT := targets/$(ARCH)/linker.ld

ASM_SOURCES := boot/header.asm boot/main.asm boot/main64.asm
CPP_SOURCES := src/kernel/main.cpp

ASM_OBJECTS := $(patsubst %.asm,$(BUILD_DIR)/%.o,$(ASM_SOURCES))
CPP_OBJECTS := $(patsubst %.cpp,$(BUILD_DIR)/%.o,$(CPP_SOURCES))
OBJECTS := $(ASM_OBJECTS) $(CPP_OBJECTS)

KERNEL_ELF := $(BIN_DIR)/kernel.elf
KERNEL_ISO := $(BIN_DIR)/kernel.iso

CXXFLAGS := -std=gnu++17 -O2 -ffreestanding -fno-exceptions -fno-rtti \
            -fno-stack-protector -fno-pic -fno-pie -mno-red-zone \
            -Wall -Wextra -fno-asynchronous-unwind-tables
ASFLAGS := -f elf64
LDFLAGS := -T $(LINKER_SCRIPT) -nostdlib -no-pie -Wl,-n \
           -Wl,--build-id=none -Wl,-z,max-page-size=0x1000

.PHONY: all run clean

all: $(KERNEL_ISO)

$(KERNEL_ELF): $(OBJECTS) $(LINKER_SCRIPT)
	mkdir -p $(BIN_DIR)
	$(CXX) $(OBJECTS) $(LDFLAGS) -o $(KERNEL_ELF)

$(KERNEL_ISO): $(KERNEL_ELF) targets/$(ARCH)/iso/boot/grub/grub.cfg
	mkdir -p $(ISO_DIR)/boot
	cp $(KERNEL_ELF) $(ISO_DIR)/boot/kernel.elf
	$(GRUBMKRESCUE) -o $(KERNEL_ISO) $(ISO_DIR)

$(BUILD_DIR)/%.o: %.asm
	mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) $< -o $@

$(BUILD_DIR)/%.o: %.cpp
	mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@

run: $(KERNEL_ISO)
	qemu-system-x86_64 -cdrom $(KERNEL_ISO) -vga std

clean:
	rm -rf $(BUILD_DIR) $(BIN_DIR)
