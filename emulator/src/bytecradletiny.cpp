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

#include "bytecradletiny.h"

/**
 * @brief Construct a new ByteCradleTiny object
 * 
 * @param romfile path to the ROM file
 */
ByteCradleTiny::ByteCradleTiny(const std::string& romfile) {
    // initialize CPU
    cpu = vrEmu6502New(CPU_W65C02, memread, memwrite, this);
    irq = vrEmu6502Int(cpu);

    // set memory
    memset(this->ram, 0x00, sizeof(this->ram));
    this->load_file_into_memory(romfile.c_str(), this->rom, sizeof(this->rom));

    // set interface chips
    this->acia = std::make_unique<ACIA>(ByteCradleTiny::ACIA_MASK, 
                                        ByteCradleTiny::ACIA_MASK_SIZE, 
                                        irq);
}

/**
 * @brief Destroy the Byte Cradle Tiny object
 * 
 */
ByteCradleTiny::~ByteCradleTiny() {
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
uint8_t ByteCradleTiny::memread(VrEmu6502 *cpu, uint16_t addr, bool isDbg) {
    auto obj = static_cast<ByteCradleTiny*>(vrEmu6502GetUserData(cpu));
    auto &ram = obj->get_ram();
    auto &rom = obj->get_rom();
    auto& keybuffer = obj->get_keybuffer();
    auto& irq = obj->irq;

    // ROM chip
    if(addr >= 0x8000) {
        return rom[addr - 0x8000];
    }

    // lower RAM
    if (addr < 0x7F00) {
        return ram[addr];
    }

    if(obj->get_acia()->responds(addr)) {
        return obj->get_acia()->read(addr);
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
void ByteCradleTiny::memwrite(VrEmu6502 *cpu, uint16_t addr, uint8_t val) {
    auto obj = static_cast<ByteCradleTiny*>(vrEmu6502GetUserData(cpu));
    auto &ram = obj->get_ram();
    auto &rom = obj->get_rom();
    
    // store in lower memory
    if (addr < 0x7F00) {
        ram[addr] = val;
        return;
    }

    if(obj->get_acia()->responds(addr)) {
        obj->get_acia()->write(addr, val);
        return;
    }

    printf("[ERROR] Invalid write: %04X.\n", addr);
}