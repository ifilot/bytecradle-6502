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

#include "bytecradlemini.h"

/**
 * @brief Construct a new ByteCradleMini object
 * 
 * @param romfile path to the ROM file
 * @param sdcardfile path to the SD card file
 */
ByteCradleMini::ByteCradleMini(const std::string& romfile, const std::string& sdcardfile) {
    cpu = vrEmu6502New(CPU_W65C02, memread, memwrite, this);
    irq = vrEmu6502Int(cpu);

    // set memory
    memset(this->ram, 0x00, sizeof(this->ram));
    this->load_file_into_memory(romfile.c_str(), this->rom, sizeof(this->rom));

    // set interface chips
    this->acia = std::make_unique<ACIA>(ByteCradleMini::ACIA_MASK, 
                                        ByteCradleMini::ACIA_MASK_SIZE, 
                                        irq);
    this->via = std::make_unique<VIA>(ByteCradleMini::VIA_MASK, 
                                      ByteCradleMini::VIA_MASK_SIZE, 
                                      irq);
    this->via->create_sdcard_and_attach(sdcardfile);
}

/**
 * @brief Destroy the Byte Cradle Tiny object
 * 
 */
ByteCradleMini::~ByteCradleMini() {
    // Destructor will call base class destructor and clean cpu
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
uint8_t ByteCradleMini::memread(VrEmu6502 *cpu, uint16_t addr, bool isDbg) {
    auto obj = static_cast<ByteCradleMini*>(vrEmu6502GetUserData(cpu));
    auto &ram = obj->get_ram();
    const auto &rom = obj->get_rom();
    auto& keybuffer = obj->get_keybuffer();
    auto& irq = obj->irq;

    // ROM chip
    if(addr >= 0xC000) {
        return rom[addr - 0xC000];
    }

    // lower RAM
    if (addr < 0x7F00) {
        return ram[addr];
    }

    // RAM banked region: $8000–$9FFF
    if (addr >= 0x8000 && addr <= 0x9FFF) {
        uint8_t rambank = obj->get_rambank();
        return ram[(addr - 0x8000) | rambank << 13];
    }
    
    // ROM banked region: $A000–$BFFF
    if (addr >= 0xA000 && addr <= 0xBFFF) {
        uint8_t rombank = obj->get_rombank();
        return rom[(addr - 0xA000) | rombank << 13];
    }

    // ACIA chip
    if(obj->get_acia()->responds(addr)) {
        return obj->get_acia()->read(addr);
    }
    
    // VIA chip
    if(obj->get_via()->responds(addr)) {
        return obj->get_via()->read(addr);
    }

    // retrieve current rombank
    if ((addr & ByteCradleMini::BANKMASK) == ROMBANK_PATTERN) {
        return obj->get_rombank();
    }

    // retrieve current rambank
    if ((addr & ByteCradleMini::BANKMASK) == RAMBANK_PATTERN) {
        return obj->get_rambank();
    }

    printf("[ERROR] Invalid write: %04X.\n", addr);

    return 0xFF;
}

/**
 * @brief Write to memory function
 * 
 * @param addr memory address
 * @param val value to write
 */
void ByteCradleMini::memwrite(VrEmu6502 *cpu, uint16_t addr, uint8_t val) {
    auto obj = static_cast<ByteCradleMini*>(vrEmu6502GetUserData(cpu));
    auto &ram = obj->get_ram();
    const auto &rom = obj->get_rom();
    
    // store in lower memory
    if (addr < 0x7F00) {
        ram[addr] = val;
        return;
    }

    // RAM banked region: $8000–$9FFF
    if (addr >= 0x8000 && addr <= 0x9FFF) {
        uint8_t rambank = obj->get_rambank();
        ram[(addr - 0x8000) | rambank << 14] = val;
    }

    // retrieve current rombank
    if ((addr & ByteCradleMini::BANKMASK) == ROMBANK_PATTERN) {
        obj->set_rombank(val);
        return;
    }

    // retrieve current rambank
    if ((addr & ByteCradleMini::BANKMASK) == RAMBANK_PATTERN) {
        obj->set_rambank(val);
        return;
    }

    // ACIA chip
    if(obj->get_acia()->responds(addr)) {
        obj->get_acia()->write(addr, val);
        return;
    }

    // VIA chip
    if(obj->get_via()->responds(addr)) {
        obj->get_via()->write(addr, val);
        return;
    }

    printf("[ERROR] Invalid write: %04X.\n", addr);

}