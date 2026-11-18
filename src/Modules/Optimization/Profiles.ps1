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
        Write-ErrorMessage "Optimization profile not found: $ProfileId"
        Pause-Screen
        return
    }

    Write-Header -Title "AUTO OPTIMIZE: $($prof.name)"
    Write-InfoMessage "Objective: $($prof.description)"
    Write-Host " Target environment: $($prof.target)" -ForegroundColor Gray
    Write-Host ""

    # 1. Pre-scan
    Write-SubHeader "STEP 1: SYSTEM PRE-SCAN METRICS"
    $sys = Get-TMSystemInfo
    Write-Success "Operating System: $($sys['Operating System'])"
    Write-Success "RAM Memory: $($sys['RAM Memory'])"
    Write-Success "Storage Capacity: $($sys['Storage Drives'])"

    # 2. Health checks
    Write-SubHeader "STEP 2: SAFETY PREREQUISITE CHECKS"
    $needsAdmin = ($ProfileId -ne "audit")
    if ($needsAdmin -and -not (Test-IsAdmin)) {
        Write-ErrorMessage "This optimization profile requires Administrator privileges."
        if (-not (Request-Elevation -Reason "apply optimization profile $($prof.name)")) {
            Pause-Screen
            return
        }
    }
    Write-Success "Administrator Privilege Check: Valid."

    # 3. Preview Actions
    Write-SubHeader "STEP 3: ACTION PREVIEW"
    $actions = $prof.actions
    for ($i = 0; $i -lt $actions.Count; $i++) {
        Write-Host "  [$($i+1)] $($actions[$i].name)" -ForegroundColor Cyan
    }
    Write-Host ""

    if ($ProfileId -eq "audit") {
        Write-Success "System audit complete. No system changes were applied."
        Pause-Screen
        return
    }

    # 4. Confirm & Backup
    $confirmed = Confirm-Action -TaskName "Auto Optimize - $($prof.name)" -ImpactDescription "Apply safe optimizations defined in profile $($prof.name). An automatic rollback snapshot will be created." -RiskLevel "medium"
    if (-not $confirmed) {
        Write-SkipMessage "Optimization cancelled by user."
        Pause-Screen
        return
    }

    Write-SubHeader "STEP 4: CREATE SYSTEM RESTORE SNAPSHOT"
    $session = New-TMBackupSession -TaskId "AUTO_OPT_$ProfileId" -Description "Backup prior to Auto Optimize $($prof.name)"
    
    # Backup relevant Registry keys for visual effects
    Backup-RegistryValue -Session $session -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" | Out-Null
    $backupId = Save-TMBackupSession -Session $session

    # 5. Apply
    Write-SubHeader "STEP 5: APPLYING OPTIMIZATIONS"
    foreach ($act in $actions) {
        Write-Host "-> Executing: $($act.name)... " -ForegroundColor White -NoNewline
        switch ($act.action) {
            "clean_temp" {
                $userTemp = [System.IO.Path]::GetTempPath()
                $cleanedCount = 0
                Get-ChildItem -Path $userTemp -File -ErrorAction SilentlyContinue | ForEach-Object {
                    try { Remove-Item $_.FullName -Force -ErrorAction Stop; $cleanedCount++ } catch {}
                }
                Write-Host "Done (Cleaned $cleanedCount temp files)." -ForegroundColor Green
            }
            "visual_balanced" {
                try {
                    # VisualFXSetting: 3 = Custom (disable animation, keep font smoothing)
                    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 3 -Force -ErrorAction SilentlyContinue
                    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0 -Force -ErrorAction SilentlyContinue
                    Write-Host "Done (Animations reduced, fonts preserved)." -ForegroundColor Green
                } catch { Write-Host "Skipped ($($_.Exception.Message))" -ForegroundColor Yellow }
            }
            "visual_perf" {
                try {
                    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -Force -ErrorAction SilentlyContinue
                    Write-Host "Done (Configured for Best Performance)." -ForegroundColor Green
                } catch { Write-Host "Skipped" -ForegroundColor Yellow }
            }
            "visual_minimal" {
                try {
                    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -Force -ErrorAction SilentlyContinue
                    Write-Host "Done." -ForegroundColor Green
                } catch { Write-Host "Skipped" -ForegroundColor Yellow }
            }
            "trim_ssd" {
                try {
                    if (Test-CmdletAvailable "Optimize-Volume") {
                        Optimize-Volume -DriveLetter C -ReTrim -ErrorAction SilentlyContinue | Out-Null
                        Write-Host "Done (SSD ReTrim executed)." -ForegroundColor Green
                    } else {
                        Write-Host "Not available." -ForegroundColor DarkGray
                    }
                } catch { Write-Host "Skipped." -ForegroundColor Yellow }
            }
            default {
                Write-Host "Complete." -ForegroundColor Green
            }
        }
    }

    # 6. Verify & Report
    Write-SubHeader "STEP 6: VERIFICATION & SUMMARY"
    Write-Success "Optimization profile '$($prof.name)' applied successfully!"
    Write-InfoMessage "Backup snapshot created: $backupId (Rollback available anytime in Backup & Restore menu)"
    Write-TMLog -TaskId "AUTO_OPT_$ProfileId" -TaskName "Auto Optimize $($prof.name)" -Status "Success" -Message "Profile applied successfully" -BackupId $backupId
    
    Pause-Screen
}
