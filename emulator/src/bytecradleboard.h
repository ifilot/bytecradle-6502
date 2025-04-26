#pragma once

#include <iostream>
#include <stdint.h>
#include <fstream>
#include <iostream>
#include <cstring>
#include <memory>

#include "vrEmu6502/vrEmu6502.h"
#include "acia.h"

/**
 * @brief ByteCradle Board Emulator - Base Class
 * 
 */
class ByteCradleBoard {
public:
    /**
     * @brief Construct a new Byte Cradle Board object
     * 
     */
    ByteCradleBoard();

    /**
     * @brief Destroy the Byte Cradle Board object
     * 
     */
    virtual ~ByteCradleBoard();
    
    /**
     * @brief Progresses the CPU by one tick
     * 
     */
    inline void tick() {
        vrEmu6502Tick(this->cpu);
    }

    /**
     * @brief Resets the CPU, clearing the registers and setting the program 
     *        counter to 0xFFFC; note that the CPU always needs to be reset
     *        before it can be used.
     * 
     */
    inline void reset() {
        vrEmu6502Reset(this->cpu);
    }

    /**
     * @brief Receives a keypress from the keyboard and places it into the key
     *        buffer
     *
     * @param ch 
     */
    inline void keypress(char ch) {
        this->acia->keypress(ch);
    }

    inline auto& get_acia() { return this->acia; }

protected:
    std::unique_ptr<ACIA> acia;     // Pointer to the ACIA object

    VrEmu6502 *cpu;
    vrEmu6502Interrupt *irq;

    inline auto& get_keybuffer() { return this->acia->get_keybuffer(); }
    inline auto& get_irq() { return irq; }

    /**
     * @brief Load a file into memory (typically ROM)
     * 
     * @param filename path to the file
     * @param memory pointer to the memory buffer
     * @param sz size of the memory buffer
     * @return true if successful, false otherwise
     */
    bool load_file_into_memory(const char* filename, uint8_t* memory, size_t sz);
};