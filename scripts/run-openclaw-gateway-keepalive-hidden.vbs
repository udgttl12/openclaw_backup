Set shell = CreateObject("WScript.Shell")
cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""C:\Users\ydg\.openclaw\scripts\ensure-openclaw-gateway.ps1"""
shell.Run cmd, 0, False
