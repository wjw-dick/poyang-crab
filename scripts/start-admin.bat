@echo off
chcp 65001 >nul
title Poyang Crab - Start Admin
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-admin.ps1" %*
echo.
pause
