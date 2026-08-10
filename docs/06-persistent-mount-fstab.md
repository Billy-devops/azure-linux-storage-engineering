# Persistent Linux Mounts with `/etc/fstab`

## 📖 Overview

Linux filesystems mounted manually with:

```bash
sudo mount /dev/device /mount-point
```

are not necessarily persistent across system reboots.

For persistent storage, Linux uses the `/etc/fstab` configuration file.

This document explains how to configure an Azure Linux VM data disk for automatic mounting using a filesystem UUID.

---

# 1. Why Persistent Mounting?

Consider:

```bash
sudo mount /dev/nvme0n3p1 /data
```

This works immediately, but after a reboot the filesystem may not automatically be mounted unless it is configured persistently.

For application and infrastructure workloads, storage often needs to be available automatically:

```text
VM Boot
   ↓
Linux Initialization
   ↓
Persistent Storage Mount
   ↓
Application Startup
```

This is the primary purpose of `/etc/fstab`.

---

# 2. `/etc/fstab`

`/etc/fstab` stands for **File System Table**.

It contains filesystem mount definitions that Linux can use during system startup.

A typical entry looks like:

```text
UUID=<filesystem-uuid> /data ext4 defaults,nofail 0 2
```

---

# 3. `/etc/fstab` Format

The standard format contains six fields:

```text
<filesystem> <mount-point> <type> <options> <dump> <pass>
```

Example:

```text
UUID=b80c92b7-0c0a-46d9-ab90-4d1dc13d0152 /data-day06 ext4 defaults,nofail 0 2
```

| Field       | Value             | Purpose                |
| ----------- | ----------------- | ---------------------- |
| Filesystem  | `UUID=...`        | Identifies filesystem  |
| Mount point | `/data-day06`     | Destination directory  |
| Type        | `ext4`            | Filesystem type        |
| Options     | `defaults,nofail` | Mount behavior         |
| Dump        | `0`               | Legacy dump setting    |
| Pass        | `2`               | Filesystem check order |

---

# 4. Why Use UUID Instead of Device Names?

A common mistake is configuring:

```text
/dev/nvme0n3p1 /data-day06 ext4 defaults 0 2
```

Device names can change when Linux discovers storage devices in a different order.

During the Day 6 lab:

```text
Before reboot:
/dev/nvme0n3p1
```

After reboot:

```text
/dev/nvme1n3p1
```

However, the filesystem UUID remained:

```text
b80c92b7-0c0a-46d9-ab90-4d1dc13d0152
```

Therefore, UUID-based configuration continued to work.

### Preferred approach

```text
UUID
 ↓
Filesystem
 ↓
Mount Point
```

rather than:

```text
Device Name
 ↓
Filesystem
 ↓
Mount Point
```

---

# 5. Discover Filesystem UUID

Use:

```bash
sudo blkid /dev/nvme0n3p1
```

Example:

```text
/dev/nvme0n3p1:
UUID="b80c92b7-0c0a-46d9-ab90-4d1dc13d0152"
TYPE="ext4"
```

Alternatively:

```bash
lsblk -f
```

---

# 6. Mount Point

Create the directory:

```bash
sudo mkdir -p /data-day06
```

The mount point is simply the location where the filesystem becomes accessible.

Example:

```text
/data-day06
├── application-data
├── logs
└── backups
```

---

# 7. Backup `/etc/fstab`

Before modifying the configuration:

```bash
sudo cp /etc/fstab /etc/fstab.backup-day06
```

This provides a rollback copy if an incorrect configuration is introduced.

---

# 8. Configure Persistent Mount

Edit:

```bash
sudo nano /etc/fstab
```

Add:

```text
UUID=b80c92b7-0c0a-46d9-ab90-4d1dc13d0152 /data-day06 ext4 defaults,nofail 0 2
```

Do not execute this line as a shell command.

It is configuration data that belongs inside `/etc/fstab`.

---

# 9. Understanding `defaults`

The `defaults` option enables a standard set of mount behaviors.

Conceptually:

```text
defaults
   ↓
standard mount behavior
```

Additional options can be appended using commas:

```text
defaults,nofail
```

---

# 10. Understanding `nofail`

`nofail` is useful for optional data disks.

Without `nofail`, a missing storage device can create boot-time problems depending on the system configuration.

With:

```text
nofail
```

Linux can continue booting if the optional filesystem cannot be mounted.

However:

> `nofail` does not mean the application will work without the disk.

Production environments should still use:

* Monitoring
* Disk health checks
* Application health checks
* Alerting
* Appropriate recovery procedures

---

# 11. Validate `/etc/fstab`

After editing:

```bash
sudo findmnt --verify
```

