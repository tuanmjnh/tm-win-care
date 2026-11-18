@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion
title TM-WinCare – Windows Optimization & Maintenance Toolkit v1.2

:: Set Working Directory to Script Directory
cd /d "%~dp0"

:: Check if src\Main.ps1 exists
if not exist "src\Main.ps1" (
    echo [LỖI] Không tìm thấy file src\Main.ps1.
    echo Vui lòng giải nén toàn bộ thư mục TM-WinCare trước khi chạy.
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
    echo         TM-WINCARE - KHỞI CHẠY TIỆN ÍCH HỆ THỐNG
    echo =========================================================
    echo  [LƯU Ý] Bạn đang chạy với quyền người dùng thông thường.
    echo  Một số chức năng bảo trì và cấu hình hệ thống sẽ yêu cầu
    echo  quyền Quản trị viên (Administrator).
    echo.
    echo  [1] Tiếp tục với quyền hiện tại (Chỉ đọc & thao tác cơ bản)
    echo  [2] Khởi động lại với quyền Quản trị viên (Khuyến nghị)
    echo =========================================================
    set /p "ADMIN_CHOICE= Lựa chọn của bạn [1-2] (Mặc định 2): "
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
