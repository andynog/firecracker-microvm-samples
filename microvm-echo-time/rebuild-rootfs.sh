#!/usr/bin/env bash

#################################################################################
# Parameters
#################################################################################

# The rootfs image file
ROOTFS_IMAGE=echo-time-minvm-rootfs.ext4

# Temporary mount folder
MOUNT_FOLDER=/tmp/echo-rootfs

# Rust Executable
EXECUTABLE_NAME=echo-time
EXECUTABLE_SOURCE=./echo-time/target/x86_64-unknown-linux-musl/release/$EXECUTABLE_NAME

#################################################################################
# Rebuild the executable and copy it to the rootfs image
#################################################################################

# Switch to the Rust program folder
cd ./echo-time

# Rebuild the Rust executable using the x86_64-unknown-linux-musl target in order to run inside the Micro VM
cargo build --target x86_64-unknown-linux-musl --release

# Switch back to script folder
cd ..

# Try to unmount folder
echo 'Umount image in case is still mounted'
sudo umount $MOUNT_FOLDER

# Remove mount folder
echo 'Removing old mount folder'
sudo rm -Rf $MOUNT_FOLDER

# Create mount folder
echo 'Creating the mount folder'
sudo mkdir $MOUNT_FOLDER

# Mount image on mount folder
echo 'Mounting the rootfs image'
sudo mount $ROOTFS_IMAGE $MOUNT_FOLDER

# Remove old executable
echo 'Removing old executable'
sudo rm -f $MOUNT_FOLDER/bin/$EXECUTABLE_NAME

# Copy executable into rootfs bin folder
echo 'Copying new executable to rootfs image'
sudo cp $EXECUTABLE_SOURCE $MOUNT_FOLDER/bin

# Make it executable
echo 'Making the new file executable'
sudo chmod +x $MOUNT_FOLDER/bin

# Unmount the rootfs image
echo 'Unmount the rootfs image'
sudo umount $MOUNT_FOLDER

echo 'Rootfs image updated with new executable'
