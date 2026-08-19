Lab 13 — Linux Storage Shell Automation

1. Lab Overview

This lab implements a Bash-based storage health-check workflow on a fresh
Azure Linux VM.

The purpose is to demonstrate how a DevOps engineer can convert repetitive
Linux storage checks into a repeatable operational script with:

filesystem validation;

mount validation;

capacity checks;

inode checks;

workload validation;

logging;

failure detection;

exit codes;

recovery verification.

This lab uses a direct partition + ext4 filesystem architecture.

No LVM was created on this VM. There is intentionally no PV, VG, or LV in
this Day 13 environment.

2. Architecture

Azure Linux VM
      |
      +-------------------- Root Disk --------------------+
      |                                                    |
      |                                               /dev/nvme0n1
      |                                                    |
      |                                                    +-- /
      |
      +-------------------- Data Disk --------------------+
                                                           |
                                                      /dev/nvme0n2
                                                           |
                                                           v
                                                     nvme0n2p1
                                                           |
                                                           v
                                                        ext4
                                                           |
                                                           v
                                                         /data
                                                           |
                                     +---------------------+-------------------+
                                     |                                         |
                              day13-test/                              health automation
                                     |                                         |
                                  test.txt                         storage-health.sh
                                                                               |
                                                                               v
                                                                  logs/storage-health.log

3. Prerequisites

Azure Linux VM;

sudo access;

Bash;

parted;

e2fsprogs/mkfs.ext4;

findmnt;

df;

lsblk;

a separate data disk.

The data disk must be identified carefully before any partitioning command is
executed.

4. Step 1 — Create Working Directory

mkdir -p ~/day13-shell-automation
cd ~/day13-shell-automation

Verify:

pwd

Expected:

/home/azureuser/day13-shell-automation

Screenshot

Capture the working directory and initial shell environment.

Suggested filename:

shell-environment.png

5. Step 2 — Identify Storage

Run:

lsblk

and:

df -hT

and:

findmnt

and:

lsblk -f

The additional data disk was identified as:

/dev/nvme0n2

The root disk was:

/dev/nvme0n1

Important safety rule

Never assume nvme0n2 is always the data disk on every VM.

Always verify:

lsblk

before running destructive commands such as:

mkfs
parted mklabel

6. Step 3 — Verify No LVM Is Being Used

The new VM was intentionally checked for LVM:

sudo pvs
sudo vgs
sudo lvs

No PV/VG/LV storage architecture was required for this lab.

This confirms the intended design:

Disk
  |
Partition
  |
Filesystem
  |
Mount

rather than:

Disk
  |
PV
  |
VG
  |
LV
  |
Filesystem
  |
Mount

7. Step 4 — Partition the Data Disk

Create GPT:

sudo parted -s /dev/nvme0n2 mklabel gpt

Create a full-disk partition:

sudo parted -s /dev/nvme0n2 mkpart primary ext4 0% 100%

Verify:

lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS

Expected:

nvme0n2
└─nvme0n2p1  15.9G  part

8. Step 5 — Create ext4 Filesystem

sudo mkfs.ext4 /dev/nvme0n2p1

Verify:

lsblk -f

and:

sudo blkid /dev/nvme0n2p1

Filesystem UUID used in this lab:

8c540652-faa1-42c8-8437-ca5239a1d0ed

Screenshot

Suggested filename:

disk_partion + file_syatem.png

9. Step 6 — Mount /data

Create mount point:

sudo mkdir -p /data

Mount:

sudo mount /dev/nvme0n2p1 /data

Verify:

findmnt /data

df -hT /data

lsblk -f

Expected:

/data -> /dev/nvme0n2p1 -> ext4

Screenshot

Suggested filename:

storage_ mounrted + fstab-validation.png

10. Step 7 — Configure Persistent Mount

Edit:

sudo nano /etc/fstab

Add:

UUID=8c540652-faa1-42c8-8437-ca5239a1d0ed /data ext4 defaults,nofail 0 2

Reload systemd:

sudo systemctl daemon-reload

Test persistence configuration:

sudo umount /data
sudo mount -a

Validate:

grep -n '/data' /etc/fstab
findmnt /data
df -hT /data
lsblk -f

Screenshot

Suggested filename:

fstab-validation.png

11. Step 8 — Create Test Workload

Create directory:

sudo mkdir -p /data/day13-test

Give the lab user ownership:

sudo chown -R azureuser:azureuser /data/day13-test

Create test file:

echo "Day 13 storage automation test" > /data/day13-test/test.txt

Verify:

ls -lah /data/day13-test

cat /data/day13-test/test.txt

The file is used as a lightweight workload probe.

12. Step 9 — Create Storage Health Script

The script performs these checks:

1. /data directory exists
2. /data is mounted
3. filesystem/device information exists
4. disk utilization is healthy
5. inode utilization is healthy
6. expected test workload exists
7. final PASS/FAIL summary is produced
8. operational log is written
9. appropriate exit status is returned

The script is executed with:

./storage-health.sh

Before execution, validate syntax:

bash -n storage-health.sh
echo $?

Expected:

0

Then:

chmod +x storage-health.sh

Verify:

ls -l storage-health.sh

13. Step 10 — Successful Health Check

Run:

./storage-health.sh

The successful execution produced:

PASS CHECKS : 6
FAIL CHECKS : 0
RESULT      : HEALTHY

Validate exit code:

echo "Exit Code: $?"

Expected:

Exit Code: 0

Interpretation

0 = successful health validation

This allows external automation to determine whether the check succeeded.

