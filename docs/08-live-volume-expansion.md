Day 8 — Live LVM Volume Expansion
Overview

This lab demonstrates live expansion of an existing LVM Logical Volume and its ext4 filesystem on an Azure Linux virtual machine.

The existing LVM configuration from Day 7 was reused. Instead of recreating the disk or filesystem, available free space inside the existing Volume Group was allocated to the application Logical Volume.

Objective
Verify existing LVM storage
Identify available free space in the Volume Group
Expand the application Logical Volume
Expand the ext4 filesystem
Validate the expanded filesystem
Verify that existing application and log storage remain accessible
Existing Storage Architecture
Azure Managed Disk
        │
        ▼
/dev/nvme1n1
        │
        ▼
LVM Physical Volume
        │
        ▼
vgdata
   ┌────┴────┐
   ▼         ▼
 lvapp     lvlogs
   │         │
   ▼         ▼
/data/app  /data/logs
Initial LVM State

The existing storage configuration was validated before expansion.

Physical Volume
sudo pvs

Initial state:

PV              VG      PSize       PFree
/dev/nvme1n1    vgdata  <110.00g    <60.00g
Volume Group
sudo vgs

Initial state:

VG      #PV   #LV   VSize       VFree
vgdata   1     2    <110.00g    <60.00g
Logical Volumes
sudo lvs

Initial configuration:

lvapp    30G
lvlogs   20G
Filesystems
df -hT

The application filesystem was mounted at:

/data/app

The log filesystem was mounted at:

/data/logs
1. Verify Existing Storage

The complete storage stack was inspected using:

lsblk -f
sudo pvs
sudo vgs
sudo lvs
df -hT
findmnt /data/app
findmnt /data/logs

This confirmed that the existing LVM configuration was healthy and that the Volume Group had available free space.

2. Live Logical Volume Expansion

The application Logical Volume was expanded using the free space available in vgdata.

First expansion:

sudo lvextend -L +20G /dev/vgdata/lvapp

The Logical Volume increased from:

30 GiB → 50 GiB

A second controlled expansion was then performed:

sudo lvextend -L +20G /dev/vgdata/lvapp

The final Logical Volume size became:

50 GiB → 70 GiB

Final LV state:

lvapp    70G
lvlogs   20G

The Logical Volume was expanded without recreating the filesystem or mount point.

3. Expand the ext4 Filesystem

Increasing an LV does not automatically increase the filesystem.

The application filesystem uses ext4, so the filesystem was expanded using:

sudo resize2fs /dev/vgdata/lvapp

The resulting filesystem size was then validated:

df -hT /data/app
4. Final Storage Architecture

The final architecture is:

/dev/nvme1n1
      │
      ▼
    vgdata
      │
      ├── lvapp   70G → ext4 → /data/app
      │
      └── lvlogs  20G → ext4 → /data/logs

The existing LVM structure was preserved throughout the expansion.

5. Final Validation

The complete storage configuration was validated using:

lsblk -f
sudo pvs
sudo vgs
sudo lvs
df -hT
findmnt /data/app
findmnt /data/logs

The final state confirmed:

vgdata remained healthy
lvapp increased to 70 GiB
lvlogs remained at 20 GiB
/data/app remained mounted
/data/logs remained mounted
ext4 filesystem was expanded
Existing storage configuration remained intact
6. Data Validation

Application storage was checked after expansion:

ls -lah /data/app

Log storage was also checked:

ls -lah /data/logs

The purpose was to verify that existing data remained accessible after the Logical Volume and filesystem expansion.

7. Important Concepts
LV Expansion

lvextend increases the size of an existing Logical Volume.

sudo lvextend -L +20G /dev/vgdata/lvapp
Filesystem Expansion

The filesystem must also be expanded after increasing the Logical Volume.

For ext4:

sudo resize2fs /dev/vgdata/lvapp
Storage Layer Relationship
Physical Disk
      ↓
LVM Physical Volume
      ↓
Volume Group
      ↓
Logical Volume
      ↓
Filesystem
      ↓
Mount Point

Increasing one layer does not necessarily increase every layer above it.

8. Key Commands
# Inspect storage
lsblk -f
sudo pvs
sudo vgs
sudo lvs
df -hT

# Extend Logical Volume
sudo lvextend -L +20G /dev/vgdata/lvapp

# Grow ext4 filesystem
sudo resize2fs /dev/vgdata/lvapp

# Validate
sudo pvs
sudo vgs
sudo lvs
df -hT
findmnt /data/app
9. Lessons Learned

This lab demonstrated how an infrastructure engineer can increase application storage capacity without recreating the existing LVM configuration.

The operational sequence is:

Existing VG Free Space
        ↓
lvextend
        ↓
Expanded Logical Volume
        ↓
resize2fs
        ↓
Expanded ext4 Filesystem
        ↓
Final Validation

The lab also reinforced the distinction between:

Azure managed disk capacity
Linux block device capacity
LVM Physical Volume
LVM Volume Group
Logical Volume
Filesystem
Mount point
10. Outcome

Successfully expanded the existing application Logical Volume from:

30 GiB → 70 GiB

while keeping the existing log Logical Volume at:

20 GiB

The ext4 filesystem was expanded and the application mount remained available.

This establishes the foundation for the next storage engineering topics, including automated resizing, production storage monitoring, backup/restore, and application/database storage management.