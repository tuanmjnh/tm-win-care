# TM-WinCare - Optimization Main Module
# Adheres to Section 3.3.1 of TM-WinCare-Architecture-v1.2.md

. (Join-Path $PSScriptRoot "Profiles.ps1")

function Show-TMOptimizationMenu {
    $menuItems = @(
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
    Show-TMMenu -Title "SAFE SYSTEM OPTIMIZATION (PROFILES & TUNING)" -MenuItems $menuItems -ExitLabel "Back"
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
