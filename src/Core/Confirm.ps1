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
        if (-not (Request-Elevation -Reason "thực hiện tác vụ '$TaskName'")) {
            Write-SkipMessage "Đã bỏ qua tác vụ '$TaskName' do thiếu quyền Administrator."
            return $false
        }
    }

    # 2. Risk confirmation
    $approved = Confirm-Action -TaskName $TaskName -ImpactDescription $ImpactDescription -RiskLevel $RiskLevel
    if (-not $approved) {
        Write-SkipMessage "Người dùng đã từ chối thực hiện tác vụ '$TaskName'."
        Write-TMLog -TaskId $TaskId -TaskName $TaskName -Status "Skipped" -Message "Bỏ qua bởi người dùng"
        return $false
    }

    return $true
}
