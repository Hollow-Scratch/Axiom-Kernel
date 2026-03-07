#include "vga.h"

void kernel_main()
{
    vga_clear();

    vga_print("Hello Kernel\n");
    vga_print("Welcome to Axiom Kernel\n");
    vga_print("> \n");
    vga_print("KJDAJDADKA\n");

    while(1);
}