#include <stdint.h>
#include <stdio.h>

#include "io.h"

int main() {
    uint16_t a = 1;
    uint16_t b = 1;
    uint16_t c = 0;
    char buf[10];
    uint8_t i = 0;

    for(i=0; i<20; i++) {
        c = a+b;
        a = b;
        b = c;
        sprintf(buf, "%i", a);
        putstrnl(buf);
    }

    return 0;
}
