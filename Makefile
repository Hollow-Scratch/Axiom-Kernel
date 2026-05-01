ARCH = x86_64

CXX = x86_64-elf-g++
AS = nasm

# dirs
SRC_DIR = src
BOOT_DIR = boot
BUILD_DIR = build
BIN_DIR = bin
ISO_DIR = targets/$(ARCH)/iso

# sources
CPP_SOURCES := $(shell find $(SRC_DIR) -name "*.cpp")
ASM_SOURCES := $(shell find $(BOOT_DIR) -name "*.asm")

CPP_OBJECTS := $(patsubst %.cpp,$(BUILD_DIR)/%.o,$(CPP_SOURCES))
ASM_OBJECTS := $(patsubst %.asm,$(BUILD_DIR)/%.o,$(ASM_SOURCES))

OBJECTS = $(CPP_OBJECTS) $(ASM_OBJECTS)

# outputs
KERNEL_ELF = $(BIN_DIR)/kernel.elf
ISO = $(BIN_DIR)/kernel.iso

# flags
CXXFLAGS_COMMON = -ffreestanding -Wall -Wextra \
                  -fno-exceptions -fno-rtti \
                  -fno-stack-protector \
                  -mno-red-zone -fno-pic -fno-pie \
                  -fno-asynchronous-unwind-tables

LDFLAGS = -T targets/$(ARCH)/linker.ld -nostdlib -no-pie

# default
CXXFLAGS = $(CXXFLAGS_COMMON) -O2

all: $(ISO)

debug: CXXFLAGS = $(CXXFLAGS_COMMON) -O0 -g
debug: clean $(ISO)

# link kernel
$(KERNEL_ELF): $(OBJECTS)
	mkdir -p $(BIN_DIR)
	$(CXX) $(LDFLAGS) $(OBJECTS) -o $(KERNEL_ELF)

# build ISO
$(ISO): $(KERNEL_ELF)
	mkdir -p $(ISO_DIR)/boot/grub
	cp $(KERNEL_ELF) $(ISO_DIR)/boot/kernel.elf
	grub-mkrescue -o $(ISO) $(ISO_DIR)

# compile C++
$(BUILD_DIR)/%.o: %.cpp
	mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@

# compile ASM
$(BUILD_DIR)/%.o: %.asm
	mkdir -p $(dir $@)
	$(AS) -f elf64 $< -o $@

# run
run: $(ISO)
	qemu-system-x86_64 \
		-cdrom $(ISO) \
		-vga std

# debug run
debug-run: $(ISO)
	qemu-system-x86_64 \
		-cdrom $(ISO) \
		-vga std \
		-s -S

# clean
clean:
	rm -rf $(BUILD_DIR) $(BIN_DIR)