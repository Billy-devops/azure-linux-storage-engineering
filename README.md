# Azure Linux Storage Engineering

> **Production-oriented Linux Storage Engineering project on Microsoft Azure**
>
> A hands-on, day-by-day learning and implementation repository covering Linux storage fundamentals, Azure Managed Disks, partitioning, filesystems, mounting, persistent storage, LVM, live volume expansion, Nginx storage, MySQL storage, backup & restore, monitoring, shell automation, troubleshooting, and production storage practices.

---

## 📌 Project Overview

**Azure Linux Storage Engineering** is a practical DevOps/Linux infrastructure project designed to build strong real-world skills in **Linux storage administration and Azure infrastructure operations**.

The project progresses from basic block-device concepts to production-style storage management and automation.

Instead of only learning commands theoretically, every major topic is implemented through:

* 📚 Technical documentation
* 🧪 Hands-on labs
* 🖥️ Azure Linux VM implementation
* 📸 Validation screenshots
* ⚙️ Shell automation
* 🔍 Monitoring and troubleshooting
* 🏗️ Production-oriented storage design

The goal is to understand not just **how to create storage**, but also:

> **How to identify, provision, mount, persist, monitor, expand, protect, troubleshoot, and automate Linux storage in a production environment.**

---

# 🎯 Project Objectives

This project focuses on developing practical expertise in:

* Linux block devices
* Azure Managed Disks
* Disk identification
* Partitioning
* Filesystem management
* Mounting and unmounting
* `/etc/fstab`
* Persistent storage
* LVM
* Physical Volumes
* Volume Groups
* Logical Volumes
* Online filesystem expansion
* Application-specific storage
* Nginx storage
* MySQL storage
* Database backup and restore
* Storage monitoring
* Disk health checks
* Shell scripting
* Idempotent automation
* Storage troubleshooting
* Production storage architecture

---

# 🏗️ Project Architecture

The project follows a progressive storage engineering architecture:

```text
                    ┌──────────────────────────────┐
                    │        Microsoft Azure       │
                    │                              │
                    │        Linux Virtual VM      │
                    └──────────────┬───────────────┘
                                   │
                         Azure Managed Disk
                                   │
                                   ▼
                        ┌──────────────────┐
                        │ Block Device     │
                        │ /dev/nvme*       │
                        └────────┬─────────┘
                                 │
                         Partitioning
                                 │
                                 ▼
                        ┌──────────────────┐
                        │ Filesystem       │
                        │ ext4             │
                        └────────┬─────────┘
                                 │
                              Mount
                                 │
                                 ▼
                        ┌──────────────────┐
                        │ Linux Mountpoint │
                        │ /data/...        │
                        └────────┬─────────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
                    ▼                         ▼
              Application                 Database
                Storage                    Storage
                    │                         │
                  Nginx                    MySQL
                    │                         │
                    └────────────┬────────────┘
                                 │
                                 ▼
                         Backup & Restore
                                 │
                                 ▼
                           Monitoring
                                 │
                                 ▼
                         Shell Automation
```

---

# 🗂️ Repository Structure

