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

/**
 * @brief Memory and I/O buffers and pointers
 * 
 * This section defines the memory and I/O buffers used by the emulator,
 * as well as pointers and file handles for various operations.
 */
uint8_t lowram[0x4000*2];       // 32 KiB LOWRAM
uint8_t highram[32][0x4000];    // 32 x 16 KiB HIGHRAM
uint8_t rambank = 0;

uint8_t rom[0x4000];            // 16 KiB ROM
vrEmu6502Interrupt *irq;        // Pointer to IRQ interrupt
char keybuffer[0x10];           // Buffer for keyboard input
char* keybuffer_ptr;            // Pointer to the current position in the key buffer
uint8_t mosi[1024];             // Buffer for MOSI (Master Out Slave In) data
uint8_t miso[1024];             // Buffer for MISO (Master In Slave Out) data
unsigned int mosiptr;           // Pointer to the current position in the MOSI buffer
unsigned int misoptr;           // Pointer to the current position in the MISO buffer
FILE *sdfile;                   // File handle for the SD card image

/**
 * @brief Initialize ROM from file
 * 
 * @param filename file address
 */
void initrom(const char *filename) {
    // check whether file exists and is readable, else exit
    check_file_exists(filename);

    FILE *file = fopen(filename, "rb");
    if (file == NULL) {
        fprintf(stderr, "Error opening file\n");
        return;
    }

    static const size_t filesize = 0x4000;
    size_t bytes_read = fread(rom, 1, filesize, file);
    if(bytes_read != filesize) {
        fprintf(stderr, "File read error (size mismatch)\n");
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
    // check whether file exists and is readable, else exit
    check_file_exists(filename);

    sdfile = fopen(filename, "rb");
    if (sdfile == NULL) {
        fprintf(stderr, "Error opening file\n");
        return;
    }
}

/**
 * @brief Insert program and run it
 *
 * @param filename file URL
 */
uint16_t init_program(const char *filename) {
    check_file_exists(filename);

    FILE *file = fopen(filename, "rb");
    if (file == NULL) {
        fprintf(stderr, "Error opening file\n");
        exit(EXIT_FAILURE);
    }

    // Get file size
    fseek(file, 0, SEEK_END);
    size_t filesize = ftell(file);
    rewind(file);

    if (filesize < 2) {  // Must be at least 2 bytes for address check
        fprintf(stderr, "File too small\n");
        fclose(file);
        exit(EXIT_FAILURE);
    }

    // Read first two bytes to determine deployment address
    uint16_t deploy_address;
    if (fread(&deploy_address, 1, 2, file) != 2) {
        fprintf(stderr, "Error reading deployment address\n");
        fclose(file);
        exit(EXIT_FAILURE);
    }

    // Check if program will surpass 0x8000
    if (deploy_address + filesize > 0x8000) {
        fprintf(stderr, "Program exceeds 0x8000.\n");
        exit(EXIT_FAILURE);
    }

    // Read the file into the appropriate memory location
    rewind(file);
    uint8_t *memory = &lowram[deploy_address];
    size_t bytes_read = fread(memory, 1, filesize, file);  // Subtract first 2 bytes
    if (bytes_read != filesize) {
        fprintf(stderr, "File read error (size mismatch)\n");
        exit(EXIT_FAILURE);
    }

    fclose(file);
    printf("Program loaded at 0x%04X\n", deploy_address);

    return deploy_address;
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
    // ROM chip
    if(addr >= 0xC000) {
        return rom[addr - 0xC000];
    }

    // lower RAM
    if (addr < 0x7F00) {
        return lowram[addr];
    }

    // upper RAM
    if(addr >= 0x8000 && addr < 0xC000) {
        return highram[rambank][addr - 0x8000];
    }

    // I/O space
    switch(addr) {
        case ACIA_DATA:     // read content UART
            if(keybuffer_ptr > keybuffer) {
                *irq = IntCleared;
                char ch = *(--keybuffer_ptr);

                // do some key mapping
                if(ch == 0x0A) {    // if line feed
                    ch = 0x0D;      // transform to carriage return
                }

                return ch;
            }
        break;
        case ACIA_STAT:     // read UART status register
            if(keybuffer_ptr > keybuffer) {
                return 0x08;
            } else {
                return 0x00;
            }
        break;

        case ACIA_CMD:
            return lowram[addr];
        break;

        case ACIA_CTRL:
            return lowram[addr];
        break;

        case SERIAL:        // sd-card interface
            uint8_t val = miso[misoptr++];
            if(misoptr == 1024) {
                misoptr = 0;
            }
            return val;
        break;

        case RAMBANK:
            return rambank;
        break;

        case SELECT:   // SD-CARD wiring
            return 0x00; // do nothing
        break;

        case DESELECT: // SD-CARD wiring
            return 0x00; // do nothing
        break;

        default:
            printf("[ERROR] Invalid read: %04X.\n", addr);
            exit(EXIT_FAILURE);
        break;
    }
}

/**
 * @brief Write to memory function
 * 
 * @param addr memory address
 * @param val value to write
 */
void memwrite(uint16_t addr, uint8_t val) {
    // store in lower memory
    if (addr < 0x7F00) {
        lowram[addr] = val;
        return;
    }

    // store in upper memory
    if(addr >= 0x8000 && addr < 0xC000) {
        highram[rambank][addr - 0x8000] = val;
        return;
    }

    // I/O space
    switch(addr) {
        case ACIA_DATA: // place data onto serial register
            putchar(val);
            fflush(stdout);
        break;

        case ACIA_CMD:
            lowram[addr] = val;
        break;

        case ACIA_CTRL:
            lowram[addr] = val;
        break;

        case SERIAL:    // store content for serial register
            lowram[addr] = val;
        break;

        case CLKSTART:  // push content of serial register to SD-card
            mosi[mosiptr++] = lowram[SERIAL];
            digest_sd();

            if(mosiptr == 1024) {
                mosiptr = 0;
            }
        break;

        case RAMBANK:   // set RAMBANK
            rambank = val;
        break;

        case SELECT:   // SD-CARD wiring
        break;

        case DESELECT: // SD-CARD wiring
        break;

        default:
            printf("[ERROR] Invalid write: %04X.\n", addr);
        break;
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
            uint16_t checksum = crc16_xmodem(&miso[4], 0x200);

            // store in big endian format
            miso[516] = checksum >> 8;
            miso[517] = checksum & 0xFF;

            //printf("%02X %02X ", miso[514], miso[515]);
            //printf("%04X ", checksum);
        }
    }
}

/**
 * @brief Check whether file exists
 * 
 * @param filename file address
 */
void check_file_exists(const char* filename) {
    if (access(filename, F_OK) == 0) {
        if (access(filename, R_OK) != 0) {
            fprintf(stderr, "File '%s' is not readable", filename);
            exit(EXIT_FAILURE);
            return;
        }   
    } else {
        fprintf(stderr, "File '%s' does NOT exist.\n", filename);
        exit(EXIT_FAILURE);
        return;
    }
}