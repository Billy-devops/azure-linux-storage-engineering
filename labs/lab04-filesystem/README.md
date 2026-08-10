# Lab 03 — Linux Disk, Partition & Filesystem Verification

## 🎯 Objective

In this lab, we will learn how to identify an Azure Linux VM's attached disk, inspect its partition and filesystem, verify its UUID and filesystem properties, mount the filesystem, validate storage usage, create test data, and safely unmount it.

### Skills Covered

* Identify Linux disks and partitions
* Understand `/dev/nvme*` devices
* Inspect filesystems using `lsblk`
* Identify filesystem UUID using `blkid`
* Inspect ext4 filesystem metadata using `tune2fs`
* Understand mount points
* Verify mounts using `findmnt`
* Verify filesystem capacity using `df`
* Mount and unmount a filesystem
* Understand the difference between a directory and a mounted filesystem

---

# 1. Storage Architecture

The storage flow used in this lab is:

```text
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
```

The important distinction is:

```text
/data directory
       ≠
/dev/nvme0n2p1 filesystem
```

The `/data` directory only becomes the access point for the managed disk **after the filesystem is mounted there**.

---

# 2. Identify Block Devices

Run:

```bash
lsblk -f
```

Example output:

```text
NAME         FSTYPE FSVER LABEL           UUID                                 MOUNTPOINTS
nvme0n1
├─nvme0n1p1  ext4   1.0   cloudimg-rootfs 1f78b266-0950-45fc-ab40-9032b0b55eac /
├─nvme0n1p14
├─nvme0n1p15 vfat   FAT32 UEFI            D1E2-AA31                            /boot/efi
└─nvme0n1p16 ext4   1.0   BOOT            862d4f3f-32b2-48e0-bb20-1822d0554c93 /boot

nvme0n2
└─nvme0n2p1  ext4                    a593a5bb-dbce-4feb-8826-d1c77ce4543d
```

### Interpretation

The important disk is:

```text
/dev/nvme0n2
```

Its partition is:

```text
/dev/nvme0n2p1
```

The partition contains an:

```text
ext4
```

filesystem.

At this point, there is **no current mount point shown** for `/dev/nvme0n2p1`.

---

# 3. Identify Filesystem UUID

Run:

```bash
sudo blkid /dev/nvme0n2p1
```

Example:

```text
/dev/nvme0n2p1: UUID="a593a5bb-dbce-4feb-8826-d1c77ce4543d" BLOCK_SIZE="4096" TYPE="ext4"
```

Important information:

```text
Device:     /dev/nvme0n2p1
Filesystem: ext4
UUID:       a593a5bb-dbce-4feb-8826-d1c77ce4543d
```

### Why UUID matters

UUID provides a persistent filesystem identifier.

Instead of depending only on:

```text
/dev/nvme0n2p1
```

Linux can identify the filesystem using:

```text
UUID=a593a5bb-dbce-4feb-8826-d1c77ce4543d
```

This becomes especially important when configuring `/etc/fstab`.

---

# 4. Inspect ext4 Filesystem Metadata

Run:

```bash
sudo tune2fs -l /dev/nvme0n2p1
```

Important fields include:

```text
Filesystem UUID: a593a5bb-dbce-4feb-8826-d1c77ce4543d
Filesystem state: clean
Block size: 4096
Filesystem created: Mon Aug 10 02:16:40 2026
Last mount time: Mon Aug 10 02:17:35 2026
Last mounted on: /data
```

### Important distinction

The line:

```text
Last mounted on: /data
```

does **not** mean the filesystem is currently mounted.

It only tells us that `/data` was the previous mount location.

To check the current state, use:

```bash
findmnt /data
```

---

# 5. Verify Current Mount Status

Run:

```bash
findmnt /data
```

If there is no output, `/data` is currently not a mount point.

Verify with:

```bash
df -h /data
```

Example:

```text
Filesystem      Size  Used Avail Use% Mounted on
/dev/root        29G  1.6G   27G   6% /
```

### Important Learning

This output proves that `/data` is currently just a directory inside the root filesystem.

It is **not** using:

```text
/dev/nvme0n2p1
```

---

# 6. Directory vs Mounted Filesystem

Before mounting the disk, creating a file under `/data`:

```bash
sudo touch /data/day04-test.txt
```

