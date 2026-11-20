@echo off
setlocal

:: Bật UTF-8 cho tiếng Việt có dấu
chcp 65001 >nul
set "PYTHONIOENCODING=utf-8"
set "LANG=en_US.UTF-8"

:: Thư mục làm việc mặc định
cd /d "D:\Applications"

title Pi CLI Agent

:: Tự động tìm đường dẫn thực tế của lệnh pi trong hệ thống
set "PI_CLI="
for /f "delims=" %%i in ('where pi.cmd 2^>nul') do (
    set "PI_CLI=%%i"
    goto :found
)
for /f "delims=" %%i in ('where pi 2^>nul') do (
    set "PI_CLI=%%i"
    goto :found
)

:found
echo.
echo ========================================
echo              PI CLI AGENT
echo ========================================
echo.
echo Working Directory:
echo %CD%
echo.

if not defined PI_CLI (
    echo [LỖI] Không tìm thấy lệnh "pi" trong hệ thống!
    echo Vui lòng kiểm tra lại xem bạn đã cài đặt Pi CLI chưa, hoặc tên lệnh có khác không.
    echo.
    pause
    exit /b 1
)

echo Pi CLI:
echo %PI_CLI%
echo.

call "%PI_CLI%" %*

echo.
echo Pi CLI đã kết thúc.
pause

endlocal