# TM-WinCare - Privacy, Notifications & Copilot Module
# Adheres to Section 7C of TM-WinCare-Architecture-v1.2.md

function Show-TMPrivacyMenu {
    $menuItems = @(
        @{ Label = "Toggle Microsoft Copilot Taskbar Button (Windows 11)"; Action = { Toggle-CopilotTaskbar } },
        @{ Label = "Disable Windows Tips, Suggestions & Promotional Ads"; Action = { Disable-WindowsTips } },
        @{ Label = "Toggle Taskbar Widgets / News Feed (Windows 11)"; Action = { Toggle-TaskbarWidgets } },
        @{ Label = "Open Windows Notifications & Actions Settings"; Action = { Start-Process "ms-settings:notifications" } },
        @{ Label = "Open Windows Privacy & Security Settings"; Action = { Start-Process "ms-settings:privacy" } },
        @{ Label = "Open Windows Search Indexing Options (Reduce Disk I/O)"; Action = { Start-Process "control.exe" "srchadmin.dll" } }
    )
    Show-TMMenu -Title "PRIVACY, NOTIFICATIONS & SYSTEM COMPONENTS" -MenuItems $menuItems -ExitLabel "Back"
}

function Toggle-CopilotTaskbar {
    Write-SubHeader "TOGGLE COPILOT TASKBAR BUTTON"
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    try {
        $current = (Get-ItemProperty -Path $regPath -Name "ShowCopilotButton" -ErrorAction SilentlyContinue).ShowCopilotButton
        $statusStr = if ($current -eq 0) { "Hidden (Disabled)" } else { "Visible (Enabled)" }
        Write-InfoMessage "Current Copilot Button Status: $statusStr"

        Write-Host " [1] Hide Copilot Button" -ForegroundColor Cyan
        Write-Host " [2] Show Copilot Button" -ForegroundColor Cyan
        Write-Host " [0] Back" -ForegroundColor Yellow
        $sel = Read-MenuSelection -Min 0 -Max 2
        switch ($sel) {
            1 {
                Set-ItemProperty -Path $regPath -Name "ShowCopilotButton" -Value 0 -Force
                Write-Success "Copilot button hidden from Taskbar."
                Write-InfoMessage "You may need to restart or refresh File Explorer."
            }
            2 {
                Set-ItemProperty -Path $regPath -Name "ShowCopilotButton" -Value 1 -Force
                Write-Success "Copilot button enabled on Taskbar."
            }
        }
    } catch {
        Handle-TMException -TaskId "PRIV_COPILOT" -TaskName "Copilot Taskbar" -Exception $_.Exception
    }
    Pause-Screen
}

function Disable-WindowsTips {
    Write-SubHeader "DISABLE WINDOWS TIPS & SUGGESTIONS"
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    try {
        Set-ItemProperty -Path $regPath -Name "SoftLandingEnabled" -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $regPath -Name "SubscribedContent-338388Enabled" -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $regPath -Name "SubscribedContent-338389Enabled" -Value 0 -Force -ErrorAction SilentlyContinue
        Write-Success "Windows tips, suggestions, and app recommendations disabled!"
        Write-TMLog -TaskId "PRIV_TIPS" -TaskName "Disable Windows Tips" -Status "Success" -Message "Success"
    } catch {
        Handle-TMException -TaskId "PRIV_TIPS" -TaskName "Disable Windows Tips" -Exception $_.Exception
    }
    Pause-Screen
}

function Toggle-TaskbarWidgets {
    Write-SubHeader "TOGGLE TASKBAR WIDGETS (WINDOWS 11)"
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    try {
        $current = (Get-ItemProperty -Path $regPath -Name "TaskbarDa" -ErrorAction SilentlyContinue).TaskbarDa
        $statusStr = if ($current -eq 0) { "Hidden (Disabled)" } else { "Visible (Enabled)" }
        Write-InfoMessage "Current Widgets Status: $statusStr"

        Write-Host " [1] Hide Widgets" -ForegroundColor Cyan
        Write-Host " [2] Show Widgets" -ForegroundColor Cyan
        Write-Host " [0] Back" -ForegroundColor Yellow
        $sel = Read-MenuSelection -Min 0 -Max 2
        switch ($sel) {
            1 {
                Set-ItemProperty -Path $regPath -Name "TaskbarDa" -Value 0 -Force
                Write-Success "Widgets hidden from Taskbar."
            }
            2 {
                Set-ItemProperty -Path $regPath -Name "TaskbarDa" -Value 1 -Force
                Write-Success "Widgets enabled on Taskbar."
            }
        }
    } catch {
        Handle-TMException -TaskId "PRIV_WIDGETS" -TaskName "Widgets Taskbar" -Exception $_.Exception
    }
    Pause-Screen
}
