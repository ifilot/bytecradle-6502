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

void VIA::write(uint16_t addr, uint8_t data) {
    switch (addr & 0x0F) {
        case VIA_REG_ORB:
            orb = data;
            update_outputs();
            break;
        case VIA_REG_ORA:
            ora = data;
            // (no outputs hooked up on ORA yet)
            break;
        case VIA_REG_DDRB:
            ddrb = data;
            update_outputs();
            break;
        case VIA_REG_DDRA:
            ddra = data;
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

}

uint8_t VIA::compute_porta_input() const {
    return 0x00; // Nothing connected to ORA for now
}

uint8_t VIA::compute_portb_input() const {
    return 0x00; // Nothing connected to ORA for now
}
