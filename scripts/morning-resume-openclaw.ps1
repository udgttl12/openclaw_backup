$ErrorActionPreference = 'Continue'
$logDir = "$env:USERPROFILE\.openclaw\logs"
if (!(Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
$logFile = Join-Path $logDir "morning-resume.log"

function Log($m){ Add-Content -Path $logFile -Value "[$(Get-Date -Format o)] $m" }

try {
  & openclaw gateway restart 2>&1 | Out-Null
  Start-Sleep -Seconds 3
  & schtasks /Run /TN "OpenClaw Node" 2>&1 | Out-Null
  Start-Sleep -Seconds 2
  $gw = (& openclaw gateway status 2>&1 | Out-String)
  $nd = (& openclaw nodes status --connected --json 2>&1 | Out-String)
  Log "Gateway restart attempted"
  Log "Node start attempted"
  Log ("Gateway status snippet: " + (($gw -split "`n" | Select-Object -First 3) -join " | "))
  Log ("Node status snippet: " + (($nd -split "`n" | Select-Object -First 2) -join " | "))
}
catch {
  Log "ERROR: $($_.Exception.Message)"
}
