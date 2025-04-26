#include "ByteCradleMini.h"

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
    this->acia = std::make_unique<ACIA>(ACIA_MASK, ACIA_MASK_SIZE, irq);
    this->via = std::make_unique<VIA>(VIA_MASK, VIA_MASK_SIZE, irq);
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
    auto &rom = obj->get_rom();
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

    // ACIA chip
    if(obj->get_acia()->responds(addr)) {
        return obj->get_acia()->read(addr);
    }
    
    // VIA chip
    if(obj->get_via()->responds(addr)) {
        return obj->get_via()->read(addr);
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
    auto &rom = obj->get_rom();
    
    // store in lower memory
    if (addr < 0x7F00) {
        ram[addr] = val;
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