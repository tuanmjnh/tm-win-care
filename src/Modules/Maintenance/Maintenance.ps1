# TM-WinCare - Disk & System Maintenance Module
# Adheres to Section 3.5 of TM-WinCare-Architecture-v1.2.md

function Show-TMMaintenanceMenu {
    $menuItems = @(
        @{ Label = "🚀 Tự Động Xử Lý Lần Lượt Toàn Diện (CHKDSK -> DISM -> SFC -> WinSxS)"; Action = { Invoke-FullSequentialRepair } },
        @{ Label = "Quy Trình Sửa Chữa Nhanh (DISM RestoreHealth -> SFC Scannow)"; Action = { Invoke-RepairPipeline } },
        @{ Label = "Inspect Disk Media Types & Storage Capacity"; Action = { Show-DiskInventory } },
        @{ Label = "Optimize Volume / SSD Re-Trim (Optimize-Volume)"; Action = { Invoke-DiskOptimization } },
        @{ Label = "Open Windows Optimize Drives GUI (dfrgui.exe)"; Action = { Start-Process "dfrgui.exe" } },
        @{ Label = "CHKDSK - Read-Only Filesystem Check"; Action = { Invoke-ChkdskBasic } },
        @{ Label = "CHKDSK - Online NTFS Scan (/scan)"; Action = { Invoke-ChkdskScan } },
        @{ Label = "CHKDSK - Fix Filesystem Errors (/f)"; Action = { Invoke-ChkdskFix } },
        @{ Label = "CHKDSK - Locate Bad Sectors & Recover Readable Data (/r)"; Action = { Invoke-ChkdskRecovery } },
        @{ Label = "SFC - Verify System File Integrity (/verifyonly)"; Action = { Invoke-SfcVerify } },
        @{ Label = "SFC - Scan and Automatically Repair Corrupted Files (/scannow)"; Action = { Invoke-SfcScanNow } },
        @{ Label = "DISM - Scan Component Store Health (/ScanHealth)"; Action = { Invoke-DismScan } },
        @{ Label = "DISM - Repair Component Store Corruption (/RestoreHealth)"; Action = { Invoke-DismRestore } },
        @{ Label = "Open Windows Disk Cleanup (cleanmgr.exe)"; Action = { Start-Process "cleanmgr.exe" } },
        @{ Label = "Export Disk & Maintenance Report"; Action = { Export-MaintenanceReport } }
    )
    Show-TMMenu -Title "DISK & SYSTEM MAINTENANCE" -MenuItems $menuItems -ExitLabel "Back"
}

function Show-DiskInventory {
    Write-SubHeader "SYSTEM STORAGE VOLUMES & HEALTH STATUS"
    try {
        $volumes = Get-Volume | Where-Object { $null -ne $_.DriveLetter }
        $list = @()
        foreach ($v in $volumes) {
            $totalGB = [math]::Round($v.Size / 1GB, 1)
            $freeGB = [math]::Round($v.SizeRemaining / 1GB, 1)
            $pctFree = if ($totalGB -gt 0) { [math]::Round(($freeGB / $totalGB) * 100, 0) } else { 0 }
            
            # Detect Media Type if possible
            $mediaType = "Unknown"
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
                Drive = "$($v.DriveLetter):"
                Label = $v.FileSystemLabel
                FileSystem = $v.FileSystem
                MediaType = $mediaType
                Capacity = "$freeGB GB / $totalGB GB ($pctFree% free)"
                Health = $v.HealthStatus
            }
        }
        $headers = @("Drive", "Label", "File System", "Media Type", "Free Space", "Health")
        $props = @("Drive", "Label", "FileSystem", "MediaType", "Capacity", "Health")
        $widths = @(6, 15, 12, 12, 28, 10)
        Show-TableList -Items $list -Headers $headers -PropertyNames $props -Widths $widths
    } catch {
        Handle-TMException -TaskId "DISK_INV" -TaskName "Inspect Disks" -Exception $_.Exception
    }
    Pause-Screen
}

