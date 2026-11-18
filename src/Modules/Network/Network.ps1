# TM-WinCare - Network & LAN Support Module
# Adheres to Section 6 of TM-WinCare-Architecture-v1.2.md

function Show-TMNetworkMenu {
    $menuItems = @(
        @{ Label = "Xem tổng quan IP, Gateway, DNS, MAC"; Action = { Show-NetworkOverview } },
        @{ Label = "Chạy ipconfig /all (Chi tiết cấu hình)"; Action = { & ipconfig.exe /all; Pause-Screen } },
        @{ Label = "Xóa cache DNS (Flush DNS)"; Action = { Clear-DnsClientCache; Write-Success "Đã xóa DNS Cache thành công."; Pause-Screen } },
        @{ Label = "Làm mới địa chỉ IP DHCP (Renew IP)"; Action = { & ipconfig.exe /renew; Pause-Screen } },
        @{ Label = "Kiểm tra Ping tới Gateway / IP / Máy chủ"; Action = { Invoke-PingTest } },
        @{ Label = "Kiểm tra phân giải tên miền (DNS Lookup)"; Action = { Invoke-DnsLookupTest } },
        @{ Label = "Kiểm tra kết nối cổng TCP (Port Ping)"; Action = { Invoke-TcpPortTest } },
        @{ Label = "Kiểm tra cấu hình SMB Client (Read-Only)"; Action = { Show-SmbConfiguration } },
        @{ Label = "Kiểm tra Firewall Rules cho File & Printer Sharing"; Action = { Show-FirewallSharingRules } },
        @{ Label = "Mở Network Connections (ncpa.cpl)"; Action = { Start-Process "ncpa.cpl" } },
        @{ Label = "Mở Advanced Sharing Settings (Cài đặt chia sẻ nâng cao)"; Action = { Start-Process "control.exe" "/name Microsoft.NetworkAndSharingCenter /page Advanced" } },
        @{ Label = "Mở Windows Firewall (firewall.cpl)"; Action = { Start-Process "firewall.cpl" } },
        @{ Label = "Mở Credential Manager (Quản lý tài khoản mạng)"; Action = { Start-Process "control.exe" "/name Microsoft.CredentialManager" } },
        @{ Label = "Xuất báo cáo cấu hình mạng"; Action = { Export-NetworkReport } }
    )
    Show-TMMenu -Title "MẠNG NỘI BỘ & LAN SUPPORT (NETWORK SUPPORT)" -MenuItems $menuItems -ExitLabel "Quay lại"
}

function Show-NetworkOverview {
    Write-SubHeader "TỔNG QUAN KẾT NỐI MẠNG"
    try {
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
        foreach ($ad in $adapters) {
            Write-Host " Card mạng: $($ad.Name) ($($ad.InterfaceDescription))" -ForegroundColor Cyan
            Write-Host "   MAC Address  : $($ad.MacAddress)" -ForegroundColor White
            Write-Host "   Tốc độ kết nối: $($ad.LinkSpeed)" -ForegroundColor White

            $ips = Get-NetIPAddress -InterfaceIndex $ad.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
            foreach ($ip in $ips) {
                Write-Host "   Địa chỉ IPv4 : $($ip.IPAddress)/$($ip.PrefixLength)" -ForegroundColor Green
            }

            $routes = Get-NetRoute -InterfaceIndex $ad.InterfaceIndex -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue
            if ($routes) {
                Write-Host "   Default Gateway: $($routes[0].NextHop)" -ForegroundColor White
            }

            $dnsServers = (Get-DnsClientServerAddress -InterfaceIndex $ad.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue).ServerAddresses
            if ($dnsServers) {
                Write-Host "   Máy chủ DNS  : $($dnsServers -join ', ')" -ForegroundColor White
            }
            Write-Host ""
        }
    } catch {
        Handle-TMException -TaskId "NET_OVERVIEW" -TaskName "Xem cấu hình mạng" -Exception $_.Exception
    }
    Pause-Screen
}

function Invoke-PingTest {
    Write-SubHeader "KIỂM TRA PING KẾT NỐI"
    Write-Host " Nhập IP hoặc tên máy chủ cần ping (mặc định 8.8.8.8): " -ForegroundColor Cyan -NoNewline
    $target = Read-Host
    if ([string]::IsNullOrWhiteSpace($target)) { $target = "8.8.8.8" }

    Write-InfoMessage "Đang gửi 4 gói tin ICMP tới $target..."
    & ping.exe $target
    Pause-Screen
}

function Invoke-DnsLookupTest {
    Write-SubHeader "KIỂM TRA PHÂN GIẢI DNS (NSLOOKUP)"
    Write-Host " Nhập tên miền hoặc hostname cần tra cứu (ví dụ: google.com): " -ForegroundColor Cyan -NoNewline
    $hostName = Read-Host
    if ([string]::IsNullOrWhiteSpace($hostName)) { $hostName = "google.com" }

    try {
        $res = Resolve-DnsName -Name $hostName -ErrorAction Stop
        $res | Select-Object Name, Type, IPAddress | Format-Table -AutoSize
    } catch {
        Write-ErrorMessage "Không thể phân giải tên '$hostName': $($_.Exception.Message)"
    }
    Pause-Screen
}

