# TM-WinCare - System Cleanup Module
# Adheres to Section 7A of TM-WinCare-Architecture-v1.2.md

function Show-TMSystemCleanupMenu {
    $menuItems = @(
        @{ Label = "Quét & Phân tích dung lượng các mục có thể dọn"; Action = { Scan-SystemCleanupTargets } },
        @{ Label = "Dọn thư mục Temp của người dùng (%TEMP%)"; Action = { Clean-UserTempFolder } },
        @{ Label = "Dọn thư mục Windows Temp (%WINDIR%\\Temp)"; Action = { Clean-WindowsTempFolder } },
        @{ Label = "Dọn Thùng rác (Recycle Bin)"; Action = { Clean-RecycleBinCustom } },
        @{ Label = "Dọn cache bản cập nhật Windows Update (SoftwareDistribution)"; Action = { Clean-WindowsUpdateCache } },
        @{ Label = "Dọn crash dumps và minidumps cũ"; Action = { Clean-CrashDumps } },
        @{ Label = "Kiểm tra & Hướng dẫn dọn dẹp thư mục Windows.old"; Action = { Show-WindowsOldWizard } },
        @{ Label = "Mở giao diện Cài đặt Lưu trữ (Storage Sense / Settings)"; Action = { Start-Process "ms-settings:storagesense" } }
    )
    Show-TMMenu -Title "DỌN DẸP HỆ THỐNG WINDOWS (SYSTEM CLEANUP)" -MenuItems $menuItems -ExitLabel "Quay lại"
}

function Scan-SystemCleanupTargets {
    Write-SubHeader "QUÉT & PHÂN TÍCH DUNG LƯỢNG RÁC HỆ THỐNG"
    Write-InfoMessage "Đang tính toán dung lượng các thư mục file tạm..."

    $targets = @(
        @{ Name = "User Temp (%TEMP%)"; Path = [System.IO.Path]::GetTempPath() },
        @{ Name = "Windows Temp"; Path = (Join-Path $env:SystemRoot "Temp") },
        @{ Name = "Windows Update Cache"; Path = (Join-Path $env:SystemRoot "SoftwareDistribution\Download") },
        @{ Name = "Minidumps"; Path = (Join-Path $env:SystemRoot "Minidump") }
    )

    $results = @()
    foreach ($t in $targets) {
        $sizeMB = 0
        $count = 0
        if (Test-Path $t.Path) {
            $files = Get-ChildItem -Path $t.Path -File -Recurse -ErrorAction SilentlyContinue
            if ($files) {
                $count = @($files).Count
                $measure = $files | Measure-Object -Property Length -Sum
                if ($measure.Sum) {
                    $sizeMB = [math]::Round($measure.Sum / 1MB, 2)
                }
            }
        }
        $results += [PSCustomObject]@{
            Muc = $t.Name
            SoLuongFile = "$count file"
            DungLuong = "$sizeMB MB"
            DuongDan = $t.Path
        }
    }

    $headers = @("Mục dọn dẹp", "Số lượng file", "Dung lượng ước tính", "Đường dẫn")
    $props = @("Muc", "SoLuongFile", "DungLuong", "DuongDan")
    $widths = @(25, 15, 20, 30)
    Show-TableList -Items $results -Headers $headers -PropertyNames $props -Widths $widths

    # Check Windows.old
    $winOld = "C:\Windows.old"
    if (Test-Path $winOld) {
        Write-WarningMessage "Phát hiện thư mục 'Windows.old' trên ổ C:. Hãy xem mục 'Windows.old Wizard' để dọn dẹp an toàn."
    }
    Pause-Screen
}

function Clean-UserTempFolder {
    $tempPath = [System.IO.Path]::GetTempPath()
    Write-SubHeader "DỌN THƯ MỤC USER TEMP: $tempPath"
    
    $confirmed = Confirm-Action -TaskName "Dọn User Temp" -ImpactDescription "Xóa các file tạm do ứng dụng tạo ra trong %TEMP%. Các file đang được mở hoặc bị khóa sẽ tự động được bỏ qua." -RiskLevel "low"
    if (-not $confirmed) { Pause-Screen; return }

    $files = Get-ChildItem -Path $tempPath -File -ErrorAction SilentlyContinue
    $deleted = 0
    $skipped = 0
    foreach ($f in $files) {
        try {
            Remove-Item $f.FullName -Force -ErrorAction Stop
            $deleted++
        } catch {
            $skipped++
        }
    }
    Write-Success "Đã dọn thành công $deleted file tạm (Bỏ qua $skipped file đang được hệ thống dùng)."
    Write-TMLog -TaskId "CLEAN_USER_TEMP" -TaskName "Dọn User Temp" -Status "Success" -Message "Đã xóa $deleted file"
    Pause-Screen
}

function Clean-WindowsTempFolder {
    if (-not (Assert-Admin "dọn thư mục Windows Temp")) { Pause-Screen; return }

    $winTemp = Join-Path $env:SystemRoot "Temp"
    Write-SubHeader "DỌN THƯ MỤC WINDOWS TEMP: $winTemp"

    $confirmed = Confirm-Action -TaskName "Dọn Windows Temp" -ImpactDescription "Xóa file tạm của Windows và dịch vụ hệ thống. Các file đang được dịch vụ sử dụng sẽ tự động được bỏ qua." -RiskLevel "low"
    if (-not $confirmed) { Pause-Screen; return }

    $files = Get-ChildItem -Path $winTemp -File -ErrorAction SilentlyContinue
    $deleted = 0
    $skipped = 0
    foreach ($f in $files) {
        try {
            Remove-Item $f.FullName -Force -ErrorAction Stop
            $deleted++
        } catch {
            $skipped++
        }
    }
    Write-Success "Đã dọn thành công $deleted file trong Windows Temp (Bỏ qua $skipped file đang dùng)."
    Write-TMLog -TaskId "CLEAN_WIN_TEMP" -TaskName "Dọn Windows Temp" -Status "Success" -Message "Đã xóa $deleted file"
    Pause-Screen
}

