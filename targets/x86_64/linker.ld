OUTPUT_FORMAT(elf64-x86-64)
OUTPUT_ARCH(i386:x86-64)
ENTRY(start)

PHDRS
{
    text PT_LOAD FLAGS(5);
    data PT_LOAD FLAGS(6);
}

SECTIONS
{
    . = 1M;

    .multiboot_header ALIGN(8) :
    {
        KEEP(*(.multiboot_header))
    } :text

    .text ALIGN(4096) :
    {
        *(.text*)
    } :text

    .rodata ALIGN(4096) :
    {
        *(.rodata*)
    } :text

    .data ALIGN(4096) :
    {
        *(.data*)
    } :data

    .bss ALIGN(4096) :
    {
        *(COMMON)
        *(.bss*)
    } :data

    /DISCARD/ :
    {
        *(.comment)
        *(.eh_frame)
        *(.note*)
    }
}
