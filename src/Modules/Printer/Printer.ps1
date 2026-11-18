# TM-WinCare - Printer Support Module
# Adheres to Section 4 & Section 5 of TM-WinCare-Architecture-v1.2.md

function Show-TMPrinterMenu {
    $menuItems = @(
        @{ Label = "Danh sách máy in đã cài trên hệ thống"; Action = { Show-InstalledPrinters } },
        @{ Label = "Mở cài đặt Printers & Scanners (Settings)"; Action = { Start-Process "ms-settings:printers" } },
        @{ Label = "Mở Devices and Printers cổ điển (Control Panel)"; Action = { Start-Process "control.exe" "printers" } },
        @{ Label = "Mở Quản lý Driver máy in (printui /s /t2)"; Action = { Start-Process "rundll32.exe" "printui.dll,PrintUIEntry /s /t2" } },
        @{ Label = "Khởi động lại dịch vụ Print Spooler"; Action = { Invoke-RestartSpooler } },
        @{ Label = "Xóa toàn bộ hàng đợi in bị treo / kẹt lệnh"; Action = { Invoke-ClearPrintQueue } },
        @{ Label = "Kiểm tra chi tiết trạng thái Print Spooler"; Action = { Test-PrintSpoolerHealth } },
        @{ Label = "Kiểm tra kết nối máy in chia sẻ qua mạng (UNC Test)"; Action = { Test-SharedPrinterConnection } },
        @{ Label = "Tạo tài khoản scan máy in (Scan-to-Folder)"; Action = { Invoke-CreateScanAccount } },
        @{ Label = "Hướng dẫn & công cụ cấu hình máy chủ chia sẻ máy in"; Action = { Show-HostPrinterGuide } },
        @{ Label = "Hướng dẫn & công cụ cấu hình máy khách kết nối máy in"; Action = { Show-ClientPrinterGuide } },
        @{ Label = "Tạo Local Port kết nối máy in qua mạng (\\Server\\Share)"; Action = { Show-LocalPortHelper } },
        @{ Label = "Hướng dẫn xử lý lỗi máy in Access Denied (0x0000011b, 0x00000709)"; Action = { Show-PrinterAccessDeniedGuide } },
        @{ Label = "Xuất báo cáo máy in ra file TXT"; Action = { Export-PrinterReport } }
    )
    Show-TMMenu -Title "HỖ TRỢ MÁY IN & IN ẤN (PRINTER SUPPORT)" -MenuItems $menuItems -ExitLabel "Quay lại"
}

function Show-InstalledPrinters {
    Write-SubHeader "DANH SÁCH MÁY IN ĐÃ CÀI ĐẶT"
    try {
        $printers = Get-Printer -ErrorAction Stop
        if (-not $printers -or @($printers).Count -eq 0) {
            Write-InfoMessage "Không tìm thấy máy in nào được cài đặt trên hệ thống."
        } else {
            $list = @()
            foreach ($p in $printers) {
                $list += [PSCustomObject]@{
                    TenMayIn = $p.Name
                    Driver = $p.DriverName
                    Cong = $p.PortName
                    ChiaSe = if ($p.Shared) { "Có ($($p.ShareName))" } else { "Không" }
                    TrangThai = $p.PrinterStatus.ToString()
                }
            }
            $headers = @("Tên máy in", "Driver", "Cổng kết nối", "Chia sẻ", "Trạng thái")
            $props = @("TenMayIn", "Driver", "Cong", "ChiaSe", "TrangThai")
            $widths = @(25, 25, 15, 12, 10)
            Show-TableList -Items $list -Headers $headers -PropertyNames $props -Widths $widths
        }
    } catch {
        Handle-TMException -TaskId "PRINT_LIST" -TaskName "Liệt kê máy in" -Exception $_.Exception
    }
    Pause-Screen
}

