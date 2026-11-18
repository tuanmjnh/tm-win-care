# TM-WinCare - Elevation & Admin Check
# Adheres to Section 13 of TM-WinCare-Architecture-v1.2.md

function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Assert-Admin {
    param (
        [string]$ActionName = "thao tác này"
    )
    if (-not (Test-IsAdmin)) {
        Write-ErrorMessage "Bạn cần chạy với quyền Quản trị viên (Run as Administrator) để thực hiện $ActionName."
        Write-InfoMessage "Vui lòng đóng công cụ và chuột phải vào Start.cmd -> chọn 'Run as administrator'."
        return $false
    }
    return $true
}

function Request-Elevation {
    param (
        [string]$Reason = "thực hiện các tác vụ quản trị hệ thống"
    )
    if (Test-IsAdmin) { return $true }

    Write-WarningMessage "Yêu cầu nâng quyền Administrator để $Reason."
    Write-Host " Bạn có muốn mở phiên làm việc mới với quyền Administrator không? (Y/N): " -ForegroundColor Cyan -NoNewline
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
