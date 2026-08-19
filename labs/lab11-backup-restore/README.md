Lab 11 – MySQL Backup & Restore
Lab Objective

The objective of this lab is to perform a practical MySQL backup and restore workflow on a Linux VM.

This lab demonstrates:

creating a MySQL backup directory
generating a full logical backup
including routines and events
using transactional backup options
verifying the backup file
creating a restore-test database
validating the database environment
understanding the restore workflow
collecting evidence for the completed lab
1. Lab Environment
Operating System

Linux VM

Database

MySQL

Backup Type

Logical backup

Backup Tool
mysqldump
Backup Directory
/var/backups/mysql-day11
Backup File
/var/backups/mysql-day11/all-databases.sql
Restore Test Database
day11_restore_test
2. Lab Architecture
                    Linux VM
                       │
                       ▼
                  MySQL Server
                       │
                       │ mysqldump
                       ▼
        /var/backups/mysql-day11/
                       │
                       ▼
              all-databases.sql
                       │
                       │ validation
                       ▼
                 Backup Check
                       │
                       ▼
              Restore Test Flow
                       │
                       ▼
             day11_restore_test
3. Step 1 – Create Backup Directory

Create the Day 11 backup directory:

sudo mkdir -p /var/backups/mysql-day11

The -p option ensures the directory is created if it does not already exist.

Verify:

sudo ls -ld /var/backups/mysql-day11

Expected:

/var/backups/mysql-day11
4. Step 2 – Create Full MySQL Backup

Run:

sudo mysqldump --all-databases \
--single-transaction \
--routines \
--events \
| sudo tee /var/backups/mysql-day11/all-databases.sql

This creates:

/var/backups/mysql-day11/all-databases.sql
5. Command Breakdown

The command contains several important options.

All Databases
--all-databases

Exports all databases.

Transaction Consistency
--single-transaction

Requests a consistent transaction snapshot for transactional tables.

Stored Procedures and Functions
--routines

Includes routines.

Event Scheduler
--events

Includes MySQL events.

Output File
/var/backups/mysql-day11/all-databases.sql

This is the final logical backup file.

6. Step 3 – Verify Backup File

Check that the file exists:

sudo ls -lh /var/backups/mysql-day11/all-databases.sql

Then perform the non-empty check:

sudo test -s /var/backups/mysql-day11/all-databases.sql && echo "BACKUP FILE IS NOT EMPTY"

Expected:

BACKUP FILE IS NOT EMPTY

This confirms that the backup file exists and contains data.

7. Step 4 – Inspect Backup

The beginning of the dump can be inspected:

sudo head -n 30 /var/backups/mysql-day11/all-databases.sql

This helps confirm that the file contains SQL dump content rather than being an empty file.

The backup is a text-based logical dump, so it can be inspected using normal Linux commands.

8. Step 5 – Check Backup Size

Run:

sudo du -h /var/backups/mysql-day11/all-databases.sql

or:

sudo ls -lh /var/backups/mysql-day11/

The purpose is to understand how much storage the backup consumes.

For production systems, unusual changes in backup size can be useful for detecting backup problems.

9. Step 6 – Create Restore Test Database

Create a dedicated database for restore testing:

sudo mysql -e "CREATE DATABASE IF NOT EXISTS day11_restore_test;"

This gives the lab an isolated database named:

day11_restore_test
10. Step 7 – Verify Database Exists

Run:

sudo mysql -e "SHOW DATABASES;"

Confirm that:

day11_restore_test

appears in the database list.

This verifies that the MySQL server is responding and the restore-test environment exists.

11. Step 8 – Verify MySQL Access

Run:

sudo mysql -e "SELECT VERSION();"

This verifies that MySQL can be accessed from the Linux shell.

You can also check the current server state:

sudo systemctl status mysql --no-pager

The service should be active.

12. Step 9 – Restore Concept

The normal logical restore mechanism is:

sudo mysql < /var/backups/mysql-day11/all-databases.sql

The process is:

all-databases.sql
        │
        ▼
      mysql
        │
        ▼
SQL statements executed
        │
        ▼
Database objects/data recreated

Because the dump was generated using:

--all-databases

the SQL file can contain definitions and data for multiple databases.

13. Important Restore Safety Principle

Never blindly restore a full production dump into a live production server during an experiment.

A full dump may contain:

database creation statements
table creation statements
data
routines
events
other database objects

Therefore, production restoration requires a controlled recovery procedure.

For this lab, the purpose is to understand and validate the recovery workflow safely.

14. Step 10 – Verify Database After Restore

After a controlled restore, check databases:

sudo mysql -e "SHOW DATABASES;"

Then inspect the target database:

sudo mysql -e "SHOW TABLES FROM day11_restore_test;"

If the database contains tables, inspect their structure:

