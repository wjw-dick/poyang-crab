@echo off
chcp 65001 >nul
title Poyang Crab - Start Backend
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-backend.ps1" %*
echo.
pause
