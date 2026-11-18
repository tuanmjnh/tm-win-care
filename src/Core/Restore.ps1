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
    if (-not (Assert-Admin "restore backup")) { return $false }

    $backupRoot = if ($PSScriptRoot) { Join-Path $PSScriptRoot "../../Backups" } else { Join-Path $env:SystemDrive "TM-WinCare\Backups" }
    $backupDir = Join-Path $backupRoot $BackupId
    $manifestPath = Join-Path $backupDir "manifest.json"
    if (-not (Test-Path $manifestPath)) {
        Write-ErrorMessage "Backup manifest file not found for: $BackupId"
        return $false
    }

    try {
        $manifest = Get-Content -Path $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
        Write-SubHeader "RESTORE BACKUP SNAPSHOT: $BackupId ($($manifest.description))"

        # 1. Rollback Registry
        if ($manifest.registry) {
            foreach ($item in $manifest.registry) {
                Write-InfoMessage "Restoring Registry: $($item.path) -> $($item.name)"
                if ($item.existed) {
                    if (-not (Test-Path $item.path)) {
                        New-Item -Path $item.path -Force | Out-Null
                    }
                    Set-ItemProperty -Path $item.path -Name $item.name -Value $item.oldValue -Force
                    Write-Success "Restored value: $($item.name) = $($item.oldValue)"
                } else {
                    Remove-ItemProperty -Path $item.path -Name $item.name -ErrorAction SilentlyContinue
                    Write-Success "Removed newly added property: $($item.name)"
                }
            }
        }

        # 2. Rollback Services
        if ($manifest.services) {
            foreach ($svc in $manifest.services) {
                Write-InfoMessage "Restoring Service: $($svc.name) -> $($svc.startMode)"
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
                    Write-Success "Restored service: $($svc.name)"
                } catch {
                    Write-ErrorMessage "Unable to restore service $($svc.name): $($_.Exception.Message)"
                }
            }
        }

        Write-TMLog -TaskId "ROLLBACK" -TaskName "Rollback Backup" -Status "Success" -Message "Restored backup $BackupId"
        Write-Success "Rollback of snapshot $BackupId completed successfully!"
        return $true
    } catch {
        Write-ErrorMessage "Error during rollback: $($_.Exception.Message)"
        Write-TMLog -TaskId "ROLLBACK" -TaskName "Rollback Backup" -Status "Failed" -Message $_.Exception.Message
        return $false
    }
}
