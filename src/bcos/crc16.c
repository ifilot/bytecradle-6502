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

#include "crc16.h"

/**
 * Calculate CRC16 checksum using XMODEM polynomial
 * 
 * @param data Pointer to the data buffer
 * @param length Length of the data buffer
 * @return uint16_t CRC16 checksum
 */
uint16_t crc16_xmodem(const uint8_t *data, uint16_t length) {
    uint16_t crc = 0x0000;
    uint16_t polynomial = 0x1021;
    uint16_t i = 0;
    uint8_t j = 0;

    for (i = 0; i < length; i++) {
        crc ^= (data[i] << 8);  // XOR the byte into the high byte of CRC

        for(j = 0; j < 8; j++) {
            if (crc & 0x8000) {
                crc = (crc << 1) ^ polynomial;
            } else {
                crc <<= 1;
            }
        }
    }

return crc;
}
 