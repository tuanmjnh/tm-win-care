# TM-WinCare - Printer Support Module
# Adheres to Section 4 & Section 5 of TM-WinCare-Architecture-v1.2.md

function Show-TMPrinterMenu {
    $menuItems = @(
        @{ Label = "List Installed Printers & Driver Status"; Action = { Show-InstalledPrinters } },
        @{ Label = "Open Windows Printers & Scanners Settings"; Action = { Start-Process "ms-settings:printers" } },
        @{ Label = "Open Classic Devices and Printers (Control Panel)"; Action = { Start-Process "control.exe" "printers" } },
        @{ Label = "Open Print Server Driver Properties (printui /s /t2)"; Action = { Start-Process "rundll32.exe" "printui.dll,PrintUIEntry /s /t2" } },
        @{ Label = "Restart Print Spooler Service"; Action = { Invoke-RestartSpooler } },
        @{ Label = "Clear Stuck Print Spool Queue Files"; Action = { Invoke-ClearPrintQueue } },
        @{ Label = "Test Print Spooler Health & Service Status"; Action = { Test-PrintSpoolerHealth } },
        @{ Label = "Test Network Shared Printer Path (UNC Connectivity)"; Action = { Test-SharedPrinterConnection } },
        @{ Label = "Create Scan-to-Folder Local Account"; Action = { Invoke-CreateScanAccount } },
        @{ Label = "Host Printer Sharing Setup Guide & Tools"; Action = { Show-HostPrinterGuide } },
        @{ Label = "Client Printer Connection Guide & Tools"; Action = { Show-ClientPrinterGuide } },
        @{ Label = "Local Port Helper for Shared Network Printers (\\Server\\Share)"; Action = { Show-LocalPortHelper } },
        @{ Label = "Troubleshoot Access Denied & 0x0000011b / 0x00000709 Errors"; Action = { Show-PrinterAccessDeniedGuide } },
        @{ Label = "Export Printer Configuration Report to TXT"; Action = { Export-PrinterReport } }
    )
    Show-TMMenu -Title "PRINTER & PRINT SPOOLER SUPPORT" -MenuItems $menuItems -ExitLabel "Back"
}

function Show-InstalledPrinters {
    Write-SubHeader "INSTALLED PRINTERS ON THIS SYSTEM"
    try {
        $printers = Get-Printer -ErrorAction Stop
        if (-not $printers -or @($printers).Count -eq 0) {
            Write-InfoMessage "No printers currently installed on this system."
        } else {
            $list = @()
            foreach ($p in $printers) {
                $list += [PSCustomObject]@{
                    PrinterName = $p.Name
                    Driver = $p.DriverName
                    Port = $p.PortName
                    Shared = if ($p.Shared) { "Yes ($($p.ShareName))" } else { "No" }
                    Status = $p.PrinterStatus.ToString()
                }
            }
            $headers = @("Printer Name", "Driver", "Port Name", "Shared", "Status")
            $props = @("PrinterName", "Driver", "Port", "Shared", "Status")
            $widths = @(25, 25, 15, 12, 10)
            Show-TableList -Items $list -Headers $headers -PropertyNames $props -Widths $widths
        }
    } catch {
        Handle-TMException -TaskId "PRINT_LIST" -TaskName "List Printers" -Exception $_.Exception
    }
    Pause-Screen
}

function Invoke-RestartSpooler {
    if (-not (Assert-Admin "restart Print Spooler")) { Pause-Screen; return }

    Write-SubHeader "RESTART PRINT SPOOLER SERVICE"
    try {
        Write-InfoMessage "Stopping Spooler service..."
        Stop-Service -Name Spooler -Force -ErrorAction Stop
        Start-Sleep -Milliseconds 800
        
        Write-InfoMessage "Starting Spooler service..."
        Start-Service -Name Spooler -ErrorAction Stop
        Start-Sleep -Milliseconds 800

        $svc = Get-Service -Name Spooler
        if ($svc.Status -eq "Running") {
            Write-Success "Print Spooler service restarted and running normally!"
            Write-TMLog -TaskId "PRINT_RESTART_SPOOLER" -TaskName "Restart Spooler" -Status "Success" -Message "Success"
        } else {
            Write-ErrorMessage "Spooler service status: $($svc.Status)"
        }
    } catch {
        Handle-TMException -TaskId "PRINT_RESTART_SPOOLER" -TaskName "Restart Spooler" -Exception $_.Exception
    }
    Pause-Screen
}

