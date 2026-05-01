global long_mode_start

extern kernel_main
extern stack_top
extern multiboot_info_ptr

section .text
bits 64
default rel

long_mode_start:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    lea rsp, [stack_top]
    xor ebp, ebp

    mov ebx, dword [multiboot_info_ptr]
    mov rdi, rbx
    call kernel_main

.hang:
    hlt
    jmp .hang