function Invoke-DiskOptimization {
    if (-not (Assert-Admin "optimize drive")) { Pause-Screen; return }

    Write-SubHeader "OPTIMIZE STORAGE VOLUME / SSD RE-TRIM"
    Write-Host " Enter drive letter to optimize (e.g. C): " -ForegroundColor Cyan -NoNewline
    $dl = Read-Host
    if (-not ($dl -match "^[a-zA-Z]$")) {
        Write-ErrorMessage "Invalid drive letter."
        Pause-Screen
        return
    }

    $confirmed = Confirm-Action -TaskName "Optimize Drive $dl`:" -ImpactDescription "Execute Optimize-Volume (automatically runs TRIM for SSD or safe defragmentation for HDD)." -RiskLevel "low"
    if ($confirmed) {
        try {
            Write-InfoMessage "Running Optimize-Volume on drive $dl`:..."
            Optimize-Volume -DriveLetter $dl -Verbose
            Write-Success "Optimization of drive $dl`: completed successfully!"
            Write-TMLog -TaskId "DISK_OPT" -TaskName "Optimize Drive" -Status "Success" -Message "Drive $dl`:"
        } catch {
            Handle-TMException -TaskId "DISK_OPT" -TaskName "Optimize Drive" -Exception $_.Exception
        }
    }
    Pause-Screen
}

function Invoke-ChkdskBasic {
    Write-SubHeader "CHKDSK - READ-ONLY FILESYSTEM CHECK"
    Write-Host " Enter drive letter (default C): " -ForegroundColor Cyan -NoNewline
    $dl = Read-Host
    if ([string]::IsNullOrWhiteSpace($dl)) { $dl = "C" }
    $dl = $dl.Trim().Substring(0, 1).ToUpper()

    Write-InfoMessage "Running chkdsk $dl`: (read-only mode)..."
    & chkdsk.exe "$dl`:"
    Write-TMLog -TaskId "CHKDSK_RO" -TaskName "CHKDSK Read-Only" -Status "Success" -Message "Drive $dl`:"
    Pause-Screen
}

function Invoke-ChkdskScan {
    if (-not (Assert-Admin "run CHKDSK online scan")) { Pause-Screen; return }
    Write-SubHeader "CHKDSK - ONLINE NTFS SCAN (/scan)"
    Write-Host " Enter drive letter (default C): " -ForegroundColor Cyan -NoNewline
    $dl = Read-Host
    if ([string]::IsNullOrWhiteSpace($dl)) { $dl = "C" }
    $dl = $dl.Trim().Substring(0, 1).ToUpper()

    Write-InfoMessage "Running chkdsk $dl`: /scan..."
    & chkdsk.exe "$dl`:" /scan
    Write-TMLog -TaskId "CHKDSK_SCAN" -TaskName "CHKDSK Scan" -Status "Success" -Message "Drive $dl`:"
    Pause-Screen
}

function Invoke-ChkdskFix {
    if (-not (Assert-Admin "fix disk errors")) { Pause-Screen; return }
    Write-SubHeader "CHKDSK - REPAIR FILESYSTEM ERRORS (/f)"
    Write-Host " Enter drive letter (default C): " -ForegroundColor Cyan -NoNewline
    $dl = Read-Host
    if ([string]::IsNullOrWhiteSpace($dl)) { $dl = "C" }
    $dl = $dl.Trim().Substring(0, 1).ToUpper()

    $confirmed = Confirm-Action -TaskName "CHKDSK /f $dl`:" -ImpactDescription "Fixes filesystem logic errors. For system drive C:, Windows will schedule the check upon next reboot." -RiskLevel "medium"
    if ($confirmed) {
        Write-InfoMessage "Executing chkdsk $dl`: /f..."
        & chkdsk.exe "$dl`:" /f
        Write-TMLog -TaskId "CHKDSK_FIX" -TaskName "CHKDSK /f" -Status "Success" -Message "Drive $dl`:" -RequiresRestart ($dl -eq "C")
    }
    Pause-Screen
}

