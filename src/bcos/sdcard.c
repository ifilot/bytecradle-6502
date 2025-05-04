#include "sdcard.h"
#include "io.h"
#include "crc16.h"

uint8_t boot_sd() {
    uint8_t res;
    uint8_t resparr[5];

    sdinit();
    sdpulse();
    
    res = sdcmd00();
    if(res != 0x01) {
        putstr("[ERROR] Failed on CMD00: ");
        puthex(res);
        putcrlf();
        return 0xFF;
    }
    
    res = sdcmd08(resparr);
    if(res != 0x01) {
        putstr("[ERROR] Failed on CMD08: ");
        puthex(res);
        putcrlf();
        return 0xFF;
    }
    
    res = sdacmd41();
    if(res != 0x00) {
        putstr("[ERROR] Failed on ACMD41: ");
        puthex(res);
        putcrlf();
        return 0xFF;
    }

    res = sdcmd58(resparr);
    if(res != 0x00) {
        putstr("[ERROR] Failed on CMD58: ");
        puthex(res);
        putcrlf();
        return 0xFF;
    }

    if(resparr[1] != 0xC0) {
        putstr("[ERROR] CMD58: not a valid SD card: ");
        puthex(resparr[1]);
        putcrlf();
        return 0xFF;
    }

    return 0;
}