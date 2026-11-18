# TM-WinCare - Interactive Console Menu Engine
# Adheres to Section 10 of TM-WinCare-Architecture-v1.2.md

function Show-TMMenu {
    param (
        [string]$Title,
        [array]$MenuItems,
        [string]$ExitLabel = "Back"
    )

    while ($true) {
        Write-Header -Title $Title
        
        for ($i = 0; $i -lt $MenuItems.Count; $i++) {
            $num = $i + 1
            $item = $MenuItems[$i]
            $padNum = $num.ToString().PadLeft(2)
            Write-Host "  [$padNum] " -ForegroundColor Cyan -NoNewline
            Write-Host "$($item.Label)" -ForegroundColor White
        }

        Write-Host "  [ 0] " -ForegroundColor Yellow -NoNewline
        Write-Host "$ExitLabel" -ForegroundColor Yellow
        Write-Divider

        $selection = Read-MenuSelection -PromptText "Select an option" -Min 0 -Max $MenuItems.Count
        if ($selection -eq 0) {
            break
        }

        $chosen = $MenuItems[$selection - 1]
        if ($chosen.Action -is [scriptblock]) {
            try {
                & $chosen.Action
            } catch {
                Write-ErrorMessage "Menu item execution error: $($_.Exception.Message)"
            }
        }
    }
}
