#include <stdint.h>

#define VGA_WIDTH 80
#define VGA_HEIGHT 25

#define VGA_BLACK         0x00
#define VGA_BLUE          0x01
#define VGA_GREEN         0x02
#define VGA_CYAN          0x03
#define VGA_RED           0x04
#define VGA_MAGENTA       0x05
#define VGA_BROWN         0x06
#define VGA_LIGHT_GRAY    0x07
#define VGA_DARK_GRAY     0x08
#define VGA_LIGHT_BLUE    0x09
#define VGA_LIGHT_GREEN   0x0A
#define VGA_LIGHT_CYAN    0x0B
#define VGA_LIGHT_RED     0x0C
#define VGA_LIGHT_MAGENTA 0x0D
#define VGA_YELLOW        0x0E
#define VGA_WHITE         0x0F


void kernel_main()
{
    uint16_t* video = (uint16_t*)0xB8000;

    // clear screen
    for(int i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++)
    {
        video[i] = (VGA_WHITE << 8) | ' ';
    }

    const char* msg = "Hello Kernel, Welcome to Axiom-Kernel";

    for(int i = 0; msg[i] != 0; i++)
    {
        video[i] = (VGA_GREEN << 8) | msg[i];
    }

    while(1) {}
}