# Connection Checker

A simple PowerShell script to check your internet connection by pinging reliable DNS servers (Google 8.8.8.8 and Cloudflare 1.1.1.1).

## Usage

1. Open PowerShell.
2. Navigate to the directory:

   ```powershell
   cd f:\connection-checker
   ```

3. Run the script:

   ```powershell
   .\check.ps1
   ```

## Output

- **Connected**: Internet is available.
- **Disconnected**: Unable to reach DNS servers.

## Report

The script appends the results to `report.log` in the same directory, including a timestamp for each run.
