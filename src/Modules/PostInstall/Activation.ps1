# TM-WinCare - Windows & Microsoft Office Activation Module
# Allows activating Windows and Office using genuine 25-character product keys
# Adheres to Section 3.2 & Section 11 of TM-WinCare-Architecture-v1.2.md

# Lightweight fallbacks for standalone execution
if (-not (Get-Command "Assert-Admin" -ErrorAction SilentlyContinue)) {
    function Assert-Admin { param($Action) return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) }
}
if (-not (Get-Command "Confirm-Action" -ErrorAction SilentlyContinue)) {
    function Confirm-Action { param($TaskName, $ImpactDescription, $RiskLevel) Write-Host "`nConfirm $TaskName? (Y/N): " -ForegroundColor Yellow -NoNewline; return ((Read-Host).Trim().ToUpper() -eq 'Y') }
}
if (-not (Get-Command "Write-Header" -ErrorAction SilentlyContinue)) {
    function Write-Header { param($Title) Write-Host "`n================ $Title ================" -ForegroundColor Cyan }
}
if (-not (Get-Command "Write-SubHeader" -ErrorAction SilentlyContinue)) {
    function Write-SubHeader { param($Title) Write-Host "`n--- $Title ---" -ForegroundColor Yellow }
}
if (-not (Get-Command "Write-Success" -ErrorAction SilentlyContinue)) {
    function Write-Success { param($Msg) Write-Host "[+] $Msg" -ForegroundColor Green }
}
if (-not (Get-Command "Write-InfoMessage" -ErrorAction SilentlyContinue)) {
    function Write-InfoMessage { param($Msg) Write-Host "[*] $Msg" -ForegroundColor Cyan }
}
if (-not (Get-Command "Write-WarningMessage" -ErrorAction SilentlyContinue)) {
    function Write-WarningMessage { param($Msg) Write-Host "[!] $Msg" -ForegroundColor Yellow }
}
if (-not (Get-Command "Write-ErrorMessage" -ErrorAction SilentlyContinue)) {
    function Write-ErrorMessage { param($Msg) Write-Host "[-] $Msg" -ForegroundColor Red }
}
if (-not (Get-Command "Write-SkipMessage" -ErrorAction SilentlyContinue)) {
    function Write-SkipMessage { param($Msg) Write-Host "[~] $Msg" -ForegroundColor DarkGray }
}
if (-not (Get-Command "Pause-Screen" -ErrorAction SilentlyContinue)) {
    function Pause-Screen { Write-Host "`nPress Enter to continue..." -ForegroundColor DarkGray; [void][Console]::ReadLine() }
}
if (-not (Get-Command "Write-TMLog" -ErrorAction SilentlyContinue)) {
    function Write-TMLog { param($TaskId, $TaskName, $Status, $Message) }
}
if (-not (Get-Command "Handle-TMException" -ErrorAction SilentlyContinue)) {
    function Handle-TMException { param($TaskId, $TaskName, $Exception) Write-Host "Error: $($Exception.Message)" -ForegroundColor Red }
}

function Find-OfficeOsppPath {
    <#
    .SYNOPSIS
        Locates the Microsoft Office Software Protection Platform script (ospp.vbs).
        Checks Click-To-Run and standard installations across 64-bit and 32-bit directories.
    #>
    $candidatePaths = @(
        # Office 2016 / 2019 / 2021 / 2024 / Microsoft 365 (Click-To-Run & MSI)
        (Join-Path $env:ProgramFiles "Microsoft Office\root\Office16\OSPP.VBS"),
        (Join-Path ${env:ProgramFiles(x86)} "Microsoft Office\root\Office16\OSPP.VBS"),
        (Join-Path $env:ProgramFiles "Microsoft Office\Office16\OSPP.VBS"),
        (Join-Path ${env:ProgramFiles(x86)} "Microsoft Office\Office16\OSPP.VBS"),

        # Office 2013 (v15)
        (Join-Path $env:ProgramFiles "Microsoft Office\root\Office15\OSPP.VBS"),
        (Join-Path ${env:ProgramFiles(x86)} "Microsoft Office\root\Office15\OSPP.VBS"),
        (Join-Path $env:ProgramFiles "Microsoft Office\Office15\OSPP.VBS"),
        (Join-Path ${env:ProgramFiles(x86)} "Microsoft Office\Office15\OSPP.VBS"),

        # Office 2010 (v14)
        (Join-Path $env:ProgramFiles "Microsoft Office\Office14\OSPP.VBS"),
        (Join-Path ${env:ProgramFiles(x86)} "Microsoft Office\Office14\OSPP.VBS")
    )

    foreach ($path in $candidatePaths) {
        if ($path -and (Test-Path $path)) {
            return $path
        }
    }

    # Fallback registry scan if installed in custom directory
    $regPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration",
        "HKLM:\SOFTWARE\Microsoft\Office\16.0\Common\InstallRoot",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\16.0\Common\InstallRoot",
        "HKLM:\SOFTWARE\Microsoft\Office\15.0\Common\InstallRoot",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Office\15.0\Common\InstallRoot"
    )

    foreach ($rp in $regPaths) {
        if (Test-Path $rp) {
            $val = (Get-ItemProperty -Path $rp -ErrorAction SilentlyContinue).Path
            if ($val) {
                $testOspp = Join-Path $val "OSPP.VBS"
                if (Test-Path $testOspp) { return $testOspp }
                $testRootOspp = Join-Path $val "root\Office16\OSPP.VBS"
                if (Test-Path $testRootOspp) { return $testRootOspp }
            }
        }
    }

    return $null
}

function Format-ProductKey {
    param ([string]$RawKey)
    if ([string]::IsNullOrWhiteSpace($RawKey)) { return $null }
    $clean = ($RawKey.Trim().ToUpper() -replace '[^A-Z0-9]', '')
    if ($clean.Length -ne 25) { return $null }
    return ($clean -replace '(.{5})', '$1-').TrimEnd('-')
}

function Invoke-WindowsKeyActivation {
    <#
    .SYNOPSIS
        Installs a 25-character Windows product key and activates Windows online.
    #>
    if (-not (Assert-Admin "activate Windows with product key")) {
        Pause-Screen
        return
    }

    Write-Header -Title "ACTIVATE WINDOWS WITH PRODUCT KEY"
    Write-InfoMessage "Using Microsoft Windows Software Licensing Management (slmgr.vbs)..."

    # Display current Windows edition and license status
    try {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
        Write-Host " Operating System : $($os.Caption)" -ForegroundColor Cyan
        Write-Host " Version / Build  : $($os.Version) (Build $($os.BuildNumber))" -ForegroundColor Gray
    } catch {}

    Write-Host "`nChecking current activation status..." -ForegroundColor Gray
    try {
        $statusOutput = & cscript.exe //nologo "$env:SystemRoot\System32\slmgr.vbs" /dli 2>&1
        $statusOutput | ForEach-Object { Write-Host "   $_" -ForegroundColor DarkGray }
    } catch {}

    Write-Host ""
    Write-Host "---------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host " Enter 25-character Windows Product Key" -ForegroundColor Yellow
    Write-Host " Format: XXXXX-XXXXX-XXXXX-XXXXX-XXXXX" -ForegroundColor DarkGray
    Write-Host " (Hyphens are optional; you can paste directly)" -ForegroundColor DarkGray
    Write-Host " Key: " -ForegroundColor Cyan -NoNewline
    $inputKey = Read-Host

    $formattedKey = Format-ProductKey -RawKey $inputKey
    if (-not $formattedKey) {
        Write-ErrorMessage "Invalid Product Key format. A valid Windows key must consist of exactly 25 alphanumeric characters."
        Pause-Screen
        return
    }

    $maskedKey = $formattedKey.Substring(0, 5) + "-XXXXX-XXXXX-XXXXX-" + $formattedKey.Substring(24, 5)
    Write-Host ""
    Write-InfoMessage "Product Key to install: $maskedKey"

    $confirmed = Confirm-Action -TaskName "Activate Windows" -ImpactDescription "Install product key ($maskedKey) and connect to Microsoft Activation Servers to activate this Windows PC." -RiskLevel "medium"
    if (-not $confirmed) {
        Write-SkipMessage "Windows activation cancelled."
        Pause-Screen
        return
    }

    Write-SubHeader "STEP 1/2: INSTALLING PRODUCT KEY (slmgr.vbs /ipk)"
    try {
        $ipkResult = & cscript.exe //nologo "$env:SystemRoot\System32\slmgr.vbs" /ipk $formattedKey 2>&1
        $ipkText = ($ipkResult | Out-String).Trim()
        Write-Host $ipkText -ForegroundColor White

        if ($ipkText -match "Error" -or $ipkText -match "0x") {
            Write-ErrorMessage "Failed to install product key: $ipkText"
            Write-TMLog -TaskId "ACT_WIN_IPK" -TaskName "Install Windows Key" -Status "Failed" -Message "Error installing key: $maskedKey"
            Pause-Screen
            return
        }
        Write-Success "Product key installed successfully into Windows licensing store."
        Write-TMLog -TaskId "ACT_WIN_IPK" -TaskName "Install Windows Key" -Status "Success" -Message "Key installed: $maskedKey"
    } catch {
        Handle-TMException -TaskId "ACT_WIN_IPK" -TaskName "Install Windows Key" -Exception $_.Exception
        Pause-Screen
        return
    }

    Write-SubHeader "STEP 2/2: ONLINE ACTIVATION (slmgr.vbs /ato)"
    try {
        $atoResult = & cscript.exe //nologo "$env:SystemRoot\System32\slmgr.vbs" /ato 2>&1
        $atoText = ($atoResult | Out-String).Trim()
        Write-Host $atoText -ForegroundColor White

        if ($atoText -match "Product activated successfully" -or $atoText -match "thành công" -or $atoText -notmatch "Error") {
            Write-Success "WINDOWS HAS BEEN ACTIVATED SUCCESSFULLY!"
            Write-TMLog -TaskId "ACT_WIN_ATO" -TaskName "Activate Windows" -Status "Success" -Message "Activated with $maskedKey"
        } else {
            Write-WarningMessage "Activation server returned: $atoText"
            Write-TMLog -TaskId "ACT_WIN_ATO" -TaskName "Activate Windows" -Status "Warning" -Message "$atoText"
        }

        # Check expiration date (/xpr)
        Write-Host "`nDetailed Activation Expiration Status:" -ForegroundColor Cyan
        $xprResult = & cscript.exe //nologo "$env:SystemRoot\System32\slmgr.vbs" /xpr 2>&1
        $xprResult | ForEach-Object { Write-Host "   $_" -ForegroundColor Green }
    } catch {
        Handle-TMException -TaskId "ACT_WIN_ATO" -TaskName "Activate Windows" -Exception $_.Exception
    }

    Pause-Screen
}

function Invoke-OfficeKeyActivation {
    <#
    .SYNOPSIS
        Installs a 25-character Office product key and activates Microsoft Office via ospp.vbs.
    #>
    if (-not (Assert-Admin "activate Microsoft Office with product key")) {
        Pause-Screen
        return
    }

    Write-Header -Title "ACTIVATE MICROSOFT OFFICE WITH PRODUCT KEY"
    Write-InfoMessage "Scanning system for Microsoft Office Software Protection Platform (ospp.vbs)..."

    $ospp = Find-OfficeOsppPath
    if (-not $ospp) {
        Write-WarningMessage "Could not automatically locate 'ospp.vbs' in standard Microsoft Office folders."
        Write-Host " Enter custom path to ospp.vbs (or directory containing ospp.vbs): " -ForegroundColor Cyan -NoNewline
        $customPath = Read-Host
        if ($customPath -and (Test-Path $customPath)) {
            if ($customPath -like "*ospp.vbs*") {
                $ospp = $customPath
            } else {
                $testInDir = Join-Path $customPath "ospp.vbs"
                if (Test-Path $testInDir) { $ospp = $testInDir }
            }
        }
    }

    if (-not $ospp -or -not (Test-Path $ospp)) {
        Write-ErrorMessage "Microsoft Office installation script (ospp.vbs) not found."
        Write-Host " Please ensure Microsoft Office (2010, 2013, 2016, 2019, 2021, 2024 or 365) is installed on this PC." -ForegroundColor Yellow
        Pause-Screen
        return
    }

    Write-Success "Detected Office Licensing Script: $ospp"

    Write-Host "`nQuerying current Office license status..." -ForegroundColor Gray
    try {
        $curStatus = & cscript.exe //nologo $ospp /dstatus 2>&1
        $curStatus | ForEach-Object { Write-Host "   $_" -ForegroundColor DarkGray }
    } catch {}

    Write-Host ""
    Write-Host "---------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host " Enter 25-character Microsoft Office Product Key" -ForegroundColor Yellow
    Write-Host " Format: XXXXX-XXXXX-XXXXX-XXXXX-XXXXX" -ForegroundColor DarkGray
    Write-Host " (Hyphens are optional; you can paste directly)" -ForegroundColor DarkGray
    Write-Host " Key: " -ForegroundColor Cyan -NoNewline
    $inputKey = Read-Host

    $formattedKey = Format-ProductKey -RawKey $inputKey
    if (-not $formattedKey) {
        Write-ErrorMessage "Invalid Product Key format. A valid Office key must consist of exactly 25 alphanumeric characters."
        Pause-Screen
        return
    }

    $maskedKey = $formattedKey.Substring(0, 5) + "-XXXXX-XXXXX-XXXXX-" + $formattedKey.Substring(24, 5)
    Write-Host ""
    Write-InfoMessage "Office Product Key to install: $maskedKey"

    $confirmed = Confirm-Action -TaskName "Activate Microsoft Office" -ImpactDescription "Install product key ($maskedKey) via ospp.vbs and activate Office." -RiskLevel "medium"
    if (-not $confirmed) {
        Write-SkipMessage "Office activation cancelled."
        Pause-Screen
        return
    }

    Write-SubHeader "STEP 1/2: INSTALLING OFFICE PRODUCT KEY (/inpkey)"
    try {
        $inpResult = & cscript.exe //nologo $ospp /inpkey:$formattedKey 2>&1
        $inpText = ($inpResult | Out-String).Trim()
        Write-Host $inpText -ForegroundColor White

        if ($inpText -match "<Product key installation successful>") {
            Write-Success "Office product key successfully installed!"
            Write-TMLog -TaskId "ACT_OFF_INPKEY" -TaskName "Install Office Key" -Status "Success" -Message "Key installed: $maskedKey"
        } else {
            Write-WarningMessage "Notice from ospp.vbs: $inpText"
            Write-TMLog -TaskId "ACT_OFF_INPKEY" -TaskName "Install Office Key" -Status "Warning" -Message "$inpText"
        }
    } catch {
        Handle-TMException -TaskId "ACT_OFF_INPKEY" -TaskName "Install Office Key" -Exception $_.Exception
        Pause-Screen
        return
    }

    Write-SubHeader "STEP 2/2: ACTIVATING OFFICE ONLINE (/act)"
    try {
        $actResult = & cscript.exe //nologo $ospp /act 2>&1
        $actText = ($actResult | Out-String).Trim()
        Write-Host $actText -ForegroundColor White

        if ($actText -match "<Product activation successful>") {
            Write-Success "MICROSOFT OFFICE HAS BEEN ACTIVATED SUCCESSFULLY!"
            Write-TMLog -TaskId "ACT_OFF_ACT" -TaskName "Activate Office" -Status "Success" -Message "Activated successfully with $maskedKey"
        } else {
            Write-WarningMessage "Office activation result: $actText"
            Write-TMLog -TaskId "ACT_OFF_ACT" -TaskName "Activate Office" -Status "Warning" -Message "$actText"
        }

        # Show updated status
        Write-Host "`nUpdated Office License Status (/dstatus):" -ForegroundColor Cyan
        $newStatus = & cscript.exe //nologo $ospp /dstatus 2>&1
        $newStatus | ForEach-Object {
            if ($_ -match "LICENSE STATUS:\s+---LICENSED---") {
                Write-Host "   $_" -ForegroundColor Green
            } else {
                Write-Host "   $_" -ForegroundColor Gray
            }
        }
    } catch {
        Handle-TMException -TaskId "ACT_OFF_ACT" -TaskName "Activate Office" -Exception $_.Exception
    }

    Pause-Screen
}

function Show-WindowsActivationDetailedStatus {
    Write-SubHeader "WINDOWS DETAILED ACTIVATION STATUS"
    Write-InfoMessage "Querying Windows licensing status via slmgr.vbs..."
    try {
        Write-Host "--> Detailed License Information (/dli):" -ForegroundColor Cyan
        & cscript.exe //nologo "$env:SystemRoot\System32\slmgr.vbs" /dli 2>&1 | ForEach-Object {
            Write-Host "   $_" -ForegroundColor White
        }

        Write-Host "`n--> Expiration Date Status (/xpr):" -ForegroundColor Cyan
        & cscript.exe //nologo "$env:SystemRoot\System32\slmgr.vbs" /xpr 2>&1 | ForEach-Object {
            Write-Host "   $_" -ForegroundColor Green
        }
    } catch {
        Write-ErrorMessage "Failed to query slmgr.vbs: $($_.Exception.Message)"
    }
    Pause-Screen
}

function Show-OfficeActivationDetailedStatus {
    Write-SubHeader "MICROSOFT OFFICE DETAILED ACTIVATION STATUS"
    $ospp = Find-OfficeOsppPath
    if (-not $ospp) {
        Write-ErrorMessage "Microsoft Office ospp.vbs not found on this system."
        Pause-Screen
        return
    }

    Write-InfoMessage "Querying Office license status via: $ospp (/dstatus)..."
    try {
        & cscript.exe //nologo $ospp /dstatus 2>&1 | ForEach-Object {
            if ($_ -match "LICENSE STATUS:\s+---LICENSED---") {
                Write-Host "   $_" -ForegroundColor Green
            } elseif ($_ -match "ERROR CODE:" -or $_ -match "LICENSE STATUS:\s+---NOTIFICATIONS---") {
                Write-Host "   $_" -ForegroundColor Yellow
            } else {
                Write-Host "   $_" -ForegroundColor Gray
            }
        }
    } catch {
        Write-ErrorMessage "Failed to execute ospp.vbs: $($_.Exception.Message)"
    }
    Pause-Screen
}

function Invoke-UninstallOfficeKey {
    if (-not (Assert-Admin "uninstall Office product key")) {
        Pause-Screen
        return
    }

    Write-SubHeader "UNINSTALL OBSOLETE OFFICE PRODUCT KEY (/unpkey)"
    $ospp = Find-OfficeOsppPath
    if (-not $ospp) {
        Write-ErrorMessage "Microsoft Office ospp.vbs not found."
        Pause-Screen
        return
    }

    Write-InfoMessage "Existing installed Office keys (/dstatus):"
    $statusLines = & cscript.exe //nologo $ospp /dstatus 2>&1
    $keysFound = @()
    foreach ($line in $statusLines) {
        if ($line -match "Last 5 characters of installed product key:\s+([A-Z0-9]{5})") {
            $keysFound += $matches[1]
            Write-Host "   Found Key Suffix: $($matches[1])" -ForegroundColor Cyan
        }
    }

    if ($keysFound.Count -eq 0) {
        Write-InfoMessage "No partial Office keys detected in licensing store."
        Pause-Screen
        return
    }

    Write-Host "`nEnter the LAST 5 CHARACTERS of the Office key to remove (e.g. $($keysFound[0])): " -ForegroundColor Cyan -NoNewline
    $last5 = Read-Host
    $last5 = ($last5.Trim().ToUpper() -replace '[^A-Z0-9]', '')
    if ($last5.Length -ne 5) {
        Write-ErrorMessage "Invalid input. Must be exactly the last 5 characters of the product key."
        Pause-Screen
        return
    }

    $confirmed = Confirm-Action -TaskName "Uninstall Office Key" -ImpactDescription "Remove product key ending in '$last5' from Office licensing store." -RiskLevel "medium"
    if ($confirmed) {
        try {
            $unpResult = & cscript.exe //nologo $ospp /unpkey:$last5 2>&1
            Write-Host ($unpResult | Out-String).Trim() -ForegroundColor White
            Write-Success "Key ending in '$last5' uninstalled from Office."
            Write-TMLog -TaskId "ACT_OFF_UNPKEY" -TaskName "Uninstall Office Key" -Status "Success" -Message "Removed key suffix $last5"
        } catch {
            Handle-TMException -TaskId "ACT_OFF_UNPKEY" -TaskName "Uninstall Office Key" -Exception $_.Exception
        }
    }
    Pause-Screen
}

function Invoke-UninstallWindowsKey {
    if (-not (Assert-Admin "uninstall Windows product key")) {
        Pause-Screen
        return
    }

    Write-SubHeader "UNINSTALL WINDOWS PRODUCT KEY (slmgr.vbs /upk & /cpky)"
    Write-WarningMessage "This will uninstall the currently installed Windows product key and clear it from the registry."

    $confirmed = Confirm-Action -TaskName "Uninstall Windows Key" -ImpactDescription "Remove Windows product key (/upk) and clear from registry (/cpky). Windows will revert to unactivated/notification state." -RiskLevel "high" -RequiresKeyword $true
    if ($confirmed) {
        try {
            $upkResult = & cscript.exe //nologo "$env:SystemRoot\System32\slmgr.vbs" /upk 2>&1
            Write-Host ($upkResult | Out-String).Trim() -ForegroundColor White

            $cpkyResult = & cscript.exe //nologo "$env:SystemRoot\System32\slmgr.vbs" /cpky 2>&1
            Write-Host ($cpkyResult | Out-String).Trim() -ForegroundColor White

            Write-Success "Windows product key uninstalled and cleared from registry."
            Write-TMLog -TaskId "ACT_WIN_UPK" -TaskName "Uninstall Windows Key" -Status "Success" -Message "Key uninstalled and cleared"
        } catch {
            Handle-TMException -TaskId "ACT_WIN_UPK" -TaskName "Uninstall Windows Key" -Exception $_.Exception
        }
    }
    Pause-Screen
}

function Show-TMActivationMenu {
    $menuItems = @(
        @{ Label = "Activate Windows with 25-character Product Key (slmgr /ipk /ato)"; Action = { Invoke-WindowsKeyActivation } },
        @{ Label = "Activate Microsoft Office with 25-character Product Key (ospp.vbs /act)"; Action = { Invoke-OfficeKeyActivation } },
        @{ Label = "View Detailed Windows Activation Status (slmgr /dli, /xpr)"; Action = { Show-WindowsActivationDetailedStatus } },
        @{ Label = "View Detailed Office Activation Status (ospp.vbs /dstatus)"; Action = { Show-OfficeActivationDetailedStatus } },
        @{ Label = "Uninstall Obsolete Office Key Fragment (ospp.vbs /unpkey)"; Action = { Invoke-UninstallOfficeKey } },
        @{ Label = "Uninstall Current Windows Product Key (slmgr /upk, /cpky)"; Action = { Invoke-UninstallWindowsKey } },
        @{ Label = "Windows & Office License Inventory Tool (Full Keys & Cloud Sync)"; Action = { Invoke-LicenseInventoryCheck } },
        @{ Label = "Open Windows Activation Settings GUI (ms-settings:activation)"; Action = { Start-Process "ms-settings:activation" } }
    )
    Show-TMMenu -Title "WINDOWS & MICROSOFT OFFICE PRODUCT ACTIVATION" -MenuItems $menuItems -ExitLabel "Back"
}
