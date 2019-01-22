#!/usr/bin/env bash

if [ -r /dev/kvm ] && [ -w /dev/kvm ]; then
 echo "KVM OK"
else
 echo "KVM not configured properly. Try to configure using 'sudo setfacl -m u:${USER}:rw /dev/kvm'"
 echo "Aborting"
 exit 1
fi

#################################################################################
# Parameters
#################################################################################

# Unix socket to communicate with Firecracker.
# This should match the socket parameter in the script used to run the microvm (run-microvm.sh)
FIRECRACKER_SOCK='/tmp/firecracker-echo-time.sock'

# Firecracker executable
FIRECRACKER_EXE='../firecracker'

#################################################################################
# Run Firecracker
#################################################################################

if [ ! -f $FIRECRACKER_EXE ]; then
    echo "Please ensure you have follow the instructions on how to obtain Firecracker executable and save it to the repository folder."
    echo "Firecracker executable file not found at => $FIRECRACKER_EXE "
    echo "Aborting..."
    exit 1
fi


# Make sure Firecracker can create its API socket
rm -f $FIRECRACKER_SOCK

# Start firecracker
echo "Start firecracker...Listening for API calls..."
../firecracker --api-sock $FIRECRACKER_SOCK