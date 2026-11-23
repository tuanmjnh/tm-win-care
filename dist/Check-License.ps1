# TM-WinCare - License and IT Inventory Tool
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

# TM-WinCare - License and IT Inventory Tool
# Decodes Full 25-character Windows Key & Office Key, Mainboard Serial, UUID, Sync to Google Sheets / Form

function Invoke-LicenseInventoryCheck {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

    # ==================== GOOGLE SHEETS / FORM CONFIGURATION ====================
    $WEB_APP_URL      = "https://script.google.com/macros/s/AKfycbyY0fbv2IehFvC8oLCi9sFIYI_HHXNyF2WEfCBdKDOwkW-5MmjFyBacjqbHXfj4R5YI0w/exec"
    $GOOGLE_FORM_URL  = "https://docs.google.com/forms/d/e/1FAIpQLSfrIXm1b_mpo0A_L0Ns4IUOElJSeAqYcOYtMY6REThZP8phKQ/viewform"
    $PREFILL_TEMPLATE = "https://docs.google.com/forms/d/e/1FAIpQLSfrIXm1b_mpo0A_L0Ns4IUOElJSeAqYcOYtMY6REThZP8phKQ/viewform?usp=pp_url&entry.149006453=__TEN_MAY__&entry.2097722978=__UUID__&entry.172201661=__MODEL__&entry.218557984=__SERIAL__&entry.2007771510=__WIN_VER__&entry.901102999=Da+kich+hoat&entry.1856982139=__WIN_KEY__&entry.610740607=__OFF_VER__&entry.695594658=Da+kich+hoat&entry.1357205106=__OFF_KEY__&entry.1710584041=__GHI_CHU__"
    $GOOGLE_SHEET_URL = "https://docs.google.com/spreadsheets/d/1GsDhi-PbcJylNoSbZaXqtzF92ZCOe12LkASalCUdHQQ/edit"
    # ============================================================================

    function Get-RegistryProductKeyLocal($regPath) {
        try {
            $reg = Get-ItemProperty -Path $regPath -ErrorAction Stop
            $bin = $reg.DigitalProductId
            if (-not $bin) { return $null }
            $chars = "BCDFGHJKMPQRTVWXY2346789"
            $isWin8OrNewer = ([math]::Truncate($bin[66] / 6) -band 1)
            $bin[66] = ($bin[66] -band 0xF7) -bor (($isWin8OrNewer -band 2) * 4)
            $keyOutput = ""
            $last = 0
            for ($i = 24; $i -ge 0; $i--) {
                $cur = 0
                for ($j = 14; $j -ge 0; $j--) {
                    $cur = $cur * 256
                    $cur = $bin[$j + 52] + $cur
                    $bin[$j + 52] = [math]::Truncate($cur / 24)
                    $cur = $cur % 24
                }
                $keyOutput = $chars[$cur] + $keyOutput
                $last = $cur
            }
            if ($isWin8OrNewer -eq 1) {
                $keypart1 = $keyOutput.Substring(1, $last)
                $keypart2 = $keyOutput.Substring($last + 1, $keyOutput.Length - ($last + 1))
                $keyOutput = $keypart1 + "N" + $keypart2
            }
            return ($keyOutput -replace '(.{5})', '$1-').TrimEnd('-')
        } catch {
            return $null
        }
    }

    Write-Host "`n[*] Scanning hardware and decoding Windows & Office Product Keys..." -ForegroundColor Cyan

    $cs = Get-CimInstance Win32_ComputerSystemProduct -ErrorAction SilentlyContinue
    $bb = Get-CimInstance Win32_BaseBoard -ErrorAction SilentlyContinue
    $os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
    $sls = Get-CimInstance SoftwareLicensingService -ErrorAction SilentlyContinue

    # 1. Full Key Windows (Registry + Backup Key + BIOS OEM Key)
    $winRegKey = Get-RegistryProductKeyLocal "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    $winBackupKey = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" -ErrorAction SilentlyContinue).BackupProductKeyDefault
    $winOemKey = if ($sls) { $sls.OA3xOriginalProductKey } else { $null }

    $allLicProducts = @(Get-CimInstance SoftwareLicensingProduct -Filter "PartialProductKey IS NOT NULL" -ErrorAction SilentlyContinue)
    $winAllLic = $allLicProducts | Where-Object { $_.ApplicationID -eq '55c92734-d682-4d71-983e-d6ec3f16059f' } | Sort-Object LicenseStatus -Descending
    $winActiveLic = $winAllLic | Select-Object -First 1
    $winStatus = if ($winActiveLic -and $winActiveLic.LicenseStatus -eq 1) { "Activated" } else { "Unactivated" }
    $winPartial = if ($winActiveLic -and $winActiveLic.PartialProductKey) { $winActiveLic.PartialProductKey } else { "N/A" }

    $winFullList = @()
    if ($winRegKey) { $winFullList += "Active: $winRegKey" }
    if ($winBackupKey -and $winBackupKey -ne $winRegKey) { $winFullList += "Backup: $winBackupKey" }
    if ($winOemKey) { $winFullList += "OEM-BIOS: $winOemKey" }
    if ($winFullList.Count -eq 0) { $winFullList += "Last-5: $winPartial" }
    $winKeySummary = $winFullList -join " | "

    # 2. Key Office
    $offAllLic = @($allLicProducts | Where-Object { $_.Name -like '*Office*' })
    if ($offAllLic.Count -eq 0) {
        $offAllLic = @(Get-CimInstance OfficeSoftwareProtectionProduct -Filter "PartialProductKey IS NOT NULL" -ErrorAction SilentlyContinue)
    }

    $offRegKeys = @()
    $offRegPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Office\*\Registration\*",
        "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Office\*\Registration\*"
    )
    foreach ($p in $offRegPaths) {
        Get-ItemProperty -Path $p -ErrorAction SilentlyContinue | ForEach-Object {
            $k = Get-RegistryProductKeyLocal $_.PSPath
            if ($k -and ($offRegKeys -notcontains $k)) { $offRegKeys += $k }
        }
    }

    if ($offAllLic.Count -gt 0) {
        $offNames = @()
        $offStatuses = @()
        $offKeys = @()

        foreach ($item in ($offAllLic | Sort-Object LicenseStatus -Descending)) {
            $cleanName = ($item.Name -replace 'Office \d+, ', '' -replace ' edition', '' -replace 'Microsoft ', '').Trim()
            $st = if ($item.LicenseStatus -eq 1) { "Activated" } else { "Unactivated" }
            $pk = $item.PartialProductKey

            $matchedFull = $offRegKeys | Where-Object { $_ -like "*$pk" } | Select-Object -First 1
            $keyDisplay = if ($matchedFull) { $matchedFull } else { "XXXXX-$pk ($cleanName)" }

            $offNames += $cleanName
            $offStatuses += $st
            $offKeys += $keyDisplay
        }
        $offNameSummary = ($offNames | Select-Object -Unique) -join " | "
        $offStatusSummary = if ($offStatuses -contains "Activated") { "Activated" } else { "Unactivated" }
        $offKeySummary = $offKeys -join " | "
    } else {
        $offNameSummary = "Not Installed"
        $offStatusSummary = "Unactivated"
        $offKeySummary = "N/A"
    }

    $dataObj = [ordered]@{
        "Thoi_Gian_Check"   = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        "Ten_May"           = $env:COMPUTERNAME
        "UUID_Mainboard"    = if ($cs -and $cs.UUID) { $cs.UUID } else { "N/A" }
        "Model_Mainboard"   = if ($bb) { "$($bb.Manufacturer) $($bb.Product)".Trim() } else { "N/A" }
        "Serial_Mainboard"  = if ($bb -and $bb.SerialNumber) { $bb.SerialNumber } else { "N/A" }
        "Phien_Ban_Win"     = if ($os) { ($os.Caption -replace 'Microsoft ', '').Trim() } else { "Windows" }
        "Trang_Thai_Win"    = $winStatus
        "Key_Win_5_Cuoi"    = $winKeySummary
        "Phien_Ban_Office"  = $offNameSummary
        "Trang_Thai_Office" = $offStatusSummary
        "Key_Office_5_Cuoi" = $offKeySummary
        "Nguon_Nhap"        = "TM-WinCare"
        "Ghi_Chu"           = ""
        "Cap_Nhat_Trung"    = $true
    }

    function Show-TerminalInfoLocal {
        Write-Host "`n================ SYSTEM INVENTORY & LICENSE KEY OVERVIEW ================" -ForegroundColor Green
        Write-Host ("  Timestamp         : {0}" -f $dataObj.Thoi_Gian_Check)
        Write-Host ("  Computer Name     : {0}" -f $dataObj.Ten_May) -ForegroundColor Yellow
        Write-Host ("  UUID Mainboard    : {0}" -f $dataObj.UUID_Mainboard)
        Write-Host ("  Model Mainboard   : {0}" -f $dataObj.Model_Mainboard)
        Write-Host ("  Serial Mainboard  : {0}" -f $dataObj.Serial_Mainboard)
        Write-Host ("  Windows OS        : {0}" -f $dataObj.Phien_Ban_Win)
        Write-Host ("  Windows Status    : {0}" -f $dataObj.Trang_Thai_Win)
        Write-Host ("  Full Windows Key  : {0}" -f $dataObj.Key_Win_5_Cuoi) -ForegroundColor Cyan
        Write-Host ("  Office Edition    : {0}" -f $dataObj.Phien_Ban_Office)
        Write-Host ("  Office Status     : {0}" -f $dataObj.Trang_Thai_Office)
        Write-Host ("  Office Keys       : {0}" -f $dataObj.Key_Office_5_Cuoi) -ForegroundColor Cyan
        Write-Host "=========================================================================" -ForegroundColor Green
    }

    function Get-ExportFolder {
        if ($PSScriptRoot -and (Test-Path $PSScriptRoot)) {
            $logsDir = Join-Path $PSScriptRoot "../../../Logs"
            if (Test-Path $logsDir) { return $logsDir }
        }
        return [System.Environment]::GetFolderPath('Desktop')
    }

    function Export-ToFileLocal {
        $folder = Get-ExportFolder
        $csvPath = Join-Path $folder "IT_Inventory_List.csv"
        $txtPath = Join-Path $folder ("Info_" + $dataObj.Ten_May + ".txt")
        $jsonPath = Join-Path $folder ("Info_" + $dataObj.Ten_May + ".json")

        Write-Host "`nSelect export format (saving to $folder):" -ForegroundColor Cyan
        Write-Host "  [1] Append to CSV inventory table (IT_Inventory_List.csv)"
        Write-Host "  [2] Export detailed TXT report (Info_$($dataObj.Ten_May).txt)"
        Write-Host "  [3] Export JSON file (Info_$($dataObj.Ten_May).json)"
        $sub = Read-Host "Choice (1/2/3)"

        switch ($sub) {
            "1" {
                [PSCustomObject]$dataObj | Export-Csv -Path $csvPath -Append -NoTypeInformation -Encoding UTF8
                Write-Host "[+] Appended to CSV inventory: $csvPath" -ForegroundColor Green
            }
            "2" {
                $dataObj.GetEnumerator() | ForEach-Object { "{0,-20}: {1}" -f $_.Key, $_.Value } | Out-File -FilePath $txtPath -Encoding UTF8
                Write-Host "[+] Exported TXT report: $txtPath" -ForegroundColor Green
            }
            "3" {
                $dataObj | ConvertTo-Json | Out-File -FilePath $jsonPath -Encoding UTF8
                Write-Host "[+] Exported JSON: $jsonPath" -ForegroundColor Green
            }
            default { Write-Host "[!] Invalid selection." -ForegroundColor Red }
        }
    }

    function Send-ToGoogleSheetsLocal {
        $pin = Read-Host "Enter secret security PIN to authorize sync"
        $dataObj.Secret_PIN = $pin

        $note = Read-Host "`nEnter notes for this machine (Press Enter to skip)"
        $dataObj.Ghi_Chu = $note
        $payload = $dataObj | ConvertTo-Json -Compress

        Write-Host "[*] Syncing inventory data to Google Sheets..." -ForegroundColor Yellow
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $res = Invoke-RestMethod -Uri $WEB_APP_URL -Method Post -Body ([System.Text.Encoding]::UTF8.GetBytes($payload)) -ContentType "text/plain; charset=utf-8"
            if ($res.status -eq "updated") {
                Write-Host "[+] SUCCESS! Overwritten record on row #$($res.row) for $($dataObj.Ten_May) in Google Sheets." -ForegroundColor Green
            } elseif ($res.status -eq "inserted") {
                Write-Host "[+] SUCCESS! Added new entry for $($dataObj.Ten_May) to Google Sheets." -ForegroundColor Green
            } elseif ($res.status -eq "error") {
                Write-Host "[!] GOOGLE APPS SCRIPT ERROR: $($res.message)" -ForegroundColor Red
            } else {
                Write-Host "[+] Sent data! Response: $($res | ConvertTo-Json -Compress)" -ForegroundColor Green
            }
        } catch {
            Write-Host "[!] CONNECTION ERROR: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    function Open-GoogleFormLocal {
        Write-Host "`nSelect Google Form mode:" -ForegroundColor Cyan
        Write-Host "  [1] Open Google Form and copy device info to Clipboard"
        Write-Host "  [2] Open blank Google Form"
        $fChoice = Read-Host "Choice (1/2)"

        if ($fChoice -eq "1" -and $PREFILL_TEMPLATE -ne "") {
            $note = Read-Host "Enter additional notes for Form (Press Enter to skip)"
            $url = $PREFILL_TEMPLATE
            $url = $url.Replace("__TEN_MAY__", [uri]::EscapeDataString($dataObj.Ten_May))
            $url = $url.Replace("__UUID__", [uri]::EscapeDataString($dataObj.UUID_Mainboard))
            $url = $url.Replace("__MODEL__", [uri]::EscapeDataString($dataObj.Model_Mainboard))
            $url = $url.Replace("__SERIAL__", [uri]::EscapeDataString($dataObj.Serial_Mainboard))
            $url = $url.Replace("__WIN_VER__", [uri]::EscapeDataString($dataObj.Phien_Ban_Win))
            $url = $url.Replace("__WIN_KEY__", [uri]::EscapeDataString($dataObj.Key_Win_5_Cuoi))
            $url = $url.Replace("__OFF_VER__", [uri]::EscapeDataString($dataObj.Phien_Ban_Office))
            $url = $url.Replace("__OFF_KEY__", [uri]::EscapeDataString($dataObj.Key_Office_5_Cuoi))
            $url = $url.Replace("__GHI_CHU__", [uri]::EscapeDataString($note))

            $regex = [regex]"Da\+kich\+hoat|Da%20kich%20hoat"
            $url = $regex.Replace($url, [uri]::EscapeDataString($dataObj.Trang_Thai_Win), 1)
            $url = $regex.Replace($url, [uri]::EscapeDataString($dataObj.Trang_Thai_Office), 1)

            Write-Host "[*] Opening Google Form (prefilled with device specs)..." -ForegroundColor Green
            Start-Process $url
        } else {
            $clipText = "Computer: $($dataObj.Ten_May) | UUID: $($dataObj.UUID_Mainboard) | Main: $($dataObj.Model_Mainboard) | Serial: $($dataObj.Serial_Mainboard) | Win: $($dataObj.Phien_Ban_Win) ($($dataObj.Trang_Thai_Win) - $($dataObj.Key_Win_5_Cuoi)) | Office: $($dataObj.Phien_Ban_Office) ($($dataObj.Trang_Thai_Office) - $($dataObj.Key_Office_5_Cuoi))"
            Set-Clipboard -Value $clipText
            Write-Host "[+] Copied device information summary to Clipboard!" -ForegroundColor Cyan
            Start-Process $GOOGLE_FORM_URL
        }
    }

    Show-TerminalInfoLocal

    while ($true) {
        Write-Host "`n==================== LICENSE & INVENTORY MENU ====================" -ForegroundColor Cyan
        Write-Host "  [1] Display License & Hardware Information"
        Write-Host "  [2] Export Data to File (CSV / TXT / JSON)"
        Write-Host "  [3] Sync to Google Sheets (Direct API)"
        Write-Host "  [4] Open Google Form (Prefilled with Machine Info)"
        Write-Host "  [5] Open Google Sheets Inventory Spreadsheet"
        Write-Host "  [6] Run All: Export CSV + Sync Google Sheets"
        Write-Host "  [7] Activate Windows with Product Key (slmgr /ipk /ato)" -ForegroundColor Green
        Write-Host "  [8] Activate Microsoft Office with Product Key (ospp.vbs)" -ForegroundColor Green
        Write-Host "  [0] Return to Main Menu"
        Write-Host "==================================================================" -ForegroundColor Cyan
        $choice = Read-Host "Enter your choice (0-8)"

        switch ($choice) {
            "1" { Show-TerminalInfoLocal }
            "2" { Export-ToFileLocal }
            "3" { Send-ToGoogleSheetsLocal }
            "4" { Open-GoogleFormLocal }
            "5" {
                Write-Host "[*] Opening Google Sheets..." -ForegroundColor Green
                Start-Process $GOOGLE_SHEET_URL
            }
            "6" {
                $folder = Get-ExportFolder
                $csvPath = Join-Path $folder "IT_Inventory_List.csv"
                [PSCustomObject]$dataObj | Export-Csv -Path $csvPath -Append -NoTypeInformation -Encoding UTF8
                Write-Host "[+] Saved CSV record to: $csvPath" -ForegroundColor Green
                Send-ToGoogleSheetsLocal
            }
            "7" {
                if (Get-Command "Invoke-WindowsKeyActivation" -ErrorAction SilentlyContinue) {
                    Invoke-WindowsKeyActivation
                } else {
                    Write-Host "[!] Activation module not loaded in standalone mode." -ForegroundColor Yellow
                }
            }
            "8" {
                if (Get-Command "Invoke-OfficeKeyActivation" -ErrorAction SilentlyContinue) {
                    Invoke-OfficeKeyActivation
                } else {
                    Write-Host "[!] Activation module not loaded in standalone mode." -ForegroundColor Yellow
                }
            }
            "0" { return }
            default { Write-Host "[!] Please select between 0 and 8." -ForegroundColor Yellow }
        }
    }
}

Invoke-LicenseInventoryCheck
