# TM-WinCare - Centralized Error Handling
# Adheres to Section 11 & Section 17 of TM-WinCare-Architecture-v1.2.md

function Handle-TMException {
    param (
        [string]$TaskId,
        [string]$TaskName,
        [System.Exception]$Exception,
        [string]$Context = ""
    )
    $msg = $Exception.Message
    Write-ErrorMessage "Đã xảy ra lỗi trong quá trình thực hiện [$TaskId] $TaskName"
    if ($Context) {
        Write-InfoMessage "Ngữ cảnh: $Context"
    }
    Write-Host "  Chi tiết lỗi: $msg" -ForegroundColor Red

    # Log error
    Write-TMLog -TaskId $TaskId -TaskName $TaskName -Status "Failed" -Message "Lỗi: $msg ($Context)"
}

function Invoke-TMSafeBlock {
    param (
        [string]$TaskId,
        [string]$TaskName,
        [scriptblock]$Action,
        [string]$Context = ""
    )
    try {
        & $Action
    } catch {
        Handle-TMException -TaskId $TaskId -TaskName $TaskName -Exception $_.Exception -Context $Context
    }
}
