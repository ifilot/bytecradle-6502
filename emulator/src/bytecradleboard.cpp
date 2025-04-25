// ByteCradleBoard.cpp

#include "ByteCradleBoard.h"

ByteCradleBoard::ByteCradleBoard()
    : cpu(nullptr) {
    this->keybuffer_ptr = this->keybuffer;
}

ByteCradleBoard::~ByteCradleBoard() {
    if (cpu) {
        vrEmu6502Destroy(cpu);
        cpu = nullptr;
    }
}

void ByteCradleBoard::keypress(char ch) {
    if (this->keybuffer_ptr < this->keybuffer + sizeof(this->keybuffer) - 1) {
        *this->keybuffer_ptr++ = ch;
    }
    *irq = IntRequested;
}

bool ByteCradleBoard::load_file_into_memory(const char* filename, uint8_t* memory, size_t sz) {
    std::ifstream file(filename, std::ios::binary | std::ios::ate);
    if (!file)
    {
        std::cerr << "Failed to open file: " << filename << std::endl;
        return false;
    }

    std::streamsize fileSize = file.tellg();
    file.seekg(0, std::ios::beg);

    if (fileSize > static_cast<std::streamsize>(sz))
    {
        std::cerr << "File too large to fit into memory buffer: " << filename << std::endl;
        return false;
    }

    if (!file.read(reinterpret_cast<char*>(memory), fileSize))
    {
        std::cerr << "Failed to read file: " << filename << std::endl;
        return false;
    }

    return true;
}
