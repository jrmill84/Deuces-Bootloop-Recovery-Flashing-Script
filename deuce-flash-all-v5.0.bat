@ECHO OFF
cls
cd /d %~dp0
echo Deuces-flash-all-script-v5.0-Windows
powershell.exe -ExecutionPolicy Bypass -File deuce-flash-all-v5.0-worker.ps1

