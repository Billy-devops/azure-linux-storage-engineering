Linux Shell Automation for Storage Engineering

1. Overview

This document covers the Day 13 shell-automation implementation for the
azure-linux-storage-engineering project.

The objective is to move from manually executing storage-validation commands
to a repeatable Bash health-check workflow that can be executed, logged,
validated, tested for failure, and verified after recovery.

The implementation uses a new Azure Linux VM with a directly partitioned
managed data disk. This lab intentionally does not use LVM because the
VM for this exercise was configured with a normal partition + filesystem
layout.

Final storage architecture

Azure Managed Data Disk
        |
        v
/dev/nvme0n2
        |
        v
/dev/nvme0n2p1
        |
        v
ext4 filesystem
        |
        v
/data
        |
        +---- /data/day13-test/test.txt
        |
        +---- storage-health.sh validation
        |
        +---- logs/storage-health.log

2. Learning Objectives

By completing this lab, the engineer should be able to:

identify Linux block devices;

identify partitions and filesystems;

create a GPT partition table;

create an ext4 filesystem;

mount a filesystem;

configure persistent mounting through /etc/fstab;

validate a mount using findmnt, df, and lsblk;

write a Bash storage-health script;

validate Bash syntax with bash -n;

make a script executable;

capture storage health information;

implement PASS/FAIL checks;

implement script exit codes;

generate operational logs;

simulate a controlled failure;

verify recovery;

understand how shell automation can become the foundation for
production monitoring.

3. Environment

VM

The lab was executed on a fresh Azure Linux VM.

The important point is that this VM did not contain the LVM structure used
in earlier labs.

The storage layout was:

Root disk:
  /dev/nvme0n1
      |
      +-- /dev/nvme0n1p1 -> /
      +-- /dev/nvme0n1p15 -> /boot/efi
      +-- /dev/nvme0n1p16 -> /boot

Data disk:
  /dev/nvme0n2
      |
      +-- /dev/nvme0n2p1 -> /data

Important design decision

No:

pvcreate

vgcreate

lvcreate

operations were performed in this Day 13 environment.

The data disk uses:

Disk -> Partition -> ext4 -> Mount point

rather than:

Disk -> Partition/PV -> VG -> LV -> Filesystem -> Mount point

This distinction is important when documenting Linux storage architecture.

4. Lab Directory

The working directory on the VM was:

~/day13-shell-automation

The main script was:

storage-health.sh

The runtime log directory was:

logs/

with:

logs/storage-health.log

5. Storage Preparation

5.1 Identify the disk

The available block devices were checked using:

lsblk

The additional 16 GiB data disk appeared as:

nvme0n2

Before partitioning, it had no filesystem or mount point.

5.2 Create GPT partition table

The disk was initialized with GPT:

sudo parted -s /dev/nvme0n2 mklabel gpt

A partition covering the disk was then created:

sudo parted -s /dev/nvme0n2 mkpart primary ext4 0% 100%

Verification:

lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS

Expected structure:

nvme0n2
└─nvme0n2p1  15.9G  part

5.3 Create ext4 filesystem

The partition was formatted:

sudo mkfs.ext4 /dev/nvme0n2p1

Filesystem identity was verified:

lsblk -f

and:

sudo blkid /dev/nvme0n2p1

The resulting UUID was:

8c540652-faa1-42c8-8437-ca5239a1d0ed

The UUID is important because /etc/fstab should preferably identify a
filesystem by UUID instead of depending on a potentially changing device
name.

6. Mount the Data Filesystem

The mount point was created:

sudo mkdir -p /data

The filesystem was initially mounted manually:

sudo mount /dev/nvme0n2p1 /data

Validation:

findmnt /data
df -hT /data
lsblk -f

Expected result:

/data -> /dev/nvme0n2p1 -> ext4

The filesystem was approximately 16 GiB with very low initial utilization.

7. Persistent Mount with fstab

The filesystem was added to /etc/fstab using its UUID:

