[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

& openclaw gateway install --force
& (Join-Path $PSScriptRoot "Set-OpenClawGatewayHidden.ps1") -Restart
