Lab 12 — Linux Storage Monitoring
1. Lab Objective

The objective of this lab is to perform a complete storage-health assessment on the Azure Linux VM.

The lab covers:

Filesystem capacity
Inode utilization
Mount verification
Block devices
LVM health
Directory-level storage usage
Large-file investigation
Disk I/O
Kernel and system logs
MySQL storage health
Application/service health
Production-oriented storage monitoring

Environment note: This is a newly created VM on which Day 10 (MySQL Storage) and Day 11 (MySQL Backup & Restore) were completed. Nginx from the previous Day 9 VM is not installed here, so Nginx is intentionally treated as Not Applicable.

2. Lab Environment
Cloud Platform : Microsoft Azure
VM             : rg-linux-vm
User           : azureuser
Database       : MySQL
MySQL Storage  : /data/mysql
Storage        : Linux filesystem + LVM
3. Pre-Lab Verification

Check the current user:

whoami

Check hostname:

hostname

Check OS:

cat /etc/os-release

Check system uptime:

uptime
4. Filesystem Capacity Monitoring
4.1 Check All Filesystems

Run:

df -hT

This displays:

Filesystem
Filesystem type
Total size
Used space
Available space
Usage percentage
Mount point
4.2 Check Root Filesystem
df -hT /
4.3 Check MySQL Filesystem
df -hT /data/mysql
Verification

Confirm:

/ exists and is mounted
/data/mysql exists
filesystem type is correct
sufficient free space is available
utilization is within acceptable limits
5. Inode Monitoring

Check inode utilization:

df -ih

For the root filesystem:

df -ih /

For MySQL:

df -ih /data/mysql
Important

A filesystem can have free disk space but still be unable to create files when all inodes are consumed.

Therefore:

Disk Capacity
+
Inode Capacity

must both be monitored.

6. Mount Verification

Display all mounts:

findmnt

Verify MySQL storage:

findmnt /data/mysql
Expected

The command should show the filesystem mounted at:

/data/mysql

This verifies that MySQL is using the intended storage location.

7. Block Device Monitoring

Run:

lsblk

Detailed view:

lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINTS

Filesystem view:

lsblk -f
Verification

Identify the relationship:

Disk
 ↓
Partition
 ↓
LVM PV
 ↓
Volume Group
 ↓
Logical Volume
 ↓
Filesystem
 ↓
Mount Point
8. LVM Monitoring
8.1 Physical Volumes
sudo pvs

Detailed:

sudo pvdisplay

Verify:

PV exists
PV belongs to expected VG
capacity is correct
allocation is healthy
8.2 Volume Groups
sudo vgs

Detailed:

sudo vgdisplay

Pay special attention to:

VFree

VFree indicates capacity available for future LV expansion.

8.3 Logical Volumes
sudo lvs

Detailed:

sudo lvdisplay

Compact view:

sudo lvs -o lv_name,vg_name,lv_size,lv_attr
Verification

Confirm:

expected VG exists
expected LVs exist
LV sizes match the storage design
VG has usable free space
9. Directory-Level Storage Monitoring

Check /data:

sudo du -xhd1 /data 2>/dev/null | sort -h

The -x option prevents du from crossing filesystem boundaries.

9.1 MySQL Directory Usage
sudo du -xhd1 /data/mysql 2>/dev/null | sort -h

This helps identify which MySQL directories are consuming the most storage.

10. Large File Investigation

Search for files larger than 500 MB:

sudo find /data -xdev -type f -size +500M -ls 2>/dev/null

If necessary, search /var:

sudo find /var -xdev -type f -size +500M -ls 2>/dev/null
Important

Do not delete a large file simply because it is large.

First determine:

Owner
Purpose
Application
Retention policy
Whether the file is currently required
11. Disk I/O Monitoring

Check whether iostat is installed:

command -v iostat

If unavailable:

sudo apt update
sudo apt install -y sysstat

Run:

iostat

Then:

iostat -xz 2 5
Observe

Important metrics:

Metric	Meaning
r/s	Reads per second
w/s	Writes per second
rkB/s	Read throughput
wkB/s	Write throughput
await	Average I/O wait
%util	Device utilization
12. VM-Level Monitoring

Run:

vmstat 2 5

Observe:

CPU activity
Memory
Swap
Processes
I/O
System activity

This helps correlate storage performance with overall VM behavior.

13. Kernel Storage Logs

Check recent kernel messages:

sudo dmesg -T | tail -50

Search storage-related messages:

sudo dmesg -T | grep -Ei 'error|fail|disk|nvme|ext4|xfs|io'

Look for:

Disk errors
Filesystem errors
I/O failures
Mount problems
NVMe errors
Kernel warnings
14. System Journal Monitoring

Check warnings and errors:

sudo journalctl -p warning..alert --no-pager

Storage-focused logs:

sudo journalctl -b --no-pager | grep -Ei 'disk|nvme|ext4|mount|filesystem|io'

