# TM-WinCare - Network & LAN Support Module
# Adheres to Section 6 of TM-WinCare-Architecture-v1.2.md

function Show-TMNetworkMenu {
    $menuItems = @(
        @{ Label = "View Network Overview (IP, Gateway, DNS, MAC)"; Action = { Show-NetworkOverview } },
        @{ Label = "Run ipconfig /all (Detailed Adapter Metrics)"; Action = { & ipconfig.exe /all; Pause-Screen } },
        @{ Label = "Flush DNS Resolver Cache"; Action = { Clear-DnsClientCache; Write-Success "DNS Client Resolver Cache flushed successfully."; Pause-Screen } },
        @{ Label = "Renew DHCP IP Address (ipconfig /renew)"; Action = { & ipconfig.exe /renew; Pause-Screen } },
        @{ Label = "Ping Connectivity Test (Gateway / Target Host)"; Action = { Invoke-PingTest } },
        @{ Label = "DNS Hostname Lookup Test (nslookup / Resolve-DnsName)"; Action = { Invoke-DnsLookupTest } },
        @{ Label = "TCP Port Connectivity Test (Test-NetConnection)"; Action = { Invoke-TcpPortTest } },
        @{ Label = "Inspect SMB Client Security Configuration (Read-Only)"; Action = { Show-SmbConfiguration } },
        @{ Label = "Check Windows Firewall Rules for File & Printer Sharing"; Action = { Show-FirewallSharingRules } },
        @{ Label = "Open Network Connections (ncpa.cpl)"; Action = { Start-Process "ncpa.cpl" } },
        @{ Label = "Open Advanced Sharing Settings"; Action = { Start-Process "control.exe" "/name Microsoft.NetworkAndSharingCenter /page Advanced" } },
        @{ Label = "Open Windows Firewall (firewall.cpl)"; Action = { Start-Process "firewall.cpl" } },
        @{ Label = "Open Credential Manager (control credman)"; Action = { Start-Process "control.exe" "/name Microsoft.CredentialManager" } },
        @{ Label = "Export Network Diagnostic Report"; Action = { Export-NetworkReport } }
    )
    Show-TMMenu -Title "LOCAL NETWORK & LAN SUPPORT" -MenuItems $menuItems -ExitLabel "Back"
}

function Show-NetworkOverview {
    Write-SubHeader "ACTIVE NETWORK INTERFACES & IP CONFIGURATION"
    try {
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
        foreach ($ad in $adapters) {
            Write-Host " Interface : $($ad.Name) ($($ad.InterfaceDescription))" -ForegroundColor Cyan
            Write-Host "   MAC Address  : $($ad.MacAddress)" -ForegroundColor White
            Write-Host "   Link Speed   : $($ad.LinkSpeed)" -ForegroundColor White

            $ips = Get-NetIPAddress -InterfaceIndex $ad.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
            foreach ($ip in $ips) {
                Write-Host "   IPv4 Address : $($ip.IPAddress)/$($ip.PrefixLength)" -ForegroundColor Green
            }

            $routes = Get-NetRoute -InterfaceIndex $ad.InterfaceIndex -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue
            if ($routes) {
                Write-Host "   Default Gateway: $($routes[0].NextHop)" -ForegroundColor White
            }

            $dnsServers = (Get-DnsClientServerAddress -InterfaceIndex $ad.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue).ServerAddresses
            if ($dnsServers) {
                Write-Host "   DNS Servers  : $($dnsServers -join ', ')" -ForegroundColor White
            }
            Write-Host ""
        }
    } catch {
        Handle-TMException -TaskId "NET_OVERVIEW" -TaskName "View Network Config" -Exception $_.Exception
    }
    Pause-Screen
}

function Invoke-PingTest {
    Write-SubHeader "ICMP PING CONNECTIVITY TEST"
    Write-Host " Enter IP address or hostname to ping (default 8.8.8.8): " -ForegroundColor Cyan -NoNewline
    $target = Read-Host
    if ([string]::IsNullOrWhiteSpace($target)) { $target = "8.8.8.8" }

    Write-InfoMessage "Sending 4 ICMP echo requests to $target..."
    & ping.exe $target
    Pause-Screen
}

function Invoke-DnsLookupTest {
    Write-SubHeader "DNS NAME RESOLUTION TEST (NSLOOKUP)"
    Write-Host " Enter domain name or hostname to resolve (e.g. google.com): " -ForegroundColor Cyan -NoNewline
    $hostName = Read-Host
    if ([string]::IsNullOrWhiteSpace($hostName)) { $hostName = "google.com" }

    try {
        $res = Resolve-DnsName -Name $hostName -ErrorAction Stop
        $res | Select-Object Name, Type, IPAddress | Format-Table -AutoSize
    } catch {
        Write-ErrorMessage "Failed to resolve '$hostName': $($_.Exception.Message)"
    }
    Pause-Screen
}