does not mean the file is stored on the managed disk.

Because `/data` is not mounted yet, the file is stored on:

```text
/dev/root
```

Conceptually:

```text
/dev/root
   │
   └── /data
       └── day04-test.txt
```

This is a critical Linux storage concept.

---

# 7. Mount the Filesystem

Create the mount point if required:

```bash
sudo mkdir -p /data
```

Mount the partition:

```bash
sudo mount /dev/nvme0n2p1 /data
```

Verify:

```bash
findmnt /data
```

Expected result:

```text
/data    /dev/nvme0n2p1    ext4    rw,...
```

Now the relationship is:

```text
/dev/nvme0n2p1
       │
       ▼
      /data
```

---

# 8. Verify Disk Capacity

Run:

```bash
df -h /data
```

Now the filesystem shown should correspond to:

```text
/dev/nvme0n2p1
```

instead of:

```text
/dev/root
```

This confirms that `/data` is now backed by the attached disk.

---

# 9. Create Test Data

Create a test file:

```bash
sudo touch /data/managed-disk-test.txt
```

Verify:

```bash
ls -lh /data
```

Now the file is being created inside the mounted filesystem.

Conceptually:

```text
/dev/nvme0n2p1
      │
      └── /data
          └── managed-disk-test.txt
```

---

# 10. Verify Using lsblk

Run:

```bash
lsblk -f
```

You should now see the mount point associated with:

```text
nvme0n2p1
```

Example:

```text
nvme0n2
└─nvme0n2p1  ext4  a593a5bb-dbce-4feb-8826-d1c77ce4543d  /data
```

---

# 11. Unmount the Filesystem

Unmount:

```bash
sudo umount /data
```

Verify:

```bash
findmnt /data
```

No output means:

```text
/data
  ↓
Not mounted
```

Verify again:

```bash
lsblk -f
```

The `/data` mount point should no longer appear for `/dev/nvme0n2p1`.

---

# 12. Understand the `umount` Error

During the lab, the following command was executed:

```bash
sudo umount /data
```

The system returned:

```text
umount: /data: not mounted.
```

This happened because `/data` was already **not mounted**.

The correct troubleshooting sequence is:

```bash
findmnt /data
```

If nothing is returned, the mount does not currently exist.

---

# 13. Common Commands

| Command      | Purpose                         |
| ------------ | ------------------------------- |
| `lsblk`      | List block devices              |
| `lsblk -f`   | Show filesystem information     |
| `blkid`      | Show filesystem UUID and type   |
| `tune2fs -l` | Inspect ext filesystem metadata |
| `findmnt`    | Show active mount points        |
| `df -h`      | Show filesystem capacity        |
| `mount`      | Mount a filesystem              |
| `umount`     | Unmount a filesystem            |
| `ls -lh`     | List files with readable sizes  |

---

# 14. Troubleshooting Checklist

### Disk exists but not mounted

```bash
lsblk -f
```

Check whether the partition has a mount point.

Then:

```bash
findmnt /data
```

If no output:

```bash
sudo mount /dev/nvme0n2p1 /data
```

---

### `umount: /data: not mounted`

Check:

```bash
findmnt /data
```

If empty, there is nothing to unmount.

---

### `df -h /data` shows `/dev/root`

This means `/data` is currently just a directory on the root filesystem.

Check:

```bash
findmnt /data
```

Then mount the intended filesystem.

---

# 15. Lab Verification

Final verification commands:

```bash
lsblk -f
```

```bash
findmnt /data
```

```bash
df -h /data
```

```bash
sudo blkid /dev/nvme0n2p1
```

```bash
sudo tune2fs -l /dev/nvme0n2p1
```

---

# 🧠 Key Takeaways

1. A disk being visible in `lsblk` does not mean it is mounted.
2. A partition can contain a filesystem without being mounted.
3. `blkid` identifies filesystem UUID and type.
4. `tune2fs` provides detailed ext4 filesystem metadata.
5. `findmnt` is useful for checking the current mount state.
6. `df -h` shows which filesystem is actually providing storage.
7. `/data` can exist as an ordinary directory even when no disk is mounted there.
8. Files created before mounting can belong to the root filesystem.
9. After mounting, the same `/data` path points to the mounted filesystem.
10. `umount` only works when the filesystem is actually mounted.
