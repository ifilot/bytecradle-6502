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

#ifndef _IO_H
#define _IO_H

// banking routines
extern void __fastcall__ set_rambank(uint8_t c);
extern uint8_t __fastcall__ get_rambank();

extern void __fastcall__ jump(uint8_t* c);
extern void __fastcall__ putbackspace();
extern void __fastcall__ putch(uint8_t c);
extern void __fastcall__ putstr(const char* c);
extern void __fastcall__ putstrnl(const char* c);
extern char __fastcall__ getch(void);
extern void __fastcall__ puthex(uint8_t c);
extern void __fastcall__ puthexword(uint16_t c);
extern void __fastcall__ putspace();

#endif
