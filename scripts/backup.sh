#!/usr/bin/env bash

set -u

SOURCE="${1:-/data}"
BACKUP_ROOT="${2:-/var/backups/storage}"

TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
BACKUP_DIR="${BACKUP_ROOT}/storage_${TIMESTAMP}"

echo "======================================"
echo "       STORAGE BACKUP"
echo "======================================"
echo "Source      : $SOURCE"
echo "Backup Root : $BACKUP_ROOT"
echo "Timestamp   : $TIMESTAMP"
echo

if [[ ! -d "$SOURCE" ]]; then
    echo "ERROR: Source directory does not exist: $SOURCE"
    exit 2
fi

if ! findmnt -rn "$SOURCE" >/dev/null 2>&1; then
    echo "ERROR: Source is not a mounted filesystem: $SOURCE"
    exit 2
fi

sudo mkdir -p "$BACKUP_DIR"

echo "[1] Creating backup..."

if sudo rsync -aHAX --delete "$SOURCE/" "$BACKUP_DIR/"; then
    echo "Backup completed successfully."
else
    echo "ERROR: Backup failed."
    exit 2
fi

echo
echo "[2] Backup validation"

if sudo test -f "$BACKUP_DIR/day13-test/test.txt"; then
    echo "PASS: Test workload found in backup."
else
    echo "WARNING: Test workload not found in backup."
fi

echo
echo "[3] Backup size"
sudo du -sh "$BACKUP_DIR"

echo
echo "Backup Location:"
echo "$BACKUP_DIR"

echo
echo "STATUS: SUCCESS"
exit 0