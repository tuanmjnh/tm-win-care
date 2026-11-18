# TM-WinCare - UI Colors & Visual Formatting
# Compatible with Windows PowerShell 5.1 & PowerShell 7

function Write-Header {
    param (
        [string]$Title,
        [int]$Width = 65
    )
    $line = "=" * $Width
    Write-Host ""
    Write-Host $line -ForegroundColor Cyan
    $pad = [math]::Max(0, [int](($Width - $Title.Length) / 2))
    $centered = (" " * $pad) + $Title
    Write-Host $centered -ForegroundColor White
    Write-Host $line -ForegroundColor Cyan
}

function Write-SubHeader {
    param (
        [string]$Title,
        [int]$Width = 65
    )
    $line = "-" * $Width
    Write-Host ""
    Write-Host (" " + $Title) -ForegroundColor Yellow
    Write-Host $line -ForegroundColor DarkGray
}

function Write-Divider {
    param ([int]$Width = 65)
    Write-Host ("-" * $Width) -ForegroundColor DarkGray
}

function Write-Success {
    param ([string]$Message)
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host $Message -ForegroundColor White
}

function Write-WarningMessage {
    param ([string]$Message)
    Write-Host "[WARNING] " -ForegroundColor Yellow -NoNewline
    Write-Host $Message -ForegroundColor Yellow
}

function Write-ErrorMessage {
    param ([string]$Message)
    Write-Host "[ERROR] " -ForegroundColor Red -NoNewline
    Write-Host $Message -ForegroundColor Red
}

function Write-InfoMessage {
    param ([string]$Message)
    Write-Host "[INFO] " -ForegroundColor Cyan -NoNewline
    Write-Host $Message -ForegroundColor Gray
}

function Write-SkipMessage {
    param ([string]$Message)
    Write-Host "[SKIPPED] " -ForegroundColor DarkYellow -NoNewline
    Write-Host $Message -ForegroundColor DarkGray
}