```text
azure-linux-storage-engineering/
│
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   └── lab-task.md
│   ├── workflows/
│   └── PULL_REQUEST_TEMPLATE.md
│
├── assets/
│   ├── banner.png
│   ├── linkedin-cover.png
│   └── repo-cover.png
│
├── cheatsheets/
│   ├── azure-managed-disk-cheatsheet.md
│   ├── commands.md
│   ├── linux-storage-cheatsheet.md
│   └── lvm-cheatsheet.md
│
├── diagrams/
│   ├── azure-storage.drawio
│   ├── azure-storage.png
│   ├── backup-flow.png
│   ├── lvm.drawio
│   ├── lvm.png
│   ├── production-storage.png
│   └── production.drawio
│
├── docs/
│   ├── 01-storage-fundamentals.md
│   ├── 02-azure-managed-disks.md
│   ├── 03-disk-partitioning.md
│   ├── 04-filesystems.md
│   ├── 05-mounting-volumes.md
│   ├── 06-persistent-mount-fstab.md
│   ├── 07-lvm.md
│   ├── 08-live-volume-expansion.md
│   ├── 09-backup-restore.md
│   ├── 10-storage-monitoring.md
│   ├── 11-shell-automation.md
│   ├── 12-production-best-practices.md
│   ├── 13-troubleshooting.md
│   └── 14-interview-questions.md
│
├── labs/
│   ├── lab01-storage-basics/
│   ├── lab02-managed-disk/
│   ├── lab03-partitioning/
│   ├── lab04-filesystem/
│   ├── lab05-mounting/
│   ├── lab06-fstab/
│   ├── lab07-lvm/
│   ├── lab08-live-expansion/
│   ├── lab09-nginx-storage/
│   ├── lab10-mysql-storage/
│   ├── lab11-backup-restore/
│   ├── lab12-monitoring/
│   ├── lab13-shell-scripting/
│   └── final-production-lab/
│
├── screenshots/
│   ├── lab01/
│   ├── lab02/
│   ├── lab03/
│   ├── lab04/
│   ├── lab05/
│   ├── lab06/
│   ├── lab07/
│   ├── lab08/
│   ├── lab09/
│   ├── lab10/
│   ├── lab11/
│   ├── lab12/
│   ├── lab13/
│   └── final/
│
├── scripts/
│   ├── backup.sh
│   ├── cleanup.sh
│   ├── disk-health.sh
│   ├── monitoring.sh
│   ├── mount.sh
│   ├── resize-lvm.sh
│   └── restore.sh
│
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
├── README.md
└── ROADMAP.md
```

---

# 📚 Learning Roadmap

The project is divided into progressive stages.

## Phase 1 — Linux Storage Fundamentals

### Day 01 — Storage Fundamentals

Covered:

* Block devices
* `/dev`
* `lsblk`
* `blkid`
* `df`
* `du`
* Filesystem vs block device
* Mountpoints
* Disk identification

---

## Day 02 — Azure Managed Disks

Covered:

* Azure Managed Disks
* OS disks
* Data disks
* Disk attachment
* Disk identification inside Linux
* Azure → Linux storage relationship

---

## Day 03 — Disk Partitioning

Covered:

* Partition tables
* GPT
* `fdisk`
* `parted`
* Partition creation
* Partition verification
* Device naming

---

## Day 04 — Filesystems

Covered:

* ext4
* `mkfs`
* Filesystem creation
* Filesystem identification
* Mount/unmount operations
* Filesystem validation

---

## Day 05 — Mounting Volumes

Covered:

* Manual mounting
* Mountpoints
* `mount`
* `umount`
* `findmnt`
* Mount validation
* Storage organization

---

## Day 06 — Persistent Mounting with `/etc/fstab`

Covered:

* `/etc/fstab`
* UUID-based mounting
* Persistent storage
* `mount -a`
* Boot-time mounting
* Configuration validation
* Safe fstab changes

---

## Day 07 — LVM

Covered:

* Physical Volumes
* Volume Groups
* Logical Volumes
* `pvcreate`
* `vgcreate`
* `lvcreate`
* `pvs`
* `vgs`
* `lvs`
* LVM mount architecture

---

## Day 08 — Live Volume Expansion

Covered:

* Increasing storage capacity
* Extending Volume Groups
* Extending Logical Volumes
* Filesystem expansion
* Online expansion
* Capacity verification
* Safe resize workflow

---

# 🚀 Application Storage

## Day 09 — Nginx Storage

A real application storage scenario was implemented using Nginx.

Focus areas:

* Application storage
* Nginx configuration
* Dedicated storage locations
* Access logs
* Error logs
* Application data
* Storage mounts
* Service validation
* HTTP validation

---

# 🗄️ Database Storage

## Day 10 — MySQL Storage

