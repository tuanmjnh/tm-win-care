# TM-WinCare - State Backup & Rollback Engine
# Adheres to Section 8 of TM-WinCare-Architecture-v1.2.md

$script:BackupDirectory = if ($PSScriptRoot) { Join-Path $PSScriptRoot "../../Backups" } else { Join-Path $env:SystemDrive "TM-WinCare\Backups" }
if (-not (Test-Path $script:BackupDirectory)) {
    New-Item -ItemType Directory -Path $script:BackupDirectory -Force | Out-Null
}

function New-TMBackupSession {
    param (
        [string]$TaskId,
        [string]$Description
    )
    $backupId = (Get-Date).ToString("yyyy-MM-dd_HHmmss")
    $sessionDir = Join-Path $script:BackupDirectory $backupId
    New-Item -ItemType Directory -Path $sessionDir -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $sessionDir "registry") -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $sessionDir "services") -Force | Out-Null

    $manifest = [ordered]@{
        backupId = $backupId
        taskId = $TaskId
        description = $Description
        createdAt = (Get-Date).ToString("o")
        machine = [System.Environment]::MachineName
        user = "$([System.Environment]::UserDomainName)\$([System.Environment]::UserName)"
        registry = @()
        services = @()
    }

    return [PSCustomObject]@{
        Id = $backupId
        Directory = $sessionDir
        Manifest = $manifest
    }
}

function Backup-RegistryValue {
    param (
        [PSCustomObject]$Session,
        [string]$Path,
        [string]$Name
    )
    try {
        $regItem = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
        $exists = ($null -ne $regItem -and $null -ne $regItem.$Name)
        $oldVal = if ($exists) { $regItem.$Name } else { $null }
        
        # Detect Registry Value Kind
        $valKind = "Unknown"
        if ($exists) {
            try {
                $hiveKey = Get-Item -Path $Path -ErrorAction Stop
                $valKind = $hiveKey.GetValueKind($Name).ToString()
            } catch {}
        }

        # Backup key to .reg file
        $regFile = Join-Path $Session.Directory "registry/$($Name)_backup.reg"
        $cmdPath = $Path -replace '^Registry::', '' -replace '^HKLM:', 'HKLM' -replace '^HKCU:', 'HKCU'
        & reg.exe export "$cmdPath" "$regFile" /y *>$null

        $Session.Manifest.registry += [ordered]@{
            path = $Path
            name = $Name
            existed = $exists
            oldValue = $oldVal
            valueKind = $valKind
            regFile = $regFile
        }
        return $true
    } catch {
        Write-ErrorMessage "Không thể sao lưu Registry: $($_.Exception.Message)"
        return $false
    }
}

function Backup-ServiceState {
    param (
        [PSCustomObject]$Session,
        [string]$ServiceName
    )
    try {
        $svc = Get-Service -Name $ServiceName -ErrorAction Stop
        $startMode = (Get-CimInstance Win32_Service -Filter "Name='$ServiceName'").StartMode
        $Session.Manifest.services += [ordered]@{
            name = $ServiceName
            status = $svc.Status.ToString()
            startMode = $startMode
        }
        return $true
    } catch {
        Write-ErrorMessage "Không thể sao lưu trạng thái Service $ServiceName : $($_.Exception.Message)"
        return $false
    }
}

function Save-TMBackupSession {
    param (
        [PSCustomObject]$Session
    )
    try {
        $manifestPath = Join-Path $Session.Directory "manifest.json"
        $json = $Session.Manifest | ConvertTo-Json -Depth 5
        Set-Content -Path $manifestPath -Value $json -Encoding UTF8 -Force
        Write-Success "Đã tạo bản sao lưu an toàn: $($Session.Id)"
        return $Session.Id
    } catch {
        Write-ErrorMessage "Lỗi khi lưu manifest backup: $($_.Exception.Message)"
        return $null
    }
}
