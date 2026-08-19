#!/usr/bin/env bash

set -u

LV_PATH="${1:-}"
SIZE="${2:-}"

echo "======================================"
echo "       LVM RESIZE VALIDATION"
echo "======================================"

if [[ -z "$LV_PATH" || -z "$SIZE" ]]; then
    echo "Usage: $0 <logical-volume> <size>"
    echo
    echo "Example:"
    echo "  $0 /dev/vgdata/lvapp +3G"
    exit 1
fi

echo "Logical Volume : $LV_PATH"
echo "Requested Size : $SIZE"
echo

if ! command -v lvs >/dev/null 2>&1; then
    echo "ERROR: LVM tools are not installed."
    exit 2
fi

if ! sudo lvs "$LV_PATH" >/dev/null 2>&1; then
    echo "ERROR: Logical volume does not exist: $LV_PATH"
    echo "No resize operation performed."
    exit 2
fi

echo "[1] LVM volume detected"
sudo lvs "$LV_PATH"

echo
echo "[2] Resizing logical volume"

if sudo lvextend -r -L "$SIZE" "$LV_PATH"; then
    echo "LVM resize completed successfully."
else
    echo "ERROR: LVM resize failed."
    exit 2
fi

echo
echo "[3] Final validation"
sudo lvs "$LV_PATH"

echo
echo "STATUS: SUCCESS"
exit 0