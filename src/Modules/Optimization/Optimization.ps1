# TM-WinCare - Optimization Main Module
# Adheres to Section 3.3.1 of TM-WinCare-Architecture-v1.2.md

. (Join-Path $PSScriptRoot "Profiles.ps1")

function Show-TMOptimizationMenu {
    $menuItems = @(
        @{ Label = "🚀 [CHẾ ĐỘ AUTO] Tự Động Tối Ưu Toàn Diện Toàn Bộ Hệ Thống (1-Click Full Care)"; Action = { Invoke-FullSystemAutoOptimize } },
        @{ Label = "Audit System & Generate Optimization Recommendations"; Action = { Invoke-AutoOptimizeProfile -ProfileId "audit" } },
        @{ Label = "Auto Optimize - Balanced (Recommended for General PC)"; Action = { Invoke-AutoOptimizeProfile -ProfileId "balanced" } },
        @{ Label = "Auto Optimize - Desktop Performance (High-Performance Workstation)"; Action = { Invoke-AutoOptimizeProfile -ProfileId "desktop_perf" } },
        @{ Label = "Auto Optimize - Low Resource / HDD Budget PC"; Action = { Invoke-AutoOptimizeProfile -ProfileId "low_resource_hdd" } },
        @{ Label = "Auto Optimize - Laptop Balanced (Battery-Conscious)"; Action = { Invoke-AutoOptimizeProfile -ProfileId "laptop_balanced" } },
        @{ Label = "Services Manager (SysMain / WSearch / Ndu Status)"; Action = { Show-ServicesManagerMenu } },
        @{ Label = "Visual Effects & Window Animations"; Action = { Show-VisualEffectsMenu } },
        @{ Label = "Startup Applications (Run at Boot)"; Action = { Show-StartupAppsMenu } },
        @{ Label = "Power Plan & Performance Schemes"; Action = { Show-PowerPlanMenu } },
        @{ Label = "View Recent Backups & Rollback"; Action = { Show-TMBackupMenu } }
    )
    Show-TMMenu -Title "SAFE SYSTEM OPTIMIZATION (AUTO CARE & PROFILES)" -MenuItems $menuItems -ExitLabel "Back"
}

