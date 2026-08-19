Azure Managed Disk Cheatsheet

Quick reference for Azure Managed Disks used with Linux Virtual Machines.

☁️ Azure Storage Architecture
Azure Subscription
       ↓
Resource Group
       ↓
Virtual Machine
       ↓
Managed Disk
       ↓
Linux VM
       ↓
Block Device
       ↓
Partition
       ↓
Filesystem
       ↓
Mountpoint
💽 Managed Disk Types

Common Azure Managed Disk performance tiers include:

Standard HDD
Standard SSD
Premium SSD
Premium SSD v2
Ultra Disk

Choose the disk type based on:

Workload
IOPS requirements
Throughput
Latency
Availability requirements
Cost
🖥️ Azure VM Disk Roles

Typical VM storage:

OS Disk
   ↓
Operating System

Data Disk
   ↓
Application / Database Data

Temporary Disk
   ↓
Temporary / Cache Workloads

Do not treat temporary storage as durable application storage.

🔍 Linux Disk Discovery

After attaching an Azure Managed Disk:

lsblk

Filesystem information:

lsblk -f

Device information:

sudo fdisk -l

UUID:

sudo blkid

Mount information:

findmnt
🧭 Identify a New Disk

Recommended workflow:

lsblk

Compare disk state before and after attaching the Azure disk.

Example:

Before
  ↓
OS Disk

After
  ↓
OS Disk
Data Disk

Never assume the device name without verification.

🧱 Partition a Data Disk

Example device:

/dev/nvme0n2

Create GPT:

sudo parted -s /dev/nvme0n2 mklabel gpt

Create partition:

sudo parted -s /dev/nvme0n2 mkpart primary ext4 0% 100%

Verify:

lsblk
🗃️ Create Filesystem

Example:

sudo mkfs.ext4 /dev/nvme0n2p1

Verify:

sudo blkid /dev/nvme0n2p1
📍 Mount Azure Data Disk

Create mountpoint:

sudo mkdir -p /data

Mount:

sudo mount /dev/nvme0n2p1 /data

Verify:

findmnt /data
df -hT /data
🔐 Persistent Mount

Get UUID:

sudo blkid /dev/nvme0n2p1

Add to:

sudo nano /etc/fstab

Example:

UUID=<UUID> /data ext4 defaults,nofail 0 2

Test:

sudo mount -a

Verify:

findmnt /data
📈 Azure Disk Expansion

General expansion workflow:

Check Current Disk
       ↓
Increase Azure Disk Size
       ↓
Linux Detects New Capacity
       ↓
Expand Partition if Required
       ↓
Expand LVM if Used
       ↓
Expand Filesystem
       ↓
Verify

Always verify the current state first:

lsblk
df -hT
🧮 Storage Capacity Verification

Check block devices:

lsblk

Check filesystem:

df -hT

Check inode capacity:

df -ih

Check mount:

findmnt
🛠️ Azure CLI Reference

Login:

az login

Show subscription:

az account show

List managed disks:

az disk list --output table

Show a disk:

az disk show \
  --resource-group <RESOURCE_GROUP> \
  --name <DISK_NAME>

List VMs:

az vm list --output table

Show VM:

az vm show \
  --resource-group <RESOURCE_GROUP> \
  --name <VM_NAME>

List VM disks:

az vm show \
  --resource-group <RESOURCE_GROUP> \
  --name <VM_NAME> \
  --query "storageProfile.dataDisks"
📊 Disk Information to Check

When evaluating a Managed Disk, check:

[ ] Disk size
[ ] Disk SKU
[ ] Provisioning state
[ ] Encryption configuration
[ ] VM attachment
[ ] Performance requirements
[ ] Backup requirements
[ ] Availability requirements
🛡️ Production Best Practices
1. Use Data Disks for Application Data

Keep important application/database data separated from the OS disk when the architecture requires it.

2. Choose the Correct Performance Tier

Do not select a disk type only based on capacity.

Consider:

IOPS
Throughput
Latency
Workload
Cost
3. Use Persistent Mounts

Prefer UUID-based /etc/fstab entries.

4. Monitor Capacity

Monitor:

df -hT
df -ih
5. Backup Critical Data

Disk storage does not replace a backup strategy.

6. Validate Before Changes

Always identify:

lsblk -f
blkid
findmnt

before performing storage operations.

🚨 Troubleshooting
Disk not visible

Check:

lsblk
dmesg | tail -50

Check the VM's attached disks from Azure.

Filesystem not mounted

Check:

findmnt

Test fstab:

sudo mount -a

Check logs:

sudo journalctl -xe
Disk appears full

Check:

df -hT

Then:

sudo du -xhd1 /data | sort -h
Inodes exhausted
df -ih

Find directories containing many files:

sudo find /data -xdev -type f | cut -d/ -f1-4 | sort | uniq -c | sort -n
🔄 Azure → Linux Validation

After attaching or resizing a disk:

lsblk

Then:

sudo fdisk -l

Then:

df -hT

Then:

findmnt

For LVM:

sudo pvs
sudo vgs
sudo lvs
🎯 Complete Azure Storage Workflow
Azure Managed Disk
        ↓
Attach to VM
        ↓
Linux Disk Discovery
        ↓
Partition
        ↓
Filesystem
        ↓
Mount
        ↓
fstab
        ↓
Application / Database
        ↓
Monitoring
        ↓
Backup
        ↓
Expansion
        ↓
Validation
⚠️ Safety Reminder

Storage operations can permanently destroy data.

Before operations such as:

parted
fdisk
mkfs
pvcreate
lvcreate
lvremove
resize

always verify the target device and ensure required backups exist.

📌 Quick Command Reference
Task	Command
List disks	lsblk
Filesystem info	lsblk -f
UUID	blkid
Disk usage	df -hT
Inodes	df -ih
Mounts	findmnt
Partition	fdisk / parted
Filesystem	mkfs.ext4
Azure disks	az disk list
Azure VM	az vm list
Disk details	az disk show
VM details	az vm show