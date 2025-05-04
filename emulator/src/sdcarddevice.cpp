#include "sdcarddevice.h"

void SdCardDevice::print_hexdump(const uint8_t* data, size_t length, size_t start_offset) {
    const size_t bytes_per_line = 16;

    for (size_t i = 0; i < length; i += bytes_per_line) {
        // Print offset
        std::cout << std::setw(8) << std::setfill('0') << std::hex << (start_offset + i) << "  ";

        // Print hex bytes
        for (size_t j = 0; j < bytes_per_line; ++j) {
            if (i + j < length) {
                std::cout << std::setw(2) << std::setfill('0') << std::hex << static_cast<int>(data[i + j]) << " ";
            } else {
                std::cout << "   ";
            }

            if (j == 7) std::cout << " "; // extra space in middle
        }

        std::cout << " ";

        // Print ASCII characters
        for (size_t j = 0; j < bytes_per_line; ++j) {
            if (i + j < length) {
                char c = static_cast<char>(data[i + j]);
                std::cout << (std::isprint(static_cast<unsigned char>(c)) ? c : '.');
            }
        }

        std::cout << "\n";
    }

    // Reset formatting
    std::cout << std::dec << std::setfill(' ');
}
