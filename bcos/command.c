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

char command_buffer[40];
char* command_argv[20];
uint8_t command_argc;
char* command_ptr = command_buffer;

static const char* command_list[] = {
    "LS",
    "DIR",
    NULL,
};

void command_loop() {
    uint8_t c;

    c = getch();
    if(c != 0) {
        switch(c) {
            case 0x0D:
                command_exec();
            break;
            default:
                *(command_ptr++) = c;
                putch(c);
            break;
        }
    }
}

void command_exec() {
    uint8_t i = 0;

    *command_ptr = 0x00;
    putstrnl(command_buffer);
    
    command_parse();

    // try to see if we can find a match
    for(i=0; i<sizeof(command_list); i++) {
        if(strcmp(command_list[i], command_argv[0]) == 0) {
            putstrnl(command_list[i]);
        }
    }

    command_ptr = command_buffer;
}

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
        putstrnl(command_argv[i]);
    }
}

// fat32_read_dir();
// fat32_sort_files();
// fat32_list_dir();

// // test: try to find this file
// fileptr = fat32_search_dir("HELLOWORTXT");
// if(fileptr != NULL) {
//     sprintf(buf, "Base name: %s", fileptr->basename);
//     putstrnl(buf);
//     sprintf(buf, "Start cluster: %08lX", fileptr->cluster);
//     putstrnl(buf);
//     sprintf(buf, "File size: %lu", fileptr->filesize);
//     putstrnl(buf);
// } else {
//     putstrnl("File not found.");
// }

// // try to load the file from the SD-card
// fat32_load_file(fileptr, 0x0800);
// for(i=0; i<32; i++) {
//     sprintf(buf, "%02X ", *(uint8_t*)(0x0800 + i));
//     putstr(buf);
// }
// putstrnl("");