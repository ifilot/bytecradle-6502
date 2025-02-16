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

#ifndef _SDCARD_H
#define _SDCARD_H

#include <stdint.h>

extern void __fastcall__ init_sd(void);
extern void __fastcall__ close_sd(void);
extern uint8_t __fastcall__ sdcmd00(void);
extern uint8_t __fastcall__ sdcmd08(uint8_t *resptr);
extern uint8_t __fastcall__ sdacmd41(void);
extern uint8_t __fastcall__ sdcmd58(uint8_t *resptr);
extern uint16_t __cdecl__ sdcmd17(uint32_t addr);

#endif
