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
#include "via.h"

/**
 * @brief ByteCradle 6502 Tiny Board Emulator
 * 
 */
class ByteCradleMini : public ByteCradleBoard {
private:
    uint8_t ram[1024 * 512];    // 512KB RAM
    uint8_t rom[1024 * 512];    // 512KB ROM
    uint8_t rombank;
    uint8_t rambank;

    std::unique_ptr<VIA> via;     // Pointer to the VIA object
public:
    // Constants for memory-mapped device masks and mask sizes
    static constexpr uint16_t ACIA_MASK         = 0x7F00;
    static constexpr uint8_t  ACIA_MASK_SIZE    = 10;

    static constexpr uint16_t VIA_MASK          = 0x7F40;
    static constexpr uint8_t  VIA_MASK_SIZE     = 10;

    static constexpr uint16_t BANKMASK           = 0xFFC0;
    static constexpr uint16_t ROMBANK_PATTERN    = 0x7F80;
    static constexpr uint16_t RAMBANK_PATTERN    = 0x7FC0;

    /**
     * @brief Construct a new ByteCradleMini object
     * 
     * @param romfile path to the ROM file
     * @param sdcardfile path to the SD card file
     * @param debug_mode whether to run in debugging mode
     */
    ByteCradleMini(const std::string& romfile, 
                   const std::string& sdcardfile,
                   bool _debug_mode = false
                  );

    /**
     * @brief Destroy the Byte Cradle Tiny object
     * 
     */
    ~ByteCradleMini() override;

    /**
     * @brief Get reference to the RAM array
     * 
     * @return reference to RAM array
     */
    inline auto& get_ram() { return ram; }

    /**
     * @brief Get reference to the ROM array
     * 
     * @return reference to ROM array
     */
    inline const auto& get_rom() const { return rom; }

    /**
     * @brief Get the current RAM bank
     * 
     * @return uint8_t current RAM bank number
     */
    inline uint8_t get_rambank() const { return this->rambank; }

    /**
     * @brief Set the current RAM bank
     * 
     * @param bank RAM bank number to set
     */
    inline void set_rambank(uint8_t bank) { this->rambank = bank & 0x3F; }

    /**
     * @brief Get the current ROM bank
     * 
     * @return uint8_t current ROM bank number
     */
    inline uint8_t get_rombank() const { return this->rombank; }

    /**
     * @brief Set the current ROM bank
     * 
     * @param bank ROM bank number to set
     */
    inline void set_rombank(uint8_t bank) { this->rombank = bank & 0x3F; }

    /**
     * @brief Get reference to the RAM array
     * 
     * @return reference to VIA chip
     */
    inline auto& get_via() { return this->via; }

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
