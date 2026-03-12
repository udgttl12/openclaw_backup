[CmdletBinding()]
param(
    [switch]$Restart
)

$ErrorActionPreference = "Stop"

$stateDir = Join-Path $HOME ".openclaw"
$taskName = "OpenClaw Gateway"
$gatewayCmdPath = Join-Path $stateDir "gateway.cmd"
$gatewayVbsPath = Join-Path $stateDir "gateway-hidden.vbs"

function Convert-ToVbsString {
    param([Parameter(Mandatory = $true)][string]$Value)

    '"' + ($Value -replace '"', '""') + '"'
}

function Parse-GatewayCmd {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path $Path)) {
        throw "Gateway script not found: $Path"
    }

    $environment = [ordered]@{}
    $commandLine = $null

    foreach ($rawLine in Get-Content $Path) {
        $line = $rawLine.Trim()
        if (-not $line) { continue }
        if ($line.StartsWith("@echo", [System.StringComparison]::OrdinalIgnoreCase)) { continue }
        if ($line.StartsWith("rem ", [System.StringComparison]::OrdinalIgnoreCase)) { continue }

        if ($line.StartsWith("set ", [System.StringComparison]::OrdinalIgnoreCase)) {
            $assignment = $line.Substring(4).Trim()
            if ($assignment.StartsWith('"') -and $assignment.EndsWith('"')) {
                $assignment = $assignment.Substring(1, $assignment.Length - 2)
            }

            $separatorIndex = $assignment.IndexOf("=")
            if ($separatorIndex -gt 0) {
                $key = $assignment.Substring(0, $separatorIndex)
                $value = $assignment.Substring($separatorIndex + 1)
                $environment[$key] = $value
            }
            continue
        }

        if ($line.StartsWith("cd /d ", [System.StringComparison]::OrdinalIgnoreCase)) {
            continue
        }

        $commandLine = $line
        break
    }

    if (-not $commandLine) {
        throw "No gateway command found in $Path"
    }

    [pscustomobject]@{
        Environment = $environment
        CommandLine = $commandLine
    }
}

$gatewayCmd = Parse-GatewayCmd -Path $gatewayCmdPath

$vbsLines = [System.Collections.Generic.List[string]]::new()
$vbsLines.Add("Option Explicit")
$vbsLines.Add("")
$vbsLines.Add("Dim shell")
$vbsLines.Add("Dim env")
$vbsLines.Add("Dim command")
$vbsLines.Add("")
$vbsLines.Add("Set shell = CreateObject(""WScript.Shell"")")
$vbsLines.Add("Set env = shell.Environment(""PROCESS"")")
$vbsLines.Add("")

foreach ($entry in $gatewayCmd.Environment.GetEnumerator()) {
    $vbsLines.Add(("env({0}) = {1}" -f (Convert-ToVbsString $entry.Key), (Convert-ToVbsString $entry.Value)))
}

$vbsLines.Add("")
$vbsLines.Add(("command = {0}" -f (Convert-ToVbsString $gatewayCmd.CommandLine)))
$vbsLines.Add("shell.Run command, 0, False")

[System.IO.File]::WriteAllLines($gatewayVbsPath, $vbsLines)

$task = Get-ScheduledTask -TaskName $taskName
$task.Actions = @(New-ScheduledTaskAction -Execute "wscript.exe" -Argument "//B //Nologo $gatewayVbsPath")
Set-ScheduledTask -InputObject $task | Out-Null

if ($Restart) {
    try {
        Stop-ScheduledTask -TaskName $taskName -ErrorAction Stop
    } catch {
    }

    Start-ScheduledTask -TaskName $taskName
}

Write-Host "Hidden gateway action applied."
Write-Host "Task: $taskName"
Write-Host "Wrapper: $gatewayVbsPath"
