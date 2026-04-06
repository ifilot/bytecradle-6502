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

#include <optional>
#include <termios.h>
#include <cstdint>

struct TerminalPollResult {
    std::optional<uint8_t> key;
    bool eof = false;
};

// Simple RAII class to set terminal into raw, non-blocking mode
class TerminalRawMode {
public:
    /**
     * @brief Construct a new Terminal Raw Mode object
     * 
     */
    TerminalRawMode();

    /**
     * @brief Destroy the Terminal Raw Mode object
     * 
     */
    ~TerminalRawMode();

    /**
     * @brief Poll for a key press
     * 
     * @return TerminalPollResult poll result containing optional key and EOF state
     */
    static TerminalPollResult poll_key();

    /**
     * @brief Check whether terminal is at least the requested size
     *
     * @param min_cols minimum number of columns
     * @param min_rows minimum number of rows
     * @return true when terminal is large enough, false otherwise
     */
    static bool has_minimum_terminal_size(unsigned short min_cols, unsigned short min_rows);

private:
    struct termios orig_term_;
    int orig_flags_ = 0;
};
