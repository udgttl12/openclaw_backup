@echo off
rem OpenClaw Gateway (v2026.2.24)
set "TMPDIR=C:\Users\ydg\AppData\Local\Temp"
set "PATH=C:\nvm4w\nodejs;C:\VulkanSDK\1.4.341.1\Bin;C:\Program Files (x86)\Intel\Intel(R) Management Engine Components\iCLS\;C:\Program Files\Intel\Intel(R) Management Engine Components\iCLS\;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Windows\System32\OpenSSH\;C:\Program Files (x86)\Intel\Intel(R) Management Engine Components\DAL;C:\Program Files\Intel\Intel(R) Management Engine Components\DAL;C:\Program Files\Git\cmd;C:\Users\ydg\AppData\Local\nvm;C:\Program Files\NVIDIA Corporation\NVIDIA App\NvDLISR;C:\Program Files (x86)\NVIDIA Corporation\PhysX\Common;C:\Users\ydg\miniconda3;C:\Users\ydg\miniconda3\Library\mingw-w64\bin;C:\Users\ydg\miniconda3\Library\usr\bin;C:\Users\ydg\miniconda3\Library\bin;C:\Users\ydg\miniconda3\Scripts;C:\Users\ydg\AppData\Local\Microsoft\WindowsApps"
set "OPENCLAW_GATEWAY_PORT=18789"
set "OPENCLAW_GATEWAY_TOKEN=699dc58eb5153705ed53fa71bd0a200b6df6036341945ac4"
set "OPENCLAW_SYSTEMD_UNIT=openclaw-gateway.service"
set "OPENCLAW_SERVICE_MARKER=openclaw"
set "OPENCLAW_SERVICE_KIND=gateway"
set "OPENCLAW_SERVICE_VERSION=2026.2.24"
C:\nvm4w\nodejs\node.exe C:\Users\ydg\AppData\Local\nvm\v22.22.0\node_modules\openclaw\dist\index.js gateway --port 18789
