Start-Process -WindowStyle Hidden -FilePath "C:\nvm4w\nodejs\openclaw.cmd" -ArgumentList @(
  "gateway","run","--port","18789","--force"
)
