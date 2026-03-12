Option Explicit

Dim shell
Dim env
Dim command

Set shell = CreateObject("WScript.Shell")
Set env = shell.Environment("PROCESS")

env("TMPDIR") = "C:\Users\ydg\AppData\Local\Temp"
env("OPENCLAW_GATEWAY_PORT") = "18789"
env("OPENCLAW_SYSTEMD_UNIT") = "openclaw-gateway.service"
env("OPENCLAW_WINDOWS_TASK_NAME") = "OpenClaw Gateway"
env("OPENCLAW_SERVICE_MARKER") = "openclaw"
env("OPENCLAW_SERVICE_KIND") = "gateway"
env("OPENCLAW_SERVICE_VERSION") = "2026.3.7"

command = "C:\nvm4w\nodejs\node.exe C:\Users\ydg\AppData\Local\nvm\v22.22.0\node_modules\openclaw\dist\index.js gateway --port 18789"
shell.Run command, 0, False
