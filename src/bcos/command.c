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
    { "DIR", command_ls },
    { "CD", command_cd },
    { "MORE", command_more },
    { "HEXDUMP", command_hexdump },
    { "SDINFO", command_sdinfo },
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
                if(c >= ' ' && c <= '~') {
                    *(command_ptr++) = c;
                    putch(c);
                }
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

    if(command_argc == 0) {
        command_pwdcmd();
        return;
    }

    // try to see if we can find a match
    for(i=0; i<sizeof(command_table); i++) {
        if(strcmp(command_table[i].str, command_argv[0]) == 0) {
            command_table[i].func();
            break;
        }
    }

    // throw illegal command
    if(i == sizeof(command_table)) {
        if(!command_try_com() == 0) {
            command_illegal();
        }
    }

    command_ptr = command_buffer;
    memset(command_buffer, 0x00, strlen(command_buffer));
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

    // ensure proper RAM bank
    asm("lda #63");
    asm("sta %w", RAMBANKREGISTER);

    if(command_argc == 1) {
        fat32_current_folder = fat32_root_folder;
        fat32_pathdepth = 1;
        return;
    }

    if(command_argc != 2) {
        command_illegal();
        return;
    }

    if(fat32_pathdepth > 1 && strcmp(command_argv[1], "..") == 0) {
        fat32_pathdepth--;
        fat32_current_folder = fat32_fullpath[fat32_pathdepth - 1];
        return;
    }

    l = l > 11 ? 11 : l;
    memcpy(dirname, command_argv[1], l);
    memset(&dirname[l], ' ', 11-l);
    dirname[11] = 0x00;

    fat32_read_dir();
    fat32_sort_files();
    res = fat32_search_dir(dirname, FOLDER_ENTRY);

    if(res != NULL) {
        if(res->cluster == 0) {
            fat32_current_folder = fat32_root_folder;
            fat32_pathdepth = 1;
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
    char *ptr;
    char *bufptr = buf;
    uint8_t i = 0;

    // ensure proper RAM bank
    asm("lda #63");
    asm("sta %w", RAMBANKREGISTER);

    *(bufptr++) = ':';
    for(i=0; i<fat32_pathdepth; i++) {
        ptr = fat32_fullpath[i].name;
        while(*ptr != 0x00 && *ptr != ' ') {
            *(bufptr++) = *(ptr++);
        }
        *(bufptr++) = '/';
    }
    *(bufptr++) = '>';
    *(bufptr++) = ' ';
    *(bufptr++) = 0x00;

    putstr(buf);
}

/**
 * @brief Informs the user on an illegal command
 */
void command_illegal() {
    putstr("Illegal command: ");
    putstrnl(command_argv[0]);
}

/**
 * @brief Outputs file to screen assuming human-readable content
 */
void command_more() {
    struct FAT32File* res = NULL;
    char base[9] = {0};
    char ext[4] = {0};
    char filename[12] = {0};
    const char *ptr;
    uint8_t pos;
    uint8_t linecounter = 0;
    uint8_t charcounter = 0;

    // ensure proper RAM bank
    asm("lda #63");
    asm("sta %w", RAMBANKREGISTER);

    if(command_argc != 2) {
        command_illegal();
        return;
    }

    memset(base, ' ', 8);
    memset(ext, ' ', 8);

    ptr = strchr(command_argv[1], '.');
    if(ptr) {
        pos = ptr - command_argv[1];
        memcpy(base, command_argv[1], pos > 8 ? 8 : pos);
        memcpy(ext, &command_argv[1][pos+1], 3);
    } else {
        pos = strlen(command_argv[1]);
        memcpy(base, command_argv[1], pos > 8 ? 8 : pos);
    }

    memcpy(filename, base, 8);
    memcpy(&filename[8], ext, 3);
    filename[11] = 0;

    putstrnl(filename);

    fat32_read_dir();
    fat32_sort_files();
    res = fat32_search_dir(filename, FILE_ENTRY);

    // when nothing can be found
    if(res == NULL) {
        putstrnl("Cannot find file.");
        return;
    }

    fat32_load_file(res, (uint8_t*)(0x1000));
    ptr = (uint8_t*)0x1000;
    while(*ptr != 0x00) {
        if(*ptr == '\n') {
            ptr++;
            putcrlf();
            linecounter++;
        } else {
            putch(*(ptr++));
        }

        charcounter++;
        if(charcounter == 80) {
            putcrlf();
            charcounter = 0;
            linecounter++;
        }

        if(linecounter == 20) {
            putstrnl("--- Press SPACE to continue ---");
            while(getch() != ' ') {}
            linecounter = 0;
        }
    }
}

/**
 * @brief Try to launch a .COM file
 */
uint8_t command_try_com() {
    struct FAT32File* res = NULL;
    char filename[12] = {0};
    uint8_t l = strlen(command_argv[0]);
    uint16_t addr;
    void __fastcall__ (*program)(void) = NULL;

    // ensure proper RAM bank
    asm("lda #63");
    asm("sta %w", RAMBANKREGISTER);

    l = l > 8 ? 8 : l;
    memset(filename, ' ', 8);
    memcpy(filename, command_argv[0], l);
    memcpy(&filename[8], "COM", 3);
    filename[11] = 0;

    fat32_read_dir();
    fat32_sort_files();
    res = fat32_search_dir(filename, FILE_ENTRY);

    // when nothing can be found
    if(res == NULL) {
        return 0xFF;
    } else {
        // store first block at 0x8000; we need the first two bytes
        sdcmd17(fat32_calculate_sector_address(res->cluster, 0));
        addr = *(uint16_t*)(0x8000);
        fat32_load_file(res, (uint8_t*)addr);
        program = (void(*)(void))(addr+2);
        program();
        memset((void*)0x0800, 0xFF, 0x7700);    // clean up user space
        return 0;
    }
}

/**
 * @brief Dumps memory contents to screen
 * 
 */
void command_hexdump() {
    uint8_t* addr;
    uint16_t i=0;
    char* endptr;

    if(command_argc != 2) {
        command_illegal();
        return;
    }

    // convert input to hex
    addr = strtol(command_argv[1], &endptr, 16);

    if(*endptr != '\0') {
        putstr("Invalid address: ");
        putstrnl(command_argv[1]);
        return;
    }

    for(i=0; i<256; i++) {
        if(i % 16 == 0) {
            puthexword(addr);
            putstr(": ");
        }
        puthex(*(uint8_t*)(addr++));
        putspace();
        if(i % 16 == 15) {
            putstrnl("");
        }
    }
}

/**
 * @brief Outputs SD-CARD information to screen
 * 
 */
void command_sdinfo() {
    fat32_print_partition_info();
}