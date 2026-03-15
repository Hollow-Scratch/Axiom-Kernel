#include "pic.h"

static inline void outb(uint16_t port, uint8_t value) {
  __asm__ volatile("outb %0, %1" : : "a"(value), "Nd"(port));
}

void pic_remap() {
  uint8_t a1, a2;

  // save masks
  __asm__ volatile("inb %1, %0" : "=a"(a1) : "Nd"(0x21));
  __asm__ volatile("inb %1, %0" : "=a"(a2) : "Nd"(0xA1));

  // start initialization
  outb(0x20, 0x11);
  outb(0xA0, 0x11);

  // set new offsets
  outb(0x21, 0x20); // IRQ0 -> 32
  outb(0xA1, 0x28); // IRQ8 -> 40

  // setup cascading
  outb(0x21, 0x04);
  outb(0xA1, 0x02);

  // 8086 mode
  outb(0x21, 0x01);
  outb(0xA1, 0x01);

  // restore masks
  outb(0x21, a1);
  outb(0xA1, a2);
}
