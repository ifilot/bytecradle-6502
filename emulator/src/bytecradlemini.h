#pragma once

#include "bytecradleboard.h"
#include "via.h"

// memory mapped 65C51 ACIA
#define ACIA_MASK       0x7F00
#define ACIA_MASK_SIZE  12

// memory mapped 65C22 VIA
#define VIA_MASK        0x7F10
#define VIA_MASK_SIZE   12

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
    /**
     * @brief Construct a new ByteCradleMini object
     * 
     * @param romfile path to the ROM file
     * @param sdcardfile path to the SD card file
     */
    ByteCradleMini(const std::string& romfile, const std::string& sdcardfile);

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
    inline auto& get_rom() { return rom; }

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
