#include "idt.h"
#include "print.h"

void kernel_main() {
  print_clear();
  idt_init();

  print_set_color(PRINT_COLOR_YELLOW, PRINT_COLOR_BLACK);
  print_str("HI Layton\n");
  print_set_color(PRINT_COLOR_BLUE, PRINT_COLOR_BLACK);
  print_str("HOW IS ARCH LINUX GOING ON!\n");
  print_set_color(PRINT_COLOR_GREEN, PRINT_COLOR_BLACK);
  print_str("AND ALSO HOW DEVVING GOING ON? :)");
  print_str("HAHAHAH");

  __asm__ volatile("int $0");
}
