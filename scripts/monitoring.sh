#!/usr/bin/env bash

set -u

MOUNT_POINT="${1:-/data}"
SERVICE="${2:-}"

echo "======================================"
echo "       SYSTEM STORAGE MONITOR"
echo "======================================"
echo "Timestamp : $(date '+%Y-%m-%d %H:%M:%S')"
echo

echo "[1] Filesystem"
df -hT "$MOUNT_POINT"

echo
echo "[2] Inodes"
df -ih "$MOUNT_POINT"

echo
echo "[3] Memory"
free -h

echo
echo "[4] Load Average"
uptime

echo
echo "[5] Disk Devices"
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS

if [[ -n "$SERVICE" ]]; then
    echo
    echo "[6] Service Health"

    if systemctl is-active --quiet "$SERVICE"; then
        echo "Service : $SERVICE"
        echo "Status  : ACTIVE"
    else
        echo "Service : $SERVICE"
        echo "Status  : INACTIVE"
        exit 1
    fi
fi

echo
echo "======================================"
echo "MONITORING COMPLETE"
echo "======================================"

exit 0