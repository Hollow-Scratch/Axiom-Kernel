#!/bin/bash
set -e

mkdir -p build
mkdir -p iso/boot/grub

nasm -f elf32 src/boot.asm -o build/boot.o

gcc -m32 -ffreestanding -c src/kernel.c -o build/kernel.o
gcc -m32 -ffreestanding -c src/vga.c -o build/vga.o

ld -m elf_i386 -T linker.ld -o kernel.bin build/boot.o build/kernel.o build/vga.o

cp kernel.bin iso/boot/
cp boot/grub/grub.cfg iso/boot/grub/

grub-mkrescue -o kernel.iso iso