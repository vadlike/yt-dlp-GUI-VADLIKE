@echo off
start "" explorer "%~dp0certs"
powershell -ExecutionPolicy Bypass -File "%~dp0yt-dlp.ps1"
pause