UUID=8c540652-faa1-42c8-8437-ca5239a1d0ed /data ext4 defaults,nofail 0 2

The configuration was validated by reloading systemd:

sudo systemctl daemon-reload

Then:

sudo umount /data
sudo mount -a

Final validation:

grep -n '/data' /etc/fstab
findmnt /data
df -hT /data
lsblk -f

Why nofail?

nofail prevents a missing/non-available data disk from unnecessarily
blocking normal system boot.

For production systems, mount options should always be selected according to
the workload and availability requirements.

8. Test Workload

A small test workload was created:

sudo mkdir -p /data/day13-test
sudo chown -R azureuser:azureuser /data/day13-test

Test data:

echo "Day 13 storage automation test" > /data/day13-test/test.txt

Validation:

ls -lah /data/day13-test
cat /data/day13-test/test.txt

This file is intentionally used by the health-check script as an application
storage validation point.

The test is more meaningful than checking only whether /data exists because
a storage path can exist while the expected workload data is missing.

9. Storage Health Automation

9.1 Script purpose

The storage-health.sh script converts several manual checks into one
repeatable operation.

The script validates:

/data directory existence;

/data mount status;

filesystem/device information;

disk capacity usage;

inode usage;

expected test workload existence;

overall health result;

operational logging;

exit status.

9.2 Syntax validation

Before executing the script:

bash -n storage-health.sh

Then:

echo $?

Expected:

0

An exit code of 0 from bash -n means no Bash syntax error was detected.

This is a static syntax check; it does not prove that the script's logic is
correct. Functional execution is required as well.

9.3 Make the script executable

chmod +x storage-health.sh

Verification:

ls -l storage-health.sh

The executable permission should be visible in the mode string.

10. Functional Health Check

The script was executed:

./storage-health.sh

A successful run produced the following logical result:

PASS CHECKS : 6
FAIL CHECKS : 0
RESULT      : HEALTHY

The checks included:

/data directory exists
/data is mounted
Filesystem information detected
Disk usage is healthy
Inode usage is healthy
Test workload exists

The final successful execution returned:

Exit Code: 0

This is important because automation systems should be able to consume both
human-readable output and the process exit status.

11. Operational Logging

The script generated:

logs/storage-health.log

The log was inspected using:

ls -lah logs/

and:

cat logs/storage-health.log

Recent entries were also checked using:

tail -20 logs/storage-health.log

The log recorded:

timestamp
PASS/FAIL state
check description
overall RESULT

Example logical sequence:

START
PASS /data directory
PASS /data mounted
PASS filesystem
PASS disk usage
PASS inode usage
PASS test workload
RESULT HEALTHY

This creates a basic audit trail for the automation.

12. Failure Simulation

A controlled failure was deliberately introduced by removing the expected
test workload:

rm /data/day13-test/test.txt

The directory was checked:

ls -lah /data/day13-test

The health script was then executed:

./storage-health.sh
echo "Exit Code: $?"

The script correctly detected:

FAIL | Test workload missing

and reported:

PASS CHECKS : 5
FAIL CHECKS : 1
RESULT      : FAILED
Exit Code: 1

This proves that the script is not simply printing a hard-coded HEALTHY
message. It can detect an actual change in the monitored state.

13. Recovery Validation

The expected workload was recreated:

echo "Day 13 storage automation test" > /data/day13-test/test.txt

Validation:

ls -lah /data/day13-test
cat /data/day13-test/test.txt

The script was executed again:

./storage-health.sh
echo "Exit Code: $?"

The recovery result was:

PASS CHECKS : 6
FAIL CHECKS : 0
RESULT      : HEALTHY
Exit Code: 0

This establishes the complete operational test cycle:

HEALTHY
   |
   v
Failure introduced
   |
   v
FAILED
   |
   v
Workload restored
   |
   v
HEALTHY

14. Exit Code Design

The current implementation uses:

0 -> HEALTHY
1 -> FAILED

The value of exit codes is that shell automation, cron, CI/CD systems, and
monitoring tools can consume them without parsing human-readable output.

