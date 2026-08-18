# Day 12 — Linux Storage Monitoring

## Overview

Day 12 focused on monitoring and validating Linux storage from an operational and production perspective.

The goal was to move beyond basic storage configuration and understand how to continuously verify:

* Filesystem capacity
* Inode utilization
* Mount points
* Block devices
* LVM health
* Directory-level storage consumption
* Disk I/O
* Storage-related system logs
* MySQL storage health
* Service availability
* Monitoring architecture

This day builds on the previous storage work involving:

* Azure Managed Disks
* Linux partitioning
* Filesystems
* Mounting
* `/etc/fstab`
* LVM
* Live volume expansion
* MySQL storage
* MySQL backup and restore

---

## Learning Objectives

By completing Day 12, the following skills were practiced:

1. Monitoring filesystem capacity.
2. Monitoring inode usage.
3. Verifying mounted filesystems.
4. Inspecting block devices.
5. Monitoring LVM PV, VG and LV state.
6. Identifying storage-heavy directories.
7. Finding unusually large files.
8. Monitoring disk I/O.
9. Inspecting kernel and system logs.
10. Verifying MySQL service health.
11. Understanding storage monitoring in production environments.
12. Understanding the role of Prometheus and Grafana.

---

# 1. Filesystem Capacity Monitoring

The primary command used was:

```bash
df -hT
```

The command displays:

* Filesystem
* Filesystem type
* Total capacity
* Used capacity
* Available capacity
* Percentage utilization
* Mount point

For individual filesystems:

```bash
df -hT /
```

For MySQL storage:

```bash
df -hT /data/mysql
```

### Production Importance

Filesystem usage should be monitored continuously because a full filesystem can cause:

* Application failures
* Database failures
* Log write failures
* Backup failures
* Service instability
* `No space left on device` errors

A common operational practice is to configure warning and critical thresholds.

---

# 2. Inode Monitoring

Filesystem capacity alone is not enough.

Inode utilization was checked using:

```bash
df -ih
```

Inodes represent the filesystem's ability to track files and directories.

A filesystem can have free disk space but still fail to create files when inode utilization reaches 100%.

Therefore production monitoring should track both:

```text
Disk Capacity
+
Inode Capacity
```

---

# 3. Mount Verification

Mounted filesystems were inspected using:

```bash
findmnt
```

Specific mounts can be checked with:

```bash
findmnt /data/mysql
```

This verifies:

* Mount target
* Source device
* Filesystem type
* Mount options

Mount verification is especially important for database storage because a failed mount can cause an application to access the wrong underlying directory.

---

# 4. Block Device Monitoring

Block devices were inspected with:

```bash
lsblk
```

Detailed filesystem information:

```bash
lsblk -f
```

A typical storage hierarchy is:

```text
Azure Managed Disk
        |
        v
Linux Block Device
        |
        v
Partition
        |
        v
LVM Physical Volume
        |
        v
Volume Group
        |
        v
Logical Volume
        |
        v
Filesystem
        |
        v
Mount Point
```

Understanding this hierarchy is essential for troubleshooting storage problems.

---

# 5. LVM Monitoring

LVM state was verified using:

```bash
sudo pvs
```

```bash
sudo vgs
```

```bash
sudo lvs
```

These commands provide visibility into:

### Physical Volumes

```bash
sudo pvs
```

Shows:

* PV name
* Volume Group
* PV size
* Allocation state

### Volume Groups

```bash
sudo vgs
```

Important value:

```text
VFree
```

`VFree` represents the capacity currently available inside the Volume Group for future logical volume expansion.

### Logical Volumes

```bash
sudo lvs
```

Shows:

* LV name
* VG
* LV size
* LV attributes

---

# 6. Directory-Level Storage Monitoring

Filesystem-level monitoring answers:

> Which filesystem is consuming storage?

Directory-level monitoring answers:

> Where inside that filesystem is the storage being consumed?

The following command was used:

```bash
sudo du -xhd1 /data 2>/dev/null | sort -h
```

For MySQL:

```bash
sudo du -xhd1 /data/mysql 2>/dev/null | sort -h
```

The `-x` option prevents `du` from crossing filesystem boundaries.

This makes the output more useful on systems containing multiple mounts.

---

# 7. Large File Detection

Large files can be located using:

```bash
sudo find /data -xdev -type f -size +500M -ls 2>/dev/null
```

The purpose is investigation, not automatic deletion.

Before removing a large file, an administrator should understand:

* What created it?
* Is it required?
* Is it a database file?
* Is it a backup?
* Is it a log?
* Is there a retention policy?
* Is it currently being used?

Production storage cleanup should always be evidence-based.

---

# 8. Disk I/O Monitoring

Capacity does not indicate disk performance.

