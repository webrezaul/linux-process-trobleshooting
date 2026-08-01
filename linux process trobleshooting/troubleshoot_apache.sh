#!/bin/bash
# ==============================================================================
# Script Name : troubleshoot_apache.sh
# Description : Automated solution for KodeKloud Linux Process Troubleshooting Lab
# Scenario    : Fix Apache service unavailability on Stratos DC app servers and
#               ensure Apache (httpd) is running on the target port.
# Usage       : ./troubleshoot_apache.sh [PORT]
# Example     : ./troubleshoot_apache.sh 3002
# ==============================================================================

# Disable bash history expansion (prevents '!' in passwords like 'Am3r!ca' from being interpreted)
set +H

TARGET_PORT="${1:-3002}"

# -T: disable pseudo-terminal allocation (prevents TTY conflicts with sshpass/sudo)
# LogLevel=ERROR: suppress "Permanently added to known hosts" warning
SSH_OPTS="-T -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o ConnectTimeout=10"

echo "====================================================="
echo " Apache Troubleshooting - Stratos DC (Port: ${TARGET_PORT})"
echo "====================================================="

fix_host() {
    local USER="$1"
    local HOST="$2"
    local PASS="$3"

    echo ""
    echo "-----------------------------------------------------"
    echo "[*] Processing Host: ${HOST} (User: ${USER})"
    echo "-----------------------------------------------------"

    # Key fix: pipe password ONCE into a single 'sudo -S bash -c' block
    # so all commands share one sudo session and one stdin password read.
    sshpass -p "${PASS}" ssh ${SSH_OPTS} "${USER}@${HOST}" \
        "echo '${PASS}' | sudo -S bash -c '
            sed -i \"s/^Listen .*/Listen ${TARGET_PORT}/\" /etc/httpd/conf/httpd.conf
            systemctl restart httpd
            systemctl enable httpd
            ss -tulnp | grep :${TARGET_PORT}
        '" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "[+] Commands executed successfully on ${HOST}"
    else
        echo "[!] Warning: issue on ${HOST}, verifying via curl..."
    fi

    # Verify from jump-host
    echo "[+] Verifying HTTP on ${HOST}:${TARGET_PORT}..."
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "http://${HOST}:${TARGET_PORT}" 2>/dev/null)
    if echo "${HTTP_CODE}" | grep -qE "200|403|404"; then
        echo "[SUCCESS] ${HOST} => HTTP ${HTTP_CODE} on port ${TARGET_PORT}"
    else
        echo "[FAIL] ${HOST} => HTTP ${HTTP_CODE} (expected 200/403/404)"
    fi
}

# Process all three app servers
fix_host "tony"   "stapp01" 'Ir0nM@n'
fix_host "steve"  "stapp02" 'Am3r!ca'
fix_host "banner" "stapp03" 'BigB@ng'

echo ""
echo "====================================================="
echo " Complete! Click 'Check' in the KodeKloud UI."
echo "====================================================="
