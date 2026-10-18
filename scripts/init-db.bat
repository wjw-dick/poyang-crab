@echo off
chcp 65001 >nul
title Poyang Crab - Init Database
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0init-db.ps1" %*
echo.
pause
