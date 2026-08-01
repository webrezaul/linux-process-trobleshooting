# Linux Process Troubleshooting: Apache Service Unavailability in Stratos DC

[![DevOps](https://img.shields.io/badge/DevOps-KodeKloud-blue.svg)](https://kodekloud.com)
[![Linux](https://img.shields.io/badge/Linux-RHEL%2FCentOS-red.svg)](https://www.redhat.com)
[![Apache](https://img.shields.io/badge/Apache-httpd-brightgreen.svg)](https://httpd.apache.org)
[![Status](https://img.shields.io/badge/Status-Completed-success.svg)](#)

## 📋 Table of Contents

- [Problem Scenario](#-problem-scenario)
- [Target System Topology](#️-target-system-topology)
- [Root Cause Analysis](#-root-cause-analysis)
- [Step-by-Step Manual Troubleshooting](#️-step-by-step-manual-troubleshooting)
- [Automated Solution Script](#-automated-solution-script)
- [Verification & Validation](#-verification--validation)

---

## 🚀 Problem Scenario

The production support team of **xFusionCorp Industries** deployed monitoring tools across all systems. A monitoring system reported **Apache service unavailability** on one of the application servers in **Stratos DC**.

### Key Requirements

1. Identify the faulty app host and fix the underlying process/service issue.
2. Ensure the Apache service (`httpd`) is **up and running** on all app hosts (`stapp01`, `stapp02`, `stapp03`).
3. Ensure Apache is listening on the **assigned port** (e.g. `3002`, `5000` — varies per lab instance) on all app servers.

> **Note:** The port number changes across lab instances. Check the lab prompt carefully before running commands.

---

## 🖥️ Target System Topology

| Hostname | Server IP | User | SSH Password | Service |
| :--- | :--- | :--- | :--- | :--- |
| **stapp01** | `172.16.238.10` | `tony` | `Ir0nM@n` | `httpd` |
| **stapp02** | `172.16.238.11` | `steve` | `Am3r!ca` | `httpd` |
| **stapp03** | `172.16.238.12` | `banner` | `BigB@ng` | `httpd` |

> All commands are executed from the **jump host** (`thor@jump-host`).

---

## 🔍 Root Cause Analysis

Apache service failures on Stratos DC app hosts typically stem from one or more of the following:

| # | Cause | Symptom |
|---|-------|---------|
| 1 | **Service not started** | `httpd` is stopped / not enabled on boot |
| 2 | **Wrong Listen port** | `/etc/httpd/conf/httpd.conf` has `Listen 80` instead of the assigned port |
| 3 | **Port conflict** | A rogue process occupies the assigned port, blocking `httpd` from binding |

---

## 🛠️ Step-by-Step Manual Troubleshooting

### 1. Identify Faulty Host

From `jump-host`, test connectivity to the assigned port on each app server:

```bash
curl -Iv http://stapp01:<PORT>
curl -Iv http://stapp02:<PORT>
curl -Iv http://stapp03:<PORT>
```

### 2. SSH into each host and fix

Replace `<PORT>` with the port from your lab prompt (e.g., `3002`).

#### stapp01

```bash
ssh tony@stapp01
# Password: Ir0nM@n

sudo systemctl status httpd
sudo grep "^Listen" /etc/httpd/conf/httpd.conf
sudo sed -i 's/^Listen .*/Listen <PORT>/' /etc/httpd/conf/httpd.conf

# Kill any conflicting process on the port
sudo ss -tulnp | grep :<PORT>
# sudo kill -9 <conflicting_PID>

sudo apachectl configtest
sudo systemctl restart httpd
sudo systemctl enable httpd
exit
```

#### stapp02

```bash
ssh steve@stapp02
# Password: Am3r!ca

sudo sed -i 's/^Listen .*/Listen <PORT>/' /etc/httpd/conf/httpd.conf
sudo systemctl restart httpd
sudo systemctl enable httpd
exit
```

#### stapp03

```bash
ssh banner@stapp03
# Password: BigB@ng

sudo sed -i 's/^Listen .*/Listen <PORT>/' /etc/httpd/conf/httpd.conf
sudo systemctl restart httpd
sudo systemctl enable httpd
exit
```

---

## ⚡ Automated Solution Script

The [`troubleshoot_apache.sh`](troubleshoot_apache.sh) script automates the entire fix across all 3 servers from `jump-host` in a single command.

### Usage

```bash
chmod +x troubleshoot_apache.sh
./troubleshoot_apache.sh <PORT>
```

**Example:**

```bash
./troubleshoot_apache.sh 3002
```

### How It Works

1. SSHes into each app server via `sshpass`.
2. Updates `/etc/httpd/conf/httpd.conf` to `Listen <PORT>`.
3. Restarts and enables `httpd` service.
4. Verifies HTTP response from `jump-host` using `curl`.

> **Design note:** The script pipes the password once into a single `sudo -S bash -c '...'` block so that all commands share one sudo session — this avoids the `Permission denied, please try again` noise caused by chained `echo | sudo -S` invocations where subsequent sudos find an empty stdin.

---

## ✅ Verification & Validation

### From Jump Host

```bash
curl -I http://stapp01:<PORT>
curl -I http://stapp02:<PORT>
curl -I http://stapp03:<PORT>
```

**Expected:** `HTTP/1.1 403 Forbidden` (Apache is running but no content is hosted yet — this is normal).

### On Each App Server

```bash
sudo ss -tulnp | grep :<PORT>
sudo systemctl is-enabled httpd
```

---

*Lab completed successfully as part of DevOps Engineer Training.*