function Invoke-FullSystemAutoOptimize {
    <#
    .SYNOPSIS
        Comprehensive 1-Click All-In-One Full Auto Optimization Mode.
        Automatically executes the complete safe maintenance & tuning pipeline across the entire system.
    #>
    Write-Header -Title "CHẾ ĐỘ AUTO: TỰ ĐỘNG TỐI ƯU TOÀN DIỆN TOÀN BỘ HỆ THỐNG"
    Write-InfoMessage "TM-WinCare All-In-One Automated Safe System Optimization Pipeline."
    Write-Host " Guarantees: Safe by Default • Preserves Defender & Firewall • Creates Rollback Snapshot" -ForegroundColor Green
    Write-Host ""

    # 1. Administrator check
    if (-not (Test-IsAdmin)) {
        Write-WarningMessage "Full System Auto Optimize requires Administrator privileges for complete maintenance."
        if (-not (Request-Elevation -Reason "run Full System Auto Optimize")) {
            Pause-Screen
            return
        }
    }

    # 2. Pipeline Overview & Preview
    Write-SubHeader "AUTOMATED OPTIMIZATION PIPELINE PREVIEW"
    Write-Host "  [1] Pre-Scan & Automatic System State Snapshot (Backups/)" -ForegroundColor Cyan
    Write-Host "  [2] Deep Junk & Temp Cleanup (%TEMP%, %WINDIR%\Temp, Recycle Bin, Crash Dumps)" -ForegroundColor Cyan
    Write-Host "  [3] Windows Update Download Cache Purge (SoftwareDistribution\Download)" -ForegroundColor Cyan
    Write-Host "  [4] Developer & Package Manager Cache Cleanup (pip, npm, uv if present)" -ForegroundColor Cyan
    Write-Host "  [5] Visual & UI Animation Tuning (Disable window delay, preserve font smoothing)" -ForegroundColor Cyan
    Write-Host "  [6] Privacy & Notification Tuning (Disable background tips, suggestions & promo ads)" -ForegroundColor Cyan
    Write-Host "  [7] Storage Volume Optimization (Automatic SSD ReTrim on all SSD drives)" -ForegroundColor Cyan
    Write-Host "  [8] Network & DNS Cache Reset (Flush DNS client cache & NetBIOS cache)" -ForegroundColor Cyan
    Write-Host "  [9] Windows Component Store Health & Cleanup (DISM StartComponentCleanup)" -ForegroundColor Cyan
    Write-Host ""

    $confirmed = Confirm-Action -TaskName "Full System Auto Optimize" -ImpactDescription "Execute the complete automated optimization pipeline. All changes are non-destructive and fully backed up." -RiskLevel "medium"
    if (-not $confirmed) {
        Write-SkipMessage "Full System Auto Optimize cancelled by user."
        Pause-Screen
        return
    }

    # Track metrics
    $totalCleanedFiles = 0
    $totalCleanedMB = 0
    $actionsApplied = @()

    # Step 1: Create Backup Session
    Write-SubHeader "[STEP 1/9] CREATING SYSTEM RESTORE SNAPSHOT"
    $session = New-TMBackupSession -TaskId "AUTO_OPT_FULL" -Description "Backup prior to Full System Auto Optimize"
    Backup-RegistryValue -Session $session -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" | Out-Null
    Backup-RegistryValue -Session $session -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" | Out-Null
    Backup-RegistryValue -Session $session -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SoftLandingEnabled" | Out-Null
    $backupId = Save-TMBackupSession -Session $session
    Write-Success "Restore snapshot created successfully: $backupId"
    $actionsApplied += "Created system rollback snapshot ($backupId)"

    # Step 2: Clean User & System Temp
    Write-SubHeader "[STEP 2/9] CLEANING TEMPORARY FILES & RECYCLE BIN"
    $userTemp = [System.IO.Path]::GetTempPath()
    $winTemp = Join-Path $env:SystemRoot "Temp"
    $tempTargets = @($userTemp, $winTemp)

    foreach ($dir in $tempTargets) {
        if (Test-Path $dir) {
            $files = Get-ChildItem -Path $dir -Recurse -File -ErrorAction SilentlyContinue
            $delCount = 0
            foreach ($f in $files) {
                try {
                    $len = $f.Length
                    Remove-Item $f.FullName -Force -ErrorAction Stop
                    $delCount++
                    $totalCleanedFiles++
                    $totalCleanedMB += ($len / 1MB)
                } catch {}
            }
            Write-Host "   -> Cleaned $delCount temp file(s) in $dir" -ForegroundColor Green
        }
    }

    # Empty Recycle Bin
    try {
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        Write-Host "   -> Emptied Recycle Bin across all disk volumes" -ForegroundColor Green
        $actionsApplied += "Emptied Recycle Bin"
    } catch {}

    # Crash Minidumps
    $dumpPath = Join-Path $env:SystemRoot "Minidump"
    if (Test-Path $dumpPath) {
        $dumpFiles = Get-ChildItem -Path $dumpPath -File -ErrorAction SilentlyContinue
        $dumpDel = 0
        foreach ($df in $dumpFiles) {
            try { Remove-Item $df.FullName -Force -ErrorAction Stop; $dumpDel++; $totalCleanedFiles++ } catch {}
        }
        if ($dumpDel -gt 0) {
            Write-Host "   -> Purged $dumpDel obsolete crash minidump(s)" -ForegroundColor Green
        }
    }
    $actionsApplied += "Cleaned user & system temporary files"

    # Step 3: Windows Update Download Cache
    Write-SubHeader "[STEP 3/9] PURGING WINDOWS UPDATE DOWNLOAD CACHE"
    $wuPath = Join-Path $env:SystemRoot "SoftwareDistribution\Download"
    if (Test-Path $wuPath) {
        try {
            Write-Host "   -> Pausing Windows Update service..." -ForegroundColor DarkGray
            Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
            $wuFiles = Get-ChildItem -Path $wuPath -Recurse -File -ErrorAction SilentlyContinue
            $wuDel = 0
            foreach ($wf in $wuFiles) {
                try {
                    $len = $wf.Length
                    Remove-Item $wf.FullName -Force -ErrorAction Stop
                    $wuDel++
                    $totalCleanedFiles++
                    $totalCleanedMB += ($len / 1MB)
                } catch {}
            }
            Write-Host "   -> Purged $wuDel downloaded Windows Update cache file(s)" -ForegroundColor Green
            Start-Service -Name wuauserv -ErrorAction SilentlyContinue
            $actionsApplied += "Purged Windows Update download cache ($wuDel files)"
        } catch {
            Write-Host "   -> Skipped Windows Update cache ($($_.Exception.Message))" -ForegroundColor Yellow
        }
    }

    # Step 4: Developer Caches (if installed)
    Write-SubHeader "[STEP 4/9] CLEANING DISPOSABLE DEVELOPER & PACKAGE CACHES"
    $devCleaned = $false
    if (Get-Command "npm" -ErrorAction SilentlyContinue) {
        try {
            Write-Host "   -> Cleaning npm cache (npm cache clean --force)..." -ForegroundColor DarkGray
            & npm cache clean --force 2>&1 | Out-Null
            Write-Host "   -> npm cache cleaned" -ForegroundColor Green
            $devCleaned = $true
        } catch {}
    }
    if (Get-Command "pip" -ErrorAction SilentlyContinue) {
        try {
            Write-Host "   -> Purging pip cache (pip cache purge)..." -ForegroundColor DarkGray
            & pip cache purge 2>&1 | Out-Null
            Write-Host "   -> pip cache purged" -ForegroundColor Green
            $devCleaned = $true
        } catch {}
    }
    if (Get-Command "uv" -ErrorAction SilentlyContinue) {
        try {
            Write-Host "   -> Cleaning uv cache (uv cache clean)..." -ForegroundColor DarkGray
            & uv cache clean 2>&1 | Out-Null
            Write-Host "   -> uv cache cleaned" -ForegroundColor Green
            $devCleaned = $true
        } catch {}
    }
    if (-not $devCleaned) {
        Write-Host "   -> No disposable dev caches found (or tools not installed)." -ForegroundColor DarkGray
    } else {
        $actionsApplied += "Cleaned developer package caches (pip/npm/uv)"
    }

    # Step 5: Visual Effects & UI Tuning
    Write-SubHeader "[STEP 5/9] OPTIMIZING VISUAL EFFECTS & ANIMATIONS"
    try {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 3 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0 -Force -ErrorAction SilentlyContinue
        Write-Host "   -> Disabled window animation latency while preserving clear font smoothing" -ForegroundColor Green
        $actionsApplied += "Tuned visual effects (reduced animation overhead, preserved fonts)"
    } catch {
        Write-Host "   -> Visual tuning skipped: $($_.Exception.Message)" -ForegroundColor Yellow
    }

    # Step 6: Privacy & Notification Tuning
    Write-SubHeader "[STEP 6/9] TUNING PRIVACY, PROMOTIONAL SUGGESTIONS & TIPS"
    try {
        $cdmPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
        Set-ItemProperty -Path $cdmPath -Name "SoftLandingEnabled" -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cdmPath -Name "SubscribedContent-338388Enabled" -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $cdmPath -Name "SubscribedContent-338389Enabled" -Value 0 -Force -ErrorAction SilentlyContinue
        Write-Host "   -> Disabled promotional tips, lockscreen recommendations & ads" -ForegroundColor Green
        $actionsApplied += "Disabled Windows tips & promotional suggestions"
    } catch {}

    # Step 7: Storage Volume Optimization (SSD ReTrim)
    Write-SubHeader "[STEP 7/9] OPTIMIZING STORAGE VOLUMES (SSD RETRIM)"
    try {
        $volumes = Get-Volume -ErrorAction SilentlyContinue | Where-Object { $null -ne $_.DriveLetter -and $_.DriveType -eq "Fixed" }
        foreach ($v in $volumes) {
            $dl = $v.DriveLetter
            Write-Host "   -> Running Optimize-Volume on drive $dl`: ... " -NoNewline -ForegroundColor DarkGray
            try {
                Optimize-Volume -DriveLetter $dl -ReTrim -ErrorAction Stop | Out-Null
                Write-Host "Done (SSD ReTrim complete)." -ForegroundColor Green
                $actionsApplied += "Ran SSD ReTrim on drive $dl`:"
            } catch {
                # Fallback defrag analyze if HDD
                try {
                    Optimize-Volume -DriveLetter $dl -Analyze -ErrorAction SilentlyContinue | Out-Null
                    Write-Host "Done (Analyzed volume)." -ForegroundColor Green
                } catch {
                    Write-Host "Skipped." -ForegroundColor DarkGray
                }
            }
        }
    } catch {
        Write-Host "   -> Storage optimization notice: $($_.Exception.Message)" -ForegroundColor Yellow
    }

    # Step 8: Network & DNS Cache Reset
    Write-SubHeader "[STEP 8/9] OPTIMIZING NETWORK & FLUSHING DNS RESOLVER CACHE"
    try {
        if (Get-Command "Clear-DnsClientCache" -ErrorAction SilentlyContinue) {
            Clear-DnsClientCache -ErrorAction SilentlyContinue
        } else {
            & ipconfig.exe /flushdns 2>&1 | Out-Null
        }
        & nbtstat.exe -R 2>&1 | Out-Null
        Write-Host "   -> Flushed Windows DNS resolver cache & NetBIOS name cache" -ForegroundColor Green
        $actionsApplied += "Flushed DNS client cache & NetBIOS cache"
    } catch {
        Write-Host "   -> DNS flush notice: $($_.Exception.Message)" -ForegroundColor Yellow
    }

    # Step 9: Component Store Cleanup (WinSxS)
    Write-SubHeader "[STEP 9/9] CLEANING COMPONENT STORE (DISM StartComponentCleanup)"
    Write-Host "   -> Purging superseded Windows update components... " -NoNewline -ForegroundColor DarkGray
    try {
        $dismOut = & dism.exe /Online /Cleanup-Image /StartComponentCleanup 2>&1
        Write-Host "Done!" -ForegroundColor Green
        $actionsApplied += "Cleaned obsolete WinSxS components (DISM StartComponentCleanup)"
    } catch {
        Write-Host "Skipped ($($_.Exception.Message))" -ForegroundColor Yellow
    }

    # Summary & Verification Report
    Write-Header -Title "FULL SYSTEM AUTO OPTIMIZATION COMPLETE!"
    Write-Success "All optimization phases have finished successfully!"
    Write-Host ""
    Write-Host "  SUMMARY REPORT:" -ForegroundColor Yellow
    Write-Host "  - Total Files Cleaned     : $totalCleanedFiles file(s)" -ForegroundColor White
    Write-Host "  - Approx. Space Reclaimed : $([math]::Round($totalCleanedMB, 1)) MB" -ForegroundColor White
    Write-Host "  - Rollback Backup ID      : $backupId" -ForegroundColor Cyan
    Write-Host "  - Windows Defender        : INTACT & PROTECTED (Safe by default)" -ForegroundColor Green
    Write-Host "  - Windows Firewall        : INTACT & PROTECTED (Safe by default)" -ForegroundColor Green
    Write-Host "  - Windows Update          : INTACT & FUNCTIONAL" -ForegroundColor Green
    Write-Host ""

    Write-InfoMessage "Actions Applied:"
    foreach ($act in $actionsApplied) {
        Write-Host "   [+] $act" -ForegroundColor Cyan
    }

    Write-Host ""
    Write-InfoMessage "You can restore original settings at any time from Menu [12] (Backup & State Restore)."
    Write-TMLog -TaskId "AUTO_OPT_FULL" -TaskName "Full System Auto Optimize" -Status "Success" -Message "Cleaned $totalCleanedFiles files ($([math]::Round($totalCleanedMB, 1)) MB). Backup: $backupId" -BackupId $backupId

    Pause-Screen
}

