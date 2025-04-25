// ByteCradleTiny.h
#pragma once

#include "bytecradleboard.h"

#define ACIA_DATA 0x7F04
#define ACIA_STAT 0x7F05
#define ACIA_CMD  0x7F06
#define ACIA_CTRL 0x7F07

class ByteCradleTiny : public ByteCradleBoard {
private:
    uint8_t ram[0x8000];
    uint8_t rom[0x8000];
public:
    ByteCradleTiny(const std::string& romfile);
    ~ByteCradleTiny() override;

    auto& get_ram() { return ram; }
    auto& get_rom() { return rom; }

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
