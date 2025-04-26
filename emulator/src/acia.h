#pragma once

#include <cstdint>
#include <vector>
#include <iostream>
#include <deque>

#include "vrEmu6502/vrEmu6502.h"

#define ACIA_DATA 0x00
#define ACIA_STAT 0x01
#define ACIA_CMD  0x02
#define ACIA_CTRL 0x03

/**
 * @brief Implementation of the 65C51 ACIA (Asynchronous Communications
 *        Interface Adapter)
 *
 */
class ACIA {
private:
    uint16_t basemask;              // basemask to respond to
    uint16_t mask;                  // address mask
    vrEmu6502Interrupt *irq;        // interrupt line
    uint8_t registers[4];           // internal registers

    std::deque<char> keybuffer;     // keyboard buffer
public:
    /**
     * @brief Construct a new ACIA object
     * 
     * @param _basemask base address mask
     * @param bitmasksize size of the bitmask
     * @param _irq pointer to the interrupt handler
     */
    ACIA(uint16_t _basemask, uint8_t bitmasksize, vrEmu6502Interrupt *_irq);

    /**
     * @brief read implementation for the 65C51 ACIA
     * 
     * @param addr 
     * @return uint8_t response
     */
    uint8_t read(uint16_t addr);

    /**
     * @brief Write implementation for the 65C51 ACIA
     * 
     * @param addr memory address
     * @param data value to be written
     */
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

    inline const auto& get_keybuffer() const {
        return this->keybuffer;
    }

    void keypress(char ch);
};
