# TM-WinCare - Windows Post-Install Configuration
# Adheres to Section 3.2 of TM-WinCare-Architecture-v1.2.md

. (Join-Path $PSScriptRoot "CheckLicense.ps1")

function Show-TMPostInstallMenu {
    $menuItems = @(
        @{ Label = "Windows & Office License Management (IT Inventory Full Key)"; Action = { Invoke-LicenseInventoryCheck } },
        @{ Label = "Rename Computer Hostname"; Action = { Invoke-RenameComputer } },
        @{ Label = "Show Known File Extensions (.exe, .txt...)"; Action = { Set-ExplorerShowFileExtensions -Enable $true } },
        @{ Label = "Hide Known File Extensions"; Action = { Set-ExplorerShowFileExtensions -Enable $false } },
        @{ Label = "Show Hidden Files and Folders"; Action = { Set-ExplorerShowHiddenFiles -Enable $true } },
        @{ Label = "Hide Hidden Files and Folders"; Action = { Set-ExplorerShowHiddenFiles -Enable $false } },
        @{ Label = "Check Missing / Faulty Drivers (Device Errors)"; Action = { Test-DeviceErrors } },
        @{ Label = "Open Date & Time Settings"; Action = { Start-Process "timedate.cpl" } },
        @{ Label = "Open Windows Update Settings"; Action = { Start-Process "ms-settings:windowsupdate" } },
        @{ Label = "Open Windows Activation Settings"; Action = { Start-Process "ms-settings:activation" } },
        @{ Label = "Open Startup Folder (shell:startup)"; Action = { Start-Process "explorer.exe" "shell:startup" } },
        @{ Label = "Open Power Options (powercfg.cpl)"; Action = { Start-Process "powercfg.cpl" } }
    )
    Show-TMMenu -Title "WINDOWS POST-INSTALL CONFIGURATION" -MenuItems $menuItems -ExitLabel "Back"
}

function Invoke-RenameComputer {
    if (-not (Assert-Admin "rename computer")) {
        Pause-Screen
        return
    }

    $currentName = [System.Environment]::MachineName
    Write-SubHeader "RENAME COMPUTER HOSTNAME"
    Write-InfoMessage "Current Computer Name: $currentName"
    Write-Host " Enter new computer name (letters, digits and dashes, max 15 chars): " -ForegroundColor Cyan -NoNewline
    $newName = Read-Host

    if ([string]::IsNullOrWhiteSpace($newName) -or $newName -match '[^a-zA-Z0-9\-]') {
        Write-ErrorMessage "Invalid computer name. Only characters a-z, 0-9 and hyphens (-) are permitted."
        Pause-Screen
        return
    }

    if ($newName.Length -gt 15) {
        Write-ErrorMessage "Computer NetBIOS name must not exceed 15 characters."
        Pause-Screen
        return
    }

    if ($newName.ToUpper() -eq $currentName.ToUpper()) {
        Write-WarningMessage "New name is identical to current computer name."
        Pause-Screen
        return
    }

    $approved = Confirm-Action -TaskName "Rename Computer" -ImpactDescription "Rename computer from '$currentName' to '$newName'. Requires a restart to take effect." -RiskLevel "medium"
    if ($approved) {
        try {
            Rename-Computer -NewName $newName -Force -ErrorAction Stop
            Write-Success "Computer successfully renamed to '$newName'!"
            Write-WarningMessage "A SYSTEM RESTART IS REQUIRED for the new hostname to take effect."
            Write-TMLog -TaskId "POST_RENAME" -TaskName "Rename Computer" -Status "Success" -Message "Renamed from $currentName to $newName" -RequiresRestart $true
        } catch {
            Handle-TMException -TaskId "POST_RENAME" -TaskName "Rename Computer" -Exception $_.Exception
        }
    }
    Pause-Screen
}

function Set-ExplorerShowFileExtensions {
    param ([bool]$Enable)
    $val = if ($Enable) { 0 } else { 1 }
    $actionDesc = if ($Enable) { "Show file extensions" } else { "Hide file extensions" }
    
    try {
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        Set-ItemProperty -Path $regPath -Name "HideFileExt" -Value $val -Force
        Write-Success "Setting updated: $actionDesc."
        Write-InfoMessage "Note: You may need to restart or refresh File Explorer."
        Write-TMLog -TaskId "POST_FILEEXT" -TaskName $actionDesc -Status "Success" -Message "HideFileExt = $val"
    } catch {
        Handle-TMException -TaskId "POST_FILEEXT" -TaskName $actionDesc -Exception $_.Exception
    }
    Pause-Screen
}

function Set-ExplorerShowHiddenFiles {
    param ([bool]$Enable)
    $val = if ($Enable) { 1 } else { 2 }
    $actionDesc = if ($Enable) { "Show hidden files and folders" } else { "Hide hidden files and folders" }

    try {
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        Set-ItemProperty -Path $regPath -Name "Hidden" -Value $val -Force
        Write-Success "Setting updated: $actionDesc."
        Write-TMLog -TaskId "POST_HIDDEN" -TaskName $actionDesc -Status "Success" -Message "Hidden = $val"
    } catch {
        Handle-TMException -TaskId "POST_HIDDEN" -TaskName $actionDesc -Exception $_.Exception
    }
    Pause-Screen
}

function Test-DeviceErrors {
    Write-SubHeader "CHECK HARDWARE DEVICES & MISSING DRIVERS"
    Write-InfoMessage "Querying Plug and Play entities via CIM..."

    try {
        $problemDevices = Get-CimInstance -ClassName Win32_PnPEntity | Where-Object { $_.ConfigManagerErrorCode -ne 0 -and $null -ne $_.ConfigManagerErrorCode }
        if (-not $problemDevices -or @($problemDevices).Count -eq 0) {
            Write-Success "All good! No faulty or missing driver devices detected on this system."
        } else {
            Write-WarningMessage "Detected $(@($problemDevices).Count) device(s) reporting error codes:"
            $headers = @("Device Name", "PnP Error Code", "Hardware ID")
            $props = @("Name", "ConfigManagerErrorCode", "DeviceID")
            $widths = @(30, 16, 30)
            Show-TableList -Items $problemDevices -Headers $headers -PropertyNames $props -Widths $widths
            Write-Host ""
            Write-InfoMessage "Tip: Open Device Manager (devmgmt.msc) to install or update drivers."
        }
    } catch {
        Handle-TMException -TaskId "DEV_CHECK" -TaskName "Check Devices" -Exception $_.Exception
    }
    Pause-Screen
}
