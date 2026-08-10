# Day 02 — Disk & Filesystem Lab

## Objective

Configure and validate an additional Azure Linux data disk.

## Environment

- Cloud: Microsoft Azure
- OS: Linux
- Lab Disk: `/dev/nvme0n2`
- Disk Size: 4 GB
- Filesystem: ext4
- Mount Point: `/data`

## Lab Flow

Disk
→ Partition
→ Filesystem
→ Mount
→ Data
→ Unmount
→ Remount
→ Validation

## 1. Identify Disk

```bash
lsblk

The 4 GB unused disk was identified as:

/dev/nvme0n2
2. Create Partition
sudo fdisk /dev/nvme0n2

Created:

/dev/nvme0n2p1
3. Create Filesystem
sudo mkfs.ext4 /dev/nvme0n2p1

Filesystem:

ext4
4. Create Mount Point
sudo mkdir -p /data
5. Mount
sudo mount /dev/nvme0n2p1 /data
6. Validate Mount
findmnt /data
df -h /data
7. Create Test File
echo "Linux Storage Engineering Day 02" | sudo tee /data/test.txt

Validate:

cat /data/test.txt
8. Check UUID
sudo blkid /dev/nvme0n2p1
9. Unmount
sudo umount /data
10. Remount
sudo mount /dev/nvme0n2p1 /data
11. Validate Data Persistence
cat /data/test.txt

Expected:

Linux Storage Engineering Day 02
Result

Successfully:

Identified the data disk
Created a partition
Created an ext4 filesystem
Mounted the filesystem
Created test data
Verified storage usage
Checked filesystem UUID
Unmounted and remounted the filesystem
Verified data persistence