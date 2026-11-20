reg add "HKCU\Console" /v FaceName /t REG_SZ /d "Consolas" /f
reg add "HKCU\Console" /v FontFamily /t REG_DWORD /d 54 /f
reg add "HKCU\Console" /v FontSize /t REG_DWORD /d 1048576 /f
reg add "HKCU\Console" /v CodePage /t REG_DWORD /d 65001 /f
pause