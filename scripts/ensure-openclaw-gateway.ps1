$ErrorActionPreference = 'Continue'

$logDir = "$env:USERPROFILE\.openclaw\logs"
if (!(Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
$logFile = Join-Path $logDir "gateway-keepalive.log"

$OpenClawExe = "C:\nvm4w\nodejs\openclaw.cmd"
if (!(Test-Path $OpenClawExe)) { $OpenClawExe = "openclaw" }

function Log($msg) {
  Add-Content -Path $logFile -Value "[$(Get-Date -Format o)] $msg"
}

function IsGatewayHealthy {
  try {
    $out = (& $OpenClawExe gateway status 2>&1 | Out-String)
    if ($out -match "RPC probe:\s*ok" -or $out -match "Listening:\s*127\.0\.0\.1:18789") {
      return $true
    }
    return $false
  }
  catch {
    return $false
  }
}

$healthy = IsGatewayHealthy
if ($healthy) { exit 0 }

Log "Gateway unhealthy detected -> restarting"
try {
  & $OpenClawExe gateway restart 2>&1 | Out-Null
  Start-Sleep -Seconds 5

  if (IsGatewayHealthy) {
    Log "Gateway restart success"
    exit 0
  }

  Log "Gateway restart failed"
  exit 1
}
catch {
  Log "Gateway restart exception: $($_.Exception.Message)"
  exit 1
}
