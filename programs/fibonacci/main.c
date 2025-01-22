#include <stdint.h>
#include <stdio.h>

extern void wait();
extern void __fastcall__ charout(char c);

int main() {
    uint8_t a = 1;
    uint8_t b = 1;
    uint8_t c = 0;
    char buf[5];
    char *ch;
    uint8_t i = 0;

    for(i=0; i<10; i++) {
        c = a+b;
	a = b;
	b = c;
	sprintf(buf, "%i\n", a);
	ch = buf;
	while(*ch != 0) {
	    charout(*ch++);
	}
    }

    return 0;
}
