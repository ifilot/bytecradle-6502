#include <stdint.h>
#include <stdio.h>

extern void __fastcall__ putch(char c);
extern void __fastcall__ putstr(char* c);
extern void __fastcall__ init_sys(void);

int main() {
    uint16_t a = 1;
    uint16_t b = 1;
    uint16_t c = 0;
    char buf[5];
    uint8_t i = 0;

    init_sys();

    putstr("Hello World!");

    // put system in infinite loop
    while(1){}
}
