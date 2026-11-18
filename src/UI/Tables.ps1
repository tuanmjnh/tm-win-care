# TM-WinCare - UI Tables and Property Grid formatting
# Compatible with PowerShell 5.1 & PowerShell 7

function Show-PropertyGrid {
    param (
        [System.Collections.IDictionary]$Properties,
        [int]$KeyWidth = 26
    )
    foreach ($key in $Properties.Keys) {
        $val = $Properties[$key]
        $displayKey = ($key.ToString() + ":").PadRight($KeyWidth)
        Write-Host "  $displayKey " -ForegroundColor Cyan -NoNewline
        if ($val -is [string] -and ($val -match "OK|Running|Active|Enabled|Activated|Healthy|Good")) {
            Write-Host $val -ForegroundColor Green
        }
        elseif ($val -is [string] -and ($val -match "Warning|Expired|Low|Disabled|Stopped|Degraded")) {
            Write-Host $val -ForegroundColor Yellow
        }
        elseif ($val -is [string] -and ($val -match "Error|Failed|Corrupt|Disconnected|Critical")) {
            Write-Host $val -ForegroundColor Red
        }
        else {
            Write-Host "$val" -ForegroundColor White
        }
    }
}

function Show-TableList {
    param (
        [array]$Items,
        [array]$Headers,
        [array]$PropertyNames,
        [array]$Widths
    )
    if (-not $Items -or $Items.Count -eq 0) {
        Write-Host "  (No data available)" -ForegroundColor DarkGray
        return
    }

    # Print Header
    $headerLine = "  "
    for ($i = 0; $i -lt $Headers.Count; $i++) {
        $w = if ($i -lt $Widths.Count) { $Widths[$i] } else { 20 }
        $headerLine += ($Headers[$i].ToString().PadRight($w)) + " "
    }
    Write-Host $headerLine -ForegroundColor Yellow
    Write-Host ("  " + ("-" * [math]::Min(75, ($headerLine.Length)))) -ForegroundColor DarkGray

    # Print Rows
    foreach ($item in $Items) {
        $rowLine = "  "
        for ($i = 0; $i -lt $Headers.Count; $i++) {
            $w = if ($i -lt $Widths.Count) { $Widths[$i] } else { 20 }
            $prop = $PropertyNames[$i]
            $val = if ($item -is [hashtable]) { $item[$prop] } else { $item.$prop }
            $strVal = if ($null -eq $val) { "" } else { $val.ToString() }
            if ($strVal.Length -gt $w) {
                $strVal = $strVal.Substring(0, [math]::Max(3, $w - 3)) + "..."
            }
            $rowLine += ($strVal.PadRight($w)) + " "
        }
        Write-Host $rowLine -ForegroundColor White
    }
}
