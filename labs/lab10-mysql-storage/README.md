Lab 10 — MySQL Storage on Dedicated Linux Storage
1. Lab Overview

This hands-on lab configures MySQL to use a dedicated Linux storage volume instead of relying on the operating-system filesystem.

The lab combines the concepts from the previous storage exercises:

Disk
  ↓
Partition
  ↓
Filesystem
  ↓
Mount
  ↓
Application Storage
  ↓
MySQL

The final target is:

/dev/nvme0n2p1
        ↓
    ext4
        ↓
 /data/mysql
        ↓
 MySQL datadir
2. Lab Objectives

By the end of the lab, you should be able to:

Identify the dedicated MySQL disk
Verify its partition
Verify its filesystem
Verify the mount point
Check storage capacity
Configure MySQL's datadir
Verify MySQL ownership
Restart MySQL safely
Verify the running MySQL server
Create a test database
Create test data
Verify physical database files
Validate the complete storage architecture
Understand the importance of database backups
3. Prerequisites

The VM should have:

Ubuntu/Linux VM
MySQL installed
A dedicated Azure Managed Disk
A Linux partition on the data disk
ext4 filesystem
/data/mysql mounted
mysql service available

Check MySQL:

sudo systemctl status mysql

Check storage:

lsblk
4. Step 1 — Identify the Dedicated Disk

Run:

lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINTS

In this lab the dedicated disk is:

nvme0n2
└── nvme0n2p1

The final expected structure is approximately:

nvme0n2        16G        disk
└─nvme0n2p1  15.9G ext4   part /data/mysql
What this proves

The VM has a separate 16 GB block device intended for MySQL data.

5. Step 2 — Verify the Filesystem

Run:

lsblk -f

Confirm that:

/dev/nvme0n2p1

has:

FSTYPE=ext4

Do not format the filesystem again if it already contains the required data.

6. Step 3 — Verify the MySQL Mount

Run:

findmnt /data/mysql

Expected:

TARGET      SOURCE         FSTYPE OPTIONS
/data/mysql /dev/nvme0n2p1 ext4   rw,relatime,stripe=8192

This proves that /data/mysql is a real filesystem mount.

It is not merely an ordinary directory on /.

7. Step 4 — Check Storage Capacity

Run:

df -h /data/mysql

The lab produced approximately:

Filesystem      Size  Used Avail Use% Mounted on
/dev/nvme0n2p1   16G  193M   15G   2% /data/mysql

This proves that MySQL has a dedicated 16 GB filesystem with approximately 15 GB available.

8. Step 5 — Inspect MySQL Configuration

Search for the configured data directory:

sudo grep -R "datadir" /etc/mysql/ -n

Check the primary configuration file:

sudo grep -n "datadir" /etc/mysql/mysql.conf.d/mysqld.cnf

Expected:

datadir = /data/mysql
9. Step 6 — Verify the MySQL Data Directory

Create the directory if required:

sudo mkdir -p /data/mysql

Verify:

sudo ls -ld /data/mysql

The directory should be accessible to the MySQL service.

10. Step 7 — Verify Ownership

Check:

sudo ls -ld /data/mysql

The expected ownership is:

mysql mysql

If the lab requires correcting ownership:

sudo chown -R mysql:mysql /data/mysql

Then verify again:

sudo ls -ld /data/mysql
11. Step 8 — Restart MySQL

After configuration changes:

sudo systemctl restart mysql

Check:

sudo systemctl status mysql

The service should show an active/running state.

If it fails:

sudo journalctl -u mysql -n 100 --no-pager

Do not continue assuming the configuration worked if the service is not healthy.

12. Step 9 — Verify Runtime datadir

This is one of the most important validation steps.

Run:

sudo mysql -e "SHOW VARIABLES LIKE 'datadir';"

Expected:

+---------------+--------------+
| Variable_name | Value        |
+---------------+--------------+
| datadir       | /data/mysql/ |
+---------------+--------------+

Also run:

sudo mysql -e "SELECT @@datadir, DATABASE();"

Expected:

@@datadir
/data/mysql/

DATABASE() can return NULL because the command did not select a database.

That is normal.

13. Step 10 — Create a Test Database

Open MySQL:

sudo mysql

Run:

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

Expected result should contain:

MySQL running from /data/mysql

This confirms that MySQL is operational.

14. Step 11 — Verify the Physical Database Directory

Exit MySQL:

EXIT;

Then:

sudo ls -lah /data/mysql/day10_test/

The lab produced:

-rw-r----- 1 mysql mysql 112K storage_test.ibd

This is important because it provides physical filesystem evidence.

The database created a real file under:

/data/mysql/day10_test/
15. Step 12 — Measure Database Storage

Run:

sudo du -sh /data/mysql/day10_test/

The lab returned:

116K

This shows the amount of filesystem space currently consumed by the test database directory.

16. Step 13 — Verify the Database Data Again

Run:

sudo mysql -e "USE day10_test; SELECT * FROM storage_test;"

Expected:

+----+--------------------------------+---------------------+
| id | message                        | created_at          |
+----+--------------------------------+---------------------+
|  1 | MySQL running from /data/mysql | ...                 |
+----+--------------------------------+---------------------+

This provides application-level proof.

17. Step 14 — Perform Final Storage Validation

Run all of the following:

lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINTS
findmnt /data/mysql
df -h /data/mysql
sudo grep -n "datadir" /etc/mysql/mysql.conf.d/mysqld.cnf
sudo mysql -e "SHOW VARIABLES LIKE 'datadir';"
sudo ls -lah /data/mysql/day10_test/
sudo mysql -e "USE day10_test; SELECT * FROM storage_test;"
18. Final Expected Architecture

The final result should look like:

Azure Managed Disk
        │
        ▼
/dev/nvme0n2
        │
        ▼
/dev/nvme0n2p1
        │
        ▼
ext4
        │
        ▼
/data/mysql
        │
        ▼
MySQL
        │
        ▼
day10_test
        │
        ▼
storage_test
        │
        ▼
storage_test.ibd
19. Evidence / Screenshot Checklist

Recommended screenshots for the Day 10 lab:

Screenshot 1 — Disk Identity

Capture:

lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINTS

Suggested filename:

disk-identity.png
Screenshot 2 — Partition Verification

Capture the partition/filesystem state.

Suggested filename:

disk-partitioned.png
Screenshot 3 — Filesystem

Capture:

lsblk -f

Suggested filename:

filesystem-created.png
Screenshot 4 — MySQL Storage Mount

Capture:

findmnt /data/mysql
df -h /data/mysql

Suggested filename:

mysql-storage-mounted.png
Additional Strong Evidence

For the completed Day 10 validation, also capture:

sudo mysql -e "SHOW VARIABLES LIKE 'datadir';"

Suggested filename:

mysql-datadir-verified.png

And:

sudo mysql -e "USE day10_test; SELECT * FROM storage_test;"

Suggested filename:

mysql-data-verified.png

And:

sudo ls -lah /data/mysql/day10_test/
sudo du -sh /data/mysql/day10_test/

Suggested filename:

mysql-physical-data-verified.png
20. Troubleshooting
MySQL is not starting
sudo systemctl status mysql

Then:

sudo journalctl -u mysql -n 100 --no-pager
/data/mysql is not mounted

Check:

findmnt /data/mysql

Then:

lsblk -f

Check whether the expected filesystem exists.

MySQL cannot access the directory

Check:

sudo ls -ld /data/mysql

Check ownership:

sudo chown -R mysql:mysql /data/mysql
MySQL still reports another datadir

Check configuration:

sudo grep -R "datadir" /etc/mysql/ -n

Then check runtime:

sudo mysql -e "SELECT @@datadir;"

Never rely only on the configuration file.

/data Shows Nothing with findmnt

This is expected if the actual mount is:

/data/mysql

Use:

findmnt /data/mysql

instead of:

findmnt /data
21. Lab Completion Checklist

Dedicated Azure disk identified

Linux block device identified

Partition verified

ext4 filesystem verified

/data/mysql mounted

Storage capacity verified

MySQL datadir configured

MySQL ownership verified

MySQL restarted successfully

Runtime datadir verified

Test database created

Test table created

Test data inserted

Physical .ibd file verified

Database data queried successfully

Final storage architecture validated

22. Final Result

The Day 10 lab successfully demonstrates dedicated database storage on Linux.

The final verified relationship is:

/dev/nvme0n2p1
        ↓
/data/mysql
        ↓
MySQL datadir
        ↓
day10_test
        ↓
storage_test
        ↓
storage_test.ibd

Lab Status: COMPLETE

The next production-level topic is backup and restore, where the focus shifts from merely storing database data to protecting and recovering that data.