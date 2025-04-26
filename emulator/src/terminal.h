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
     * @return std::optional<char> character if a key was pressed, std::nullopt otherwise
     */
    static std::optional<char> poll_key();

private:
    struct termios origTerm_;
};
