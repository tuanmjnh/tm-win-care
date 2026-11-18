# TM-WinCare - Compatibility & Feature Testing
# Adheres to Section 12 of TM-WinCare-Architecture-v1.2.md

function Test-IsWindowsHome {
    try {
        $edition = (Get-CimInstance Win32_OperatingSystem).Caption
        return ($edition -match "Home")
    } catch {
        return $false
    }
}

function Test-CmdletAvailable {
    param ([string]$Name)
    $cmd = Get-Command -Name $Name -ErrorAction SilentlyContinue
    return ($null -ne $cmd)
}

function Test-ToolAvailable {
    param ([string]$ExecutableName)
    $path = Get-Command -Name $ExecutableName -ErrorAction SilentlyContinue
    return ($null -ne $path)
}

function Assert-FeatureSupported {
    param (
        [string]$FeatureName,
        [int]$MinBuild = 0,
        [bool]$RequiresPro = $false
    )
    if ($global:TM_OS_INFO) {
        if ($MinBuild -gt 0 -and $global:TM_OS_INFO.Build -lt $MinBuild) {
            Write-WarningMessage "$FeatureName yêu cầu Windows build tối thiểu $MinBuild (Hiện tại: $($global:TM_OS_INFO.Build))."
            return $false
        }
        if ($RequiresPro -and (Test-IsWindowsHome)) {
            Write-WarningMessage "$FeatureName yêu cầu phiên bản Windows Pro/Enterprise (Phiên bản Home không hỗ trợ chính thức)."
            return $false
        }
    }
    return $true
}
