# TM-WinCare - Elevation & Admin Check
# Adheres to Section 13 of TM-WinCare-Architecture-v1.2.md

function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Assert-Admin {
    param (
        [string]$ActionName = "this action"
    )
    if (-not (Test-IsAdmin)) {
        Write-ErrorMessage "Administrator privileges required to perform $ActionName."
        Write-InfoMessage "Please restart the tool as Administrator (right click -> 'Run as administrator')."
        return $false
    }
    return $true
}

function Request-Elevation {
    param (
        [string]$Reason = "perform system administration tasks"
    )
    if (Test-IsAdmin) { return $true }

    Write-WarningMessage "Administrator elevation required to $Reason."
    Write-Host " Would you like to restart in an elevated Administrator session? (Y/N): " -ForegroundColor Cyan -NoNewline
    $ans = Read-Host
    if ($ans.Trim().ToUpper() -eq "Y") {
        $startCmd = Join-Path $PSScriptRoot "../../Start.cmd"
        if (Test-Path $startCmd) {
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$startCmd`"" -Verb RunAs
            exit 0
        }
    }
    return $false
}
