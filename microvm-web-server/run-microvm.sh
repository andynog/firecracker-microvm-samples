#!/usr/bin/env bash

#################################################################################
# Parameters
#################################################################################

# Kernel Image
KERNEL=$PWD/images/hello-vmlinux.bin

# Root Filesystem (rootfs) Image
ROOTFS=$PWD/images/web-server-rootfs.ext4

# Number of vCPUs to allocate for the microvm
VCPU_COUNT=1

# Memory Size (MB) to allocate for the microvm. This sample allocates only 128 MB
MEM_SIZE_MIB=128

# Unix socket to communicate with Firecracker.
# This should match the socket parameter in the script used to run firecracker (start-firecracker.sh)
FIRECRACKER_SOCK=/tmp/firecracker-web-server.sock

# Firecracker's log
FIRECRACKER_LOG=/tmp/firecracker-web-server-log.fifo

# Make sure Firecracker log is clean
rm -f $FIRECRACKER_LOG

# Create named pipe (FIFO) for log
mkfifo $FIRECRACKER_LOG

# Firecracker's metrics
FIRECRACKER_METRICS=/tmp/firecracker-web-server-metrics.fifo

# Make sure Firecracker metrics is clean
rm -f $FIRECRACKER_METRICS

# Create named pipe (FIFO) for metrics
mkfifo $FIRECRACKER_METRICS

#################################################################################
# Setup networking on host
# ################################################################################

sudo ip tuntap add tap0 mode tap
sudo ip addr add 172.16.0.1/24 dev tap0
sudo ip link set tap0 up
sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i tap0 -o eth0 -j ACCEPT

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


# Configure the network
curl --unix-socket $FIRECRACKER_SOCK -i \
  -X PUT 'http://localhost/network-interfaces/eth0' \
  -H 'Accept: application/json' \
  -H 'Content-Type:application/json' \
  -d '{
      "iface_id": "eth0",
      "guest_mac": "AA:FC:00:00:00:01",
      "host_dev_name": "tap0"
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