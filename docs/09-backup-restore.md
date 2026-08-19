Day 9 — NGINX Storage Integration & Production Storage Architecture

Azure Linux Storage Engineering — Day 9

Focus: Linux Application Storage, LVM-backed NGINX Storage, Dedicated Log Storage, Service Integration, Validation, Capacity Planning and Production Design

1. Executive Summary

Day 9 integrates a Linux web workload with the persistent storage architecture established during the previous storage labs.

The workload used in this lab is NGINX running on an Azure Linux Virtual Machine.

Instead of using the operating system's default filesystem locations for application content and logs, the workload is explicitly mapped to dedicated LVM-backed filesystems:

Application Content
        |
        v
/data/app/nginx
        |
        v
/dev/mapper/vgdata-lvapp


Application Logs
        |
        v
/data/logs/nginx
        |
        v
/dev/mapper/vgdata-lvlogs

The underlying storage architecture is:

Azure Managed Disk
        |
        v
/dev/nvme1n1
        |
        v
LVM Physical Volume
        |
        v
Volume Group: vgdata
        |
        +----------------------+
        |                      |
        v                      v
     lvapp                  lvlogs
        |                      |
        v                      v
  /data/app               /data/logs
        |                      |
        v                      v
 /data/app/nginx       /data/logs/nginx
        |                      |
        |              +-------+-------+
        |              |               |
        |              v               v
        |          access.log      error.log
        |
        v
     NGINX
        |
        v
     HTTP :80

The key engineering principle demonstrated in this lab is:

Application workloads should have explicitly designed storage boundaries rather than depending blindly on the OS root filesystem.

2. Engineering Objectives

The objective of this lab is not simply to "install NGINX".

The engineering objectives are:

Integrate an application with dedicated persistent storage.
Separate application content from the OS filesystem.
Separate application logs from application data.
Use LVM as the storage abstraction layer.
Validate storage before application integration.
Configure NGINX against explicit storage paths.
Validate configuration before service reload.
Validate application availability after configuration.
Confirm that application requests generate persistent logs.
Verify that the service is backed by the intended filesystems.
Establish a foundation for storage monitoring and capacity planning.
3. Why This Architecture Matters

A common beginner architecture is:

Linux VM
   |
   +-- /
       |
       +-- /var/www/html
       |
       +-- /var/log/nginx

This creates a potential failure domain:

Application Growth
       +
Log Growth
       |
       v
Root Filesystem
       |
       v
Filesystem Exhaustion
       |
       v
Application / OS Impact

For infrastructure engineering, this is undesirable.

A more controlled design is:

OS
 |
 +---- Root filesystem

Application
 |
 +---- Dedicated application filesystem

Logs
 |
 +---- Dedicated log filesystem

This provides better:

Capacity isolation
Troubleshooting
Expansion planning
Monitoring
Backup planning
Operational control
4. Environment
Cloud Platform

Microsoft Azure

Compute

Azure Linux Virtual Machine

Operating System

Ubuntu Linux

Application

NGINX

Storage

Linux LVM

Block Device
/dev/nvme1n1
Volume Group
vgdata
Logical Volumes
lvapp
lvlogs
Mount Points
/data/app
/data/logs
NGINX Application Root
/data/app/nginx
NGINX Log Directory
/data/logs/nginx
5. Current Storage Architecture

The existing storage topology was verified before integrating NGINX.

lsblk -f

The relevant device is:

nvme1n1
└── LVM2_member
    ├── vgdata-lvapp
    │   └── /data/app
    │
    └── vgdata-lvlogs
        └── /data/logs

This gives the application a logical storage abstraction rather than directly depending on the physical device.

6. Storage Layer Validation
6.1 Physical Volume
sudo pvs

Observed architecture:

PV            VG
/dev/nvme1n1  vgdata

The important relationship is:

/dev/nvme1n1
       |
       v
Physical Volume
       |
       v
vgdata
7. Volume Group
sudo vgs

The volume group is:

vgdata

The volume group acts as the capacity pool from which logical volumes are allocated.

Conceptually:

vgdata
|
+---- lvapp
|
+---- lvlogs
|
+---- Free Capacity

This is one of the major advantages of LVM.

Storage capacity can be managed at the volume-group level instead of treating every filesystem as an isolated physical disk.

8. Logical Volume Design
sudo lvs

Current logical volumes:

lvapp
lvlogs

The design intentionally separates:

lvapp
 |
 +-- application content


