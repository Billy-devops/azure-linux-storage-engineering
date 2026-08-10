Lab 06 — Persistent Mounts with /etc/fstab
📌 Objective

Configure an Azure Linux VM data disk for persistent mounting using /etc/fstab and verify that the filesystem automatically mounts after a VM reboot.

This lab demonstrates a production-oriented approach to Linux storage persistence using a filesystem UUID instead of relying on a device name.

🏗️ Lab Architecture
Azure Managed Disk
       │
       ▼
Linux VM
       │
       ▼
/dev/nvme0n3
       │
       ▼
/dev/nvme0n3p1
       │
       ▼
     ext4
       │
       ▼
UUID=b80c92b7-0c0a-46d9-ab90-4d1dc13d0152
       │
       ▼
/etc/fstab
       │
       ▼
/data-day06
       │
       ▼
Persistent Mount

Important: After reboot, Linux detected the same filesystem as /dev/nvme1n3p1 instead of /dev/nvme0n3p1. The filesystem UUID remained the stable identity, demonstrating why UUID-based mounting is preferred over hard-coded device names.

1. Environment
Component	Value
OS	Ubuntu 24.04.4 LTS
VM	Azure Linux VM
New Data Disk	8 GiB
Initial Device	/dev/nvme0n3
Partition	/dev/nvme0n3p1
Filesystem	ext4
Mount Point	/data-day06
Filesystem UUID	b80c92b7-0c0a-46d9-ab90-4d1dc13d0152
2. Identify the New Disk

The new Azure managed disk was detected using:

lsblk

Initial layout:

nvme0n3
└─nvme0n3p1

The new disk was confirmed as an 8 GiB disk.

The existing OS disk and Day 5 disk were left untouched.

3. Create the Filesystem

The new partition was formatted with ext4:

sudo mkfs.ext4 /dev/nvme0n3p1

Output confirmed filesystem creation:

Filesystem UUID:
b80c92b7-0c0a-46d9-ab90-4d1dc13d0152

The filesystem was then verified:

lsblk -f

Expected:

nvme0n3
└─nvme0n3p1 ext4 b80c92b7-0c0a-46d9-ab90-4d1dc13d0152
4. Verify UUID

The filesystem UUID was confirmed using:

sudo blkid /dev/nvme0n3p1

Result:

UUID="b80c92b7-0c0a-46d9-ab90-4d1dc13d0152"
TYPE="ext4"
Why UUID?

Linux device names can change depending on device discovery/order.

For example, before reboot:

/dev/nvme0n3p1

After reboot:

/dev/nvme1n3p1

However, the filesystem UUID remained:

b80c92b7-0c0a-46d9-ab90-4d1dc13d0152

Therefore:

Device Name = Can Change
UUID         = Stable Filesystem Identity
5. Create Mount Point

Created a dedicated mount point:

sudo mkdir -p /data-day06

Verified:

ls -ld /data-day06
6. Perform Initial Manual Mount

The filesystem was initially mounted manually:

sudo mount /dev/nvme0n3p1 /data-day06

Verified using:

df -h /data-day06

Result:

Filesystem      Size  Used Avail Use% Mounted on
/dev/nvme0n3p1  7.8G   24K  7.4G   1% /data-day06
7. Write Test Data

A test file was created:

echo "Day 06 Persistent Mount Test" | sudo tee /data-day06/day06-test.txt

Verified:

cat /data-day06/day06-test.txt

Output:

Day 06 Persistent Mount Test
8. Unmount the Filesystem

The filesystem was unmounted:

sudo umount /data-day06

Verified:

findmnt /data-day06

No mount information was returned, confirming the filesystem was unmounted.

9. Configure /etc/fstab

A backup of the original configuration was created:

sudo cp /etc/fstab /etc/fstab.backup-day06

The following persistent mount entry was added:

UUID=b80c92b7-0c0a-46d9-ab90-4d1dc13d0152 /data-day06 ext4 defaults,nofail 0 2
/etc/fstab Entry Breakdown
UUID=...                 /data-day06    ext4    defaults,nofail    0    2
│                        │              │       │                  │    │
│                        │              │       │                  │    └─ fsck order
│                        │              │       │                  └──── dump
│                        │              │       └────────────────────── mount options
│                        │              └────────────────────────────── filesystem type
│                        └──────────────────────────────────────────── mount point
└──────────────────────────────────────────────────────────────────── filesystem identity
10. Why nofail?

