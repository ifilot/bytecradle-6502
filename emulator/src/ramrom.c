/**************************************************************************
 *                                                                        *
 *   Author: Ivo Filot <ivo@ivofilot.nl>                                  *
 *                                                                        *
 *   BC6502EMU is free software:                                          *
 *   you can redistribute it and/or modify it under the terms of the      *
 *   GNU General Public License as published by the Free Software         *
 *   Foundation, either version 3 of the License, or (at your option)     *
 *   any later version.                                                   *
 *                                                                        *
 *   BC6502EMU is distributed in the hope that it will be useful,         *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty          *
 *   of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.              *
 *   See the GNU General Public License for more details.                 *
 *                                                                        *
 *   You should have received a copy of the GNU General Public License    *
 *   along with this program.  If not, see http://www.gnu.org/licenses/.  *
 *                                                                        *
 **************************************************************************/

#include "ramrom.h"

uint8_t ram[0x4000*3];  // 48 KiB RAM
uint8_t rom[0x4000];    // 16 KiB ROM
vrEmu6502Interrupt *irq;
char keybuffer[0x10];
char* keybuffer_ptr;

/**
 * @brief Initialize ROM from file
 * 
 * @param filename file address
 */
void initrom(const char *filename) {
    FILE *file = fopen(filename, "rb");
    if (file == NULL) {
        perror("Error opening file");
        return;
    }

    static const size_t filesize = 0x4000;
    size_t bytes_read = fread(rom, 1, filesize, file);
    if(bytes_read != filesize) {
        perror("File read error (size mismatch)");
    }
    fclose(file);
}

/**
 * @brief Read memory function
 * 
 * This function also needs to handle any memory mapped I/O devices
 * 
 * @param addr memory address
 * @param isDbg 
 * @return uint8_t value at memory address
 */
uint8_t memread(uint16_t addr, bool isDbg) {
    if(addr == ACIA_DATA) {
        if(keybuffer_ptr > keybuffer) {
            *irq = IntCleared;
            char ch = *(--keybuffer_ptr);

            // do some key mapping
            if(ch == 0x0A) {    // if line feed
                ch = 0x0D;      // transform to carriage return
            }

            return ch;
        }
    }

    if(addr == ACIA_STAT) {
        if(keybuffer_ptr > keybuffer) {
            return 0x08;
        } else {
            return 0x00;
        }
    }

    if (addr < 0xC000) {
        return ram[addr];
    }
    
    return rom[addr - 0xC000];
}

/**
 * @brief Write to memory function
 * 
 * @param addr memory address
 * @param val value to write
 */
void memwrite(uint16_t addr, uint8_t val) {
    if(addr == ACIA_DATA) {
        putchar(val);
        fflush(stdout);
    }

    if (addr < 0xC000) {
        ram[addr] = val;
    }
}