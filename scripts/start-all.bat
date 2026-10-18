@echo off
chcp 65001 >nul
title Poyang Crab - Start All (Native, no Docker)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-all.ps1" %*
echo.
pause
