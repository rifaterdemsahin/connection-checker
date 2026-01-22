Write-Host "Checking internet connection..." -ForegroundColor Cyan

$hosts = @("8.8.8.8", "1.1.1.1")
$connected = $false

foreach ($h in $hosts) {
    try {
        if (Test-Connection -ComputerName $h -Count 1 -Quiet -ErrorAction Stop) {
            $connected = $true
            break
        }
    }
    catch {
        # Ignore errors and try next host
    }
}

$logFile = "$PSScriptRoot\report.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

if ($connected) {
    $msg = "Connected! Internet is available."
    Write-Host $msg -ForegroundColor Green
    "$timestamp - $msg" | Out-File -FilePath $logFile -Append -Encoding utf8
}
else {
    $msg = "Disconnected! Unable to reach reliable DNS servers."
    Write-Host $msg -ForegroundColor Red
    "$timestamp - $msg" | Out-File -FilePath $logFile -Append -Encoding utf8
}
