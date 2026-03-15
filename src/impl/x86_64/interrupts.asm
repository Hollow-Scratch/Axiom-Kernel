bits 64

global isr0
extern isr0_handler

section .text

isr0:
    push rbp
    mov rbp, rsp

    call isr0_handler

    pop rbp
    iretq
