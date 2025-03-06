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

#pragma once

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <termios.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>

#include "vrEmu6502/vrEmu6502.h"
#include "crc16.h"
#include "screen.h"

#define ROMBANK   0x7000
#define RAMBANK   0x7001
#define ACIA_DATA 0x7F04
#define ACIA_STAT 0x7F05
#define ACIA_CMD  0x7F06
#define ACIA_CTRL 0x7F07
#define SERIAL    0x7F20
#define CLKSTART  0x7F21
#define DESELECT  0x7F22
#define SELECT    0x7F23

extern vrEmu6502Interrupt *irq;
extern char keybuffer[0x10];
extern char* keybuffer_ptr;

/**
 * @brief Initialize ROM from file
 * 
 * @param filename file URL
 */
void initrom(const char *filename);

/**
 * @brief Open file pointer to SD card image
 *
 * @param filename file URL
 */
void init_sd(const char *filename);

/**
 * @brief Insert program and run it
 *
 * @param filename file URL
 */
uint16_t init_program(const char *filename);

/**
 * Close SD-card pointer
 */
void close_sd();

/**
 * @brief Read memory function
 * 
 * This function also needs to handle any memory mapped I/O devices
 * 
 * @param addr memory address
 * @param isDbg 
 * @return uint8_t value at memory address
 */
uint8_t memread(uint16_t addr, bool isDbg);

/**
 * @brief Write to memory function
 * 
 * @param addr memory address
 * @param val value to write
 */
void memwrite(uint16_t addr, uint8_t val);

/*
 * Check buffer to see if a valid SD command has been sent,
 * if so, appropriately populate the miso buffer
 */
void digest_sd();

/**
 * @brief Check whether file exists
 * 
 * @param filename file address
 */
void check_file_exists(const char* filename);