# 🔧 Linux Process Troubleshooting: Apache Service Fix

Fix Apache (`httpd`) service unavailability on Stratos DC app servers and ensure it's running on the assigned port.

![KodeKloud](https://img.shields.io/badge/KodeKloud-Completed-brightgreen)
![Platform](https://img.shields.io/badge/Platform-Nautilus-blue)
![Status](https://img.shields.io/badge/Lab-Passed%20✅-success)

---

## 📦 Stack / Tech Used

| Technology | Version | Purpose |
|------------|---------|---------|
| httpd | `2.4.62` | Apache HTTP Server |
| sshpass | `1.06+` | Non-interactive SSH auth |
| Bash | `4.x` | Automation scripting |

---

## 📁 Project Structure

```
.
├── troubleshoot_apache.sh   # Main automation script (run from jump host)
├── Lab-requirements.txt     # Original task requirements
└── README.md                # This file
```

---

## 🌐 Infrastructure Details

### Servers

| Server | Hostname | User | Password |
|--------|----------|------|----------|
| App Server 1 | `stapp01` | `tony` | `Ir0nM@n` |
| App Server 2 | `stapp02` | `steve` | `Am3r!ca` |
| App Server 3 | `stapp03` | `banner` | `BigB@ng` |
| Jump Host | `jump_host` | `thor` | `mjolnir123` |

> **Note:** The assigned port varies per lab instance (e.g. `3002`, `5000`). Check the lab prompt before running.

---

## ✅ Prerequisites

- Access to the **Jump Host** (`thor@jump_host`)
- SSH connectivity to all **3 app servers** from the jump host
- `sshpass` on the jump host — script auto-installs via `apt`, `dnf`, or `yum`

> ⚠️ **Run from jump host only.**

---

## 🚀 Quick Start

### 1. SSH into the Jump Host

```bash
ssh thor@jump_host
```

### 2. Clone the Repository

```bash
git clone https://github.com/webrezaul/linux-process-trobleshooting.git
cd linux-process-trobleshooting
```

### 3. Make it Executable & Run

```bash
chmod +x troubleshoot_apache.sh
./troubleshoot_apache.sh <PORT>
```

**Example:**

```bash
./troubleshoot_apache.sh 3002
```

---

## 📋 What the Script Does

| Step | Action | Command Used |
|------|--------|-------------|
| 1 | SSHes into each app server via `sshpass` | `sshpass -p <PASS> ssh <USER>@<HOST>` |
| 2 | Updates Apache Listen port in config | `sed -i 's/^Listen .*/Listen <PORT>/' /etc/httpd/conf/httpd.conf` |
| 3 | Restarts `httpd` service | `systemctl restart httpd` |
| 4 | Enables `httpd` on boot | `systemctl enable httpd` |
| 5 | Verifies port binding on server | `ss -tulnp \| grep :<PORT>` |
| 6 | Verifies HTTP response from jump host | `curl -I http://<HOST>:<PORT>` |

> **Note:** The script pipes the password once into a single `sudo -S bash -c '...'` block to avoid `Permission denied` noise from chained sudo calls.

---

## 🔍 Root Cause

| # | Cause | Fix |
|---|-------|-----|
| 1 | `httpd` service not started / not enabled | `systemctl restart httpd && systemctl enable httpd` |
| 2 | Wrong `Listen` port in config | `sed -i 's/^Listen .*/Listen <PORT>/' /etc/httpd/conf/httpd.conf` |
| 3 | Conflicting process on assigned port | `kill -9 <PID>` |

---

## 🛠️ Manual Fix

SSH into each server and run (replace `<PORT>` with the assigned port):

```bash
sudo sed -i 's/^Listen .*/Listen <PORT>/' /etc/httpd/conf/httpd.conf
sudo systemctl restart httpd
sudo systemctl enable httpd
```

---

## 🧪 Verification

From `jump-host`:

```bash
curl -I http://stapp01:<PORT>
curl -I http://stapp02:<PORT>
curl -I http://stapp03:<PORT>
```

**Expected:** `HTTP/1.1 403 Forbidden` (Apache running, no content hosted).

On each app server:

```bash
sudo systemctl status httpd
sudo ss -tulnp | grep :<PORT>
sudo systemctl is-enabled httpd
```

---

## ⚡ Key Technical Decisions

### Why `sudo -S bash -c '...'` instead of chained `echo | sudo -S`?

```bash
# ❌ WRONG — each sudo -S consumes stdin separately, subsequent calls get empty stdin
echo 'pass' | sudo -S cmd1 && echo 'pass' | sudo -S cmd2

# ✅ CORRECT — single sudo session, password piped once
echo 'pass' | sudo -S bash -c 'cmd1 && cmd2 && cmd3'
```

### Why `-T` flag in SSH?

Disables pseudo-terminal allocation to prevent TTY conflicts between `sshpass` and `sudo`.

### Why `set +H`?

Disables bash history expansion so `!` in passwords like `Am3r!ca` is not interpreted.

---

## 📝 Changelog

| Version | Date | Changes |
|---------|------|---------|
| `1.2.0` | 2026-08-01 | Single `sudo -S bash -c` block, `-T` SSH flag, `set +H` for password safety |
| `1.1.0` | 2026-08-01 | Added `LogLevel=ERROR`, port parameterization |
| `1.0.0` | 2026-08-01 | Initial script with Apache troubleshooting |

---

## 👤 Author

**Rezaul**
- Platform: [KodeKloud](https://kodekloud.com/)
- Project: Nautilus — Stratos DC
