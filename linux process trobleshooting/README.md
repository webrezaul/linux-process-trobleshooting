# Linux Process Troubleshooting: Apache Service Unavailability in Stratos DC

[![DevOps](https://img.shields.io/badge/DevOps-KodeKloud-blue.svg)](https://kodekloud.com)
[![Linux](https://img.shields.io/badge/Linux-RHEL%2FCentOS-red.svg)](https://www.redhat.com)
[![Apache](https://img.shields.io/badge/Apache-httpd-brightgreen.svg)](https://httpd.apache.org)
[![Status](https://img.shields.io/badge/Status-Completed-success.svg)](#)

## 📋 Table of Contents
- [Problem Scenario](#-problem-scenario)
- [Target System Topology](#-target-system-topology)
- [Root Cause Analysis](#-root-cause-analysis)
- [Step-by-Step Troubleshooting Guide](#-step-by-step-troubleshooting-guide)
  - [1. Identify Faulty Host](#1-identify-faulty-host)
  - [2. Inspect & Resolve Config / Process Conflicts](#2-inspect--resolve-config--process-conflicts)
  - [3. Start & Enable Apache Service](#3-start--enable-apache-service)
- [Automated Solution Script](#-automated-solution-script)
- [Verification & Validation](#-verification--validation)
- [GitHub Deployment Commands](#-github-deployment-commands)

---

## 🚀 Problem Scenario

The production support team of **xFusionCorp Industries** deployed monitoring tools across all systems. A monitoring system reported **Apache service unavailability** on one of the application servers in **Stratos DC**.

### Key Requirements:
1. Identify the faulty app host and fix the underlying process/service issue.
2. Ensure the Apache service (`httpd`) is up and running on all app hosts (`stapp01`, `stapp02`, `stapp03`).
3. Ensure Apache is listening on the assigned port (**port 3002** / **port 5000** as required by the lab prompt) on all app servers.

---

## 🖥️ Target System Topology

| Hostname | Server IP | Default User | Default SSH Password | Target Service | Assigned Port |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **stapp01** | `172.16.238.10` | `tony` | `Ir0nM@n` | `httpd` | `3002` |
| **stapp02** | `172.16.238.11` | `steve` | `Am3r!ca` | `httpd` | `3002` |
| **stapp03** | `172.16.238.12` | `banner` | `BigB@ng` | `httpd` | `3002` |

---

## 🔍 Root Cause Analysis

During inspection, Apache service failures on application hosts typically stem from one of three issues:
1. **Service Inactive**: `httpd` is stopped or not set to automatically start on boot.
2. **Incorrect Configuration**: `/etc/httpd/conf/httpd.conf` is set to listen on default port `80` instead of target port `3002`.
3. **Port Conflict**: Another rogue process (or legacy service) is holding open the target port (`3002`), causing `httpd` startup to fail with `Address already in use`.

---

## 🛠️ Step-by-Step Troubleshooting Guide

### 1. Identify Faulty Host

From `jump-host` (`thor`), run `curl` against target port (e.g. `3002`) on all app servers:

```bash
curl -Iv http://stapp01:3002
curl -Iv http://stapp02:3002
curl -Iv http://stapp03:3002
```

---

### 2. Inspect & Resolve Config / Process Conflicts

SSH into each application server to check and remediate the configuration:

#### Host 1: `stapp01`
```bash
ssh tony@stapp01
# Password: Ir0nM@n

# Check httpd status
sudo systemctl status httpd

# Verify httpd configuration port
sudo grep -i "^Listen" /etc/httpd/conf/httpd.conf

# Update Listen port to 3002
sudo sed -i 's/^Listen .*/Listen 3002/' /etc/httpd/conf/httpd.conf

# Check if any conflicting process binds to port 3002
sudo ss -tulnp | grep :3002

# If a non-httpd process is found, kill it:
# sudo kill -9 <PID>

# Start & Enable Apache
sudo apachectl configtest
sudo systemctl restart httpd
sudo systemctl enable httpd
```

#### Host 2: `stapp02`
```bash
ssh steve@stapp02
# Password: Am3r!ca (Note: Single quote password in bash to avoid ! expansion)

# Update configuration & start service
sudo sed -i 's/^Listen .*/Listen 3002/' /etc/httpd/conf/httpd.conf
sudo systemctl restart httpd
sudo systemctl enable httpd
```

#### Host 3: `stapp03`
```bash
ssh banner@stapp03
# Password: BigB@ng

# Update configuration & start service
sudo sed -i 's/^Listen .*/Listen 3002/' /etc/httpd/conf/httpd.conf
sudo systemctl restart httpd
sudo systemctl enable httpd
```

---

## ⚡ Automated Solution Script

You can execute the included [`troubleshoot_apache.sh`](troubleshoot_apache.sh) script directly from `jump-host` to automatically troubleshoot and fix all 3 servers in one command:

```bash
# Make script executable
chmod +x troubleshoot_apache.sh

# Run for port 3002 (or pass any custom port as $1)
./troubleshoot_apache.sh 3002
```

---

## ✅ Verification & Validation

To ensure all servers meet lab requirements:

1. **Check Listening Ports on App Servers**:
   ```bash
   sudo ss -tulnp | grep 3002
   ```
   *Expected Output:*
   ```text
   tcp   LISTEN 0 511 *:3002 *:* users:(("httpd",pid=XXXX,fd=X))
   ```

2. **Verify HTTP Response from Jump Host**:
   ```bash
   curl -I http://stapp01:3002
   curl -I http://stapp02:3002
   curl -I http://stapp03:3002
   ```

3. **Verify Service Persistence**:
   ```bash
   sudo systemctl is-enabled httpd
   ```

---

## 📤 GitHub Deployment Commands

To push updates to your GitHub repository:

```bash
git add .
git commit -m "fix: update target port to 3002 and improve SSH connection handling"
git push origin main
```

---

*Lab completed successfully as part of DevOps Engineer Training.*
