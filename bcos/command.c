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

#include "command.h"

static char command_buffer[40];
static char* command_argv[20];
static uint8_t command_argc;
static char* command_ptr = command_buffer;

static const CommandEntry command_table[] = {
    { "LS", command_ls },
    { "DIR", command_ls },  // Alias for LS
    { "CD", command_cd },
};

/**
 * @brief Continuously sample keyboard input, retrieve and parse commands
 */
void command_loop() {
    uint8_t c;

    c = getch();
    if(c != 0) {
        switch(c) {
            case 0x0D:
                command_exec();
            break;
            case 0x7F:
                if(command_ptr > command_buffer) {
                    putbackspace();
                    command_ptr--;
                }
            break;
            default:
                *(command_ptr++) = c;
                putch(c);
            break;
        }
    }
}

/**
 * @brief Try to execute a command when user has pressed enter
 */
void command_exec() {
    uint8_t i = 0;

    putstrnl("");
    *command_ptr = 0x00;    // place terminating byte
    command_parse();        // split string

    // try to see if we can find a match
    for(i=0; i<sizeof(command_table); i++) {
        if(strcmp(command_table[i].str, command_argv[0]) == 0) {
            command_table[i].func();
            break;
        }
    }
    if(i == sizeof(command_table)) {
        command_illegal();
    }

    command_ptr = command_buffer;
    command_pwdcmd();
}

/**
 * @brief Parse command buffer, splits using spaces
 */
void command_parse() {
    char* ptr = strtok(command_buffer, " ");
    char** argv_ptr = command_argv;
    uint8_t i;

    *(argv_ptr++) = ptr;
    command_argc = 0;

    while(ptr != NULL) {
        ptr = strtok(NULL, " ");
        *(argv_ptr++) = ptr;
        command_argc++;
    }

    for(i=0; i<command_argc; i++) {
        strupper(command_argv[i]);
    }
}

/**
 * @brief Execute the "ls" command
 */
void command_ls() {
    fat32_read_dir();
    fat32_sort_files();
    fat32_list_dir();
}

/**
 * @brief Execute the "cd" command
 */
void command_cd() {
    struct FAT32File* res = NULL;
    char dirname[12];
    uint8_t l = strlen(command_argv[1]);

    if(command_argc == 1) {
        fat32_current_folder = fat32_root_folder;
        return;
    }

    if(command_argc != 2) {
        command_illegal();
        return;
    }

    l = l > 11 ? 11 : l;
    memcpy(dirname, command_argv[1], l);
    memset(&dirname[l], ' ', 11-l);
    dirname[11] = 0x00;

    fat32_read_dir();
    fat32_sort_files();
    res = fat32_search_dir(dirname);
    if(res != NULL && res->attrib & (1 << 4)) {
        if(res->cluster == 0) {
            fat32_current_folder = fat32_root_folder;
        } else if(fat32_pathdepth > 1 && strcmp(dirname, "..")) {
            fat32_current_folder = fat32_fullpath[--fat32_pathdepth];
        } else {
            memcpy(fat32_current_folder.name, res->basename, 11);
            fat32_current_folder.cluster = res->cluster;
            fat32_fullpath[fat32_pathdepth++] = fat32_current_folder;
        }
    } else {
        putstrnl("Cannot find folder");
    }
}

/**
 * @brief Places the current working directory on the screen
 */
void command_pwdcmd() {
    char buf[80];
    uint8_t i = 0;

    for(i=0; i<fat32_pathdepth; i++) {
        
    }

    putstr(buf);
}

/**
 * @brief Informs the user on an illegal command
 */
void command_illegal() {
    putstr("Illegal command: ");
    putstrnl(command_argv[0]);
}