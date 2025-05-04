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

#pragma once

#include "bytecradleboard.h"

/**
 * @brief ByteCradle 6502 Tiny Board Emulator
 * 
 */
class ByteCradleTiny : public ByteCradleBoard {
private:
    uint8_t ram[0x8000];
    uint8_t rom[0x8000];
public:
    // Constants for memory-mapped device masks and mask sizes
    static constexpr uint16_t ACIA_MASK      = 0x7F00;
    static constexpr uint8_t  ACIA_MASK_SIZE = 12;

    /**
     * @brief Construct a new ByteCradleTiny object
     * 
     * @param romfile path to the ROM file
     * @param debug_mode whether to run in debugging mode
     */
    ByteCradleTiny(const std::string& romfile, bool _debug_mode = false);

    /**
     * @brief Destroy the Byte Cradle Tiny object
     * 
     */
    ~ByteCradleTiny() override;

    /**
     * @brief Get reference to the RAM array
     * 
     * @return auto& 
     */
    inline auto& get_ram() { return ram; }

    /**
     * @brief Get reference to the ROM array
     * 
     * @return auto& 
     */
    inline auto& get_rom() { return rom; }

private:
    /**
     * @brief Read memory function
     * 
     * This function also needs to handle any memory mapped I/O devices
     * 
     * @param addr memory address
     * @param isDbg 
     * @return uint8_t value at memory address
     */
    static uint8_t memread(VrEmu6502 *cpu, uint16_t addr, bool isDbg);

    /**
     * @brief Write to memory function
     * 
     * @param addr memory address
     * @param val value to write
     */
    static void memwrite(VrEmu6502 *cpu, uint16_t addr, uint8_t val);
};