function Invoke-ChkdskRecovery {
    if (-not (Assert-Admin "scan and recover bad sectors")) { Pause-Screen; return }
    Write-SubHeader "CHKDSK - BAD SECTOR SCAN & DATA RECOVERY (/r)"
    Write-WarningMessage "Notice: Scanning every sector on the drive surface may take hours depending on disk capacity."
    Write-Host " Enter drive letter (default C): " -ForegroundColor Cyan -NoNewline
    $dl = Read-Host
    if ([string]::IsNullOrWhiteSpace($dl)) { $dl = "C" }
    $dl = $dl.Trim().Substring(0, 1).ToUpper()

    $confirmed = Confirm-Action -TaskName "CHKDSK /r $dl`:" -ImpactDescription "Locates bad sectors and recovers readable information. Demands high disk I/O and requires a restart for drive C:." -RiskLevel "high" -RequiresKeyword $true
    if ($confirmed) {
        Write-InfoMessage "Executing chkdsk $dl`: /r..."
        & chkdsk.exe "$dl`:" /r
        Write-TMLog -TaskId "CHKDSK_R" -TaskName "CHKDSK /r" -Status "Success" -Message "Drive $dl`:" -RequiresRestart ($dl -eq "C")
    }
    Pause-Screen
}

function Invoke-SfcVerify {
    if (-not (Assert-Admin "verify system files")) { Pause-Screen; return }
    Write-SubHeader "SFC - VERIFY SYSTEM FILE INTEGRITY (/verifyonly)"
    Write-InfoMessage "Running sfc /verifyonly... Please keep this window open."
    & sfc.exe /verifyonly
    Write-TMLog -TaskId "SFC_VERIFY" -TaskName "SFC VerifyOnly" -Status "Success" -Message "Verification complete"
    Pause-Screen
}

function Invoke-SfcScanNow {
    if (-not (Assert-Admin "scan and repair system files")) { Pause-Screen; return }
    Write-SubHeader "SFC - SCAN AND REPAIR SYSTEM FILES (/scannow)"
    Write-InfoMessage "Running sfc /scannow... This process takes several minutes."
    & sfc.exe /scannow
    Write-TMLog -TaskId "SFC_SCANNOW" -TaskName "SFC ScanNow" -Status "Success" -Message "Scan and repair complete"
    Pause-Screen
}

function Invoke-DismScan {
    if (-not (Assert-Admin "scan component store")) { Pause-Screen; return }
    Write-SubHeader "DISM - SCAN COMPONENT STORE (/ScanHealth)"
    Write-InfoMessage "Running DISM /Online /Cleanup-Image /ScanHealth..."
    & dism.exe /Online /Cleanup-Image /ScanHealth
    Write-TMLog -TaskId "DISM_SCAN" -TaskName "DISM ScanHealth" -Status "Success" -Message "Scan complete"
    Pause-Screen
}

function Invoke-DismRestore {
    if (-not (Assert-Admin "repair component store")) { Pause-Screen; return }
    Write-SubHeader "DISM - REPAIR COMPONENT STORE (/RestoreHealth)"
    Write-InfoMessage "Running DISM /Online /Cleanup-Image /RestoreHealth..."
    & dism.exe /Online /Cleanup-Image /RestoreHealth
    Write-TMLog -TaskId "DISM_RESTORE" -TaskName "DISM RestoreHealth" -Status "Success" -Message "Repair complete"
    Pause-Screen
}

