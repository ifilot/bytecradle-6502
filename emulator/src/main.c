/**************************************************************************
 *                                                                        *
 *   Author: Ivo Filot <ivo@ivofilot.nl>                                  *
 *                                                                        *
 *   BC6502EMU is free software:                                          *
 *   you can redistribute it and/or modify it under the terms of the      *
 *   GNU General Public License as published by the Free Software         *
 *   Foundation, either version 3 of the License, or (at your option)     *
 *   any later version.                                                   *
 *                                                                        *
 *   BC6502EMU is distributed in the hope that it will be useful,         *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty          *
 *   of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.              *
 *   See the GNU General Public License for more details.                 *
 *                                                                        *
 *   You should have received a copy of the GNU General Public License    *
 *   along with this program.  If not, see http://www.gnu.org/licenses/.  *
 *                                                                        *
 **************************************************************************/

#include <stddef.h>
#include <stdio.h>
#include <termios.h>
#include <unistd.h>
#include <fcntl.h>

#include "ramrom.h"
#include "vrEmu6502/vrEmu6502.h"

// forward declarations
void term_disable_blocking();
void term_restore_default(struct termios *original);
int kbhit();

/**
 * @brief main function
 * 
 * @return int 
 */
int main(int argc, char *argv[]) {
    // initialize memory from file
    if(argc != 2) {
        fprintf(stderr, "Incorrect number of parameters!\n");
        exit(EXIT_FAILURE);
    }
    initrom(argv[1]);

    // modify terminal settings, but store original settings
    struct termios original;
    tcgetattr(STDIN_FILENO, &original);
    term_disable_blocking();

    // create CPU core
    VrEmu6502 *cpu65c02 = vrEmu6502New(CPU_W65C02, memread, memwrite);

    // boot CPU core
    if(cpu65c02) {
        irq = vrEmu6502Int(cpu65c02);   // set IRQ pin

        // reset the processor
        vrEmu6502Reset(cpu65c02);

        // set key buffer pointer
        keybuffer_ptr = keybuffer;

        // construct infinite loop
        while (1) {
            // check for keyboard input
            kbhit();

            // keyboard input triggers interrupt
            if(keybuffer_ptr > keybuffer) {
                *irq = IntRequested;
            }

            // perform CPU tick
            vrEmu6502Tick(cpu65c02);
        }

        // clean up the mess
        vrEmu6502Destroy(cpu65c02);
        cpu65c02 = NULL;
    }

    // restore original terminal settings
    term_restore_default(&original);
    return 0;
}

/**
 * @brief Disables the blocking call when reading from standard input
 * 
 */
void term_disable_blocking() {
    struct termios t;
    tcgetattr(STDIN_FILENO, &t);
    t.c_lflag &= ~(ICANON | ECHO);  // Disable line buffering and echo
    tcsetattr(STDIN_FILENO, TCSANOW, &t);

    int flags = fcntl(STDIN_FILENO, F_GETFL, 0);
    fcntl(STDIN_FILENO, F_SETFL, flags | O_NONBLOCK);  // Set non-blocking mode
}

/**
 * @brief Restore regular terminal settings for STDIN
 * 
 * @param original 
 */
void term_restore_default(struct termios *original) {
    tcsetattr(STDIN_FILENO, TCSANOW, original);
}

/**
 * @brief Function to check whether a key has been hit; if so, the keyboard
 *        input is stored in an internal buffer which can be accessed by the
 *        ROM/RAM routines
 * 
 * @return int whether key has been pushed
 */
int kbhit() {
    char ch;
    int bytes_read = read(STDIN_FILENO, &ch, 1);
    
    if (bytes_read > 0) {
        *(keybuffer_ptr++) = ch;
        return 1;
    }

    return 0;
}