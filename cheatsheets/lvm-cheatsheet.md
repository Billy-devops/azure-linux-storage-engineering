LVM Cheatsheet

Quick reference for Linux Logical Volume Manager.

🏗️ LVM Architecture
Physical Disk
     ↓
Partition
     ↓
Physical Volume (PV)
     ↓
Volume Group (VG)
     ↓
Logical Volume (LV)
     ↓
Filesystem
     ↓
Mountpoint
🔎 LVM Discovery

Physical Volumes:

sudo pvs

Detailed PV information:

sudo pvdisplay

Volume Groups:

sudo vgs

Detailed VG information:

sudo vgdisplay

Logical Volumes:

sudo lvs

Detailed LV information:

sudo lvdisplay
🧱 Create Physical Volume

Example:

sudo pvcreate /dev/nvme1n1

Verify:

sudo pvs
📦 Create Volume Group
sudo vgcreate vgdata /dev/nvme1n1

Verify:

sudo vgs
💾 Create Logical Volume

Create 10 GB LV:

sudo lvcreate -L 10G -n lvapp vgdata

Create using percentage:

sudo lvcreate -l 100%FREE -n lvapp vgdata

Verify:

sudo lvs
🧱 Create Filesystem
sudo mkfs.ext4 /dev/vgdata/lvapp

Verify:

sudo blkid /dev/vgdata/lvapp
📍 Mount LVM Volume

Create mountpoint:

sudo mkdir -p /data/app

Mount:

sudo mount /dev/vgdata/lvapp /data/app

Verify:

findmnt /data/app
df -hT /data/app
🔐 Persistent LVM Mount

Get UUID:

sudo blkid /dev/vgdata/lvapp

Add to /etc/fstab:

UUID=<UUID> /data/app ext4 defaults,nofail 0 2

Validate:

sudo mount -a
📈 Extend Logical Volume

Check available VG space:

sudo vgs

Extend by 5 GB:

sudo lvextend -L +5G /dev/vgdata/lvapp

Extend to a specific size:

sudo lvextend -L 20G /dev/vgdata/lvapp

Extend using all free space:

sudo lvextend -l +100%FREE /dev/vgdata/lvapp
📐 Extend ext4 Filesystem

After extending the LV:

sudo resize2fs /dev/vgdata/lvapp

Or use lvextend with filesystem resize:

sudo lvextend -r -L +5G /dev/vgdata/lvapp
🔄 Live Expansion Workflow
Check Current State
       ↓
Check VG Free Space
       ↓
Extend LV
       ↓
Extend Filesystem
       ↓
Verify

Commands:

sudo lvs
sudo vgs
df -hT

Then:

sudo lvextend -L +5G /dev/vgdata/lvapp
sudo resize2fs /dev/vgdata/lvapp

Finally:

sudo lvs
df -hT
➕ Add Another Disk to Existing VG

Create PV:

sudo pvcreate /dev/nvme2n1

Extend VG:

sudo vgextend vgdata /dev/nvme2n1

Verify:

sudo pvs
sudo vgs
🔍 LVM Troubleshooting

Check PV:

sudo pvs

Check VG free space:

sudo vgs

Check LV:

sudo lvs

Check filesystem:

df -hT

Check mount:

findmnt

Check device relationships:

lsblk -f
🛡️ Safe LVM Expansion

Before resizing:

sudo pvs
sudo vgs
sudo lvs
df -hT
lsblk -f

Confirm:

Correct PV
Correct VG
Correct LV
Sufficient free space
Correct filesystem
Correct mountpoint

After resizing:

sudo lvs
df -hT
lsblk -f
⚠️ Important

Never run destructive LVM commands against an unverified device.

Be especially careful with:

pvcreate
lvcreate
lvremove
vgremove
pvremove
mkfs

Always identify the target device first.

🧠 LVM Quick Reference
Task	Command
List PVs	pvs
List VGs	vgs
List LVs	lvs
Create PV	pvcreate
Create VG	vgcreate
Create LV	lvcreate
Extend VG	vgextend
Extend LV	lvextend
Resize ext4	resize2fs
Remove LV	lvremove
Detailed PV	pvdisplay
Detailed VG	vgdisplay
Detailed LV	lvdisplay
🎯 Production Workflow
Azure Disk
    ↓
Linux Device
    ↓
PV
    ↓
VG
    ↓
LV
    ↓
Filesystem
    ↓
Mountpoint
    ↓
Application
    ↓
Monitoring
    ↓
Backup