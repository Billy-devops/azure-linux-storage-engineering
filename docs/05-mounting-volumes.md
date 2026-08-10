05 — Mounting Volumes in Linux
📘 Overview

Linux storage becomes useful to applications only after a filesystem is made accessible through a mount point.

The fundamental relationship is:

Block Device
     ↓
Partition
     ↓
Filesystem
     ↓
Mount Point
     ↓
Application Data

For this lab:

/dev/nvme0n2
      ↓
/dev/nvme0n2p1
      ↓
ext4
      ↓
/data
1. What Is Mounting?

Mounting is the process of attaching a filesystem to a directory in the Linux filesystem hierarchy.

Example:

sudo mount /dev/nvme0n2p1 /data

Here:

Source:
    /dev/nvme0n2p1

Target:
    /data

After mounting, users and applications access the filesystem through:

/data
2. Mount Point

A mount point is a directory where a filesystem becomes accessible.

Example:

sudo mkdir -p /data

Before mounting:

/
└── data/

/data is simply a directory.

After mounting:

/
└── data/
    └── mounted filesystem

The directory now provides access to the mounted filesystem.

3. Identify the Filesystem

Use:

lsblk -f

The Day 5 environment contained:

nvme0n2
└─nvme0n2p1  ext4

Therefore:

Device      : /dev/nvme0n2p1
Filesystem  : ext4
UUID        : a593a5bb-dbce-4feb-8826-d1c77ce4543d
4. Verify Whether a Mount Exists

Use:

findmnt /data

If no output is returned:

/data is not currently mounted

This is one of the simplest ways to verify a specific mount point.

5. Mount the Filesystem

Use:

sudo mount /dev/nvme0n2p1 /data

Then verify:

findmnt /data

Expected relationship:

/data → /dev/nvme0n2p1 → ext4
6. Verify Capacity

Use:

df -h /data

During the practical:

/dev/nvme0n2p1  3.9G  28K  3.7G  1% /data

This confirmed that /data was backed by the dedicated filesystem.

7. Why findmnt and df Are Important

Both commands answer different questions.

findmnt

Answers:

Which filesystem is mounted at this location?

Example:

/data → /dev/nvme0n2p1
df -h

Answers:

How much storage does the mounted filesystem have and how much is being used?

Example:

Size    Used    Avail
3.9G    32K     3.7G

Together they provide strong mount verification.

8. Writing Data to a Mounted Volume

After mounting:

sudo touch /data/day05-test.txt

Then:

echo "Day 05 Linux Storage Mount Test" | sudo tee /data/day05-test.txt

Verify:

cat /data/day05-test.txt

The data is now written through the /data mount point to the filesystem on:

/dev/nvme0n2p1
9. Duplicate Mount Behavior

During the practical, the filesystem was intentionally mounted again:

sudo mount /dev/nvme0n2p1 /data

Linux returned:

mount: /data: /dev/nvme0n2p1 already mounted on /data.

This is expected behavior.

The filesystem was already associated with:

/data

Therefore, the correct action is to verify the existing mount:

findmnt /data
10. Unmounting

Unmount a filesystem using:

sudo umount /data

Important:

umount is spelled without the n.

Correct:

umount

Incorrect:

unmount
11. Verify After Unmount

Run:

findmnt /data

If there is no output, /data is no longer a mount point.

Then:

lsblk -f

The filesystem should no longer show /data as its mount point.

12. Current Working Directory Matters

Before unmounting, check:

pwd

If the shell is currently inside the filesystem:

/data

move outside:

cd ~

Then:

sudo umount /data

This avoids common "target is busy" situations caused by a shell or process using the mount point.

13. Linux Mount Lifecycle

The complete lifecycle is:

                    ┌──────────────┐
                    │ Block Device │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │  Filesystem  │
                    └──────┬───────┘
                           │
                        mount
                           │
                           ▼
                    ┌──────────────┐
                    │  /data       │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │ Application  │
                    │     Data     │
                    └──────┬───────┘
                           │
                        umount
                           │
                           ▼
                    Filesystem
                    disconnected
                    from /data
14. Useful Commands
Discover
lsblk -f
Identify filesystem
sudo blkid /dev/nvme0n2p1
Create mount point
sudo mkdir -p /data
Mount
sudo mount /dev/nvme0n2p1 /data
Verify mount
findmnt /data
Verify capacity
df -h /data
Check mounted files
ls -lh /data
Unmount
sudo umount /data
Verify unmount
findmnt /data
15. Troubleshooting
Problem: Device already mounted

Error:

/dev/nvme0n2p1 already mounted on /data

Solution:

findmnt /data

Do not mount it again if the expected relationship already exists.

Problem: /data is not mounted

Check:

findmnt /data

Then:

lsblk -f

If the filesystem exists but has no mount point:

sudo mount /dev/nvme0n2p1 /data
Problem: umount: /data: not mounted

Check:

findmnt /data

No output means the filesystem is already unmounted.

Problem: Target is busy

Check which processes are using the mount:

sudo lsof +D /data

or:

sudo fuser -vm /data

Also check your shell:

pwd

If necessary:

cd ~

Then retry:

sudo umount /data
16. Production Considerations

Manual mounting is useful for testing and labs, but production systems usually require persistent mounting.

For persistent mounts, Linux commonly uses:

/etc/fstab

Example concept:

UUID=<filesystem-uuid>   /data   ext4   defaults,nofail   0 2

This topic is covered separately in:

docs/06-persistent-mount-fstab.md

Do not add the /etc/fstab configuration during this lab unless specifically required.

17. Operational Verification Pattern

For production troubleshooting, remember this sequence:

lsblk -f

↓

findmnt /data

↓

df -h /data

↓

ls -lh /data

This gives:

Device information
       ↓
Mount relationship
       ↓
Capacity/usage
       ↓
Actual filesystem contents
🧠 Key Concepts
Block Device

Represents the storage device exposed to Linux.

Example:

/dev/nvme0n2
Partition

A logical section of a disk.

Example:

/dev/nvme0n2p1
Filesystem

The structure used to store files.

Example:

ext4
Mount Point

Directory through which the filesystem is accessed.

Example:

/data
Mount

Connects:

/dev/nvme0n2p1
        ↓
      /data
Unmount

Disconnects the filesystem from the mount point.

🔥 Day 05 Learning Summary

The practical demonstrated the complete Linux volume mounting lifecycle:

Identify
   ↓
Create Mount Point
   ↓
Mount
   ↓
Verify
   ↓
Write Data
   ↓
Validate
   ↓
Unmount
   ↓
Verify Again

The most important operational lesson is:

Never assume a disk is mounted just because Linux detects the disk. Always verify the actual mount relationship.

Recommended verification commands:

lsblk -f
findmnt /data
df -h /data
✅ Status

Day 05 — Mounting Volumes: COMPLETED