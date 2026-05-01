global start
global stack_top
global multiboot_info_ptr

extern long_mode_start

%define MULTIBOOT2_BOOTLOADER_MAGIC 0x36D76289
%define CR0_PG                    (1 << 31)
%define CR4_PAE                   (1 << 5)
%define EFER_MSR                  0xC0000080
%define EFER_LME                  (1 << 8)
%define PAGE_PRESENT              (1 << 0)
%define PAGE_WRITABLE             (1 << 1)
%define PAGE_LARGE                (1 << 7)
%define PAGE_FLAGS                (PAGE_PRESENT | PAGE_WRITABLE)
%define PAGE_LARGE_FLAGS          (PAGE_PRESENT | PAGE_WRITABLE | PAGE_LARGE)
%define PAGE_DIRECTORY_COUNT      4
%define ENTRIES_PER_TABLE         512
%define TOTAL_2M_PAGES            (PAGE_DIRECTORY_COUNT * ENTRIES_PER_TABLE)

section .text
bits 32

start:
    cli
    mov esp, stack_top

    cmp eax, MULTIBOOT2_BOOTLOADER_MAGIC
    jne halt

    mov [multiboot_info_ptr], ebx
    mov dword [0xB8000], 0x0F4B0F4F

    call zero_page_tables
    call setup_page_tables
    call enable_long_mode

    lgdt [gdt64_descriptor]
    jmp 0x08:long_mode_start

halt:
.hang:
    hlt
    jmp .hang

zero_page_tables:
    cld
    xor eax, eax
    mov edi, page_table_l4
    mov ecx, (page_tables_end - page_table_l4) / 4
    rep stosd
    ret

setup_page_tables:
    mov eax, page_table_l3
    or eax, PAGE_FLAGS
    mov [page_table_l4 + 0], eax
    mov dword [page_table_l4 + 4], 0

    mov eax, page_table_l2_0
    or eax, PAGE_FLAGS
    mov [page_table_l3 + 0], eax
    mov dword [page_table_l3 + 4], 0

    mov eax, page_table_l2_1
    or eax, PAGE_FLAGS
    mov [page_table_l3 + 8], eax
    mov dword [page_table_l3 + 12], 0

    mov eax, page_table_l2_2
    or eax, PAGE_FLAGS
    mov [page_table_l3 + 16], eax
    mov dword [page_table_l3 + 20], 0

    mov eax, page_table_l2_3
    or eax, PAGE_FLAGS
    mov [page_table_l3 + 24], eax
    mov dword [page_table_l3 + 28], 0

    xor ecx, ecx

.map_identity:
    mov eax, ecx
    shl eax, 21
    or eax, PAGE_LARGE_FLAGS
    mov [page_table_l2_0 + (ecx * 8)], eax
    mov dword [page_table_l2_0 + (ecx * 8) + 4], 0

    inc ecx
    cmp ecx, TOTAL_2M_PAGES
    jne .map_identity

    ret

enable_long_mode:
    mov eax, page_table_l4
    mov cr3, eax

    mov eax, cr4
    or eax, CR4_PAE
    mov cr4, eax

    mov ecx, EFER_MSR
    rdmsr
    or eax, EFER_LME
    wrmsr

    mov eax, cr0
    or eax, CR0_PG
    mov cr0, eax

    ret

section .rodata
align 8
gdt64:
    dq 0x0000000000000000
    dq 0x00AF9A000000FFFF
    dq 0x00AF92000000FFFF
gdt64_end:

gdt64_descriptor:
    dw gdt64_end - gdt64 - 1
    dd gdt64

section .bss
alignb 4096
page_table_l4:      resb 4096
page_table_l3:      resb 4096
page_table_l2_0:    resb 4096
page_table_l2_1:    resb 4096
page_table_l2_2:    resb 4096
page_table_l2_3:    resb 4096
page_tables_end:

alignb 16
multiboot_info_ptr: resd 1

alignb 16
stack_bottom:       resb 16384
stack_top:
