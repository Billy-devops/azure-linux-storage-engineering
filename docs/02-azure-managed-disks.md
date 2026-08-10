Isko directly docs/day02-storage-concepts.md me paste kar de:

# Day 02 — Linux Storage Concepts

## Linux Disk, Partition, Filesystem and Mount Management

---

## 1. Objective

The objective of Day 02 is to understand how Linux handles storage at the operating-system level.

The main storage workflow covered in this module is:

```text
Physical / Azure Data Disk
        ↓
Block Device
        ↓
Partition
        ↓
Filesystem
        ↓
Mount Point
        ↓
Directory / Files
        ↓
Application Data

In this lab, an Azure Linux VM was used to understand the complete storage lifecycle.

2. Understanding Linux Storage

Linux does not directly work with an Azure disk as a normal directory.

A newly attached disk generally needs to go through several stages before applications can use it.

Example:

Azure Managed Disk
       ↓
Linux Block Device
       ↓
Partition
       ↓
Filesystem
       ↓
Mount
       ↓
/data
       ↓
Application Files

Each layer has a different responsibility.

3. Disk vs Partition vs Filesystem

These three concepts are very important.

Disk

A disk is the actual block storage device presented to Linux.

Example:

/dev/nvme0n2

This represents the complete 4 GB disk used in the Day 02 lab.

Partition

A partition is a logical section of a disk.

Example:

/dev/nvme0n2p1

Here:

/dev/nvme0n2
        ↓
      Disk

/dev/nvme0n2p1
        ↓
     Partition 1

A single disk can contain multiple partitions.

Example:

/dev/nvme0n2
├── /dev/nvme0n2p1
├── /dev/nvme0n2p2
└── /dev/nvme0n2p3

For this lab, only one partition was created.

4. What is a Block Device?

Linux represents storage devices as block devices.

Examples:

/dev/nvme0n1
/dev/nvme0n2
/dev/sda
/dev/sdb

Block devices allow Linux to read and write data in blocks.

The exact device name is not guaranteed to be the same across different VMs.

For example, one VM may show:

/dev/sdb

while another VM may show:

/dev/nvme0n2

Therefore, we should never blindly assume that a data disk will always be /dev/sdb.

The correct approach is:

lsblk

and then identify the correct device.

5. Azure VM Storage Used in This Lab

The Azure VM showed:

nvme0n1      30G   → OS Disk
nvme1n1     110G   → Additional Disk
nvme0n2       4G   → Day 02 Lab Disk

The OS disk was:

/dev/nvme0n1

and contained the root filesystem:

/

The dedicated 4 GB lab disk was:

/dev/nvme0n2

Only the 4 GB disk was used for partitioning and filesystem practice.

6. Identifying Disks with lsblk

The primary command for identifying block devices is:

lsblk

Example:

NAME         SIZE TYPE MOUNTPOINTS

nvme0n1       30G disk
├─nvme0n1p1   29G part /
├─nvme0n1p14   4M part
├─nvme0n1p15 106M part /boot/efi
└─nvme0n1p16 913M part /boot

nvme1n1      110G disk

nvme0n2        4G disk

This output allows us to understand:

Which disks exist
Disk sizes
Which partitions exist
Which partition is mounted
Which device is the OS disk
Which device is unused
7. Why lsblk is Important for DevOps Engineers

In real environments, disks can be attached dynamically.

For example:

Azure VM
   ↓
Attach Managed Disk
   ↓
Linux detects device
   ↓
lsblk
   ↓
Identify device

Before running commands such as:

mkfs
fdisk
mount

we must first identify the correct device.

This is especially important because formatting the wrong disk can destroy existing data.

8. Partitioning

Partitioning divides a disk into logical sections.

The fdisk utility can be used to create partitions.

Example:

sudo fdisk /dev/nvme0n2

A new partition was created:

/dev/nvme0n2p1

The resulting structure became:

/dev/nvme0n2
└── /dev/nvme0n2p1
9. Why Partitioning is Required

A disk and filesystem are different layers.

The disk itself is a block storage device.

A filesystem provides the structure required to store files and directories.

Conceptually:

Disk
 ↓
Partition
 ↓
Filesystem
 ↓
Files

Partitioning allows us to define which portion of the disk will be used for a particular purpose.

10. Filesystem

A filesystem defines how data is organized and stored on a storage device.

Linux supports several filesystems.

Examples include:

ext4
xfs
btrfs

For this lab, the ext4 filesystem was used.

11. Creating an ext4 Filesystem

Command:

sudo mkfs.ext4 /dev/nvme0n2p1

The mkfs command creates a filesystem.

Here:

mkfs
 ↓
make filesystem

and:

.ext4
 ↓
filesystem type

Therefore:

mkfs.ext4

means:

Create an ext4 filesystem
12. Important Warning About mkfs

The following command is destructive when used on a device containing existing data:

sudo mkfs.ext4 /dev/nvme0n2p1

It creates a new filesystem and can make previous filesystem data inaccessible.

Therefore:

Never run mkfs blindly.

Always identify the correct device first:

lsblk

For this lab:

/dev/nvme0n2

was intentionally selected as the dedicated lab disk.

13. Verify Filesystem

After creating the filesystem:

lsblk -f

This command provides filesystem information.

Example:

NAME         FSTYPE UUID                                 MOUNTPOINTS
nvme0n2
└─nvme0n2p1  ext4   xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

Important fields include:

FSTYPE
UUID
MOUNTPOINTS
14. What is Mounting?

Creating a filesystem does not automatically make it available through a normal directory.

For example:

/dev/nvme0n2p1

may have an ext4 filesystem, but applications cannot simply use /data until the filesystem is mounted there.

Mounting connects a filesystem to the Linux directory tree.

Example:

/dev/nvme0n2p1
       ↓
      ext4
       ↓
     mount
       ↓
     /data
15. Mount Point

A mount point is a directory where a filesystem is attached.

For this lab:

/data

was used as the mount point.

Create it with:

sudo mkdir -p /data
16. Mounting the Filesystem

Command:

sudo mount /dev/nvme0n2p1 /data

After this operation:

/dev/nvme0n2p1
       ↓
      ext4
       ↓
     /data

The files stored on the filesystem become accessible through /data.

17. Understanding the Linux Directory Tree

Linux has a single directory tree.

The root is:

/

Directories such as:

/etc
/var
/home
/opt
/data

exist below /.

A mounted filesystem becomes part of this directory tree.

For example:

/
├── etc
├── var
├── home
├── opt
└── data

The /data directory can represent the root of the mounted filesystem.

18. Mount vs Directory

A directory and a mounted filesystem are not the same thing.

Initially:

/data

is simply a directory.

After:

sudo mount /dev/nvme0n2p1 /data

the filesystem becomes accessible through that directory.

Conceptually:

Before mount:

/
└── data
    └── normal directory


After mount:

/
└── data
    └── ext4 filesystem
19. Verifying Mount

Use:

findmnt /data

This shows the filesystem mounted at /data.

Another useful command:

df -h /data

This displays filesystem storage usage.

20. df vs du

This is an important Linux troubleshooting concept.

df
df -h

df shows filesystem-level storage usage.

Example information:

Filesystem
Size
Used
Available
Use%
Mounted on

Use df when you want to know:

How much space is available in this filesystem?

du
du -sh /data

du shows how much space files/directories are consuming.

Use du when you want to know:

Which directory/files are consuming storage?

21. Creating Test Data

After mounting the filesystem:

echo "Linux Storage Engineering Day 02" | sudo tee /data/test.txt

This creates:

/data/test.txt

Read it using:

cat /data/test.txt

Expected output:

Linux Storage Engineering Day 02

This validates that the filesystem is writable.

22. Filesystem UUID

Every filesystem can have a UUID.

UUID means:

Universally Unique Identifier

Check it using:

sudo blkid /dev/nvme0n2p1

Example:

/dev/nvme0n2p1:
UUID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
TYPE="ext4"
23. Why UUID is Important

Device names can change.

For example:

/dev/sdb

on one system might appear as:

/dev/nvme0n2

on another system.

Because of this, using a stable identifier such as UUID is useful for persistent storage configuration.

For example:

UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

This concept becomes especially important when configuring:

/etc/fstab

which will be covered in the next storage module.

24. Unmounting

A mounted filesystem can be detached using:

sudo umount /data

Important:

The command is:

umount

not:

unmount

After unmounting:

/dev/nvme0n2p1
       ↓
      ext4

      X

     /data

The filesystem is no longer attached to /data.

25. Does umount Delete Data?

No.

umount does not format or delete the filesystem.

It only removes the filesystem from the active directory tree.

Example:

Before:

/dev/nvme0n2p1
      ↓
     ext4
      ↓
    /data
      ↓
 test.txt


umount


After:

/dev/nvme0n2p1
      ↓
     ext4
      ↓
 filesystem detached

The filesystem and its data still exist on the disk.

26. Remounting

The filesystem can be mounted again:

sudo mount /dev/nvme0n2p1 /data

Then:

cat /data/test.txt

should still show:

Linux Storage Engineering Day 02

This demonstrates that unmounting did not delete the data.

27. Complete Storage Lifecycle

The complete workflow practiced in Day 02 is:

Azure Managed Disk
        ↓
Linux detects block device
        ↓
/dev/nvme0n2
        ↓
Partition
        ↓
/dev/nvme0n2p1
        ↓
Filesystem creation
        ↓
ext4
        ↓
Mount point
        ↓
/data
        ↓
Application/User Data
        ↓
/data/test.txt
28. Storage Layers

A useful mental model for Linux storage is:

┌─────────────────────────────┐
│       Application           │
├─────────────────────────────┤
│        /data/files          │
├─────────────────────────────┤
│        Mount Point          │
│            /data            │
├─────────────────────────────┤
│       Filesystem            │
│            ext4             │
├─────────────────────────────┤
│        Partition            │
│      nvme0n2p1              │
├─────────────────────────────┤
│       Block Device          │
│       nvme0n2               │
├─────────────────────────────┤
│      Azure Managed Disk     │
└─────────────────────────────┘

Understanding these layers is important for Linux and DevOps troubleshooting.

29. Common Commands
List disks
lsblk
List disks with filesystem information
lsblk -f
Partition a disk
sudo fdisk /dev/nvme0n2
Create ext4 filesystem
sudo mkfs.ext4 /dev/nvme0n2p1
Create mount point
sudo mkdir -p /data
Mount filesystem
sudo mount /dev/nvme0n2p1 /data
Verify mount
findmnt /data
Check filesystem usage
df -h /data
Check directory usage
du -sh /data
Check UUID
sudo blkid /dev/nvme0n2p1
Unmount
sudo umount /data
30. Common Troubleshooting Scenarios
Scenario 1 — Device Does Not Exist

Example:

The file /dev/sdb1 does not exist

Possible reason:

The actual disk may have a different device name.

Solution:

lsblk

Identify the actual device first.

Example:

/dev/nvme0n2

instead of:

/dev/sdb
Scenario 2 — Partition Does Not Exist

If:

/dev/nvme0n2p1

does not exist, check:

lsblk

If only:

nvme0n2

exists, the disk has no partition yet.

Create one using:

sudo fdisk /dev/nvme0n2
Scenario 3 — Mount Fails

Check filesystem:

lsblk -f

Check device:

sudo blkid

Check whether something is already mounted:

findmnt
Scenario 4 — Disk Space Full

First check:

df -h

Then identify large directories:

du -sh /var/*

This is a common Linux production troubleshooting workflow.

31. Important Safety Rules

Before performing storage operations:

Rule 1

Always identify the disk:

lsblk
Rule 2

Never run mkfs on an unknown device.

Rule 3

Never partition an unknown disk.

Rule 4

Confirm the OS disk before modifying storage.

Rule 5

Use UUID-based persistent configuration where appropriate.

Rule 6

Before unmounting, make sure applications are not actively using the filesystem.

32. Day 02 Practical Summary

The following operations were completed:

1. Identify disk
       ↓
2. Select 4 GB lab disk
       ↓
3. Create partition
       ↓
4. Create ext4 filesystem
       ↓
5. Create /data
       ↓
6. Mount filesystem
       ↓
7. Create test file
       ↓
8. Validate storage
       ↓
9. Check UUID
       ↓
10. Unmount
       ↓
11. Remount
       ↓
12. Validate data persistence
33. DevOps Engineering Perspective

Linux storage knowledge is important for DevOps and infrastructure engineering.

Storage problems can affect:

Application deployments
Databases
Logs
Docker/container workloads
Kubernetes workloads
Monitoring systems
CI/CD agents
Backup systems
Application performance

For example, if an application server reports:

No space left on device

a DevOps engineer should be able to investigate:

df -h

Then identify which filesystem is full.

After that:

du -sh

can help identify which directories are consuming space.

Therefore, understanding Linux storage is not only about creating disks. It is also an important production troubleshooting skill.

34. Day 02 Key Takeaways
Disk
=
Block storage device


Partition
=
Logical section of a disk


Filesystem
=
Structure used to organize files


Mount Point
=
Directory where filesystem is attached


UUID
=
Stable filesystem identifier


mount
=
Attach filesystem


umount
=
Detach filesystem


df
=
Filesystem space usage


du
=
Directory/file space usage


lsblk
=
Block device discovery


blkid
=
Filesystem identity information
35. Final Architecture
                 Azure
                   │
                   ▼
          Azure Managed Disk
                   │
                   ▼
             /dev/nvme0n2
                   │
                   ▼
             Partitioning
                   │
                   ▼
          /dev/nvme0n2p1
                   │
                   ▼
              ext4 FS
                   │
                   ▼
                mount
                   │
                   ▼
                 /data
                   │
                   ▼
              test.txt
                   │
                   ▼
          Application Data