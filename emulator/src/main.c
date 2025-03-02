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
#include <time.h>
#include <argp.h>

#include "ramrom.h"
#include "vrEmu6502/vrEmu6502.h"

// forward declarations
void term_disable_blocking();
void term_restore_default(struct termios *original);
void cleanup();
int kbhit();
VrEmu6502 *cpu65c02;
struct termios original;

/**
 * @brief Structure to hold command-line arguments.
 * 
 * This structure is used to store the values of the command-line arguments
 * parsed by the argp library. It contains fields for verbosity and the
 * output file.
 */
struct arguments {
    int verbose;
    char *rom;
    char *sdcard;
    char *program;
};

/**
 * @brief Command-line options.
 * 
 * This array defines the command-line options that the program accepts.
 * Each option is described by a struct argp_option, which includes the
 * long option name, short option character, argument name, flags, and
 * a documentation string.
 */
static struct argp_option options[] = {
    {"rom", 'r', "FILE", 0, "ROM file"},
    {"sdcard",  's', "FILE", 0, "SDCARD image"},
    {"program",  'p', "FILE", 0, "program file"},
    { 0 }
};

/**
 * @brief Parses command-line options.
 * 
 * This function is called by the argp library to handle command-line options.
 * It sets the appropriate fields in the arguments structure based on the
 * provided key and argument.
 * 
 * @param key The key representing the option.
 * @param arg The argument associated with the option.
 * @param state The state of the argument parser.
 * @return error_t Returns 0 on success, ARGP_ERR_UNKNOWN on unknown option.
 */
static error_t parse_opt(int key, char *arg, struct argp_state *state) {
    struct arguments *arguments = state->input;

    switch (key) {
        case 'v':
            arguments->verbose = 1;
            break;
        case 'r':
            arguments->rom = arg;
            break;
        case 's':
            arguments->sdcard = arg;
            break;
        case 'p':
            arguments->program = arg;
            break;
        case ARGP_KEY_ARG:
            return 0;
        default:
            return ARGP_ERR_UNKNOWN;
    }
    return 0;
}

/**
 * @brief Argument parser configuration.
 * 
 * This structure defines the options, parser function, and documentation
 * for the command-line argument parser used by the argp library.
 */
static struct argp argp = { options, 
                            parse_opt, 
                            0, 
                            "BC6502 Emulator" };

/**
 * @brief Main function for the emulator.
 * 
 * This function initializes the emulator, sets up the CPU core, and enters
 * an infinite loop to handle keyboard input and CPU ticks.
 * 
 * @param argc The number of command-line arguments.
 * @param argv The array of command-line arguments.
 * @return int Returns 0 on successful execution.
 */
int main(int argc, char *argv[]) {
    // register clean-up function
    atexit(cleanup);

    // initialize argument structure
    struct arguments arguments = { 0, NULL };

    // parse command-line arguments
    argp_parse(&argp, argc, argv, 0, 0, &arguments);

    // enforce mandatory arguments
    if(arguments.rom == NULL) {
        fprintf(stderr, "Error: --rom is required!\n");
        return EXIT_FAILURE;
    }

    if(arguments.sdcard == NULL) {
        fprintf(stderr, "Error: --sdcard is required!\n");
        return EXIT_FAILURE;
    }

    // load the ROM memory using external file
    initrom(arguments.rom);
    init_sd(arguments.sdcard);

    // modify terminal settings, but store original settings
    tcgetattr(STDIN_FILENO, &original);
    term_disable_blocking();

    // create CPU core
    cpu65c02 = vrEmu6502New(CPU_W65C02, memread, memwrite);

    // keep track of time, this is needed for keyboard polling
    struct timespec start, current;
    clock_gettime(CLOCK_MONOTONIC, &start);

    // When running in direct program mode, this variable is used to terminate
    // the emulator when the program finishes. The idea is that the stacklimit
    // is probed right before the program is started and once the stackpointer
    // is back to its original value, we know that the program has completed.
    uint8_t stacklimit = 0;

    // boot CPU core
    if(cpu65c02) {
        irq = vrEmu6502Int(cpu65c02);   // set IRQ pin

        // reset the processor
        vrEmu6502Reset(cpu65c02);

        if(arguments.program != NULL) {
            while(vrEmu6502GetPC(cpu65c02) != 0xD28C) {
                vrEmu6502Tick(cpu65c02);
            }

            uint16_t prgaddr = init_program(arguments.program);

            // print memory contents starting at prgaddr
            for(int i = 0; i < 0x10; i++) {
                printf("%02X ", memread(prgaddr+i, false));
            }
            printf("\n");

            // storing stack position
            stacklimit = vrEmu6502GetStackPointer(cpu65c02) + 2;

            printf("Jumping to $%04X.\n", prgaddr+2);
            vrEmu6502SetPC(cpu65c02, prgaddr+2);
        }

        // set key buffer pointer
        keybuffer_ptr = keybuffer;

        // construct infinite loop
        while (1) {
            // check for keyboard input
            clock_gettime(CLOCK_MONOTONIC, &current);
            long elapsed_ms = (current.tv_sec - start.tv_sec) * 1000 +
                              (current.tv_nsec - start.tv_nsec) / 1000000;

            // only 'poll' the keyboard every 10 ms
            if (elapsed_ms >= 10) {
                kbhit();
            }

            // keyboard input triggers interrupt
            if(keybuffer_ptr > keybuffer) {
                *irq = IntRequested;
            }

            // perform CPU tick
            vrEmu6502Tick(cpu65c02);

            // check if stack limit is reached
            if(arguments.program != NULL) {
                if(vrEmu6502GetStackPointer(cpu65c02) == stacklimit) {
                    printf("Program finished. Exiting simulator...\n");
                    break;
                }
            }
        }

        // clean up the mess
        vrEmu6502Destroy(cpu65c02);
        cpu65c02 = NULL;
    }

    // close pointer to SD-card
    close_sd();

    // restore original terminal settings
    term_restore_default(&original);
    return EXIT_SUCCESS;
}

/**
 * @brief Disables the blocking call when reading from standard input
 * 
 */
void term_disable_blocking() {
    struct termios t;
    tcgetattr(STDIN_FILENO, &t);

    // Disable line buffering and echo
    t.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &t);

    int flags = fcntl(STDIN_FILENO, F_GETFL, 0);

    // Set non-blocking mode
    fcntl(STDIN_FILENO, F_SETFL, flags | O_NONBLOCK);
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
    
    // detect CTRL+R
    if(ch == ('R' - 0x40)) {
        keybuffer_ptr = keybuffer;
        ch = getchar(); // consume character
        printf("Reset triggered.\n");
        vrEmu6502Reset(cpu65c02);        
        return 0;
    }

    // detect CTRL+Q
    if(ch == ('X' - 0x40)) {
        printf("Exiting program.\n");
        exit(EXIT_SUCCESS);
        return 0;
    }

    // detect CTRL+N
    if(ch == ('N' - 0x40)) {
        keybuffer_ptr = keybuffer;
        ch = getchar(); // consume character
        printf("NMI triggered.\n");
        vrEmu6502Nmi(cpu65c02);
        return 0;
    }

    if (bytes_read > 0) {
        *(keybuffer_ptr++) = ch;
        return EXIT_FAILURE;
    }

    return 0;
}

void cleanup() {
    vrEmu6502Destroy(cpu65c02);
    term_restore_default(&original);
}