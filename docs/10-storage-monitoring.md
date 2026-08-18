Day 10 — MySQL Storage Engineering
1. Overview

This document explains how Linux storage can be designed and configured for a MySQL database running on an Azure Linux Virtual Machine.

The objective of this day is to move MySQL database storage away from the operating-system filesystem and place it on a dedicated data disk.

The final architecture implemented in this lab is:

Azure Managed Disk
        │
        ▼
/dev/nvme0n2
        │
        ▼
/dev/nvme0n2p1
        │
        ▼
ext4 filesystem
        │
        ▼
/data/mysql
        │
        ▼
MySQL datadir
        │
        ├── day10_test/
        │      └── storage_test.ibd
        │
        └── other MySQL databases

The important point is that the database is not simply configured to use a directory named /data/mysql.

The directory itself is backed by a separate filesystem:

/dev/nvme0n2p1 → /data/mysql

and MySQL is configured to use that path:

datadir = /data/mysql
2. Objectives

By completing this lab, the following concepts should be understood:

Why database storage should be separated from the OS disk
How Azure Managed Disks appear inside Linux
How a Linux partition becomes a filesystem
How a filesystem is mounted
How MySQL's datadir works
How to configure MySQL to use dedicated storage
How filesystem ownership affects MySQL
How to verify the running MySQL server
How to prove that actual database files are being created on the dedicated disk
How storage capacity can be monitored
Why database backups are required before major storage changes
3. Why Dedicated Storage for MySQL?

A database continuously performs disk I/O.

MySQL stores database information on disk including:

table data
indexes
InnoDB tablespaces
redo/undo related data
metadata
temporary database files
other database-specific files

If MySQL uses the same filesystem as the operating system, database growth can eventually consume the root filesystem.

For example:

OS
├── /etc
├── /var
├── /usr
├── /home
└── /var/lib/mysql

If the database becomes very large, / can run out of space.

A better storage layout is:

OS Disk
└── /

Data Disk
└── /data/mysql

This gives database storage its own capacity boundary.

4. Storage Architecture Used in This Lab

The VM contains two important disks.

OS Disk
nvme0n1
└── nvme0n1p1
    └── /

The OS disk is approximately 30 GB.

MySQL Data Disk
nvme0n2
└── nvme0n2p1
    └── /data/mysql

The dedicated MySQL disk is approximately 16 GB.

The verified Linux output was:

nvme0n2        16G        disk
└─nvme0n2p1  15.9G ext4   part /data/mysql

This proves that the second disk is being used specifically for MySQL storage.

5. Identify the Storage Devices

Before modifying storage, always inspect the block devices.

lsblk

For a more useful view:

lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINTS

Example result:

NAME          SIZE FSTYPE TYPE MOUNTPOINTS
nvme0n1        30G        disk
├─nvme0n1p1    29G ext4   part /
├─nvme0n1p14    4M        part
├─nvme0n1p15  106M vfat   part /boot/efi
└─nvme0n1p16  913M ext4   part /boot
nvme0n2        16G        disk
└─nvme0n2p1  15.9G ext4   part /data/mysql

This provides the complete relationship between:

Disk → Partition → Filesystem → Mount Point
6. Verify the MySQL Storage Mount

The most important command is:

findmnt /data/mysql

Expected result:

TARGET      SOURCE         FSTYPE OPTIONS
/data/mysql /dev/nvme0n2p1 ext4   rw,relatime,stripe=8192

This proves:

/data/mysql
      ↓
/dev/nvme0n2p1
      ↓
ext4

The application is therefore using a dedicated mounted filesystem.

7. Check Filesystem Capacity

Use:

df -h /data/mysql

The lab produced:

Filesystem      Size  Used Avail Use% Mounted on
/dev/nvme0n2p1   16G  193M   15G   2% /data/mysql

This shows:

Total capacity: approximately 16 GB
Used space: approximately 193 MB
Available space: approximately 15 GB
Usage: approximately 2%

