#include <stdint.h>
#include <stdio.h>

#include "sdcard.h"
#include "io.h"

int main(void) {
    uint8_t c = 0;
    uint8_t buf[10];
    uint8_t* sdbuf = (uint8_t*)0x8000;

    boot_sd();

    sprintf(buf, "Before CMD17: %04X\n", (uint16_t)sdbuf);
    putstr(buf);

    // retrieve sector
    sdcmd17(0x12345678);

    sprintf(buf, "After CMD17: %04X\n", (uint16_t)sdbuf);
    putstr(buf);

    // print bytes
    sprintf(buf, "Check byte: %02X %02X\n", *(volatile uint8_t*)0x81FE, sdbuf[0x1FF]);
    putstr(buf);

    sprintf(buf, "%04X\n", (uint16_t)sdbuf);
    putstr(buf);

    // put system in infinite loop
    while(1){
        c = getch();
        if(c != 0) {
            putch(c);
        }
    }

    return 0;
}