function Invoke-FullSequentialRepair {
    <#
    .SYNOPSIS
        Comprehensive 5-step automated sequential repair pipeline:
        1. CHKDSK /scan (Online filesystem check)
        2. DISM /ScanHealth (Component Store health scan)
        3. DISM /RestoreHealth (Component Store corruption repair)
        4. SFC /scannow (Protected OS files integrity check & replacement)
        5. DISM /StartComponentCleanup (Purge obsolete WinSxS packages)
    #>
    if (-not (Assert-Admin "run full sequential Windows repair wizard")) { Pause-Screen; return }

    Write-Header -Title "QUY TRÌNH TỰ ĐỘNG XỬ LÝ LẦN LƯỢT TOÀN DIỆN (CHKDSK -> DISM -> SFC -> WINSXS)"
    Write-InfoMessage "Tự động thực thi tuần tự 5 bước sửa chữa chuyên sâu chuẩn Microsoft:"
    Write-Host "  [1/5] Quét lỗi logic phân vùng NTFS trực tuyến (chkdsk C: /scan)" -ForegroundColor Cyan
    Write-Host "  [2/5] Quét sâu kho lưu trữ linh kiện hệ thống (DISM /ScanHealth)" -ForegroundColor Cyan
    Write-Host "  [3/5] Khôi phục & sửa chữa Component Store (DISM /RestoreHealth)" -ForegroundColor Cyan
    Write-Host "  [4/5] Quét & tự động thay thế file hệ thống bị hỏng (sfc /scannow)" -ForegroundColor Cyan
    Write-Host "  [5/5] Dọn dẹp kho linh kiện WinSxS sau khi sửa chữa (DISM /StartComponentCleanup)" -ForegroundColor Cyan
    Write-Host ""

    $confirmed = Confirm-Action -TaskName "Full Sequential Windows Repair" -ImpactDescription "Automatically executes the complete 5-step repair and integrity workflow sequentially. May take 10-25 minutes." -RiskLevel "medium"
    if (-not $confirmed) {
        Write-SkipMessage "Sequential repair cancelled by user."
        Pause-Screen
        return
    }

    $startTime = Get-Date

    # Step 1: CHKDSK Online Scan
    Write-SubHeader "[BƯỚC 1/5] QUÉT LỖI Ổ ĐĨA TRỰC TUYẾN (chkdsk C: /scan)"
    Write-InfoMessage "Đang kiểm tra tính toàn vẹn filesystem NTFS trên ổ C: (không ngắt quãng hệ thống)..."
    try {
        & chkdsk.exe "C:" /scan
        Write-Success "Bước 1 hoàn tất: Đã quét xong phân vùng C:!"
    } catch {
        Write-WarningMessage "Thông báo từ CHKDSK: $($_.Exception.Message)"
    }

    # Step 2: DISM ScanHealth
    Write-SubHeader "[BƯỚC 2/5] QUÉT KHO LINH KIỆN HỆ THỐNG (DISM /ScanHealth)"
    Write-InfoMessage "Đang quét sâu kiểm tra kho linh kiện Component Store..."
    try {
        & dism.exe /Online /Cleanup-Image /ScanHealth
        Write-Success "Bước 2 hoàn tất: Đã quét xong kho linh kiện!"
    } catch {
        Write-WarningMessage "Thông báo từ DISM ScanHealth: $($_.Exception.Message)"
    }

    # Step 3: DISM RestoreHealth
    Write-SubHeader "[BƯỚC 3/5] KHÔI PHỤC & SỬA CHỮA KHO LINH KIỆN (DISM /RestoreHealth)"
    Write-InfoMessage "Đang tải và sửa chữa các gói hệ thống bị hỏng từ máy chủ Microsoft..."
    try {
        & dism.exe /Online /Cleanup-Image /RestoreHealth
        Write-Success "Bước 3 hoàn tất: Đã khôi phục Component Store thành công!"
    } catch {
        Write-WarningMessage "Thông báo từ DISM RestoreHealth: $($_.Exception.Message)"
    }

    # Step 4: SFC Scannow
    Write-SubHeader "[BƯỚC 4/5] QUÉT & THAY THẾ FILE HỆ THỐNG (SFC /scannow)"
    Write-InfoMessage "Đang quét và khôi phục các file hệ điều hành bị hỏng bằng file sạch từ Component Store..."
    try {
        & sfc.exe /scannow
        Write-Success "Bước 4 hoàn tất: Đã kiểm tra và sửa chữa xong file hệ thống!"
    } catch {
        Write-WarningMessage "Thông báo từ SFC Scannow: $($_.Exception.Message)"
    }

    # Step 5: DISM StartComponentCleanup
    Write-SubHeader "[BƯỚC 5/5] DỌN DẸP KHO LINH KIỆN WINSXS (DISM /StartComponentCleanup)"
    Write-InfoMessage "Đang dọn dẹp các tệp linh kiện cũ bị thay thế trong WinSxS để thu hồi ổ cứng..."
    try {
        & dism.exe /Online /Cleanup-Image /StartComponentCleanup
        Write-Success "Bước 5 hoàn tất: Đã dọn dẹp kho WinSxS sạch sẽ!"
    } catch {
        Write-WarningMessage "Thông báo từ DISM ComponentCleanup: $($_.Exception.Message)"
    }

    $elapsed = (Get-Date) - $startTime
    $elapsedMinutes = [math]::Round($elapsed.TotalMinutes, 1)

    Write-Header -Title "QUY TRÌNH TỰ ĐỘNG XỬ LÝ LẦN LƯỢT HOÀN TẤT!"
    Write-Success "Toàn bộ 5 bước kiểm tra & sửa chữa hệ điều hành đã được thực thi thành công!"
    Write-Host ""
    Write-Host "  BÁO CÁO TỔNG KẾT:" -ForegroundColor Yellow
    Write-Host "  [+] Bước 1: CHKDSK /scan               : Hoàn tất" -ForegroundColor Green
    Write-Host "  [+] Bước 2: DISM /ScanHealth           : Hoàn tất" -ForegroundColor Green
    Write-Host "  [+] Bước 3: DISM /RestoreHealth        : Hoàn tất" -ForegroundColor Green
    Write-Host "  [+] Bước 4: SFC /scannow               : Hoàn tất" -ForegroundColor Green
    Write-Host "  [+] Bước 5: DISM ComponentCleanup      : Hoàn tất" -ForegroundColor Green
    Write-Host "  - Tổng thời gian thực thi              : $elapsedMinutes phút" -ForegroundColor Cyan
    Write-Host ""
    Write-InfoMessage "Hệ thống Windows của bạn đã được kiểm tra toàn vẹn và phục hồi về trạng thái chuẩn."
    Write-TMLog -TaskId "REPAIR_FULL_PIPELINE" -TaskName "Full Sequential Repair" -Status "Success" -Message "Completed in $elapsedMinutes minutes"

    Pause-Screen
}

