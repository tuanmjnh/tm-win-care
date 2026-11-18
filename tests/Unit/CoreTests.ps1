# TM-WinCare - Unit Tests for Core Modules
# Adheres to Section 15 of TM-WinCare-Architecture-v1.2.md

$testRoot = $PSScriptRoot
$srcRoot = Join-Path $testRoot "../../src"

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "              TM-WINCARE - BỘ KIỂM THỬ CORE             " -ForegroundColor White
Write-Host "=========================================================" -ForegroundColor Cyan

$passed = 0
$failed = 0

function Assert-Test {
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

# 1. Test Bootstrap and Configuration Loading
. (Join-Path $srcRoot "Core/Bootstrap.ps1")

Assert-Test -Name "Nạp Bootstrap & App Configuration" -TestBlock {
    return ($null -ne $global:TM_CONFIG -and $global:TM_CONFIG.version -eq "1.2.0")
}

# 2. Test System Info Detection
Assert-Test -Name "Nhận diện hệ điều hành và phần cứng qua CIM" -TestBlock {
    $sys = Get-TMSystemInfo
    return ($null -ne $sys -and $sys.Contains("Hệ điều hành") -and $sys.Contains("Tên máy (Hostname)"))
}

# 3. Test OS Detection logic (Win10 vs Win11)
Assert-Test -Name "Xác định phiên bản Windows 10/11 chính xác" -TestBlock {
    return ($null -ne $global:TM_OS_INFO.Build -and $global:TM_OS_INFO.Build -gt 10000)
}

# 4. Test Logger & Secret Sanitization
Assert-Test -Name "Ghi Log có che giấu thông tin mật khẩu (Sanitization)" -TestBlock {
    $rawMsg = 'Tao tai khoan net user test "MySecretPassword123" /add'
    $sanitized = Sanitize-LogMessage -Message $rawMsg
    Write-TMLog -TaskId "TEST_LOG" -TaskName "Test Log" -Status "Info" -Message $rawMsg
    return ($sanitized -notmatch "MySecretPassword123")
}

# 5. Test Backup Session Manifest Creation
Assert-Test -Name "Tạo Backup Session & Manifest JSON" -TestBlock {
    $session = New-TMBackupSession -TaskId "TEST_BACKUP" -Description "Unit test backup session"
    $backupId = Save-TMBackupSession -Session $session
    $manifestFile = Join-Path $session.Directory "manifest.json"
    $valid = (Test-Path $manifestFile)
    
    # Cleanup test backup
    if (Test-Path $session.Directory) {
        Remove-Item -Path $session.Directory -Recurse -Force -ErrorAction SilentlyContinue
    }
    return $valid
}

# 6. Test Quick Commands Catalog Integrity
Assert-Test -Name "Kiểm tra tính toàn vẹn danh mục Quick Commands" -TestBlock {
    . (Join-Path $srcRoot "Modules/QuickCommands/QuickCommands.ps1")
    $cmds = Get-QuickCommandsList
    return ($cmds.Count -gt 15)
}

# 7. Test Optimization Profiles Catalog Integrity
Assert-Test -Name "Kiểm tra tính toàn vẹn hồ sơ Auto Optimize" -TestBlock {
    . (Join-Path $srcRoot "Modules/Optimization/Profiles.ps1")
    $profs = Get-OptimizationProfiles
    return ($profs.Count -ge 5)
}

Write-Host "---------------------------------------------------------" -ForegroundColor DarkGray
Write-Host " Kết quả: $passed passed, $failed failed." -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })
Write-Host "=========================================================" -ForegroundColor Cyan

if ($failed -gt 0) { exit 1 } else { exit 0 }
