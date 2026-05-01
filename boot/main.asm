global start
extern long_mode_start

section .text
bits 32

start:
    mov esp, stack_top

    ; check multiboot magic (safe, no calls)
    cmp eax, 0x36d76289
    jne error

    ; DO NOT call anything else (rbx must stay intact)

    call setup_page_tables
    call enable_paging

    lgdt [gdt64_pointer]
    jmp 0x08:long_mode_start

    hlt


; paging
setup_page_tables:
    mov eax, page_table_l3
    or eax, 0b11
    mov [page_table_l4], eax

    mov eax, page_table_l2
    or eax, 0b11
    mov [page_table_l3], eax

    mov ecx, 0
.loop:
    mov eax, 0x200000
    mul ecx
    or eax, 0b10000011
    mov [page_table_l2 + ecx * 8], eax

    inc ecx
    cmp ecx, 512
    jne .loop

    ret


enable_paging:
    mov eax, page_table_l4
    mov cr3, eax

    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ret


error:
    mov dword [0xb8000], 0x4f524f45
    mov dword [0xb8004], 0x4f3a4f52
    mov dword [0xb8008], 0x4f204f20
    mov byte  [0xb800a], 'X'
    hlt


section .bss
align 4096
page_table_l4: resb 4096
page_table_l3: resb 4096
page_table_l2: resb 4096

stack_bottom: resb 4096 * 4
stack_top:


section .rodata
gdt64:
    dq 0x0000000000000000
    dq 0x00af9a000000ffff

gdt64_pointer:
    dw gdt64_end - gdt64 - 1
    dq gdt64

gdt64_end: