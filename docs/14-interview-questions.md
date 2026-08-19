# Linux Storage Engineering — Interview Questions & Answers

## 1. Linux Storage Fundamentals

### Q1. Disk, Partition, Filesystem aur Mount Point kya hote hain?

* **Disk:** Block storage device, e.g. `/dev/sdb`
* **Partition:** Disk ka logical section, e.g. `/dev/sdb1`
* **Filesystem:** Files store karne ka structure, e.g. `ext4`, `xfs`
* **Mount Point:** Jahan filesystem accessible hota hai, e.g. `/data`

```text
Disk → Partition → Filesystem → Mount Point
```

### Q2. Disk identify karne ke commands?

```bash
lsblk
sudo fdisk -l
lsblk -f
sudo blkid
findmnt
```

### Q3. `df` vs `du`?

```bash
df -h
```

Filesystem ki total/used/free capacity dikhata hai.

```bash
du -sh /var/*
```

Individual files/directories ka space usage dikhata hai.

---

# 2. Azure Managed Disks

### Q4. Azure Managed Disk attach karne ke baad Linux mein kya karoge?

```text
Azure Disk Attach
      ↓
lsblk
      ↓
Partition
      ↓
Filesystem
      ↓
Mount
      ↓
/etc/fstab
      ↓
Validation
```

Commands:

```bash
lsblk
sudo fdisk -l
sudo blkid
```

### Q5. `/dev/sdb` ko directly `/etc/fstab` mein use kyu nahi karte?

Device names discovery order ke according change ho sakte hain.

Isliye UUID preferred hai:

```bash
sudo blkid
```

```text
UUID=xxxx /data ext4 defaults,nofail 0 2
```

### Q6. Azure disk attach hai but Linux mein show nahi ho raha. Kya check karoge?

```bash
lsblk
sudo fdisk -l
dmesg | tail -50
```

Phir Azure VM ke disk attachment ko verify karunga.

---

# 3. Partitioning

### Q7. Linux disk partition kaise karte ho?

```bash
sudo fdisk /dev/sdb
```

Verify:

```bash
lsblk
sudo fdisk -l /dev/sdb
```

Large modern disks ke liye GPT generally preferred hai.

### Q8. GPT vs MBR?

**MBR:**

* Older partitioning scheme
* Large disks ke liye limitations

**GPT:**

* Modern
* Large disks support
* More partitions
* UEFI systems ke saath commonly used

---

# 4. Filesystems

### Q9. ext4 filesystem kaise create karoge?

```bash
sudo mkfs.ext4 /dev/sdb1
```

Verify:

```bash
sudo blkid /dev/sdb1
```

**Important:** `mkfs` existing data destroy kar sakta hai.

### Q10. ext4 vs XFS?

**ext4**

* General-purpose
* Widely used
* Mature and reliable

**XFS**

* Large-scale workloads
* High-performance enterprise workloads
* Large files/filesystems ke liye suitable

### Q11. Kya XFS filesystem shrink kar sakte ho?

**No.**

XFS ko in-place shrink nahi kar sakte.

XFS ko grow kar sakte hain:

```bash
sudo xfs_growfs /data
```

---

# 5. Mounting

### Q12. Filesystem mount kaise karoge?

```bash
sudo mkdir -p /data
sudo mount /dev/sdb1 /data
```

Verify:

```bash
findmnt /data
df -Th /data
```

### Q13. Mount busy aa raha hai. Kya karoge?

```bash
sudo lsof +D /data
sudo fuser -vm /data
```

Pehle dependent process/application identify aur safely stop karunga.

---

# 6. `/etc/fstab`

### Q14. `/etc/fstab` kya hai?

Linux ki filesystem configuration file hai jo boot ke time filesystems ko automatically mount karne ke liye use hoti hai.

Example:

```text
UUID=xxxx /data ext4 defaults,nofail 0 2
```

### Q15. `fstab` change ke baad reboot se pehle kya karoge?

```bash
sudo mount -a
```

Then:

```bash
findmnt
df -Th
```

**Production mein blindly reboot nahi karunga.**

### Q16. `nofail` kya karta hai?

Agar non-critical filesystem mount fail ho jaye to system boot ko unnecessarily block hone se bachata hai.

---

# 7. LVM

### Q17. LVM kya hai?

**LVM = Logical Volume Manager**

```text
Disk/Partition
      ↓
PV
      ↓
VG
      ↓
LV
      ↓
Filesystem
      ↓
Mount Point
```

### Q18. PV, VG, LV kya hain?

**PV — Physical Volume**

```bash
pvcreate /dev/sdb1
```

**VG — Volume Group**

```bash
vgcreate vg_data /dev/sdb1
```

**LV — Logical Volume**

```bash
lvcreate -L 5G -n lv_data vg_data
```

### Q19. LVM use karne ka advantage?

* Flexible storage management
* Storage pooling
* Logical volumes
* Easy expansion
* Multiple disks combine kar sakte hain
* Production capacity management easier

### Q20. LVM troubleshoot commands?

```bash
pvs
vgs
lvs
lsblk
pvdisplay
vgdisplay
lvdisplay
```

---

# 8. Live Volume Expansion

### Q21. LVM volume expand ka process?

```text
Azure Disk
    ↓
Partition
    ↓
PV
    ↓
VG
    ↓
LV
    ↓
Filesystem
```

Example:

```bash
sudo lvextend -L +5G /dev/vg_data/lv_data
```

Filesystem bhi resize:

```bash
sudo lvextend -r -L +5G /dev/vg_data/lv_data
```

### Q22. `lvextend` vs `resize2fs`?

`lvextend` → LV size increase karta hai.

`resize2fs` → ext4 filesystem resize karta hai.

```bash
sudo lvextend -L +5G /dev/vg_data/lv_data
sudo resize2fs /dev/vg_data/lv_data
```

### Q23. XFS filesystem resize kaise karoge?

```bash
sudo xfs_growfs /data
```

---

# 9. Nginx Storage

### Q24. Nginx ke liye dedicated storage kyu?

* Application isolation
* Log growth management
* Better capacity planning
* Root filesystem protect
* Easier backup/maintenance

Useful commands:

```bash
df -Th
findmnt
sudo nginx -t
sudo systemctl status nginx
```

---

# 10. MySQL Storage

### Q25. MySQL storage important kyu hai?

Database performance storage performance se strongly affected hoti hai:

* IOPS
* Latency
* Throughput
* Capacity
* Filesystem
* Disk performance

### Q26. MySQL storage usage kaise check karoge?

```bash
df -Th
sudo du -sh /var/lib/mysql
sudo du -sh /var/lib/mysql/*
sudo systemctl status mysql
```

### Q27. MySQL data migrate karne se pehle kya check karoge?

1. Backup
2. Database state
3. Permissions
4. Filesystem
5. Mount persistence
6. MySQL configuration
7. Validation
8. Rollback plan

---

# 11. Backup & Restore

### Q28. Backup aur Restore mein difference?

**Backup:** Data ki recoverable copy create karna.

**Restore:** Backup se data recover karna.

### Q29. Backup successful hai to kya restore guaranteed hai?

**No.**

Backup ko regularly restore-test karna chahiye.

### Q30. Backup ke liye kaunse tools use kiye?

Project mein:

```bash
rsync
tar
cp
find
```

Aur Bash automation scripts.

### Q31. 3-2-1 Backup Strategy kya hai?

```text
3 Copies
2 Different Storage/Media
1 Offsite Copy
```

---

# 12. Storage Monitoring

### Q32. Storage mein kya monitor karoge?

* Disk capacity
* Inodes
* IOPS
* Throughput
* Latency
* I/O wait
* Disk utilization
* Mount status
* Application storage
* Log growth

Commands:

```bash
df -h
df -i
du -sh
iostat
vmstat
lsblk
findmnt
journalctl
```

### Q33. Filesystem 100% full ho gaya. Kya karoge?

```bash
df -h
df -i
sudo du -xhd1 / | sort -h
```

