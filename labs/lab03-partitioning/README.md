# Lab 03 — Linux Disk Partitioning

## Objective

Understand how to identify a Linux block device and create a partition using `fdisk`.

## Environment

- Cloud: Microsoft Azure
- OS: Linux
- Lab Disk: `/dev/nvme0n2`
- Disk Size: 4 GB
- Partition: `/dev/nvme0n2p1`
- Partition Type: Linux (83)

## Storage Flow

```text
Azure Managed Disk
        ↓
Linux Block Device
        ↓
/dev/nvme0n2
        ↓
Partition Table
        ↓
/dev/nvme0n2p1
Step 1 — Identify Disks
lsblk

Used to identify available disks, partitions and mount points.

Step 2 — Inspect the Lab Disk
sudo fdisk -l /dev/nvme0n2

This verifies the selected disk before modifying it.

Important: The OS disk must not be modified.

Step 3 — Open fdisk
sudo fdisk /dev/nvme0n2
Step 4 — View Partition Table

Inside fdisk:

p

p prints the current partition table.

Step 5 — Create a New Partition

Inside fdisk:

n

Then create:

Primary partition
Partition number: 1
Default first sector
Default last sector

This creates:

/dev/nvme0n2p1
Step 6 — Verify Before Saving

Inside fdisk:

p

Expected partition:

/dev/nvme0n2p1
Step 7 — Write Changes

After verification:

w

w writes the partition table changes to disk.

Step 8 — Verify From Linux Shell

Exit fdisk and run:

lsblk

Then:

sudo fdisk -l /dev/nvme0n2

Expected:

nvme0n2
└─nvme0n2p1
Important Concepts
Disk
/dev/nvme0n2

Represents the complete 4 GB block device.

Partition
/dev/nvme0n2p1

Represents partition number 1 created inside the disk.

Partition Type
83 Linux

This identifies the partition as a Linux partition type.

Important Difference

A partition is NOT the same thing as a filesystem.

Current state:

/dev/nvme0n2
      ↓
/dev/nvme0n2p1

Filesystem creation is a separate step and will be covered in the filesystem lab.

Commands Practiced
lsblk
lsblk -f
sudo fdisk -l /dev/nvme0n2
sudo fdisk /dev/nvme0n2

Inside fdisk:

m  → Help
p  → Print partition table
n  → Create partition
w  → Write changes
Validation

The 4 GB lab disk was successfully partitioned into:

/dev/nvme0n2p1
Safety Notes

Never modify the OS disk accidentally.

Before running partitioning commands:

lsblk

Always identify the correct data disk first.

Do not run filesystem or partitioning commands against the OS disk.

Evidence

Screenshots are stored under:

screenshots/lab03/
Status

✅ Disk identified
✅ Partition created
✅ Partition table verified
✅ Changes written
✅ Partition verified from Linux shell