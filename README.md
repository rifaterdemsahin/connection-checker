# Connection Checker

A lightweight, cross-platform tool to monitor your internet connection by pinging reliable DNS servers (Google `8.8.8.8` and Cloudflare `1.1.1.1`). Includes a bash script for macOS/Linux, a PowerShell script for Windows/PowerShell Core, and a web dashboard for GitHub Pages.

🌐 **Live Web Dashboard**: [https://rifaterdemsahin.github.io/connection-checker/](https://rifaterdemsahin.github.io/connection-checker/)

---

## Features

- **macOS & Linux Support**: Native Bash script (`check.sh`) with colored output and latency display.
- **Windows Support**: Cross-platform PowerShell script (`check.ps1`).
- **Web Dashboard**: Interactive `index.html` with real-time connectivity testing and log history.
- **Automatic Logging**: Results appended to `report.log` with timestamps.
- **GitHub Pages Integration**: Automatic deployment workflow included.

---

## Usage

### macOS & Linux

1. Clone or navigate to the repository directory:

   ```bash
   cd connection-checker
   ```

2. Make the script executable (first time only):

   ```bash
   chmod +x check.sh
   ```

3. Run the check:

   ```bash
   ./check.sh
   ```

### Windows (PowerShell)

1. Open PowerShell and navigate to the directory:

   ```powershell
   cd connection-checker
   ```

2. Run the script:

   ```powershell
   .\check.ps1
   ```

---

## Output & Reports

- **Connected**: Displays host and response time (e.g. `8.8.8.8 - 7.9 ms`).
- **Disconnected**: Alerts when public DNS targets cannot be reached.

Every run records an entry in `report.log`:

```text
2026-09-06 14:00:41 - Connected! Internet is available.
```

---

## GitHub Pages Deployment

The project includes:
- `index.html` at the repository root.
- `.github/workflows/pages.yml` for automated GitHub Actions deployment.

To enable GitHub Pages in your repository:
1. Go to **Settings** > **Pages** (`https://github.com/rifaterdemsahin/connection-checker/settings/pages`).
2. Under **Build and deployment** > **Source**, choose **GitHub Actions** (or select branch `main` / `gh-pages` root).
3. Visit [https://rifaterdemsahin.github.io/connection-checker/](https://rifaterdemsahin.github.io/connection-checker/).