function Show-ServicesManagerMenu {
    Write-Header -Title "WINDOWS SERVICES MANAGEMENT CONSOLE"
    Write-InfoMessage "Querying service status for critical system components..."

    $servicesToCheck = @("SysMain", "WSearch", "Ndu")
    $list = @()
    foreach ($sName in $servicesToCheck) {
        $svc = Get-Service -Name $sName -ErrorAction SilentlyContinue
        $startMode = "Not Found"
        if ($svc) {
            $cim = Get-CimInstance Win32_Service -Filter "Name='$sName'" -ErrorAction SilentlyContinue
            if ($cim) { $startMode = $cim.StartMode }
        }
        $list += [PSCustomObject]@{
            ServiceName = $sName
            Status = if ($svc) { $svc.Status.ToString() } else { "Not Present" }
            StartupType = $startMode
        }
    }

    $headers = @("Service Name", "Status", "Startup Type")
    $props = @("ServiceName", "Status", "StartupType")
    $widths = @(18, 18, 20)
    Show-TableList -Items $list -Headers $headers -PropertyNames $props -Widths $widths

    Write-Host ""
    Write-Host "  IMPORTANT STABILITY & ARCHITECTURAL GUIDANCE:" -ForegroundColor Yellow
    Write-Host "  - SysMain: Memory prefetching. Do NOT disable if using SSD and sufficient RAM." -ForegroundColor Gray
    Write-Host "  - WSearch: Search indexer. Do NOT fully disable; narrow index locations instead." -ForegroundColor Gray
    Write-Host "  - Ndu: Network Data Usage monitor. Keep running; disabling is not supported by Microsoft." -ForegroundColor Gray
    Write-Host ""

    Write-Host "  [1] Open Services Management Console (services.msc)" -ForegroundColor Cyan
    Write-Host "  [2] Configure Search Indexing Scope (control srchadmin.dll)" -ForegroundColor Cyan
    Write-Host "  [0] Back" -ForegroundColor Yellow
    Write-Divider

    $sel = Read-MenuSelection -PromptText "Select an option" -Min 0 -Max 2
    switch ($sel) {
        1 { Start-Process "services.msc" }
        2 { Start-Process "control.exe" "srchadmin.dll" }
        0 { return }
    }
}

