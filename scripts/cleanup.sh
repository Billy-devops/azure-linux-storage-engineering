#!/usr/bin/env bash

set -u

TARGET="${1:-/data/restore-test}"

echo "======================================"
echo "       STORAGE CLEANUP"
echo "======================================"
echo "Target: $TARGET"
echo

if [[ "$TARGET" == "/" || "$TARGET" == "/data" || "$TARGET" == "/var" ]]; then
    echo "ERROR: Refusing to clean protected filesystem: $TARGET"
    exit 2
fi

if [[ ! -e "$TARGET" ]]; then
    echo "INFO: Target does not exist. Nothing to clean."
    exit 0
fi

echo "[1] Target detected"
sudo ls -ld "$TARGET"

echo
echo "[2] Removing target"

if sudo rm -rf -- "$TARGET"; then
    echo "Cleanup completed successfully."
else
    echo "ERROR: Cleanup failed."
    exit 2
fi

echo
echo "[3] Validation"

if [[ ! -e "$TARGET" ]]; then
    echo "PASS: Target successfully removed."
else
    echo "FAIL: Target still exists."
    exit 2
fi

echo
echo "STATUS: SUCCESS"
exit 0