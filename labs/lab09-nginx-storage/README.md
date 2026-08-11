# Lab 09 — Production-Style NGINX Storage Integration

> **Azure Linux Storage Engineering Series**
>
> **Level:** Infrastructure Engineer → Senior DevOps / Platform Engineer
>
> **Workload:** NGINX
>
> **Storage Model:** LVM-backed Application + Dedicated Log Storage

---

# 1. Lab Objective

This lab integrates an NGINX workload with dedicated Linux storage.

The implementation uses two independent logical volumes:

```text
lvapp
  |
  v
/data/app
  |
  v
/data/app/nginx
  |
  v
NGINX Web Content
```

and:

```text
lvlogs
  |
  v
/data/logs
  |
  v
/data/logs/nginx
  |
  +---- access.log
  |
  +---- error.log
```

The lab demonstrates application/storage integration rather than simply
installing a web server.

---

# 2. Architecture

```text
                     Azure Linux VM
                           |
                           v
                    Data Managed Disk
                           |
                           v
                     /dev/nvme1n1
                           |
                           v
                    LVM Physical Volume
                           |
                           v
                        vgdata
                       /      \
                      /        \
                     v          v
                  lvapp       lvlogs
                    |            |
                    v            v
               /data/app     /data/logs
                    |            |
                    v            v
              /data/app/nginx  /data/logs/nginx
                    |            |
                    v        +---+---+
                 index.html  |       |
                    |        v       v
                    |   access.log error.log
                    |
                    v
                  NGINX
                    |
                    v
                HTTP :80
                    |
                    v
                  Client
```

---

# 3. Prerequisites

Verify:

```bash
lsblk -f
```

```bash
sudo pvs
```

```bash
sudo vgs
```

```bash
sudo lvs
```

```bash
df -hT /data/app
```

```bash
df -hT /data/logs
```

```bash
findmnt /data/app
```

```bash
findmnt /data/logs
```

Do not modify the LVM structure unnecessarily if the Day 7/Day 8 storage
architecture is already present.

---

# 4. Verify NGINX

```bash
nginx -v
```

If required:

```bash
sudo apt update
sudo apt install nginx -y
```

---

# 5. Verify Service

```bash
sudo systemctl status nginx --no-pager
```

Enable:

```bash
sudo systemctl enable nginx
```

Validate:

```bash
systemctl is-enabled nginx
```

```bash
systemctl is-active nginx
```

Expected:

```text
enabled
active
```

---

# 6. Create Application Directory

```bash
sudo mkdir -p /data/app/nginx
```

Verify:

```bash
ls -ld /data/app/nginx
```

---

# 7. Create Log Directory

```bash
sudo mkdir -p /data/logs/nginx
```

Verify:

```bash
sudo ls -ld /data/logs/nginx
```

---

# 8. Deploy Test Application

```bash
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
```

Validate:

```bash
cat /data/app/nginx/index.html
```

---

# 9. Configure Ownership

Application:

```bash
sudo chown -R www-data:www-data /data/app/nginx
```

Logs:

```bash
sudo chown -R www-data:adm /data/logs/nginx
```

Validate:

```bash
ls -ld /data/app/nginx
```

```bash
sudo ls -ld /data/logs/nginx
```

---

# 10. Configure NGINX

Edit:

```bash
sudo nano /etc/nginx/sites-available/default
```

Use:

```nginx
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
```

Save and exit.

---

# 11. Validate Configuration

Run:

```bash
sudo nginx -t
```

Expected:

```text
syntax is ok
test is successful
```

Reload:

```bash
sudo systemctl reload nginx
```

---

# 12. Verify Loaded Configuration

```bash
sudo nginx -T 2>/dev/null | grep -E 'access_log|error_log|root '
```

Expected:

```text
root /data/app/nginx;
access_log /data/logs/nginx/access.log;
error_log /data/logs/nginx/error.log;
```

This confirms that the active NGINX configuration points to the intended
storage.

---

# 13. Test Application

```bash
curl http://localhost
```

Then:

```bash
curl -I http://localhost
```

Expected:

```text
HTTP/1.1 200 OK
```

---

# 14. Validate Access Logging

Generate traffic:

```bash
curl http://localhost
```

Check:

```bash
sudo tail -n 10 /data/logs/nginx/access.log
```

Expected pattern:

```text
"GET / HTTP/1.1" 200
```

This proves that the request reached NGINX and the log was written to the
dedicated log filesystem.

---

# 15. Validate Error Logging

```bash
sudo tail -n 10 /data/logs/nginx/error.log
```

An empty file is acceptable if no errors have occurred.

Verify file:

```bash
sudo ls -lah /data/logs/nginx
```

Expected:

```text
access.log
error.log
```

---

# 16. Verify Application Storage

```bash
df -hT /data/app
```

```bash
findmnt /data/app
```

```bash
sudo ls -lah /data/app/nginx
```

The application must be stored under:

```text
/data/app/nginx
```

---

# 17. Verify Log Storage

```bash
df -hT /data/logs
```

```bash
findmnt /data/logs
```

```bash
sudo ls -lah /data/logs/nginx
```

The logs must be stored under:

```text
/data/logs/nginx
```

---

# 18. Verify LVM

```bash
sudo pvs
```

```bash
sudo vgs
```

```bash
sudo lvs
```

Expected logical volumes:

```text
lvapp
lvlogs
```

---

# 19. Full Validation Script

Run:

```bash
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

echo "===== NGINX ====="

sudo nginx -t

systemctl is-enabled nginx
systemctl is-active nginx

echo "===== WEB ====="

curl -I http://localhost

echo "===== APPLICATION ====="

sudo ls -lah /data/app/nginx

echo "===== LOGS ====="

sudo ls -lah /data/logs/nginx
sudo tail -n 5 /data/logs/nginx/access.log
sudo tail -n 5 /data/logs/nginx/error.log
```

---

# 20. Expected Validation

```text
NGINX CONFIG
    |
    +---- root /data/app/nginx
    |
    +---- access_log /data/logs/nginx/access.log
    |
    +---- error_log /data/logs/nginx/error.log


STORAGE
    |
    +---- vgdata
          |
          +---- lvapp
          |
          +---- lvlogs


MOUNTS
    |
    +---- /data/app
    |
    +---- /data/logs


SERVICE
    |
    +---- enabled
    |
    +---- active


WEB
    |
    +---- HTTP 200 OK


LOGGING
    |
    +---- access.log generated
    |
    +---- error.log available
```

---

# 21. Troubleshooting

## Problem: Access log does not exist

Check active configuration:

```bash
sudo nginx -T 2>/dev/null | grep access_log
```

Generate traffic:

```bash
curl http://localhost
```

Check:

```bash
sudo ls -lah /data/logs/nginx
```

---

## Problem: HTTP 404

Check:

```bash
sudo nginx -T 2>/dev/null | grep "root "
```

Verify:

```bash
ls -lah /data/app/nginx
```

Confirm:

```text
index.html
```

exists.

---

## Problem: NGINX fails to reload

Run:

```bash
sudo nginx -t
```

Then:

```bash
sudo systemctl status nginx --no-pager
```

Review:

```bash
sudo journalctl -u nginx -n 50 --no-pager
```

---

## Problem: Correct directory but wrong filesystem

This is a common storage troubleshooting issue.

Check:

```bash
findmnt /data/app
```

and:

```bash
df -hT /data/app
```

Do not assume that because `/data/app` exists, the intended disk is mounted.

---

# 22. Production Engineering Notes

## Application Isolation

The application is separated from the OS root filesystem.

## Log Isolation

Logs have an independent filesystem.

## Capacity Management

LVM allows future capacity management without redesigning the application
directory structure.

## Operational Safety

NGINX configuration is validated before reload.

## Observability

Application traffic generates persistent access logs.

## Failure Domains

`lvapp` and `lvlogs` provide filesystem-level isolation, but both still depend
on the underlying disk and volume group.

---

# 23. Important LVM Operational Rule

Always validate three different layers:

```text
LV
 |
 +---- sudo lvs


Filesystem
 |
 +---- df -hT


Mount
 |
 +---- findmnt
```

Example:

```bash
sudo lvs
df -hT /data/app
findmnt /data/app
```

A successful `lvextend` does not necessarily mean the filesystem has already
grown.

For ext4:

```bash
sudo resize2fs /dev/vgdata/lvapp
```

Then:

```bash
df -hT /data/app
```

This distinction is critical during production storage expansion.

---

# 24. Evidence Checklist

Save screenshots under:

```text
screenshots/lab09/
```

Recommended evidence:

### Screenshot 1 — Storage

Show:

```bash
sudo pvs
sudo vgs
sudo lvs
```

### Screenshot 2 — Mounts

Show:

```bash
df -hT /data/app
df -hT /data/logs
findmnt /data/app
findmnt /data/logs
```

### Screenshot 3 — NGINX Configuration

Show:

```bash
sudo nginx -T 2>/dev/null | grep -E 'access_log|error_log|root '
```

### Screenshot 4 — Service

Show:

```bash
sudo nginx -t
systemctl is-enabled nginx
systemctl is-active nginx
```

### Screenshot 5 — Application

Show:

```bash
curl -I http://localhost
```

### Screenshot 6 — Logs

Show:

```bash
sudo ls -lah /data/logs/nginx
sudo tail -n 5 /data/logs/nginx/access.log
```

---

# 25. Final Result

The completed workload is:

```text
                 NGINX
                   |
          +--------+--------+
          |                 |
          v                 v
    Application          Logging
          |                 |
          v                 v
 /data/app/nginx    /data/logs/nginx
          |                 |
          v                 v
       lvapp             lvlogs
          \                 /
           \               /
            +---- vgdata --+
                   |
                   v
             /dev/nvme1n1
```

The architecture demonstrates a clear relationship between:

```text
Cloud Storage
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
Application
      ↓
Service
      ↓
HTTP + Logs
```

---

# 26. Day 9 Completion Criteria

Day 9 is considered complete when all of the following are true:

* [x] NGINX installed
* [x] NGINX enabled
* [x] NGINX active
* [x] LVM verified
* [x] Application filesystem verified
* [x] Log filesystem verified
* [x] NGINX root moved to `/data/app/nginx`
* [x] Access log moved to `/data/logs/nginx`
* [x] Error log moved to `/data/logs/nginx`
* [x] NGINX configuration validated
* [x] HTTP `200 OK` verified
* [x] Access log generated
* [x] Persistent storage verified
* [x] Evidence screenshots captured
* [x] Documentation completed

---

# 27. Engineering Takeaway

The main lesson of this lab is:

> **Infrastructure engineering is not just about making an application run. It is about designing where the application stores data, how that storage is isolated, how it grows, how it is monitored, and what happens when a component fails.**

Day 9 therefore connects the previous storage fundamentals with an actual
Linux application workload.

```text
Storage Engineering
        +
Linux Engineering
        +
Application Engineering
        +
Operational Validation
        =
Production Infrastructure Engineering
```
