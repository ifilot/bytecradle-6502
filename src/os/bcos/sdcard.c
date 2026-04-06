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

/**
 * @brief Read sector and verify checksum integrity
 * 
 * @param addr 
 * @return uint8_t whether checksum is valid (0) or not (1)
 */
uint8_t read_sector(uint32_t addr) {
    uint16_t checksum;
    uint16_t crc16;

    checksum = sdcmd17(addr);
    crc16 = crc16_xmodem_sdsector();

    if(checksum == crc16) {
        return 0;
    } else {
        putstrnl("[ERROR] SD-CARD checksum error: HALTING");
        puthex(checksum >> 8);
        puthex(checksum);
        putch(' ');
        puthex(crc16 >> 8);
        puthex(crc16);
        putcrlf();
        asm("loop: jmp loop");
    }
}