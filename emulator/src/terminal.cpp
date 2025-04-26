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

#include "terminal.h"

#include <unistd.h>
#include <fcntl.h>
#include <termios.h>

/**
 * @brief Construct a new Terminal Raw Mode object
 * 
 */
TerminalRawMode::TerminalRawMode() {
    // Save original terminal settings
    tcgetattr(STDIN_FILENO, &origTerm_);
    termios raw = origTerm_;
    raw.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &raw);

    // Set stdin to non-blocking
    int flags = fcntl(STDIN_FILENO, F_GETFL, 0);
    fcntl(STDIN_FILENO, F_SETFL, flags | O_NONBLOCK);
}

/**
 * @brief Destroy the Terminal Raw Mode object
 * 
 */
TerminalRawMode::~TerminalRawMode() {
    // Restore original terminal settings
    tcsetattr(STDIN_FILENO, TCSANOW, &origTerm_);

    // Remove non-blocking flag
    int flags = fcntl(STDIN_FILENO, F_GETFL, 0);
    flags &= ~O_NONBLOCK;
    fcntl(STDIN_FILENO, F_SETFL, flags);
}

/**
 * @brief Poll for a key press
 * 
 * @return std::optional<char> character if a key was pressed, std::nullopt otherwise
 */
std::optional<char> TerminalRawMode::poll_key() {
    char ch;
    ssize_t nread = read(STDIN_FILENO, &ch, 1);

    if (nread > 0) {
        return ch;
    }
    
    return std::nullopt;
}
