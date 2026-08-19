Linux Storage Commands Cheatsheet

Quick reference for commonly used Linux storage, filesystem, mounting, LVM, monitoring, and troubleshooting commands.

🔎 Disk & Block Device Discovery
List block devices
lsblk

Detailed filesystem information:

lsblk -f

Detailed device information:

lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS,UUID
🆔 Identify Filesystem UUID
blkid

Specific device:

blkid /dev/nvme0n2p1
💾 Disk Usage

Filesystem usage:

df -h

Filesystem type + usage:

df -hT

Inode usage:

df -ih
📦 Directory Usage

Current directory:

du -sh .

Directory breakdown:

du -h --max-depth=1

Root filesystem breakdown:

sudo du -xhd1 / | sort -h

/var breakdown:

sudo du -xhd1 /var | sort -h
🔗 Mount Information

Show mounted filesystems:

findmnt

Specific mountpoint:

findmnt /data

Filesystem table:

mount
📌 Mount a Filesystem

Create mountpoint:

sudo mkdir -p /data

Mount:

sudo mount /dev/nvme0n2p1 /data

Verify:

findmnt /data
df -hT /data
❌ Unmount
sudo umount /data

If the mount is busy, first identify processes:

sudo lsof +D /data

or:

sudo fuser -vm /data
🗂️ Partitioning
fdisk
sudo fdisk /dev/nvme0n2

List partition table:

sudo fdisk -l /dev/nvme0n2
parted

Create GPT:

sudo parted -s /dev/nvme0n2 mklabel gpt

Create partition:

sudo parted -s /dev/nvme0n2 mkpart primary ext4 0% 100%
🧱 Filesystem

Create ext4:

sudo mkfs.ext4 /dev/nvme0n2p1

Identify filesystem:

sudo blkid /dev/nvme0n2p1

Check filesystem:

sudo fsck -f /dev/nvme0n2p1

Never run filesystem creation or filesystem repair commands against the wrong device.

🔄 Persistent Mount

Edit:

sudo nano /etc/fstab

Validate:

sudo mount -a

Check:

findmnt
df -hT

Prefer UUID-based entries:

UUID=<filesystem-uuid> /data ext4 defaults,nofail 0 2
📈 Filesystem Expansion

For ext4:

sudo resize2fs /dev/<device>

If the filesystem is mounted, ext4 can normally be expanded online after the underlying block device/LV has been extended.

⚙️ Service Validation

Check service:

sudo systemctl status <service>

Check active state:

sudo systemctl is-active <service>

Restart:

sudo systemctl restart <service>

Enable at boot:

sudo systemctl enable <service>
📜 Logs

View service logs:

sudo journalctl -u <service>

Recent logs:

sudo journalctl -u <service> --since "1 hour ago"

Follow logs:

sudo journalctl -u <service> -f
📊 System Monitoring

Memory:

free -h

Load:

uptime

Processes:

ps aux

Disk I/O:

iostat -xz 1

iostat may require the sysstat package.

🛡️ Safe Storage Workflow

Before modifying storage:

lsblk -f
blkid
findmnt
df -hT

After modification:

lsblk -f
findmnt
df -hT

For production work:

Identify
   ↓
Verify
   ↓
Backup
   ↓
Change
   ↓
Validate
   ↓
Monitor