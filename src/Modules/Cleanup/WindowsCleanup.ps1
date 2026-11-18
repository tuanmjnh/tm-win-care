# TM-WinCare - System Cleanup Module
# Adheres to Section 7A of TM-WinCare-Architecture-v1.2.md

function Show-TMSystemCleanupMenu {
    $menuItems = @(
        @{ Label = "Scan & Analyze Junk Storage Footprint"; Action = { Scan-SystemCleanupTargets } },
        @{ Label = "Clean Current User Temporary Files (%TEMP%)"; Action = { Clean-UserTempFolder } },
        @{ Label = "Clean Windows System Temp Files (%WINDIR%\\Temp)"; Action = { Clean-WindowsTempFolder } },
        @{ Label = "Empty Recycle Bin Across All Drives"; Action = { Clean-RecycleBinCustom } },
        @{ Label = "Purge Windows Update Download Cache (SoftwareDistribution)"; Action = { Clean-WindowsUpdateCache } },
        @{ Label = "Purge Obsolete Crash Dumps & Minidumps"; Action = { Clean-CrashDumps } },
        @{ Label = "Windows.old Storage Inspection & Guidance"; Action = { Show-WindowsOldWizard } },
        @{ Label = "Open Windows Storage Sense Settings"; Action = { Start-Process "ms-settings:storagesense" } }
    )
    Show-TMMenu -Title "WINDOWS SYSTEM CLEANUP" -MenuItems $menuItems -ExitLabel "Back"
}

function Scan-SystemCleanupTargets {
    Write-SubHeader "SCAN & ANALYZE JUNK FILE VOLUMES"
    Write-InfoMessage "Measuring temporary directories and storage footprint..."

    $targets = @(
        @{ Name = "User Temp (%TEMP%)"; Path = [System.IO.Path]::GetTempPath() },
        @{ Name = "Windows Temp"; Path = (Join-Path $env:SystemRoot "Temp") },
        @{ Name = "Windows Update Cache"; Path = (Join-Path $env:SystemRoot "SoftwareDistribution\Download") },
        @{ Name = "Crash Minidumps"; Path = (Join-Path $env:SystemRoot "Minidump") }
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
            Target = $t.Name
            FileCount = "$count files"
            EstimatedSize = "$sizeMB MB"
            DirectoryPath = $t.Path
        }
    }

    $headers = @("Cleanup Target", "Files", "Estimated Size", "Directory Path")
    $props = @("Target", "FileCount", "EstimatedSize", "DirectoryPath")
    $widths = @(25, 14, 18, 32)
    Show-TableList -Items $results -Headers $headers -PropertyNames $props -Widths $widths

    # Check Windows.old
    $winOld = "C:\Windows.old"
    if (Test-Path $winOld) {
        Write-WarningMessage "Detected 'C:\Windows.old' folder. Use the 'Windows.old Guidance' wizard for safe removal."
    }
    Pause-Screen
}

function Clean-UserTempFolder {
    $tempPath = [System.IO.Path]::GetTempPath()
    Write-SubHeader "CLEAN USER TEMP FOLDER: $tempPath"
    
    $confirmed = Confirm-Action -TaskName "Clean User Temp" -ImpactDescription "Deletes temporary application files in %TEMP%. Locked or currently active files are automatically skipped." -RiskLevel "low"
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
    Write-Success "Cleaned $deleted temporary files ($skipped active file(s) safely skipped)."
    Write-TMLog -TaskId "CLEAN_USER_TEMP" -TaskName "Clean User Temp" -Status "Success" -Message "Deleted $deleted files"
    Pause-Screen
}

function Clean-WindowsTempFolder {
    if (-not (Assert-Admin "clean Windows Temp folder")) { Pause-Screen; return }

    $winTemp = Join-Path $env:SystemRoot "Temp"
    Write-SubHeader "CLEAN WINDOWS SYSTEM TEMP FOLDER: $winTemp"

    $confirmed = Confirm-Action -TaskName "Clean Windows Temp" -ImpactDescription "Deletes system and service temporary files. Active in-use files are skipped automatically." -RiskLevel "low"
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
    Write-Success "Cleaned $deleted file(s) in Windows Temp ($skipped in-use file(s) skipped)."
    Write-TMLog -TaskId "CLEAN_WIN_TEMP" -TaskName "Clean Windows Temp" -Status "Success" -Message "Deleted $deleted files"
    Pause-Screen
}

