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
            $eolNotice = " [Standard EOL: Oct 14, 2025]"
        }

        $info["Operating System"] = "$osFamily $displayVersion (Build $buildNumber)$eolNotice"
        $info["OS Edition"] = $osCaption
        $info["Architecture"] = $osCim.OSArchitecture
        $info["Computer Name (Hostname)"] = [System.Environment]::MachineName
        $info["Current User"] = "$([System.Environment]::UserDomainName)\$([System.Environment]::UserName)"
        $info["Administrator Privilege"] = if (Test-IsAdmin) { "Yes (Elevated)" } else { "No (Standard User)" }
    } catch {
        $info["Operating System"] = "Windows (Unable to read CIM: $($_.Exception.Message))"
    }

    # 2. Hardware: CPU & RAM
    try {
        $cpu = Get-CimInstance -ClassName Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($cpu) {
            $info["Processor (CPU)"] = $cpu.Name.Trim()
        }

        $totalMem = [math]::Round($osCim.TotalVisibleMemorySize / 1MB, 1)
        $freeMem = [math]::Round($osCim.FreePhysicalMemory / 1MB, 1)
        $usedMem = [math]::Round($totalMem - $freeMem, 1)
        $pctMem = [math]::Round(($usedMem / $totalMem) * 100, 0)
        $info["RAM Memory"] = "$usedMem GB / $totalMem GB ($pctMem% used - $freeMem GB free)"
    } catch {}

    # 3. Storage
    try {
        $drives = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction SilentlyContinue
        $driveSummaries = @()
        foreach ($d in $drives) {
            $totalGB = [math]::Round($d.Size / 1GB, 1)
            $freeGB = [math]::Round($d.FreeSpace / 1GB, 1)
            $pctFree = if ($totalGB -gt 0) { [math]::Round(($freeGB / $totalGB) * 100, 0) } else { 0 }
            $driveSummaries += "$($d.DeviceID) ($freeGB GB free / $totalGB GB - $pctFree%)"
        }
        $info["Storage Drives"] = $driveSummaries -join ", "
    } catch {}

    # 4. Network Status
    try {
        $net = Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "*Wi-Fi*","*Ethernet*","*LAN*" -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notlike "169.254*" } | Select-Object -First 1
        if ($net) {
            $info["IPv4 Address"] = "$($net.IPAddress) ($($net.InterfaceAlias))"
        } else {
            $info["IPv4 Address"] = "No active LAN or Wi-Fi adapter detected"
        }
    } catch {
        $info["IPv4 Address"] = "Unable to read network info"
    }

    # 5. Security & Services
    try {
        $spooler = Get-Service -Name Spooler -ErrorAction SilentlyContinue
        $info["Print Spooler"] = if ($spooler) { "$($spooler.Status) (Startup: $($spooler.StartType))" } else { "Not Found" }
    } catch {}

    try {
        $printers = Get-Printer -ErrorAction SilentlyContinue
        $printerCount = if ($printers) { @($printers).Count } else { 0 }
        $info["Installed Printers"] = "$printerCount printers"
    } catch {
        $info["Installed Printers"] = "Unable to read printers"
    }

    try {
        $defenderSvc = Get-Service -Name WinDefend -ErrorAction SilentlyContinue
        $info["Microsoft Defender"] = if ($defenderSvc -and $defenderSvc.Status -eq "Running") { "Running (Active)" } else { "Disabled or Unavailable" }
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
