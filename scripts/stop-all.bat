@echo off
chcp 65001 >nul
title Poyang Crab - Stop All
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0stop-all.ps1" %*
echo.
pause
