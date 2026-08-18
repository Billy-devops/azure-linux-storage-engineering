Day 11 – MySQL Backup & Restore Engineering
Overview

Day 11 focuses on MySQL backup and restore engineering in a Linux environment.

The objective is to understand how database administrators and DevOps engineers protect MySQL data against:

accidental deletion
database corruption
server failure
configuration mistakes
application deployment issues
storage failures
operational mistakes

A database backup is useful only when it can be verified and successfully restored.

Therefore, this day follows a production-oriented workflow:

MySQL Database
      │
      ▼
Create Logical Backup
      │
      ▼
Store Backup Safely
      │
      ▼
Verify Backup File
      │
      ▼
Prepare Restore Test
      │
      ▼
Restore Database
      │
      ▼
Verify Restored Data
      │
      ▼
Backup/Restore Confidence
1. Learning Objectives

By completing Day 11, the following concepts should be understood:

MySQL logical backups
mysqldump
full database backups
backup storage locations
transactional consistency
routines and events
backup file validation
database restore
restore testing
backup integrity
disaster recovery fundamentals
Recovery Point Objective (RPO)
Recovery Time Objective (RTO)
2. Why Database Backup Is Important

MySQL contains application-critical information.

For example:

Application
    │
    ▼
MySQL
    │
    ├── Users
    ├── Orders
    ├── Transactions
    ├── Configuration
    └── Application Data

If the database is accidentally deleted or corrupted, the application may stop functioning.

A backup provides a recovery point.

The important principle is:

A backup is not considered reliable until the restore process has been tested.

Simply creating a .sql file does not prove that recovery will work.

3. Logical Backup vs Physical Backup

There are two major approaches to database backup.

Logical Backup

A logical backup exports database objects and data as SQL statements.

Example:

mysqldump ...

The resulting file may contain statements such as:

CREATE DATABASE ...
CREATE TABLE ...
INSERT INTO ...

Advantages:

easy to inspect
portable
easy to restore
useful for migrations
database-independent at the storage-file level

Disadvantages:

restore can be slower for very large databases
SQL dump files can become large
backup and restore consume CPU and I/O
Physical Backup

A physical backup copies database storage files.

Examples include:

MySQL data directory copies
filesystem snapshots
storage snapshots
specialized physical backup tools

Physical backups can be faster for large environments, but they require more careful handling of:

database state
filesystem consistency
permissions
storage layout
MySQL version compatibility
4. Tool Used in Day 11

The primary tool used was:

mysqldump

mysqldump creates a logical SQL representation of MySQL databases.

Basic syntax:

mysqldump [options] database_name > backup.sql

For all databases:

mysqldump --all-databases > all-databases.sql
5. Backup Location

The Day 11 backup directory was:

/var/backups/mysql-day11/

The final backup file was:

/var/backups/mysql-day11/all-databases.sql

Directory structure:

/var/backups/
└── mysql-day11/
    └── all-databases.sql

This keeps the backup separate from the MySQL data directory.

6. Full MySQL Backup

The backup command used was:

sudo mysqldump --all-databases \
--single-transaction \
--routines \
--events \
| sudo tee /var/backups/mysql-day11/all-databases.sql
Explanation
sudo

Runs the command with elevated privileges.

sudo

This is useful when the MySQL account or backup destination requires administrative permissions.

mysqldump

Creates a logical SQL backup.

mysqldump
--all-databases

Backs up all databases accessible through the MySQL server.

--all-databases

Instead of specifying one database:

mysqldump database_name

the complete database set is exported.

--single-transaction

Creates a transaction-based consistent snapshot for transactional tables such as InnoDB.

--single-transaction

This is especially useful because it can reduce locking impact while creating the dump.

It is not a universal consistency mechanism for every storage engine or every type of database object, so production environments still require appropriate backup planning.

--routines

Includes stored procedures and functions.

--routines

Without this option, important stored program objects may not be included in the expected backup.

--events

Includes MySQL Event Scheduler events.

--events

This is important when applications depend on scheduled database-side jobs.

Pipe |

The output of mysqldump is passed to another command:

|

Flow:

mysqldump
    │
    ▼
SQL output
    │
    ▼
tee
    │
    ▼
all-databases.sql
tee

The command:

sudo tee /var/backups/mysql-day11/all-databases.sql

writes the backup output to the specified file.

7. Backup Verification

Creating the backup file is only the first step.

The backup file was checked using:

sudo test -s /var/backups/mysql-day11/all-databases.sql && echo "BACKUP FILE IS NOT EMPTY"

Expected result:

BACKUP FILE IS NOT EMPTY
What does test -s mean?

The -s condition checks whether the file exists and has a size greater than zero.

Conceptually:

File exists?
     │
     ├── No → Backup invalid
     │
     └── Yes
          │
          ▼
     File has data?
          │
          ├── No → Backup invalid
          │
          └── Yes → Continue validation

This is a basic validation check.

It does not prove that every SQL statement inside the backup is valid.

That is why restore testing is important.

8. Restore Testing

A restore test was performed using a dedicated test database:

day11_restore_test

The database was created with:

sudo mysql -e "CREATE DATABASE IF NOT EXISTS day11_restore_test;"

The database can then be verified using:

sudo mysql -e "SHOW DATABASES;"

Expected output includes:

day11_restore_test
9. Why Use a Restore-Test Database?

A dedicated restore-test database provides an isolated environment.

Instead of immediately overwriting production databases:

Production Database
        │
        └── Dangerous direct restore

we use:

Backup
  │
  ▼
Restore Test
  │
  ▼
