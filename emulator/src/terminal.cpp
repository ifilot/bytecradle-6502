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
#include <sys/ioctl.h>

/**
 * @brief Construct a new Terminal Raw Mode object
 * 
 */
TerminalRawMode::TerminalRawMode() {
    // Save original terminal settings
    tcgetattr(STDIN_FILENO, &orig_term_);
    termios raw = orig_term_;
    raw.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &raw);

    // Set stdin to non-blocking
    orig_flags_ = fcntl(STDIN_FILENO, F_GETFL, 0);
    fcntl(STDIN_FILENO, F_SETFL, orig_flags_ | O_NONBLOCK);
}

/**
 * @brief Destroy the Terminal Raw Mode object
 * 
 */
TerminalRawMode::~TerminalRawMode() {
    // Restore original terminal settings
    tcsetattr(STDIN_FILENO, TCSANOW, &orig_term_);

    // Remove non-blocking flag
    fcntl(STDIN_FILENO, F_SETFL, orig_flags_);
}

/**
 * @brief Poll for a key press
 * 
 * @return TerminalPollResult poll result containing optional key and EOF state
 */
TerminalPollResult TerminalRawMode::poll_key() {
    TerminalPollResult result;
    uint8_t ch = 0;
    ssize_t nread = read(STDIN_FILENO, &ch, 1);

    if (nread > 0) {
        result.key = ch;
        return result;
    }

    if (nread == 0) {
        result.eof = true;
    }

    return result;
}

/**
 * @brief Check whether terminal is at least the requested size
 *
 * @param min_cols minimum number of columns
 * @param min_rows minimum number of rows
 * @return true when terminal is large enough, false otherwise
 */
bool TerminalRawMode::has_minimum_terminal_size(unsigned short min_cols, unsigned short min_rows) {
    struct winsize ws {};
    if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws) == -1) {
        return true; // if query fails, do not block startup
    }

    return ws.ws_col >= min_cols && ws.ws_row >= min_rows;
}
