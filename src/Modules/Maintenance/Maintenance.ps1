# TM-WinCare - Disk & System Maintenance Module
# Adheres to Section 3.5 of TM-WinCare-Architecture-v1.2.md

function Show-TMMaintenanceMenu {
    $menuItems = @(
        @{ Label = "Kiểm tra loại ổ đĩa và dung lượng"; Action = { Show-DiskInventory } },
        @{ Label = "Phân tích / tối ưu HDD hoặc SSD (Optimize-Volume)"; Action = { Invoke-DiskOptimization } },
        @{ Label = "Mở công cụ Optimize Drives của Windows (dfrgui.exe)"; Action = { Start-Process "dfrgui.exe" } },
        @{ Label = "CHKDSK - Kiểm tra ổ đĩa (Không sửa)"; Action = { Invoke-ChkdskBasic } },
        @{ Label = "CHKDSK - Quét online NTFS (/scan)"; Action = { Invoke-ChkdskScan } },
        @{ Label = "CHKDSK - Sửa lỗi hệ thống file (/f)"; Action = { Invoke-ChkdskFix } },
        @{ Label = "CHKDSK - Quét sector và phục hồi (/r)"; Action = { Invoke-ChkdskRecovery } },
        @{ Label = "SFC - Xác minh file hệ thống (/verifyonly)"; Action = { Invoke-SfcVerify } },
        @{ Label = "SFC - Quét và sửa file hệ thống (/scannow)"; Action = { Invoke-SfcScanNow } },
        @{ Label = "DISM - Quét Component Store (/ScanHealth)"; Action = { Invoke-DismScan } },
        @{ Label = "DISM - Khôi phục Component Store (/RestoreHealth)"; Action = { Invoke-DismRestore } },
        @{ Label = "Chạy quy trình DISM + SFC tuần tự (Windows Repair Wizard)"; Action = { Invoke-RepairPipeline } },
        @{ Label = "Mở Cài đặt Dọn đĩa (Storage Settings / cleanmgr)"; Action = { Start-Process "cleanmgr.exe" } },
        @{ Label = "Xuất báo cáo ổ đĩa và bảo trì"; Action = { Export-MaintenanceReport } }
    )
    Show-TMMenu -Title "BẢO TRÌ Ổ ĐĨA & HỆ THỐNG (DISK & MAINTENANCE)" -MenuItems $menuItems -ExitLabel "Quay lại"
}

function Show-DiskInventory {
    Write-SubHeader "DANH SÁCH Ổ ĐĨA LƯU TRỮ TRÊN HỆ THỐNG"
    try {
        $volumes = Get-Volume | Where-Object { $null -ne $_.DriveLetter }
        $list = @()
        foreach ($v in $volumes) {
            $totalGB = [math]::Round($v.Size / 1GB, 1)
            $freeGB = [math]::Round($v.SizeRemaining / 1GB, 1)
            $pctFree = if ($totalGB -gt 0) { [math]::Round(($freeGB / $totalGB) * 100, 0) } else { 0 }
            
            # Detect Media Type if possible
            $mediaType = "Không rõ"
            try {
                $part = Get-Partition -DriveLetter $v.DriveLetter -ErrorAction SilentlyContinue
                if ($part) {
                    $disk = Get-Disk -Number $part.DiskNumber -ErrorAction SilentlyContinue
                    if ($disk) {
                        $pDisk = Get-PhysicalDisk | Where-Object { $_.DeviceId -eq $disk.Number } -ErrorAction SilentlyContinue
                        if ($pDisk) { $mediaType = $pDisk.MediaType }
                    }
                }
            } catch {}

            $list += [PSCustomObject]@{
                O = "$($v.DriveLetter):"
                Nhan = $v.FileSystemLabel
                DinhDang = $v.FileSystem
                LoaiMedia = $mediaType
                DungLuong = "$freeGB GB / $totalGB GB ($pctFree% trống)"
                TrangThai = $v.HealthStatus
            }
        }
        $headers = @("Ổ", "Nhãn", "Định dạng", "Loại ổ", "Dung lượng trống", "Sức khỏe")
        $props = @("O", "Nhan", "DinhDang", "LoaiMedia", "DungLuong", "TrangThai")
        $widths = @(5, 15, 12, 12, 28, 10)
        Show-TableList -Items $list -Headers $headers -PropertyNames $props -Widths $widths
    } catch {
        Handle-TMException -TaskId "DISK_INV" -TaskName "Kiểm tra ổ đĩa" -Exception $_.Exception
    }
    Pause-Screen
}

