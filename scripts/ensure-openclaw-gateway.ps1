$ErrorActionPreference = 'Continue'

$logDir = "$env:USERPROFILE\.openclaw\logs"
if (!(Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
$logFile = Join-Path $logDir "gateway-keepalive.log"

$OpenClawExe = "C:\nvm4w\nodejs\openclaw.cmd"
$GatewayPort = 18789
$GatewayLock = Join-Path $logDir "gateway-keepalive.lock"

if (!(Test-Path $OpenClawExe)) {
  Add-Content -Path $logFile -Value "[$(Get-Date -Format o)] Gateway executable not found: $OpenClawExe"
  exit 1
}

function Log($msg) {
  Add-Content -Path $logFile -Value "[$(Get-Date -Format o)] $msg"
}

function Test-PortOpen($port) {
  try {
    return [bool](Get-NetTCPConnection -ErrorAction SilentlyContinue -LocalPort $port -State Listen)
  }
  catch {
    return $false
  }
}

function Try-GatewayLock {
  try {
    $fs = [System.IO.File]::Open($GatewayLock, [System.IO.FileMode]::OpenOrCreate, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
    return $fs
  }
  catch {
    return $null
  }
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

$lockStream = Try-GatewayLock
if (-not $lockStream) {
  Log "Gateway keepalive already running; skip duplicate"
  exit 0
}

try {
  $healthy = IsGatewayHealthy
  if ($healthy) {
    Log "Gateway healthy"
    exit 0
  }

  if (Test-PortOpen $GatewayPort) {
    Log "Gateway port $GatewayPort is already open but health check failed; skip restart to avoid overlap"
    exit 1
  }

  Log "Gateway unhealthy and port closed -> starting"
  Start-Process -FilePath $OpenClawExe -ArgumentList @('gateway','run','--port',"$GatewayPort",'--force') -WindowStyle Hidden | Out-Null
  Start-Sleep -Seconds 5

  if (IsGatewayHealthy) {
    Log "Gateway start success"
    exit 0
  }

  Log "Gateway start failed"
  exit 1
}
finally {
  if ($lockStream) {
    $lockStream.Close()
    $lockStream.Dispose()
    Remove-Item -Path $GatewayLock -Force -ErrorAction SilentlyContinue
  }
}