Review the context of any warning before considering it a real incident.

15. MySQL Storage Health

Verify MySQL mount:

findmnt /data/mysql

Check filesystem capacity:

df -hT /data/mysql

Check inode utilization:

df -ih /data/mysql

Check MySQL storage consumption:

sudo du -xhd1 /data/mysql 2>/dev/null | sort -h
16. MySQL Service Health

Check service state:

sudo systemctl is-active mysql

Expected:

active

Detailed status:

sudo systemctl --no-pager status mysql | head -15
Completed Verification

The MySQL service was confirmed with:

Active: active (running)
Status: "Server is operational"

Therefore:

MySQL Health = PASS
17. Nginx Applicability Check

Because this is a new VM, verify whether Nginx exists:

sudo systemctl is-active nginx

Check service:

sudo systemctl --no-pager status nginx | head -20

Check package:

dpkg -l | grep -i nginx

Check binary:

command -v nginx

Check previous Nginx storage path:

sudo ls -ld /data/logs/nginx
Actual Result on This VM

The VM returned:

Unit nginx.service could not be found.

The Nginx package and binary were also not present.

The directory:

/data/logs/nginx

was not present.

Conclusion

Nginx is not installed on this VM.

Therefore:

Nginx Storage Monitoring = Not Applicable

No Nginx installation was performed because Day 9 Nginx work belongs to the previous VM/environment.

18. Combined Storage Health Check

Run the following commands as a final operational check:

df -hT
df -ih
findmnt
lsblk -f
sudo pvs
sudo vgs
sudo lvs
sudo du -xhd1 /data 2>/dev/null | sort -h
iostat -xz 2 5
sudo journalctl -p warning..alert --no-pager
sudo systemctl is-active mysql
19. Storage Incident Simulation
Scenario

Suppose an application reports:

No space left on device

Do not immediately delete files.

Follow this investigation sequence.

Step 1 — Check filesystem
df -hT
Step 2 — Check inodes
df -ih
Step 3 — Identify large directories
sudo du -xhd1 /mountpoint 2>/dev/null | sort -h
Step 4 — Identify large files
sudo find /mountpoint -xdev -type f -size +500M -ls 2>/dev/null
Step 5 — Check deleted but open files
sudo lsof +L1
Step 6 — Check logs
sudo journalctl -p warning..alert --no-pager
Step 7 — Check LVM
sudo vgs
sudo lvs
Step 8 — Check application
sudo systemctl status mysql --no-pager

This produces an evidence-based troubleshooting process.

20. Prometheus and Grafana Monitoring

Long-term storage monitoring can be implemented using:

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

Node Exporter can expose:

Filesystem metrics
Disk metrics
CPU metrics
Memory metrics
Network metrics

Prometheus stores time-series data.

Grafana provides dashboards and visualization.

21. Final Storage Health Report

Complete the following after collecting the outputs:

Hostname:

Root filesystem usage:

Root inode usage:

/data/mysql filesystem usage:

/data/mysql inode usage:

VG name:

VG total capacity:

VG free capacity:

Logical volumes:

Largest directory:

Large files found:

Disk I/O observation:

Kernel log observation:

Journal observation:

MySQL status:

Nginx status:

Overall storage health:
22. Screenshot Checklist

Recommended evidence files:

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

Do not capture:

Passwords
Database credentials
Access tokens
SSH private keys
Connection strings containing secrets
23. Lab Completion Checklist

Filesystem capacity checked

Inode usage checked

Mount points verified

Block devices inspected

LVM PV checked

LVM VG checked

LVM LV checked

/data usage analyzed

/data/mysql usage analyzed

Large files investigated

Disk I/O checked

VM-level I/O checked

Kernel logs checked

System journal checked

MySQL storage verified

MySQL service verified

Nginx applicability verified

Final storage health assessment completed

24. Final Result
Filesystem Monitoring    = COMPLETED
Inode Monitoring         = COMPLETED
Mount Verification       = COMPLETED
Block Device Monitoring  = COMPLETED
LVM Monitoring           = COMPLETED
Directory Monitoring     = COMPLETED
Large File Investigation = COMPLETED
Disk I/O Monitoring      = COMPLETED
Kernel Log Monitoring    = COMPLETED
Journal Monitoring       = COMPLETED
MySQL Storage Health     = PASS
MySQL Service Health     = PASS
Nginx                    = NOT APPLICABLE
25. Key Takeaway

The most important lesson from Day 12 is that storage monitoring is not limited to:

df -h

A proper storage-health assessment combines:

Capacity
   +
Inodes
   +
Mounts
   +
Block Devices
   +
LVM
   +
Directory Usage
   +
Large Files
   +
Disk I/O
   +
System Logs
   +
Application Health

This creates a foundation for Day 13 — Shell Automation, where these manual monitoring checks will be converted into repeatable automated health checks.