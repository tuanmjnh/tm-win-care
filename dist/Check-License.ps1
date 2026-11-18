# TM-WinCare - License and IT Inventory Tool
# TM-WinCare - Windows & Office License Management (IT Inventory)
# Decodes Full 25-character Windows Key & Office Key, Mainboard Serial, UUID, Sync to Google Sheets / Form

function Invoke-LicenseInventoryCheck {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

    # ==================== CAU HINH LINK GOOGLE SHEETS / FORM ====================
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

    Write-Host "`n[*] Đang quét phần cứng và giải mã toàn bộ Key Windows / Office..." -ForegroundColor Cyan

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
    $winStatus = if ($winActiveLic -and $winActiveLic.LicenseStatus -eq 1) { "Da kich hoat" } else { "Chua kich hoat" }
    $winPartial = if ($winActiveLic -and $winActiveLic.PartialProductKey) { $winActiveLic.PartialProductKey } else { "N/A" }

    $winFullList = @()
    if ($winRegKey) { $winFullList += "Active: $winRegKey" }
    if ($winBackupKey -and $winBackupKey -ne $winRegKey) { $winFullList += "Backup: $winBackupKey" }
    if ($winOemKey) { $winFullList += "OEM-BIOS: $winOemKey" }
    if ($winFullList.Count -eq 0) { $winFullList += "5-Cuoi: $winPartial" }
    $winKeySummary = $winFullList -join " | "

    # 2. Key Office tren may
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
            $st = if ($item.LicenseStatus -eq 1) { "Da kich hoat" } else { "Chua kich hoat" }
            $pk = $item.PartialProductKey

            $matchedFull = $offRegKeys | Where-Object { $_ -like "*$pk" } | Select-Object -First 1
            $keyDisplay = if ($matchedFull) { $matchedFull } else { "XXXXX-$pk ($cleanName)" }

            $offNames += $cleanName
            $offStatuses += $st
            $offKeys += $keyDisplay
        }
        $offNameSummary = ($offNames | Select-Object -Unique) -join " | "
        $offStatusSummary = if ($offStatuses -contains "Da kich hoat") { "Da kich hoat" } else { "Chua kich hoat" }
        $offKeySummary = $offKeys -join " | "
    } else {
        $offNameSummary = "Chua cai"
        $offStatusSummary = "Chua kich hoat"
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
        Write-Host "`n================ THÔNG TIN MÁY & TOÀN BỘ BẢN QUYỀN KEY ================" -ForegroundColor Green
        Write-Host ("  Thời gian check   : {0}" -f $dataObj.Thoi_Gian_Check)
        Write-Host ("  Tên máy           : {0}" -f $dataObj.Ten_May) -ForegroundColor Yellow
        Write-Host ("  UUID Mainboard    : {0}" -f $dataObj.UUID_Mainboard)
        Write-Host ("  Model Mainboard   : {0}" -f $dataObj.Model_Mainboard)
        Write-Host ("  Serial Mainboard  : {0}" -f $dataObj.Serial_Mainboard)
        Write-Host ("  Phiên bản Windows : {0}" -f $dataObj.Phien_Ban_Win)
        Write-Host ("  Trạng thái Win    : {0}" -f $dataObj.Trang_Thai_Win)
        Write-Host ("  Full Key Windows  : {0}" -f $dataObj.Key_Win_5_Cuoi) -ForegroundColor Cyan
        Write-Host ("  Phiên bản Office  : {0}" -f $dataObj.Phien_Ban_Office)
        Write-Host ("  Trạng thái Office : {0}" -f $dataObj.Trang_Thai_Office)
        Write-Host ("  Các Key Office    : {0}" -f $dataObj.Key_Office_5_Cuoi) -ForegroundColor Cyan
        Write-Host "========================================================================" -ForegroundColor Green
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

        Write-Host "`nChọn định dạng xuất file (lưu tại $folder):" -ForegroundColor Cyan
        Write-Host "  [1] Xuất/Cộng dồn vào file CSV (IT_Inventory_List.csv)"
        Write-Host "  [2] Xuất file TXT chi tiết (Info_$($dataObj.Ten_May).txt)"
        Write-Host "  [3] Xuất file JSON (Info_$($dataObj.Ten_May).json)"
        $sub = Read-Host "Chọn (1/2/3)"

        switch ($sub) {
            "1" {
                [PSCustomObject]$dataObj | Export-Csv -Path $csvPath -Append -NoTypeInformation -Encoding UTF8
                Write-Host "[+] Đã lưu cộng dồn vào: $csvPath" -ForegroundColor Green
            }
            "2" {
                $dataObj.GetEnumerator() | ForEach-Object { "{0,-20}: {1}" -f $_.Key, $_.Value } | Out-File -FilePath $txtPath -Encoding UTF8
                Write-Host "[+] Đã xuất file TXT: $txtPath" -ForegroundColor Green
            }
            "3" {
                $dataObj | ConvertTo-Json | Out-File -FilePath $jsonPath -Encoding UTF8
                Write-Host "[+] Đã xuất file JSON: $jsonPath" -ForegroundColor Green
            }
            default { Write-Host "[!] Lựa chọn không hợp lệ." -ForegroundColor Red }
        }
    }

    function Send-ToGoogleSheetsLocal {
        $pin = Read-Host "Nhập mã PIN bảo mật để đồng bộ"
        $dataObj.Secret_PIN = $pin

        $note = Read-Host "`nNhập ghi chú cho máy này (Bấm Enter để bỏ qua)"
        $dataObj.Ghi_Chu = $note
        $payload = $dataObj | ConvertTo-Json -Compress

        Write-Host "[*] Đang đồng bộ dữ liệu lên Google Sheets..." -ForegroundColor Yellow
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $res = Invoke-RestMethod -Uri $WEB_APP_URL -Method Post -Body ([System.Text.Encoding]::UTF8.GetBytes($payload)) -ContentType "text/plain; charset=utf-8"
            if ($res.status -eq "updated") {
                Write-Host "[+] THÀNH CÔNG! Đã cập nhật đè lên dòng #$($res.row) của máy $($dataObj.Ten_May) trên Google Sheets." -ForegroundColor Green
            } elseif ($res.status -eq "inserted") {
                Write-Host "[+] THÀNH CÔNG! Đã thêm mới máy $($dataObj.Ten_May) vào Google Sheets." -ForegroundColor Green
            } elseif ($res.status -eq "error") {
                Write-Host "[!] LỖI TỪ GOOGLE APPS SCRIPT: $($res.message)" -ForegroundColor Red
            } else {
                Write-Host "[+] Đã gửi dữ liệu! Phản hồi: $($res | ConvertTo-Json -Compress)" -ForegroundColor Green
            }
        } catch {
            Write-Host "[!] LỖI KẾT NỐI WEB APP: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    function Open-GoogleFormLocal {
        Write-Host "`nChọn chế độ mở Google Form:" -ForegroundColor Cyan
        Write-Host "  [1] Mở Google Form và Copy sẵn thông tin máy vào Clipboard"
        Write-Host "  [2] Mở Google Form trống"
        $fChoice = Read-Host "Chọn (1/2)"

        if ($fChoice -eq "1" -and $PREFILL_TEMPLATE -ne "") {
            $note = Read-Host "Nhập ghi chú kèm theo trên Form (Bấm Enter để bỏ qua)"
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

            Write-Host "[*] Đang mở Google Form (Đã điền sẵn thông tin máy)..." -ForegroundColor Green
            Start-Process $url
        } else {
            $clipText = "Tên máy: $($dataObj.Ten_May) | UUID: $($dataObj.UUID_Mainboard) | Main: $($dataObj.Model_Mainboard) | Serial: $($dataObj.Serial_Mainboard) | Win: $($dataObj.Phien_Ban_Win) ($($dataObj.Trang_Thai_Win) - $($dataObj.Key_Win_5_Cuoi)) | Office: $($dataObj.Phien_Ban_Office) ($($dataObj.Trang_Thai_Office) - $($dataObj.Key_Office_5_Cuoi))"
            Set-Clipboard -Value $clipText
            Write-Host "[+] Đã copy toàn bộ thông tin máy vào Clipboard!" -ForegroundColor Cyan
            Start-Process $GOOGLE_FORM_URL
        }
    }

    Show-TerminalInfoLocal

    while ($true) {
        Write-Host "`n==================== MENU QUẢN LÝ BẢN QUYỀN ====================" -ForegroundColor Cyan
        Write-Host "  [1] In lại thông tin bản quyền và phần cứng"
        Write-Host "  [2] Xuất dữ liệu ra File (CSV / TXT / JSON)"
        Write-Host "  [3] Đồng bộ trực tiếp lên Google Sheets (Auto API)"
        Write-Host "  [4] Mở Google Form (Tự động điền sẵn)"
        Write-Host "  [5] Mở bảng Google Sheets quản lý"
        Write-Host "  [6] Chạy tất cả: Xuất CSV + Đồng bộ Google Sheets"
        Write-Host "  [0] Quay lại Menu chính"
        Write-Host "=================================================================" -ForegroundColor Cyan
        $choice = Read-Host "Nhập lựa chọn của bạn (0-6)"

        switch ($choice) {
            "1" { Show-TerminalInfoLocal }
            "2" { Export-ToFileLocal }
            "3" { Send-ToGoogleSheetsLocal }
            "4" { Open-GoogleFormLocal }
            "5" {
                Write-Host "[*] Đang mở Google Sheets..." -ForegroundColor Green
                Start-Process $GOOGLE_SHEET_URL
            }
            "6" {
                $folder = Get-ExportFolder
                $csvPath = Join-Path $folder "IT_Inventory_List.csv"
                [PSCustomObject]$dataObj | Export-Csv -Path $csvPath -Append -NoTypeInformation -Encoding UTF8
                Write-Host "[+] Đã lưu file CSV tại: $csvPath" -ForegroundColor Green
                Send-ToGoogleSheetsLocal
            }
            "0" { return }
            default { Write-Host "[!] Vui lòng chọn từ 0 đến 6." -ForegroundColor Yellow }
        }
    }
}

Invoke-LicenseInventoryCheck