function Invoke-DiskOptimization {
    if (-not (Assert-Admin "tối ưu hóa ổ đĩa")) { Pause-Screen; return }

    Write-SubHeader "TỐI ƯU HÓA VOLUME / SSD RE-TRIM"
    Write-Host " Nhập ký tự ổ đĩa cần tối ưu (ví dụ: C): " -ForegroundColor Cyan -NoNewline
    $dl = Read-Host
    if (-not ($dl -match "^[a-zA-Z]$")) {
        Write-ErrorMessage "Ký tự ổ đĩa không hợp lệ."
        Pause-Screen
        return
    }

    $confirmed = Confirm-Action -TaskName "Tối ưu ổ đĩa $dl`:" -ImpactDescription "Chạy Optimize-Volume (tự động chọn TRIM cho SSD hoặc Defrag an toàn cho HDD)." -RiskLevel "low"
    if ($confirmed) {
        try {
            Write-InfoMessage "Đang chạy Optimize-Volume cho ổ $dl`:..."
            Optimize-Volume -DriveLetter $dl -Verbose
            Write-Success "Tối ưu hóa ổ $dl`: hoàn tất thành công!"
            Write-TMLog -TaskId "DISK_OPT" -TaskName "Tối ưu ổ đĩa" -Status "Success" -Message "Ổ $dl`:"
        } catch {
            Handle-TMException -TaskId "DISK_OPT" -TaskName "Tối ưu ổ đĩa" -Exception $_.Exception
        }
    }
    Pause-Screen
}

function Invoke-ChkdskBasic {
    Write-SubHeader "CHKDSK - KIỂM TRA Ổ ĐĨA CHẾ ĐỘ READ-ONLY"
    Write-Host " Nhập ký tự ổ đĩa (mặc định C): " -ForegroundColor Cyan -NoNewline
    $dl = Read-Host
    if ([string]::IsNullOrWhiteSpace($dl)) { $dl = "C" }
    $dl = $dl.Trim().Substring(0, 1).ToUpper()

    Write-InfoMessage "Đang chạy chkdsk $dl`: (chỉ đọc, không sửa)..."
    & chkdsk.exe "$dl`:"
    Write-TMLog -TaskId "CHKDSK_RO" -TaskName "CHKDSK Read-Only" -Status "Success" -Message "Ổ $dl`:"
    Pause-Screen
}

function Invoke-ChkdskScan {
    if (-not (Assert-Admin "chạy CHKDSK online scan")) { Pause-Screen; return }
    Write-SubHeader "CHKDSK - QUÉT ONLINE NTFS (/scan)"
    Write-Host " Nhập ký tự ổ đĩa (mặc định C): " -ForegroundColor Cyan -NoNewline
    $dl = Read-Host
    if ([string]::IsNullOrWhiteSpace($dl)) { $dl = "C" }
    $dl = $dl.Trim().Substring(0, 1).ToUpper()

    Write-InfoMessage "Đang chạy chkdsk $dl`: /scan..."
    & chkdsk.exe "$dl`:" /scan
    Write-TMLog -TaskId "CHKDSK_SCAN" -TaskName "CHKDSK Scan" -Status "Success" -Message "Ổ $dl`:"
    Pause-Screen
}