The low usage confirms that the dedicated disk currently has significant free capacity.

8. Check the Existing MySQL Data Directory

Before changing MySQL configuration, inspect the current configuration.

sudo grep -R "datadir" /etc/mysql/ -n

The relevant configuration file is:

/etc/mysql/mysql.conf.d/mysqld.cnf

The configured value is:

datadir = /data/mysql

Verify it directly:

sudo grep -n "datadir" /etc/mysql/mysql.conf.d/mysqld.cnf
9. Why Configuration Verification Is Not Enough

Seeing:

datadir = /data/mysql

inside a configuration file does not by itself prove that the running MySQL server is using the path.

The running database must be queried directly.

Use:

sudo mysql -e "SHOW VARIABLES LIKE 'datadir';"

Expected result:

+---------------+--------------+
| Variable_name | Value        |
+---------------+--------------+
| datadir       | /data/mysql/ |
+---------------+--------------+

Another useful command is:

sudo mysql -e "SELECT @@datadir, DATABASE();"

The lab returned:

@@datadir
/data/mysql/

This is strong runtime verification.

10. MySQL Storage Permissions

MySQL must have permission to access its data directory.

The directory is owned by:

mysql:mysql

Verify:

sudo ls -ld /data/mysql

For database storage, ownership and permissions must be treated carefully because database files can contain sensitive application data.

The typical ownership command is:

sudo chown -R mysql:mysql /data/mysql

Do not blindly apply broad permissions such as:

chmod 777

Database storage should remain restricted.

11. Create a Test Database

To prove that MySQL is actually operating correctly from the new storage location, create a small test database and table.

Example:

sudo mysql

Then:

CREATE DATABASE day10_test;

USE day10_test;

