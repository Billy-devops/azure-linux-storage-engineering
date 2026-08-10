Day 04 — Linux Storage & Filesystem Verification
📅 Day 04 Practical
Topic

Azure Linux VM — Disk, Partition, Filesystem, Mount and Unmount Verification

🎯 Learning Objective

The goal of Day 04 was to understand what happens between an Azure Managed Disk and the Linux filesystem.

The practical covered:

Managed Disk
     ↓
Linux Block Device
     ↓
Partition
     ↓
Filesystem
     ↓
Mount Point
     ↓
Application Data
1. Identify the Attached Storage

The first command used was:

lsblk -f

This showed:

nvme0n2
└─nvme0n2p1  ext4

Therefore:

Disk:
 /dev/nvme0n2

Partition:
 /dev/nvme0n2p1

Filesystem:
 ext4
2. Filesystem Identification

The filesystem was inspected using:

sudo blkid /dev/nvme0n2p1

The filesystem UUID was:

a593a5bb-dbce-4feb-8826-d1c77ce4543d

Filesystem type:

ext4

UUID is important because it provides a stable identifier for the filesystem.

3. Inspect Filesystem Internals

The command:

sudo tune2fs -l /dev/nvme0n2p1

was used to inspect ext4 filesystem metadata.

Important observations:

Filesystem state: clean
Block size: 4096
Filesystem UUID: a593a5bb-dbce-4feb-8826-d1c77ce4543d
Last mounted on: /data
Important Concept

Last mounted on: /data does not mean that the filesystem is currently mounted.

It represents historical filesystem metadata.

Current mount status should be checked using:

findmnt /data
4. Verify Current Mount

The command:

findmnt /data

returned no result.

Therefore:

/data = NOT currently mounted

The command:

df -h /data

returned:

/dev/root  29G  1.6G  27G  6% /

This proves that /data was currently part of the root filesystem.

5. Important Practical Discovery

A test file was created:

sudo touch /data/day04-test.txt

The file was successfully created.

However, because /data was not mounted, the file was stored on:

/dev/root

and not on:

/dev/nvme0n2p1

This demonstrates an important Linux concept:

A directory does not automatically represent a mounted disk.

6. Mounting Model

The intended storage relationship is:

/dev/nvme0n2
       │
       ▼
/dev/nvme0n2p1
       │
       ▼
     ext4
       │
       │ mount
       ▼
     /data

After mounting:

sudo mount /dev/nvme0n2p1 /data

the /data path becomes the entry point to the attached filesystem.

7. Verification After Mount

After mounting, use:

findmnt /data

and:

df -h /data

The filesystem should now show:

/dev/nvme0n2p1

rather than:

/dev/root

This confirms that the mount was successful.

8. Test Data

After mounting:

sudo touch /data/managed-disk-test.txt

Then:

ls -lh /data

The file now belongs to the mounted filesystem.

Conceptually:

/dev/nvme0n2p1
       │
       └── /data
           └── managed-disk-test.txt
9. Unmounting

To safely remove the filesystem from the mount point:

sudo umount /data

Then verify:

findmnt /data

If no output is returned:

/data is no longer mounted
10. Why umount Failed During Practice

The command:

sudo umount /data

returned:

umount: /data: not mounted.

This was not a disk failure.

It simply meant that /data was not currently a mounted filesystem.

The correct troubleshooting command is:

findmnt /data
11. Command Cheat Sheet
# List disks and filesystems
lsblk -f

# Identify filesystem UUID
sudo blkid /dev/nvme0n2p1

# Inspect ext4 filesystem
sudo tune2fs -l /dev/nvme0n2p1

# Check whether /data is mounted
findmnt /data

# Check filesystem capacity
df -h /data

# Mount filesystem
sudo mount /dev/nvme0n2p1 /data

# Unmount filesystem
sudo umount /data
12. Interview-Level Understanding
Q: Does seeing a disk in lsblk mean it is mounted?

No.

A disk can be:

Detected
   ↓
Partitioned
   ↓
Formatted
   ↓
Not mounted
Q: How do you verify whether a mount is active?

Use:

findmnt /data

or:

mount | grep /data
Q: Why can I create a file in /data even when the disk isn't mounted?

Because /data can simply be an ordinary directory inside the root filesystem.

Q: How do you verify which filesystem is actually being used?

Use:

df -h /data
Q: What is the difference between lsblk and df?

lsblk shows the block-device/storage topology.

Disk
 └── Partition
      └── Filesystem

df shows filesystem capacity and usage.

Filesystem
 ├── Size
 ├── Used
 ├── Available
 └── Mount Point
🧠 Day 04 Summary

The most important concept learned today was:

Disk ≠ Partition ≠ Filesystem ≠ Mount Point

More precisely:

Azure Managed Disk
        ↓
Block Device
        ↓
Partition
        ↓
Filesystem
        ↓
Mount Point
        ↓
Application Data

Understanding this flow is fundamental for Linux administration, Azure infrastructure engineering, DevOps, Kubernetes storage and production troubleshooting.

✅ Day 04 Status

Disk identification

Partition identification

Filesystem identification

UUID verification

ext4 metadata inspection

Mount-point verification

df verification

Test-file creation

Unmount troubleshooting

Storage architecture understanding

Day 04 completed.