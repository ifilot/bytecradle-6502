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

struct FAT32Partition fat32_partition;
uint32_t fat32_linkedlist[F32_LLSZ];
uint32_t fat32_filesize_current_file = 0;
uint32_t fat32_current_folder_cluster = 0;

/**
 * Read the Master Boot Record from the SD card, assumes that the SD-card
 * has already been initialized.
 */
uint8_t fat32_read_mbr(void) {
    uint16_t checksum_sd = 0x0000;
    uint16_t checksum = 0x0000;
    uint8_t* sdbuf = (uint8_t*)(SDBUF);

    checksum_sd = read_sector(0x00000000);
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
    read_sector(lba);

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
    fat32_partition.lba_addr_root_dir = fat32_calculate_sector_address(fat32_partition.root_dir_first_cluster, 0);

    // set the cluster of the current folder
    fat32_current_folder_cluster = fat32_partition.root_dir_first_cluster;

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
    read_sector(fat32_partition.lba_addr_root_dir);

    // copy volume name
    memcpy(fat32_partition.volume_label, (uint8_t*)(SDBUF), 11);
    sprintf(buf, "Volume name: %.11s\0", (uint8_t*)(SDBUF));
    putstrnl(buf);
}

void fat32_list_dir() {
    uint8_t ctr = 0;                // counter over clusters
    uint16_t fctr = 0;              // counter over directory entries (files and folders)
    uint32_t totalfilesize = 0;     // collect size of files in folder
    uint16_t loc = 0;               // current entry position
    uint8_t c = 0;                  // check byte
    uint8_t i = 0;
    uint16_t j = 0;
    uint8_t filename[11];
    uint32_t fc, filesize;
    uint8_t buf[80];

    // build linked list
    fat32_build_linked_list(fat32_current_folder_cluster);

    while(fat32_linkedlist[ctr] != 0xFFFFFFFF && ctr < F32_LLSZ) {
        // print cluster number and address
        uint32_t caddr = fat32_calculate_sector_address(fat32_linkedlist[ctr], 0);

        // loop over all sectors per cluster
        for(i=0; i<fat32_partition.sectors_per_cluster; i++) {
            read_sector(caddr);            // read sector data
            loc = SDBUF;
            for(j=0; j<16; j++) { // 16 file tables per sector
                // check first position
                c = *(uint8_t*)(loc);

                // continue if an unused entry is encountered 0xE5
                if(c == 0xE5) {
                    loc += 32;  // next file entry location
                    continue;
                }

                // early exit if a zero is read
                // if(c == 0x00) {
                //     stopreading = 1;
                //     break;
                // }

                c = *(uint8_t*)(loc + 0x0B);    // attrib byte

                // check if we are reading a file or a folder
                if((c & 0x0F) == 0x00) {

                    // capture metadata
                    fctr++;
                    fc = fat32_grab_cluster_address_from_fileblock(loc);
                    filesize = *(uint32_t*)(loc + 0x1C);
                    totalfilesize += filesize;

                    memcpy(filename, *(uint8_t*)(loc), 11);
                    if(c & (1 << 4)) { // directory entry
                        sprintf(buf, "%3u%.8s DIR       %08lX", fctr,  &filename[0x00], fc);
                        putstrnl(buf);
                    } else {           // file entry
                        sprintf(buf, "%3u%.8s.%.3s%6lu%08lX", fctr, &filename[0x00], &filename[0x08], filesize, fc);
                        putstrnl(buf);
                    }
                }
                loc += 32;  // next file entry location
            }
            caddr++;    // next sector
        }
        ctr++;  // next cluster
    }
}

/**
 * @brief Calculate the sector address from cluster and sector
 * 
 * @param cluster which cluster
 * @param sector which sector on the cluster (0-Nclusters)
 * @return uint32_t sector address (512 byte address)
 */
uint32_t fat32_calculate_sector_address(uint32_t cluster, uint8_t sector) {
    return fat32_partition.sector_begin_lba + (cluster - 2) * fat32_partition.sectors_per_cluster + sector;   
}

/**
 * @brief Build a linked list of sector addresses starting from a root address
 * 
 * @param nextcluster first cluster in the linked list
 */
 void fat32_build_linked_list(uint32_t nextcluster) {
    // counter over clusters
    uint8_t ctr = 0;
    uint8_t item = 0;

    // clear previous linked list
    memset(fat32_linkedlist, 0xFF, F32_LLSZ * sizeof(uint32_t));

    // try grabbing next cluster
    while(nextcluster < 0x0FFFFFF8 && nextcluster != 0 && ctr < F32_LLSZ) {
        fat32_linkedlist[ctr] = nextcluster;
        read_sector(fat32_partition.fat_begin_lba + (nextcluster >> 7));
        item = nextcluster & 0b01111111;
        nextcluster = *(uint32_t*)(SDBUF + item * 4);
        ctr++;
    }
}

uint32_t fat32_grab_cluster_address_from_fileblock(uint16_t loc) {
    return *(uint16_t*)(loc + 0x14) << 16 | 
           *(uint16_t*)(loc + 0x1A);
}