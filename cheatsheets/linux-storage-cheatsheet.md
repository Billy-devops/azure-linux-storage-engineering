Linux Storage Cheatsheet

Quick reference for Linux storage administration.

🧩 Storage Layers
Physical / Azure Disk
        ↓
Block Device
        ↓
Partition
        ↓
Filesystem
        ↓
Mountpoint
        ↓
Application / Database

With LVM:

Disk
 ↓
Partition
 ↓
Physical Volume
 ↓
Volume Group
 ↓
Logical Volume
 ↓
Filesystem
 ↓
Mountpoint
🔍 Storage Discovery
lsblk
lsblk -f
blkid
findmnt
df -hT
df -ih
💽 Disk Information

Show disks:

lsblk -d

Show sizes:

lsblk -o NAME,SIZE,TYPE

Show filesystem information:

lsblk -f

Show partition table:

sudo fdisk -l
📦 Storage Usage

Filesystem usage:

df -hT

Inodes:

df -ih

Directory usage:

sudo du -xhd1 / | sort -h

Find large directories:

sudo du -xhd1 /var | sort -h
🧱 Partitioning

Using fdisk:

sudo fdisk /dev/nvme0n2

Using parted:

sudo parted /dev/nvme0n2

Create GPT:

sudo parted -s /dev/nvme0n2 mklabel gpt

Create partition:

sudo parted -s /dev/nvme0n2 mkpart primary ext4 0% 100%

Verify:

lsblk
sudo fdisk -l /dev/nvme0n2
🗃️ Filesystems

Create ext4:

sudo mkfs.ext4 /dev/nvme0n2p1

Verify:

sudo blkid /dev/nvme0n2p1

Check filesystem:

sudo fsck -f /dev/nvme0n2p1
📍 Mounting

Create mountpoint:

sudo mkdir -p /data

Mount:

sudo mount /dev/nvme0n2p1 /data

Verify:

findmnt /data
df -hT /data

Unmount:

sudo umount /data
🔐 Persistent Mounting

Get UUID:

blkid /dev/nvme0n2p1

Edit fstab:

sudo nano /etc/fstab

Example:

UUID=<UUID> /data ext4 defaults,nofail 0 2

Validate:

sudo mount -a

Verify:

findmnt /data
📈 Storage Expansion

General workflow:

Increase Azure Disk
       ↓
Linux detects larger disk
       ↓
Expand partition if required
       ↓
Expand PV/LV if using LVM
       ↓
Expand filesystem
       ↓
Verify capacity

Always verify:

lsblk
df -hT
🚨 Storage Troubleshooting
Disk not visible
lsblk
dmesg | tail -50
Mount failed
findmnt
sudo mount -a
sudo journalctl -xe
Disk full
df -hT
sudo du -xhd1 / | sort -h
Inodes exhausted
df -ih
Mountpoint busy
sudo lsof +D /data
sudo fuser -vm /data
🧠 Production Rules
Never assume a device name.
Verify the disk before destructive operations.
Prefer UUIDs in /etc/fstab.
Validate fstab using mount -a.
Maintain backups before risky operations.
Verify storage after every change.
Monitor both capacity and inodes.
Document storage architecture.
Test backup restoration.
Automate repetitive operations safely.
✅ Storage Validation Checklist
[ ] Disk identified
[ ] Correct device verified
[ ] Partition verified
[ ] Filesystem verified
[ ] Mountpoint verified
[ ] fstab validated
[ ] Capacity verified
[ ] Application validated
[ ] Backup verified
[ ] Monitoring configured