function Invoke-TcpPortTest {
    Write-SubHeader "KIỂM TRA KẾT NỐI CỔNG TCP (PORT TEST)"
    Write-Host " Nhập địa chỉ IP hoặc tên máy: " -ForegroundColor Cyan -NoNewline
    $dest = Read-Host
    if ([string]::IsNullOrWhiteSpace($dest)) {
        Write-ErrorMessage "Địa chỉ không được để trống."
        Pause-Screen
        return
    }

    Write-Host " Nhập số cổng TCP (ví dụ: 80, 443, 445 cho SMB, 135 cho RPC, 9100 cho máy in): " -ForegroundColor Cyan -NoNewline
    $portStr = Read-Host
    if (-not ($portStr -match "^\d+$")) {
        Write-ErrorMessage "Số cổng không hợp lệ."
        Pause-Screen
        return
    }

    $port = [int]$portStr
    Write-InfoMessage "Đang kiểm tra kết nối TCP tới $dest`:$port..."
    try {
        $test = Test-NetConnection -ComputerName $dest -Port $port -WarningAction SilentlyContinue
        if ($test.TcpTestSucceeded) {
            Write-Success "Kết nối tới $dest`:$port THÀNH CÔNG!"
        } else {
            Write-ErrorMessage "Kết nối tới $dest`:$port THẤT BẠI. Cổng có thể bị đóng hoặc chặn bởi tường lửa."
        }
    } catch {
        Handle-TMException -TaskId "NET_PORT_TEST" -TaskName "Port Test" -Exception $_.Exception
    }
    Pause-Screen
}

function Show-SmbConfiguration {
    Write-SubHeader "CẤU HÌNH SMB CLIENT HIỆN TẠI (READ-ONLY)"
    try {
        if (Test-CmdletAvailable "Get-SmbClientConfiguration") {
            $smb = Get-SmbClientConfiguration
            Write-Host "  RequireSecuritySignature (Bắt buộc ký số SMB): $($smb.RequireSecuritySignature)" -ForegroundColor $(if ($smb.RequireSecuritySignature) { "Green" } else { "Yellow" })
            Write-Host "  EnableInsecureGuestLogons (Cho phép Guest):      $($smb.EnableInsecureGuestLogons)" -ForegroundColor $(if ($smb.EnableInsecureGuestLogons) { "Red" } else { "Green" })
            Write-Host "  EnableSMB1Protocol (Giao thức cũ SMB1):          $(if (Test-CmdletAvailable 'Get-WindowsOptionalFeature') { 'Kiểm tra qua Windows Features' } else { 'Không khả dụng' })" -ForegroundColor Gray
            Write-Host ""
            Write-InfoMessage "Ghi chú: Giữ RequireSecuritySignature = True là cấu hình an toàn tiêu chuẩn của Microsoft."
        } else {
            Write-WarningMessage "Cmdlet Get-SmbClientConfiguration không khả dụng trên phiên bản Windows này."
        }
    } catch {
        Handle-TMException -TaskId "SMB_CONF" -TaskName "Kiểm tra SMB" -Exception $_.Exception
    }
    Pause-Screen
}

function Show-FirewallSharingRules {
    Write-SubHeader "TRẠNG THÁI TƯỜNG LỬA CHO FILE & PRINTER SHARING"
    try {
        $rules = Get-NetFirewallRule -DisplayGroup "*File and Printer Sharing*" -ErrorAction SilentlyContinue | Select-Object -First 5
        if ($rules) {
            foreach ($r in $rules) {
                $status = if ($r.Enabled -eq "True") { "[BẬT]" } else { "[TẮT]" }
                $color = if ($r.Enabled -eq "True") { "Green" } else { "Yellow" }
                Write-Host "  $status $($r.DisplayName)" -ForegroundColor $color
            }
        } else {
            Write-InfoMessage "Không tìm thấy rule File and Printer Sharing."
        }
    } catch {
        Handle-TMException -TaskId "FW_RULES" -TaskName "Kiểm tra Firewall Rules" -Exception $_.Exception
    }
    Pause-Screen
}

function Export-NetworkReport {
    $reportDir = Join-Path $PSScriptRoot "../../../Logs"
    $filename = "NetworkReport_" + (Get-Date).ToString("yyyyMMdd_HHmmss") + ".txt"
    $fullPath = Join-Path $reportDir $filename

    $lines = @()
    $lines += "========================================================="
    $lines += "         TM-WINCARE - BÁO CÁO CẤU HÌNH MẠNG"
    $lines += "  Thời gian: " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $lines += "========================================================="
    try {
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
        foreach ($ad in $adapters) {
            $lines += "Card: $($ad.Name) | MAC: $($ad.MacAddress) | Tốc độ: $($ad.LinkSpeed)"
        }
    } catch {}
    $lines += "========================================================="
    Set-Content -Path $fullPath -Value $lines -Encoding UTF8 -Force
    Write-Success "Đã xuất báo cáo ra file: $fullPath"
    Pause-Screen
}
