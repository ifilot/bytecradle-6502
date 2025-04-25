#include "ByteCradleTiny.h"

ByteCradleTiny::ByteCradleTiny(const std::string& romfile) {
    cpu = vrEmu6502New(CPU_W65C02, memread, memwrite, this);
    irq = vrEmu6502Int(cpu);

    memset(this->ram, 0x00, sizeof(this->ram));
    this->load_file_into_memory(romfile.c_str(), this->rom, sizeof(this->rom));
}

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
    auto& keybuffer_ptr = obj->get_keybuffer_ptr();
    auto& irq = obj->irq;

    // ROM chip
    if(addr >= 0x8000) {
        return rom[addr - 0x8000];
    }

    // lower RAM
    if (addr < 0x7F00) {
        return ram[addr];
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
        case ACIA_STAT:
            if(keybuffer_ptr > keybuffer) {
                return 0x08;
            } else {
                return 0x00;
            }
        break;

        case ACIA_CMD:
            return ram[addr];
        break;

        case ACIA_CTRL:
            return ram[addr];
        break;

        default:
            printf("[ERROR] Invalid read: %04X.\n", addr);
            exit(EXIT_FAILURE);
        break;
    }

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

    // I/O space
    switch(addr) {
        case ACIA_DATA: // place data onto serial register
            std::cout << val << std::flush;
        break;

        case ACIA_CMD:
            ram[addr] = val;
        break;

        case ACIA_CTRL:
            ram[addr] = val;
        break;

        default:
            printf("[ERROR] Invalid write: %04X.\n", addr);
        break;
    }

}