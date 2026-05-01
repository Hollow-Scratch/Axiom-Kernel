section .multiboot_header
align 8

header_start:
    dd 0xE85250D6
    dd 0
    dd header_end - header_start
    dd -(0xE85250D6 + 0 + (header_end - header_start))

align 8
    dw 5
    dw 0
    dd 20
    dd 1024
    dd 768
    dd 32

align 8
    dw 0
    dw 0
    dd 8

header_end:
