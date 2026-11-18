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
        Write-ErrorMessage "Không tìm thấy danh mục Quick Commands."
        Pause-Screen
        return
    }

    while ($true) {
        Write-Header -Title "THƯ VIỆN LỆNH NHANH (QUICK COMMANDS)"
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

        Write-Host "  [ 0] Quay lại" -ForegroundColor Yellow
        Write-Divider

        $sel = Read-MenuSelection -PromptText "Chọn lệnh cần chạy" -Min 0 -Max $commands.Count
        if ($sel -eq 0) { break }

        $chosen = $commands[$sel - 1]
        Invoke-QuickCommandItem -CommandItem $chosen
    }
}

function Invoke-QuickCommandItem {
    param ($CommandItem)

    Write-SubHeader "THỰC THI LỆNH: $($CommandItem.name)"
    Write-InfoMessage "Nhóm chức năng: $($CommandItem.group)"
    Write-Host " Mô tả: $($CommandItem.description)" -ForegroundColor Gray
    Write-Host " Câu lệnh: " -ForegroundColor White -NoNewline
    Write-Host "$($CommandItem.command)" -ForegroundColor Cyan

    if ($CommandItem.requiresAdmin -and -not (Test-IsAdmin)) {
        Write-ErrorMessage "Lệnh này yêu cầu quyền Administrator để thực thi đầy đủ."
        if (-not (Request-Elevation -Reason "chạy lệnh '$($CommandItem.name)'")) {
            Pause-Screen
            return
        }
    }

    Write-Host ""
    Write-Host "  [1] Chạy lệnh ngay (Run)" -ForegroundColor Cyan
    Write-Host "  [2] Sao chép câu lệnh vào Clipboard (Copy)" -ForegroundColor Cyan
    Write-Host "  [0] Bỏ qua" -ForegroundColor Yellow
    Write-Divider

    $sel = Read-MenuSelection -PromptText "Chọn thao tác" -Min 0 -Max 2
    switch ($sel) {
        1 {
            Write-InfoMessage "Đang thực thi: $($CommandItem.command)..."
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
                    Write-Success "Đã khởi chạy công cụ: $exe"
                } catch {
                    Handle-TMException -TaskId $CommandItem.id -TaskName $CommandItem.name -Exception $_.Exception
                }
            } else {
                # CLI command
                & cmd.exe /c $CommandItem.command
                Write-Success "Lệnh hoàn tất với Exit Code: $LASTEXITCODE"
            }
            Write-TMLog -TaskId $CommandItem.id -TaskName $CommandItem.name -Status "Success" -Message "Đã chạy $($CommandItem.command)"
            Pause-Screen
        }
        2 {
            try {
                Set-Clipboard -Value $CommandItem.command
                Write-Success "Đã sao chép câu lệnh vào bộ nhớ tạm (Clipboard)!"
            } catch {
                Write-WarningMessage "Không thể sao chép tự động: $($_.Exception.Message)"
            }
            Pause-Screen
        }
        0 { return }
    }
}
