#!/usr/bin/env bash

set -u

BACKUP_SOURCE="${1:-}"
RESTORE_TARGET="${2:-}"

echo "======================================"
echo "       STORAGE RESTORE"
echo "======================================"

if [[ -z "$BACKUP_SOURCE" || -z "$RESTORE_TARGET" ]]; then
    echo "Usage: $0 <backup-source> <restore-target>"
    exit 1
fi

echo "Backup Source : $BACKUP_SOURCE"
echo "Restore Target: $RESTORE_TARGET"
echo

if [[ ! -d "$BACKUP_SOURCE" ]]; then
    echo "ERROR: Backup source does not exist: $BACKUP_SOURCE"
    exit 2
fi

if [[ ! -d "$RESTORE_TARGET" ]]; then
    echo "Creating restore target..."
    sudo mkdir -p "$RESTORE_TARGET"
fi

echo "[1] Restoring backup..."

if sudo rsync -aHAX "$BACKUP_SOURCE/" "$RESTORE_TARGET/"; then
    echo "Restore completed successfully."
else
    echo "ERROR: Restore operation failed."
    exit 2
fi

echo
echo "[2] Restore validation"

if sudo test -f "$RESTORE_TARGET/day13-test/test.txt"; then
    echo "PASS: Restored workload found."
else
    echo "ERROR: Restored workload not found."
    exit 2
fi

echo
echo "[3] Restored content"

sudo cat "$RESTORE_TARGET/day13-test/test.txt"

echo
echo
echo "STATUS: SUCCESS"
exit 0