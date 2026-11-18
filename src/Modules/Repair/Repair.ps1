# TM-WinCare - Windows Repair Module
# Adheres to Section 3.4 & 3.5 of TM-WinCare-Architecture-v1.2.md

function Show-TMRepairMenu {
    $menuItems = @(
        @{ Label = "Complete Windows Repair Wizard (DISM RestoreHealth -> SFC Scannow)"; Action = { Invoke-RepairPipeline } },
        @{ Label = "SFC - Scan and Automatically Repair Corrupted Files (sfc /scannow)"; Action = { Invoke-SfcScanNow } },
        @{ Label = "DISM - Quick Corruption Check (CheckHealth)"; Action = { Invoke-DismCheckHealth } },
        @{ Label = "DISM - Deep Component Store Health Scan (ScanHealth)"; Action = { Invoke-DismScan } },
        @{ Label = "DISM - Restore Component Store Health (RestoreHealth)"; Action = { Invoke-DismRestore } },
        @{ Label = "Clean Windows Component Store WinSxS (DISM StartComponentCleanup)"; Action = { Invoke-DismComponentCleanup } },
        @{ Label = "Reset Network Winsock & TCP/IP Stack (Netsh Winsock Reset)"; Action = { Invoke-ResetWinsock } }
    )
    Show-TMMenu -Title "WINDOWS SYSTEM REPAIR & HEALTH" -MenuItems $menuItems -ExitLabel "Back"
}

function Invoke-DismCheckHealth {
    if (-not (Assert-Admin "run DISM quick check")) { Pause-Screen; return }
    Write-SubHeader "DISM /CheckHealth - QUICK COMPONENT STORE HEALTH CHECK"
    & dism.exe /Online /Cleanup-Image /CheckHealth
    Pause-Screen
}

function Invoke-DismComponentCleanup {
    if (-not (Assert-Admin "clean component store")) { Pause-Screen; return }
    Write-SubHeader "CLEAN WINSXS COMPONENT STORE (DISM StartComponentCleanup)"
    Write-InfoMessage "Reclaims disk space by purging superseded update components per official Microsoft guidance."
    
    $confirmed = Confirm-Action -TaskName "DISM Component Cleanup" -ImpactDescription "Cleans superseded update packages in WinSxS. Operation cannot be rolled back but is officially safe." -RiskLevel "medium"
    if ($confirmed) {
        Write-InfoMessage "Executing DISM /Online /Cleanup-Image /StartComponentCleanup..."
        & dism.exe /Online /Cleanup-Image /StartComponentCleanup
        Write-Success "Component Store cleanup complete!"
        Write-TMLog -TaskId "DISM_CLEANUP" -TaskName "DISM StartComponentCleanup" -Status "Success" -Message "Complete"
    }
    Pause-Screen
}

function Invoke-ResetWinsock {
    if (-not (Assert-Admin "reset Winsock")) { Pause-Screen; return }
    Write-SubHeader "RESET WINSOCK & TCP/IP STACK"
    $confirmed = Confirm-Action -TaskName "Reset Winsock" -ImpactDescription "Resets network socket catalog to default to fix internet, DNS, or broken proxy issues. Requires restart." -RiskLevel "medium"
    if ($confirmed) {
        & netsh.exe winsock reset
        & netsh.exe int ip reset
        Write-Success "Winsock and TCP/IP stack successfully reset!"
        Write-WarningMessage "Please restart your computer to apply the network reset."
        Write-TMLog -TaskId "NET_WINSOCK_RESET" -TaskName "Reset Winsock" -Status "Success" -Message "Success" -RequiresRestart $true
    }
    Pause-Screen
}