function Invoke-ChkdskFix {
    if (-not (Assert-Admin "sửa lỗi ổ đĩa")) { Pause-Screen; return }
    Write-SubHeader "CHKDSK - SỬA LỖI HỆ THỐNG FILE (/f)"
    Write-Host " Nhập ký tự ổ đĩa (mặc định C): " -ForegroundColor Cyan -NoNewline
    $dl = Read-Host
    if ([string]::IsNullOrWhiteSpace($dl)) { $dl = "C" }
    $dl = $dl.Trim().Substring(0, 1).ToUpper()

    $confirmed = Confirm-Action -TaskName "CHKDSK /f $dl`:" -ImpactDescription "Sửa lỗi logic hệ thống file. Với ổ hệ thống C:, Windows sẽ hỏi lên lịch quét khi khởi động lại máy." -RiskLevel "medium"
    if ($confirmed) {
        Write-InfoMessage "Đang thực thi chkdsk $dl`: /f..."
        & chkdsk.exe "$dl`:" /f
        Write-TMLog -TaskId "CHKDSK_FIX" -TaskName "CHKDSK /f" -Status "Success" -Message "Ổ $dl`:" -RequiresRestart ($dl -eq "C")
    }
    Pause-Screen
}

function Invoke-ChkdskRecovery {
    if (-not (Assert-Admin "quét phục hồi sector")) { Pause-Screen; return }
    Write-SubHeader "CHKDSK - QUÉT SECTOR VÀ PHỤC HỒI DỮ LIỆU (/r)"
    Write-WarningMessage "Lưu ý: Quá trình /r quét toàn bộ bề mặt ổ đĩa có thể mất từ 1 đến vài giờ."
    Write-Host " Nhập ký tự ổ đĩa (mặc định C): " -ForegroundColor Cyan -NoNewline
    $dl = Read-Host
    if ([string]::IsNullOrWhiteSpace($dl)) { $dl = "C" }
    $dl = $dl.Trim().Substring(0, 1).ToUpper()

    $confirmed = Confirm-Action -TaskName "CHKDSK /r $dl`:" -ImpactDescription "Tìm sector lỗi và cố gắng phục hồi dữ liệu đọc được. Thao tác mất nhiều thời gian và yêu cầu khởi động lại nếu là ổ C:." -RiskLevel "high" -RequiresKeyword $true
    if ($confirmed) {
        Write-InfoMessage "Đang thực thi chkdsk $dl`: /r..."
        & chkdsk.exe "$dl`:" /r
        Write-TMLog -TaskId "CHKDSK_R" -TaskName "CHKDSK /r" -Status "Success" -Message "Ổ $dl`:" -RequiresRestart ($dl -eq "C")
    }
    Pause-Screen
}

function Invoke-SfcVerify {
    if (-not (Assert-Admin "xác minh file hệ thống")) { Pause-Screen; return }
    Write-SubHeader "SFC - XÁC MINH FILE HỆ THỐNG (/verifyonly)"
    Write-InfoMessage "Đang chạy sfc /verifyonly... Vui lòng không đóng cửa sổ."
    & sfc.exe /verifyonly
    Write-TMLog -TaskId "SFC_VERIFY" -TaskName "SFC VerifyOnly" -Status "Success" -Message "Hoàn tất kiểm tra"
    Pause-Screen
}

function Invoke-SfcScanNow {
    if (-not (Assert-Admin "quét và sửa file hệ thống")) { Pause-Screen; return }
    Write-SubHeader "SFC - QUÉT VÀ SỬA FILE HỆ THỐNG (/scannow)"
    Write-InfoMessage "Đang chạy sfc /scannow... Quá trình này mất khoảng vài phút."
    & sfc.exe /scannow
    Write-TMLog -TaskId "SFC_SCANNOW" -TaskName "SFC ScanNow" -Status "Success" -Message "Hoàn tất quét sửa"
    Pause-Screen
}

