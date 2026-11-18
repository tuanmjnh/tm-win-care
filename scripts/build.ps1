# TM-WinCare - Bundler & Release Packaging Script
# Generates:
#   1. dist/TM-WinCare-AIO.ps1 (Single-file script for `irm <url> | iex`)
#   2. dist/TM-WinCare-AIO.cmd (All-In-One double-clickable CMD script)
#   3. dist/TM-WinCare-Portable.zip (Full standalone release archive)

$rootDir = Resolve-Path (Join-Path $PSScriptRoot "..")
$distDir = Join-Path $rootDir "dist"
if (-not (Test-Path $distDir)) {
    New-Item -ItemType Directory -Path $distDir -Force | Out-Null
}

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "        TM-WINCARE - QUY TRÌNH ĐÓNG GÓI & BUILD         " -ForegroundColor White
Write-Host "=========================================================" -ForegroundColor Cyan

# 1. Read JSON data files to embed
Write-Host "-> Đang nhúng cấu hình và dữ liệu catalog..." -ForegroundColor Yellow
$appJson = Get-Content (Join-Path $rootDir "config/app.json") -Raw -Encoding UTF8
$quickCmdsJson = Get-Content (Join-Path $rootDir "data/command-catalog/quick-commands.json") -Raw -Encoding UTF8
$profilesJson = Get-Content (Join-Path $rootDir "data/optimization-profiles/profiles.json") -Raw -Encoding UTF8
$sysCleanupJson = Get-Content (Join-Path $rootDir "data/cleanup-catalog/system-cleanup.json") -Raw -Encoding UTF8
$aiDevCleanupJson = Get-Content (Join-Path $rootDir "data/cleanup-catalog/aidev-cleanup.json") -Raw -Encoding UTF8

# 2. Collect PowerShell source files in dependency order
$sourceFiles = @(
    "src/UI/Colors.ps1",
    "src/UI/Tables.ps1",
    "src/UI/Prompts.ps1",
    "src/Core/Logger.ps1",
    "src/Core/Admin.ps1",
    "src/Core/WindowsInfo.ps1",
    "src/Core/Compatibility.ps1",
    "src/Core/Backup.ps1",
    "src/Core/Restore.ps1",
    "src/Core/Confirm.ps1",
    "src/Core/ErrorHandler.ps1",
    "src/Core/Menu.ps1",
    "src/Modules/Dashboard/Dashboard.ps1",
    "src/Modules/PostInstall/PostInstall.ps1",
    "src/Modules/Optimization/Profiles.ps1",
    "src/Modules/Optimization/Optimization.ps1",
    "src/Modules/Maintenance/Maintenance.ps1",
    "src/Modules/Repair/Repair.ps1",
    "src/Modules/Network/Network.ps1",
    "src/Modules/Printer/Printer.ps1",
    "src/Modules/Cleanup/WindowsCleanup.ps1",
    "src/Modules/Cleanup/AiDevCleanup.ps1",
    "src/Modules/Privacy/Privacy.ps1",
    "src/Modules/Accounts/Accounts.ps1",
    "src/Modules/QuickCommands/QuickCommands.ps1",
    "src/Modules/BackupRestore/BackupRestore.ps1"
)

# 3. Assemble AIO PowerShell Code
Write-Host "-> Đang đóng gói mã nguồn thành Single-file AIO script..." -ForegroundColor Yellow

$psBuilder = [System.Text.StringBuilder]::new()
$psBuilder.AppendLine("# TM-WinCare – Windows Optimization & Maintenance Toolkit v1.2 (All-In-One Standalone)") | Out-Null
$psBuilder.AppendLine("[Console]::OutputEncoding = [System.Text.Encoding]::UTF8") | Out-Null
$psBuilder.AppendLine("`$OutputEncoding = [System.Text.Encoding]::UTF8") | Out-Null
$psBuilder.AppendLine("`$global:IsBundledAIO = `$true") | Out-Null

# Embed JSON variables
$escapedApp = $appJson.Replace('"', '\"')
$escapedCmds = $quickCmdsJson.Replace('"', '\"')
$escapedProfs = $profilesJson.Replace('"', '\"')
$escapedSysClean = $sysCleanupJson.Replace('"', '\"')
$escapedAiClean = $aiDevCleanupJson.Replace('"', '\"')

$psBuilder.AppendLine("`$global:TM_CONFIG = @'`n$appJson`n'@ | ConvertFrom-Json") | Out-Null
$psBuilder.AppendLine("`$global:TM_EMBEDDED_QUICK_COMMANDS = @'`n$quickCmdsJson`n'@ | ConvertFrom-Json") | Out-Null
$psBuilder.AppendLine("`$global:TM_EMBEDDED_OPTIMIZATION_PROFILES = @'`n$profilesJson`n'@ | ConvertFrom-Json") | Out-Null
$psBuilder.AppendLine("`$global:TM_EMBEDDED_SYSTEM_CLEANUP = @'`n$sysCleanupJson`n'@ | ConvertFrom-Json") | Out-Null
$psBuilder.AppendLine("`$global:TM_EMBEDDED_AIDEV_CLEANUP = @'`n$aiDevCleanupJson`n'@ | ConvertFrom-Json") | Out-Null
$psBuilder.AppendLine("") | Out-Null

