# TM-WinCare - User Interaction & Prompts
# Compatible with PowerShell 5.1 & PowerShell 7

function Read-MenuSelection {
    param (
        [string]$PromptText = "Lựa chọn của bạn",
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
        Write-ErrorMessage "Vui lòng nhập một số hợp lệ từ $Min đến $Max."
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
    Write-Host " XÁC NHẬN THỰC HIỆN TÁC VỤ: $TaskName" -ForegroundColor White
    Write-Host " Mức độ rủi ro: $RiskLevel" -ForegroundColor Yellow
    if ($ImpactDescription) {
        Write-Host " Ảnh hưởng:" -ForegroundColor Gray
        Write-Host "   $ImpactDescription" -ForegroundColor Gray
    }
    Write-Host "=========================================================" -ForegroundColor Yellow

    if ($RequiresKeyword -or $RiskLevel -eq "high") {
        Write-Host " Tác vụ có rủi ro cao. Nhập 'APPLY' để xác nhận thực hiện, hoặc bấm phím khác để hủy:" -ForegroundColor Red -NoNewline
        $ans = Read-Host
        return ($ans.Trim() -eq "APPLY")
    }

    Write-Host " Bạn có chắc chắn muốn tiếp tục? (Y/N): " -ForegroundColor Cyan -NoNewline
    $ans = Read-Host
    return ($ans.Trim().ToUpper() -eq "Y")
}

function Read-SecurePassword {
    param (
        [string]$PromptText = "Nhập mật khẩu"
    )
    Write-Host " $($PromptText): " -ForegroundColor Cyan -NoNewline
    $sec = Read-Host -AsSecureString
    return $sec
}

function Pause-Screen {
    param (
        [string]$Message = "Nhấn Enter để quay lại menu..."
    )
    Write-Host ""
    Write-Host " $Message" -ForegroundColor DarkGray
    [void][System.Console]::ReadLine()
}
