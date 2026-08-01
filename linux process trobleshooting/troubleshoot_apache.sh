#!/bin/bash
# ==============================================================================
# Script Name : troubleshoot_apache.sh
# Description : Automated solution for KodeKloud Linux Process Troubleshooting Lab
# Scenario    : Fix Apache service unavailability on Stratos DC app servers and
#               ensure Apache (httpd) is running on the target port (default: 3002).
# Usage       : ./troubleshoot_apache.sh [PORT]
# Example     : ./troubleshoot_apache.sh 3002
# ==============================================================================

set -uo pipefail

# Target port (defaults to 3002 as per lab requirement)
TARGET_PORT="${1:-3002}"

# Color formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Server details array (Single quotes prevent bash '!' history expansion)
SERVERS=(
    'tony:stapp01:Ir0nM@n'
    'steve:stapp02:Am3r!ca'
    'banner:stapp03:BigB@ng'
)

HTTPD_CONF="/etc/httpd/conf/httpd.conf"

echo -e "${BLUE}=====================================================${NC}"
echo -e "${BLUE} Starting Apache Troubleshooting on Stratos DC App Servers ${NC}"
echo -e "${BLUE} Target Port: ${TARGET_PORT}${NC}"
echo -e "${BLUE}=====================================================${NC}\n"

# SSH common options
SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PreferredAuthentications=password,keyboard-interactive -o PubkeyAuthentication=no -o ConnectTimeout=10"

for SERVER_INFO in "${SERVERS[@]}"; do
    IFS=":" read -r USER HOST PASS <<< "$SERVER_INFO"
    echo -e "${YELLOW}-----------------------------------------------------${NC}"
    echo -e "${YELLOW}[*] Processing Host: ${HOST} (User: ${USER})${NC}"
    echo -e "${YELLOW}-----------------------------------------------------${NC}"

    # Use single quotes for remote script execution to avoid password mangling
    sshpass -p "$PASS" ssh $SSH_OPTS "${USER}@${HOST}" bash -s <<REMOTE_SCRIPT || true
        PORT_NUM="${TARGET_PORT}"
        CONF_FILE="${HTTPD_CONF}"
        MY_PASS='${PASS}'

        echo "[+] Checking current Apache status on \$(hostname)..."
        echo "\$MY_PASS" | sudo -S systemctl status httpd --no-pager || true

        # 1. Update Listen port in httpd.conf if required
        if grep -E "^Listen " "\$CONF_FILE" | grep -qv "\$PORT_NUM"; then
            echo "[!] Apache is not configured for port \$PORT_NUM. Updating \$CONF_FILE..."
            echo "\$MY_PASS" | sudo -S sed -i "s/^Listen .*/Listen \$PORT_NUM/" "\$CONF_FILE"
        else
            echo "[+] \$CONF_FILE is already configured with Listen \$PORT_NUM."
        fi

        # 2. Check for conflicting process on target port
        CONFLICT_PID=\$(echo "\$MY_PASS" | sudo -S ss -tulnp | grep ":\$PORT_NUM " | awk '{print \$7}' | sed -E 's/.*pid=([0-9]+).*/\1/' || true)
        if [ -n "\$CONFLICT_PID" ]; then
            CONFLICT_NAME=\$(ps -p "\$CONFLICT_PID" -o comm= || echo "unknown")
            if [ "\$CONFLICT_NAME" != "httpd" ]; then
                echo "[!] Found conflicting process (PID: \$CONFLICT_PID, Name: \$CONFLICT_NAME) on port \$PORT_NUM. Terminating..."
                echo "\$MY_PASS" | sudo -S kill -9 "\$CONFLICT_PID" || true
            fi
        fi

        # 3. Test configuration syntax
        echo "[+] Testing Apache configuration syntax..."
        echo "\$MY_PASS" | sudo -S apachectl configtest || true

        # 4. Restart and enable httpd service
        echo "[+] Starting and enabling Apache (httpd) service..."
        echo "\$MY_PASS" | sudo -S systemctl restart httpd
        echo "\$MY_PASS" | sudo -S systemctl enable httpd || true

        # 5. Verify listening port
        echo "[+] Verifying port \$PORT_NUM binding..."
        echo "\$MY_PASS" | sudo -S ss -tulnp | grep ":\$PORT_NUM " || true
REMOTE_SCRIPT

    # Verify from jump-host
    echo -e "${GREEN}[+] Testing HTTP connectivity from jump-host to ${HOST}:${TARGET_PORT}...${NC}"
    if curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "http://${HOST}:${TARGET_PORT}" | grep -E "200|403|404" &> /dev/null; then
        echo -e "${GREEN}[SUCCESS] ${HOST} Apache is responding on port ${TARGET_PORT}!${NC}\n"
    else
        echo -e "${RED}[FAIL] Could not connect to http://${HOST}:${TARGET_PORT}${NC}\n"
    fi
done

echo -e "${GREEN}=====================================================${NC}"
echo -e "${GREEN} Troubleshooting completed on all servers. ${NC}"
echo -e "${GREEN}=====================================================${NC}"