Then:

1. Large directories identify
2. Logs check
3. Large files identify
4. Deleted-open files check
5. Safe cleanup/rotation
6. Storage expansion if required
7. Application validation

### Q34. `df -h` free space dikha raha hai but file create nahi ho rahi?

Possible reason **inode exhaustion**.

```bash
df -i
```

Another possibility:

```bash
sudo lsof | grep deleted
```

---

# 13. Troubleshooting

### Q35. Reboot ke baad mount nahi hua. Kya check karoge?

```bash
cat /etc/fstab
sudo mount -a
lsblk -f
sudo blkid
findmnt
journalctl -b
```

Common issues:

* Wrong UUID
* Wrong filesystem type
* Wrong mount point
* Wrong options
* Disk unavailable
* Typo in `fstab`

### Q36. `mount -a` error de raha hai. Reboot karoge?

**No.**

Pehle:

```bash
cat /etc/fstab
sudo blkid
lsblk -f
```

Issue fix karke:

```bash
sudo mount -a
```

### Q37. "No space left on device" but disk free hai?

Check:

```bash
df -i
```

Inode exhaustion ho sakta hai.

Also:

```bash
sudo lsof | grep deleted
```

---

# 14. Shell Automation

### Q38. Bash automation kyu use karte ho?

Repetitive operations automate karne ke liye:

* Backup
* Restore
* Mount validation
* Disk health
* Monitoring
* Cleanup
* LVM safety checks

### Q39. Production-safe Bash script mein kya hona chahiye?

* Validation
* Permission/root check
* Error handling
* Logging
* Exit codes
* Pre-flight checks
* Safety checks
* Idempotency
* Backup before destructive operation

### Q40. Idempotency kya hai?

Same script ko multiple times run karne par unwanted duplicate changes nahi hone chahiye.

Example:

```bash
mount
```

karne se pehle check karna ki filesystem already mounted hai ya nahi.

### Q41. Storage commands mein safety checks kyu?

Dangerous commands:

```bash
mkfs
fdisk
parted
lvremove
rm
```

Wrong device par run hone se data loss ho sakta hai.

---

# 15. Production Storage

### Q42. Production storage design karte waqt kya consider karoge?

```text
Capacity
Performance
IOPS
Throughput
Latency
Availability
Growth
Backup
Recovery
Monitoring
Security
Cost
```

### Q43. Application, DB aur logs same disk par rakhoge?

Depends on workload.

Small environment mein possible hai.

Production mein high-write workloads ko separate storage par rakhna better isolation, capacity management aur performance planning provide kar sakta hai.

### Q44. Root filesystem full ho gaya. Kya karoge?

```bash
df -h /
sudo du -xhd1 / | sort -h
```

Then:

* Logs
* Package cache
* Temporary files
* Application data

identify karunga.

Blindly delete nahi karunga.

---

# 16. Scenario-Based Questions

### Q45. Azure disk 50GB se 100GB kar diya, Linux abhi bhi 50GB dikha raha hai. Why?

Azure disk expansion ke baad Linux storage stack ke remaining layers automatically expand hona zaroori nahi.

Check:

```bash
lsblk
sudo fdisk -l
```

Depending on architecture:

```text
Disk
 ↓
Partition
 ↓
PV
 ↓
VG
 ↓
LV
 ↓
Filesystem
```

Required layers ko expand karna padega.

### Q46. MySQL suddenly slow ho gaya. Storage issue kaise identify karoge?

```bash
iostat -xz 1
vmstat 1
df -h
df -i
```

Check:

* High I/O wait
* High disk utilization
* High latency
* Low free space
* Log growth
* Filesystem issues

Then MySQL metrics ke saath correlate karunga.

### Q47. Backup script success bol rahi hai but restore fail ho raha hai. Meaning?

Backup process sufficiently validated nahi hai.

Need:

```text
Backup
 ↓
Integrity Check
 ↓
Restore Test
 ↓
Validation
```

---

# 17. Project Explanation — Most Important

