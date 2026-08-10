# 2️⃣ `docs/03-disk-partitioning.md`

Ye **concept/documentation wali file** hai:

```markdown
# 03 — Linux Disk Partitioning

## What is Disk Partitioning?

Disk partitioning is the process of dividing a physical or virtual disk into logical sections called partitions.

Example:

```text
Disk
/dev/nvme0n2
      │
      └── Partition
          /dev/nvme0n2p1

A partition provides a defined area of the disk that can later be used for a filesystem.

Disk vs Partition
Disk
/dev/nvme0n2

Represents the complete block device.

Partition
/dev/nvme0n2p1

Represents partition number 1 inside the disk.

Why Partition a Disk?

Partitioning allows storage to be logically separated.

For example:

4 GB Disk
│
├── Partition 1 → Application data
└── Partition 2 → Backup data

Different partitions can later be formatted with different filesystems or used for different workloads.

Linux Block Device

Linux represents storage devices under:

/dev/

Examples:

/dev/sda
/dev/sdb
/dev/nvme0n1
/dev/nvme0n2

NVMe devices commonly use names such as:

/dev/nvme0n1
/dev/nvme0n2

Partitions are represented as:

/dev/nvme0n2p1
/dev/nvme0n2p2
Understanding the Device Name

Example:

/dev/nvme0n2p1

Breakdown:

/dev/
  ↓
device directory

nvme0
  ↓
NVMe device/controller identifier

n2
  ↓
disk number

p1
  ↓
partition number 1
fdisk

fdisk is a command-line utility used to manage disk partition tables.

Start it with:

sudo fdisk /dev/nvme0n2

Inside fdisk:

Command	Purpose
m	Display help
p	Print partition table
n	Create a new partition
d	Delete a partition
t	Change partition type
w	Write changes
q	Quit without saving
Partition Creation Workflow
Identify Disk
     ↓
Inspect Disk
     ↓
Open fdisk
     ↓
Create Partition
     ↓
Verify Partition
     ↓
Write Changes
     ↓
Verify From Linux

Commands:

lsblk
sudo fdisk -l /dev/nvme0n2
sudo fdisk /dev/nvme0n2

Inside fdisk:

n
p
w

Then:

lsblk
Partition Type 83

In the lab the partition appeared as:

83 Linux

This is a Linux partition type identifier in the DOS/MBR partition table context.

It should not be confused with a filesystem.

Partition vs Filesystem

These are two different concepts.

Partition
/dev/nvme0n2p1

Defines an area of the disk.

Filesystem

Example:

ext4

Provides the structure used to store and manage files and directories.

Overall flow:

Disk
 ↓
Partition
 ↓
Filesystem
 ↓
Mount Point
 ↓
Files

Example:

/dev/nvme0n2
       ↓
/dev/nvme0n2p1
       ↓
ext4
       ↓
/data
       ↓
application files
Safety Considerations

Disk partitioning is a potentially destructive operation.

Before modifying a disk:

lsblk

Confirm:

Correct disk
Correct disk size
Correct device name
The disk is not the OS disk
No important data exists on the target disk

Never blindly run:

fdisk
mkfs

against an unknown device.

Lab Result

The Azure Linux VM contained a 4 GB additional disk:

/dev/nvme0n2

A Linux partition was created:

/dev/nvme0n2p1

The partition was verified using:

lsblk
sudo fdisk -l /dev/nvme0n2

Filesystem creation and mounting are separate storage operations and are covered in subsequent labs.