function Invoke-ClearPrintQueue {
    if (-not (Assert-Admin "clear stuck print queue")) { Pause-Screen; return }

    Write-SubHeader "PURGE STUCK PRINT JOBS (CLEAR SPOOL QUEUE)"
    $spoolPath = Join-Path $env:SystemRoot "System32\spool\PRINTERS"

    $confirmed = Confirm-Action -TaskName "Purge Stuck Print Jobs" -ImpactDescription "Stops Spooler, deletes all pending .SPL/.SHD files in $spoolPath, and restarts Spooler." -RiskLevel "medium"
    if (-not $confirmed) { Pause-Screen; return }

    try {
        Write-InfoMessage "1. Stopping Print Spooler service..."
        Stop-Service -Name Spooler -Force -ErrorAction Stop
        Start-Sleep -Milliseconds 500

        Write-InfoMessage "2. Purging temporary spool job files in $spoolPath..."
        $files = Get-ChildItem -Path $spoolPath -File -ErrorAction SilentlyContinue
        $deleted = 0
        foreach ($f in $files) {
            try {
                Remove-Item $f.FullName -Force -ErrorAction Stop
                $deleted++
            } catch {}
        }
        Write-Success "Deleted $deleted stuck spool file(s)."

        Write-InfoMessage "3. Restarting Print Spooler service..."
        Start-Service -Name Spooler -ErrorAction Stop
        Start-Sleep -Milliseconds 500

        $svc = Get-Service -Name Spooler
        if ($svc.Status -eq "Running") {
            Write-Success "Print spool queue cleared and Spooler service resumed!"
            Write-TMLog -TaskId "PRINT_CLEAR_QUEUE" -TaskName "Clear Spool Queue" -Status "Success" -Message "Purged $deleted print jobs"
        }
    } catch {
        Handle-TMException -TaskId "PRINT_CLEAR_QUEUE" -TaskName "Clear Spool Queue" -Exception $_.Exception
    }
    Pause-Screen
}

function Test-PrintSpoolerHealth {
    Write-SubHeader "PRINT SPOOLER HEALTH & DIAGNOSTICS"
    try {
        $svc = Get-Service -Name Spooler -ErrorAction Stop
        Write-Host "  Service Name  : $($svc.ServiceName) ($($svc.DisplayName))" -ForegroundColor Cyan
        Write-Host "  Current Status: $($svc.Status)" -ForegroundColor $(if ($svc.Status -eq "Running") { "Green" } else { "Red" })

        $cim = Get-CimInstance Win32_Service -Filter "Name='Spooler'" -ErrorAction SilentlyContinue
        if ($cim) {
            Write-Host "  Startup Mode  : $($cim.StartMode)" -ForegroundColor White
            Write-Host "  Process PID   : $($cim.ProcessId)" -ForegroundColor White
        }

        # Check Spool folder size
        $spoolPath = Join-Path $env:SystemRoot "System32\spool\PRINTERS"
        if (Test-Path $spoolPath) {
            $files = Get-ChildItem -Path $spoolPath -File -ErrorAction SilentlyContinue
            Write-Host "  Pending Jobs  : $(@($files).Count) file(s)" -ForegroundColor $(if (@($files).Count -gt 0) { "Yellow" } else { "Green" })
        }
    } catch {
        Handle-TMException -TaskId "PRINT_HEALTH" -TaskName "Inspect Spooler" -Exception $_.Exception
    }
    Pause-Screen
}

