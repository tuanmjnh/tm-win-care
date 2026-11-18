@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion
title TM-WinCare – Windows Optimization & Maintenance Toolkit v1.2

:: Set Working Directory to Script Directory
cd /d "%~dp0"

:: Check if src\Main.ps1 exists
if not exist "src\Main.ps1" (
    echo [ERROR] Cannot find src\Main.ps1.
    echo Please extract the entire TM-WinCare folder before running.
    pause
    exit /b 1
)

:: Find best PowerShell runtime (PowerShell 7 pwsh.exe if available, otherwise Windows PowerShell)
set "PS_EXE=powershell.exe"
where pwsh.exe >nul 2>nul
if %ERRORLEVEL% equ 0 (
    set "PS_EXE=pwsh.exe"
)

:: Check for Administrative Rights
net session >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo =========================================================
    echo         TM-WINCARE - WINDOWS TOOLKIT LAUNCHER
    echo =========================================================
    echo  [NOTICE] Currently running under standard user privileges.
    echo  System maintenance and optimization functions require
    echo  elevated Administrator rights.
    echo.
    echo  [1] Continue with standard privileges (Read-Only / Basic)
    echo  [2] Restart with Administrator privileges (Recommended)
    echo =========================================================
    set /p "ADMIN_CHOICE= Select choice [1-2] (Default 2): "
    if "!ADMIN_CHOICE!"=="" set "ADMIN_CHOICE=2"
    if "!ADMIN_CHOICE!"=="2" (
        powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process cmd.exe -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
        exit /b 0
    )
)

:: Launch TM-WinCare Main Script
"%PS_EXE%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0src\Main.ps1"

endlocal
exit /b 0
