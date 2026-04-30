extern "C" void kernel_main() {
    const char* msg = "Hello from kernel";
    volatile char* video = (volatile char*)0xb8000;

    for (int i = 0; msg[i]; i++) {
        video[i * 2] = msg[i];
        video[i * 2 + 1] = 0x0F; // white text
    }

    while (1) {
        asm("hlt");
    }
}