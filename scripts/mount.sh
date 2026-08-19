#!/usr/bin/env bash

set -u

DEVICE="${1:-}"
MOUNT_POINT="${2:-}"

if [[ -z "$DEVICE" || -z "$MOUNT_POINT" ]]; then
    echo "Usage: $0 <device> <mount-point>"
    exit 1
fi

echo "======================================"
echo "       STORAGE MOUNT VALIDATION"
echo "======================================"
echo "Device      : $DEVICE"
echo "Mount Point : $MOUNT_POINT"
echo

if [[ ! -b "$DEVICE" ]]; then
    echo "ERROR: Block device does not exist: $DEVICE"
    exit 2
fi

if [[ ! -d "$MOUNT_POINT" ]]; then
    echo "Creating mount point: $MOUNT_POINT"
    sudo mkdir -p "$MOUNT_POINT"
fi

if findmnt -rn "$MOUNT_POINT" >/dev/null 2>&1; then
    CURRENT_SOURCE=$(findmnt -rn -o SOURCE "$MOUNT_POINT")

    echo "INFO: Mount point already mounted."
    echo "Current Source: $CURRENT_SOURCE"

    if [[ "$CURRENT_SOURCE" == "$DEVICE" ]]; then
        echo "STATUS: HEALTHY"
        exit 0
    else
        echo "ERROR: Mount point is occupied by another device."
        exit 2
    fi
fi

echo "Mounting $DEVICE on $MOUNT_POINT..."

if sudo mount "$DEVICE" "$MOUNT_POINT"; then
    echo
    echo "Mount successful."
    findmnt "$MOUNT_POINT"
    echo
    df -hT "$MOUNT_POINT"
    echo
    echo "STATUS: HEALTHY"
    exit 0
else
    echo "STATUS: FAILED"
    exit 2
fi