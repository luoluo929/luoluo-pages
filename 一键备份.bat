@echo off
chcp 65001 >nul
echo.
echo ==== luoluo-pages backup ====
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0backup.ps1"
echo.
echo Press any key to close this window...
pause >nul
