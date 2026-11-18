# TM-WinCare - Task Confirmation & Safety Gate
# Adheres to Section 1 & Section 13 of TM-WinCare-Architecture-v1.2.md

function Test-TaskApproval {
    param (
        [string]$TaskId,
        [string]$TaskName,
        [string]$ImpactDescription,
        [string]$RiskLevel = "low",
        [bool]$RequiresAdmin = $false
    )
    
    # 1. Elevation check
    if ($RequiresAdmin -and -not (Test-IsAdmin)) {
        if (-not (Request-Elevation -Reason "execute task '$TaskName'")) {
            Write-SkipMessage "Task '$TaskName' skipped due to missing Administrator privileges."
            return $false
        }
    }

    # 2. Risk confirmation
    $approved = Confirm-Action -TaskName $TaskName -ImpactDescription $ImpactDescription -RiskLevel $RiskLevel
    if (-not $approved) {
        Write-SkipMessage "User cancelled task '$TaskName'."
        Write-TMLog -TaskId $TaskId -TaskName $TaskName -Status "Skipped" -Message "Cancelled by user"
        return $false
    }

    return $true
}
