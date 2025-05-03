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

#pragma once

#include "sdcarddevice.h"
#include <vector>
#include <queue>
#include <fstream>
#include <array>

/**
 * @brief SD-CARD interface
 * 
 */
class SdCardBasic : public SdCardDevice {
public:
    /**
     * @brief Construct SD-CARD interface
     * 
     * @param path path to image file 
     */
    SdCardBasic(const std::string& image_filename, bool _verbose = false);

    /**
     * @brief Receive /CS line signal
     * 
     * @param _cs /CS line signal
     */
    inline void set_cs(bool _cs) override {
        this->cs = _cs;
    }
    
    /**
     * @brief Receive MOSI line signal
     * 
     * @return MOSI line signal
     */
    inline void set_mosi(bool bit) override {
        this->mosi_bit = bit;
    }

    /**
     * @brief Receive MISO line signal
     * 
     * @return MISO line signal
     */
    inline bool get_miso() const override {
        return this->miso_bit;
    }

    /**
     * @brief Set CLK line signal
     * 
     * @param _clk CLK line signal
     */
    void set_clk(bool _clk) override;

private:
    std::queue<uint8_t> mosi_queue;     // queue for incoming MOSI data
    std::queue<uint8_t> miso_queue;     // queue for outgoing MISO data
    
    bool cs;                            // /CS line signal
    bool clk;                           // CLK line signal
    bool mosi_bit;                      // MOSI line signal
    bool miso_bit;                      // MISO line signal
    
    uint8_t mosi_shift_reg;             // shift register for incoming MOSI data
    uint8_t miso_shift_reg;             // shift register for outgoing MISO data
    
    uint8_t mosi_bit_count;             // number of bits received in the current byte
    uint8_t miso_bit_count;             // number of bits remaining in the current byte

    std::ifstream sdfile;               // file stream for the SD card image

    bool verbose = false;               // verbose mode

    /**
     * @brief digest SD-card commands
     * 
     */
    void digest_sd();

    /**
     * @brief Load a response to the MISO queue
     * 
     * @param resp response array
     */
    void load_response(const std::vector<uint8_t>& resp);

    /**
     * @brief Load a response to the MISO queue for CMD17
     * 
     * @param addr SD-card 512-byte address
     */
    void load_response_cmd17(uint32_t addr);
    
    /**
     * @brief Calculate CRC16 using XMODEM polynomial
     * 
     * @param data pointer to data
     * @param len size of data
     * @return uint16_t checksum
     */
    uint16_t crc16_xmodem(const uint8_t* data, size_t len);
};