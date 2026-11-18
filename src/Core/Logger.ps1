# TM-WinCare - Structured Logging (TXT & JSONL)
# Adheres to Section 11 of TM-WinCare-Architecture-v1.2.md

$script:LogDirectory = if ($PSScriptRoot) { Join-Path $PSScriptRoot "../../Logs" } else { Join-Path $env:TEMP "TM-WinCare\Logs" }
if (-not (Test-Path $script:LogDirectory)) {
    New-Item -ItemType Directory -Path $script:LogDirectory -Force | Out-Null
}

function Sanitize-LogMessage {
    param ([string]$Message)
    if ([string]::IsNullOrEmpty($Message)) { return "" }
    # Filter passwords, tokens, credentials
    $sanitized = $Message -replace "(?i)(password|pwd|secret|token|key)\s*[:=]\s*\S+", '$1: [REDACTED]'
    $sanitized = $sanitized -replace '(?i)(net\s+user\s+\S+\s+)"?[^"\s/]+"?', '$1[REDACTED]'
    $sanitized = $sanitized -replace '(?i)/add\s+"[^"]+"', '/add [REDACTED]'
    return $sanitized
}

function Write-TMLog {
    param (
        [string]$TaskId = "SYS",
        [string]$TaskName = "System",
        [ValidateSet("Started", "Success", "Failed", "Skipped", "Warning", "Info")]
        [string]$Status = "Info",
        [string]$Message = "",
        [string]$BackupId = "",
        [bool]$RequiresRestart = $false
    )

    $cleanMsg = Sanitize-LogMessage -Message $Message
    $now = Get-Date
    $dateStr = $now.ToString("yyyy-MM-dd")
    $timeStr = $now.ToString("yyyy-MM-dd HH:mm:ss")
    $logTxtPath = Join-Path $script:LogDirectory "$dateStr.log"
    $logJsonlPath = Join-Path $script:LogDirectory "$dateStr.jsonl"

    $osVersion = if ($global:TM_OS_INFO) { "$($global:TM_OS_INFO.Version) Build $($global:TM_OS_INFO.Build)" } else { [System.Environment]::OSVersion.VersionString }

    # 1. Plain text log
    $txtLine = "[$timeStr] [$Status] [$TaskId] $TaskName - $cleanMsg"
    if ($BackupId) { $txtLine += " (Backup: $BackupId)" }
    if ($RequiresRestart) { $txtLine += " [Requires Restart]" }
    
    try {
        Add-Content -Path $logTxtPath -Value $txtLine -Encoding UTF8 -ErrorAction SilentlyContinue
    } catch {}

    # 2. Structured JSONL record
    $record = [ordered]@{
        timestamp = $now.ToString("o")
        taskId = $TaskId
        taskName = $TaskName
        status = $Status
        message = $cleanMsg
        backupId = $BackupId
        requiresRestart = $RequiresRestart
        os = $osVersion
        user = "$([System.Environment]::UserDomainName)\$([System.Environment]::UserName)"
    }

    try {
        $jsonLine = $record | ConvertTo-Json -Compress
        Add-Content -Path $logJsonlPath -Value $jsonLine -Encoding UTF8 -ErrorAction SilentlyContinue
    } catch {}
}
