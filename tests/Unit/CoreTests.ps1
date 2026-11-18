# TM-WinCare - Unit Tests for Core Modules
# Adheres to Section 15 of TM-WinCare-Architecture-v1.2.md

$testRoot = $PSScriptRoot
$srcRoot = Join-Path $testRoot "../../src"

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "              TM-WINCARE - CORE TEST SUITE              " -ForegroundColor White
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

Assert-Test -Name "Load Bootstrap & Application Configuration" -TestBlock {
    return ($null -ne $global:TM_CONFIG -and $global:TM_CONFIG.version -eq "1.2.0")
}

# 2. Test System Info Detection
Assert-Test -Name "Detect OS and Hardware Metrics via CIM" -TestBlock {
    $sys = Get-TMSystemInfo
    return ($null -ne $sys -and $sys.Contains("Operating System") -and $sys.Contains("Computer Name (Hostname)"))
}

# 3. Test OS Detection logic (Win10 vs Win11)
Assert-Test -Name "Verify Windows 10/11 Build Detection Logic" -TestBlock {
    return ($null -ne $global:TM_OS_INFO.Build -and $global:TM_OS_INFO.Build -gt 10000)
}

# 4. Test Logger & Secret Sanitization
Assert-Test -Name "Log Sanitization Redacts Passwords and Credentials" -TestBlock {
    $rawMsg = 'Create user net user test "MySecretPassword123" /add'
    $sanitized = Sanitize-LogMessage -Message $rawMsg
    Write-TMLog -TaskId "TEST_LOG" -TaskName "Test Log" -Status "Info" -Message $rawMsg
    return ($sanitized -notmatch "MySecretPassword123")
}

# 5. Test Backup Session Manifest Creation
Assert-Test -Name "Create Backup Session & Manifest JSON" -TestBlock {
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
Assert-Test -Name "Verify Quick Commands Catalog Integrity" -TestBlock {
    $catalogPath = Join-Path $testRoot "../../data/command-catalog/quick-commands.json"
    $cmds = Get-Content -Path $catalogPath -Raw -Encoding UTF8 | ConvertFrom-Json
    return ($cmds.Count -ge 10)
}

# 7. Test Optimization Profiles Catalog Integrity
Assert-Test -Name "Verify Optimization Profiles Catalog Integrity" -TestBlock {
    $profilesPath = Join-Path $testRoot "../../data/optimization-profiles/profiles.json"
    $profiles = Get-Content -Path $profilesPath -Raw -Encoding UTF8 | ConvertFrom-Json
    return ($profiles.Count -ge 5)
}

Write-Divider
Write-Host " Results: $passed passed, $failed failed." -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })
Write-Host "=========================================================" -ForegroundColor Cyan
if ($failed -gt 0) { exit 1 }