Validation

This reduces operational risk during practice.

10. Restore Concept

A SQL dump is restored by feeding the SQL file back into MySQL.

General syntax:

mysql < backup.sql

For an administrative restore:

sudo mysql < /var/backups/mysql-day11/all-databases.sql

A restore process essentially performs the reverse operation:

Database
   │
   │ mysqldump
   ▼
SQL Backup
   │
   │ mysql restore
   ▼
Database
11. Backup Integrity Levels

Backup validation can be considered in multiple levels.

Level 1 – File Exists
ls -lh /var/backups/mysql-day11/all-databases.sql

Confirms that the expected file exists.

Level 2 – File Is Not Empty
sudo test -s /var/backups/mysql-day11/all-databases.sql

Confirms that the file contains data.

Level 3 – Inspect Backup Contents

Example:

sudo head -n 30 /var/backups/mysql-day11/all-databases.sql

This allows the SQL dump structure to be inspected.

Level 4 – Restore Test

Restore the backup into a safe environment.

This is substantially stronger evidence that the backup is usable.

12. Backup vs Restore

These two operations solve different problems.

Backup

Protects data by creating a recovery copy.

MySQL
  ↓
mysqldump
  ↓
SQL file
Restore

Uses the recovery copy to recreate database state.

SQL file
  ↓
mysql
  ↓
Database

Both operations must be tested.

13. RPO – Recovery Point Objective

RPO answers:

How much data can the organization afford to lose?

Example:

Backup every 24 hours

Potential maximum data-loss window:

≈ 24 hours

If backups are taken every hour:

Potential data-loss window
≈ 1 hour

Lower RPO generally requires more frequent backups or replication.

14. RTO – Recovery Time Objective

RTO answers:

How quickly must the service be restored?

Example:

RTO = 30 minutes

The recovery process should be designed and tested so that the service can be restored within the required timeframe.

Backup alone does not guarantee a particular RTO.

Restore speed depends on:

database size
disk performance
network
CPU
backup format
database configuration
recovery procedure
15. Production Backup Architecture

A simplified production design:

                 ┌───────────────────┐
                 │   MySQL Server    │
                 └─────────┬─────────┘
                           │
                           ▼
                    Backup Process
                           │
                           ▼
                 ┌───────────────────┐
                 │ Backup Repository │
                 └─────────┬─────────┘
                           │
                           ▼
                    Off-site Copy
                           │
                           ▼
                 Disaster Recovery

A production environment should generally avoid relying on only one backup copy on the same server.

16. 3-2-1 Backup Principle

A commonly used backup strategy is the 3-2-1 rule:

3 copies of data
2 different storage/media types
1 copy off-site

For example:

Primary Database
       │
       ├── Local Backup
       │
       └── Remote Backup

The exact implementation depends on organizational requirements.

17. Backup Security

Database backups can contain sensitive application information.

Therefore, backups should be protected using:

restrictive filesystem permissions
encryption where required
secure storage
controlled access
retention policies
audit logging

A backup should never be treated as harmless just because it is not the live database.

18. Backup Retention

A production backup strategy should define how long backups are retained.

Example:

Daily backups   → 7 days
Weekly backups  → 4 weeks
Monthly backups → 12 months

Actual retention depends on:

business requirements
compliance
storage cost
recovery requirements
19. Common Backup Mistakes
Mistake 1 – Backup Created but Never Tested
Backup exists
     ↓
Nobody tested restore
     ↓
Production incident
     ↓
Restore fails

A backup that cannot be restored is a major operational risk.

Mistake 2 – Backup Stored on Same Disk

If both database and backup are stored on the same failed disk:

Disk Failure
    │
    ├── Database lost
    └── Backup lost

Separate storage is safer.

Mistake 3 – Forgetting Database Objects

A backup may need more than table data.

Depending on the application, important objects can include:

stored procedures
functions
events
triggers
users/privileges
application configuration

The backup strategy must match the application requirements.

Mistake 4 – No Monitoring

A backup job can silently fail.

Production systems should monitor:

backup completion
backup size
backup age
exit status
storage availability
restore-test results
20. Operational Verification Checklist

A good backup workflow verifies:

[1] Backup directory exists
[2] Backup command completes
[3] Backup file exists
[4] Backup file is not empty
[5] Backup size is reasonable
[6] Backup contents can be inspected
[7] Restore environment exists
[8] Restore succeeds
[9] Restored database can be queried
[10] Backup process is documented
21. Day 11 Outcome

By the end of Day 11, the workflow became:

MySQL
  │
  ▼
mysqldump
  │
  ├── all databases
  ├── transactions
  ├── routines
  └── events
  │
  ▼
/var/backups/mysql-day11/all-databases.sql
  │
  ▼
File validation
  │
  ▼
Restore test
  │
  ▼
Database verification

The key lesson is:

Backup creation is only half of database recovery engineering. The restore must also be verified.

22. Interview Takeaway
Q: Why use --single-transaction?

For transactional engines such as InnoDB, it allows mysqldump to obtain a consistent snapshot while minimizing the need for table locking.

Q: Why use --routines?

To include stored procedures and functions in the logical backup.

Q: Why use --events?

To include MySQL Event Scheduler events.

Q: Is a non-empty SQL file enough to prove the backup works?

No.

A non-empty file only proves that data was written. A restore test provides much stronger validation.

Q: What is RPO?

The maximum acceptable amount of data loss measured in time.

Q: What is RTO?

The target maximum time required to restore service after a failure.

Q: What is the most important backup lesson?

Untested backups should not be considered reliable backups.