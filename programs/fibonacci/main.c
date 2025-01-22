#include <stdint.h>
#include <stdio.h>

extern void wait();
extern void __fastcall__ charout(char c);
extern void __fastcall__ stringout(char* c);

int main() {
    uint16_t a = 1;
    uint16_t b = 1;
    uint16_t c = 0;
    char buf[5];
    uint8_t i = 0;

    for(i=0; i<20; i++) {
        c = a+b;
	a = b;
	b = c;
	sprintf(buf, "%i\n", a);
	stringout(buf);
    }

    return 0;
}
