# Linux Process Troubleshooting: Apache Service Fix (Stratos DC)


## Problem

Apache (`httpd`) service reported unavailable on app servers in **Stratos DC**. Fix the issue and ensure `httpd` is running on the assigned port on all app servers.

## Server Details

| Hostname | User | Password | IP |
| :--- | :--- | :--- | :--- |
| stapp01 | tony | Ir0nM@n | 172.16.238.10 |
| stapp02 | steve | Am3r!ca | 172.16.238.11 |
| stapp03 | banner | BigB@ng | 172.16.238.12 |

## Root Cause

1. `httpd` service not started or not enabled on boot
2. `/etc/httpd/conf/httpd.conf` set to `Listen 80` instead of the assigned port
3. Conflicting process occupying the assigned port

## Manual Fix

SSH into each server and run (replace `<PORT>` with the assigned port):

```bash
sudo sed -i 's/^Listen .*/Listen <PORT>/' /etc/httpd/conf/httpd.conf
sudo systemctl restart httpd
sudo systemctl enable httpd
```

## Automated Fix

Run from `jump-host`:

```bash
chmod +x troubleshoot_apache.sh
./troubleshoot_apache.sh <PORT>
```

## Verification

From `jump-host`:

```bash
curl -I http://stapp01:<PORT>
curl -I http://stapp02:<PORT>
curl -I http://stapp03:<PORT>
```

Expected: `HTTP/1.1 403 Forbidden` (Apache running, no content hosted).

