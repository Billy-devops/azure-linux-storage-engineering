Lab 08 — Live LVM Volume Expansion
Objective

Expand an existing LVM Logical Volume using available free space in the Volume Group and then expand the ext4 filesystem.

Environment
Component	Value
OS	Linux
Disk	/dev/nvme1n1
Disk Size	110 GiB
Volume Group	vgdata
Application LV	lvapp
Log LV	lvlogs
Application Mount	/data/app
Log Mount	/data/logs
Filesystem	ext4
Initial State
/dev/nvme1n1
      │
      ▼
    vgdata
   ┌───────┴───────┐
   ▼               ▼
 lvapp           lvlogs
 30G              20G
   │                │
   ▼                ▼
/data/app        /data/logs

The Volume Group had approximately 60 GiB of free space.

Step 1 — Validate Existing LVM
lsblk -f
sudo pvs
sudo vgs
sudo lvs
df -hT
Step 2 — Extend Application LV

The application LV was increased by 20 GiB:

sudo lvextend -L +20G /dev/vgdata/lvapp

This increased:

30G → 50G

A second 20 GiB expansion was performed:

sudo lvextend -L +20G /dev/vgdata/lvapp

Final size:

50G → 70G
Step 3 — Expand ext4 Filesystem
sudo resize2fs /dev/vgdata/lvapp
Step 4 — Final Validation
lsblk -f
sudo pvs
sudo vgs
sudo lvs
df -hT

Mount validation:

findmnt /data/app
findmnt /data/logs
Step 5 — Data Validation
ls -lah /data/app
ls -lah /data/logs

Existing application and log storage were verified after expansion.

Final Architecture
/dev/nvme1n1
      │
      ▼
    vgdata
      │
      ├── lvapp   70G → ext4 → /data/app
      │
      └── lvlogs  20G → ext4 → /data/logs
Validation Checklist

Existing LVM configuration verified

VG free space verified

lvapp expanded from 30G to 50G

lvapp expanded from 50G to 70G

ext4 filesystem expanded

/data/app verified

/data/logs verified

Existing data verified

Final LVM state validated

Key Learning

An LVM Logical Volume and its filesystem are separate layers.

Expanding the Logical Volume must be followed by filesystem expansion.

VG Free Space
     ↓
lvextend
     ↓
Logical Volume
     ↓
resize2fs
     ↓
ext4 Filesystem
     ↓
Mount Point