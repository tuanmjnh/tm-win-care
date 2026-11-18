# TM-WinCare - Hardware & Windows OS Detection Engine
# Adheres to Section 3.1 & Section 12 of TM-WinCare-Architecture-v1.2.md
# No WMIC dependency; uses CIM & Native Registry

function Get-TMSystemInfo {
    $info = [ordered]@{}

    # 1. OS & Build Identification
    try {
        $osCim = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
        $buildNumber = [int]$osCim.BuildNumber
        $osCaption = $osCim.Caption
        
        # Determine Windows 10 vs 11 cleanly
        $isWin11 = ($buildNumber -ge 22000)
        $osFamily = if ($isWin11) { "Windows 11" } else { "Windows 10" }

        # Get DisplayVersion (e.g. 22H2, 23H2) from Registry
        $displayVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name DisplayVersion -ErrorAction SilentlyContinue).DisplayVersion
        if (-not $displayVersion) {
            $displayVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ReleaseId -ErrorAction SilentlyContinue).ReleaseId
        }

        # Check Windows 10 EOL
        $eolNotice = ""
        if (-not $isWin11 -and $buildNumber -le 19045) {
            $eolNotice = " [Hết hỗ trợ tiêu chuẩn 14/10/2025]"
        }

        $info["Hệ điều hành"] = "$osFamily $displayVersion (Build $buildNumber)$eolNotice"
        $info["Phiên bản chi tiết"] = $osCaption
        $info["Kiến trúc"] = $osCim.OSArchitecture
        $info["Tên máy (Hostname)"] = [System.Environment]::MachineName
        $info["Người dùng hiện tại"] = "$([System.Environment]::UserDomainName)\$([System.Environment]::UserName)"
        $info["Quyền Administrator"] = if (Test-IsAdmin) { "Có (Elevated)" } else { "Không (Standard User)" }
    } catch {
        $info["Hệ điều hành"] = "Windows (Không thể đọc CIM: $($_.Exception.Message))"
    }

    # 2. Hardware: CPU & RAM
    try {
        $cpu = Get-CimInstance -ClassName Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($cpu) {
            $info["Bộ vi xử lý (CPU)"] = $cpu.Name.Trim()
        }

        $totalMem = [math]::Round($osCim.TotalVisibleMemorySize / 1MB, 1)
        $freeMem = [math]::Round($osCim.FreePhysicalMemory / 1MB, 1)
        $usedMem = [math]::Round($totalMem - $freeMem, 1)
        $pctMem = [math]::Round(($usedMem / $totalMem) * 100, 0)
        $info["Bộ nhớ RAM"] = "$usedMem GB / $totalMem GB ($pctMem% đang dùng - $freeMem GB trống)"
    } catch {}

    # 3. Storage
    try {
        $drives = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction SilentlyContinue
        $driveSummaries = @()
        foreach ($d in $drives) {
            $totalGB = [math]::Round($d.Size / 1GB, 1)
            $freeGB = [math]::Round($d.FreeSpace / 1GB, 1)
            $pctFree = if ($totalGB -gt 0) { [math]::Round(($freeGB / $totalGB) * 100, 0) } else { 0 }
            $driveSummaries += "$($d.DeviceID) ($freeGB GB trống / $totalGB GB - $pctFree%)"
        }
        $info["Ổ đĩa lưu trữ"] = $driveSummaries -join ", "
    } catch {}

    # 4. Network Status
    try {
        $net = Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "*Wi-Fi*","*Ethernet*","*LAN*" -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notlike "169.254*" } | Select-Object -First 1
        if ($net) {
            $info["Địa chỉ IPv4"] = "$($net.IPAddress) ($($net.InterfaceAlias))"
        } else {
            $info["Địa chỉ IPv4"] = "Không phát hiện card mạng LAN/Wi-Fi đang kết nối"
        }
    } catch {
        $info["Địa chỉ IPv4"] = "Không thể lấy thông tin mạng"
    }

    # 5. Security & Services
    try {
        $spooler = Get-Service -Name Spooler -ErrorAction SilentlyContinue
        $info["Print Spooler"] = if ($spooler) { "$($spooler.Status) (Khởi động: $($spooler.StartType))" } else { "Không tìm thấy" }
    } catch {}

    try {
        $printers = Get-Printer -ErrorAction SilentlyContinue
        $printerCount = if ($printers) { @($printers).Count } else { 0 }
        $info["Số lượng máy in đã cài"] = "$printerCount máy in"
    } catch {
        $info["Số lượng máy in đã cài"] = "Không thể đọc danh sách máy in"
    }

    try {
        $defenderSvc = Get-Service -Name WinDefend -ErrorAction SilentlyContinue
        $info["Microsoft Defender"] = if ($defenderSvc -and $defenderSvc.Status -eq "Running") { "Đang chạy (Hoạt động)" } else { "Tắt hoặc không khả dụng" }
    } catch {}

    # Store global OS info
    $global:TM_OS_INFO = [PSCustomObject]@{
        IsWin11 = $isWin11
        Build = $buildNumber
        Version = $displayVersion
        Edition = $osCaption
        TotalRAM = $totalMem
        IsAdmin = (Test-IsAdmin)
    }

    return $info
}