function Invoke-TcpPortTest {
    Write-SubHeader "TCP PORT CONNECTIVITY TEST"
    Write-Host " Enter destination host or IP: " -ForegroundColor Cyan -NoNewline
    $dest = Read-Host
    if ([string]::IsNullOrWhiteSpace($dest)) {
        Write-ErrorMessage "Target address cannot be empty."
        Pause-Screen
        return
    }

    Write-Host " Enter TCP port number (e.g. 80, 443, 445 for SMB, 135 for RPC, 9100 for RAW printer): " -ForegroundColor Cyan -NoNewline
    $portStr = Read-Host
    if (-not ($portStr -match "^\d+$")) {
        Write-ErrorMessage "Invalid port number."
        Pause-Screen
        return
    }

    $port = [int]$portStr
    Write-InfoMessage "Testing TCP connection to $dest`:$port..."
    try {
        $test = Test-NetConnection -ComputerName $dest -Port $port -WarningAction SilentlyContinue
        if ($test.TcpTestSucceeded) {
            Write-Success "Connection to $dest`:$port SUCCEEDED!"
        } else {
            Write-ErrorMessage "Connection to $dest`:$port FAILED. Port may be closed or blocked by firewall."
        }
    } catch {
        Handle-TMException -TaskId "NET_PORT_TEST" -TaskName "Port Test" -Exception $_.Exception
    }
    Pause-Screen
}

function Show-SmbConfiguration {
    Write-SubHeader "SMB CLIENT SECURITY CONFIGURATION (READ-ONLY)"
    try {
        if (Test-CmdletAvailable "Get-SmbClientConfiguration") {
            $smb = Get-SmbClientConfiguration
            Write-Host "  RequireSecuritySignature (SMB Signing Mandatory): $($smb.RequireSecuritySignature)" -ForegroundColor $(if ($smb.RequireSecuritySignature) { "Green" } else { "Yellow" })
            Write-Host "  EnableInsecureGuestLogons (Insecure Guest Allowed): $($smb.EnableInsecureGuestLogons)" -ForegroundColor $(if ($smb.EnableInsecureGuestLogons) { "Red" } else { "Green" })
            Write-Host "  EnableSMB1Protocol (Deprecated SMBv1 Protocol):   $(if (Test-CmdletAvailable 'Get-WindowsOptionalFeature') { 'Queryable via Optional Features' } else { 'Not Available' })" -ForegroundColor Gray
            Write-Host ""
            Write-InfoMessage "Note: Keeping RequireSecuritySignature = True is official Microsoft security best practice."
        } else {
            Write-WarningMessage "Cmdlet Get-SmbClientConfiguration is unavailable on this edition."
        }
    } catch {
        Handle-TMException -TaskId "SMB_CONF" -TaskName "Inspect SMB" -Exception $_.Exception
    }
    Pause-Screen
}

function Show-FirewallSharingRules {
    Write-SubHeader "FIREWALL STATUS FOR FILE & PRINTER SHARING"
    try {
        $rules = Get-NetFirewallRule -DisplayGroup "*File and Printer Sharing*" -ErrorAction SilentlyContinue | Select-Object -First 5
        if ($rules) {
            foreach ($r in $rules) {
                $status = if ($r.Enabled -eq "True") { "[ENABLED]" } else { "[DISABLED]" }
                $color = if ($r.Enabled -eq "True") { "Green" } else { "Yellow" }
                Write-Host "  $status $($r.DisplayName)" -ForegroundColor $color
            }
        } else {
            Write-InfoMessage "No File and Printer Sharing rules detected."
        }
    } catch {
        Handle-TMException -TaskId "FW_RULES" -TaskName "Check Firewall Rules" -Exception $_.Exception
    }
    Pause-Screen
}

function Export-NetworkReport {
    Write-SubHeader "EXPORT NETWORK DIAGNOSTIC REPORT"
    $reportDir = Join-Path $PSScriptRoot "../../../Logs"
    $filename = "NetworkReport_" + (Get-Date).ToString("yyyyMMdd_HHmmss") + ".txt"
    $fullPath = Join-Path $reportDir $filename

    $lines = @()
    $lines += "========================================================="
    $lines += "         TM-WINCARE - NETWORK DIAGNOSTIC REPORT"
    $lines += "  Generated: " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $lines += "========================================================="
    try {
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
        foreach ($ad in $adapters) {
            $lines += "Adapter: $($ad.Name) | MAC: $($ad.MacAddress) | Speed: $($ad.LinkSpeed)"
        }
    } catch {}
    $lines += "========================================================="
    Set-Content -Path $fullPath -Value $lines -Encoding UTF8 -Force
    Write-Success "Report exported to file: $fullPath"
    Pause-Screen
}