function Clean-RecycleBinCustom {
    Write-SubHeader "DỌN SẠCH THÙNG RÁC (RECYCLE BIN)"
    $confirmed = Confirm-Action -TaskName "Dọn sạch Thùng rác" -ImpactDescription "Xóa vĩnh viễn toàn bộ file trong Thùng rác trên tất cả các ổ đĩa. Thao tác này không thể hoàn tác." -RiskLevel "medium"
    if (-not $confirmed) { Pause-Screen; return }

    try {
        Clear-RecycleBin -Force -ErrorAction Stop
        Write-Success "Đã dọn sạch Thùng rác thành công!"
        Write-TMLog -TaskId "CLEAN_RECYCLE_BIN" -TaskName "Dọn thùng rác" -Status "Success" -Message "Thành công"
    } catch {
        Handle-TMException -TaskId "CLEAN_RECYCLE_BIN" -TaskName "Dọn thùng rác" -Exception $_.Exception
    }
    Pause-Screen
}

function Clean-WindowsUpdateCache {
    if (-not (Assert-Admin "dọn cache Windows Update")) { Pause-Screen; return }

    Write-SubHeader "DỌN CACHE BẢN CẬP NHẬT WINDOWS UPDATE"
    $wuPath = Join-Path $env:SystemRoot "SoftwareDistribution\Download"

    $confirmed = Confirm-Action -TaskName "Dọn cache Windows Update" -ImpactDescription "Tạm dừng dịch vụ wuauserv, dọn các file cài đặt đã tải xong trong SoftwareDistribution\Download và khởi động lại dịch vụ." -RiskLevel "medium"
    if (-not $confirmed) { Pause-Screen; return }

    try {
        Write-InfoMessage "Tạm dừng dịch vụ Windows Update..."
        Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
        
        $files = Get-ChildItem -Path $wuPath -Recurse -File -ErrorAction SilentlyContinue
        $deleted = 0
        foreach ($f in $files) {
            try { Remove-Item $f.FullName -Force -ErrorAction Stop; $deleted++ } catch {}
        }
        Write-Success "Đã xóa $deleted file cài đặt cập nhật cũ."

        Write-InfoMessage "Khởi động lại dịch vụ Windows Update..."
        Start-Service -Name wuauserv -ErrorAction SilentlyContinue
        Write-Success "Hoàn tất dọn dẹp cache Windows Update!"
        Write-TMLog -TaskId "CLEAN_WU_CACHE" -TaskName "Dọn cache Windows Update" -Status "Success" -Message "Đã xóa $deleted file"
    } catch {
        Handle-TMException -TaskId "CLEAN_WU_CACHE" -TaskName "Dọn cache WU" -Exception $_.Exception
    }
    Pause-Screen
}

function Clean-CrashDumps {
    if (-not (Assert-Admin "dọn crash dumps")) { Pause-Screen; return }

    Write-SubHeader "DỌN CRASH DUMPS & MINIDUMPS CŨ"
    $dumpPath = Join-Path $env:SystemRoot "Minidump"
    if (-not (Test-Path $dumpPath)) {
        Write-InfoMessage "Không tìm thấy thư mục Minidump trên máy tính này."
        Pause-Screen
        return
    }

    $confirmed = Confirm-Action -TaskName "Dọn Minidump" -ImpactDescription "Xóa các file ghi nhớ sự cố BSOD cũ trong $dumpPath." -RiskLevel "low"
    if ($confirmed) {
        $files = Get-ChildItem -Path $dumpPath -File -ErrorAction SilentlyContinue
        $deleted = 0
        foreach ($f in $files) {
            try { Remove-Item $f.FullName -Force -ErrorAction Stop; $deleted++ } catch {}
        }
        Write-Success "Đã xóa $deleted file minidump."
    }
    Pause-Screen
}

function Show-WindowsOldWizard {
    Write-SubHeader "HƯỚNG DẪN DỌN DẸP THƯ MỤC WINDOWS.OLD AN TOÀN"
    $winOld = "C:\Windows.old"
    if (-not (Test-Path $winOld)) {
        Write-Success "Thư mục 'C:\Windows.old' KHÔNG tồn tại trên máy tính này. Không cần dọn dẹp."
        Pause-Screen
        return
    }

    Write-WarningMessage "PHÁT HIỆN THƯ MỤC C:\Windows.old TRÊN HỆ THỐNG!"
    Write-Host " CẢNH BÁO QUAN TRỌNG:" -ForegroundColor Yellow
    Write-Host "  - Windows.old chứa bản cài đặt Windows trước đó của bạn." -ForegroundColor Gray
    Write-Host "  - Xóa Windows.old sẽ làm MẤT HOÀN TOÀN khả năng quay lại (Rollback) bản Windows cũ." -ForegroundColor Gray
    Write-Host "  - Microsoft khuyến nghị KHÔNG tự dùng lệnh xóa thủ công, mà dùng Disk Cleanup hoặc Storage Sense." -ForegroundColor Gray
    Write-Host ""
    Write-Host " Bạn có muốn mở giao diện Windows Storage Sense để dọn dẹp 'Previous Windows installation(s)' an toàn không? (Y/N): " -ForegroundColor Cyan -NoNewline
    $ans = Read-Host
    if ($ans.Trim().ToUpper() -eq "Y") {
        Start-Process "ms-settings:storagesense"
    }
    Pause-Screen
}
