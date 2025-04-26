#pragma once

#include "sdcarddevice.h"
#include <vector>
#include <queue>
#include <fstream>

class SdCardBasic : public SdCardDevice {
public:
    SdCardBasic(const std::string& image_filename);

    void set_cs(bool active) override;
    void set_clk(bool high) override;
    void set_mosi(bool high) override;
    bool get_miso() const override;

private:
    std::vector<uint8_t> mosi_buffer;
    std::queue<uint8_t> miso_queue;
    
    bool cs_active;
    bool clk_high;
    bool mosi_bit;
    
    uint8_t mosi_shift_reg;
    uint8_t miso_shift_reg;
    
    int bit_count;

    std::ifstream sdfile;

    void digest_sd();
    void load_response(const uint8_t* data, size_t len);
    void load_data_block(uint32_t addr);
    
    uint16_t crc16_xmodem(const uint8_t* data, size_t len);
};