function Invoke-DismScan {
    if (-not (Assert-Admin "quét component store")) { Pause-Screen; return }
    Write-SubHeader "DISM - QUÉT COMPONENT STORE (/ScanHealth)"
    Write-InfoMessage "Đang chạy DISM /Online /Cleanup-Image /ScanHealth..."
    & dism.exe /Online /Cleanup-Image /ScanHealth
    Write-TMLog -TaskId "DISM_SCAN" -TaskName "DISM ScanHealth" -Status "Success" -Message "Hoàn tất"
    Pause-Screen
}

function Invoke-DismRestore {
    if (-not (Assert-Admin "khôi phục component store")) { Pause-Screen; return }
    Write-SubHeader "DISM - KHÔI PHỤC COMPONENT STORE (/RestoreHealth)"
    Write-InfoMessage "Đang chạy DISM /Online /Cleanup-Image /RestoreHealth..."
    & dism.exe /Online /Cleanup-Image /RestoreHealth
    Write-TMLog -TaskId "DISM_RESTORE" -TaskName "DISM RestoreHealth" -Status "Success" -Message "Hoàn tất"
    Pause-Screen
}

function Invoke-RepairPipeline {
    if (-not (Assert-Admin "chạy quy trình sửa chữa Windows")) { Pause-Screen; return }
    Write-Header -Title "QUY TRÌNH SỬA CHỮA WINDOWS TOÀN DIỆN (DISM + SFC)"
    Write-InfoMessage "Trình tự khuyến nghị chuẩn của Microsoft:"
    Write-Host "  1. Quét và khôi phục kho linh kiện Windows Component Store (DISM RestoreHealth)" -ForegroundColor Gray
    Write-Host "  2. Quét và thay thế các file hệ thống được bảo vệ (SFC scannow)" -ForegroundColor Gray
    Write-Host ""

    $confirmed = Confirm-Action -TaskName "Sửa chữa hệ thống DISM + SFC" -ImpactDescription "Tự động chạy DISM RestoreHealth rồi đến SFC Scannow để sửa các file Windows bị hỏng." -RiskLevel "medium"
    if ($confirmed) {
        Write-SubHeader "BƯỚC 1/2: CHẠY DISM RESTOREHEALTH"
        & dism.exe /Online /Cleanup-Image /RestoreHealth

        Write-SubHeader "BƯỚC 2/2: CHẠY SFC SCANNOW"
        & sfc.exe /scannow

        Write-Success "Quy trình sửa chữa DISM + SFC đã hoàn thành!"
        Write-TMLog -TaskId "REPAIR_PIPELINE" -TaskName "DISM + SFC Pipeline" -Status "Success" -Message "Hoàn tất quy trình sửa chữa"
    }
    Pause-Screen
}

function Export-MaintenanceReport {
    Write-SubHeader "XUẤT BÁO CÁO Ổ ĐĨA & BẢO TRÌ"
    $reportDir = Join-Path $PSScriptRoot "../../../Logs"
    $filename = "MaintenanceReport_" + (Get-Date).ToString("yyyyMMdd_HHmmss") + ".txt"
    $fullPath = Join-Path $reportDir $filename

    $lines = @()
    $lines += "========================================================="
    $lines += "         TM-WINCARE - BÁO CÁO BẢO TRÌ & Ổ ĐĨA"
    $lines += "  Thời gian: " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $lines += "========================================================="
    try {
        $volumes = Get-Volume | Where-Object { $null -ne $_.DriveLetter }
        foreach ($v in $volumes) {
            $totalGB = [math]::Round($v.Size / 1GB, 1)
            $freeGB = [math]::Round($v.SizeRemaining / 1GB, 1)
            $lines += "Ổ $($v.DriveLetter): [$($v.FileSystemLabel)] - $freeGB GB trống / $totalGB GB ($($v.FileSystem))"
        }
    } catch {}
    $lines += "========================================================="

    Set-Content -Path $fullPath -Value $lines -Encoding UTF8 -Force
    Write-Success "Đã xuất báo cáo ra: $fullPath"
    Pause-Screen
}
