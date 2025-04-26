/**************************************************************************
 *                                                                        *
 *   Author: Ivo Filot <ivo@ivofilot.nl>                                  *
 *                                                                        *
 *   ByteCradle 6502 EMULATOR is free software:                           *
 *   you can redistribute it and/or modify it under the terms of the      *
 *   GNU General Public License as published by the Free Software         *
 *   Foundation, either version 3 of the License, or (at your option)     *
 *   any later version.                                                   *
 *                                                                        *
 *   This program is distributed in the hope that it will be useful,      *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty          *
 *   of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.              *
 *   See the GNU General Public License for more details.                 *
 *                                                                        *
 *   You should have received a copy of the GNU General Public License    *
 *   along with this program.  If not, see http://www.gnu.org/licenses/.  *
 *                                                                        *
 **************************************************************************/

#include "acia.h"

/**
 * @brief Construct a new ACIA object
 * 
 * @param _basemask base address mask
 * @param bitmasksize size of the bitmask
 * @param _irq pointer to the interrupt handler
 */
ACIA::ACIA(uint16_t _basemask, uint8_t bitmasksize, vrEmu6502Interrupt *_irq)
    : basemask(_basemask), irq(_irq) {
    
    this->mask = static_cast<uint16_t>(0xFFFF << (16 - bitmasksize));
}

/**
 * @brief Receives a keypress from the keyboard and places it into the key
 *        buffer
 *
 * @param ch 
 */
void ACIA::keypress(char ch) {
    if (this->keybuffer.size() >= 16) {
        this->keybuffer.pop_front(); // Drop the oldest key
    }
    this->keybuffer.push_back(ch);

    *irq = IntRequested;
}

/**
 * @brief read implementation for the 65C51 ACIA
 * 
 * @param addr 
 * @return uint8_t response
 */
uint8_t ACIA::read(uint16_t addr) {
    uint8_t offset = addr & 0x03;

    switch(offset) {
        case ACIA_DATA: // Read UART content
            if (!keybuffer.empty()) {
                *irq = IntCleared;
                char ch = keybuffer.front();
                keybuffer.pop_front();

                if (ch == 0x0A) { // if line feed
                    ch = 0x0D;    // transform to carriage return
                }

                return ch;
            }
        break;

        case ACIA_STAT:
            return this->keybuffer.size() > 0 ? 0x08 : 0x00;
        break;

        case ACIA_CMD:
            return this->registers[offset];
        break;

        case ACIA_CTRL:
            return this->registers[offset];
        break;
    }

    return 0xFF;
}

/**
 * @brief Write implementation for the 65C51 ACIA
 * 
 * @param addr memory address
 * @param data value to be written
 */
void ACIA::write(uint16_t addr, uint8_t data) {
    uint8_t offset = addr & 0x03;

    switch(offset) {
        case ACIA_DATA: // place data onto serial register
            std::cout << data << std::flush;
        break;

        case ACIA_CMD:
            this->registers[offset] = data;
        break;

        case ACIA_CTRL:
            this->registers[offset] = data;
        break;
    }
}