The nofail option allows the system to continue booting even if the optional data disk cannot be mounted.

Conceptually:

Without nofail:

VM Boot
   ↓
fstab
   ↓
Disk unavailable
   ↓
Mount failure
   ↓
Potential boot issue

With nofail:

VM Boot
   ↓
fstab
   ↓
Disk unavailable
   ↓
Mount skipped/failed
   ↓
System continues booting

For production systems, this should be combined with proper monitoring and application health checks.

11. Validate /etc/fstab

The configuration was validated:

sudo findmnt --verify

Initial validation produced a systemd reload warning because /etc/fstab had just been modified:

your fstab has been modified, but systemd still uses the old version

However, the validation showed:

0 parse errors, 0 errors

After reboot, final validation confirmed:

Success, no errors or warnings detected
12. Test mount -a

The filesystem was mounted using the configuration from /etc/fstab:

sudo mount -a

Then verified:

findmnt /data-day06

Result:

TARGET       SOURCE          FSTYPE
/data-day06  /dev/nvme0n3p1  ext4

This confirmed that Linux could resolve the UUID from /etc/fstab and mount the filesystem.

13. Reboot Persistence Test

The VM was rebooted:

sudo reboot

After reconnecting through SSH, the persistent mount was verified:

findmnt /data-day06

Result:

TARGET       SOURCE          FSTYPE
/data-day06  /dev/nvme1n3p1  ext4

Notice the important change:

Before reboot:
 /dev/nvme0n3p1

After reboot:
 /dev/nvme1n3p1

The device name changed, but the filesystem remained correctly mounted.

This proves that /etc/fstab was using the UUID rather than relying on the device path.

14. Verify Storage Capacity
df -h /data-day06

Result:

Filesystem      Size  Used Avail Use% Mounted on
/dev/nvme1n3p1  7.8G   28K  7.4G   1% /data-day06
15. Verify Data Persistence

The previously created test file was still available:

cat /data-day06/day06-test.txt

Output:

Day 06 Persistent Mount Test

This confirms that the filesystem was mounted automatically after reboot and the stored data remained available.

16. Final Validation

Final verification:

sudo findmnt --verify

Result:

Success, no errors or warnings detected

Additional validation:

findmnt /data-day06
df -h /data-day06
cat /data-day06/day06-test.txt

All checks passed successfully.

🧠 Key Learnings
1. Device names are not reliable identifiers
/dev/nvme0n3p1

can become:

/dev/nvme1n3p1

after reboot or device enumeration changes.

2. UUID provides filesystem identity
UUID=b80c92b7-0c0a-46d9-ab90-4d1dc13d0152

remains associated with the filesystem.

3. /etc/fstab provides persistent mount configuration
/etc/fstab
     ↓
VM boot
     ↓
UUID resolution
     ↓
Filesystem mount
     ↓
/data-day06
4. mount -a is an important validation step

Before rebooting after changing /etc/fstab:

sudo mount -a

should be used to detect configuration problems.

5. Always back up /etc/fstab
sudo cp /etc/fstab /etc/fstab.backup-day06

This is a useful operational safety practice.

🎯 Day 6 Success Criteria

Added a new Azure managed disk

Detected the disk from Linux

Created partition

Created ext4 filesystem

Retrieved filesystem UUID

Created mount point

Performed manual mount

Tested filesystem with real data

Unmounted filesystem

Backed up /etc/fstab

Configured UUID-based persistent mount

Validated /etc/fstab

Tested mount -a

Rebooted the VM

Verified automatic mounting after reboot

Verified test data after reboot

Confirmed final findmnt --verify success

🏆 Final Result
Azure Managed Disk
       ↓
/dev/nvme0n3
       ↓
/dev/nvme0n3p1
       ↓
ext4
       ↓
UUID
       ↓
/etc/fstab
       ↓
/data-day06
       ↓
Automatic Mount After Reboot ✅

Day 6 Status: COMPLETED ✅