### Q48. Apna Linux Storage Engineering project explain karo.

**Answer:**

> "I built a hands-on Linux Storage Engineering project on an Azure Linux VM. I started with Linux storage fundamentals and Azure Managed Disks, then worked on disk partitioning, filesystems, mounting, persistent mounts using `/etc/fstab`, and LVM. I also implemented live volume expansion, configured storage for Nginx and MySQL, practiced backup and restore, performed storage monitoring and troubleshooting, and automated operational tasks using Bash scripts. The project focuses on production-oriented storage management, safety, monitoring, backup and recovery."

### Q49. Project mein kya-kya technologies use ki?

```text
Azure Linux VM
Azure Managed Disks
Linux
Bash
fdisk
ext4
XFS
LVM
fstab
Nginx
MySQL
rsync
tar
iostat
df
du
systemd
journalctl
```

### Q50. Project se kya skills gain hui?

* Linux Storage Administration
* Azure Managed Disk Management
* Disk Partitioning
* Filesystem Management
* Mounting
* `/etc/fstab`
* LVM
* Live Expansion
* Nginx Storage
* MySQL Storage
* Backup/Restore
* Monitoring
* Troubleshooting
* Bash Automation
* Production Best Practices

---

# 18. Rapid-Fire Commands

| Requirement       | Command                  |
| ----------------- | ------------------------ |
| Show disks        | `lsblk`                  |
| Disk details      | `fdisk -l`               |
| Filesystem + UUID | `lsblk -f`               |
| UUID              | `blkid`                  |
| Filesystem usage  | `df -h`                  |
| Inodes            | `df -i`                  |
| Directory usage   | `du -sh`                 |
| Mounts            | `findmnt`                |
| Mount all fstab   | `mount -a`               |
| PV                | `pvs`                    |
| VG                | `vgs`                    |
| LV                | `lvs`                    |
| LV details        | `lvdisplay`              |
| VG details        | `vgdisplay`              |
| Disk I/O          | `iostat -xz 1`           |
| System load       | `vmstat 1`               |
| Logs              | `journalctl`             |
| Busy mount        | `fuser -vm /data`        |
| Open files        | `lsof`                   |
| Nginx test        | `nginx -t`               |
| Nginx status      | `systemctl status nginx` |
| MySQL status      | `systemctl status mysql` |

---

# 19. Final Interview Checklist

* [ ] Disk vs Partition vs Filesystem
* [ ] Block devices
* [ ] `lsblk`
* [ ] `fdisk`
* [ ] GPT vs MBR
* [ ] ext4 vs XFS
* [ ] Mount / Unmount
* [ ] `/etc/fstab`
* [ ] UUID
* [ ] `nofail`
* [ ] LVM
* [ ] PV / VG / LV
* [ ] `pvs / vgs / lvs`
* [ ] LV expansion
* [ ] Filesystem expansion
* [ ] XFS growth
* [ ] Azure Managed Disks
* [ ] Nginx storage
* [ ] MySQL storage
* [ ] Backup / Restore
* [ ] 3-2-1 backup
* [ ] `df` vs `du`
* [ ] Inode exhaustion
* [ ] Disk I/O
* [ ] `fstab` troubleshooting
* [ ] Bash automation
* [ ] Idempotency
* [ ] Storage safety
* [ ] Production storage design
* [ ] Project explanation

---

# 20. Complete Storage Flow

```text
Azure Managed Disk
        ↓
Linux Disk Detection
        ↓
Partitioning
        ↓
Filesystem
        ↓
Mount
        ↓
/etc/fstab
        ↓
LVM
        ↓
Live Expansion
        ↓
Nginx / MySQL Storage
        ↓
Backup & Restore
        ↓
Monitoring
        ↓
Troubleshooting
        ↓
Bash Automation
        ↓
Production-Ready Linux Storage
```

## Final Interview Line

> **"My project covers the complete Linux storage lifecycle — from Azure disk provisioning and filesystem management to LVM, application storage, backup/restore, monitoring, troubleshooting and Bash automation, with a production-focused approach."**
