# ========================================
#           OPENCODE CLI LAUNCHER
# ========================================

$ScriptPath = $PSCommandPath

# Nếu chưa chạy trong PowerShell 7 thì mở PowerShell 7
if ($PSVersionTable.PSVersion.Major -lt 7) {

    Start-Process "pwsh.exe" `
        -ArgumentList "-NoLogo", "-NoExit", "-ExecutionPolicy", "Bypass", "-File", "`"$ScriptPath`""

    exit
}

# ========================================
# UTF-8
# ========================================

[Console]::InputEncoding = [System.Text.UTF8Encoding]::new()
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$OutputEncoding = [System.Text.UTF8Encoding]::new()

# ========================================
# Working Directory
# ========================================

Set-Location "D:\Applications"

# ========================================
# Title
# ========================================

$Host.UI.RawUI.WindowTitle = "OpenCode CLI"

Clear-Host

Write-Host ""
Write-Host "========================================"
Write-Host "            OPENCODE CLI"
Write-Host "========================================"
Write-Host ""

Write-Host "Working Directory:"
Write-Host "  $((Get-Location).Path)"
Write-Host ""

# ========================================
# Check OpenCode
# ========================================

$OpenCode = Get-Command opencode -ErrorAction SilentlyContinue

if (-not $OpenCode) {

    Write-Host "[LOI] Khong tim thay OpenCode." -ForegroundColor Red
    Write-Host ""

    Write-Host "Kiem tra:"
    Write-Host "  where.exe opencode"
    Write-Host ""

    Read-Host "Nhan Enter de thoat"

    exit 1
}

Write-Host "OpenCode:"
Write-Host "  $($OpenCode.Source)"
Write-Host ""

Write-Host "----------------------------------------"
Write-Host ""

# ========================================
# Run OpenCode
# ========================================

& opencode

Write-Host ""
Write-Host "----------------------------------------"
Write-Host "OpenCode da ket thuc."
Write-Host ""

Read-Host "Nhan Enter de dong"