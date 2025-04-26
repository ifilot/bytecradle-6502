#include "sdcardbasic.h"
#include <algorithm>
#include <iostream>
#include <cstring>

SdCardBasic::SdCardBasic(const std::string& image_filename)
    : cs_active(false), clk_high(false), mosi_bit(false),
      mosi_shift_reg(0), miso_shift_reg(0), bit_count(0)
{
    sdfile.open(image_filename, std::ios::binary);
    if (!sdfile) {
        std::cerr << "Failed to open SD card image: " << image_filename << std::endl;
    }
}

void SdCardBasic::set_cs(bool active) {
    cs_active = active;

    if (!cs_active) {
        mosi_buffer.clear();
        miso_queue = std::queue<uint8_t>();
        mosi_shift_reg = 0;
        miso_shift_reg = 0;
        //bit_count = 0;
    }
}

void SdCardBasic::set_clk(bool high) {
    if (clk_high == false && high == true && !cs_active) {
        mosi_shift_reg = (mosi_shift_reg << 1) | (mosi_bit ? 1 : 0);
        ++bit_count;

        if (bit_count == 8) {
            mosi_buffer.push_back(mosi_shift_reg);
            std::cout << "Received byte:" << std::hex << (unsigned int)mosi_shift_reg << std::endl;
            digest_sd();
            bit_count = 0;
            mosi_shift_reg = 0;
        }

        // Shift out MISO bit
        if (!miso_queue.empty()) {
            miso_shift_reg = miso_queue.front();
            miso_queue.pop();
        } else {
            miso_shift_reg = 0xFF;
        }
    }

    clk_high = high;
}

void SdCardBasic::set_mosi(bool high) {
    mosi_bit = high;
}

bool SdCardBasic::get_miso() const {
    return (miso_shift_reg & 0x80) != 0;
}

void SdCardBasic::digest_sd() {
    static const uint8_t cmd00[6] = {0x40,0x00,0x00,0x00,0x00,0x95};
    static const uint8_t cmd08[6] = {0x48,0x00,0x00,0x01,0xAA,0x87};
    static const uint8_t cmd55[6] = {0x77,0x00,0x00,0x00,0x00,0x01};
    static const uint8_t acmd41[6] = {0x69,0x40,0x00,0x00,0x00,0x01};
    static const uint8_t cmd58[6] = {0x7A,0x00,0x00,0x00,0x00,0x01};

    static const uint8_t respcmd00[2] = {0xFF, 0x01};
    static const uint8_t respcmd08[6] = {0xFF, 0x01, 0x00, 0x00, 0x01, 0xAA};
    static const uint8_t respcmd55[2] = {0xFF, 0x01};
    static const uint8_t respacmd41[2] = {0xFF, 0x00};
    static const uint8_t respcmd58[6] = {0xFF, 0x00, 0xC0, 0xFF, 0x80, 0x00};

    if (mosi_buffer.size() >= 6) {
        if (std::equal(mosi_buffer.end() - 6, mosi_buffer.end(), cmd00)) {
            load_response(respcmd00, 2);
            mosi_buffer.clear();
            return;
        }
        if (std::equal(mosi_buffer.end() - 6, mosi_buffer.end(), cmd08)) {
            load_response(respcmd08, 6);
            mosi_buffer.clear();
            return;
        }
        if (std::equal(mosi_buffer.end() - 6, mosi_buffer.end(), cmd55)) {
            load_response(respcmd55, 2);
            mosi_buffer.clear();
            return;
        }
        if (std::equal(mosi_buffer.end() - 6, mosi_buffer.end(), acmd41)) {
            load_response(respacmd41, 2);
            mosi_buffer.clear();
            return;
        }
        if (std::equal(mosi_buffer.end() - 6, mosi_buffer.end(), cmd58)) {
            load_response(respcmd58, 6);
            mosi_buffer.clear();
            return;
        }

        // Handle CMD17 (read single block)
        if (mosi_buffer[mosi_buffer.size() - 6] == (17 | 0x40)) {
            uint32_t addr =
                (mosi_buffer[mosi_buffer.size() - 5] << 24) |
                (mosi_buffer[mosi_buffer.size() - 4] << 16) |
                (mosi_buffer[mosi_buffer.size() - 3] << 8)  |
                (mosi_buffer[mosi_buffer.size() - 2]);
            load_data_block(addr);
            mosi_buffer.clear();
            return;
        }
    }
}

void SdCardBasic::load_response(const uint8_t* data, size_t len) {
    for (size_t i = 0; i < len; ++i) {
        miso_queue.push(data[i]);
    }
    for (size_t i = len; i < 512; ++i) {
        miso_queue.push(0xFF); // Fill with idle
    }
}

void SdCardBasic::load_data_block(uint32_t addr) {
    if (!sdfile.is_open()) return;

    sdfile.seekg(addr * 512, std::ios::beg);
    if (!sdfile) return;

    miso_queue.push(0xFF); // wait
    miso_queue.push(0x01); // command accepted
    miso_queue.push(0xFF);
    miso_queue.push(0xFE); // data start token

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