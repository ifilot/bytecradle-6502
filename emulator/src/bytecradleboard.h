#pragma once

#include <iostream>
#include <stdint.h>
#include <fstream>
#include <iostream>
#include <cstring>
#include "vrEmu6502/vrEmu6502.h"

class ByteCradleBoard {
public:
    ByteCradleBoard();
    virtual ~ByteCradleBoard();
    
    inline void tick() {
        vrEmu6502Tick(this->cpu);
    }

    inline void reset() {
        vrEmu6502Reset(this->cpu);
    }

    void keypress(char ch);

protected:
    char keybuffer[0x10];           // Buffer for keyboard input
    char* keybuffer_ptr;            // Pointer to the current position in the key buffer

    VrEmu6502 *cpu;
    vrEmu6502Interrupt *irq;

    auto& get_keybuffer() { return keybuffer; }
    auto& get_keybuffer_ptr() { return keybuffer_ptr; }
    auto& get_irq() { return irq; }

    bool load_file_into_memory(const char* filename, uint8_t* memory, size_t sz);
};