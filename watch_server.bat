@echo off
chcp 65001 >nul
title Ikariam Wars — Watch Server (auto-restart)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0watch_server.ps1"
pause
