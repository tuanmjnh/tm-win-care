@echo off
chcp 65001 >nul
setlocal
title Cong Cu Quan Ly Cau Hinh ^& Full Key Windows/Office

:: Khoi chay PowerShell doc truc tiep phan code nam duoi nhan #_POWERSHELL_SCRIPT_#
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$batFile = '%~f0'; $lines = Get-Content -LiteralPath $batFile -Encoding UTF8; $idx = [Array]::IndexOf($lines, '#_POWERSHELL_SCRIPT_#'); $psCode = $lines[($idx + 1)..($lines.Length - 1)] -join \"`n\"; Invoke-Expression $psCode"

pause
exit /b

#_POWERSHELL_SCRIPT_#
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ==================== CAU HINH LINK CUA BAN ====================
# 1. Link Web App (Lay sau khi bam Deploy -> New deployment -> Web app)
$WEB_APP_URL      = "https://script.google.com/macros/s/AKfycbyY0fbv2IehFvC8oLCi9sFIYI_HHXNyF2WEfCBdKDOwkW-5MmjFyBacjqbHXfj4R5YI0w/exec"
# 2. Link Google Form cua ban (Da gan san)
$GOOGLE_FORM_URL  = "https://docs.google.com/forms/d/e/1FAIpQLSfrIXm1b_mpo0A_L0Ns4IUOElJSeAqYcOYtMY6REThZP8phKQ/viewform"
# 3. Link Pre-fill mau (Copy tu ket qua chay ham getFormConfigForBat dan vao day de tu dong dien Form)
$PREFILL_TEMPLATE = "https://docs.google.com/forms/d/e/1FAIpQLSfrIXm1b_mpo0A_L0Ns4IUOElJSeAqYcOYtMY6REThZP8phKQ/viewform?usp=pp_url&entry.149006453=__TEN_MAY__&entry.2097722978=__UUID__&entry.172201661=__MODEL__&entry.218557984=__SERIAL__&entry.2007771510=__WIN_VER__&entry.901102999=Da+kich+hoat&entry.1856982139=__WIN_KEY__&entry.610740607=__OFF_VER__&entry.695594658=Da+kich+hoat&entry.1357205106=__OFF_KEY__&entry.1710584041=__GHI_CHU__"
# 4. Link Google Sheets quan ly
$GOOGLE_SHEET_URL = "https://docs.google.com/spreadsheets/d/1GsDhi-PbcJylNoSbZaXqtzF92ZCOe12LkASalCUdHQQ/edit"
# ===============================================================