function Invoke-RestartSpooler {
    if (-not (Assert-Admin "khởi động lại Print Spooler")) { Pause-Screen; return }

    Write-SubHeader "KHỞI ĐỘNG LẠI DỊCH VỤ PRINT SPOOLER"
    try {
        Write-InfoMessage "Đang dừng dịch vụ Spooler..."
        Stop-Service -Name Spooler -Force -ErrorAction Stop
        Start-Sleep -Milliseconds 800
        
        Write-InfoMessage "Đang khởi động lại dịch vụ Spooler..."
        Start-Service -Name Spooler -ErrorAction Stop
        Start-Sleep -Milliseconds 800

        $svc = Get-Service -Name Spooler
        if ($svc.Status -eq "Running") {
            Write-Success "Dịch vụ Print Spooler đã được khởi động lại và đang hoạt động bình thường!"
            Write-TMLog -TaskId "PRINT_RESTART_SPOOLER" -TaskName "Restart Spooler" -Status "Success" -Message "Thành công"
        } else {
            Write-ErrorMessage "Dịch vụ Spooler ở trạng thái: $($svc.Status)"
        }
    } catch {
        Handle-TMException -TaskId "PRINT_RESTART_SPOOLER" -TaskName "Restart Spooler" -Exception $_.Exception
    }
    Pause-Screen
}

function Invoke-ClearPrintQueue {
    if (-not (Assert-Admin "xóa hàng đợi in bị treo")) { Pause-Screen; return }

    Write-SubHeader "XÓA HÀNG ĐỢI IN BỊ TREO (CLEAR SPOOL QUEUE)"
    $spoolPath = Join-Path $env:SystemRoot "System32\spool\PRINTERS"

    $confirmed = Confirm-Action -TaskName "Xóa hàng đợi in bị kẹt" -ImpactDescription "Dừng Print Spooler, dọn sạch tất cả lệnh in đang chờ trong thư mục $spoolPath và khởi động lại Spooler." -RiskLevel "medium"
    if (-not $confirmed) { Pause-Screen; return }

    try {
        Write-InfoMessage "1. Đang dừng dịch vụ Print Spooler..."
        Stop-Service -Name Spooler -Force -ErrorAction Stop
        Start-Sleep -Milliseconds 500

        Write-InfoMessage "2. Đang xóa các file lệnh in tạm trong $spoolPath..."
        $files = Get-ChildItem -Path $spoolPath -File -ErrorAction SilentlyContinue
        $deleted = 0
        foreach ($f in $files) {
            try {
                Remove-Item $f.FullName -Force -ErrorAction Stop
                $deleted++
            } catch {}
        }
        Write-Success "Đã xóa $deleted file lệnh in bị kẹt."

        Write-InfoMessage "3. Đang khởi động lại dịch vụ Print Spooler..."
        Start-Service -Name Spooler -ErrorAction Stop
        Start-Sleep -Milliseconds 500

        $svc = Get-Service -Name Spooler
        if ($svc.Status -eq "Running") {
            Write-Success "Hàng đợi in đã được dọn sạch và Spooler đã hoạt động trở lại!"
            Write-TMLog -TaskId "PRINT_CLEAR_QUEUE" -TaskName "Xóa hàng đợi in" -Status "Success" -Message "Đã xóa $deleted file lệnh in"
        }
    } catch {
        Handle-TMException -TaskId "PRINT_CLEAR_QUEUE" -TaskName "Xóa hàng đợi in" -Exception $_.Exception
    }
    Pause-Screen
}

function Test-PrintSpoolerHealth {
    Write-SubHeader "KIỂM TRA SỨC KHỎE DỊCH VỤ PRINT SPOOLER"
    try {
        $svc = Get-Service -Name Spooler -ErrorAction Stop
        Write-Host "  Tên dịch vụ   : $($svc.ServiceName) ($($svc.DisplayName))" -ForegroundColor Cyan
        Write-Host "  Trạng thái    : $($svc.Status)" -ForegroundColor $(if ($svc.Status -eq "Running") { "Green" } else { "Red" })

        $cim = Get-CimInstance Win32_Service -Filter "Name='Spooler'" -ErrorAction SilentlyContinue
        if ($cim) {
            Write-Host "  Chế độ startup: $($cim.StartMode)" -ForegroundColor White
            Write-Host "  Tiến trình PID: $($cim.ProcessId)" -ForegroundColor White
        }

        # Check Spool folder size
        $spoolPath = Join-Path $env:SystemRoot "System32\spool\PRINTERS"
        if (Test-Path $spoolPath) {
            $files = Get-ChildItem -Path $spoolPath -File -ErrorAction SilentlyContinue
            Write-Host "  Số lệnh in kẹt: $(@($files).Count) file" -ForegroundColor $(if (@($files).Count -gt 0) { "Yellow" } else { "Green" })
        }
    } catch {
        Handle-TMException -TaskId "PRINT_HEALTH" -TaskName "Kiểm tra Spooler" -Exception $_.Exception
    }
    Pause-Screen
}