For example:

./storage-health.sh
status=$?

if [ "$status" -eq 0 ]; then
    echo "Storage healthy"
else
    echo "Storage check failed"
fi

This is a fundamental DevOps automation pattern.

15. Why Automation Is Better Than Manual Checking

Without automation, an operator might execute:

findmnt /data
df -hT /data
df -ih /data
lsblk -f
ls -lah /data/day13-test

every time a storage check is required.

With the health script:

./storage-health.sh

one command performs the defined validation workflow.

Benefits:

repeatability;

reduced human error;

consistent output;

logging;

machine-readable exit status;

easier troubleshooting;

easy integration with scheduled jobs;

foundation for monitoring/alerting.

16. Current Scope and Limitations

The completed Day 13 implementation is intentionally focused on a direct
partitioned filesystem.

It does not currently implement:

LVM management;

automatic disk expansion;

filesystem resizing;

MySQL health checks;

Nginx health checks;

alert delivery;

email/Teams/Slack notifications;

JSON output;

multi-mount command-line arguments;

concurrency locking;

systemd timer deployment.

These belong to later automation improvements or production extensions and
should not be confused with the completed core Day 13 lab.

17. Production Improvements

A production-grade evolution of this script could add:

--mount /data
--warning 80
--critical 90
--json
--help

Additional improvements:

shellcheck validation;

dependency validation;

configurable thresholds;

multiple mount point support;

JSON output;

flock concurrency protection;

systemd timer/cron scheduling;

structured log format;

alert integration;

monitoring-system integration.

These are natural next steps, but the current lab already demonstrates the
core automation lifecycle.

18. Troubleshooting Lessons

Script reports FAILED unexpectedly

Check:

ls -lah /data/day13-test

The expected workload file must exist.

/data is not mounted

Check:

findmnt /data

Then:

grep -n '/data' /etc/fstab

and:

sudo mount -a

fstab changes appear not to be reflected

Reload systemd:

sudo systemctl daemon-reload

Then validate again:

sudo umount /data
sudo mount -a
findmnt /data

Script is not executable

Use:

chmod +x storage-health.sh

Bash syntax validation fails

Run:

bash -n storage-health.sh

The reported line number should be investigated before functional execution.

19. Evidence Collected

The Day 13 lab includes screenshots covering:

shell environment;

disk partition and filesystem creation;

storage mounted and fstab validation;

fstab final validation;

successful health check;

health-check log;

controlled health-check failure;

successful recovery.

Recommended screenshot mapping:

shell-environment.png
disk_partion + file_syatem.png
storage_ mounrted + fstab-validation.png
fstab-validation.png
health-check-pass.png
health-check-log.png
health-check-failure.png
health-check-recovery.png

20. Key DevOps Concepts Demonstrated

This lab demonstrates the progression:

Manual Operations
      |
      v
Repeatable Commands
      |
      v
Bash Script
      |
      v
Validation
      |
      v
Logging
      |
      v
Failure Detection
      |
      v
Exit Codes
      |
      v
Recovery Verification
      |
      v
Automation Foundation

The important engineering lesson is that automation is not merely writing a
script. A useful operational script must also be validated, tested under
failure, produce meaningful status information, and support recovery
verification.

21. Final Outcome

Day 13 core shell-automation lab is complete.

Final verified state:

Data disk                 PASS
Partition                 PASS
ext4 filesystem           PASS
/data mount               PASS
Persistent fstab mount    PASS
Test workload             PASS
Health script             PASS
Syntax validation         PASS
Logging                   PASS
Failure simulation        PASS
Failure detection         PASS
Recovery                  PASS
Exit code validation      PASS

Final healthy state:

PASS CHECKS : 6
FAIL CHECKS : 0
RESULT      : HEALTHY
Exit Code   : 0

The project can now move from the completed Day 13 lab implementation toward
repository cleanup, documentation finalization, Git commit/PR preparation,
and the final production-storage lab.