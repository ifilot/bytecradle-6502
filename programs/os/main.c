/**************************************************************************
 *                                                                        *
 *   Author: Ivo Filot <ivo@ivofilot.nl>                                  *
 *                                                                        *
 *   ByteCradle 6502 OS is free software:                                 *
 *   you can redistribute it and/or modify it under the terms of the      *
 *   GNU General Public License as published by the Free Software         *
 *   Foundation, either version 3 of the License, or (at your option)     *
 *   any later version.                                                   *
 *                                                                        *
 *   ByteCradle 6502 OS is distributed in the hope that it will be useful,*
 *   but WITHOUT ANY WARRANTY; without even the implied warranty          *
 *   of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.              *
 *   See the GNU General Public License for more details.                 *
 *                                                                        *
 *   You should have received a copy of the GNU General Public License    *
 *   along with this program.  If not, see http://www.gnu.org/licenses/.  *
 *                                                                        *
 **************************************************************************/

#include <stdint.h>
#include <stdio.h>

#include "sdcard.h"
#include "io.h"
#include "crc16.h"

int main(void) {
    uint8_t c = 0;
    uint8_t buf[10];
    uint8_t* sdbuf = (uint8_t*)0x8000;
    uint16_t checksum = 0x0000;
    uint8_t res = 0;
    uint8_t resparr[6];
    uint16_t i,j;

    // initialize SD card
    init_sd();

    // initialize sd card
    res = sdcmd00();
    sprintf(buf, "CMD00: %02X\n", res);
    putstr(buf);
    if(res != 0x01) {
        putstr("Exiting...");
        return -1;
    }

    res = sdcmd08(resparr);
    sprintf(buf, "CMD08: %02X %02X %02X %02X %02X\n", resparr[0], resparr[1], resparr[2], resparr[3], resparr[4]);
    putstr(buf);
    if(res != 0x01) {
        putstr("Exiting...");
        return -1;
    }
    
    res = 0xFF;
    while(res != 0x00) {
        res = sdacmd41();
        sprintf(buf, "CMD41: %02X\n", res);
        putstr(buf);
    }

    res = sdcmd58(resparr);
    sprintf(buf, "CMD58: %02X %02X %02X %02X %02X\n", resparr[0], resparr[1], resparr[2], resparr[3], resparr[4]);
    putstr(buf);
    if(res != 0x00) {
        return -1;
    }

    // retrieve sector
    checksum = sdcmd17(0x00000000);

    sprintf(buf, "Checksum SD: %04X\n", checksum);
    putstr(buf);

    checksum = crc16_xmodem(sdbuf, 0x200);

    sprintf(buf, "Calculated checksum: %04X\n", checksum);
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
