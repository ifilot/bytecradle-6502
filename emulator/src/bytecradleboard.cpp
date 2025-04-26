#include "bytecradleboard.h"

/**
 * @brief Construct a new Byte Cradle Board object
 * 
 */
ByteCradleBoard::ByteCradleBoard()
    : cpu(nullptr) {
}

/**
 * @brief Destroy the Byte Cradle Board object
 * 
 */
ByteCradleBoard::~ByteCradleBoard() {
    if (cpu) {
        vrEmu6502Destroy(cpu);
        cpu = nullptr;
    }
}

/**
 * @brief Load a file into memory (typically ROM)
 * 
 * @param filename path to the file
 * @param memory pointer to the memory buffer
 * @param sz size of the memory buffer
 * @return true if successful, false otherwise
 */
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
