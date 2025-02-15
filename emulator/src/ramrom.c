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
uint8_t mosi[1024];
uint8_t miso[1024];
unsigned int mosiptr;
unsigned int misoptr;
FILE *sdfile;

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

    // reset miso and mosi pointers
    mosiptr = 0;
    misoptr = 0;
    memset(mosi, 0x00, 0x10);
    memset(miso, 0xFF, 1024);
}

/**
 * @brief Open file pointer to SD card image
 *
 * @param filename file URL
 */
void init_sd(const char* filename) {
    sdfile = fopen(filename, "rb");
    if (sdfile == NULL) {
        perror("Error opening file");
        return;
    }
}

/**
 * Close SD-card pointer
 */
void close_sd() {
    fclose(sdfile);
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

    // sd-card interface
    if(addr == SERIAL) {
        return miso[misoptr++];
    }

    // prevent buffer underrun
    if(misoptr == 1024) {
        misoptr = 0;
    }

    // internal memory
    if (addr < 0xC000) {
        return ram[addr];
    }

    // rom chip
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

    if(addr == CLKSTART) {
        mosi[mosiptr++] = ram[SERIAL];
        digest_sd();
    }

    if(mosiptr == 1024) {
        mosiptr = 0;
    }

    if (addr < 0xC000) {
        ram[addr] = val;
    }
}

/*
 * Check buffer to see if a valid SD command has been sent,
 * if so, appropriately populate the miso buffer
 */
void digest_sd() {
    static const uint8_t cmd00[6] = {0x40, 0x00, 0x00, 0x00, 0x00, 0x94|1};
    static const uint8_t cmd08[6] = {8|0x40, 0x00, 0x00, 0x01, 0xAA, 0x86|1};
    static const uint8_t cmd55[6] = {55|0x40, 0x00, 0x00, 0x00, 0x00, 0x00|1};
    static const uint8_t acmd41[6] = {41|0x40, 0x40, 0x00, 0x00, 0x00, 0x00|1};
    static const uint8_t cmd58[6] = {58|0x40, 0x00, 0x00, 0x00, 0x00, 0x00|1};

    static const uint8_t respcmd00[2] = {0xFF, 0x01};
    static const uint8_t respcmd08[6] = {0xFF, 0x01, 0x00, 0x00, 0x01, 0xAA};
    static const uint8_t respcmd55[2] = {0xFF, 0x01};
    static const uint8_t respacmd41[2] = {0xFF, 0x00};
    static const uint8_t respcmd58[6] = {0xFF, 0x00, 0xC0, 0xFF, 0x80, 0x00};

    if(mosiptr >= 6) {
        if(strcmp(cmd00, &mosi[mosiptr-6]) == 0) {
            // set miso
            misoptr = 0;
            mosiptr = 0;

            // set buffer
            static const unsigned int l = 2;
            memcpy(miso, respcmd00, l);
            memset(&miso[l], 0xFF, 1024-l);

            // reset mosipointer
            mosiptr = 0;
            return;
        }
        if(strcmp(cmd08, &mosi[mosiptr-6]) == 0) {
            // reset pointers
            misoptr = 0;
            mosiptr = 0;

            // set buffer
            static const unsigned int l = 6;
            memcpy(miso, respcmd08, l);
            memset(&miso[l], 0xFF, 1024-l);

            return;
        }
        if(strcmp(cmd55, &mosi[mosiptr-6]) == 0) {
            // reset pointers
            misoptr = 0;
            mosiptr = 0;

            // set buffer
            static const unsigned int l = 2;
            memcpy(miso, respcmd55, l);
            memset(&miso[l], 0xFF, 1024-l);

            return;
        }
        if(strcmp(acmd41, &mosi[mosiptr-6]) == 0) {
            // reset pointers
            misoptr = 0;
            mosiptr = 0;

            // set buffer
            static const unsigned int l = 2;
            memcpy(miso, respacmd41, l);
            memset(&miso[l], 0xFF, 1024-l);

            return;
        }
        if(strcmp(cmd58, &mosi[mosiptr-6]) == 0) {
            // reset pointers
            misoptr = 0;
            mosiptr = 0;

            // set buffer
            static const unsigned int l = 6;
            memcpy(miso, respcmd58, l);
            memset(&miso[l], 0xFF, 1024-l);

            return;
        }
        if(mosi[mosiptr-6] == (17|0x40) && mosi[mosiptr-1] == 0x01) {
            uint32_t addr = (mosi[mosiptr-5] << 24) |
                            (mosi[mosiptr-4] << 16) |
                            (mosi[mosiptr-3] << 8)  |
                            (mosi[mosiptr-2]);

            // reset pointers
            misoptr = 0;
            mosiptr = 0;
            memset(miso, 0xFF, 1024);

            // copy data
            fseek(sdfile, addr * 512, SEEK_SET);
            miso[0] = 0xFF; // wait byte
            miso[1] = 0x01; // response to CMD17
            miso[2] = 0xFF; // another wait byte
            miso[3] = 0xFE; // pre-block byte
            size_t nrbytes = fread(&miso[4], 1, 512, sdfile);        // data
            //printf("%i ", nrbytes);
            uint16_t checksum = crc16_xmodem(&miso[3], 0x200);
            miso[516] = checksum >> 8;
            miso[517] = checksum & 0xFF;

            //printf("%02X %02X ", miso[514], miso[515]);
            //printf("%04X ", checksum);
        }
    }
}
