# Changelog

All notable changes to the **Azure Linux Storage Engineering** project are documented in this file.

The project follows a practical, day-by-day implementation approach where each milestone includes documentation, hands-on labs, validation evidence, and production-oriented practices.

---

## [Unreleased]

### Planned

* Complete Final Production Storage Lab
* Add complete production architecture validation
* Improve shell-script error handling and logging
* Add ShellCheck validation
* Improve monitoring automation
* Add additional storage failure and recovery scenarios
* Add Azure CLI automation
* Add Terraform-based Azure disk provisioning
* Improve CI validation for scripts and documentation

---

# [Day 13] — Shell Automation

### Added

* Storage automation scripts
* Backup automation
* Restore automation
* Cleanup automation
* Disk health validation
* Storage monitoring automation
* Mount automation
* LVM resize safety checks

### Scripts

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

### Validation

Added evidence for:

* Backup success and failure
* Restore success and failure
* Cleanup protection
* Disk health validation
* Invalid mount detection
* Health-check failures
* Health-check recovery
* Mount idempotency
* LVM resize safety
* Storage monitoring
* Filesystem validation
* Persistent mount validation

---

# [Day 12] — Storage Monitoring

### Added

* Filesystem capacity monitoring
* Inode monitoring
* Disk I/O monitoring
* Memory monitoring
* Load monitoring
* Process monitoring
* MySQL health monitoring
* MySQL storage analysis
* `/var` storage analysis
* `/var/lib` storage analysis
* Journal disk usage analysis
* InnoDB redo analysis

### Documentation

Added:

```text
docs/10-storage-monitoring.md
labs/lab12-monitoring/README.md
```

### Evidence

Added monitoring screenshots covering:

* Filesystem capacity
* Inode usage
* Disk I/O
* MySQL health
* MySQL storage
* Journal usage
* Root disk usage
* `/var`
* `/var/lib`
* Memory
* Load
* Processes

---

# [Day 11] — Backup & Restore

### Added

* Full MySQL backup workflow
* Backup file validation
* Restore testing
* Restore verification
* Database failure simulation
* Recovery validation

### Documentation

Added:

```text
docs/09-backup-restore.md
labs/lab11-backup-restore/README.md
```

### Evidence

Added screenshots covering:

* Existing databases
* Full backup creation
* Backup content validation
* Restore source data
* Restore testing
* Restore success
* Failure simulation
* Final restore validation

---

# [Day 10] — MySQL Storage

### Added

* Dedicated MySQL storage
* Azure data disk preparation
* Disk partitioning
* ext4 filesystem
* Persistent storage mount
* MySQL data directory migration
* MySQL `datadir` configuration
* Data synchronization
* MySQL service validation
* Database storage verification

### Documentation

Added:

```text
labs/lab10-mysql-storage/README.md
```

---

# [Day 09] — Nginx Storage

### Added

* Dedicated application storage
* Nginx storage configuration
* Nginx access log storage
* Nginx error log storage
* Application storage validation
* Nginx service validation
* HTTP validation

### Documentation

Added:

```text
labs/lab09-nginx-storage/README.md
```

---

# [Day 08] — Live Volume Expansion

### Added

* LVM volume expansion
* Logical Volume resizing
* Filesystem expansion
* Online storage expansion
* Post-resize validation

### Documentation

Added:

```text
docs/08-live-volume-expansion.md
labs/lab08-live-expansion/README.md
```

---

# [Day 07] — LVM

### Added

* Physical Volume creation
* Volume Group creation
* Logical Volume creation
* LVM storage architecture
* Application and log storage separation
* LVM validation

### Documentation

Added:

```text
docs/07-lvm.md
labs/lab07-lvm/README.md
```

---

# [Day 06] — Persistent Mounting

### Added

* `/etc/fstab` configuration
* UUID-based persistent mounting
* `mount -a` validation
* Reboot persistence validation
* Mount verification

### Documentation

Added:

```text
docs/06-persistent-mount-fstab.md
labs/lab06-fstab/README.md
```

---

# [Day 05] — Mounting Volumes

### Added

* Manual filesystem mounting
* Mountpoint management
* Unmounting
* `findmnt` validation
* Mount state verification

### Documentation

Added:

```text
docs/05-mounting-volumes.md
labs/lab05-mounting/README.md
```

---

# [Day 04] — Filesystems

### Added

* ext4 filesystem creation
* Filesystem identification
* Filesystem mounting
* Filesystem validation
* Mount/unmount testing

### Documentation

Added:

```text
docs/04-filesystems.md
labs/lab04-filesystem/README.md
```

---

# [Day 03] — Disk Partitioning

### Added

* GPT partition table
* Partition creation
* `fdisk`
* `parted`
* Partition verification

### Documentation

Added:

```text
docs/03-disk-partitioning.md
labs/lab03-partitioning/README.md
```

---

# [Day 02] — Azure Managed Disks

### Added

* Azure Managed Disk concepts
* Data disk attachment
* Linux disk identification
* Azure-to-Linux storage workflow

### Documentation

Added:

```text
docs/02-azure-managed-disks.md
labs/lab02-managed-disk/README.md
```

---

# [Day 01] — Storage Fundamentals

### Added

* Linux block-device fundamentals
* Disk identification
* Filesystem concepts
* Mountpoint concepts
* Storage usage analysis
* Basic storage commands

### Documentation

Added:

```text
docs/01-storage-fundamentals.md
labs/lab01-storage-basics/README.md
```

---

# Repository Foundation

### Added

Initial repository structure containing:

```text
.github/
assets/
cheatsheets/
diagrams/
docs/
labs/
screenshots/
scripts/
```

### Documentation

Added:

* `README.md`
* `CONTRIBUTING.md`
* `CHANGELOG.md`
* `ROADMAP.md`
* `LICENSE`

### GitHub Project Structure

Added:

* Pull Request template
* Lab task issue template
* Project documentation structure
* Screenshot evidence structure
* Cheatsheets
* Architecture diagrams

---

# Versioning Strategy

The project uses milestone-based changelog entries.

Major milestones are organized around the learning stages:

```text
Day 01 → Fundamentals
Day 02 → Azure Disks
Day 03 → Partitioning
Day 04 → Filesystems
Day 05 → Mounting
Day 06 → fstab
Day 07 → LVM
Day 08 → Expansion
Day 09 → Nginx
Day 10 → MySQL
Day 11 → Backup & Restore
Day 12 → Monitoring
Day 13 → Automation
Final → Production Lab
```

---

# Changelog Maintenance

Every significant project milestone should update this file with:

* New features
* New labs
* New scripts
* Documentation changes
* Architecture improvements
* Bug fixes
* Automation improvements
* Production enhancements
* Breaking changes, if any

---

## Current Status

**Completed:** Day 01 → Day 13

**Current Focus:** Final Production Storage Lab

**Project Status:** Active Development