A dedicated storage architecture was implemented for MySQL.

The lab covers:

* Azure data disk
* Linux partitioning
* ext4 filesystem
* Persistent mount
* MySQL installation
* MySQL data directory migration
* `datadir` configuration
* Data synchronization
* MySQL service validation
* Database creation
* Storage verification

Example architecture:

```text
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
MySQL datadir
```

---

# 🔐 Backup & Restore

## Day 11 — MySQL Backup & Restore

This stage introduces database protection and recovery concepts.

Covered:

* Full database backup
* `mysqldump`
* Backup validation
* Restore testing
* Restore verification
* Failure simulation
* Recovery validation
* Backup storage organization

Example:

```text
MySQL
  │
  ▼
mysqldump
  │
  ▼
SQL Backup
  │
  ▼
Backup Storage
  │
  ▼
Restore Test
  │
  ▼
Database Validation
```

---

# 📊 Monitoring

## Day 12 — Storage Monitoring

Monitoring was implemented at the filesystem, disk, system, and MySQL levels.

Covered:

* Filesystem capacity
* Inode usage
* Disk I/O
* Storage utilization
* `/var` analysis
* `/var/lib` analysis
* Journal usage
* MySQL storage breakdown
* MySQL health
* Memory
* Load
* Processes
* InnoDB redo information

Important commands include:

```bash
df -hT
df -ih
du -xhd1
lsblk
findmnt
iostat
free -h
uptime
ps
systemctl status mysql
```

---

# ⚙️ Shell Automation

## Day 13 — Storage Automation

The project moves from manual administration to reusable shell automation.

Automation scripts include:

```text
scripts/
├── backup.sh
├── cleanup.sh
├── disk-health.sh
├── monitoring.sh
├── mount.sh
├── resize-lvm.sh
└── restore.sh
```

The scripts focus on:

* Input validation
* Error handling
* Exit codes
* Logging
* Safety checks
* Idempotency
* Failure handling
* Recovery validation
* Storage health checks
* Backup automation
* Cleanup automation
* Mount automation
* LVM resize safety

---

# 🏭 Final Production Storage Lab

The final lab combines the concepts learned throughout the project into a production-oriented storage workflow.

The final architecture brings together:

```text
                Azure
                  │
                  ▼
          Managed Data Disk
                  │
                  ▼
             Linux VM
                  │
          ┌───────┴────────┐
          │                │
          ▼                ▼
      Application        Database
       Storage            Storage
          │                │
        Nginx            MySQL
          │                │
          └───────┬────────┘
                  │
                  ▼
             Monitoring
                  │
                  ▼
          Backup & Restore
                  │
                  ▼
        Shell Automation
                  │
                  ▼
       Health & Recovery
```

---

# 🧪 Labs

Every major topic has a dedicated hands-on lab.

| Lab       | Topic                       |
| --------- | --------------------------- |
| Lab 01    | Storage Basics              |
| Lab 02    | Azure Managed Disk          |
| Lab 03    | Disk Partitioning           |
| Lab 04    | Filesystem                  |
| Lab 05    | Mounting                    |
| Lab 06    | Persistent Mount with fstab |
| Lab 07    | LVM                         |
| Lab 08    | Live Volume Expansion       |
| Lab 09    | Nginx Storage               |
| Lab 10    | MySQL Storage               |
| Lab 11    | Backup & Restore            |
| Lab 12    | Storage Monitoring          |
| Lab 13    | Shell Scripting             |
| Final Lab | Production Storage          |

Each lab contains its own `README.md` with implementation steps, commands, validation, expected results, troubleshooting information, and practical notes.

---

# 📸 Evidence & Screenshots

The repository maintains screenshots for each major implementation stage.

```text
screenshots/
├── lab01/
├── lab02/
├── lab03/
├── lab04/
├── lab05/
├── lab06/
├── lab07/
├── lab08/
├── lab09/
├── lab10/
├── lab11/
├── lab12/
├── lab13/
└── final/
```