CREATE TABLE storage_test (
    id INT AUTO_INCREMENT PRIMARY KEY,
    message VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO storage_test (message)
VALUES ('MySQL running from /data/mysql');

SELECT * FROM storage_test;

Expected data:

id | message                        | created_at
1  | MySQL running from /data/mysql | ...

This is an application-level verification.

12. Verify Physical Database Files

The database directory can be inspected from Linux.

sudo ls -lah /data/mysql/day10_test/

The lab produced:

total 120K

-rw-r----- 1 mysql mysql 112K storage_test.ibd

The directory size was:

sudo du -sh /data/mysql/day10_test/

Result:

116K

This provides physical evidence that database files are being created underneath /data/mysql.

13. Verify Database Data

Run:

sudo mysql -e "USE day10_test; SELECT * FROM storage_test;"

The lab returned:

+----+--------------------------------+---------------------+
| id | message                        | created_at          |
+----+--------------------------------+---------------------+
|  1 | MySQL running from /data/mysql | 2026-08-18 09:58:06 |
+----+--------------------------------+---------------------+

This completes the verification chain:

MySQL
  ↓
day10_test
  ↓
storage_test
  ↓
storage_test.ibd
  ↓
/data/mysql
  ↓
/dev/nvme0n2p1
14. Important Difference Between /data and /data/mysql

During validation, the following command produced no mount information:

findmnt /data

This is expected because /data itself is not the mounted filesystem.

The actual mount point is:

/data/mysql

Therefore the correct command is:

findmnt /data/mysql

which returns:

/data/mysql /dev/nvme0n2p1 ext4

This distinction is important when troubleshooting Linux storage.

A parent directory does not automatically mean that the parent is the mount point.

15. Storage Validation Checklist

The complete Day 10 storage validation consists of several independent checks.

Block Device
lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINTS

Confirms the disk and partition.

Filesystem
lsblk -f

Confirms filesystem type.

Mount
findmnt /data/mysql

Confirms the mounted source.

Capacity
df -h /data/mysql

Confirms usable filesystem capacity.

MySQL Configuration
sudo grep -n "datadir" /etc/mysql/mysql.conf.d/mysqld.cnf

Confirms intended configuration.

MySQL Runtime
sudo mysql -e "SHOW VARIABLES LIKE 'datadir';"

Confirms the running server.

Application Data
sudo mysql -e "USE day10_test; SELECT * FROM storage_test;"

Confirms database functionality.

Physical Files
sudo ls -lah /data/mysql/day10_test/

Confirms actual files exist on the storage path.

16. Database Backup Awareness

Changing database storage should not be treated as a normal filesystem configuration change.

Before major database-storage operations, a logical backup provides an additional recovery option.

Create a backup directory:

sudo mkdir -p /var/backups/mysql-day10

Create a logical dump:

sudo mysqldump --all-databases \
  --single-transaction \
  --routines \
  --events \
  | sudo tee /var/backups/mysql-day10/all-databases.sql

Verify:

sudo ls -lh /var/backups/mysql-day10/all-databases.sql

And:

sudo wc -l /var/backups/mysql-day10/all-databases.sql

A backup is only useful if it can actually be recovered, so production systems should also test restoration.

17. Troubleshooting Commands

If MySQL does not start after a storage change:

sudo systemctl status mysql

Then inspect recent logs:

sudo journalctl -u mysql -n 100 --no-pager

Check the mount:

findmnt /data/mysql

Check capacity:

df -h /data/mysql

Check permissions:

sudo ls -ld /data/mysql
sudo ls -lah /data/mysql

Check the configured datadir:

sudo grep -R "datadir" /etc/mysql/ -n

Check the runtime datadir:

sudo mysql -e "SELECT @@datadir;"
18. Common Mistakes
Mistake 1 — Only changing datadir

Changing:

datadir = /data/mysql

does not prove the database is correctly using the storage.

Always verify:

SELECT @@datadir;
Mistake 2 — Forgetting the filesystem mount

A directory named /data/mysql does not automatically mean a dedicated disk is mounted there.

Always run:

findmnt /data/mysql
Mistake 3 — Checking the wrong path
findmnt /data

and:

findmnt /data/mysql

are not equivalent.

The second command identifies the actual MySQL mount used in this lab.

Mistake 4 — Incorrect ownership

If MySQL cannot access the directory, verify:

sudo ls -ld /data/mysql

and ensure the MySQL service account has appropriate access.

Mistake 5 — Filling the root filesystem

Do not assume a dedicated database directory exists on a dedicated disk.

Always confirm:

df -h /data/mysql

and:

findmnt /data/mysql
19. Final Architecture

The final Day 10 architecture is:

                    Azure
                      │
                      ▼
              Managed Data Disk
                      │
                      ▼
                /dev/nvme0n2
                      │
                      ▼
              /dev/nvme0n2p1
                      │
                   ext4
                      │
                      ▼
                /data/mysql
                      │
                      ▼
                 MySQL Server
                      │
                      ▼
                 day10_test
                      │
                      ▼
                storage_test
                      │
                      ▼
              storage_test.ibd
20. Production Engineering Takeaway

Day 10 connects the storage concepts learned during the previous days with a real application.

The progression is:

Azure Managed Disk
        ↓
Linux Block Device
        ↓
Partition
        ↓
Filesystem
        ↓
Mount Point
        ↓
Application Storage
        ↓
MySQL
        ↓
Database Data
        ↓
Backup / Recovery

The most important lesson is:

Never assume that an application is using the storage you intended. Prove it from the block-device layer, filesystem layer, mount layer, application configuration layer, and application runtime layer.

For this lab, all five layers were verified successfully.

21. Day 10 Completion Status
Validation	Status
Dedicated disk detected	✅
Partition detected	✅
ext4 filesystem detected	✅
/data/mysql mounted	✅
Dedicated disk capacity verified	✅
MySQL datadir configured	✅
Running MySQL datadir verified	✅
MySQL test database created	✅
Test table created	✅
Physical .ibd file verified	✅
Database data queried successfully	✅
Storage architecture validated	✅

Day 10 MySQL Storage: COMPLETE