Disk I/O was monitored using:

```bash
iostat -xz 2 5
```

Important metrics include:

| Metric  | Meaning            |
| ------- | ------------------ |
| `r/s`   | Reads per second   |
| `w/s`   | Writes per second  |
| `rkB/s` | Read throughput    |
| `wkB/s` | Write throughput   |
| `await` | Average I/O wait   |
| `%util` | Device utilization |

A disk may have plenty of free space while still experiencing high I/O latency.

Therefore:

```text
Storage Monitoring
=
Capacity Monitoring
+
Performance Monitoring
```

---

# 9. VM-Level I/O Context

The following command can provide additional system-level context:

```bash
vmstat 2 5
```

It helps correlate:

* CPU activity
* Memory activity
* Swap
* Processes
* I/O
* System activity

Storage troubleshooting should consider the complete system rather than a single metric.

---

# 10. Storage-Related Logs

Kernel messages were inspected using:

```bash
sudo dmesg -T | tail -50
```

Storage-related messages can be filtered using:

```bash
sudo dmesg -T | grep -Ei 'error|fail|disk|nvme|ext4|xfs|io'
```

The system journal can be checked with:

```bash
sudo journalctl -p warning..alert --no-pager
```

These checks can reveal:

* Disk errors
* Filesystem errors
* Mount failures
* I/O failures
* NVMe problems
* Kernel warnings

Logs should always be interpreted in context.

---

# 11. MySQL Storage Monitoring

MySQL was the primary storage-dependent application on the new VM.

The MySQL datadir was configured under:

```text
/data/mysql
```

The mount was verified with:

```bash
findmnt /data/mysql
```

Filesystem capacity:

```bash
df -hT /data/mysql
```

Inode usage:

```bash
df -ih /data/mysql
```

Directory usage:

```bash
sudo du -xhd1 /data/mysql 2>/dev/null | sort -h
```

---

# 12. MySQL Service Health Verification

The MySQL service was verified using:

```bash
sudo systemctl is-active mysql
```

Result:

```text
active
```

Detailed status showed:

```text
Active: active (running)
Status: "Server is operational"
```

The service was therefore confirmed as healthy and operational.

The important monitoring chain is:

```text
/data/mysql
      |
      v
Filesystem
      |
      v
Storage Capacity
      |
      v
MySQL
      |
      v
Application/Data Availability
```

---

# 13. Nginx Applicability on the New VM

This Day 12 lab was performed on a newly created VM.

Nginx was not installed on this VM.

Verification:

```bash
sudo systemctl is-active nginx
```

returned:

```text
inactive
```

Further verification:

```bash
sudo systemctl --no-pager status nginx
```

returned:

```text
Unit nginx.service could not be found.
```

Package verification:

```bash
dpkg -l | grep -i nginx
```

returned no result.

Command verification:

```bash
command -v nginx
```

returned no result.

The expected Nginx log directory was also not present:

```bash
sudo ls -ld /data/logs/nginx
```

returned:

```text
No such file or directory
```

### Conclusion

This was not treated as an Nginx failure.

The VM simply does not contain the Nginx setup from the earlier Day 9 lab.

Therefore:

```text
Nginx monitoring = Not Applicable on this VM
```

No unnecessary Nginx installation was performed.

---

# 14. Prometheus and Grafana Monitoring Concept

Long-term monitoring can be implemented using:

```text
Linux VM
   |
   v
Node Exporter
   |
   v
Prometheus
   |
   v
Grafana
```

### Node Exporter

Provides operating-system metrics such as:

* Filesystem usage
* Disk statistics
* CPU
* Memory
* Network

### Prometheus

Stores time-series metrics and allows querying.

### Grafana

Provides:

* Dashboards
* Visualization
* Historical trends
* Monitoring views

This architecture converts manual commands into continuous observability.

---

# 15. Production Monitoring Model

A production storage monitoring strategy should observe:

```text
Filesystem Capacity
        +
Inodes
        +
Mounts
        +
LVM
        +
Directory Growth
        +
Disk I/O
        +
System Logs
        +
Application Health
```

This provides a complete storage-health picture.

---

# 16. Troubleshooting Workflow

When an application reports:

```text
No space left on device
```

the correct approach is not immediate deletion.

Recommended workflow:

```bash
df -hT
```

Then:

```bash
df -ih
```

Then identify large directories:

```bash
sudo du -xhd1 /mountpoint 2>/dev/null | sort -h
```

Then identify large files:

```bash
sudo find /mountpoint -xdev -type f -size +500M -ls 2>/dev/null
```

Check deleted-but-open files:

```bash
sudo lsof +L1
```

Check logs:

```bash
sudo journalctl -p warning..alert --no-pager
```