function Clean-RecycleBinCustom {
    Write-SubHeader "EMPTY RECYCLE BIN ACROSS ALL VOLUMES"
    $confirmed = Confirm-Action -TaskName "Empty Recycle Bin" -ImpactDescription "Permanently deletes all contents from Recycle Bin across all disk volumes. Cannot be undone." -RiskLevel "medium"
    if (-not $confirmed) { Pause-Screen; return }

    try {
        Clear-RecycleBin -Force -ErrorAction Stop
        Write-Success "Recycle Bin emptied successfully!"
        Write-TMLog -TaskId "CLEAN_RECYCLE_BIN" -TaskName "Empty Recycle Bin" -Status "Success" -Message "Success"
    } catch {
        Handle-TMException -TaskId "CLEAN_RECYCLE_BIN" -TaskName "Empty Recycle Bin" -Exception $_.Exception
    }
    Pause-Screen
}

function Clean-WindowsUpdateCache {
    if (-not (Assert-Admin "clean Windows Update cache")) { Pause-Screen; return }

    Write-SubHeader "PURGE WINDOWS UPDATE DOWNLOAD CACHE"
    $wuPath = Join-Path $env:SystemRoot "SoftwareDistribution\Download"

    $confirmed = Confirm-Action -TaskName "Purge Windows Update Cache" -ImpactDescription "Pauses wuauserv service, purges downloaded update files in SoftwareDistribution\Download, and restarts service." -RiskLevel "medium"
    if (-not $confirmed) { Pause-Screen; return }

    try {
        Write-InfoMessage "Pausing Windows Update service..."
        Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
        
        $files = Get-ChildItem -Path $wuPath -Recurse -File -ErrorAction SilentlyContinue
        $deleted = 0
        foreach ($f in $files) {
            try { Remove-Item $f.FullName -Force -ErrorAction Stop; $deleted++ } catch {}
        }
        Write-Success "Purged $deleted downloaded update cache files."

        Write-InfoMessage "Restarting Windows Update service..."
        Start-Service -Name wuauserv -ErrorAction SilentlyContinue
        Write-Success "Windows Update cache cleanup completed!"
        Write-TMLog -TaskId "CLEAN_WU_CACHE" -TaskName "Clean WU Cache" -Status "Success" -Message "Deleted $deleted files"
    } catch {
        Handle-TMException -TaskId "CLEAN_WU_CACHE" -TaskName "Clean WU Cache" -Exception $_.Exception
    }
    Pause-Screen
}

function Clean-CrashDumps {
    if (-not (Assert-Admin "clean crash dumps")) { Pause-Screen; return }

    Write-SubHeader "PURGE PAST CRASH DUMPS & MINIDUMPS"
    $dumpPath = Join-Path $env:SystemRoot "Minidump"
    if (-not (Test-Path $dumpPath)) {
        Write-InfoMessage "No Minidump directory present on this system."
        Pause-Screen
        return
    }

    $confirmed = Confirm-Action -TaskName "Purge Minidumps" -ImpactDescription "Deletes obsolete BSOD crash dump files in $dumpPath." -RiskLevel "low"
    if ($confirmed) {
        $files = Get-ChildItem -Path $dumpPath -File -ErrorAction SilentlyContinue
        $deleted = 0
        foreach ($f in $files) {
            try { Remove-Item $f.FullName -Force -ErrorAction Stop; $deleted++ } catch {}
        }
        Write-Success "Purged $deleted minidump file(s)."
    }
    Pause-Screen
}

function Show-WindowsOldWizard {
    Write-SubHeader "SAFE WINDOWS.OLD STORAGE GUIDANCE"
    $winOld = "C:\Windows.old"
    if (-not (Test-Path $winOld)) {
        Write-Success "'C:\Windows.old' does NOT exist on this PC. No action required."
        Pause-Screen
        return
    }

    Write-WarningMessage "DETECTED 'C:\Windows.old' ON SYSTEM DRIVE!"
    Write-Host " IMPORTANT SAFETY NOTICE:" -ForegroundColor Yellow
    Write-Host "  - Windows.old contains your previous Windows installation." -ForegroundColor Gray
    Write-Host "  - Removing Windows.old permanently deletes the ability to roll back to the prior OS build." -ForegroundColor Gray
    Write-Host "  - Microsoft recommends using Storage Sense or Disk Cleanup rather than manual deletion." -ForegroundColor Gray
    Write-Host ""
    Write-Host " Open Windows Storage Sense to safely purge 'Previous Windows installation(s)'? (Y/N): " -ForegroundColor Cyan -NoNewline
    $ans = Read-Host
    if ($ans.Trim().ToUpper() -eq "Y") {
        Start-Process "ms-settings:storagesense"
    }
    Pause-Screen
}
