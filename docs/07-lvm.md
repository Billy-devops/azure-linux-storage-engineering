07 — Linux LVM (Logical Volume Manager)
📌 Overview

Logical Volume Manager (LVM) is a Linux storage management layer that provides flexible disk allocation and resizing.

Instead of directly creating filesystems on disk partitions, LVM introduces abstraction layers:

Physical Disk
     │
     ▼
Physical Volume (PV)
     │
     ▼
Volume Group (VG)
     │
     ├──────────────┐
     ▼              ▼
Logical Volume   Logical Volume
     │              │
     ▼              ▼
Filesystem       Filesystem
     │              │
     ▼              ▼
/data/app        /data/logs

In this lab, an Azure managed disk was used as the underlying storage device.

🎯 Objectives

By completing this lab, you will understand:

What LVM is
Physical Volume (PV)
Volume Group (VG)
Logical Volume (LV)
LVM-to-filesystem relationship
Mounting Logical Volumes
Checking LVM metadata
Using free space inside a Volume Group
Extending Logical Volumes
Growing an ext4 filesystem
Verifying application and log data
Troubleshooting missing mounts
Understanding why an existing LVM disk must not be reinitialized
🏗️ Lab Environment
Component	Value
Cloud	Microsoft Azure
OS	Ubuntu 24.04 LTS
Storage Disk	/dev/nvme1n1
Disk Size	110 GB
LVM PV	/dev/nvme1n1
Volume Group	vgdata
Logical Volume 1	lvapp
Logical Volume 2	lvlogs
Application Mount	/data/app
Logs Mount	/data/logs
Filesystem	ext4
1. Identify Available Disks
lsblk

Example:

nvme0n1      30G
├─nvme0n1p1  29G  /
├─nvme0n1p15 106M /boot/efi
└─nvme0n1p16 913M /boot

nvme1n1     110G

The 110 GB disk is the storage disk used for LVM.

2. Inspect Filesystem and LVM Metadata
lsblk -f

Example:

nvme1n1         LVM2_member
├─vgdata-lvapp  ext4
└─vgdata-lvlogs ext4

This shows that /dev/nvme1n1 is already an LVM Physical Volume.

3. Verify the Physical Volume
sudo pvs

Example:

PV            VG      Fmt  Attr  PSize    PFree
/dev/nvme1n1  vgdata  lvm2 a--   <110G    <70G

Detailed information:

sudo pvdisplay
Important

Do not run:

sudo pvcreate /dev/nvme1n1

on an already initialized PV.

Attempting this produced:

Can't initialize physical volume "/dev/nvme1n1"
of volume group "vgdata" without -ff

This is a safety mechanism preventing accidental destruction of existing LVM metadata.

4. Verify the Volume Group
sudo vgs

Detailed:

sudo vgdisplay vgdata

The Volume Group contains the available storage pool.

Conceptually:

vgdata = ~110 GB
       │
       ├── lvapp
       ├── lvlogs
       │
       └── Free Space

The free space can later be allocated to existing or new Logical Volumes.

5. Verify Logical Volumes
sudo lvs

Detailed:

sudo lvdisplay

Useful production view:

sudo lvs -o lv_name,vg_name,lv_size,lv_attr,devices

Example architecture:

/dev/nvme1n1
      │
      ▼
   vgdata
    │   │
    ▼   ▼
 lvapp lvlogs
6. Mount Existing Logical Volumes

During validation, the LVs were present but their mountpoints were missing.

This can be detected using:

lsblk -f

and:

df -hT

The LVs existed, but /data/app and /data/logs were not shown as mounted.

Create mount directories:

sudo mkdir -p /data/app
sudo mkdir -p /data/logs

Mount the application LV:

sudo mount /dev/vgdata/lvapp /data/app

Mount the logs LV:

sudo mount /dev/vgdata/lvlogs /data/logs

Verify:

lsblk -f

Expected:

vgdata-lvapp   ext4   /data/app
vgdata-lvlogs  ext4   /data/logs
7. Verify Filesystem Usage
df -hT

Specific mount:

df -hT /data/app
df -hT /data/logs

Also:

findmnt /data/app
findmnt /data/logs
8. Application Storage Test

Create application data:

sudo mkdir -p /data/app/application
echo "Production Application Data" | sudo tee /data/app/application/app.txt

Verify:

cat /data/app/application/app.txt

Expected:

Production Application Data
9. Application Log Storage Test