lvlogs
 |
 +-- application logs

This separation gives independent storage boundaries.

9. Filesystem Validation

Application filesystem:

df -hT /data/app

Log filesystem:

df -hT /data/logs

Mount relationships:

findmnt /data/app
findmnt /data/logs

Expected:

/data/app  -> /dev/mapper/vgdata-lvapp
/data/logs -> /dev/mapper/vgdata-lvlogs

This validation is important because the directory existing does not prove that the intended storage is mounted.

For example:

Directory exists
        !=
Correct filesystem mounted

A production engineer must verify both.

10. NGINX Installation

Verify installation:

nginx -v

If required:

sudo apt update
sudo apt install nginx -y

Verify:

nginx -v
11. Service Management

Check:

sudo systemctl status nginx --no-pager

Enable:

sudo systemctl enable nginx

Validate:

systemctl is-enabled nginx

Expected:

enabled

Validate runtime state:

systemctl is-active nginx

Expected:

active

The distinction is important:

enabled
   =
start automatically during boot


active
   =
currently running

A production engineer must understand both.

12. Application Storage Design

Create the application directory:

sudo mkdir -p /data/app/nginx

The final application hierarchy becomes:

/data/app
└── nginx
    └── index.html

This creates a clear ownership boundary:

/data/app
    |
    +---- Application Storage

/data/app/nginx
    |
    +---- NGINX Web Content
13. Log Storage Design

Create:

sudo mkdir -p /data/logs/nginx

Final hierarchy:

/data/logs
└── nginx
    ├── access.log
    └── error.log

This creates a dedicated logging boundary.

14. Permissions and Ownership

NGINX on Ubuntu normally runs using the www-data service account.

Application ownership:

sudo chown -R www-data:www-data /data/app/nginx

Log directory:

sudo chown -R www-data:adm /data/logs/nginx

Verify:

ls -ld /data/app/nginx
sudo ls -ld /data/logs/nginx

The principle is:

Give the service the permissions it requires, but do not unnecessarily grant broad filesystem access.

15. Application Deployment

Create a test application:

sudo tee /data/app/nginx/index.html > /dev/null <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Azure Linux Storage Engineering</title>
</head>
<body>
    <h1>Day 9 - NGINX Storage Lab</h1>
    <p>NGINX web content is stored on persistent LVM-backed storage.</p>
</body>
</html>
EOF

Verify:

cat /data/app/nginx/index.html

The application artifact is now physically stored under:

/data/app/nginx
16. NGINX Configuration

Configuration file:

/etc/nginx/sites-available/default

Final server configuration:

server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /data/app/nginx;

    index index.html;

    server_name _;

    access_log /data/logs/nginx/access.log;
    error_log /data/logs/nginx/error.log;

    location / {
        try_files $uri $uri/ =404;
    }
}
17. Configuration Breakdown
Listener
listen 80 default_server;

NGINX listens for HTTP traffic on port 80.

IPv6 Listener
listen [::]:80 default_server;

Allows the server block to accept IPv6 traffic.

Application Root
root /data/app/nginx;

This is the most important storage integration point.

NGINX no longer serves content from:

/var/www/html

Instead:

NGINX
  |
  v
/data/app/nginx
  |
  v
LVM-backed filesystem
Access Logging
access_log /data/logs/nginx/access.log;

Every successful HTTP request is written to the dedicated log filesystem.

Error Logging
error_log /data/logs/nginx/error.log;

NGINX operational errors are written to the dedicated log filesystem.

18. Why Configuration Validation Comes First

Never blindly reload a production service after editing configuration.

Correct operational workflow:

Edit Configuration
        |
        v
nginx -t
        |
        +---- FAIL ----> Fix Configuration
        |
       PASS
        |
        v
systemctl reload nginx
        |
        v
Application Validation

Run:

sudo nginx -t

Expected:

syntax is ok
test is successful

Only then:

sudo systemctl reload nginx
19. Active Configuration Verification

Use:

sudo nginx -T 2>/dev/null | grep -E 'access_log|error_log|root '

Expected active configuration:

root /data/app/nginx;

access_log /data/logs/nginx/access.log;

error_log /data/logs/nginx/error.log;

This is stronger than simply checking the configuration file because:

/etc/nginx/sites-available/default

may contain a configuration that is not actually active.

nginx -T shows the configuration NGINX has loaded.

20. HTTP Application Validation

Generate a request:

curl http://localhost

Validate HTTP headers:

