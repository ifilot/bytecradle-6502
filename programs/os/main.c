#include <stdint.h>
#include <stdio.h>

#include "sdcard.h"
#include "io.h"

int main(void) {
    uint8_t c = 0;
    uint8_t buf[10];
    uint8_t* sdbuf = (uint8_t*)0x8000;
    uint16_t checksum = 0x0000;
    uint8_t res = 0;
    uint8_t resparr[6];

    // initialize sd card
    res = sdcmd00();
    sprintf(buf, "CMD00: %02X\n", res);
    putstr(buf);

    res = sdcmd08(resparr);
    sprintf(buf, "CMD08: %02X %02X %02X %02X %02X\n", resparr[0], resparr[1], resparr[2], resparr[3], resparr[4]);
    putstr(buf);
    return 0;

    // retrieve sector
    checksum = sdcmd17(0x00000000);

    sprintf(buf, "Checksum: %04X\n", checksum);
    putstr(buf);

    // print bytes
    sprintf(buf, "Check byte: %02X %02X\n", sdbuf[0x1FE], sdbuf[0x1FF]);
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