function Test-SharedPrinterConnection {
    Write-SubHeader "TEST NETWORK SHARED PRINTER PATH (UNC)"
    Write-Host " Enter printer UNC path (e.g. \\SERVER-NAME\PrinterShare or \\192.168.1.100\PrinterShare): " -ForegroundColor Cyan -NoNewline
    $unc = Read-Host
    if ([string]::IsNullOrWhiteSpace($unc) -or -not ($unc.StartsWith("\\"))) {
        Write-ErrorMessage "Invalid path format. Must begin with \\ (e.g. \\Server\Printer)."
        Pause-Screen
        return
    }

    $parts = $unc.TrimStart('\').Split('\')
    $serverName = $parts[0]

    Write-InfoMessage "1. Testing name resolution & TCP 445 (SMB) connection to host $serverName..."
    $testSmb = Test-NetConnection -ComputerName $serverName -Port 445 -WarningAction SilentlyContinue
    if ($testSmb.TcpTestSucceeded) {
        Write-Success "Host $serverName is listening on SMB sharing port (TCP 445)."
    } else {
        Write-WarningMessage "Unable to reach SMB port on $serverName. Check IP address, hostname, or firewall rules."
    }

    Write-InfoMessage "2. Verifying accessibility of share path $unc..."
    if (Test-Path -LiteralPath $unc -ErrorAction SilentlyContinue) {
        Write-Success "Shared path $unc is accessible!"
    } else {
        Write-WarningMessage "Cannot access $unc directly. Authentication credentials in Credential Manager may be required."
    }
    Pause-Screen
}

function Invoke-CreateScanAccount {
    if (-not (Assert-Admin "create scan account")) { Pause-Screen; return }

    Write-SubHeader "CREATE DEDICATED SCAN-TO-FOLDER LOCAL ACCOUNT"
    Write-InfoMessage "Local account used by multi-function printers to deliver scanned files over SMB."
    Write-Host ""
    Write-Host " Enter account name (default 'scan'): " -ForegroundColor Cyan -NoNewline
    $uName = Read-Host
    if ([string]::IsNullOrWhiteSpace($uName)) { $uName = "scan" }

    # Check if user already exists
    if (Test-CmdletAvailable "Get-LocalUser") {
        $existing = Get-LocalUser -Name $uName -ErrorAction SilentlyContinue
        if ($existing) {
            Write-WarningMessage "Account '$uName' already exists on this computer!"
            Pause-Screen
            return
        }
    }

    # Secure Password Input
    Write-Host " Enter password for account '$uName': " -ForegroundColor Cyan -NoNewline
    $secPass1 = Read-Host -AsSecureString
    Write-Host " Confirm password: " -ForegroundColor Cyan -NoNewline
    $secPass2 = Read-Host -AsSecureString

    # Validate passwords match
    $bstr1 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secPass1)
    $bstr2 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secPass2)
    $plain1 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr1)
    $plain2 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr2)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr1)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr2)

    if ($plain1 -ne $plain2) {
        Write-ErrorMessage "Passwords do not match. Action cancelled."
        Pause-Screen
        return
    }
    if ([string]::IsNullOrWhiteSpace($plain1)) {
        Write-ErrorMessage "Password cannot be empty."
        Pause-Screen
        return
    }

    Write-Host " Set password to never expire (PasswordNeverExpires)? (Y/N): " -ForegroundColor Cyan -NoNewline
    $pneAns = Read-Host
    $neverExpires = ($pneAns.Trim().ToUpper() -eq "Y")

    $confirmed = Confirm-Action -TaskName "Create scan account '$uName'" -ImpactDescription "Create dedicated local user '$uName' for printer scan delivery. Password is fully secured." -RiskLevel "medium"
    if ($confirmed) {
        try {
            if (Test-CmdletAvailable "New-LocalUser") {
                New-LocalUser -Name $uName -Password $secPass1 -Description "Dedicated Scan-to-folder service account" -PasswordNeverExpires:$neverExpires -ErrorAction Stop
            } else {
                & net.exe user "$uName" "$plain1" /add /comment:"Scan to folder account"
            }
            Write-Success "Account '$uName' successfully created!"
            Write-InfoMessage "Now grant '$uName' permissions to your shared scan destination folder (e.g. D:\Scan)."
            Write-TMLog -TaskId "PRINT_SCAN_USER" -TaskName "Create Scan User" -Status "Success" -Message "User: $uName"
        } catch {
            Handle-TMException -TaskId "PRINT_SCAN_USER" -TaskName "Create Scan User" -Exception $_.Exception
        }
    }
    Pause-Screen
}

function Show-HostPrinterGuide {
    Write-SubHeader "HOST PRINTER SHARING SETUP GUIDE (PRINT SERVER PC)"
    Write-Host " 1. Ensure the printer prints locally from the host PC without errors." -ForegroundColor White
    Write-Host " 2. Open Control Panel > Devices and Printers > Right-click printer > Printer Properties." -ForegroundColor White
    Write-Host " 3. In Sharing tab: Check 'Share this printer' and provide a concise share name (e.g. Canon2900)." -ForegroundColor White
    Write-Host " 4. In Security tab: Verify 'Everyone' group has 'Print' permissions." -ForegroundColor White
    Write-Host " 5. Open Advanced Sharing Settings: Verify 'Turn on file and printer sharing' is active." -ForegroundColor White
    Write-Host " 6. Record this host's Computer Name (Hostname) or static IP address." -ForegroundColor Cyan
    Pause-Screen
}