sudo mysql -e "SHOW CREATE TABLE day11_restore_test.<table_name>\G"

Replace <table_name> with the actual table name.

15. Step 11 – Validate Database Connectivity

Run:

sudo mysql -e "SELECT NOW();"

This confirms that SQL queries are being executed successfully.

You can also run:

sudo mysql -e "SELECT VERSION();"

The purpose is to verify the MySQL server remains operational after the backup/restore workflow.

16. Step 12 – Verify Backup Directory

Final backup verification:

sudo ls -lah /var/backups/mysql-day11/

Expected structure:

/var/backups/mysql-day11/
└── all-databases.sql
17. Evidence Collected During Lab

The most important evidence from the completed practice includes:

Backup file validation
sudo test -s /var/backups/mysql-day11/all-databases.sql && echo "BACKUP FILE IS NOT EMPTY"

Expected:

BACKUP FILE IS NOT EMPTY
Database verification
sudo mysql -e "SHOW DATABASES;"

Expected:

day11_restore_test
Backup file
/var/backups/mysql-day11/all-databases.sql
18. Suggested Screenshot Evidence

Store Day 11 screenshots under:

screenshots/lab11/

Recommended evidence:

screenshots/lab11/
├── 01-backup-created.png
├── 02-backup-file-verified.png
├── 03-restore-test-database.png
└── 04-final-verification.png

The screenshots should show the actual terminal output from the lab.

19. What Was Actually Achieved

The lab successfully demonstrated the following workflow:

Create backup directory
        ↓
Run mysqldump
        ↓
Generate all-databases.sql
        ↓
Verify file is not empty
        ↓
Create restore-test database
        ↓
Verify database list
        ↓
Validate MySQL environment

The key operational concept is:

BACKUP
  ≠
RECOVERY

Backup creates the recovery material.

Restore testing proves that the recovery material can actually be used.

20. Production-Oriented Improvements

A real production backup solution would additionally consider:

scheduled backups
backup rotation
retention
encryption
remote/off-site storage
monitoring
alerting
backup failure detection
restore drills
RPO
RTO
access control
audit logging

For example:

MySQL
  │
  ▼
Scheduled Backup
  │
  ▼
Local Backup
  │
  ▼
Remote Backup
  │
  ▼
Monitoring
  │
  ▼
Periodic Restore Test
21. Troubleshooting
Backup file does not exist

Check:

sudo ls -lah /var/backups/mysql-day11/

If the directory does not exist:

sudo mkdir -p /var/backups/mysql-day11
Backup file is empty

Run:

sudo test -s /var/backups/mysql-day11/all-databases.sql && echo "BACKUP FILE IS NOT EMPTY"

If nothing is returned, investigate the backup command and MySQL connectivity.

Check:

sudo systemctl status mysql --no-pager
MySQL command fails

Check service status:

sudo systemctl status mysql --no-pager

Check MySQL connectivity:

sudo mysql -e "SELECT VERSION();"
Database does not appear

Run:

sudo mysql -e "SHOW DATABASES;"

If required:

sudo mysql -e "CREATE DATABASE IF NOT EXISTS day11_restore_test;"
22. Key Commands Learned
Create backup directory
sudo mkdir -p /var/backups/mysql-day11
Create complete logical backup
sudo mysqldump --all-databases \
--single-transaction \
--routines \
--events \
| sudo tee /var/backups/mysql-day11/all-databases.sql
Verify backup is not empty
sudo test -s /var/backups/mysql-day11/all-databases.sql && echo "BACKUP FILE IS NOT EMPTY"
Inspect backup
sudo head -n 30 /var/backups/mysql-day11/all-databases.sql
Check backup size
sudo ls -lh /var/backups/mysql-day11/all-databases.sql
Create restore test database
sudo mysql -e "CREATE DATABASE IF NOT EXISTS day11_restore_test;"
Verify databases
sudo mysql -e "SHOW DATABASES;"
Verify MySQL version
sudo mysql -e "SELECT VERSION();"
Check MySQL service
sudo systemctl status mysql --no-pager
Logical restore syntax
sudo mysql < /var/backups/mysql-day11/all-databases.sql
23. Final Lab Result
Status
Day 11 – COMPLETED
Backup
/var/backups/mysql-day11/all-databases.sql
Backup Validation
BACKUP FILE IS NOT EMPTY
Restore Test Database
day11_restore_test
Core Skill
MySQL Backup & Restore
24. Final Takeaway

The most important lesson from Lab 11 is:

Create Backup
      ↓
Verify Backup
      ↓
Test Restore
      ↓
Verify Recovered Data

A database backup strategy is incomplete if restoration has never been tested.

This lab establishes the foundation for more advanced production topics such as:

automated backup scripts
backup scheduling
retention policies
remote backup storage
monitoring
restore automation
disaster recovery
RPO/RTO planning