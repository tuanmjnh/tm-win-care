# TM-WinCare - Main Entry Point
# TM-WinCare – Windows Optimization & Maintenance Toolkit v1.2
# Adheres to Section 4.1, 9, 10 of TM-WinCare-Architecture-v1.2.md

# 1. Bootstrap Core & UI
$srcDir = $PSScriptRoot
. (Join-Path $srcDir "Core/Bootstrap.ps1")

# 2. Source All Functional Modules
. (Join-Path $srcDir "Modules/Dashboard/Dashboard.ps1")
. (Join-Path $srcDir "Modules/PostInstall/PostInstall.ps1")
. (Join-Path $srcDir "Modules/Optimization/Optimization.ps1")
. (Join-Path $srcDir "Modules/Maintenance/Maintenance.ps1")
. (Join-Path $srcDir "Modules/Repair/Repair.ps1")
. (Join-Path $srcDir "Modules/Network/Network.ps1")
. (Join-Path $srcDir "Modules/Printer/Printer.ps1")
. (Join-Path $srcDir "Modules/Cleanup/WindowsCleanup.ps1")
. (Join-Path $srcDir "Modules/Cleanup/AiDevCleanup.ps1")
. (Join-Path $srcDir "Modules/Privacy/Privacy.ps1")
. (Join-Path $srcDir "Modules/Accounts/Accounts.ps1")
. (Join-Path $srcDir "Modules/QuickCommands/QuickCommands.ps1")
. (Join-Path $srcDir "Modules/BackupRestore/BackupRestore.ps1")

# 3. Main Application Loop
function Start-TMApplication {
    while ($true) {
        $adminBadge = if (Test-IsAdmin) { "[ADMIN]" } else { "[USER]" }
        $adminColor = if (Test-IsAdmin) { "Green" } else { "Yellow" }
        $osStr = if ($global:TM_OS_INFO) { "$($global:TM_OS_INFO.Version) Build $($global:TM_OS_INFO.Build)" } else { "Windows" }

        Write-Host ""
        Write-Host "=========================================================" -ForegroundColor Cyan
        Write-Host "                 TM-WINDOWS TOOLKIT                      " -ForegroundColor White
        Write-Host "      Windows Optimization & Maintenance Toolkit         " -ForegroundColor Gray
        Write-Host "=========================================================" -ForegroundColor Cyan
        Write-Host "  Hệ điều hành: $osStr | Quyền: " -NoNewline -ForegroundColor DarkGray
        Write-Host "$adminBadge" -ForegroundColor $adminColor
        Write-Host "---------------------------------------------------------" -ForegroundColor DarkGray

        Write-Host "  [ 1] " -ForegroundColor Cyan -NoNewline; Write-Host "Dashboard / Thông tin hệ thống" -ForegroundColor White
        Write-Host "  [ 2] " -ForegroundColor Cyan -NoNewline; Write-Host "Windows Post-Install" -ForegroundColor White
        Write-Host "  [ 3] " -ForegroundColor Cyan -NoNewline; Write-Host "Auto Optimize / Custom Optimize" -ForegroundColor White
        Write-Host "  [ 4] " -ForegroundColor Cyan -NoNewline; Write-Host "Disk & System Maintenance" -ForegroundColor White
        Write-Host "  [ 5] " -ForegroundColor Cyan -NoNewline; Write-Host "Windows Repair (SFC / DISM / CHKDSK)" -ForegroundColor White
        Write-Host "  [ 6] " -ForegroundColor Cyan -NoNewline; Write-Host "Network & LAN Support" -ForegroundColor White
        Write-Host "  [ 7] " -ForegroundColor Cyan -NoNewline; Write-Host "Printer Support" -ForegroundColor White
        Write-Host "  [ 8] " -ForegroundColor Cyan -NoNewline; Write-Host "AI & Developer Cleanup" -ForegroundColor White
        Write-Host "  [ 9] " -ForegroundColor Cyan -NoNewline; Write-Host "Privacy, Notifications & Copilot" -ForegroundColor White
        Write-Host "  [10] " -ForegroundColor Cyan -NoNewline; Write-Host "Tài khoản & quyền truy cập" -ForegroundColor White
        Write-Host "  [11] " -ForegroundColor Cyan -NoNewline; Write-Host "Quick Commands" -ForegroundColor White
        Write-Host "  [12] " -ForegroundColor Cyan -NoNewline; Write-Host "Backup & Restore" -ForegroundColor White
        Write-Host "  [ 0] " -ForegroundColor Yellow -NoNewline; Write-Host "Thoát" -ForegroundColor Yellow
        Write-Host "=========================================================" -ForegroundColor Cyan

        $sel = Read-MenuSelection -PromptText "Chọn chức năng" -Min 0 -Max 12
        switch ($sel) {
            1  { Show-TMDashboard }
            2  { Show-TMPostInstallMenu }
            3  { Show-TMOptimizationMenu }
            4  { Show-TMMaintenanceMenu }
            5  { Show-TMRepairMenu }
            6  { Show-TMNetworkMenu }
            7  { Show-TMPrinterMenu }
            8  { Show-TMAiDevCleanupMenu }
            9  { Show-TMPrivacyMenu }
            10 { Show-TMAccountsMenu }
            11 { Show-TMQuickCommandsMenu }
            12 { Show-TMBackupMenu }
            0  {
                Write-InfoMessage "Cảm ơn bạn đã sử dụng TM-WinCare. Tạm biệt!"
                Write-TMLog -TaskId "EXIT" -TaskName "Thoát ứng dụng" -Status "Info" -Message "Thoát bình thường"
                return
            }
        }
    }
}

Start-TMApplication
