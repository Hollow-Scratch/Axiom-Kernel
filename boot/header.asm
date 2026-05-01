section .multiboot_header
align 8

header_start:

    ; magic
    dd 0xe85250d6

    ; architecture (0 = i386)
    dd 0

    ; header length
    dd header_end - header_start

    ; checksum
    dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start))


    ; -------------------------
    ; ALIGN BEFORE TAG
    ; -------------------------
    align 8

    ; framebuffer tag
    dw 5              ; type
    dw 0              ; flags
    dd 20             ; size

    dd 1024           ; width
    dd 768            ; height
    dd 32             ; bpp


    ; -------------------------
    ; ALIGN BEFORE END TAG
    ; -------------------------
    align 8

    ; end tag
    dw 0
    dw 0
    dd 8

header_end: