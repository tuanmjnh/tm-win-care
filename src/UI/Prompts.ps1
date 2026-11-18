# TM-WinCare - User Interaction & Prompts
# Compatible with PowerShell 5.1 & PowerShell 7

function Read-MenuSelection {
    param (
        [string]$PromptText = "Select an option",
        [int]$Min = 0,
        [int]$Max = 99
    )
    while ($true) {
        Write-Host ""
        Write-Host " $PromptText [$Min-$Max]: " -ForegroundColor Cyan -NoNewline
        $inputVal = Read-Host
        if ($inputVal -match "^\d+$") {
            $num = [int]$inputVal
            if ($num -ge $Min -and $num -le $Max) {
                return $num
            }
        }
        Write-ErrorMessage "Please enter a valid number between $Min and $Max."
    }
}

function Confirm-Action {
    param (
        [string]$TaskName,
        [string]$ImpactDescription,
        [string]$RiskLevel = "medium",
        [bool]$RequiresKeyword = $false
    )
    Write-Host ""
    Write-Host "=========================================================" -ForegroundColor Yellow
    Write-Host " CONFIRM ACTION: $TaskName" -ForegroundColor White
    Write-Host " Risk Level: $RiskLevel" -ForegroundColor Yellow
    if ($ImpactDescription) {
        Write-Host " Impact:" -ForegroundColor Gray
        Write-Host "   $ImpactDescription" -ForegroundColor Gray
    }
    Write-Host "=========================================================" -ForegroundColor Yellow

    if ($RequiresKeyword -or $RiskLevel -eq "high") {
        Write-Host " High-risk action. Type 'APPLY' to confirm, or press any other key to cancel: " -ForegroundColor Red -NoNewline
        $ans = Read-Host
        return ($ans.Trim() -eq "APPLY")
    }

    Write-Host " Are you sure you want to proceed? (Y/N): " -ForegroundColor Cyan -NoNewline
    $ans = Read-Host
    return ($ans.Trim().ToUpper() -eq "Y")
}

function Read-SecurePassword {
    param (
        [string]$PromptText = "Enter password"
    )
    Write-Host " $($PromptText): " -ForegroundColor Cyan -NoNewline
    $sec = Read-Host -AsSecureString
    return $sec
}

function Pause-Screen {
    param (
        [string]$Message = "Press Enter to return to menu..."
    )
    Write-Host ""
    Write-Host " $Message" -ForegroundColor DarkGray
    [void][System.Console]::ReadLine()
}
