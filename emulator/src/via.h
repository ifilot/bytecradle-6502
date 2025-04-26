#pragma once

#include <cstdint>

#include "vrEmu6502/vrEmu6502.h"

#define VIA_REG_ORB   0x00
#define VIA_REG_ORA   0x01
#define VIA_REG_DDRB  0x02
#define VIA_REG_DDRA  0x03

class VIA {
private:
    uint8_t ddra;
    uint8_t ddrb;
    uint8_t ora;
    uint8_t orb;

    void update_outputs();

    uint8_t compute_porta_input() const;
    uint8_t compute_portb_input() const;

    uint16_t basemask;
    uint16_t mask;

public:
    VIA(uint16_t _basemask, uint8_t bitmasksize, vrEmu6502Interrupt *_irq);

    uint8_t read(uint16_t addr);

    void write(uint16_t addr, uint8_t data);

    /**
     * @brief Whether the ACIA responds to the given address
     * 
     * @param addr address
     * @return true if the ACIA responds to the address
     * @return false otherwise
     */
    inline bool responds(uint16_t addr) const {
        return (addr & this->mask) == this->basemask;
    }

    void tick(); // Reserved for future timers
};
