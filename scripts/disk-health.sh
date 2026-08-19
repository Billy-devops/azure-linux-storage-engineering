#!/usr/bin/env bash

set -u

MOUNT_POINT="${1:-/data}"

WARN_THRESHOLD=80
CRITICAL_THRESHOLD=90

echo "======================================"
echo "       DISK HEALTH CHECK"
echo "======================================"
echo "Mount Point : $MOUNT_POINT"
echo "Timestamp   : $(date '+%Y-%m-%d %H:%M:%S')"
echo

# 1. Directory check
if [[ ! -d "$MOUNT_POINT" ]]; then
    echo "STATUS      : CRITICAL"
    echo "ERROR       : Directory does not exist: $MOUNT_POINT"
    exit 2
fi

# 2. Mount check
if ! findmnt -rn "$MOUNT_POINT" >/dev/null 2>&1; then
    echo "STATUS      : CRITICAL"
    echo "ERROR       : $MOUNT_POINT is not mounted"
    exit 2
fi

# 3. Filesystem information
DEVICE=$(findmnt -rn -o SOURCE "$MOUNT_POINT")
FILESYSTEM=$(findmnt -rn -o FSTYPE "$MOUNT_POINT")

# 4. Usage
USAGE=$(df -P "$MOUNT_POINT" | awk 'NR==2 {gsub("%","",$5); print $5}')
AVAILABLE=$(df -hP "$MOUNT_POINT" | awk 'NR==2 {print $4}')

echo "Device      : $DEVICE"
echo "Filesystem  : $FILESYSTEM"
echo "Usage       : ${USAGE}%"
echo "Available   : $AVAILABLE"
echo

# 5. Threshold evaluation
if (( USAGE >= CRITICAL_THRESHOLD )); then
    echo "STATUS      : CRITICAL"
    echo "ACTION      : Immediate storage investigation required"
    exit 2
elif (( USAGE >= WARN_THRESHOLD )); then
    echo "STATUS      : WARNING"
    echo "ACTION      : Storage cleanup/expansion should be planned"
    exit 1
else
    echo "STATUS      : HEALTHY"
    exit 0
fi