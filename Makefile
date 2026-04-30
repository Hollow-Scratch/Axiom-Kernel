ARCH = x86_64

CXX = x86_64-elf-g++
AS = nasm

CXXFLAGS = -ffreestanding -O2 -Wall -Wextra \
           -fno-exceptions -fno-rtti \
           -fno-stack-protector \
           -mno-red-zone -fno-pic -fno-pie

LDFLAGS = -T targets/$(ARCH)/linker.ld -nostdlib -no-pie

SRC_DIR = src
BOOT_DIR = boot
BUILD_DIR = build
ISO_DIR = targets/$(ARCH)/iso

CPP_SOURCES := $(shell find $(SRC_DIR) -name "*.cpp")
ASM_SOURCES := $(shell find $(BOOT_DIR) -name "*.asm")

CPP_OBJECTS := $(patsubst %.cpp,$(BUILD_DIR)/%.o,$(CPP_SOURCES))
ASM_OBJECTS := $(patsubst %.asm,$(BUILD_DIR)/%.o,$(ASM_SOURCES))

OBJECTS = $(CPP_OBJECTS) $(ASM_OBJECTS)

KERNEL = kernel.bin
ISO = kernel.iso

all: $(ISO)

$(KERNEL): $(OBJECTS)
	$(CXX) $(LDFLAGS) $(OBJECTS) -o $(KERNEL)

$(ISO): $(KERNEL)
	mkdir -p $(ISO_DIR)/boot
	cp $(KERNEL) $(ISO_DIR)/boot/kernel.bin

	grub-mkrescue -o $(ISO) $(ISO_DIR)

$(BUILD_DIR)/%.o: %.cpp
	mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.asm
	mkdir -p $(dir $@)
	$(AS) -f elf64 $< -o $@

run: $(ISO)
	qemu-system-x86_64 -cdrom $(ISO)

clean:
	rm -rf $(BUILD_DIR) *.bin *.iso