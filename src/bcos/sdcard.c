#include "sdcard.h"
#include "io.h"
#include "crc16.h"

uint8_t boot_sd() {
    uint8_t c = 0;
    uint8_t buf[10];
    uint8_t* sdbuf = (uint8_t*)0x8000;
    uint16_t checksum = 0x0000;
    uint16_t checksum_sd = 0x0000;
    uint8_t res = 0;
    uint8_t resparr[6];
    uint8_t i;

    // initialize SD card
    init_sd();

    // initialize sd card
    res = sdcmd00();
    if(res != 0x01) {
        return -1;
    }

    res = sdcmd08(resparr);
    if(res != 0x01) {
        return -1;
    }

    res = 0xFF;
    for(i=0; i<100; i++) {
        res = sdacmd41();
        if(res != 0x00) {
            continue;
        }
        res = sdcmd58(resparr);
        if(res == 0x00) {
            break;
        }
    }

    if(res != 0x00) {
        return -1;
    }

    return 0;
}
