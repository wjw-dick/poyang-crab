@echo off
chcp 65001 >nul
title Poyang Crab - Start H5
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-h5.ps1" %*
echo.
pause
