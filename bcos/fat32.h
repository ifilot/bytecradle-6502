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

#include <stdio.h>
#include <string.h>

#include "sdcard.h"
#include "crc16.h"
#include "io.h"

#ifndef _FAT32_H
#define _FAT32_H

#define F32_LLSZ 16

struct FAT32Partition {
    uint16_t bytes_per_sector;
    uint8_t sectors_per_cluster;
    uint16_t reserved_sectors;
    uint8_t number_of_fats;
    uint32_t sectors_per_fat;
    uint32_t root_dir_first_cluster;
    uint32_t fat_begin_lba;
    uint32_t lba_addr_root_dir;
    uint32_t sector_begin_lba;
    char volume_label[11];
};

extern struct FAT32Partition fat32_partition;
extern uint32_t fat32_linkedlist[F32_LLSZ];
extern uint32_t fat32_filesize_current_file;
extern uint32_t fat32_current_folder_cluster;

/**
 * Read the Master Boot Record from the SD card
 */
uint8_t fat32_read_mbr(void);

/**
 * Read the partition table from the MBR
 * 
 * This function assumes that the MBR has already been read and it present
 * in RAM at location 0x8000
 */
void fat32_read_partition(void);

/**
 * @brief Calculate the sector address from cluster and sector
 * 
 * @param cluster which cluster
 * @param sector which sector on the cluster (0-Nclusters)
 * @return uint32_t sector address (512 byte address)
 */
uint32_t fat32_calculate_sector_address(uint32_t cluster, uint8_t sector);

void fat32_list_dir();

/**
 * @brief Build a linked list of sector addresses starting from a root address
 * 
 * @param nextcluster first cluster in the linked list
 */
void fat32_build_linked_list(uint32_t nextcluster);

#endif