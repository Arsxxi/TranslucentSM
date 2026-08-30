@echo off
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v TranslucentSM /f
taskkill /f /im start.exe >nul 2>&1
echo Uninstalled. Run install.cmd to re-enable.