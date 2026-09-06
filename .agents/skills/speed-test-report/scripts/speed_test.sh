#!/usr/bin/env bash
# Network Speed Test Script for macOS and Linux
# Measures download/upload throughput, latency, and bufferbloat responsiveness.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel 2>/dev/null || (cd "${SCRIPT_DIR}/../../../../" && pwd))"
JSON_OUTPUT="${REPO_ROOT}/speedtest_report.json"
LOG_FILE="${REPO_ROOT}/report.log"

# Terminal ANSI colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

commit_and_push() {
  echo -e "${YELLOW}Saving report to file, committing, and pushing...${NC}"
  git -C "${REPO_ROOT}" add "${JSON_OUTPUT}" "${LOG_FILE}" || true
  git -C "${REPO_ROOT}" commit -m "Auto-update speedtest report: $TIMESTAMP" || true
  git -C "${REPO_ROOT}" push || true
}

if [ ! -t 1 ]; then
  CYAN=''
  GREEN=''
  YELLOW=''
  BLUE=''
  BOLD=''
  NC=''
fi

echo -e "${CYAN}${BOLD}⚡ Running Internet Speed Test...${NC}"

TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Check if macOS networkQuality is available
if [ -x "/usr/bin/networkQuality" ]; then
  # Run Apple's official networkQuality with computer-readable JSON output
  RAW_JSON=$(/usr/bin/networkQuality -c -M 4 2>/dev/null || true)
  
  if [ -n "$RAW_JSON" ]; then
    python3 - <<EOF
import json, sys

try:
    data = json.loads('''$RAW_JSON''')
    dl_bps = data.get("dl_throughput", 0)
    ul_bps = data.get("ul_throughput", 0)
    dl_mbps = round(dl_bps / 1_000_000, 2)
    ul_mbps = round(ul_bps / 1_000_000, 2)
    base_rtt = round(data.get("base_rtt", 0), 2)
    responsiveness = round(data.get("responsiveness", 0))
    endpoint = data.get("test_endpoint", "Apple Edge")
    interface = data.get("interface_name", "Unknown")

    summary = {
        "timestamp": "$TIMESTAMP",
        "download_mbps": dl_mbps,
        "upload_mbps": ul_mbps,
        "latency_ms": base_rtt,
        "responsiveness_rpm": responsiveness,
        "endpoint": endpoint,
        "interface": interface,
        "status": "Online"
    }

    with open("$JSON_OUTPUT", "w") as f:
        json.dump(summary, f, indent=2)

    # Print formatted output
    print(f"\n${GREEN}${BOLD}✓ Speed Test Completed Successfully${NC}")
    print(f"  ${BOLD}Download:${NC}       {dl_mbps} Mbps")
    print(f"  ${BOLD}Upload:${NC}         {ul_mbps} Mbps")
    print(f"  ${BOLD}Latency (RTT):${NC}  {base_rtt} ms")
    print(f"  ${BOLD}Responsiveness:${NC} {responsiveness} RPM (Round-trips per minute)")
    print(f"  ${BOLD}Interface:${NC}      {interface}")
    print(f"  ${BOLD}Test Server:${NC}    {endpoint}")
    print(f"  ${BOLD}Recorded At:${NC}    $TIMESTAMP\n")

    # Log to report.log
    with open("$LOG_FILE", "a") as f:
        f.write(f"$TIMESTAMP - SpeedTest: DL {dl_mbps} Mbps | UL {ul_mbps} Mbps | Ping {base_rtt} ms | RPM {responsiveness}\n")

except Exception as e:
    sys.exit(1)
EOF
    commit_and_push
    exit 0
  fi
fi

# Fallback test if networkQuality is unavailable (Linux / fallback)
echo -e "${YELLOW}Using fallback HTTP/ping speed measurement...${NC}"

# Measure ping latency
PING_TIME=$(ping -c 1 -t 2 8.8.8.8 2>/dev/null | grep -o 'time=[0-9.]*' | head -n 1 | cut -d'=' -f2 || echo "0")

# Measure download speed using curl (2MB sample)
DL_BYTES_PER_SEC=$(curl -s -w "%{speed_download}" -o /dev/null -A "Mozilla/5.0" --max-time 6 "https://speed.cloudflare.com/__down?bytes=2000000" 2>/dev/null || echo "0")

python3 - <<EOF
import json

dl_bytes_sec = float("$DL_BYTES_PER_SEC" or 0)
dl_mbps = round((dl_bytes_sec * 8) / 1_000_000, 2)
ping_ms = float("$PING_TIME" or 0)

summary = {
    "timestamp": "$TIMESTAMP",
    "download_mbps": dl_mbps,
    "upload_mbps": 0.0,
    "latency_ms": ping_ms,
    "responsiveness_rpm": 0,
    "endpoint": "Cloudflare Edge",
    "interface": "Default",
    "status": "Online" if dl_mbps > 0 else "Degraded"
}

with open("$JSON_OUTPUT", "w") as f:
    json.dump(summary, f, indent=2)

print(f"\n${GREEN}${BOLD}✓ Fallback Speed Test Completed${NC}")
print(f"  ${BOLD}Download:${NC}   {dl_mbps} Mbps")
print(f"  ${BOLD}Ping:${NC}       {ping_ms} ms")
print(f"  ${BOLD}Recorded At:${NC}$TIMESTAMP\n")

with open("$LOG_FILE", "a") as f:
    f.write(f"$TIMESTAMP - SpeedTest (Fallback): DL {dl_mbps} Mbps | Ping {ping_ms} ms\n")
EOF

commit_and_push