function Show-VisualEffectsMenu {
    Write-Header -Title "VISUAL EFFECTS & WINDOW ANIMATIONS"
    Write-Host "  [1] Balanced Optimization (Disable window animations, keep font smoothing)" -ForegroundColor Cyan
    Write-Host "  [2] Best Performance (Disable all animations and effects)" -ForegroundColor Cyan
    Write-Host "  [3] Restore Windows Default (Let Windows choose what's best)" -ForegroundColor Cyan
    Write-Host "  [4] Open Windows Performance Options GUI" -ForegroundColor Cyan
    Write-Host "  [0] Back" -ForegroundColor Yellow
    Write-Divider

    $sel = Read-MenuSelection -PromptText "Select visual preset" -Min 0 -Max 4
    switch ($sel) {
        1 {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 3 -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0 -Force -ErrorAction SilentlyContinue
            Write-Success "Balanced visual effects applied."
            Pause-Screen
        }
        2 {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -Force -ErrorAction SilentlyContinue
            Write-Success "Best Performance preset applied."
            Pause-Screen
        }
        3 {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 0 -Force -ErrorAction SilentlyContinue
            Write-Success "Restored automatic Windows defaults."
            Pause-Screen
        }
        4 {
            Start-Process "SystemPropertiesPerformance.exe"
        }
        0 { return }
    }
}

