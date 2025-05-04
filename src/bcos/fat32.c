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
struct FAT32Folder fat32_current_folder;
struct FAT32Folder fat32_root_folder;
struct FAT32File *fat32_files = (struct FAT32File*)FAT32FILESLOC;
struct FAT32Folder *fat32_fullpath = (struct FAT32Folder*)FAT32FOLDERLOC;
uint8_t fat32_pathdepth = 0;

/**
 * Read the Master Boot Record from the SD card, assumes that the SD-card
 * has already been initialized.
 */
uint8_t fat32_read_mbr(void) {
    uint16_t checksum_sd = 0x0000;
    uint16_t checksum = 0x0000;
    uint8_t* sdbuf = (uint8_t*)(SDBUF);

    if(read_sector(0x00000000) != 0) {
        return -1;
    }

    // check partition type
    if(sdbuf[0x1C2] != 0x0C) {
        return -1;
    }

    // check pattern
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
    // extract logical block address (LBA) from partition table
    uint32_t lba = *(uint32_t*)(SDBUF + 0x1C6);

    // retrieve the partition table
    if(read_sector(lba) != 0) {
        return;
    }

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
    fat32_current_folder.cluster = fat32_partition.root_dir_first_cluster;
    fat32_current_folder.nrfiles = 0;
    memset(fat32_current_folder.name, 0x00, 11);
    fat32_root_folder = fat32_current_folder;
    fat32_fullpath[0] = fat32_root_folder;
    fat32_pathdepth = 1;

    // read first sector of first partition to establish volume name
    read_sector(fat32_partition.lba_addr_root_dir);

    // copy volume name
    memcpy(fat32_partition.volume_label, (uint8_t*)(SDBUF), 11);
}

/**
 * Print partition info
 */
void fat32_print_partition_info() {
    char buf[32];
    sprintf(buf, "LBA partition 1: %08lX", fat32_partition.fat_begin_lba - 
                                           fat32_partition.reserved_sectors);
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

    sprintf(buf, "Address ROOT dir: %08lX", fat32_partition.lba_addr_root_dir);
    putstrnl(buf);

    sprintf(buf, "Volume name: %.11s\0", (uint8_t*)(SDBUF));
    putstrnl(buf);
}

/**
 * Read the contents of the current directory, store the result starting
 * at 0x8200.
 */
void fat32_read_dir() {
    uint8_t ctr = 0;                // counter over clusters
    uint16_t fctr = 0;              // counter over directory entries (files and folders)
    uint8_t i = 0, j = 0;
    uint8_t* locptr = NULL;
    struct FAT32File *file = NULL;

    // build linked list
    fat32_build_linked_list(fat32_current_folder.cluster);

    while(fat32_linkedlist[ctr] != 0xFFFFFFFF && ctr < F32_LLSZ) {
        // print cluster number and address
        uint32_t caddr = fat32_calculate_sector_address(fat32_linkedlist[ctr], 0);

        // loop over all sectors per cluster
        for(i=0; i<fat32_partition.sectors_per_cluster; i++) {
            read_sector(caddr);            // read sector data
            locptr = (uint8_t*)(SDBUF);    // set pointer to sector data
            for(j=0; j<16; j++) { // 16 file tables per sector
                // continue if an unused entry is encountered 0xE5
                if(*locptr == 0xE5) {
                    locptr += 32;  // next file entry location
                    continue;
                }

                // early exit if a zero is read
                if(*locptr == 0x00) {
                    file = &fat32_files[fctr];
                    fat32_current_folder.nrfiles = fctr;
                    return;
                }

                // check if we are reading a file or a folder
                if((*(locptr + 0x0B) & 0x0F) == 0x00) {

                    file = &fat32_files[fctr];
                    memcpy(file->basename, locptr, 11);
                    file->termbyte = 0x00;  // by definition
                    file->attrib = *(locptr + 0x0B);
                    file->cluster = fat32_grab_cluster_address_from_fileblock(locptr);
                    file->filesize = *(uint32_t*)(locptr + 0x1C);
                    fctr++;

                    if(fctr > MAXFILES) {
                        putstrnl("Error: too many entries in folder; cannot parse...");
                        return;
                    }
                }
                locptr += 32;  // next file entry location
            }
            caddr++;    // next sector
        }
        ctr++;  // next cluster
    }
    fat32_current_folder.nrfiles = fctr;
}

/**
 * Sort the files in the file list
 */
void fat32_sort_files() {
    qsort(fat32_files, fat32_current_folder.nrfiles, sizeof(struct FAT32File), fat32_file_compare);
}

/**
 * List the contents of the current directory
 */
void fat32_list_dir() {
    uint16_t i = 0;
    uint8_t buf[80];
    struct FAT32File *file = fat32_files;
    for(i = 0; i<fat32_current_folder.nrfiles; i++) {
        if(file->attrib & MASK_DIR) {
            sprintf(buf, "%.8s %.3s %08lX DIR", file->basename, file->extension, file->cluster);
        } else {
            sprintf(buf, "%.8s.%.3s %08lX %lu", file->basename, file->extension, file->cluster, file->filesize);
        }
        putstrnl(buf);
        file++;
    }
}

/**
 * Find a file
 */
 struct FAT32File* fat32_search_dir(const char* filename, uint8_t entry_type) {
    struct FAT32File key;
    memcpy(key.basename, filename, 11);
    key.termbyte = 0x00;
    key.attrib = (entry_type == FOLDER_ENTRY) ? MASK_DIR : 0;

    return (struct FAT32File*)bsearch(&key, fat32_files, fat32_current_folder.nrfiles, sizeof(struct FAT32File), fat32_file_compare);
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
 * Load a file to location in RAM
 */
void fat32_load_file(const struct FAT32File* fileptr, uint8_t* location) {
    uint32_t* addr = fat32_linkedlist;
    uint32_t caddr;
    uint32_t nbytes = 0;
    uint8_t i=0;

    if(fileptr->filesize < 0x7500) { // 29 KiB
        fat32_build_linked_list(fileptr->cluster);

        while(*addr != 0x0FFFFFFF && nbytes < fileptr->filesize) {
            caddr = fat32_calculate_sector_address(*(addr++), 0);

            for(i=0; i<fat32_partition.sectors_per_cluster; i++) {
                read_sector(caddr);
                caddr++;
                memcpy(location, (uint8_t*)SDBUF, 0x200);
                location += 0x200;

                nbytes += 0x200;
                if(nbytes >= fileptr->filesize) {
                    break;
                }
            }
        }
    }
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

/**
 * @brief Construct sector address from file entry
 * 
 * @return uint32_t sector address
 */
uint32_t fat32_grab_cluster_address_from_fileblock(uint8_t *loc) {
    return ((uint32_t)*(uint16_t*)(loc + 0x14)) << 16 | 
                      *(uint16_t*)(loc + 0x1A);
}

/**
 * @brief Compare two files
 *
 * This routine is used for both searching a file/folder as well as for
 * sorting files.
 */
int fat32_file_compare(const void* item1, const void *item2) {
    const struct FAT32File *file1 = (const struct FAT32File*)item1;
    const struct FAT32File *file2 = (const struct FAT32File*)item2;

    // Extract directory bit (1 if directory, 0 otherwise)
    uint8_t is_dir1 = (file1->attrib & MASK_DIR) != 0;
    uint8_t is_dir2 = (file2->attrib & MASK_DIR) != 0;

    // Sort directories before files
    if (is_dir1 && !is_dir2) {
        return -1;
    } else if (!is_dir1 && is_dir2) {
        return 1;
    }

    // if same type, compare names
    return strcmp(file1->basename, file2->basename);
}
