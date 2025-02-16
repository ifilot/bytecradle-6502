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

#include "fat32.h"
#include "constants.h"

static struct FAT32Partition fat32_partition;

/**
 * Read the Master Boot Record from the SD card, assumes that the SD-card
 * has already been initialized.
 */
uint8_t fat32_read_mbr(void) {
    uint16_t checksum_sd = 0x0000;
    uint16_t checksum = 0x0000;
    uint8_t* sdbuf = (uint8_t*)(SDBUF);

    checksum_sd = sdcmd17(0x00000000);
    checksum = crc16_xmodem(sdbuf, 0x200);

    if(checksum != checksum_sd) {
        return -1;
    }

    if(sdbuf[0x1FE] != 0x55 || sdbuf[0x1FF] != 0xAA) {
        return -1;
    }

    return 0;
}

/**
 * Read the partition table from the MBR
 * 
 * This function assumes that the MBR has already been read and it present
 * in RAM at location 0x8000
 */
void fat32_read_partition(void) {
    char buf[32];
    // extract logical block address (LBA) from partition table
    uint32_t lba = *(uint32_t*)(SDBUF + 0x1C6);

    // retrieve the partition table
    sdcmd17(lba);

    // store partition information
    fat32_partition.bytes_per_sector = *(uint16_t*)(SDBUF + 0x0B);
    fat32_partition.sectors_per_cluster = *(uint8_t*)(SDBUF + 0x0D);
    fat32_partition.reserved_sectors = *(uint16_t*)(SDBUF + 0x0E);
    fat32_partition.number_of_fats = *(uint8_t*)(SDBUF + 0x10);
    fat32_partition.sectors_per_fat = *(uint32_t*)(SDBUF + 0x24);
    fat32_partition.root_dir_first_cluster = *(uint32_t*)(SDBUF + 0x2C);
    fat32_partition.fat_begin_lba = lba + fat32_partition.reserved_sectors;
    fat32_partition.sector_begin_lba = fat32_partition.fat_begin_lba + 
        (fat32_partition.number_of_fats * fat32_partition.sectors_per_fat);
    fat32_partition.lba_addr_root_dir = calculate_sector_address(fat32_partition.root_dir_first_cluster, 0);

    // print data
    sprintf(buf, "LBA partition 1: %08lX", lba);
    putstrnl(buf);

    sprintf(buf, "Bytes per sector: %i", fat32_partition.bytes_per_sector);
    putstrnl(buf);

    sprintf(buf, "Sectors per cluster: %i", fat32_partition.sectors_per_cluster);
    putstrnl(buf);

    sprintf(buf, "Reserved sectors: %i", fat32_partition.reserved_sectors);
    putstrnl(buf);

    sprintf(buf, "Number of FATS: %i", fat32_partition.number_of_fats);
    putstrnl(buf);

    sprintf(buf, "Sectors per FAT: %lu", fat32_partition.sectors_per_fat);
    putstrnl(buf);

    sprintf(buf, "Partition size: %lu MiB", (fat32_partition.sectors_per_fat * 
                                             fat32_partition.sectors_per_cluster * 
                                             fat32_partition.bytes_per_sector) >> 13);
    putstrnl(buf);

    // read first sector of first partition to establish volume name
    sdcmd17(fat32_partition.lba_addr_root_dir);

    // copy volume name
    memcpy(fat32_partition.volume_label, (uint8_t*)(SDBUF), 11);
    puthex(fat32_partition.volume_label[0]);
    // sprintf(buf, "Volume name:%.11s\0", (uint8_t*)(SDBUF));
    // putstrnl(buf);
}