function Test-SharedPrinterConnection {
    Write-SubHeader "KIỂM TRA KẾT NỐI MÁY IN CHIA SẺ TRONG MẠNG LAN"
    Write-Host " Nhập đường dẫn UNC máy in (ví dụ: \\TEN-MAY-CHU\TEN-MAY-IN hoặc \\192.168.1.100\PrinterName): " -ForegroundColor Cyan -NoNewline
    $unc = Read-Host
    if ([string]::IsNullOrWhiteSpace($unc) -or -not ($unc.StartsWith("\\"))) {
        Write-ErrorMessage "Đường dẫn không hợp lệ. Phải bắt đầu bằng \\ (ví dụ \\Server\Printer)."
        Pause-Screen
        return
    }

    $parts = $unc.TrimStart('\').Split('\')
    $serverName = $parts[0]

    Write-InfoMessage "1. Kiểm tra phân giải & kết nối TCP 445 (SMB) tới máy chủ $serverName..."
    $testSmb = Test-NetConnection -ComputerName $serverName -Port 445 -WarningAction SilentlyContinue
    if ($testSmb.TcpTestSucceeded) {
        Write-Success "Máy chủ $serverName đang mở cổng chia sẻ SMB (TCP 445)."
    } else {
        Write-WarningMessage "Không thể kết nối cổng SMB tới $serverName. Hãy kiểm tra địa chỉ IP, tên máy hoặc tường lửa."
    }

    Write-InfoMessage "2. Kiểm tra đường dẫn chia sẻ $unc..."
    if (Test-Path -LiteralPath $unc -ErrorAction SilentlyContinue) {
        Write-Success "Đường dẫn chia sẻ $unc có thể truy cập thành công!"
    } else {
        Write-WarningMessage "Chưa thể truy cập trực tiếp $unc. Điều này có thể do cần xác thực tài khoản qua Credential Manager."
    }
    Pause-Screen
}

function Invoke-CreateScanAccount {
    if (-not (Assert-Admin "tạo tài khoản scan")) { Pause-Screen; return }

    Write-SubHeader "TẠO TÀI KHOẢN SCAN MÁY IN (SCAN-TO-FOLDER)"
    Write-InfoMessage "Tài khoản local dùng cho máy in đa chức năng scan gửi file vào thư mục mạng."
    Write-Host ""
    Write-Host " Nhập tên tài khoản (mặc định 'scan'): " -ForegroundColor Cyan -NoNewline
    $uName = Read-Host
    if ([string]::IsNullOrWhiteSpace($uName)) { $uName = "scan" }

    # Check if user already exists
    if (Test-CmdletAvailable "Get-LocalUser") {
        $existing = Get-LocalUser -Name $uName -ErrorAction SilentlyContinue
        if ($existing) {
            Write-WarningMessage "Tài khoản '$uName' đã tồn tại trên máy tính này!"
            Pause-Screen
            return
        }
    }

    # Secure Password Input
    Write-Host " Nhập mật khẩu cho tài khoản '$uName': " -ForegroundColor Cyan -NoNewline
    $secPass1 = Read-Host -AsSecureString
    Write-Host " Xác nhận lại mật khẩu: " -ForegroundColor Cyan -NoNewline
    $secPass2 = Read-Host -AsSecureString

    # Validate passwords match
    $bstr1 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secPass1)
    $bstr2 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secPass2)
    $plain1 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr1)
    $plain2 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr2)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr1)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr2)

    if ($plain1 -ne $plain2) {
        Write-ErrorMessage "Mật khẩu xác nhận không khớp. Hủy thao tác."
        Pause-Screen
        return
    }
    if ([string]::IsNullOrWhiteSpace($plain1)) {
        Write-ErrorMessage "Mật khẩu không được để trống."
        Pause-Screen
        return
    }

    Write-Host " Bạn có muốn đặt mật khẩu không bao giờ hết hạn (PasswordNeverExpires)? (Y/N): " -ForegroundColor Cyan -NoNewline
    $pneAns = Read-Host
    $neverExpires = ($pneAns.Trim().ToUpper() -eq "Y")

    $confirmed = Confirm-Action -TaskName "Tạo tài khoản scan '$uName'" -ImpactDescription "Tạo user cục bộ '$uName' dùng riêng cho dịch vụ scan máy in. Mật khẩu được bảo mật hoàn toàn." -RiskLevel "medium"
    if ($confirmed) {
        try {
            if (Test-CmdletAvailable "New-LocalUser") {
                New-LocalUser -Name $uName -Password $secPass1 -Description "Tài khoản dùng cho scan máy in" -PasswordNeverExpires:$neverExpires -ErrorAction Stop
            } else {
                # Fallback to net user if LocalAccounts cmdlet not present
                & net.exe user "$uName" "$plain1" /add /comment:"Tai khoan scan"
            }
            Write-Success "Đã tạo tài khoản '$uName' thành công!"
            Write-InfoMessage "Bây giờ bạn có thể phân quyền cho user '$uName' vào thư mục nhận file scan (ví dụ D:\Scan)."
            Write-TMLog -TaskId "PRINT_SCAN_USER" -TaskName "Tạo tài khoản scan" -Status "Success" -Message "User: $uName"
        } catch {
            Handle-TMException -TaskId "PRINT_SCAN_USER" -TaskName "Tạo user scan" -Exception $_.Exception
        }
    }
    Pause-Screen
}