# Append each source file (filtering out local dot-sourcing lines)
foreach ($relPath in $sourceFiles) {
    $full = Join-Path $rootDir $relPath
    if (Test-Path $full) {
        $content = Get-Content $full -Raw -Encoding UTF8
        # Remove dot-sourcing lines
        $filtered = ($content -split "`r?`n" | Where-Object { $_ -notmatch '^\s*\.\s*\(' }) -join "`r`n"
        $psBuilder.AppendLine("# === SOURCE: $relPath ===") | Out-Null
        $psBuilder.AppendLine($filtered) | Out-Null
        $psBuilder.AppendLine("") | Out-Null
    }
}

# Append Main Menu caller
$mainContent = Get-Content (Join-Path $rootDir "src/Main.ps1") -Raw -Encoding UTF8
$filteredMain = ($mainContent -split "`r?`n" | Where-Object { $_ -notmatch '^\s*\.\s*\(' }) -join "`r`n"
$psBuilder.AppendLine("# === MAIN ENTRY POINT ===") | Out-Null
$psBuilder.AppendLine($filteredMain) | Out-Null
$psBuilder.AppendLine("Start-TMApplication") | Out-Null

$bundlePs1Path = Join-Path $distDir "TM-WinCare-AIO.ps1"
[System.IO.File]::WriteAllText($bundlePs1Path, $psBuilder.ToString(), [System.Text.Encoding]::UTF8)
Write-Host " [OK] Đã tạo thành công: $bundlePs1Path" -ForegroundColor Green

# 4. Generate TM-WinCare-AIO.cmd (Polyglot Batch + PowerShell)
Write-Host "-> Đang tạo file All-In-One CMD (TM-WinCare-AIO.cmd)..." -ForegroundColor Yellow
$cmdHeader = @'
<# : batch script
@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion
title TM-WinCare – Windows Optimization & Maintenance Toolkit v1.2 (All-In-One)

set "PS_EXE=powershell.exe"
where pwsh.exe >nul 2>nul && set "PS_EXE=pwsh.exe"

net session >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo =========================================================
    echo         TM-WINCARE - KHỞI CHẠY TIỆN ÍCH HỆ THỐNG
    echo =========================================================
    echo  [LƯU Ý] Bạn đang chạy với quyền người dùng thông thường.
    echo  Một số tác vụ quản trị sẽ yêu cầu quyền Administrator.
    echo.
    echo  [1] Tiếp tục với quyền thường
    echo  [2] Khởi động lại với quyền Administrator (Khuyến nghị)
    echo =========================================================
    set /p "ADMIN_CHOICE= Lựa chọn của bạn [1-2] (Mặc định 2): "
    if "!ADMIN_CHOICE!"=="" set "ADMIN_CHOICE=2"
    if "!ADMIN_CHOICE!"=="2" (
        powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process cmd.exe -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
        exit /b 0
    )
)

%PS_EXE% -NoProfile -ExecutionPolicy Bypass -Command "$c=[System.IO.File]::ReadAllText('%~f0', [System.Text.Encoding]::UTF8); $i=$c.IndexOf('#_POWERSHELL_START_#'); Invoke-Expression $c.Substring($i)"
endlocal
exit /b
: end batch / begin powershell #>
#_POWERSHELL_START_#
'@

$aioCmdPath = Join-Path $distDir "TM-WinCare-AIO.cmd"
$aioCmdContent = $cmdHeader + "`r`n" + $psBuilder.ToString()
[System.IO.File]::WriteAllText($aioCmdPath, $aioCmdContent, [System.Text.Encoding]::UTF8)
Write-Host " [OK] Đã tạo thành công: $aioCmdPath" -ForegroundColor Green

# 5. Generate Root Online Launcher get.ps1
Write-Host "-> Đang tạo file khởi chạy trực tuyến get.ps1..." -ForegroundColor Yellow
$getPs1Content = @'
# TM-WinCare Online Bootstrap Launcher
# Usage: irm https://raw.githubusercontent.com/<username>/tm-wincare/main/dist/TM-WinCare-AIO.ps1 | iex
$url = "https://raw.githubusercontent.com/tuanminh/tm-wincare/main/dist/TM-WinCare-AIO.ps1"
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $content = (Invoke-RestMethod -Uri $url -UseBasicParsing)
    Invoke-Expression $content
} catch {
    Write-Host "[LỖI] Không thể tải TM-WinCare: $($_.Exception.Message)" -ForegroundColor Red
}
'@
[System.IO.File]::WriteAllText((Join-Path $rootDir "get.ps1"), $getPs1Content, [System.Text.Encoding]::UTF8)

# 6. Generate Portable ZIP
Write-Host "-> Đang nén file bản phát hành ZIP..." -ForegroundColor Yellow
$zipPath = Join-Path $distDir "TM-WinCare-v1.2.0-Portable.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }

$itemsToZip = @(
    (Join-Path $rootDir "Start.cmd"),
    (Join-Path $rootDir "README.md"),
    (Join-Path $rootDir "src"),
    (Join-Path $rootDir "config"),
    (Join-Path $rootDir "data")
)
Compress-Archive -Path $itemsToZip -DestinationPath $zipPath -CompressionLevel Optimal -Force
Write-Host " [OK] Đã tạo bản phát hành ZIP: $zipPath" -ForegroundColor Green

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host " BUILD THÀNH CÔNG! SẴN SÀNG RELEASE LÊN GITHUB." -ForegroundColor Green
Write-Host " Các file đã tạo:" -ForegroundColor White
Write-Host "  1. dist/TM-WinCare-AIO.ps1 (chạy qua irm ... | iex)" -ForegroundColor Cyan
Write-Host "  2. dist/TM-WinCare-AIO.cmd (chạy 1 file duy nhất)" -ForegroundColor Cyan
Write-Host "  3. dist/TM-WinCare-v1.2.0-Portable.zip (bản nén)" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