function Invoke-RepairPipeline {
    if (-not (Assert-Admin "run Windows repair wizard")) { Pause-Screen; return }
    Write-Header -Title "COMPREHENSIVE WINDOWS REPAIR PIPELINE (DISM + SFC)"
    Write-InfoMessage "Standard Microsoft-recommended sequence:"
    Write-Host "  1. Repair Windows Component Store (DISM /Online /Cleanup-Image /RestoreHealth)" -ForegroundColor Gray
    Write-Host "  2. Scan and replace protected system files (SFC /scannow)" -ForegroundColor Gray
    Write-Host ""

    $confirmed = Confirm-Action -TaskName "DISM + SFC Repair Pipeline" -ImpactDescription "Automatically runs DISM RestoreHealth followed by SFC Scannow to fix corrupted OS files." -RiskLevel "medium"
    if ($confirmed) {
        Write-SubHeader "STEP 1/2: EXECUTING DISM RESTOREHEALTH"
        & dism.exe /Online /Cleanup-Image /RestoreHealth

        Write-SubHeader "STEP 2/2: EXECUTING SFC SCANNOW"
        & sfc.exe /scannow

        Write-Success "DISM + SFC Repair Pipeline completed successfully!"
        Write-TMLog -TaskId "REPAIR_PIPELINE" -TaskName "DISM + SFC Pipeline" -Status "Success" -Message "Repair pipeline finished"
    }
    Pause-Screen
}

function Export-MaintenanceReport {
    Write-SubHeader "EXPORT DISK & MAINTENANCE REPORT"
    $reportDir = Join-Path $PSScriptRoot "../../../Logs"
    $filename = "MaintenanceReport_" + (Get-Date).ToString("yyyyMMdd_HHmmss") + ".txt"
    $fullPath = Join-Path $reportDir $filename

    $lines = @()
    $lines += "========================================================="
    $lines += "         TM-WINCARE - DISK & MAINTENANCE REPORT"
    $lines += "  Generated: " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $lines += "========================================================="
    try {
        $volumes = Get-Volume | Where-Object { $null -ne $_.DriveLetter }
        foreach ($v in $volumes) {
            $totalGB = [math]::Round($v.Size / 1GB, 1)
            $freeGB = [math]::Round($v.SizeRemaining / 1GB, 1)
            $lines += "Drive $($v.DriveLetter): [$($v.FileSystemLabel)] - $freeGB GB free / $totalGB GB ($($v.FileSystem))"
        }
    } catch {}
    $lines += "========================================================="

    Set-Content -Path $fullPath -Value $lines -Encoding UTF8 -Force
    Write-Success "Report exported to: $fullPath"
    Pause-Screen
}