function Show-HostPrinterGuide {
    Write-SubHeader "HƯỚNG DẪN CẤU HÌNH TRÊN MÁY CHỦ (MÁY CẮM MÁY IN)"
    Write-Host " 1. Kiểm tra máy in đã in được trực tiếp từ máy chủ." -ForegroundColor White
    Write-Host " 2. Vào Control Panel > Devices and Printers > Chuột phải vào máy in > Printer Properties." -ForegroundColor White
    Write-Host " 3. Mở tab Sharing > Tích chọn 'Share this printer' và đặt tên chia sẻ ngắn gọn (ví dụ: Canon2900)." -ForegroundColor White
    Write-Host " 4. Mở tab Security > Kiểm tra nhóm 'Everyone' có quyền 'Print'." -ForegroundColor White
    Write-Host " 5. Mở Advanced Sharing Settings > Bật 'Turn on file and printer sharing'." -ForegroundColor White
    Write-Host " 6. Ghi lại Tên máy chủ (Hostname) hoặc địa chỉ IP của máy này." -ForegroundColor Cyan
    Pause-Screen
}

function Show-ClientPrinterGuide {
    Write-SubHeader "HƯỚNG DẪN CẤU HÌNH TRÊN MÁY KHÁCH (CLIENT)"
    Write-Host " 1. Mở Credential Manager > Windows Credentials > Add a Windows credential." -ForegroundColor White
    Write-Host "    - Network address: Nhập tên hoặc IP máy chủ (ví dụ: \\TEN-MAY-CHU)" -ForegroundColor Gray
    Write-Host "    - User name / Password: Nhập tài khoản của máy chủ." -ForegroundColor Gray
    Write-Host " 2. Bấm Win + R > Nhập '\\TEN-MAY-CHU' để kiểm tra xem đã nhìn thấy máy in chia sẻ chưa." -ForegroundColor White
    Write-Host " 3. Chuột phải vào máy in chia sẻ > Chọn 'Connect'." -ForegroundColor White
    Write-Host " 4. Nếu gặp lỗi Access Denied hoặc driver, hãy dùng chức năng 'Tạo Local Port' bên dưới." -ForegroundColor Cyan
    Pause-Screen
}

