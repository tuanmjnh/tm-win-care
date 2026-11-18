# TM-WinCare - Backup & Restore Management Module
# Adheres to Section 8 of TM-WinCare-Architecture-v1.2.md

function Show-TMBackupMenu {
    while ($true) {
        Write-Header -Title "QUẢN LÝ SAO LƯU & HOÀN TÁC (BACKUP & RESTORE)"
        $backups = Get-TMBackupList

        if (-not $backups -or $backups.Count -eq 0) {
            Write-InfoMessage "Chưa có bản sao lưu nào được ghi nhận trong thư mục Backups."
        } else {
            Write-Host " Danh sách các bản sao lưu đã tạo:" -ForegroundColor Yellow
            for ($i = 0; $i -lt $backups.Count; $i++) {
                $b = $backups[$i]
                $num = ($i + 1).ToString().PadLeft(2)
                Write-Host "  [$num] " -ForegroundColor Cyan -NoNewline
                Write-Host "$($b.Id) " -ForegroundColor White -NoNewline
                Write-Host "- $($b.Description)" -ForegroundColor Gray
            }
        }

        Write-Host ""
        Write-Host "  [R] Hoàn tác bản sao lưu đã chọn" -ForegroundColor Cyan
        Write-Host "  [0] Quay lại" -ForegroundColor Yellow
        Write-Divider

        Write-Host " Lựa chọn của bạn (Nhập số bản sao lưu để xem chi tiết / R để hoàn tác / 0 để quay lại): " -ForegroundColor Cyan -NoNewline
        $ans = Read-Host

        if ($ans -eq "0") { break }

        if ($ans -match "^\d+$") {
            $idx = [int]$ans - 1
            if ($idx -ge 0 -and $idx -lt $backups.Count) {
                Show-BackupDetails -BackupItem $backups[$idx]
            }
        }
    }
}

function Show-BackupDetails {
    param ($BackupItem)

    Write-SubHeader "CHI TIẾT BẢN SAO LƯU: $($BackupItem.Id)"
    Write-Host " Tác vụ gốc: $($BackupItem.TaskId)" -ForegroundColor White
    Write-Host " Mô tả     : $($BackupItem.Description)" -ForegroundColor White
    Write-Host " Thời gian : $($BackupItem.CreatedAt)" -ForegroundColor White
    Write-Host " Thư mục   : $($BackupItem.Path)" -ForegroundColor Gray

    $manifestPath = Join-Path $BackupItem.Path "manifest.json"
    if (Test-Path $manifestPath) {
        $manifest = Get-Content -Path $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($manifest.registry) {
            Write-Host ""
            Write-Host "  Mục Registry được sao lưu:" -ForegroundColor Yellow
            foreach ($r in $manifest.registry) {
                Write-Host "   - $($r.path)\$($r.name) (Giá trị cũ: $($r.oldValue))" -ForegroundColor Gray
            }
        }
        if ($manifest.services) {
            Write-Host ""
            Write-Host "  Dịch vụ được sao lưu:" -ForegroundColor Yellow
            foreach ($s in $manifest.services) {
                Write-Host "   - $($s.name) (Khởi động: $($s.startMode))" -ForegroundColor Gray
            }
        }
    }

    Write-Host ""
    Write-Host " Bạn có muốn hoàn tác (Rollback) bản sao lưu này ngay bây giờ không? (Y/N): " -ForegroundColor Cyan -NoNewline
    $rb = Read-Host
    if ($rb.Trim().ToUpper() -eq "Y") {
        Invoke-TMRollback -BackupId $BackupItem.Id
    }
    Pause-Screen
}
