# 🧪 Lab 07 — Linux LVM Storage Engineering

## 🎯 Objective

Build and operate a Linux LVM storage architecture on an Azure Linux VM.

This lab focuses on:

* PV
* VG
* LV
* ext4 filesystem
* Mounting
* Storage verification
* LVM troubleshooting
* Capacity expansion
* Application/log separation

---

## 🏗️ Architecture

```text
Azure Managed Disk
       │
       ▼
/dev/nvme1n1 — 110 GB
       │
       ▼
Physical Volume
       │
       ▼
VG: vgdata
       │
       ├──────────────┐
       ▼              ▼
   lvapp            lvlogs
       │              │
       ▼              ▼
     ext4            ext4
       │              │
       ▼              ▼
 /data/app        /data/logs
```

---

# Step 1 — Identify Disk

```bash
lsblk
```

Verify the 110 GB disk:

```bash
sudo fdisk -l
```

---

# Step 2 — Verify LVM PV

```bash
sudo pvs
```

```bash
sudo pvdisplay
```

Expected:

```text
/dev/nvme1n1 → vgdata
```

---

# Step 3 — Verify Volume Group

```bash
sudo vgs
```

```bash
sudo vgdisplay vgdata
```

---

# Step 4 — Verify Logical Volumes

```bash
sudo lvs
```

```bash
sudo lvdisplay
```

Detailed:

```bash
sudo lvs -o lv_name,vg_name,lv_size,lv_attr,devices
```

---

# Step 5 — Verify Filesystems

```bash
lsblk -f
```

Expected:

```text
nvme1n1
├── vgdata-lvapp   ext4
└── vgdata-lvlogs  ext4
```

---

# Step 6 — Check Mount State

```bash
df -hT
```

```bash
findmnt /data/app
findmnt /data/logs
```

If the LVs exist but aren't mounted:

```bash
sudo mkdir -p /data/app
sudo mkdir -p /data/logs
```

---

# Step 7 — Mount LVs

```bash
sudo mount /dev/vgdata/lvapp /data/app
```

```bash
sudo mount /dev/vgdata/lvlogs /data/logs
```

Verify:

```bash
lsblk -f
```

```bash
df -hT
```

---

# Step 8 — Application Data Test

```bash
sudo mkdir -p /data/app/application
```

```bash
echo "Production Application Data" | sudo tee /data/app/application/app.txt
```

Verify:

```bash
cat /data/app/application/app.txt
```

Expected:

```text
Production Application Data
```

---

# Step 9 — Log Data Test

```bash
sudo mkdir -p /data/logs/application
```

```bash
echo "Application started successfully" | sudo tee /data/logs/application/app.log
```

Verify:

```bash
cat /data/logs/application/app.log
```

---

# Step 10 — LVM Capacity Check

```bash
sudo vgs
```

Look for:

```text
VFree
```

This represents unused storage available inside the Volume Group.

---

# Step 11 — Extend Application LV

Example: increase `lvapp` by 10 GB.

```bash
sudo lvextend -L +10G /dev/vgdata/lvapp
```

Verify:

```bash
sudo lvs
```

---

# Step 12 — Expand ext4 Filesystem

```bash
sudo resize2fs /dev/vgdata/lvapp
```

Verify:

```bash
df -hT /data/app
```

---

# Step 13 — Validate Application Data

```bash
cat /data/app/application/app.txt
```

The existing data should remain available after LV expansion.

---

# 🔎 Troubleshooting Scenario

During validation, the LVs existed:

```text
vgdata-lvapp
vgdata-lvlogs
```

but their mountpoints were missing.

This caused:

```bash
cat /data/app/application/app.txt
```

to return:

```text
No such file or directory
```

The solution was **not** to recreate the LVs.

Instead:

```bash
sudo mount /dev/vgdata/lvapp /data/app
sudo mount /dev/vgdata/lvlogs /data/logs
```

After mounting, the existing application and log data became accessible.

### Important lesson

```text
Existing LV ≠ Mounted LV
```

Always check:

```bash
lsblk -f
df -hT
findmnt
```

before making destructive storage changes.

---

# 🧠 Command Cheat Sheet

| Command     | Purpose                         |
| ----------- | ------------------------------- |
| `lsblk`     | View disks and block devices    |
| `lsblk -f`  | View filesystem/LVM information |
| `pvs`       | View Physical Volumes           |
| `pvdisplay` | Detailed PV information         |
| `vgs`       | View Volume Groups              |
| `vgdisplay` | Detailed VG information         |
| `lvs`       | View Logical Volumes            |
| `lvdisplay` | Detailed LV information         |
| `lvscan`    | Scan LVs                        |
| `findmnt`   | View mounted filesystems        |
| `df -hT`    | Filesystem capacity             |
| `lvextend`  | Increase LV size                |
| `resize2fs` | Expand ext4 filesystem          |

---

# 🚨 Safety Rules

Before modifying storage:

```bash
lsblk
lsblk -f
sudo pvs
sudo vgs
sudo lvs
sudo wipefs -n /dev/nvme1n1
```

Never blindly execute:

```bash
pvcreate
mkfs
wipefs -a
fdisk
```

on a production disk.

These commands can destroy existing storage metadata or data.

---

# ✅ Lab Completion

```text
[x] Azure disk identified
[x] PV verified
[x] VG verified
[x] LVs verified
[x] ext4 verified
[x] Mount issue diagnosed
[x] lvapp mounted
[x] lvlogs mounted
[x] Application data verified
[x] Log data verified
[x] VG capacity inspected
[x] LV expansion practiced
[x] Filesystem expansion practiced
```

---

## 🏆 Day 7 Engineering Outcome

```text
Azure Disk
    ↓
Linux PV
    ↓
Volume Group
    ↓
Logical Volumes
    ↓
ext4
    ↓
Mount Points
    ↓
Application + Logs
```

This lab demonstrates the foundation required for managing flexible Linux storage in production environments.
