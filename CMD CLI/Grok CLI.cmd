@echo off
setlocal
:: UTF-8 hỗ trợ tiếng Việt có dấu
chcp 65001 >nul

:: Thư mục làm việc mặc định
cd /d "D:\Applications"

title Grok CLI
set "GROK=%USERPROFILE%\.grok\bin\grok.exe"

echo.
echo ========================================
echo              GROK CLI
echo ========================================
echo.
echo Thư mục làm việc:
echo %CD%
echo.
echo Grok CLI:
echo %GROK%
echo.

if not exist "%GROK%" (
    echo [LỖI] Không tìm thấy Grok CLI tại:
    echo %GROK%
    echo.
    echo Hãy cài đặt bằng lệnh PowerShell:
    echo irm https://x.ai/cli/install.ps1 ^| iex
    echo.
    echo Hoặc nếu cài qua npm:
    echo npm i -g @xai-official/grok
    echo.
    pause
    exit /b 1
)

call "%GROK%" %*

echo.
echo Grok CLI đã kết thúc.
pause
endlocal