# TM-WinCare - Quick Commands Library
# Adheres to Section 7 of TM-WinCare-Architecture-v1.2.md

function Get-QuickCommandsList {
    if ($global:TM_EMBEDDED_QUICK_COMMANDS) {
        return $global:TM_EMBEDDED_QUICK_COMMANDS
    }
    $catalogPath = if ($PSScriptRoot) { Join-Path $PSScriptRoot "../../../data/command-catalog/quick-commands.json" } else { "" }
    if ($catalogPath -and (Test-Path $catalogPath)) {
        return Get-Content -Path $catalogPath -Raw -Encoding UTF8 | ConvertFrom-Json
    }
    return @()
}

function Show-TMQuickCommandsMenu {
    $commands = Get-QuickCommandsList
    if (-not $commands -or $commands.Count -eq 0) {
        Write-ErrorMessage "Quick Commands catalog not found."
        Pause-Screen
        return
    }

    while ($true) {
        Write-Header -Title "QUICK COMMANDS & APPLET LAUNCHER"
        for ($i = 0; $i -lt $commands.Count; $i++) {
            $cmd = $commands[$i]
            $num = ($i + 1).ToString().PadLeft(2)
            $adminBadge = if ($cmd.requiresAdmin) { "[Admin] " } else { "        " }
            $groupBadge = "[$($cmd.group)]".PadRight(10)
            Write-Host "  [$num] " -ForegroundColor Cyan -NoNewline
            Write-Host "$groupBadge " -ForegroundColor Yellow -NoNewline
            Write-Host "$adminBadge" -ForegroundColor $(if ($cmd.requiresAdmin) { "Red" } else { "DarkGray" }) -NoNewline
            Write-Host "$($cmd.name)" -ForegroundColor White
        }

        Write-Host "  [ 0] Back" -ForegroundColor Yellow
        Write-Divider

        $sel = Read-MenuSelection -PromptText "Select command to execute" -Min 0 -Max $commands.Count
        if ($sel -eq 0) { break }

        $chosen = $commands[$sel - 1]
        Invoke-QuickCommandItem -CommandItem $chosen
    }
}

function Invoke-QuickCommandItem {
    param ($CommandItem)

    Write-SubHeader "EXECUTE COMMAND: $($CommandItem.name)"
    Write-InfoMessage "Category : $($CommandItem.group)"
    Write-Host " Description : $($CommandItem.description)" -ForegroundColor Gray
    Write-Host " Command Line: " -ForegroundColor White -NoNewline
    Write-Host "$($CommandItem.command)" -ForegroundColor Cyan

    if ($CommandItem.requiresAdmin -and -not (Test-IsAdmin)) {
        Write-ErrorMessage "This command requires Administrator privileges."
        if (-not (Request-Elevation -Reason "execute '$($CommandItem.name)'")) {
            Pause-Screen
            return
        }
    }

    Write-Host ""
    Write-Host "  [1] Execute command now" -ForegroundColor Cyan
    Write-Host "  [2] Copy command string to Clipboard" -ForegroundColor Cyan
    Write-Host "  [0] Cancel" -ForegroundColor Yellow
    Write-Divider

    $sel = Read-MenuSelection -PromptText "Select an option" -Min 0 -Max 2
    switch ($sel) {
        1 {
            Write-InfoMessage "Executing: $($CommandItem.command)..."
            Write-Host ""
            if ($CommandItem.type -eq "process") {
                try {
                    $parts = $CommandItem.command.Split(' ', 2)
                    $exe = $parts[0]
                    $args = if ($parts.Length -gt 1) { $parts[1] } else { "" }
                    if ($args) {
                        Start-Process -FilePath $exe -ArgumentList $args
                    } else {
                        Start-Process -FilePath $exe
                    }
                    Write-Success "Process started: $exe"
                } catch {
                    Handle-TMException -TaskId $CommandItem.id -TaskName $CommandItem.name -Exception $_.Exception
                }
            } else {
                & cmd.exe /c $CommandItem.command
                Write-Success "Command completed with Exit Code: $LASTEXITCODE"
            }
            Write-TMLog -TaskId $CommandItem.id -TaskName $CommandItem.name -Status "Success" -Message "Executed $($CommandItem.command)"
            Pause-Screen
        }
        2 {
            try {
                Set-Clipboard -Value $CommandItem.command
                Write-Success "Command copied to Clipboard!"
            } catch {
                Write-WarningMessage "Could not copy automatically: $($_.Exception.Message)"
            }
            Pause-Screen
        }
        0 { return }
    }
}
