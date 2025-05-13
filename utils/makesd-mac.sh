#!/bin/bash

COPY_DIR="$1"
[ -z "$COPY_DIR" ] && echo "usage: $0 <dir>" && exit 1

# Create the empty disk image file,
dd if=/dev/zero of=myimage.img bs=1m count=100
# Assign a /dev entry to the disk image file,
devEntry="$(hdiutil attach -nomount myimage.img)"
# Show ouput from hdiutil.
echo "$devEntry"
# Remove whitespace from variable devEntry.
devEntry="$(echo $devEntry)"
# Create a MBR partition table and mount the newly created FAT32 volume.
diskutil erasedisk fat32 MYSD mbr "$devEntry"
# Copy files from the folder to FAT32 volume.
cp -R "$COPY_DIR/" /Volumes/MYSD
# Remove all ._* files.
dot_clean /Volumes/MYSD
# Eject the disk image.
hdiutil detach "$devEntry"