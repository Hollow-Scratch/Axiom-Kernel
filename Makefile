ARCH = x86_64

CXX = x86_64-elf-g++
AS = nasm

CXXFLAGS = -ffreestanding -O2 -Wall -Wextra \
           -fno-exceptions -fno-rtti \
           -fno-stack-protector \
           -mno-red-zone -fno-pic -fno-pie

LDFLAGS = -T targets/$(ARCH)/linker.ld -nostdlib -no-pie

# dirs
SRC_DIR = src
BOOT_DIR = boot
BUILD_DIR = build
BIN_DIR = bin
ISO_DIR = targets/$(ARCH)/iso

# 🔥 auto loop
CPP_SOURCES := $(shell find $(SRC_DIR) -name "*.cpp")
ASM_SOURCES := $(shell find $(BOOT_DIR) -name "*.asm")

CPP_OBJECTS := $(patsubst %.cpp,$(BUILD_DIR)/%.o,$(CPP_SOURCES))
ASM_OBJECTS := $(patsubst %.asm,$(BUILD_DIR)/%.o,$(ASM_SOURCES))

OBJECTS = $(CPP_OBJECTS) $(ASM_OBJECTS)

KERNEL = $(BIN_DIR)/kernel.bin
ISO = $(BIN_DIR)/kernel.iso

all: $(ISO)

# link kernel
$(KERNEL): $(OBJECTS)
	mkdir -p $(BIN_DIR)
	$(CXX) $(LDFLAGS) $(OBJECTS) -o $(KERNEL)

# build ISO
$(ISO): $(KERNEL)
	mkdir -p $(ISO_DIR)/boot
	cp $(KERNEL) $(ISO_DIR)/boot/kernel.bin

	mkdir -p $(BIN_DIR)
	grub-mkrescue -o $(ISO) $(ISO_DIR)

# compile C++
$(BUILD_DIR)/%.o: %.cpp
	mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@

# compile ASM
$(BUILD_DIR)/%.o: %.asm
	mkdir -p $(dir $@)
	$(AS) -f elf64 $< -o $@

run: $(ISO)
	qemu-system-x86_64 -cdrom $(ISO)

clean:
	rm -rf $(BUILD_DIR) $(BIN_DIR)