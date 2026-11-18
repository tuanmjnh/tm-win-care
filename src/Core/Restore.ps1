# TM-WinCare - Restore & Rollback Engine
# Adheres to Section 8 of TM-WinCare-Architecture-v1.2.md

function Get-TMBackupList {
    $backupDir = if ($PSScriptRoot) { Join-Path $PSScriptRoot "../../Backups" } else { Join-Path $env:SystemDrive "TM-WinCare\Backups" }
    if (-not (Test-Path $backupDir)) { return @() }
    
    $list = @()
    $folders = Get-ChildItem -Path $backupDir -Directory | Sort-Object Name -Descending
    foreach ($f in $folders) {
        $manifestPath = Join-Path $f.FullName "manifest.json"
        if (Test-Path $manifestPath) {
            try {
                $manifest = Get-Content -Path $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
                $list += [PSCustomObject]@{
                    Id = $f.Name
                    Description = $manifest.description
                    TaskId = $manifest.taskId
                    CreatedAt = $manifest.createdAt
                    Path = $f.FullName
                }
            } catch {}
        }
    }
    return $list
}

function Invoke-TMRollback {
    param (
        [string]$BackupId
    )
    if (-not (Assert-Admin "khôi phục sao lưu")) { return $false }

    $backupRoot = if ($PSScriptRoot) { Join-Path $PSScriptRoot "../../Backups" } else { Join-Path $env:SystemDrive "TM-WinCare\Backups" }
    $backupDir = Join-Path $backupRoot $BackupId
    $manifestPath = Join-Path $backupDir "manifest.json"
    if (-not (Test-Path $manifestPath)) {
        Write-ErrorMessage "Không tìm thấy file manifest của bản sao lưu: $BackupId"
        return $false
    }

    try {
        $manifest = Get-Content -Path $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
        Write-SubHeader "KHÔI PHỤC BẢN SAO LƯU: $BackupId ($($manifest.description))"

        # 1. Rollback Registry
        if ($manifest.registry) {
            foreach ($item in $manifest.registry) {
                Write-InfoMessage "Khôi phục Registry: $($item.path) -> $($item.name)"
                if ($item.existed) {
                    if (-not (Test-Path $item.path)) {
                        New-Item -Path $item.path -Force | Out-Null
                    }
                    Set-ItemProperty -Path $item.path -Name $item.name -Value $item.oldValue -Force
                    Write-Success "Đã khôi phục giá trị: $($item.name) = $($item.oldValue)"
                } else {
                    # If it did not exist before, remove it
                    Remove-ItemProperty -Path $item.path -Name $item.name -ErrorAction SilentlyContinue
                    Write-Success "Đã xóa thuộc tính được thêm mới: $($item.name)"
                }
            }
        }

        # 2. Rollback Services
        if ($manifest.services) {
            foreach ($svc in $manifest.services) {
                Write-InfoMessage "Khôi phục Service: $($svc.name) -> $($svc.startMode)"
                try {
                    $startType = switch ($svc.startMode) {
                        "Auto" { "Automatic" }
                        "Manual" { "Manual" }
                        "Disabled" { "Disabled" }
                        default { "Manual" }
                    }
                    Set-Service -Name $svc.name -StartupType $startType -ErrorAction SilentlyContinue
                    if ($svc.status -eq "Running") {
                        Start-Service -Name $svc.name -ErrorAction SilentlyContinue
                    }
                    Write-Success "Đã khôi phục dịch vụ: $($svc.name)"
                } catch {
                    Write-ErrorMessage "Không thể khôi phục dịch vụ $($svc.name): $($_.Exception.Message)"
                }
            }
        }

        Write-TMLog -TaskId "ROLLBACK" -TaskName "Khôi phục sao lưu" -Status "Success" -Message "Đã khôi phục bản sao lưu $BackupId"
        Write-Success "Quá trình hoàn tác bản sao lưu $BackupId đã hoàn thành thành công!"
        return $true
    } catch {
        Write-ErrorMessage "Lỗi trong quá trình khôi phục: $($_.Exception.Message)"
        Write-TMLog -TaskId "ROLLBACK" -TaskName "Khôi phục sao lưu" -Status "Failed" -Message "Lỗi: $($_.Exception.Message)"
        return $false
    }
}
