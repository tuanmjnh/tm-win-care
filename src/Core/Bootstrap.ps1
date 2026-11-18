# TM-WinCare - Application Bootstrap
# Adheres to Section 9 & 10 of TM-WinCare-Architecture-v1.2.md

# 1. Force UTF-8 Encoding in Console
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# 2. Source Core & UI Modules
$corePath = $PSScriptRoot
$uiPath = Join-Path $PSScriptRoot "../UI"

. (Join-Path $uiPath "Colors.ps1")
. (Join-Path $uiPath "Tables.ps1")
. (Join-Path $uiPath "Prompts.ps1")

. (Join-Path $corePath "Logger.ps1")
. (Join-Path $corePath "Admin.ps1")
. (Join-Path $corePath "WindowsInfo.ps1")
. (Join-Path $corePath "Compatibility.ps1")
. (Join-Path $corePath "Backup.ps1")
. (Join-Path $corePath "Restore.ps1")
. (Join-Path $corePath "Confirm.ps1")
. (Join-Path $corePath "ErrorHandler.ps1")
. (Join-Path $corePath "Menu.ps1")

# 3. Load App Configuration
$configPath = Join-Path $PSScriptRoot "../../config/app.json"
if (Test-Path $configPath) {
    $global:TM_CONFIG = Get-Content -Path $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
} else {
    $global:TM_CONFIG = [PSCustomObject]@{
        name = "TM-WinCare"
        version = "1.2.0"
        displayName = "TM Windows Support"
    }
}

# 4. Cache System & OS Info
$null = Get-TMSystemInfo

# 5. Log startup
Write-TMLog -TaskId "INIT" -TaskName "Khởi động ứng dụng" -Status "Started" -Message "TM-WinCare v$($global:TM_CONFIG.version) khởi động thành công"