Screenshot

Suggested filename:

health-check-pass.png

14. Step 11 — Verify Logs

Inspect:

ls -lah logs/

Then:

cat logs/storage-health.log

Recent entries:

tail -20 logs/storage-health.log

The log records timestamped operational events such as:

PASS | /data directory exists
PASS | /data is mounted
PASS | Filesystem information detected
PASS | Disk usage is healthy
PASS | Inode usage is healthy
PASS | Test workload exists
RESULT | HEALTHY

Screenshot

Suggested filename:

health-check-log.png

15. Step 12 — Failure Simulation

Remove the test workload:

rm /data/day13-test/test.txt

Verify:

ls -lah /data/day13-test

Run the health check:

./storage-health.sh

Then:

echo "Exit Code: $?"

Expected logical result:

PASS CHECKS : 5
FAIL CHECKS : 1
RESULT      : FAILED
Exit Code: 1

The important failure is:

FAIL | Test workload missing

This proves that the script detects a real state change.

Screenshot

Suggested filename:

health-check-failure.png

16. Step 13 — Recovery

Restore the expected workload:

echo "Day 13 storage automation test" > /data/day13-test/test.txt

Verify:

ls -lah /data/day13-test
cat /data/day13-test/test.txt

Run:

./storage-health.sh

Then:

echo "Exit Code: $?"

Expected:

PASS CHECKS : 6
FAIL CHECKS : 0
RESULT      : HEALTHY
Exit Code: 0

Screenshot

Suggested filename:

health-check-recovery.png

17. Test Matrix

Test

Expected Result

Status

Data disk identified

/dev/nvme0n2

PASS

Partition created

/dev/nvme0n2p1

PASS

ext4 filesystem created

ext4 detected

PASS

/data mounted

mounted

PASS

fstab configured

UUID entry present

PASS

mount -a validation

successful

PASS

Test workload created

test.txt exists

PASS

Script syntax check

exit 0

PASS

Health check

HEALTHY

PASS

Log generated

log file exists

PASS

Test workload removed

failure simulated

PASS

Failure detected

FAILED / exit 1

PASS

Workload restored

recovery

PASS

Final health check

HEALTHY / exit 0

PASS

18. What This Lab Demonstrates

The lab demonstrates the complete automation feedback loop:

Storage State
     |
     v
Health Check
     |
     +---- PASS ----> Exit 0
     |
     +---- FAIL ----> Exit 1
     |
     v
Log Result
     |
     v
Operator / Automation

More importantly:

Manual Commands
      |
      v
Bash Automation
      |
      v
Repeatable Validation
      |
      v
Failure Detection
      |
      v
Recovery Verification

19. Operational Lessons

Lesson 1 — A mounted directory is not enough

Checking only:

mountpoint /data

does not prove the expected workload is available.

The lab therefore also validates:

/data/day13-test/test.txt

Lesson 2 — Exit codes matter

Human-readable output is useful for operators, but automation should be able
to consume:

0 = success
1 = failure

Lesson 3 — Logs provide operational evidence

A script should leave enough information to understand what happened after
execution.

Lesson 4 — Failure testing is mandatory

A script that only passes healthy tests has not been fully validated.

The deliberate deletion of test.txt proved that the failure path works.

Lesson 5 — Recovery testing completes the lifecycle

The final recovery test proved:

Healthy -> Failure -> Detection -> Recovery -> Healthy

20. Repository Mapping

The Day 13 lab belongs to:

labs/lab13-shell-scripting/

Screenshots belong to:

screenshots/lab13/

The reusable repository automation script should ultimately belong under:

scripts/

The Day 13 conceptual documentation belongs to:

docs/11-shell-automation.md

The repository already contains a scripts/disk-health.sh placeholder. The
final repository implementation should use a single clearly defined
storage-health responsibility rather than maintaining duplicate scripts for
the same purpose.

21. Screenshot Evidence

Current evidence covers:

shell-environment.png
disk_partion + file_syatem.png
storage_ mounrted + fstab-validation.png
fstab-validation.png
health-check-pass.png
health-check-log.png
health-check-failure.png
health-check-recovery.png

These screenshots demonstrate the complete lab progression from environment
preparation through failure and recovery.

22. Completion Criteria

Day 13 core lab is considered complete when all of the following are true:

Working directory created

Data disk identified

GPT partition created

ext4 filesystem created

/data mount point created

Filesystem mounted

UUID identified

/etc/fstab configured

mount -a validated

Test workload created

Bash health-check script created

Bash syntax validated

Script executable

Healthy execution verified

Log generation verified

Failure simulated

Failure detected

Exit code verified

Workload restored

Recovery verified

Final HEALTHY state verified

Screenshot evidence captured

23. Final Result

The completed Day 13 implementation successfully demonstrates storage
health automation on a directly partitioned Azure Linux data disk.

Final healthy state:

PASS CHECKS : 6
FAIL CHECKS : 0
RESULT      : HEALTHY
Exit Code   : 0

Failure test:

PASS CHECKS : 5
FAIL CHECKS : 1
RESULT      : FAILED
Exit Code   : 1

Recovery:

PASS CHECKS : 6
FAIL CHECKS : 0
RESULT      : HEALTHY
Exit Code   : 0

This completes the core Day 13 Shell Scripting / Storage Automation lab.

Advanced production extensions such as configurable thresholds, multiple mount
points, JSON output, flock, scheduled execution, ShellCheck integration and
alerting can be treated as future enhancements rather than prerequisites for
the completed core lab.