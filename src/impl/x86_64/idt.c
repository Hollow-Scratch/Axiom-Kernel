#include "idt.h"
#include "print.h"

extern void isr0();

static struct IDTEntry idt[256];
static struct IDTPointer idt_ptr;

static void idt_set_gate(int n, void *handler) {
  uint64_t addr = (uint64_t)handler;

  idt[n].offset_low = addr & 0xFFFF;
  idt[n].selector = 0x08;
  idt[n].ist = 0;
  idt[n].type_attr = 0x8E;
  idt[n].offset_mid = (addr >> 16) & 0xFFFF;
  idt[n].offset_high = (addr >> 32);
  idt[n].zero = 0;
}

void idt_init() {
  idt_set_gate(0, isr0);

  idt_ptr.limit = sizeof(idt) - 1;
  idt_ptr.base = (uint64_t)&idt;

  __asm__ volatile("lidt %0" : : "m"(idt_ptr));
}

void isr0_handler() {
  print_set_color(PRINT_COLOR_RED, PRINT_COLOR_BLACK);
  print_str("Divide by zero interrupt!\n");

  while (1)
    __asm__ volatile("hlt");
}
