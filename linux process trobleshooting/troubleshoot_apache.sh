#!/bin/bash
# ==============================================================================
# Script Name : troubleshoot_apache.sh
# Description : Automated solution for KodeKloud Linux Process Troubleshooting Lab
# Scenario    : Fix Apache service unavailability on Stratos DC app servers and
#               ensure Apache (httpd) is running on the target port (default: 3002).
# Usage       : ./troubleshoot_apache.sh [PORT]
# Example     : ./troubleshoot_apache.sh 3002
# ==============================================================================

# Disable bash history expansion so '!' in passwords like 'Am3r!ca' is never mangled
set +H

TARGET_PORT="${1:-3002}"

echo "====================================================="
echo " Starting Apache Troubleshooting on Stratos DC App Servers"
echo " Target Port: ${TARGET_PORT}"
echo "====================================================="
echo ""

SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10"

# Host 1: stapp01 (tony / Ir0nM@n)
echo "-----------------------------------------------------"
echo "[*] Processing Host: stapp01 (User: tony)"
echo "-----------------------------------------------------"
sshpass -p 'Ir0nM@n' ssh $SSH_OPTS tony@stapp01 "
    echo 'Ir0nM@n' | sudo -S sed -i 's/^Listen .*/Listen ${TARGET_PORT}/' /etc/httpd/conf/httpd.conf
    echo 'Ir0nM@n' | sudo -S systemctl restart httpd
    echo 'Ir0nM@n' | sudo -S systemctl enable httpd
    echo 'Ir0nM@n' | sudo -S ss -tulnp | grep ':${TARGET_PORT} ' || true
" || echo "[!] SSH failed for stapp01"

curl -I "http://stapp01:${TARGET_PORT}" || true
echo ""

# Host 2: stapp02 (steve / Am3r!ca)
echo "-----------------------------------------------------"
echo "[*] Processing Host: stapp02 (User: steve)"
echo "-----------------------------------------------------"
sshpass -p 'Am3r!ca' ssh $SSH_OPTS steve@stapp02 "
    echo 'Am3r!ca' | sudo -S sed -i 's/^Listen .*/Listen ${TARGET_PORT}/' /etc/httpd/conf/httpd.conf
    echo 'Am3r!ca' | sudo -S systemctl restart httpd
    echo 'Am3r!ca' | sudo -S systemctl enable httpd
    echo 'Am3r!ca' | sudo -S ss -tulnp | grep ':${TARGET_PORT} ' || true
" || echo "[!] SSH failed for stapp02"

curl -I "http://stapp02:${TARGET_PORT}" || true
echo ""

# Host 3: stapp03 (banner / BigB@ng)
echo "-----------------------------------------------------"
echo "[*] Processing Host: stapp03 (User: banner)"
echo "-----------------------------------------------------"
sshpass -p 'BigB@ng' ssh $SSH_OPTS banner@stapp03 "
    echo 'BigB@ng' | sudo -S sed -i 's/^Listen .*/Listen ${TARGET_PORT}/' /etc/httpd/conf/httpd.conf
    echo 'BigB@ng' | sudo -S systemctl restart httpd
    echo 'BigB@ng' | sudo -S systemctl enable httpd
    echo 'BigB@ng' | sudo -S ss -tulnp | grep ':${TARGET_PORT} ' || true
" || echo "[!] SSH failed for stapp03"

curl -I "http://stapp03:${TARGET_PORT}" || true
echo ""

echo "====================================================="
echo " Troubleshooting completed on all servers."
echo "====================================================="
