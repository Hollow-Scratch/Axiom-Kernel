#include <stdint.h>

struct [[gnu::packed]] MultibootTag {
    uint32_t type;
    uint32_t size;
};

struct [[gnu::packed]] MultibootFramebufferTag {
    uint32_t type;
    uint32_t size;
    uint64_t framebuffer_addr;
    uint32_t framebuffer_pitch;
    uint32_t framebuffer_width;
    uint32_t framebuffer_height;
    uint8_t framebuffer_bpp;
    uint8_t framebuffer_type;
    uint16_t reserved;
    uint8_t red_field_position;
    uint8_t red_mask_size;
    uint8_t green_field_position;
    uint8_t green_mask_size;
    uint8_t blue_field_position;
    uint8_t blue_mask_size;
};

static inline uint32_t align_up_8(uint32_t v) {
    return (v + 7u) & ~7u;
}

static inline uint32_t mask_for_bits(uint8_t bits) {
    return (bits >= 32u) ? 0xFFFFFFFFu : ((1u << bits) - 1u);
}

[[noreturn]] static void halt_forever() {
    for (;;) asm volatile("hlt");
}

// -------- SIMPLE FONT STORAGE --------
static uint8_t font[128][8];

static void init_font() {
    // Clear everything
    for (int i = 0; i < 128; i++)
        for (int j = 0; j < 8; j++)
            font[i][j] = 0;

    // 'O' (ASCII 79)
    uint8_t O[8] = {0x3C,0x42,0x42,0x42,0x42,0x42,0x3C,0x00};
    for (int i = 0; i < 8; i++) font[79][i] = O[i];

    // 'K' (ASCII 75)
    uint8_t K[8] = {0x42,0x44,0x48,0x70,0x48,0x44,0x42,0x00};
    for (int i = 0; i < 8; i++) font[75][i] = K[i];
}

extern "C" [[noreturn]] void kernel_main(uint64_t mb_addr) {

    init_font();

    // -------- multiboot --------
    auto* mb = (uint8_t*)mb_addr;
    uint32_t total = *(uint32_t*)mb;
    auto* end = mb + total;
    auto* tag_bytes = mb + 8;

    MultibootFramebufferTag* fb = nullptr;

    while (tag_bytes < end) {
        auto* tag = (MultibootTag*)tag_bytes;

        if (tag->type == 0) break;

        if (tag->type == 8) {
            fb = (MultibootFramebufferTag*)tag;
            break;
        }

        tag_bytes += align_up_8(tag->size);
    }

    if (!fb) halt_forever();
    if (fb->framebuffer_type != 1 || fb->framebuffer_bpp != 32)
        halt_forever();

    int W = fb->framebuffer_width;
    int H = fb->framebuffer_height;

    auto* front = (uint32_t*)(uintptr_t)fb->framebuffer_addr;

    // -------- backbuffer --------
    static uint32_t backbuffer[1920 * 1080];

    auto make_color = [&](uint32_t r, uint32_t g, uint32_t b) {
        return ((r & mask_for_bits(fb->red_mask_size)) << fb->red_field_position) |
               ((g & mask_for_bits(fb->green_mask_size)) << fb->green_field_position) |
               ((b & mask_for_bits(fb->blue_mask_size)) << fb->blue_field_position);
    };

    auto put_pixel = [&](int x, int y, uint32_t c) {
        if (x < 0 || y < 0 || x >= W || y >= H) return;
        backbuffer[y * W + x] = c;
    };

    // -------- background --------
    for (int y = 0; y < H; y++) {
        for (int x = 0; x < W; x++) {
            uint32_t r = (x * 255) / W;
            uint32_t g = (y * 255) / H;
            put_pixel(x, y, make_color(r, g, 50));
        }
    }

    // -------- text --------
    auto draw_char = [&](int x, int y, char c, uint32_t color) {
        uint8_t* glyph = font[(int)c];
        for (int row = 0; row < 8; row++) {
            uint8_t bits = glyph[row];
            for (int col = 0; col < 8; col++) {
                if (bits & (1 << (7 - col))) {
                    put_pixel(x + col, y + row, color);
                }
            }
        }
    };

    auto draw_string = [&](int x, int y, const char* str, uint32_t color) {
        int cx = x;
        while (*str) {
            draw_char(cx, y, *str, color);
            cx += 8;
            str++;
        }
    };

    draw_string(50, 50, "OK", make_color(255,255,255));

    // -------- copy --------
    for (int y = 0; y < H; y++) {
        auto* dst = (uint32_t*)((uint8_t*)front + y * fb->framebuffer_pitch);
        auto* src = &backbuffer[y * W];

        for (int x = 0; x < W; x++) {
            dst[x] = src[x];
        }
    }

    halt_forever();
}