#!/usr/bin/env bash
# Connection Checker for macOS & Linux

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/report.log"

# ANSI Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

if [ ! -t 1 ]; then
    CYAN=''
    GREEN=''
    RED=''
    NC=''
fi

echo -e "${CYAN}Checking internet connection...${NC}"

HOSTS=("8.8.8.8" "1.1.1.1")
CONNECTED=0
ACTIVE_HOST=""
PING_TIME=""

# Detect ping syntax for timeout (macOS uses -t, Linux uses -W)
if [[ "$OSTYPE" == "darwin"* ]]; then
    PING_CMD="ping -c 1 -t 2"
else
    PING_CMD="ping -c 1 -W 2"
fi

for host in "${HOSTS[@]}"; do
    if ping_output=$($PING_CMD "$host" 2>/dev/null); then
        CONNECTED=1
        ACTIVE_HOST="$host"
        PING_TIME=$(echo "$ping_output" | grep -o 'time=[0-9.]*' | head -n 1 | cut -d'=' -f2)
        break
    fi
done

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

if [ "$CONNECTED" -eq 1 ]; then
    MSG="Connected! Internet is available."
    if [ -n "$PING_TIME" ]; then
        echo -e "${GREEN}${MSG} (${ACTIVE_HOST} - ${PING_TIME} ms)${NC}"
    else
        echo -e "${GREEN}${MSG} (${ACTIVE_HOST})${NC}"
    fi
    echo "${TIMESTAMP} - ${MSG}" >> "${LOG_FILE}"
else
    MSG="Disconnected! Unable to reach reliable DNS servers."
    echo -e "${RED}${MSG}${NC}"
    echo "${TIMESTAMP} - ${MSG}" >> "${LOG_FILE}"
    exit 1
fi
