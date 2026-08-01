#!/bin/bash
# ==============================================================================
# Script Name : troubleshoot_apache.sh
# Description : Automated solution for KodeKloud Linux Process Troubleshooting Lab
# Scenario    : Fix Apache service unavailability on Stratos DC app servers and
#               ensure Apache (httpd) is running on the target port (default: 3002).
# Usage       : ./troubleshoot_apache.sh [PORT]
# Example     : ./troubleshoot_apache.sh 3002
# ==============================================================================

set +H

TARGET_PORT="${1:-3002}"

# LogLevel=ERROR suppresses 'Warning: Permanently added to known_hosts' which breaks sshpass
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o ConnectTimeout=10"

echo "====================================================="
echo " Starting Apache Troubleshooting (Port: ${TARGET_PORT})"
echo "====================================================="

# Host 1: stapp01 (tony)
echo "[*] Processing Host: stapp01 (User: tony)"
sshpass -p 'Ir0nM@n' ssh $SSH_OPTS tony@stapp01 "
    echo 'Ir0nM@n' | sudo -S sed -i 's/^Listen .*/Listen ${TARGET_PORT}/' /etc/httpd/conf/httpd.conf
    echo 'Ir0nM@n' | sudo -S systemctl restart httpd
    echo 'Ir0nM@n' | sudo -S systemctl enable httpd
" || true
curl -I "http://stapp01:${TARGET_PORT}"

# Host 2: stapp02 (steve)
echo "[*] Processing Host: stapp02 (User: steve)"
sshpass -p 'Am3r!ca' ssh $SSH_OPTS steve@stapp02 "
    echo 'Am3r!ca' | sudo -S sed -i 's/^Listen .*/Listen ${TARGET_PORT}/' /etc/httpd/conf/httpd.conf
    echo 'Am3r!ca' | sudo -S systemctl restart httpd
    echo 'Am3r!ca' | sudo -S systemctl enable httpd
" || true
curl -I "http://stapp02:${TARGET_PORT}"

# Host 3: stapp03 (banner)
echo "[*] Processing Host: stapp03 (User: banner)"
sshpass -p 'BigB@ng' ssh $SSH_OPTS banner@stapp03 "
    echo 'BigB@ng' | sudo -S sed -i 's/^Listen .*/Listen ${TARGET_PORT}/' /etc/httpd/conf/httpd.conf
    echo 'BigB@ng' | sudo -S systemctl restart httpd
    echo 'BigB@ng' | sudo -S systemctl enable httpd
" || true
curl -I "http://stapp03:${TARGET_PORT}"

echo "====================================================="
echo " Troubleshooting Completed!"
echo "====================================================="