function Show-ClientPrinterGuide {
    Write-SubHeader "CLIENT PRINTER CONNECTION GUIDE (CLIENT PC)"
    Write-Host " 1. Open Credential Manager > Windows Credentials > Add a Windows credential:" -ForegroundColor White
    Write-Host "    - Network address: Enter host computer name or IP (e.g. \\HOST-PC)" -ForegroundColor Gray
    Write-Host "    - User name / Password: Enter valid credentials of the host computer." -ForegroundColor Gray
    Write-Host " 2. Press Win + R > Enter '\\HOST-PC' to view shared printer shares." -ForegroundColor White
    Write-Host " 3. Right-click the shared printer > Select 'Connect'." -ForegroundColor White
    Write-Host " 4. If an Access Denied or driver error occurs, use the 'Local Port Helper' option below." -ForegroundColor Cyan
    Pause-Screen
}

function Show-LocalPortHelper {
    Write-SubHeader "LOCAL PORT HELPER FOR SHARED NETWORK PRINTERS"
    Write-InfoMessage "A Local Port is the most reliable workaround when encountering RPC or driver install blocks."
    Write-Host ""
    Write-Host " Enter Host Computer Name or IP: " -ForegroundColor Cyan -NoNewline
    $server = Read-Host
    Write-Host " Enter Printer Share Name: " -ForegroundColor Cyan -NoNewline
    $share = Read-Host

    if ([string]::IsNullOrWhiteSpace($server) -or [string]::IsNullOrWhiteSpace($share)) {
        Write-ErrorMessage "Server and share name cannot be empty."
        Pause-Screen
        return
    }

    $portName = "\\$server\$share"
    Write-Success "Target Local Port string: $portName"
    Write-Host ""
    Write-Host " Setup steps in Windows:" -ForegroundColor Yellow
    Write-Host "  1. Open 'Devices and Printers' -> Click 'Add a printer'." -ForegroundColor White
    Write-Host "  2. Select 'The printer that I want isn't listed'." -ForegroundColor White
    Write-Host "  3. Select 'Add a local printer or network printer with manual settings' -> Next." -ForegroundColor White
    Write-Host "  4. Select 'Create a new port' -> Port type: 'Local Port' -> Next." -ForegroundColor White
    Write-Host "  5. Paste this exact string into Port Name: " -ForegroundColor White
    Write-Host "     $portName" -ForegroundColor Cyan
    Write-Host "  6. Select matching printer driver from vendor list or click Have Disk." -ForegroundColor White
    Write-Host ""
    Write-Host " Open Devices and Printers now? (Y/N): " -ForegroundColor Cyan -NoNewline
    $ans = Read-Host
    if ($ans.Trim().ToUpper() -eq "Y") {
        Start-Process "control.exe" "printers"
    }
    Pause-Screen
}

function Show-PrinterAccessDeniedGuide {
    Write-SubHeader "TROUBLESHOOTING ACCESS DENIED / 0x0000011b ERRORS (WIN 10 & 11)"
    Write-Host " Common root causes:" -ForegroundColor Yellow
    Write-Host "  - Windows Point and Print RPC hardening updates require elevated RPC authentication." -ForegroundColor Gray
    Write-Host "  - Client has not saved host credentials in Windows Credential Manager." -ForegroundColor Gray
    Write-Host "  - Windows 11 22H2+ enforces RPC over TCP while older servers use Named Pipes." -ForegroundColor Gray
    Write-Host ""
    Write-Host " Safe resolution sequence:" -ForegroundColor Cyan
    Write-Host "  1. Save host credentials into Credential Manager on the client PC." -ForegroundColor White
    Write-Host "  2. Pre-install identical printer driver version locally on client before connecting." -ForegroundColor White
    Write-Host "  3. Connect using Local Port (\\Server\Share) instead of automatic point-and-print." -ForegroundColor White
    Write-Host "  4. Restart Print Spooler on both host and client machines." -ForegroundColor White
    Pause-Screen
}

function Export-PrinterReport {
    Write-SubHeader "EXPORT PRINTER CONFIGURATION REPORT"
    $reportDir = Join-Path $PSScriptRoot "../../../Logs"
    $filename = "PrinterReport_" + (Get-Date).ToString("yyyyMMdd_HHmmss") + ".txt"
    $fullPath = Join-Path $reportDir $filename

    $lines = @()
    $lines += "========================================================="
    $lines += "         TM-WINCARE - PRINTER CONFIGURATION REPORT"
    $lines += "  Generated: " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $lines += "========================================================="
    try {
        $printers = Get-Printer
        foreach ($p in $printers) {
            $lines += "Printer: $($p.Name) | Driver: $($p.DriverName) | Port: $($p.PortName) | Shared: $($p.Shared)"
        }
    } catch {}
    $lines += "========================================================="
    Set-Content -Path $fullPath -Value $lines -Encoding UTF8 -Force
    Write-Success "Report exported to file: $fullPath"
    Pause-Screen
}
