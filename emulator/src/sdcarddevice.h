#pragma once

#include <cstdint>

/**
 * @brief Abstract base class for an SD card device.
 *        Defines the standard SPI interface methods.
 */
class SdCardDevice {
public:
    virtual void set_cs(bool active) = 0;   // Chip Select (CS) signal
    virtual void set_clk(bool high) = 0;     // Clock (CLK) signal
    virtual void set_mosi(bool high) = 0;    // Master Out Slave In (MOSI) signal
    virtual bool get_miso() const = 0;       // Master In Slave Out (MISO) signal

    virtual ~SdCardDevice() = default;       // Virtual destructor for safe polymorphic use
};
