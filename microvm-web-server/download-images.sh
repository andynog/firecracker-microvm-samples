#!/usr/bin/env bash

# Ensure images folder exist
mkdir images

# Download kernel
echo "Downloading kernel..."
curl -fsSL -o ./images/hello-vmlinux.bin https://s3.amazonaws.com/spec.ccfc.min/img/hello/kernel/hello-vmlinux.bin

# Download rootfs
echo "Downloading rootfs..."
curl -fsSL -o ./images/web-server-rootfs.ext4 https://s3.amazonaws.com/spec.ccfc.min/img/ubuntu/fsfiles/xenial.rootfs.ext4

echo "Done"
