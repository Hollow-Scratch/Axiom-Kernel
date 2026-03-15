#include "idt.h"
#include "pic.h"
#include "print.h"

void kernel_main() {
  print_clear();
  idt_init();
  pic_remap();

  __asm__ volatile("sti");

  print_set_color(PRINT_COLOR_YELLOW, PRINT_COLOR_BLACK);
  print_str("HI Layton\n");
  print_set_color(PRINT_COLOR_BLUE, PRINT_COLOR_BLACK);
  print_str("HOW IS ARCH LINUX GOING ON!\n");
  print_set_color(PRINT_COLOR_GREEN, PRINT_COLOR_BLACK);
  print_str("AND ALSO HOW DEVVING GOING ON? :)\n");
  print_str("HAHAHAH\n");

  __asm__ volatile("int $0");
}