Check LVM:

```bash
sudo vgs
sudo lvs
```

This makes storage troubleshooting systematic and evidence-driven.

---

# 17. Day 12 Key Lessons

### Lesson 1

`df` tells us filesystem capacity.

### Lesson 2

`df -i` tells us inode capacity.

### Lesson 3

`findmnt` confirms actual mounts.

### Lesson 4

`lsblk` shows the physical/storage hierarchy.

### Lesson 5

`pvs`, `vgs`, and `lvs` provide LVM visibility.

### Lesson 6

`du` identifies storage-heavy directories.

### Lesson 7

`find` helps identify large files.

### Lesson 8

`iostat` provides disk-performance information.

### Lesson 9

`dmesg` and `journalctl` help identify storage-related errors.

### Lesson 10

Application health must be monitored together with storage health.

---

# 18. Completion Criteria

Day 12 is considered complete when the engineer can:

* Monitor filesystem capacity
* Monitor inode utilization
* Verify mount points
* Inspect block devices
* Inspect LVM
* Analyze directory usage
* Find large files
* Monitor disk I/O
* Review storage-related logs
* Verify MySQL health
* Understand why Nginx is not applicable on the new VM
* Understand Prometheus/Grafana storage monitoring
* Troubleshoot storage incidents systematically

---

# 19. Next Day

## Day 13 — Shell Automation

Day 13 will automate the repetitive monitoring checks from Day 12.

The objective is to convert:

```text
Manual Storage Checks
```

into:

```text
Automated Storage Health Checks
```

with:

