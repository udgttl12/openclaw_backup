Option Explicit

Dim shell
Dim launcher

Set shell = CreateObject("WScript.Shell")
launcher = shell.ExpandEnvironmentStrings("%USERPROFILE%\.openclaw\gateway.cmd")
shell.Run """" & launcher & """", 0, False