# Ham giai ma Full 25 ky tu Windows Key tu Registry DigitalProductId
function Get-RegistryProductKey($regPath) {
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

Write-Host "`n[*] Dang quet phan cung va giai ma toan bo Key Windows/Office..." -ForegroundColor Cyan

$cs = Get-CimInstance Win32_ComputerSystemProduct
$bb = Get-CimInstance Win32_BaseBoard
$os = Get-CimInstance Win32_OperatingSystem
$sls = Get-CimInstance SoftwareLicensingService

# 1. Lay Full Key Windows (Registry + Backup Key + BIOS OEM Key)
$winRegKey = Get-RegistryProductKey "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
$winBackupKey = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" -ErrorAction SilentlyContinue).BackupProductKeyDefault
$winOemKey = $sls.OA3xOriginalProductKey

$winAllLic = Get-CimInstance SoftwareLicensingProduct | Where-Object { $_.ApplicationID -eq '55c92734-d682-4d71-983e-d6ec3f16059f' -and $_.PartialProductKey } | Sort-Object LicenseStatus -Descending
$winActiveLic = $winAllLic | Select-Object -First 1
$winStatus = if ($winActiveLic -and $winActiveLic.LicenseStatus -eq 1) { "Da kich hoat" } else { "Chua kich hoat" }
$winPartial = if ($winActiveLic -and $winActiveLic.PartialProductKey) { $winActiveLic.PartialProductKey } else { "N/A" }

# So khop de hien thi Full Key Windows chinh xac nhat
$winFullList = @()
if ($winRegKey) { $winFullList += "Active: $winRegKey" }
if ($winBackupKey -and $winBackupKey -ne $winRegKey) { $winFullList += "Backup: $winBackupKey" }
if ($winOemKey) { $winFullList += "OEM-BIOS: $winOemKey" }
if ($winFullList.Count -eq 0) { $winFullList += "5-Cuoi: $winPartial" }
$winKeySummary = $winFullList -join " | "

# 2. Lay TOAN BO cac ban Office & Key Office tren may
$offAllLic = @(Get-CimInstance SoftwareLicensingProduct | Where-Object { $_.Name -like '*Office*' -and $_.PartialProductKey })
if ($offAllLic.Count -eq 0) {
    $offAllLic = @(Get-CimInstance OfficeSoftwareProtectionProduct -ErrorAction SilentlyContinue | Where-Object { $_.PartialProductKey })
}

# Thu giai ma Full Key Office neu la ban cu luu trong Registry
$offRegKeys = @()
$offRegPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Office\*\Registration\*",
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Office\*\Registration\*"
)
foreach ($p in $offRegPaths) {
    Get-ItemProperty -Path $p -ErrorAction SilentlyContinue | ForEach-Object {
        $k = Get-RegistryProductKey $_.PSPath
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

        # Kiem tra xem co Full Key trong Registry trung 5 ky tu cuoi khong
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
    "UUID_Mainboard"    = if ($cs.UUID) { $cs.UUID } else { "N/A" }
    "Model_Mainboard"   = "$($bb.Manufacturer) $($bb.Product)".Trim()
    "Serial_Mainboard"  = if ($bb.SerialNumber) { $bb.SerialNumber } else { "N/A" }
    "Phien_Ban_Win"     = ($os.Caption -replace 'Microsoft ', '').Trim()
    "Trang_Thai_Win"    = $winStatus
    "Key_Win_5_Cuoi"    = $winKeySummary
    "Phien_Ban_Office"  = $offNameSummary
    "Trang_Thai_Office" = $offStatusSummary
    "Key_Office_5_Cuoi" = $offKeySummary
    "Nguon_Nhap"        = "Script .bat"
    "Ghi_Chu"           = ""
    "Cap_Nhat_Trung"    = $true
}

function Show-TerminalInfo {
    Write-Host "`n================ THONG TIN MAY & TOAN BO KEY ================" -ForegroundColor Green
    Write-Host ("  Thoi gian check   : {0}" -f $dataObj.Thoi_Gian_Check)
    Write-Host ("  Ten may           : {0}" -f $dataObj.Ten_May) -ForegroundColor Yellow
    Write-Host ("  UUID Mainboard    : {0}" -f $dataObj.UUID_Mainboard)
    Write-Host ("  Model Mainboard   : {0}" -f $dataObj.Model_Mainboard)
    Write-Host ("  Serial Mainboard  : {0}" -f $dataObj.Serial_Mainboard)
    Write-Host ("  Phien ban Windows : {0}" -f $dataObj.Phien_Ban_Win)
    Write-Host ("  Trang thai Win    : {0}" -f $dataObj.Trang_Thai_Win)
    Write-Host ("  Full Key Windows  : {0}" -f $dataObj.Key_Win_5_Cuoi) -ForegroundColor Cyan
    Write-Host ("  Phien ban Office  : {0}" -f $dataObj.Phien_Ban_Office)
    Write-Host ("  Trang thai Office : {0}" -f $dataObj.Trang_Thai_Office)
    Write-Host ("  Cac Key Office    : {0}" -f $dataObj.Key_Office_5_Cuoi) -ForegroundColor Cyan
    Write-Host "=============================================================" -ForegroundColor Green
}

function Export-ToFile {
    $folder = Split-Path -Parent $batFile
    $csvPath = Join-Path $folder "IT_Inventory_List.csv"
    $txtPath = Join-Path $folder ("Info_" + $dataObj.Ten_May + ".txt")
    $jsonPath = Join-Path $folder ("Info_" + $dataObj.Ten_May + ".json")

    Write-Host "`nChon dinh dang xuat file:" -ForegroundColor Cyan
    Write-Host "  [1] Xuat/Cong don vao file CSV (IT_Inventory_List.csv - Mo bang Excel)"
    Write-Host "  [2] Xuat file TXT chi tiet (Info_$($dataObj.Ten_May).txt)"
    Write-Host "  [3] Xuat file JSON (Info_$($dataObj.Ten_May).json)"
    $sub = Read-Host "Chon (1/2/3)"

    switch ($sub) {
        "1" {
            [PSCustomObject]$dataObj | Export-Csv -Path $csvPath -Append -NoTypeInformation -Encoding UTF8
            Write-Host "[+] Da luu cong don vao: $csvPath" -ForegroundColor Green
        }
        "2" {
            $dataObj.GetEnumerator() | ForEach-Object { "{0,-20}: {1}" -f $_.Key, $_.Value } | Out-File -FilePath $txtPath -Encoding UTF8
            Write-Host "[+] Da xuat file TXT: $txtPath" -ForegroundColor Green
        }
        "3" {
            $dataObj | ConvertTo-Json | Out-File -FilePath $jsonPath -Encoding UTF8
            Write-Host "[+] Da xuat file JSON: $jsonPath" -ForegroundColor Green
        }
        default { Write-Host "[!] Lua chon khong hop le." -ForegroundColor Red }
    }
}

function Send-ToGoogleSheets {
	$pin = Read-Host "Nhap ma PIN bao mat de dong bo"
	$dataObj.Secret_PIN = $pin

    $note = Read-Host "`nNhap ghi chu cho may nay (Bam Enter de bo qua)"
    $dataObj.Ghi_Chu = $note
    $payload = $dataObj | ConvertTo-Json -Compress

    Write-Host "[*] Dang dong bo du lieu len Google Sheets..." -ForegroundColor Yellow
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $res = Invoke-RestMethod -Uri $WEB_APP_URL -Method Post -Body ([System.Text.Encoding]::UTF8.GetBytes($payload)) -ContentType "text/plain; charset=utf-8"
        if ($res.status -eq "updated") {
            Write-Host "[+] THANH CONG! Da cap nhat de len dong #$($res.row) cua may $($dataObj.Ten_May) tren Google Sheets." -ForegroundColor Green
        } elseif ($res.status -eq "inserted") {
            Write-Host "[+] THANH CONG! Da them moi may $($dataObj.Ten_May) vao Google Sheets." -ForegroundColor Green
        } elseif ($res.status -eq "error") {
            Write-Host "[!] LOI TU GOOGLE APPS SCRIPT: $($res.message)" -ForegroundColor Red
        } else {
            Write-Host "[+] Da gui du lieu! Phan hoi: $($res | ConvertTo-Json -Compress)" -ForegroundColor Green
        }
    } catch {
        Write-Host "[!] LOI KET NOI WEB APP: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Open-GoogleForm {
    Write-Host "`nChon che do mo Google Form:" -ForegroundColor Cyan
    Write-Host "  [1] Mo Google Form va Copy san thong tin may vao Clipboard (Ctrl+V)"
    Write-Host "  [2] Mo Google Form trong de tu nhap tay"
    $fChoice = Read-Host "Chon (1/2)"

    if ($fChoice -eq "1" -and $PREFILL_TEMPLATE -ne "") {
        $note = Read-Host "Nhap ghi chu kem theo tren Form (Bam Enter de bo qua)"
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

        Write-Host "[*] Dang mo Google Form (Da dien san thong tin may)..." -ForegroundColor Green
        Start-Process $url
    } else {
        if ($fChoice -eq "1") {
            $clipText = "Ten may: $($dataObj.Ten_May) | UUID: $($dataObj.UUID_Mainboard) | Main: $($dataObj.Model_Mainboard) | Serial: $($dataObj.Serial_Mainboard) | Win: $($dataObj.Phien_Ban_Win) ($($dataObj.Trang_Thai_Win) - $($dataObj.Key_Win_5_Cuoi)) | Office: $($dataObj.Phien_Ban_Office) ($($dataObj.Trang_Thai_Office) - $($dataObj.Key_Office_5_Cuoi))"
            Set-Clipboard -Value $clipText
            Write-Host "[+] Da copy toan bo thong tin may vao Clipboard!" -ForegroundColor Cyan
        }
        Write-Host "[*] Dang mo Google Form tren trinh duyet..." -ForegroundColor Green
        Start-Process $GOOGLE_FORM_URL
    }
}

Show-TerminalInfo

while ($true) {
    Write-Host "`n==================== MENU TUY CHON ====================" -ForegroundColor Cyan
    Write-Host "  [1] In lai thong tin chi tiet ra Terminal"
    Write-Host "  [2] Export du lieu ra File (CSV / TXT / JSON)"
    Write-Host "  [3] Dong bo thang len Google Sheets (Auto API)"
    Write-Host "  [4] Mo Google Form (Tu dong dien san hoac Nhap tay)"
    Write-Host "  [5] Mo bang Google Sheets quan ly"
    Write-Host "  [6] Chay Tat Ca: Xuat CSV + Dong bo Google Sheets"
    Write-Host "  [0] Thoat"
    Write-Host "=======================================================" -ForegroundColor Cyan
    $choice = Read-Host "Nhap lua chon cua ban (0-6)"

    switch ($choice) {
        "1" { Show-TerminalInfo }
        "2" { Export-ToFile }
        "3" { Send-ToGoogleSheets }
        "4" { Open-GoogleForm }
        "5" {
            Write-Host "[*] Dang mo Google Sheets..." -ForegroundColor Green
            Start-Process $GOOGLE_SHEET_URL
        }
        "6" {
            $folder = Split-Path -Parent $batFile
            $csvPath = Join-Path $folder "IT_Inventory_List.csv"
            [PSCustomObject]$dataObj | Export-Csv -Path $csvPath -Append -NoTypeInformation -Encoding UTF8
            Write-Host "[+] Da luu file CSV tai: $csvPath" -ForegroundColor Green
            Send-ToGoogleSheets
        }
        "0" { break }
        default { Write-Host "[!] Vui long chon tu 0 den 6." -ForegroundColor Yellow }
    }
}