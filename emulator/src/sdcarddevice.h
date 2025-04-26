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
