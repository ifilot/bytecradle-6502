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

#ifndef _SCREEN_H
#define _SCREEN_H

#include <ncurses.h>

#define ESC 27
#define BACKSPACE 0x08

#define WINHEIGHT 24
#define MAINWIDTH 84
#define SIDEWIDTH 14

extern WINDOW *main_box;
extern WINDOW *side_box;
extern WINDOW *screen_win;
extern WINDOW *status_win;
extern WINDOW *statusbar;

extern char statusbar_msg[80];

void screen_init();
void screen_clean();
void screen_refresh();
void screen_border();
void parse_character(char ch);
void update_status_bar();

#endif // _SCREEN_H