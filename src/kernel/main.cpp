// kernel.cpp

#include <stdint.h>

struct multiboot_tag {
    uint32_t type;
    uint32_t size;
};

extern "C" void kernel_main(uint64_t mb_addr) {
    // VGA text buffer
    volatile char* vga = (volatile char*)0xB8000;

    // Step 1: kernel reached
    vga[0] = 'O';
    vga[1] = 0x0F;

    // Step 2: basic execution continues
    vga[2] = 'M';
    vga[3] = 0x0F;

    // Step 3: scan multiboot2 tags
    multiboot_tag* tag = (multiboot_tag*)(mb_addr + 8);

    int found_fb = 0;

    while (tag->type != 0) {
        if (tag->type == 8) { // framebuffer tag
            found_fb = 1;
            break;
        }

        tag = (multiboot_tag*)((uint8_t*)tag + ((tag->size + 7) & ~7));
    }

    // Step 4: result
    if (found_fb) {
        vga[4] = 'Y'; // framebuffer found
        vga[5] = 0x0F;
    } else {
        vga[4] = 'F'; // framebuffer NOT found
        vga[5] = 0x0F;
    }

    // Halt
    while (1) {
        asm("hlt");
    }
}