function Show-LocalPortHelper {
    Write-SubHeader "HỖ TRỢ TẠO LOCAL PORT CHO MÁY IN MẠNG"
    Write-InfoMessage "Local Port là giải pháp cực kỳ tin cậy để kết nối máy in chia sẻ khi gặp lỗi driver hoặc mạng."
    Write-Host ""
    Write-Host " Nhập tên hoặc IP máy chủ (Server): " -ForegroundColor Cyan -NoNewline
    $server = Read-Host
    Write-Host " Nhập tên chia sẻ máy in (Share name): " -ForegroundColor Cyan -NoNewline
    $share = Read-Host

    if ([string]::IsNullOrWhiteSpace($server) -or [string]::IsNullOrWhiteSpace($share)) {
        Write-ErrorMessage "Tên máy chủ và tên chia sẻ không được để trống."
        Pause-Screen
        return
    }

    $portName = "\\$server\$share"
    Write-Success "Đường dẫn Local Port của bạn là: $portName"
    Write-Host ""
    Write-Host " Các bước thực hiện trong Windows:" -ForegroundColor Yellow
    Write-Host "  1. Mở 'Devices and Printers' -> Bấm 'Add a printer'." -ForegroundColor White
    Write-Host "  2. Chọn 'The printer that I want isn't listed'." -ForegroundColor White
    Write-Host "  3. Chọn 'Add a local printer or network printer with manual settings' -> Next." -ForegroundColor White
    Write-Host "  4. Chọn 'Create a new port' -> Loại port chọn: 'Local Port' -> Next." -ForegroundColor White
    Write-Host "  5. Dán chính xác đường dẫn sau vào ô Port Name: " -ForegroundColor White
    Write-Host "     $portName" -ForegroundColor Cyan
    Write-Host "  6. Chọn đúng Driver máy in từ danh sách hoặc Have Disk để hoàn tất." -ForegroundColor White
    Write-Host ""
    Write-Host " Bạn có muốn mở ngay trình quản lý Devices and Printers không? (Y/N): " -ForegroundColor Cyan -NoNewline
    $ans = Read-Host
    if ($ans.Trim().ToUpper() -eq "Y") {
        Start-Process "control.exe" "printers"
    }
    Pause-Screen
}

function Show-PrinterAccessDeniedGuide {
    Write-SubHeader "HƯỚNG DẪN XỬ LÝ LỖI ACCESS DENIED / 0x0000011b TRÊN WINDOWS 10 & 11"
    Write-Host " Nguyên nhân thường gặp:" -ForegroundColor Yellow
    Write-Host "  - Bản cập nhật bảo mật RPC Printing của Microsoft yêu cầu xác thực mức cao." -ForegroundColor Gray
    Write-Host "  - Máy khách chưa lưu thông tin tài khoản của máy chủ trong Credential Manager." -ForegroundColor Gray
    Write-Host "  - Windows 11 22H2+ mặc định dùng RPC over TCP trong khi máy chủ cũ dùng Named Pipes." -ForegroundColor Gray
    Write-Host ""
    Write-Host " Các bước xử lý an toàn theo thứ tự ưu tiên:" -ForegroundColor Cyan
    Write-Host "  1. Lưu tài khoản máy chủ vào Credential Manager trên máy khách." -ForegroundColor White
    Write-Host "  2. Cài đặt sẵn driver máy in giống hệt phiên bản trên máy khách trước khi kết nối." -ForegroundColor White
    Write-Host "  3. Sử dụng kết nối qua Local Port thay vì kết nối tự động (đã hướng dẫn ở mục 12)." -ForegroundColor White
    Write-Host "  4. Khởi động lại Print Spooler trên cả hai máy." -ForegroundColor White
    Pause-Screen
}

function Export-PrinterReport {
    $reportDir = Join-Path $PSScriptRoot "../../../Logs"
    $filename = "PrinterReport_" + (Get-Date).ToString("yyyyMMdd_HHmmss") + ".txt"
    $fullPath = Join-Path $reportDir $filename

    $lines = @()
    $lines += "========================================================="
    $lines += "         TM-WINCARE - BÁO CÁO DANH SÁCH MÁY IN"
    $lines += "  Thời gian: " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $lines += "========================================================="
    try {
        $printers = Get-Printer
        foreach ($p in $printers) {
            $lines += "Tên: $($p.Name) | Driver: $($p.DriverName) | Cổng: $($p.PortName) | Shared: $($p.Shared)"
        }
    } catch {}
    $lines += "========================================================="
    Set-Content -Path $fullPath -Value $lines -Encoding UTF8 -Force
    Write-Success "Đã xuất báo cáo ra file: $fullPath"
    Pause-Screen
}
