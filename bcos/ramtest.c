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

#include "ramtest.h"

void ramtest() {
    uint8_t j;
    uint8_t *ptr;
    uint8_t error = 0;
    char buf[20];

    // loop over all rambanks and test them
    putstr("Probing memory banks: ");
    for(j=0; j<32; j++) {
        if(j == 0x10) {
            putstrnl("");
            putstr("                      ");
        }
        
        sprintf(buf, "%02X ", j);
        putstr(buf);

        set_rambank(j);
        store_ram_upper(0xAA);
        error = probe_ram_upper(0xAA);
        if(error == 1) {
            break;
        }

        store_ram_upper(0x55);
        error = probe_ram_upper(0x55);
        if(error == 1) {
            break;
        }
    }
    putstrnl("");

    set_rambank(0);
    if(error == 0) {
        putstrnl("All memory OK!");
    } else {
        putstrnl("Memory error!");
    }
}