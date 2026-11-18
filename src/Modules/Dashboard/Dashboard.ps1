# TM-WinCare - Dashboard & System Health Information
# Adheres to Section 3.1 of TM-WinCare-Architecture-v1.2.md

function Show-TMDashboard {
    Write-Header -Title "SYSTEM INFORMATION & HEALTH DASHBOARD"
    Write-InfoMessage "Loading hardware and operating system metrics..."

    $sys = Get-TMSystemInfo
    Write-Host ""
    Show-PropertyGrid -Properties $sys -KeyWidth 28

    Write-Host ""
    Write-Host "  [1] Refresh Information" -ForegroundColor Cyan
    Write-Host "  [2] Export System Report to TXT" -ForegroundColor Cyan
    Write-Host "  [3] Export System Report to JSON" -ForegroundColor Cyan
    Write-Host "  [0] Back to Main Menu" -ForegroundColor Yellow
    Write-Divider

    $sel = Read-MenuSelection -PromptText "Select an option" -Min 0 -Max 3
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
    $lines += "         TM-WINCARE - SYSTEM DIAGNOSTIC REPORT"
    $lines += "  Generated: " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $lines += "========================================================="
    foreach ($k in $Properties.Keys) {
        $lines += ("{0,-28}: {1}" -f $k, $Properties[$k])
    }
    $lines += "========================================================="

    Set-Content -Path $fullPath -Value $lines -Encoding UTF8 -Force
    Write-Success "Report exported to file: $fullPath"
    Write-TMLog -TaskId "REPORT_TXT" -TaskName "Export System Report" -Status "Success" -Message "Exported $filename"
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
    Write-Success "Report exported to file: $fullPath"
    Write-TMLog -TaskId "REPORT_JSON" -TaskName "Export System Report JSON" -Status "Success" -Message "Exported $filename"
    Pause-Screen
}