Also test:

```bash
sudo mount -a
```

`mount -a` attempts to mount filesystems defined in `/etc/fstab`.

This makes it an important pre-reboot validation step.

---

# 12. Verify the Mount

Use:

```bash
findmnt /data-day06
```

Expected:

```text
TARGET       SOURCE          FSTYPE
/data-day06  /dev/nvme0n3p1  ext4
```

Also:

```bash
df -h /data-day06
```

This confirms filesystem capacity and usage.

---

# 13. Reboot Persistence Test

After successful validation:

```bash
sudo reboot
```

Reconnect to the VM and run:

```bash
findmnt /data-day06
```

Then:

```bash
df -h /data-day06
```

Finally verify application/test data:

```bash
cat /data-day06/day06-test.txt
```

If the filesystem is mounted and the file is available, persistent mounting has been successfully validated.

---

# 14. Real Lab Observation

The Day 6 lab produced an important real-world observation.

### Before reboot

```text
/dev/nvme0n3p1
```

### After reboot

```text
/dev/nvme1n3p1
```

The device path changed.

But:

```text
UUID=b80c92b7-0c0a-46d9-ab90-4d1dc13d0152
```

remained the filesystem identity.

Therefore `/etc/fstab` successfully mounted the filesystem after reboot.

This is a practical demonstration of why infrastructure engineers should avoid depending on unstable device naming when persistent storage configuration is required.

---

# 15. Useful Commands

## List block devices

```bash
lsblk
```

## Show filesystem information

```bash
lsblk -f
```

## Show UUID

```bash
sudo blkid
```

## Show a specific filesystem

```bash
sudo blkid /dev/nvme0n3p1
```

## Show mounted filesystem

```bash
findmnt /data-day06
```

## Show filesystem usage

```bash
df -h /data-day06
```

## Validate fstab

```bash
sudo findmnt --verify
```

## Mount all fstab entries

```bash
sudo mount -a
```

## Backup fstab

```bash
sudo cp /etc/fstab /etc/fstab.backup
```

---

# 16. Troubleshooting

### Problem: Mount point is not available

Check:

```bash
ls -ld /data-day06
```

Create it:

```bash
sudo mkdir -p /data-day06
```

---

### Problem: Filesystem is not mounted

Check:

```bash
findmnt /data-day06
```

Then:

```bash
sudo mount -a
```

Check errors carefully.

---

### Problem: UUID is incorrect

Check:

```bash
lsblk -f
```

and:

```bash
sudo blkid
```

Compare the UUID with `/etc/fstab`.

---

### Problem: Device name changed

Do not immediately modify `/etc/fstab`.

Check:

```bash
lsblk -f
```

If the UUID is unchanged, UUID-based mounting should continue to work.

---

### Problem: fstab syntax error

Run:

```bash
sudo findmnt --verify
```

Then inspect:

```bash
cat /etc/fstab
```

---

# 17. Production Engineering Perspective

Persistent mounting is a small but important part of Linux infrastructure management.

A typical application storage architecture can look like:

```text
Azure Managed Disk
       ↓
Linux Block Device
       ↓
Partition
       ↓
Filesystem
       ↓
UUID
       ↓
/etc/fstab
       ↓
Mount Point
       ↓
Application
```

For example:

```text
/data-day06
├── app-data
├── logs
├── uploads
└── backups
```

This allows the application to depend on a predictable filesystem path instead of a changing block-device name.

---

# 18. Operational Best Practices

### Use UUID for persistent mounts

```text
UUID=...
```

instead of hard-coding device paths where appropriate.

### Validate before reboot

Always follow:

```text
Edit fstab
    ↓
findmnt --verify
    ↓
mount -a
    ↓
findmnt
    ↓
df -h
    ↓
Reboot
```

### Keep a backup

```bash
sudo cp /etc/fstab /etc/fstab.backup
```

### Use `nofail` carefully

Useful for optional disks, but don't treat it as a replacement for monitoring.

### Verify after reboot

```bash
findmnt /data-day06
```

---

# 19. Day 6 Lab Result

The persistent mount configuration was successfully implemented.

```text
Azure Managed Disk
       ↓
8 GiB Disk
       ↓
Partition
       ↓
ext4
       ↓
UUID
       ↓
/etc/fstab
       ↓
/data-day06
       ↓
VM Reboot
       ↓
Automatic Mount
       ↓
Data Available ✅
```

Final validation:

```bash
sudo findmnt --verify
```

Result:

```text
Success, no errors or warnings detected
```

## ✅ Day 6 Status

**COMPLETED**

The lab successfully demonstrated persistent Linux storage using `/etc/fstab` and UUID-based filesystem identification.