Create log directory:

sudo mkdir -p /data/logs/application

Create log:

echo "Application started successfully" | sudo tee /data/logs/application/app.log

Verify:

cat /data/logs/application/app.log

Expected:

Application started successfully
10. Important Troubleshooting Scenario

Initially, the following commands failed:

cat /data/app/application/app.txt

and:

cat /data/logs/application/app.log

with:

No such file or directory

However, the LVM volumes were still present.

The important distinction was:

LV exists ≠ LV is mounted

This was verified using:

lsblk -f

The solution was to mount the existing LVs:

sudo mount /dev/vgdata/lvapp /data/app
sudo mount /dev/vgdata/lvlogs /data/logs

After mounting, the existing application and log data became accessible.

11. LVM Capacity Expansion

One major advantage of LVM is flexible storage expansion.

First inspect free space:

sudo vgs

Example:

VG      VSize    VFree
vgdata  <110G    <70G

Assume the application requires an additional 10 GB.

Extend the Logical Volume:

sudo lvextend -L +10G /dev/vgdata/lvapp

Verify:

sudo lvs

For ext4, expand the filesystem:

sudo resize2fs /dev/vgdata/lvapp

Verify:

df -hT /data/app

Storage flow:

VG Free Space
      │
      ▼
   lvextend
      │
      ▼
Logical Volume grows
      │
      ▼
   resize2fs
      │
      ▼
Filesystem grows
      │
      ▼
Application gets more capacity
12. Useful LVM Commands
Physical Volumes
sudo pvs
sudo pvdisplay
Volume Groups
sudo vgs
sudo vgdisplay
Logical Volumes
sudo lvs
sudo lvdisplay
sudo lvscan
Disk Mapping
lsblk
lsblk -f
Filesystem Usage
df -hT
Mount Information
findmnt
findmnt /data/app
findmnt /data/logs
13. Production Architecture

A common enterprise Linux storage design is:

Azure Managed Disk
       │
       ▼
/dev/nvme1n1
       │
       ▼
Physical Volume
       │
       ▼
Volume Group: vgdata
       │
       ├───────────────┐
       ▼               ▼
Logical Volume      Logical Volume
lvapp               lvlogs
       │               │
       ▼               ▼
ext4                ext4
       │               │
       ▼               ▼
/data/app           /data/logs
       │               │
       ▼               ▼
Application         Application Logs
14. Key Production Lessons
1. Never blindly run pvcreate

Before initializing a disk:

sudo wipefs -n /dev/nvme1n1

and:

sudo pvs

should be checked.

2. Disk can exist without being mounted
Disk exists
    ↓
PV exists
    ↓
VG exists
    ↓
LV exists
    ↓
BUT
    ↓
Mount can still be missing
3. LVM provides abstraction

Applications don't need to know the physical disk.

They simply use:

/data/app
/data/logs

while LVM manages the underlying storage.

4. LVM simplifies expansion

Instead of repartitioning a disk, free VG capacity can be allocated to an LV.

🧪 Lab Validation Checklist

Identify Azure disk

Verify PV

Verify VG

Verify LVs

Verify ext4 filesystems

Detect missing mount

Mount lvapp

Mount lvlogs

Verify mountpoints

Create application data

Create application logs

Verify stored data

Inspect VG free space

Practice LV expansion

Verify filesystem expansion

🎯 Interview Questions
What is LVM?

LVM is a Linux storage abstraction layer that provides flexible allocation and resizing of storage using PVs, VGs and LVs.

What is a PV?

A Physical Volume is storage initialized for use by LVM.

Example:

/dev/nvme1n1
What is a VG?

A Volume Group combines one or more PVs into a storage pool.

Example:

vgdata
What is an LV?

A Logical Volume is a virtual block device allocated from a VG.

Examples:

lvapp
lvlogs
Why use LVM?

Because it provides:

Flexible allocation
Online expansion
Storage abstraction
Easier capacity management
Separation of application and log storage
What happens if an LV exists but is not mounted?

The LV and its filesystem can still exist, but applications accessing the mount path will see the underlying directory instead of the LV's data.

🏁 Day 7 Result

Successfully practiced Linux LVM on an Azure Linux VM:

110 GB Azure Disk
      ↓
PV
      ↓
vgdata
      ↓
├── lvapp  → /data/app
└── lvlogs → /data/logs

Application and log data were successfully recovered and verified after restoring the missing mount relationships.