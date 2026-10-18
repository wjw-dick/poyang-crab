@echo off
chcp 65001 >nul
title Poyang Crab - Environment Check
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0check-env.ps1" %*
echo.
pause