Screenshots provide implementation evidence for:

* Disk identification
* Partitioning
* Filesystem creation
* Mounting
* Persistent mounts
* LVM architecture
* Volume expansion
* Nginx storage
* MySQL migration
* Backup and restore
* Monitoring
* Automation
* Failure handling
* Recovery

---

# 📖 Documentation

The `docs/` directory contains detailed technical documentation.

| Document | Topic                       |
| -------- | --------------------------- |
| 01       | Storage Fundamentals        |
| 02       | Azure Managed Disks         |
| 03       | Disk Partitioning           |
| 04       | Filesystems                 |
| 05       | Mounting Volumes            |
| 06       | Persistent Mount with fstab |
| 07       | LVM                         |
| 08       | Live Volume Expansion       |
| 09       | Backup & Restore            |
| 10       | Storage Monitoring          |
| 11       | Shell Automation            |
| 12       | Production Best Practices   |
| 13       | Troubleshooting             |
| 14       | Interview Questions         |

---

# 🧰 Cheatsheets

Quick-reference material is available under:

```text
cheatsheets/
```

Including:

* Linux storage commands
* Azure Managed Disk commands
* LVM commands
* General storage command reference

These are useful for day-to-day administration and interview preparation.

---

# 📐 Architecture Diagrams

The `diagrams/` directory contains visual representations of important storage architectures.

Available diagrams include:

* Azure storage architecture
* LVM architecture
* Backup flow
* Production storage architecture

Both editable `.drawio` files and exported image formats are maintained where applicable.

---

# 🛠️ Technologies Used

### Cloud

* Microsoft Azure
* Azure Virtual Machines
* Azure Managed Disks

### Operating System

* Linux
* Ubuntu

### Storage

* Block Devices
* GPT
* ext4
* LVM
* `/etc/fstab`

### Applications

* Nginx
* MySQL

### Automation

* Bash
* Shell scripting

### Monitoring

* Linux filesystem utilities
* Disk I/O utilities
* Process and memory monitoring
* MySQL health checks

### Version Control

* Git
* GitHub

---

# 🔍 Key Commands Practiced

Some of the important commands used throughout the project:

```bash
lsblk
blkid
fdisk
parted
mkfs
mount
umount
findmnt
df
du
```

LVM:

```bash
pvcreate
pvs
vgcreate
vgs
lvcreate
lvs
lvextend
```

Filesystem:

```bash
resize2fs
fsck
```

System:

```bash
systemctl
journalctl
free
uptime
ps
```

MySQL:

```bash
mysql
mysqldump
```

Shell:

```bash
bash
chmod
grep
awk
sed
find
tee
```

---

# 🛡️ Production Practices Demonstrated

The project emphasizes operational safety rather than simply executing commands.

Important practices include:

### 1. Device Verification

Never assume a device name.

```bash
lsblk
blkid
findmnt
```

### 2. UUID-Based Persistent Mounting

Use filesystem UUIDs in `/etc/fstab` where appropriate instead of relying only on device names.

### 3. Pre-Change Validation

Before modifying storage:

```bash
lsblk
df -hT
findmnt
```

### 4. Post-Change Validation

After storage changes:

```bash
df -hT
findmnt
lsblk
```

### 5. Service Validation

Application/database storage changes should always be followed by service validation.

```bash
systemctl status <service>
```

### 6. Backup Before Risky Operations

Critical data should have a valid backup before migration, resize, or recovery operations.

### 7. Idempotent Automation

Automation should be safe to execute repeatedly without unnecessarily breaking an existing configuration.

### 8. Failure Handling

Scripts validate errors and return meaningful exit codes instead of silently continuing.

---

# 🧠 What This Project Demonstrates

After completing this project, the following complete workflow can be understood:

```text
Identify Storage
      ↓
Attach Azure Disk
      ↓
Identify Linux Device
      ↓
Partition Disk
      ↓
Create Filesystem
      ↓
Mount Filesystem
      ↓
Configure /etc/fstab
      ↓
Validate Persistent Storage
      ↓
Configure Application/Database Storage
      ↓
Monitor Storage
      ↓
Backup Data
      ↓
Expand Storage
      ↓
Validate Services
      ↓
Automate Operations
      ↓
Handle Failures
      ↓
Restore & Recover
```

This represents a practical storage administration lifecycle rather than isolated Linux commands.

---

# 📈 Project Progress

```text
[✓] Day 01 — Storage Fundamentals
[✓] Day 02 — Azure Managed Disks
[✓] Day 03 — Disk Partitioning
[✓] Day 04 — Filesystems
[✓] Day 05 — Mounting
[✓] Day 06 — Persistent Mount / fstab
[✓] Day 07 — LVM
[✓] Day 08 — Live Volume Expansion
[✓] Day 09 — Nginx Storage
[✓] Day 10 — MySQL Storage
[✓] Day 11 — Backup & Restore
[✓] Day 12 — Storage Monitoring
[✓] Day 13 — Shell Automation
[ ] Final Production Lab
```

---

# 🚀 How to Use This Repository

Clone the repository:

```bash
git clone <repository-url>
cd azure-linux-storage-engineering
```

Start with the fundamentals:

```text
docs/01-storage-fundamentals.md
```

Then follow the labs sequentially:

```text
labs/lab01-storage-basics/
labs/lab02-managed-disk/
...
labs/lab13-shell-scripting/
labs/final-production-lab/
```

For quick command references, use:

```text
cheatsheets/
```

---

# ⚠️ Lab Safety

Storage operations can cause data loss when performed incorrectly.

Before performing any destructive operation:

* Verify the target disk.
* Verify the partition.
* Confirm the mountpoint.
* Take backups of important data.
* Never blindly copy commands from the lab into a production system.
* Validate `/etc/fstab` before rebooting.
* Verify filesystem and volume information before resizing.
* Test backup and restore procedures.

This repository is intended primarily for **learning, lab environments, and controlled infrastructure testing**.

---

# 🎓 Learning Outcome

This project builds a practical foundation for roles involving:

* DevOps Engineering
* Linux Administration
* Cloud Infrastructure
* Azure Infrastructure
* Site Reliability Engineering
* Platform Engineering
* Infrastructure Automation

The focus is on developing the ability to reason about storage from the **Azure disk layer → Linux block-device layer → filesystem layer → application/database layer → monitoring → backup → automation → recovery**.

---

# 🗺️ Future Roadmap

Potential future improvements include:

* Automated Azure disk provisioning with Terraform
* Azure CLI-based storage automation
* Automated storage health reporting
* Prometheus-based storage metrics
* Grafana dashboards
* Alerting for disk capacity and inode exhaustion
* Automated backup retention
* Cloud-based backup integration
* CI validation for shell scripts
* ShellCheck integration
* Production-grade logging
* Disaster recovery scenarios
* Infrastructure-as-Code integration

---

# 🤝 Contributing

Contributions, improvements, corrections, and additional lab scenarios are welcome.

Please review:

```text
CONTRIBUTING.md
```

before submitting changes.

---

# 📄 License

This project is licensed under the terms defined in:

```text
LICENSE
```

---

# ⭐ Project Philosophy

> **Don't just learn Linux storage commands. Learn how storage behaves as part of a real infrastructure system.**

The objective of this repository is to move from:

```text
Command Knowledge
       ↓
Hands-on Practice
       ↓
Troubleshooting
       ↓
Automation
       ↓
Production Thinking
```

and ultimately develop the mindset required to manage storage reliably in real-world cloud environments.

---

## 👨‍💻 Project Status

**Status:** Active Development

**Focus:** Linux Storage + Azure Infrastructure + DevOps Automation

**Current Stage:** Day 13 — Shell Automation

**Next Stage:** Final Production Storage Lab

