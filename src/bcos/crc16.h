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

#ifndef _CRC16_H
#define _CRC16_H
 
#include <stdint.h>

/**
 * Calculate CRC16 checksum using XMODEM polynomial
 * 
 * @param data Pointer to the data buffer
 * @param length Length of the data buffer
 * @return uint16_t CRC16 checksum
 */
uint16_t crc16_xmodem(const uint8_t *data, uint16_t length);

/**
 * @brief Optimized CRC16 checksum for SD sector
 * 
 * @return uint16_t CRC16 checksum
 */
extern uint16_t __fastcall__ crc16_xmodem_sdsector(void);

#endif
 