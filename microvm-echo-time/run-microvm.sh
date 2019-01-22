#!/usr/bin/env bash

#################################################################################
# Parameters
#################################################################################

# Kernel Image
KERNEL=$PWD/images/hello-vmlinux.bin

# Root Filesystem (rootfs) Image
ROOTFS=$PWD/images/echo-time-minvm-rootfs.ext4

# Number of vCPUs to allocate for the microvm
VCPU_COUNT=1

# Memory Size (MB) to allocate for the microvm. This sample allocates only 64 MB
MEM_SIZE_MIB=64

# Unix socket to communicate with Firecracker.
# This should match the socket parameter in the script used to run firecracker (start-firecracker.sh)
FIRECRACKER_SOCK=/tmp/firecracker-echo-time.sock

# Firecracker's log
FIRECRACKER_LOG=/tmp/firecracker-echo-time-log.fifo

# Make sure Firecracker log is clean
rm -f $FIRECRACKER_LOG

# Create named pipe (FIFO) for log
mkfifo $FIRECRACKER_LOG

# Firecracker's metrics
FIRECRACKER_METRICS=/tmp/firecracker-echo-time-metrics.fifo

# Make sure Firecracker metrics is clean
rm -f $FIRECRACKER_METRICS

# Create named pipe (FIFO) for metrics
mkfifo $FIRECRACKER_METRICS

#################################################################################
# Call Firecracker APIs to configure and run the micro vm
#################################################################################

# Configure logging
curl --unix-socket $FIRECRACKER_SOCK -i  \
    -X PUT 'http://localhost/logger' \
    -H 'Accept: application/json'            \
    -H 'Content-Type: application/json'      \
    -d '{
           "log_fifo":"'$FIRECRACKER_LOG'",
           "metrics_fifo":"'$FIRECRACKER_METRICS'",
           "level": "Error",
           "show_level": true,
           "show_log_origin": false
     }'

# Configure the machine
curl --unix-socket $FIRECRACKER_SOCK -i  \
    -X PUT 'http://localhost/machine-config' \
    -H 'Accept: application/json'            \
    -H 'Content-Type: application/json'      \
    -d '{
        "vcpu_count":'$VCPU_COUNT',
        "mem_size_mib":'$MEM_SIZE_MIB'
    }'

# Set the guest kernel
curl --unix-socket $FIRECRACKER_SOCK  -i \
    -X PUT 'http://localhost/boot-source'   \
    -H 'Accept: application/json'           \
    -H 'Content-Type: application/json'     \
    -d '{
        "kernel_image_path": "'$KERNEL'",
        "boot_args": "console=ttyS0 reboot=k panic=1 pci=off"
    }'

# Set the guest rootfs
curl --unix-socket $FIRECRACKER_SOCK  -i \
    -X PUT 'http://localhost/drives/rootfs' \
    -H 'Accept: application/json'           \
    -H 'Content-Type: application/json'     \
    -d '{
        "drive_id": "rootfs",
        "path_on_host": "'$ROOTFS'",
        "is_root_device": true,
        "is_read_only": false
    }'

# Start the guest machine:
curl --unix-socket $FIRECRACKER_SOCK  -i \
    -X PUT 'http://localhost/actions'       \
    -H  'Accept: application/json'          \
    -H  'Content-Type: application/json'    \
    -d '{
        "action_type": "InstanceStart"
     }'