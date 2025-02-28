/**************************************************************************
 *                                                                        *
 *   Author: Ivo Filot <ivo@ivofilot.nl>                                  *
 *                                                                        *
 *   ByteCradle 6502 OS is free software:                                 *
 *   you can redistribute it and/or modify it under the terms of the      *
 *   GNU General Public License as published by the Free Software         *
 *   Foundation, either version 3 of the License, or (at your option)     *
 *   any later version.                                                   *
 *                                                                        *
 *   ByteCradle 6502 OS is distributed in the hope that it will be useful,*
 *   but WITHOUT ANY WARRANTY; without even the implied warranty          *
 *   of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.              *
 *   See the GNU General Public License for more details.                 *
 *                                                                        *
 *   You should have received a copy of the GNU General Public License    *
 *   along with this program.  If not, see http://www.gnu.org/licenses/.  *
 *                                                                        *
 **************************************************************************/

#ifndef _COMMAND_H
#define _COMMAND_H

#include "fat32.h"
#include "constants.h"
#include "io.h"

typedef struct {
    const char *str;
    void (*func)(void);
} CommandEntry;

/**
 * @brief Continuously sample keyboard input, retrieve and parse commands
 */
void command_loop();

/**
 * @brief Try to execute a command when user has pressed enter
 */
void command_exec();

/**
 * @brief Parse command buffer, splits using spaces
 */
void command_parse();

/**
 * @brief Execute the "ls" command
 */
void command_ls();

/**
 * @brief Execute the "cd" command
 */
void command_cd();

/**
 * @brief Performs a backspace operation on the command buffer
 */
void command_backspace();

/**
 * @brief Places the current working directory on the screen
 */
void command_pwdcmd();

/**
 * @brief Informs the user on an illegal command
 */
void command_illegal();

/**
 * @brief Outputs file to screen assuming human-readable content
 */
void command_more();

/**
 * @brief Try to launch a .COM file
 */
uint8_t command_try_com();

#endif