* Thresholds
* Exit codes
* Clear output
* Alerts
* Repeatable execution
  """

# Lab 12 — Linux Storage Monitoring

## Objective

The objective of this lab was to perform a complete storage-health assessment on the new Azure Linux VM.

The lab focused on the storage configuration actually present on the VM.

The VM contains the MySQL storage and backup/restore work completed during Day 10 and Day 11.

Nginx was not installed on this VM, so Nginx-specific monitoring was not treated as a required component of this lab.

---

# 1. Environment

```text
Platform: Azure
OS: Linux
VM: rg-linux-vm
Primary Application: MySQL
Database Storage: /data/mysql
Storage Technology: Linux filesystem + LVM
```

---

# 2. MySQL Health Verification

The MySQL service was checked using:

```bash
sudo systemctl is-active mysql
```

Result:

```text
active
```

Detailed verification:

```bash
sudo systemctl --no-pager status mysql | head -15
```

Important result:

```text
Active: active (running)
Status: "Server is operational"
```

This confirms that MySQL is currently operational.

---

# 3. Filesystem Monitoring

Run:

```bash
df -hT
```

Purpose:

* Check total capacity
* Check used space
* Check available space
* Check utilization percentage
* Identify mounted filesystems

For MySQL storage:

```bash
df -hT /data/mysql
```

---

# 4. Inode Monitoring

Run:

```bash
df -ih
```

For MySQL:

```bash
df -ih /data/mysql
```

The purpose is to ensure that the filesystem has sufficient inodes available for new files.

---

# 5. Mount Verification

Run:

```bash
findmnt
```

Verify MySQL storage specifically:

```bash
findmnt /data/mysql
```

This confirms that the expected filesystem is mounted at the MySQL data directory.

---

# 6. Block Device Verification

Run:

```bash
lsblk -f
```

This command helps identify:

* Disk
* Partition
* Filesystem
* LVM relationship
* Mount point

The storage hierarchy should be understood as:

```text
Disk
 ↓
Partition
 ↓
LVM PV
 ↓
VG
 ↓
LV
 ↓
Filesystem
 ↓
Mount
```

---

# 7. LVM Health

Physical volumes:

```bash
sudo pvs
```

Volume groups:

```bash
sudo vgs
```

Logical volumes:

```bash
sudo lvs
```

The important value in `vgs` output is:

```text
VFree
```

This determines whether additional logical-volume expansion can be performed without first adding more capacity to the Volume Group.

---

# 8. Directory Usage

Check `/data`:

```bash
sudo du -xhd1 /data 2>/dev/null | sort -h
```

Check MySQL:

```bash
sudo du -xhd1 /data/mysql 2>/dev/null | sort -h
```

The purpose is to identify where storage is being consumed.

---

# 9. Large File Investigation

Run:

```bash
sudo find /data -xdev -type f -size +500M -ls 2>/dev/null
```

Large files should be investigated before deletion.

Potential causes include:

* Database files
* Backups
* Logs
* Application data
* Temporary files

---

# 10. Disk I/O Monitoring

Check whether `iostat` is available:

```bash
command -v iostat
```

If available:

```bash
iostat -xz 2 5
```

Observe:

* Read operations
* Write operations
* Throughput
* I/O wait
* Device utilization
* Latency

Disk capacity and disk performance are separate monitoring dimensions.

---

# 11. System-Level I/O

Run:

```bash
vmstat 2 5
```

This provides additional information about:

* CPU
* Memory
* Swap
* Processes
* I/O

---

# 12. Kernel Storage Logs

Run:

```bash
sudo dmesg -T | tail -50
```

Storage-related messages:

```bash
sudo dmesg -T | grep -Ei 'error|fail|disk|nvme|ext4|xfs|io'
```

These commands help identify low-level storage or filesystem problems.

---

# 13. Journal Monitoring

Run:

```bash
sudo journalctl -p warning..alert --no-pager
```

Storage-focused search:

```bash
sudo journalctl -b --no-pager | grep -Ei 'disk|nvme|ext4|mount|filesystem|io'
```

The output should be interpreted in context rather than assuming every warning is a storage incident.

---

# 14. MySQL Storage Validation

Check the mount:

```bash
findmnt /data/mysql
```

Check capacity:

```bash
df -hT /data/mysql
```

Check inode usage:

```bash
df -ih /data/mysql
```

Check directory usage:

```bash
sudo du -xhd1 /data/mysql 2>/dev/null | sort -h
```

Check service:

```bash
sudo systemctl is-active mysql
```

Expected:

```text
active
```

---

# 15. Nginx Verification

Nginx was checked because it existed in the previous storage lab, but this is a **new VM**.

Command:

```bash
sudo systemctl is-active nginx
```

Result:

```text
inactive
```

Detailed check:

```bash
sudo systemctl --no-pager status nginx | head -20
```

Result:

```text
Unit nginx.service could not be found.
```

Package check:

```bash
dpkg -l | grep -i nginx
```

No package was returned.

Binary check:

```bash
command -v nginx
```

No binary was returned.

Directory check:

```bash
sudo ls -ld /data/logs/nginx
```

Result:

```text
No such file or directory
```

### Conclusion

Nginx is not installed on this new VM.

Therefore:

```text
Nginx Monitoring: Not Applicable
```

No unnecessary installation was performed.

The previous Day 9 Nginx work remains separate from this new VM.

---

# 16. MySQL Application Health

The final MySQL verification showed:

```text
Active: active (running)
```

and:

```text
Status: "Server is operational"
```

Therefore:

```text
MySQL Health = PASS
```

---

# 17. Storage Monitoring Checklist

* [ ] `df -hT` checked
* [ ] `df -ih` checked
* [ ] `findmnt` checked
* [ ] `lsblk -f` checked
* [ ] `sudo pvs` checked
* [ ] `sudo vgs` checked
* [ ] `sudo lvs` checked
* [ ] `/data` usage checked
* [ ] `/data/mysql` usage checked
* [ ] Large files investigated
* [ ] `iostat` checked
* [ ] `vmstat` checked
* [ ] Kernel storage logs checked
* [ ] Journal checked
* [ ] MySQL service verified
* [ ] Nginx applicability verified
* [ ] Final storage health assessed

---

# 18. Evidence / Screenshots

Recommended screenshots for the completed lab:

```text
day12-01-df-filesystem-usage.png
day12-02-inode-usage.png
day12-03-findmnt-storage.png
day12-04-lsblk-storage-layout.png
day12-05-lvm-health.png
day12-06-directory-usage.png
day12-07-large-files.png
day12-08-iostat.png
day12-09-vmstat.png
day12-10-kernel-storage-check.png
day12-11-journal-storage-check.png
day12-12-mysql-storage-health.png
day12-14-combined-storage-health.png
```

Nginx screenshot was intentionally not included because Nginx is not installed on this VM.

---

# 19. Final Lab Result

```text
Filesystem Monitoring       = Completed
Inode Monitoring            = Completed
Mount Monitoring            = Completed
Block Device Monitoring     = Completed
LVM Monitoring              = Completed
Directory Monitoring        = Completed
Large File Investigation    = Completed
Disk I/O Monitoring         = Completed
Kernel Log Monitoring       = Completed
Journal Monitoring          = Completed
MySQL Health Check          = PASS
Nginx Check                 = NOT APPLICABLE
```

---

# 20. Production Takeaway

The main lesson from Day 12 is that storage monitoring is not just:

```bash
df -h
```

A complete storage-health assessment combines:

```text
Filesystem Capacity
        +
Inodes
        +
Mounts
        +
Block Devices
        +
LVM
        +
Directory Growth
        +
Large Files
        +
Disk I/O
        +
System Logs
        +
Application Health
```

This provides the foundation for Day 13, where these repetitive checks can be converted into shell automation.

## Next

**Day 13 — Shell Automation**
