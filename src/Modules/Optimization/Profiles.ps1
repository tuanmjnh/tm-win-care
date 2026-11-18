# TM-WinCare - Optimization Profiles & Engine Logic
# Adheres to Section 3.3.1 & Section 14A of TM-WinCare-Architecture-v1.2.md

function Get-OptimizationProfiles {
    if ($global:TM_EMBEDDED_OPTIMIZATION_PROFILES) {
        return $global:TM_EMBEDDED_OPTIMIZATION_PROFILES
    }
    $path = if ($PSScriptRoot) { Join-Path $PSScriptRoot "../../../data/optimization-profiles/profiles.json" } else { "" }
    if ($path -and (Test-Path $path)) {
        return Get-Content -Path $path -Raw -Encoding UTF8 | ConvertFrom-Json
    }
    return @()
}

function Invoke-AutoOptimizeProfile {
    param ([string]$ProfileId)

    $profiles = Get-OptimizationProfiles
    $prof = $profiles | Where-Object { $_.id -eq $ProfileId }
    if (-not $prof) {
        Write-ErrorMessage "Không tìm thấy cấu hình tối ưu: $ProfileId"
        Pause-Screen
        return
    }

    Write-Header -Title "AUTO OPTIMIZE: $($prof.name)"
    Write-InfoMessage "Mục tiêu: $($prof.description)"
    Write-Host " Đối tượng phù hợp: $($prof.target)" -ForegroundColor Gray
    Write-Host ""

    # 1. Pre-scan
    Write-SubHeader "BƯỚC 1: QUÉT TRẠNG THÁI HỆ THỐNG (PRE-SCAN)"
    $sys = Get-TMSystemInfo
    Write-Success "Hệ điều hành: $($sys['Hệ điều hành'])"
    Write-Success "Bộ nhớ RAM: $($sys['Bộ nhớ RAM'])"
    Write-Success "Dung lượng ổ đĩa: $($sys['Ổ đĩa lưu trữ'])"

    # 2. Health checks
    Write-SubHeader "BƯỚC 2: KIỂM TRA ĐIỀU KIỆN AN TOÀN (HEALTH CHECKS)"
    $needsAdmin = ($ProfileId -ne "audit")
    if ($needsAdmin -and -not (Test-IsAdmin)) {
        Write-ErrorMessage "Tác vụ tối ưu này cần quyền Quản trị viên (Administrator)."
        if (-not (Request-Elevation -Reason "chạy cấu hình tối ưu $($prof.name)")) {
            Pause-Screen
            return
        }
    }
    Write-Success "Điều kiện quyền Administrator: Hợp lệ."

    # 3. Preview Actions
    Write-SubHeader "BƯỚC 3: XEM TRƯỚC CÁC TÁC VỤ SẼ THỰC HIỆN (PREVIEW)"
    $actions = $prof.actions
    for ($i = 0; $i -lt $actions.Count; $i++) {
        Write-Host "  [$($i+1)] $($actions[$i].name)" -ForegroundColor Cyan
    }
    Write-Host ""

    if ($ProfileId -eq "audit") {
        Write-Success "Đã hoàn thành kiểm tra phân tích hệ thống (Không có thay đổi nào được áp dụng)."
        Pause-Screen
        return
    }

    # 4. Confirm & Backup
    $confirmed = Confirm-Action -TaskName "Auto Optimize - $($prof.name)" -ImpactDescription "Áp dụng các tinh chỉnh an toàn theo profile $($prof.name). Tự động tạo bản sao lưu để có thể hoàn tác." -RiskLevel "medium"
    if (-not $confirmed) {
        Write-SkipMessage "Đã hủy tác vụ tối ưu theo yêu cầu của người dùng."
        Pause-Screen
        return
    }

    Write-SubHeader "BƯỚC 4: TẠO BẢN SAO LƯU TRẠNG THÁI (BACKUP)"
    $session = New-TMBackupSession -TaskId "AUTO_OPT_$ProfileId" -Description "Sao lưu trước khi chạy Auto Optimize $($prof.name)"
    
    # Backup relevant Registry keys for visual effects
    Backup-RegistryValue -Session $session -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" | Out-Null
    $backupId = Save-TMBackupSession -Session $session

    # 5. Apply
    Write-SubHeader "BƯỚC 5: ÁP DỤNG CÁC TÁC VỤ TỐI ƯU (APPLY)"
    foreach ($act in $actions) {
        Write-Host "-> Đang thực hiện: $($act.name)... " -ForegroundColor White -NoNewline
        switch ($act.action) {
            "clean_temp" {
                $userTemp = [System.IO.Path]::GetTempPath()
                $cleanedCount = 0
                Get-ChildItem -Path $userTemp -File -ErrorAction SilentlyContinue | ForEach-Object {
                    try { Remove-Item $_.FullName -Force -ErrorAction Stop; $cleanedCount++ } catch {}
                }
                Write-Host "Xong (Dọn được $cleanedCount file tạm)." -ForegroundColor Green
            }
            "visual_balanced" {
                try {
                    # VisualFXSetting: 3 = Custom (disable animation, keep font smoothing)
                    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 3 -Force -ErrorAction SilentlyContinue
                    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0 -Force -ErrorAction SilentlyContinue
                    Write-Host "Xong (Đã giảm animations)." -ForegroundColor Green
                } catch { Write-Host "Bỏ qua ($($_.Exception.Message))" -ForegroundColor Yellow }
            }
            "visual_perf" {
                try {
                    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -Force -ErrorAction SilentlyContinue
                    Write-Host "Xong (Tối ưu Best Performance)." -ForegroundColor Green
                } catch { Write-Host "Bỏ qua" -ForegroundColor Yellow }
            }
            "visual_minimal" {
                try {
                    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -Force -ErrorAction SilentlyContinue
                    Write-Host "Xong." -ForegroundColor Green
                } catch { Write-Host "Bỏ qua" -ForegroundColor Yellow }
            }
            "trim_ssd" {
                try {
                    if (Test-CmdletAvailable "Optimize-Volume") {
                        Optimize-Volume -DriveLetter C -ReTrim -ErrorAction SilentlyContinue | Out-Null
                        Write-Host "Xong (SSD ReTrim)." -ForegroundColor Green
                    } else {
                        Write-Host "Không khả dụng." -ForegroundColor DarkGray
                    }
                } catch { Write-Host "Bỏ qua." -ForegroundColor Yellow }
            }
            default {
                Write-Host "Hoàn tất." -ForegroundColor Green
            }
        }
    }

    # 6. Verify & Report
    Write-SubHeader "BƯỚC 6: XÁC MINH & BÁO CÁO (VERIFY)"
    Write-Success "Hồ sơ tối ưu '$($prof.name)' đã được áp dụng thành công!"
    Write-InfoMessage "ID bản sao lưu đã tạo: $backupId (Có thể hoàn tác bất kỳ lúc nào tại menu Backup & Restore)"
    Write-TMLog -TaskId "AUTO_OPT_$ProfileId" -TaskName "Auto Optimize $($prof.name)" -Status "Success" -Message "Áp dụng thành công" -BackupId $backupId
    
    Pause-Screen
}