curl -I http://localhost

Observed:

HTTP/1.1 200 OK

This validates:

Client
  |
  v
NGINX
  |
  v
/data/app/nginx/index.html
  |
  v
HTTP 200
21. Access Log Validation

Generate request:

curl http://localhost

Read log:

sudo tail -n 10 /data/logs/nginx/access.log

Observed example:

::1 - - [11/Aug/2026:10:48:50 +0000] "GET / HTTP/1.1" 200 239 "-" "curl/8.5.0"

This proves the complete chain:

HTTP Request
      |
      v
NGINX
      |
      v
Application Response
      |
      v
Access Log
      |
      v
/data/logs/nginx/access.log
22. Error Log Validation
sudo tail -n 10 /data/logs/nginx/error.log

The file exists even if there are currently no errors.

An empty error log during a successful test is expected.

Important distinction:

Empty error.log
        !=
Logging broken

Validate the configuration first:

sudo nginx -T 2>/dev/null | grep error_log

Then validate file creation:

sudo ls -lah /data/logs/nginx
23. Storage Validation After Application Integration

After NGINX is configured, verify that the application is actually using the intended filesystems.

df -hT /data/app
df -hT /data/logs

Then:

findmnt /data/app
findmnt /data/logs

Finally:

sudo lvs

The validation chain becomes:

LVM
 |
 v
Logical Volume
 |
 v
Filesystem
 |
 v
Mount Point
 |
 v
Application Directory
 |
 v
NGINX
24. Current Lab State

The actual Day 9 validation demonstrated:

NGINX root:
    /data/app/nginx

NGINX access log:
    /data/logs/nginx/access.log

NGINX error log:
    /data/logs/nginx/error.log

NGINX configuration:
    syntax valid

NGINX service:
    active

NGINX boot state:
    enabled

HTTP:
    200 OK

Access logging:
    working
25. Important Capacity Observation

During the previous LVM expansion exercise, the logical volume and filesystem sizes must always be validated independently.

For example:

sudo lvs
df -hT /data/app

These commands answer different questions.

lvs

Shows:

Logical Volume Size
df

Shows:

Filesystem Size

Therefore:

LV size
   !=
automatically guaranteed filesystem size

This is an important Linux storage engineering concept.

After an LV expansion, the filesystem may also require an explicit filesystem resize.

For ext4:

sudo resize2fs /dev/vgdata/lvapp

Then validate:

df -hT /data/app

For future production work, always verify both layers.

26. Storage Failure Domain

The current architecture separates:

OS
 |
 +---- root filesystem


Application
 |
 +---- lvapp


Logs
 |
 +---- lvlogs

However, the application and logs still depend on the underlying storage device:

/dev/nvme1n1
      |
      v
    vgdata
    /   \
 lvapp  lvlogs

Therefore, if the underlying managed disk becomes unavailable:

Disk Failure
     |
     v
LVM unavailable
     |
     +---- lvapp unavailable
     |
     +---- lvlogs unavailable

This is why production architecture must consider:

Managed disk redundancy
Backup
Snapshots
Replication
Availability requirements
Recovery objectives

Dedicated logical volumes provide isolation, not automatic high availability.

27. Capacity Planning

A production engineer should monitor:

Filesystem Capacity
Filesystem Inodes
LV Free Space
VG Free Space
Disk IOPS
Disk Throughput
Latency
Log Growth
Application Growth

Useful commands:

df -h
df -i
sudo lvs
sudo vgs
lsblk

For the application:

du -sh /data/app/nginx

For logs:

sudo du -sh /data/logs/nginx

A simple operational model is:

Current Usage
      +
Expected Growth
      +
Safety Buffer
      =
Required Capacity
28. Log Growth Risk

NGINX access logs can grow continuously.

For example:

Client Requests
      |
      v
access.log
      |
      v
Storage Growth
      |
      v
Filesystem Capacity
      |
      v
Potential Full Filesystem

Therefore production environments should implement:

logrotate
Retention policies
Compression
Monitoring
Alerts
Centralized logging

This lab deliberately keeps log rotation as a later operational topic.

29. Security Considerations

The application directory should not be made world-writable.

Avoid:

chmod -R 777 /data/app/nginx

This would weaken the security boundary.

Instead, use controlled ownership and permissions.

Verify:

namei -l /data/app/nginx

Also review:

ls -ld /data/app
ls -ld /data/app/nginx

The goal is:

Minimum Required Access
        |
        v
