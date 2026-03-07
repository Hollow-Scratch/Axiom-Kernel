#include <stdint.h>
#include "vga.h"

#define VGA_WIDTH 80
#define VGA_HEIGHT 25
#define VGA_COLOR 0x0F

static uint16_t* video = (uint16_t*)0xB8000;

static int cursor_x = 0;
static int cursor_y = 0;

void vga_clear()
{
    for(int i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++)
        video[i] = (VGA_COLOR << 8) | ' ';
}

void vga_putchar(char c)
{
    if(c == '\n')
    {
        cursor_x = 0;
        cursor_y++;
        return;
    }

    video[cursor_y * VGA_WIDTH + cursor_x] = (VGA_COLOR << 8) | c;

    cursor_x++;

    if(cursor_x >= VGA_WIDTH)
    {
        cursor_x = 0;
        cursor_y++;
    }
}

void vga_print(const char* str)
{
    for(int i = 0; str[i] != 0; i++)
        vga_putchar(str[i]);
}