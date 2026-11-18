# TM-WinCare - Dashboard & System Health Information
# Adheres to Section 3.1 of TM-WinCare-Architecture-v1.2.md

function Show-TMDashboard {
    Write-Header -Title "THÔNG TIN HỆ THỐNG & DASHBOARD"
    Write-InfoMessage "Đang tải thông tin phần cứng và hệ điều hành..."

    $sys = Get-TMSystemInfo
    Write-Host ""
    Show-PropertyGrid -Properties $sys -KeyWidth 25

    Write-Host ""
    Write-Host "  [1] Làm mới thông tin (Refresh)" -ForegroundColor Cyan
    Write-Host "  [2] Xuất báo cáo hệ thống ra file TXT" -ForegroundColor Cyan
    Write-Host "  [3] Xuất báo cáo hệ thống ra file JSON" -ForegroundColor Cyan
    Write-Host "  [0] Quay lại Menu chính" -ForegroundColor Yellow
    Write-Divider

    $sel = Read-MenuSelection -PromptText "Chọn thao tác" -Min 0 -Max 3
    switch ($sel) {
        1 { Show-TMDashboard }
        2 { Export-TMDashboardText -Properties $sys }
        3 { Export-TMDashboardJson -Properties $sys }
        0 { return }
    }
}

function Export-TMDashboardText {
    param ([System.Collections.IDictionary]$Properties)
    $reportDir = Join-Path $PSScriptRoot "../../../Logs"
    $filename = "SystemReport_" + (Get-Date).ToString("yyyyMMdd_HHmmss") + ".txt"
    $fullPath = Join-Path $reportDir $filename

    $lines = @()
    $lines += "========================================================="
    $lines += "         TM-WINCARE - BÁO CÁO THÔNG TIN HỆ THỐNG"
    $lines += "  Thời gian tạo: " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $lines += "========================================================="
    foreach ($k in $Properties.Keys) {
        $lines += ("{0,-28}: {1}" -f $k, $Properties[$k])
    }
    $lines += "========================================================="

    Set-Content -Path $fullPath -Value $lines -Encoding UTF8 -Force
    Write-Success "Đã xuất báo cáo ra file: $fullPath"
    Write-TMLog -TaskId "REPORT_TXT" -TaskName "Xuất báo cáo hệ thống" -Status "Success" -Message "Đã xuất file $filename"
    Pause-Screen
}

function Export-TMDashboardJson {
    param ([System.Collections.IDictionary]$Properties)
    $reportDir = Join-Path $PSScriptRoot "../../../Logs"
    $filename = "SystemReport_" + (Get-Date).ToString("yyyyMMdd_HHmmss") + ".json"
    $fullPath = Join-Path $reportDir $filename

    $obj = [ordered]@{
        generator = "TM-WinCare v$($global:TM_CONFIG.version)"
        timestamp = (Get-Date).ToString("o")
        system = $Properties
    }
    $json = $obj | ConvertTo-Json -Depth 4
    Set-Content -Path $fullPath -Value $json -Encoding UTF8 -Force
    Write-Success "Đã xuất báo cáo ra file: $fullPath"
    Write-TMLog -TaskId "REPORT_JSON" -TaskName "Xuất báo cáo hệ thống JSON" -Status "Success" -Message "Đã xuất file $filename"
    Pause-Screen
}
