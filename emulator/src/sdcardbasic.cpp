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

#include <algorithm>
#include <iostream>
#include <cstring>

#include "sdcardbasic.h"

/**
 * @brief Construct SD-CARD interface
 * 
 * @param path to image file 
 */
SdCardBasic::SdCardBasic(const std::string& image_filename)
    : cs(false), clk(false), mosi_bit(false), miso_bit(false),
      mosi_shift_reg(0), miso_shift_reg(0), mosi_bit_count(0), miso_bit_count(0)
{
    sdfile.open(image_filename, std::ios::binary);
    if (!sdfile) {
        std::cerr << "Failed to open SD card image: " << image_filename << std::endl;
        exit(-1);
    }
}

/**
 * @brief digest SD-card commands
 * 
 */
void SdCardBasic::set_clk(bool _clk) {
    // check if clock goes from low to _clk
    if (this->clk == false && _clk == true) {

        // place current MOSI bit in the mosi shift register
        this->mosi_shift_reg = (this->mosi_shift_reg << 1) | (this->mosi_bit ? 1 : 0);
        ++this->mosi_bit_count;

        // check if eight bits have been received
        if (this->mosi_bit_count == 8) {
            this->mosi_queue.push(mosi_shift_reg);
            this->mosi_bit_count = 0;
            this->mosi_shift_reg = 0;
            digest_sd();
        }

        // check if there are any bits left to consume from miso shift register
        if(this->miso_bit_count == 0) {
            if(this->miso_queue.size() > 0) {
                this->miso_shift_reg = this->miso_queue.front();
                this->miso_queue.pop();
            } else {
                this->miso_shift_reg = 0xFF;
            }
            this->miso_bit_count = 8;
        }

        // place MSB of miso shift register in the miso bit
        this->miso_bit = (miso_shift_reg & 0x80) != 0;
        this->miso_shift_reg <<= 1;
        --this->miso_bit_count;
    }

    this->clk = _clk;
}

void SdCardBasic::digest_sd() {
    static const std::array<uint8_t,6> cmd00 = {0x40,0x00,0x00,0x00,0x00,0x95};
    static const std::array<uint8_t,6> cmd08 = {0x48,0x00,0x00,0x01,0xAA,0x87};
    static const std::array<uint8_t,6> cmd55 = {0x77,0x00,0x00,0x00,0x00,0x01};
    static const std::array<uint8_t,6> acmd41 = {0x69,0x40,0x00,0x00,0x00,0x01};
    static const std::array<uint8_t,6> cmd58 = {0x7A,0x00,0x00,0x00,0x00,0x01};

    static const std::vector<uint8_t> respcmd00 = {0xFF, 0x01};
    static const std::vector<uint8_t> respcmd08 = {0xFF, 0x01, 0x00, 0x00, 0x01, 0xAA};
    static const std::vector<uint8_t> respcmd55 = {0xFF, 0x01};
    static const std::vector<uint8_t> respacmd41 = {0xFF, 0x00};
    static const std::vector<uint8_t> respcmd58 = {0xFF, 0x00, 0xC0, 0xFF, 0x80, 0x00};

    // discard any 0xFF bytes
    if(mosi_queue.size() == 1 && mosi_queue.front() == 0xFF) {
        mosi_queue.pop();
        return;
    }

    if (mosi_queue.size() >= 6) {
        std::array<uint8_t, 6> cmd;
        for(uint8_t i = 0; i < 6; ++i) {
            cmd[i] = mosi_queue.front();
            mosi_queue.pop();
        }

        if(cmd == cmd00) {
            load_response(respcmd00);
            return;
        }

        if(cmd == cmd08) {
            load_response(respcmd08);
            return;
        }

        if(cmd == cmd55) {
            load_response(respcmd55);
            return;
        }

        if(cmd == acmd41) {
            load_response(respacmd41);
            return;
        }

        if(cmd == cmd58) {
            load_response(respcmd58);
            return;
        }

        if(cmd[0] == (17 | 0x40) && cmd[5] == 0x01) {
            uint32_t addr =
                (cmd[1] << 24) |
                (cmd[2] << 16) |
                (cmd[3] << 8)  |
                (cmd[4]);
            load_response_cmd17(addr);
            return;
        }
    }
}

/**
 * @brief Load a response to the MISO queue
 * 
 * @param resp response array
 */
void SdCardBasic::load_response(const std::vector<uint8_t>& resp) {
    for (size_t i = 0; i < resp.size(); ++i) {
        this->miso_queue.push(resp[i]);
    }
}

/**
 * @brief Load a response to the MISO queue for CMD17
 * 
 * @param addr SD-card 512-byte address
 */
void SdCardBasic::load_response_cmd17(uint32_t addr) {
    if (!sdfile.is_open()) return;

    sdfile.seekg(addr * 512, std::ios::beg);
    if (!sdfile) return;

    miso_queue.push(0xFF);  // wait
    miso_queue.push(0x00);  // command accepted
    miso_queue.push(0xFF);  // few wait bytes
    miso_queue.push(0xFF);  // few wait bytes
    miso_queue.push(0xFF);  // few wait bytes
    miso_queue.push(0xFF);  // few wait bytes
    miso_queue.push(0xFE);  // data start token

    char buffer[512];
    sdfile.read(buffer, 512);
    size_t bytes_read = sdfile.gcount();
    for (size_t i = 0; i < bytes_read; ++i) {
        miso_queue.push(static_cast<uint8_t>(buffer[i]));
    }

    uint16_t checksum = crc16_xmodem(reinterpret_cast<uint8_t*>(buffer), 512);
    miso_queue.push((checksum >> 8) & 0xFF);
    miso_queue.push(checksum & 0xFF);
}

/**
 * @brief Calculate CRC16 using XMODEM polynomial
 * 
 * @param data pointer to data
 * @param len size of data
 * @return uint16_t checksum
 */
uint16_t SdCardBasic::crc16_xmodem(const uint8_t* data, size_t len) {
    uint16_t crc = 0x0000;
    for (size_t i = 0; i < len; ++i) {
        crc ^= static_cast<uint16_t>(data[i]) << 8;
        for (int j = 0; j < 8; j++) {
            if (crc & 0x8000)
                crc = (crc << 1) ^ 0x1021;
            else
                crc <<= 1;
        }
    }
    return crc;
}