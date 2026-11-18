# TM-WinCare - Backup & Restore Management Module
# Adheres to Section 8 of TM-WinCare-Architecture-v1.2.md

function Show-TMBackupMenu {
    while ($true) {
        Write-Header -Title "BACKUP SNAPSHOTS & STATE ROLLBACK"
        $backups = Get-TMBackupList

        if (-not $backups -or $backups.Count -eq 0) {
            Write-InfoMessage "No backup snapshots found in Backups directory."
        } else {
            Write-Host " Available State Snapshots:" -ForegroundColor Yellow
            for ($i = 0; $i -lt $backups.Count; $i++) {
                $b = $backups[$i]
                $num = ($i + 1).ToString().PadLeft(2)
                Write-Host "  [$num] " -ForegroundColor Cyan -NoNewline
                Write-Host "$($b.Id) " -ForegroundColor White -NoNewline
                Write-Host "- $($b.Description)" -ForegroundColor Gray
            }
        }

        Write-Host ""
        Write-Host "  [0] Back" -ForegroundColor Yellow
        Write-Divider

        Write-Host " Select snapshot number to inspect / rollback (0 to return): " -ForegroundColor Cyan -NoNewline
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

    Write-SubHeader "SNAPSHOT DETAILS: $($BackupItem.Id)"
    Write-Host " Task ID    : $($BackupItem.TaskId)" -ForegroundColor White
    Write-Host " Description: $($BackupItem.Description)" -ForegroundColor White
    Write-Host " Created At : $($BackupItem.CreatedAt)" -ForegroundColor White
    Write-Host " Directory  : $($BackupItem.Path)" -ForegroundColor Gray

    $manifestPath = Join-Path $BackupItem.Path "manifest.json"
    if (Test-Path $manifestPath) {
        $manifest = Get-Content -Path $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($manifest.registry) {
            Write-Host ""
            Write-Host "  Backed Up Registry Keys:" -ForegroundColor Yellow
            foreach ($r in $manifest.registry) {
                Write-Host "   - $($r.path)\$($r.name) (Old Value: $($r.oldValue))" -ForegroundColor Gray
            }
        }
        if ($manifest.services) {
            Write-Host ""
            Write-Host "  Backed Up Service States:" -ForegroundColor Yellow
            foreach ($s in $manifest.services) {
                Write-Host "   - $($s.name) (Startup: $($s.startMode))" -ForegroundColor Gray
            }
        }
    }

    Write-Host ""
    Write-Host " Rollback this backup snapshot now? (Y/N): " -ForegroundColor Cyan -NoNewline
    $rb = Read-Host
    if ($rb.Trim().ToUpper() -eq "Y") {
        Invoke-TMRollback -BackupId $BackupItem.Id
    }
    Pause-Screen
}
