/**************************************************************************
 *                                                                        *
 *   Author: Ivo Filot <ivo@ivofilot.nl>                                  *
 *                                                                        *
 *   ByteCradle 6502 EMULATOR is free software:                           *
 *   you can redistribute it and/or modify it under the terms of the      *
 *   GNU General Public License as published by the Free Software         *
 *   Foundation, either version 3 of the License, or (at your option)     *
 *   any later version.                                                   *
 *                                                                        *
 *   This program is distributed in the hope that it will be useful,      *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty          *
 *   of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.              *
 *   See the GNU General Public License for more details.                 *
 *                                                                        *
 *   You should have received a copy of the GNU General Public License    *
 *   along with this program.  If not, see http://www.gnu.org/licenses/.  *
 *                                                                        *
 **************************************************************************/

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

    std::streamsize file_size = file.tellg();
    file.seekg(0, std::ios::beg);

    if (file_size > static_cast<std::streamsize>(sz))
    {
        std::cerr << "File too large to fit into memory buffer: " << filename << std::endl;
        return false;
    }

    // Clear entire buffer first
    std::memset(memory, 0, sz);

    if (!file.read(reinterpret_cast<char*>(memory), file_size))
    {
        std::cerr << "Failed to read file: " << filename << std::endl;
        return false;
    }

    return true;
}