@echo off
setlocal

:: UTF-8
chcp 65001 >nul

:: Thư mục làm việc mặc định
cd /d "D:\Applications"

title OpenCode CLI

set "OPENCODE=C:\Users\tuanmjnh\AppData\Roaming\npm\opencode.cmd"

echo.
echo ========================================
echo             OPENCODE CLI
echo ========================================
echo.
echo Working Directory:
echo %CD%
echo.
echo OpenCode:
echo %OPENCODE%
echo.

if not exist "%OPENCODE%" (
    echo [LOI] Khong tim thay OpenCode tai:
    echo %OPENCODE%
    echo.
    pause
    exit /b 1
)

call "%OPENCODE%" %*

echo.
echo OpenCode da ket thuc.
pause

endlocal