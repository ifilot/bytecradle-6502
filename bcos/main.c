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

#define SDMAX 5

int main(void) {
    uint8_t c;
    uint8_t i;
    struct FAT32File* fileptr;
    uint8_t buf[40];

    putstrnl("Starting system...");
    // putstrnl("Probing memory banks...");
    // ramtest();
    putstr("Connecting to SD-card");
    for(i=0; i<SDMAX; i++) {
        putch('.');
        c = boot_sd();
        if(c == 0x00) {
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
        fat32_read_dir();
        fat32_sort_files();
        fat32_list_dir();
        
        // test: try to find this file
        fileptr = fat32_search_dir("HELLOWORTXT");
        if(fileptr != NULL) {
            sprintf(buf, "Base name: %s", fileptr->basename);
            putstrnl(buf);
            sprintf(buf, "Start cluster: %08lX", fileptr->cluster);
            putstrnl(buf);
            sprintf(buf, "File size: %lu", fileptr->filesize);
            putstrnl(buf);
        } else {
            putstrnl("File not found.");
        }

        // try to load the file from the SD-card
        fat32_load_file(fileptr, 0x0800);
        for(i=0; i<32; i++) {
            sprintf(buf, "%02X ", *(uint8_t*)(0x0800 + i));
            putstr(buf);
        }
        putstrnl("");

    } else {
        putstrnl("Cannot read MBR, exiting...");
        return -1;
    }

    // put system in infinite loop
    while(1){
        c = getch();
        if(c != 0) {
            putch(c);
        }
    }

    return 0;
}