Service Account
        |
        v
Required Application Path
30. Operational Troubleshooting Model

When NGINX fails after a storage change, troubleshoot layer by layer.

Layer 1
Operating System
       |
       v
Layer 2
Block Device
       |
       v
Layer 3
LVM
       |
       v
Layer 4
Filesystem
       |
       v
Layer 5
Mount
       |
       v
Layer 6
Application Directory
       |
       v
Layer 7
NGINX Configuration
       |
       v
Layer 8
NGINX Service
       |
       v
Layer 9
HTTP Application

Useful commands:

lsblk
sudo pvs
sudo vgs
sudo lvs
df -hT
findmnt
sudo nginx -t
systemctl status nginx
curl -I http://localhost

This layered troubleshooting approach is much more reliable than randomly
restarting services.

31. Production Readiness Checklist
Storage

Dedicated application filesystem

Dedicated log filesystem

LVM-backed storage

Mount points verified

Filesystem type verified

NGINX

Installed

Enabled

Active

Configuration validated

Application root configured

Access log configured

Error log configured

Application

Test application deployed

HTTP request successful

HTTP 200 verified

Logging

Access log generated

Error log path configured

Log storage verified

Operations

Configuration test performed

Service state verified

Storage state verified

Future Production Enhancements

Log rotation

Filesystem monitoring

Alerting

Backup

Centralized logging

TLS

High availability

Capacity alerts

Disaster recovery validation

32. Final Validation Command Set

Use this as the Day 9 production-style validation bundle:

echo "===== NGINX CONFIG ====="

sudo nginx -T 2>/dev/null | grep -E 'access_log|error_log|root '

echo "===== STORAGE ====="

sudo pvs
sudo vgs
sudo lvs

df -hT /data/app
df -hT /data/logs

echo "===== MOUNTS ====="

findmnt /data/app
findmnt /data/logs

echo "===== NGINX SERVICE ====="

sudo nginx -t

systemctl is-enabled nginx
systemctl is-active nginx

echo "===== APPLICATION ====="

curl -I http://localhost

echo "===== APPLICATION STORAGE ====="

sudo ls -lah /data/app/nginx

echo "===== LOG STORAGE ====="

sudo ls -lah /data/logs/nginx

echo "===== ACCESS LOG ====="

sudo tail -n 5 /data/logs/nginx/access.log

echo "===== ERROR LOG ====="

sudo tail -n 5 /data/logs/nginx/error.log
33. Final Architecture
                         AZURE
                           |
                           v
                    Linux Virtual Machine
                           |
             +-------------+-------------+
             |                           |
             v                           v
        OS Root Disk               Managed Data Disk
             |                           |
             v                           v
        / filesystem              /dev/nvme1n1
                                         |
                                         v
                                  LVM Physical Volume
                                         |
                                         v
                                      vgdata
                                    /        \
                                   /          \
                                  v            v
                               lvapp        lvlogs
                                  |            |
                                  v            v
                             /data/app     /data/logs
                                  |            |
                                  v            v
                           /data/app/nginx /data/logs/nginx
                                  |            |
                                  |        +---+---+
                                  |        |       |
                                  |        v       v
                                  |    access.log error.log
                                  |
                                  v
                                NGINX
                                  |
                                  v
                              HTTP :80
                                  |
                                  v
                               Client
34. Engineering Takeaways

The important lesson of Day 9 is not NGINX itself.

The important lesson is application-aware storage architecture.

A production infrastructure engineer should understand:

Where is the application data?
Where are the logs?
Which filesystem owns the data?
Which LV backs the filesystem?
Which disk backs the LV?
What happens when capacity reaches 80%?
What happens when the disk fails?
How is the data backed up?
How is the filesystem expanded?
How are logs rotated?
How is storage monitored?

This is the difference between:

Running a Linux command

and:

Engineering an infrastructure workload.
35. Day 9 Outcome

Day 9 successfully demonstrated:

Azure Managed Storage
        ↓
Linux Block Device
        ↓
LVM
        ↓
Logical Volume
        ↓
Filesystem
        ↓
Mount Point
        ↓
NGINX Application Storage
        ↓
HTTP Workload

and:

NGINX
  ↓
Dedicated Log Path
  ↓
LVM-backed Log Filesystem
  ↓
Persistent Access/Error Logs

The lab establishes the foundation for the next workload-focused storage
labs, where application data persistence, database storage, backup,
monitoring and recovery become increasingly important.