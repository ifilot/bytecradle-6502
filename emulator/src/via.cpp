#include "via.h"

VIA::VIA(uint16_t _basemask, uint8_t bitmasksize, vrEmu6502Interrupt *_irq)
    : basemask(_basemask), ddra(0), ddrb(0), ora(0), orb(0) {

    this->mask = static_cast<uint16_t>(0xFFFF << (16 - bitmasksize));
}

uint8_t VIA::read(uint16_t addr) {
    uint8_t result = 0xFF;

    switch (addr & 0x0F) {
        case VIA_REG_ORB:
            result = (orb & ddrb) | (compute_portb_input() & ~ddrb);
            break;
        case VIA_REG_ORA:
            result = (ora & ddra) | (compute_porta_input() & ~ddra);
            break;
        case VIA_REG_DDRB:
            result = ddrb;
            break;
        case VIA_REG_DDRA:
            result = ddra;
            break;
        default:
            result = 0xFF; // Unimplemented registers
            break;
    }

    return result;
}

void VIA::create_sdcard_and_attach(const std::string& image_filename) {
    this->sdcard = std::make_unique<SdCardBasic>(image_filename);
    if (this->sdcard) {
        sdcard->set_cs(true); // Set CS high initially
        update_outputs();
    }
}

void VIA::write(uint16_t addr, uint8_t data) {
    switch (addr & 0x0F) {
        case VIA_REG_ORB:
            orb = data;
            update_outputs();
            break;
        case VIA_REG_ORA:
            ora = data;
            update_outputs();
            break;
        case VIA_REG_DDRB:
            ddrb = data;
            update_outputs();
            break;
        case VIA_REG_DDRA:
            ddra = data;
            update_outputs();
            break;
        default:
            // Ignore writes to unimplemented registers
            break;
    }
}

void VIA::tick() {
    // Future timers could be emulated here
}

void VIA::update_outputs() {
    if (this->sdcard) {
        bool cs = (ora & (1 << 3)) != 0;   // PA3 = CS
        bool clk = (ora & (1 << 2)) != 0;  // PA2 = CLK
        bool mosi = (ora & (1 << 1)) != 0; // PA1 = MOSI

        this->sdcard->set_cs(cs);
        this->sdcard->set_clk(clk);
        this->sdcard->set_mosi(mosi);

        //std::cout << "VIA: CS=" << cs << ", CLK=" << clk << ", MOSI=" << mosi << std::endl;
    }
}

uint8_t VIA::compute_porta_input() const {
    uint8_t input = 0x00;

    if (sdcard) {
        if (sdcard->get_miso()) {
            input |= (1 << 0); // PA0 = MISO from SD card
        }
    }

    return input;
}

uint8_t VIA::compute_portb_input() const {
    return 0x00; // Nothing connected to ORA for now
}
