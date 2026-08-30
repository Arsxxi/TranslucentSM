@echo off
cd /d "%~dp0"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v TranslucentSM /t REG_SZ /d "\"%~dp0start.exe\" --daemon --quiet" /f
start "" "start.exe" --daemon --quiet
echo Installed. TranslucentSM will auto-apply on every Start Menu launch.