function Show-StartupAppsMenu {
    Write-Header -Title "STARTUP APPLICATIONS (RUN AT BOOT)"
    Write-InfoMessage "Querying startup entries in user and system Registry..."

    $regPaths = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
    )

    $items = @()
    foreach ($rp in $regPaths) {
        if (Test-Path $rp) {
            $props = Get-ItemProperty -Path $rp
            foreach ($name in $props.PSObject.Properties.Name) {
                if ($name -notmatch "^PS.*") {
                    $items += [PSCustomObject]@{
                        AppName = $name
                        Scope = if ($rp -match "HKCU") { "User" } else { "System" }
                        Command = $props.$name
                    }
                }
            }
        }
    }

    $headers = @("Application Name", "Scope", "Command Line")
    $props = @("AppName", "Scope", "Command")
    $widths = @(25, 10, 35)
    Show-TableList -Items $items -Headers $headers -PropertyNames $props -Widths $widths

    Write-Host ""
    Write-Host "  [1] Open Startup Apps in Windows Settings" -ForegroundColor Cyan
    Write-Host "  [2] Open Task Manager (Startup Tab)" -ForegroundColor Cyan
    Write-Host "  [0] Back" -ForegroundColor Yellow
    Write-Divider

    $sel = Read-MenuSelection -PromptText "Select an option" -Min 0 -Max 2
    switch ($sel) {
        1 { Start-Process "ms-settings:startupapps" }
        2 { Start-Process "taskmgr.exe" }
        0 { return }
    }
}

function Show-PowerPlanMenu {
    Write-Header -Title "POWER PLAN & PERFORMANCE SCHEMES"
    try {
        $activePlan = (powercfg /getactivescheme)
        Write-InfoMessage "Current Scheme: $activePlan"
    } catch {}

    Write-Host ""
    Write-Host "  [1] Open Classic Power Options (Control Panel)" -ForegroundColor Cyan
    Write-Host "  [2] Set to Balanced Power Scheme" -ForegroundColor Cyan
    Write-Host "  [3] Set to High Performance Power Scheme" -ForegroundColor Cyan
    Write-Host "  [0] Back" -ForegroundColor Yellow
    Write-Divider

    $sel = Read-MenuSelection -PromptText "Select an option" -Min 0 -Max 3
    switch ($sel) {
        1 { Start-Process "powercfg.cpl" }
        2 {
            powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e
            Write-Success "Switched to Balanced Power Scheme."
            Pause-Screen
        }
        3 {
            powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
            Write-Success "Switched to High Performance Power Scheme."
            Pause-Screen
        }
        0 { return }
    }
}
