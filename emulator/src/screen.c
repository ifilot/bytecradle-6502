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

#include "ncurses.h"
#include "screen.h"

WINDOW *main_box = NULL;
WINDOW *side_box = NULL;
WINDOW *status_win = NULL;
WINDOW *screen_win = NULL;
WINDOW *statusbar = NULL;

char statusbar_msg[80];

void screen_init() {
    initscr();
    cbreak();  // Disable line buffering
    noecho();  // Don't echo input characters
    keypad(stdscr, TRUE); // Enable special keys
    nodelay(stdscr, TRUE);
    raw();
    curs_set(0);
    start_color(); // Enable colors
    init_pair(1, COLOR_BLACK, COLOR_WHITE); // Inverted colors for status bar
    strcpy(statusbar_msg, "Press CTRL+X to exit.");

    // Create two windows
    main_box = newwin(WINHEIGHT, MAINWIDTH, 0, 0);  // 80x24 window at (0,0)
    side_box = newwin(WINHEIGHT, SIDEWIDTH, 0, MAINWIDTH); // 10x24 window at (0,80)
    statusbar = newwin(1, MAINWIDTH + SIDEWIDTH, WINHEIGHT, 0);

    screen_border();

    // Create a sub-window inside `win` (excluding header)
    status_win = derwin(side_box, WINHEIGHT - 2, SIDEWIDTH - 2, 1, 1);
    scrollok(status_win, TRUE);
    wsetscrreg(status_win, 1, WINHEIGHT - 2);

    // Create a sub-window inside `win` (excluding header)
    screen_win = derwin(main_box, WINHEIGHT - 2, MAINWIDTH - 2, 1, 1);
    scrollok(screen_win, TRUE);
    wsetscrreg(screen_win, 1, WINHEIGHT - 2);

    // Refresh windows
    wrefresh(main_box);
    wrefresh(side_box);
    wrefresh(screen_win);
    wrefresh(status_win);
    wrefresh(statusbar);
}

void screen_clean() {
    delwin(main_box);
    delwin(side_box);
    endwin();
}

void screen_refresh() {
    wrefresh(main_box);
    wrefresh(side_box);
    wrefresh(screen_win);
    wrefresh(status_win);
    wrefresh(statusbar);
}

void screen_border() {
    // Box the windows
    box(main_box, 0, 0);
    box(side_box, 0, 0);

    // Print messages in windows
    mvwprintw(main_box, 0, 3, "[ SCREEN ]");  // Centered header
    mvwprintw(side_box, 0, 1, "[ KEYBOARD ]");  // Centered header

    update_status_bar();
}

void parse_character(char ch) {
    static int escape_sequence = 0;
    static char esc_buffer[10];
    static int esc_index = 0;
    static int cursor_x = 0, cursor_y = 0;
    
    getyx(screen_win, cursor_y, cursor_x);

    if (escape_sequence) {
        esc_buffer[esc_index++] = ch;
        esc_buffer[esc_index] = '\0';
        
        // Detect end of escape sequence
        if ((ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z')) {
            escape_sequence = 0;
            esc_index = 0;
            
            // do no do anything yet with escape sequence patterns
            refresh();
        }
        return;
    }
    
    if (ch == ESC) {
        escape_sequence = 1;
        esc_index = 0;
        return;
    }

    // Handle Backspace (0x08)
    if (ch == BACKSPACE) {
        if (cursor_x > 0) {
            wmove(screen_win, cursor_y, cursor_x - 1);  // Move left
            wdelch(screen_win);  // Delete the character at the new position
            wrefresh(screen_win);
        }
        return;
    }
    
    // Regular character input
    waddch(screen_win, ch);
    refresh();
}

void update_status_bar() {
    wbkgd(statusbar, COLOR_PAIR(1)); // Apply inverted colors
    wattron(statusbar, COLOR_PAIR(1)); // Enable color attribute
    werase(statusbar); // Clear the status bar before printing
    mvwprintw(statusbar, 0, 2, "%s", statusbar_msg);
    wattroff(statusbar, COLOR_PAIR(1)); // Disable color attribute
    wrefresh(statusbar);
}