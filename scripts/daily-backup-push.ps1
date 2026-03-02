$ErrorActionPreference = 'Stop'

$repo = "$env:USERPROFILE\.openclaw"
$logDir = "$env:USERPROFILE\.openclaw\logs"
if (!(Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
$logFile = Join-Path $logDir "daily-backup-push.log"

function Log($msg) {
  Add-Content -Path $logFile -Value "[$(Get-Date -Format o)] $msg"
}

try {
  if (!(Test-Path (Join-Path $repo '.git'))) {
    Log "SKIP: git repo not found at $repo"
    exit 0
  }

  $status = git -C $repo status --porcelain=v1
  if ([string]::IsNullOrWhiteSpace(($status | Out-String))) {
    Log "NO_CHANGES: nothing to commit"
    exit 0
  }

  git -C $repo add -A
  $msg = "백업: 일일 자동 스냅샷 $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

  try {
    git -C $repo commit -m $msg | Out-Null
    Log "COMMIT_OK: $msg"
  }
  catch {
    Log "COMMIT_SKIP_OR_FAIL: $($_.Exception.Message)"
    # Commit failed can still happen if only ignored/untracked filtered out.
  }

  git -C $repo push origin main | Out-Null
  Log "PUSH_OK"
}
catch {
  Log "ERROR: $($_.Exception.Message)"
  exit 1
}
