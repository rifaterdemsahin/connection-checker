---
name: speed-test-report
description: Run this skill to perform a network speed test and generate a report.
---

# Speed Test Report Skill

To create a speed test report, you should execute the speed test script:
```bash
./.agents/skills/speed-test-report/scripts/speed_test.sh
```

This script will measure download/upload throughput, latency, and bufferbloat responsiveness.
It will generate a `speedtest_report.json` and append to `report.log` in the repository root.

After running the script, read the `speedtest_report.json` file and summarize the internet connection status for the user.
