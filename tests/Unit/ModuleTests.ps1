# TM-WinCare - Unit Tests for Functional Modules
# Adheres to Section 15 of TM-WinCare-Architecture-v1.2.md

$testRoot = $PSScriptRoot
$srcRoot = Join-Path $testRoot "../../src"

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "            TM-WINCARE - BỘ KIỂM THỬ MODULES            " -ForegroundColor White
Write-Host "=========================================================" -ForegroundColor Cyan

. (Join-Path $srcRoot "Core/Bootstrap.ps1")
. (Join-Path $srcRoot "Modules/Dashboard/Dashboard.ps1")
. (Join-Path $srcRoot "Modules/PostInstall/PostInstall.ps1")
. (Join-Path $srcRoot "Modules/Optimization/Optimization.ps1")
. (Join-Path $srcRoot "Modules/Maintenance/Maintenance.ps1")
. (Join-Path $srcRoot "Modules/Repair/Repair.ps1")
. (Join-Path $srcRoot "Modules/Network/Network.ps1")
. (Join-Path $srcRoot "Modules/Printer/Printer.ps1")
. (Join-Path $srcRoot "Modules/Cleanup/WindowsCleanup.ps1")
. (Join-Path $srcRoot "Modules/Cleanup/AiDevCleanup.ps1")
. (Join-Path $srcRoot "Modules/Privacy/Privacy.ps1")
. (Join-Path $srcRoot "Modules/Accounts/Accounts.ps1")
. (Join-Path $srcRoot "Modules/QuickCommands/QuickCommands.ps1")
. (Join-Path $srcRoot "Modules/BackupRestore/BackupRestore.ps1")

$passed = 0
$failed = 0

function Assert-ModuleTest {
    param (
        [string]$Name,
        [scriptblock]$TestBlock
    )
    try {
        $result = & $TestBlock
        if ($result) {
            Write-Host " [PASS] $Name" -ForegroundColor Green
            $script:passed++
        } else {
            Write-Host " [FAIL] $Name (Condition returned false)" -ForegroundColor Red
            $script:failed++
        }
    } catch {
        Write-Host " [FAIL] $Name (Exception: $($_.Exception.Message))" -ForegroundColor Red
        $script:failed++
    }
}

# 1. Test System Cleanup Catalog
Assert-ModuleTest -Name "Kiểm tra danh mục System Cleanup JSON" -TestBlock {
    $catalogPath = Join-Path $testRoot "../../data/cleanup-catalog/system-cleanup.json"
    $items = Get-Content -Path $catalogPath -Raw -Encoding UTF8 | ConvertFrom-Json
    return ($items.Count -ge 5)
}

# 2. Test AI & Developer Cleanup Catalog
Assert-ModuleTest -Name "Kiểm tra danh mục AI & Dev Cleanup JSON" -TestBlock {
    $catalogPath = Join-Path $testRoot "../../data/cleanup-catalog/aidev-cleanup.json"
    $items = Get-Content -Path $catalogPath -Raw -Encoding UTF8 | ConvertFrom-Json
    # Verify Ollama has safety preservation
    $ollama = $items | Where-Object { $_.id -eq "AIDEV_OLLAMA" }
    return ($items.Count -ge 5 -and $ollama.safeToDelete -eq $false)
}

# 3. Test Network Overview logic
Assert-ModuleTest -Name "Kiểm tra truy vấn cấu hình mạng" -TestBlock {
    $adapters = Get-NetAdapter -ErrorAction SilentlyContinue
    return ($null -ne $adapters)
}

# 4. Test Volume query logic
Assert-ModuleTest -Name "Kiểm tra truy vấn ổ đĩa lưu trữ" -TestBlock {
    $vols = Get-Volume -ErrorAction SilentlyContinue | Where-Object { $null -ne $_.DriveLetter }
    return ($vols.Count -ge 1)
}

# 5. Test Spooler Health function
Assert-ModuleTest -Name "Kiểm tra trạng thái Print Spooler" -TestBlock {
    $spooler = Get-Service -Name Spooler -ErrorAction SilentlyContinue
    return ($null -ne $spooler)
}

Write-Host "---------------------------------------------------------" -ForegroundColor DarkGray
Write-Host " Kết quả: $passed passed, $failed failed." -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })
Write-Host "=========================================================" -ForegroundColor Cyan

if ($failed -gt 0) { exit 1 } else { exit 0 }
