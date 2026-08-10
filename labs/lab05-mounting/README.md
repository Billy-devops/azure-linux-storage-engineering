Lab 05 — Linux Filesystem Mounting & Unmounting
🎯 Objective

In this lab, we will practice mounting an existing Linux filesystem to a mount point, verify the mount, write data to the mounted filesystem, understand duplicate mount behavior, and safely unmount the filesystem.

Skills Covered
Identify available disks and filesystems
Create a mount point
Mount an ext4 filesystem
Verify mount status using findmnt
Verify filesystem capacity using df
Write data to a mounted filesystem
Understand duplicate mount errors
Safely unmount a filesystem
Verify the filesystem after unmounting
1. Storage Architecture

The storage flow used in this lab:

Azure Managed Disk
       │
       ▼
Linux Block Device
/dev/nvme0n2
       │
       ▼
Partition
/dev/nvme0n2p1
       │
       ▼
ext4 Filesystem
       │
       │ mount
       ▼
     /data
       │
       ▼
Application Data
2. Identify Available Filesystems

Run:

lsblk -f

The important device identified during the lab was:

nvme0n2
└─nvme0n2p1  ext4  a593a5bb-dbce-4feb-8826-d1c77ce4543d

Therefore:

Device:
    /dev/nvme0n2

Partition:
    /dev/nvme0n2p1

Filesystem:
    ext4

UUID:
    a593a5bb-dbce-4feb-8826-d1c77ce4543d

The filesystem did not have an active mount point at the beginning of the lab.

3. Check Existing Mounts

Run:

findmnt

The root filesystem was mounted as:

/dev/nvme0n1p1 → /

The data partition:

/dev/nvme0n2p1

was not mounted.

Verify specifically:

findmnt /data

No output means:

/data
  ↓
Not currently mounted
4. Check Filesystem Usage

Run:

df -h

The root filesystem was:

/dev/root  29G  1.7G  27G  6% /

The data filesystem was not present in df because it was not mounted.

This demonstrates that a filesystem does not appear in df merely because the block device exists.

5. Create the Mount Point

Create the mount point:

sudo mkdir -p /data

Verify:

ls -ld /data

Example:

drwxr-xr-x 2 root root 4096 Aug 10 03:26 /data

At this stage:

/data

is only a normal directory.

Verify:

findmnt /data

No output is expected.

6. Mount the Filesystem

Mount the existing ext4 filesystem:

sudo mount /dev/nvme0n2p1 /data

No error indicates that the mount was successful.

7. Verify the Mount

Use findmnt:

findmnt /data

Observed result:

TARGET
      SOURCE         FSTYPE OPTIONS
/data /dev/nvme0n2p1 ext4   rw,relatime,stripe=8192

This confirms:

/dev/nvme0n2p1
       │
       ▼
     /data
8. Verify Filesystem Capacity

Run:

df -h /data

Observed result:

Filesystem      Size  Used Avail Use% Mounted on
/dev/nvme0n2p1  3.9G   28K  3.7G   1% /data

This is an important validation.

Before mounting:

/data → /dev/root

was effectively just a directory.

After mounting:

/data → /dev/nvme0n2p1

is backed by the dedicated data filesystem.

9. Write Data to the Mounted Filesystem

Create a test file:

sudo touch /data/day05-test.txt

Write content:

echo "Day 05 Linux Storage Mount Test" | sudo tee /data/day05-test.txt

Output:

Day 05 Linux Storage Mount Test

Verify:

cat /data/day05-test.txt

Expected:

Day 05 Linux Storage Mount Test
10. Verify Storage Usage After Writing

Run:

df -h /data

Observed:

Filesystem      Size  Used Avail Use% Mounted on
/dev/nvme0n2p1  3.9G   32K  3.7G   1% /data

The filesystem is still correctly mounted.

11. Duplicate Mount Attempt

During the lab, the filesystem was intentionally mounted again:

sudo mount /dev/nvme0n2p1 /data

Linux returned:

mount: /data: /dev/nvme0n2p1 already mounted on /data.
Why did this happen?

Because the filesystem was already mounted:

/dev/nvme0n2p1
       ↓
      /data

Linux prevents the same filesystem from being mounted again at the same mount point in this normal workflow.

Correct troubleshooting

Check:

findmnt /data

If the output shows:

/data /dev/nvme0n2p1 ext4

the filesystem is already mounted.

12. Check Current Directory Before Unmounting

Before unmounting, check:

pwd

Observed:

/home/azurerm

This is good because the shell was not inside /data.

If the shell is inside the mount point:

cd ~

Then unmount.

13. Unmount the Filesystem

Run:

sudo umount /data

No error means the filesystem was successfully unmounted.

14. Verify Unmount

Run:

findmnt /data

No output means:

/data
  ↓
Not mounted

Then:

lsblk -f

The /dev/nvme0n2p1 filesystem should no longer show /data as its mount point.

15. Complete Mount Lifecycle

The complete workflow practiced in this lab:

1. Identify
      ↓
   lsblk -f
      ↓
2. Create mount point
      ↓
   mkdir -p /data
      ↓
3. Mount
      ↓
   mount /dev/nvme0n2p1 /data
      ↓
4. Verify
      ↓
   findmnt /data
      ↓
5. Check capacity
      ↓
   df -h /data
      ↓
6. Write data
      ↓
   /data/day05-test.txt
      ↓
7. Unmount
      ↓
   umount /data
      ↓
8. Verify again
      ↓
   findmnt /data
16. Important Commands
Command	Purpose
lsblk -f	List disks, partitions and filesystems
findmnt	Display active mount relationships
findmnt /data	Check whether /data is mounted
df -h	Display filesystem usage
mkdir -p /data	Create mount point
mount DEVICE /data	Mount filesystem
umount /data	Unmount filesystem
ls -lh /data	List files in mounted filesystem
cat /data/file	Read test data
17. Troubleshooting
Error: Already mounted
mount: /data: /dev/nvme0n2p1 already mounted on /data.

Check:

findmnt /data

If mounted, do not run the mount command again.

Error: Not mounted during unmount
umount: /data: not mounted.

Check:

findmnt /data

If no output appears, there is nothing to unmount.

df -h /data shows /dev/root

This means the filesystem is probably not mounted on /data.

Check:

findmnt /data

Then mount the intended filesystem.

18. Lab Verification Checklist

Identified /dev/nvme0n2

Identified /dev/nvme0n2p1

Confirmed ext4 filesystem

Created /data

Verified /data was initially unmounted

Mounted /dev/nvme0n2p1

Verified mount with findmnt

Verified capacity with df -h

Created test file

Wrote data to mounted filesystem

Tested duplicate mount behavior

Successfully unmounted filesystem

Verified final unmounted state

🧠 Key Takeaways
1. Device ≠ Mount Point
/dev/nvme0n2p1

is a block-device partition.

/data

is a directory/mount point.

They become connected through:

mount /dev/nvme0n2p1 /data
2. Always Verify

After mounting:

findmnt /data
df -h /data

After unmounting:

findmnt /data
lsblk -f
3. A Directory Can Exist Without a Mounted Disk

/data can exist even when no filesystem is mounted there.

4. Mounting Changes What /data Represents

Before:

/dev/root
   └── /data

After:

/dev/nvme0n2p1
   └── /data

This distinction is fundamental to Linux storage administration.

✅ Lab Status

Day 05 — Linux Filesystem Mounting & Unmounting: COMPLETED