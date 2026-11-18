# TM-WinCare - Windows Post-Install Configuration
# Adheres to Section 3.2 of TM-WinCare-Architecture-v1.2.md

. (Join-Path $PSScriptRoot "CheckLicense.ps1")

function Show-TMPostInstallMenu {
    $menuItems = @(
        @{ Label = "Quản lý bản quyền Windows & Office (IT Inventory Full Key)"; Action = { Invoke-LicenseInventoryCheck } },
        @{ Label = "Đổi tên máy tính (Rename Computer)"; Action = { Invoke-RenameComputer } },
        @{ Label = "Bật hiển thị đuôi mở rộng file (.exe, .txt...)"; Action = { Set-ExplorerShowFileExtensions -Enable $true } },
        @{ Label = "Tắt hiển thị đuôi mở rộng file"; Action = { Set-ExplorerShowFileExtensions -Enable $false } },
        @{ Label = "Bật hiển thị file và thư mục ẩn"; Action = { Set-ExplorerShowHiddenFiles -Enable $true } },
        @{ Label = "Tắt hiển thị file và thư mục ẩn"; Action = { Set-ExplorerShowHiddenFiles -Enable $false } },
        @{ Label = "Kiểm tra thiết bị thiếu driver / bị lỗi (Device Errors)"; Action = { Test-DeviceErrors } },
        @{ Label = "Mở cài đặt Ngày giờ & Ngôn ngữ (Date & Time)"; Action = { Start-Process "timedate.cpl" } },
        @{ Label = "Mở cài đặt Windows Update"; Action = { Start-Process "ms-settings:windowsupdate" } },
        @{ Label = "Mở trang Kích hoạt Windows (Activation)"; Action = { Start-Process "ms-settings:activation" } },
        @{ Label = "Mở thư mục Khởi động (Startup Folder)"; Action = { Start-Process "explorer.exe" "shell:startup" } },
        @{ Label = "Mở Cấu hình Nguồn điện (Power Options)"; Action = { Start-Process "powercfg.cpl" } }
    )
    Show-TMMenu -Title "CẤU HÌNH HẬU CÀI ĐẶT WINDOWS (POST-INSTALL)" -MenuItems $menuItems -ExitLabel "Quay lại"
}

function Invoke-RenameComputer {
    if (-not (Assert-Admin "đổi tên máy tính")) {
        Pause-Screen
        return
    }

    $currentName = [System.Environment]::MachineName
    Write-SubHeader "ĐỔI TÊN MÁY TÍNH"
    Write-InfoMessage "Tên máy hiện tại: $currentName"
    Write-Host " Nhập tên máy mới (chữ, số và dấu gạch ngang, tối đa 15 ký tự): " -ForegroundColor Cyan -NoNewline
    $newName = Read-Host

    if ([string]::IsNullOrWhiteSpace($newName) -or $newName -match '[^a-zA-Z0-9\-]') {
        Write-ErrorMessage "Tên máy không hợp lệ. Chỉ chấp nhận ký tự a-z, 0-9 và dấu gạch ngang (-)."
        Pause-Screen
        return
    }

    if ($newName.Length -gt 15) {
        Write-ErrorMessage "Tên máy tính trên Windows không nên vượt quá 15 ký tự NetBIOS."
        Pause-Screen
        return
    }

    if ($newName.ToUpper() -eq $currentName.ToUpper()) {
        Write-WarningMessage "Tên mới trùng với tên máy hiện tại."
        Pause-Screen
        return
    }

    $approved = Confirm-Action -TaskName "Đổi tên máy tính" -ImpactDescription "Đổi tên máy từ '$currentName' thành '$newName'. Yêu cầu khởi động lại máy để áp dụng." -RiskLevel "medium"
    if ($approved) {
        try {
            Rename-Computer -NewName $newName -Force -ErrorAction Stop
            Write-Success "Đổi tên máy tính thành công thành '$newName'!"
            Write-WarningMessage "Bạn CẦN KHỞI ĐỘNG LẠI máy tính để tên mới có hiệu lực."
            Write-TMLog -TaskId "POST_RENAME" -TaskName "Đổi tên máy tính" -Status "Success" -Message "Đổi tên từ $currentName sang $newName" -RequiresRestart $true
        } catch {
            Handle-TMException -TaskId "POST_RENAME" -TaskName "Đổi tên máy tính" -Exception $_.Exception
        }
    }
    Pause-Screen
}

function Set-ExplorerShowFileExtensions {
    param ([bool]$Enable)
    $val = if ($Enable) { 0 } else { 1 }
    $actionDesc = if ($Enable) { "Bật hiển thị phần mở rộng của file" } else { "Ẩn phần mở rộng của file" }
    
    try {
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        Set-ItemProperty -Path $regPath -Name "HideFileExt" -Value $val -Force
        Write-Success "Đã cập nhật cấu hình: $actionDesc."
        Write-InfoMessage "Lưu ý: Bạn có thể cần mở lại File Explorer để thay đổi hiển thị."
        Write-TMLog -TaskId "POST_FILEEXT" -TaskName $actionDesc -Status "Success" -Message "HideFileExt = $val"
    } catch {
        Handle-TMException -TaskId "POST_FILEEXT" -TaskName $actionDesc -Exception $_.Exception
    }
    Pause-Screen
}

function Set-ExplorerShowHiddenFiles {
    param ([bool]$Enable)
    $val = if ($Enable) { 1 } else { 2 }
    $actionDesc = if ($Enable) { "Hiển thị file và thư mục ẩn" } else { "Ẩn file và thư mục ẩn" }

    try {
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        Set-ItemProperty -Path $regPath -Name "Hidden" -Value $val -Force
        Write-Success "Đã cập nhật cấu hình: $actionDesc."
        Write-TMLog -TaskId "POST_HIDDEN" -TaskName $actionDesc -Status "Success" -Message "Hidden = $val"
    } catch {
        Handle-TMException -TaskId "POST_HIDDEN" -TaskName $actionDesc -Exception $_.Exception
    }
    Pause-Screen
}

function Test-DeviceErrors {
    Write-SubHeader "KIỂM TRA THIẾT BỊ LỖI / THIẾU DRIVER"
    Write-InfoMessage "Đang truy vấn Plug and Play Entity..."

    try {
        $problemDevices = Get-CimInstance -ClassName Win32_PnPEntity | Where-Object { $_.ConfigManagerErrorCode -ne 0 -and $null -ne $_.ConfigManagerErrorCode }
        if (-not $problemDevices -or @($problemDevices).Count -eq 0) {
            Write-Success "Tuyệt vời! Không phát hiện thiết bị nào bị lỗi hoặc thiếu driver trên hệ thống."
        } else {
            Write-WarningMessage "Phát hiện $(@($problemDevices).Count) thiết bị đang gặp sự cố:"
            $headers = @("Tên thiết bị", "Mã lỗi PnP", "Hardware ID")
            $props = @("Name", "ConfigManagerErrorCode", "DeviceID")
            $widths = @(30, 15, 30)
            Show-TableList -Items $problemDevices -Headers $headers -PropertyNames $props -Widths $widths
            Write-Host ""
            Write-InfoMessage "Gợi ý: Mở Device Manager để cập nhật driver cho các thiết bị trên."
        }
    } catch {
        Handle-TMException -TaskId "DEV_CHECK" -TaskName "Kiểm tra thiết bị" -Exception $_.Exception
    }
    Pause-Screen
}
