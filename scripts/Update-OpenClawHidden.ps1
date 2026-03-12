[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

& openclaw gateway stop
& openclaw update
& openclaw gateway install --force
& (Join-Path $PSScriptRoot "Set-OpenClawGatewayHidden.ps1") -Restart
