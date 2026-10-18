@echo off
chcp 65001 >nul
title Poyang Crab - Miniapp Browser Preview
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0preview-miniapp.ps1" %*
echo.
pause
