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
    Write-ErrorMessage "An error occurred while executing [$TaskId] $TaskName"
    if ($Context) {
        Write-InfoMessage "Context: $Context"
    }
    Write-Host "  Error details: $msg" -ForegroundColor Red

    # Log error
    Write-TMLog -TaskId $TaskId -TaskName $TaskName -Status "Failed" -Message "Error: $msg ($Context)"
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
