#!/bin/bash

loremipsum () {
  if [ "${1}" = "" ] || [ "${2}" = "" ]; then
    echo "Usage: loremipsum [paragraphs, sentences] [integer]"
  else
    curl -s http://metaphorpsum.com/"${1}"/"${2}" && printf "\n"
  fi
}

set -e  # Exit on error

# delete any existing files and folders
rm -rf *.img *.zip software-main

# Configuration
IMAGE_NAME="sdcard.img"
PARTITION_SIZE="128MiB"
FILESYSTEM="fat32"
LABEL="BYTECRADLE"

# Step 1: Create an empty image file
echo "Creating an empty image file of size $PARTITION_SIZE..."
dd if=/dev/zero of=$IMAGE_NAME bs=1M count=$(echo $PARTITION_SIZE | sed 's/MiB//')

# Step 2: Partition the image
echo "Partitioning the image..."
parted --script $IMAGE_NAME mklabel msdos
parted --script $IMAGE_NAME mkpart primary $FILESYSTEM 1MiB 100%

# Step 3: Associate the image with a loop device
LOOP_DEVICE=$(losetup --show -fP $IMAGE_NAME)
echo "Image attached to loop device: $LOOP_DEVICE"

# Step 4: Format the partition as FAT32
echo "Formatting the partition as FAT32..."
mkfs.vfat -F 32 -n $LABEL "${LOOP_DEVICE}p1"

# Step 5: Mount and populate partitions
echo "Mounting partitions..."
ROOT_MOUNT=$(mktemp -d)

# Step 6: mount device
mount "${LOOP_DEVICE}p1" $ROOT_MOUNT

# Step 7: Populate the partitions (customize this part as needed)
echo "Populating root partition..."
mkdir -p $ROOT_MOUNTls
loremipsum paragraphs 10 > $ROOT_MOUNT/README.txt
echo "Hello World!" > $ROOT_MOUNT/HelloWor.txt
mkdir -pv $ROOT_MOUNT/folder1/{sub1,sub2}
mkdir -pv $ROOT_MOUNT/folder2/{sub1,sub2}
loremipsum paragraphs 10 > $ROOT_MOUNT/folder1/sub1/file1.txt
loremipsum paragraphs 10 > $ROOT_MOUNT/folder1/sub2/file2.txt
loremipsum paragraphs 10 > $ROOT_MOUNT/folder2/sub1/file1.txt
loremipsum paragraphs 10 > $ROOT_MOUNT/folder2/sub2/file2.txt

# Step 8: Cleanup
echo "Unmounting and cleaning up..."
umount $ROOT_MOUNT
losetup -d $LOOP_DEVICE
rmdir $ROOT_MOUNT

echo "SD card image creation completed: $IMAGE_NAME"
