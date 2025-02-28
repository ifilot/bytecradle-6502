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
#include <string.h>

#include "fat32.h"
#include "io.h"
#include "ramtest.h"
#include "command.h"

#define SDMAX 5

int main(void) {
    uint8_t i;
    uint8_t res;

    putstrnl("Starting system...");
    // putstrnl("Probing memory banks...");
    // ramtest();
    putstr("Connecting to SD-card");
    for(i=0; i<SDMAX; i++) {
        putch('.');
        res = boot_sd();
        if(res == 0x00) {
            putch('\n');
            putstrnl("SD-card initialized.");
            break;
        }
    }
    if(i == SDMAX) {
        putch('\n');
        putstrnl("Cannot open SD-card, exiting...");
        return -1;
    }

    if(fat32_read_mbr() == 0x00) {
        fat32_read_partition();
    } else {
        putstrnl("Cannot read MBR, exiting...");
        return -1;
    }

    // put system in infinite loop
    command_pwdcmd();
    while(1){
        command_loop();
    }

    return 0;
}
