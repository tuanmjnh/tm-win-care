# TM-WinCare - Privacy, Notifications & Copilot Module
# Adheres to Section 7C of TM-WinCare-Architecture-v1.2.md

function Show-TMPrivacyMenu {
    $menuItems = @(
        @{ Label = "Bật / Tắt nút Copilot trên thanh Taskbar (Windows 11)"; Action = { Toggle-CopilotTaskbar } },
        @{ Label = "Tắt gợi ý & quảng cáo mẹo vặt của Windows (Tips & Suggestions)"; Action = { Disable-WindowsTips } },
        @{ Label = "Bật / Tắt Widget trên thanh Taskbar (Windows 11)"; Action = { Toggle-TaskbarWidgets } },
        @{ Label = "Mở cài đặt Thông báo (Notifications & Actions)"; Action = { Start-Process "ms-settings:notifications" } },
        @{ Label = "Mở cài đặt Quyền riêng tư (Privacy & Security)"; Action = { Start-Process "ms-settings:privacy" } },
        @{ Label = "Mở cấu hình phạm vi Search Indexing (Giảm tải ổ đĩa)"; Action = { Start-Process "control.exe" "srchadmin.dll" } }
    )
    Show-TMMenu -Title "QUYỀN RIÊNG TƯ & THÀNH PHẦN WINDOWS (PRIVACY & COPILOT)" -MenuItems $menuItems -ExitLabel "Quay lại"
}

function Toggle-CopilotTaskbar {
    Write-SubHeader "BẬT / TẮT NÚT COPILOT TRÊN TASKBAR"
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    try {
        $current = (Get-ItemProperty -Path $regPath -Name "ShowCopilotButton" -ErrorAction SilentlyContinue).ShowCopilotButton
        $statusStr = if ($current -eq 0) { "Đang ẩn (Tắt)" } else { "Đang hiện (Bật)" }
        Write-InfoMessage "Trạng thái nút Copilot hiện tại: $statusStr"

        Write-Host " [1] Ẩn nút Copilot" -ForegroundColor Cyan
        Write-Host " [2] Hiện nút Copilot" -ForegroundColor Cyan
        Write-Host " [0] Quay lại" -ForegroundColor Yellow
        $sel = Read-MenuSelection -Min 0 -Max 2
        switch ($sel) {
            1 {
                Set-ItemProperty -Path $regPath -Name "ShowCopilotButton" -Value 0 -Force
                Write-Success "Đã ẩn nút Copilot trên Taskbar."
                Write-InfoMessage "Có thể cần khởi động lại Explorer để cập nhật ngay."
            }
            2 {
                Set-ItemProperty -Path $regPath -Name "ShowCopilotButton" -Value 1 -Force
                Write-Success "Đã bật hiển thị nút Copilot trên Taskbar."
            }
        }
    } catch {
        Handle-TMException -TaskId "PRIV_COPILOT" -TaskName "Copilot Taskbar" -Exception $_.Exception
    }
    Pause-Screen
}

function Disable-WindowsTips {
    Write-SubHeader "TẮT GỢI Ý & QUẢNG CÁO MẸO VẶT CỦA WINDOWS"
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    try {
        Set-ItemProperty -Path $regPath -Name "SoftLandingEnabled" -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $regPath -Name "SubscribedContent-338388Enabled" -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $regPath -Name "SubscribedContent-338389Enabled" -Value 0 -Force -ErrorAction SilentlyContinue
        Write-Success "Đã tắt các mẹo vặt và gợi ý ứng dụng trên Windows!"
        Write-TMLog -TaskId "PRIV_TIPS" -TaskName "Tắt gợi ý Windows" -Status "Success" -Message "Thành công"
    } catch {
        Handle-TMException -TaskId "PRIV_TIPS" -TaskName "Tắt gợi ý Windows" -Exception $_.Exception
    }
    Pause-Screen
}

function Toggle-TaskbarWidgets {
    Write-SubHeader "BẬT / TẮT WIDGET TRÊN THANH TASKBAR"
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    try {
        $current = (Get-ItemProperty -Path $regPath -Name "TaskbarDa" -ErrorAction SilentlyContinue).TaskbarDa
        $statusStr = if ($current -eq 0) { "Đang ẩn (Tắt)" } else { "Đang hiện (Bật)" }
        Write-InfoMessage "Trạng thái Widgets hiện tại: $statusStr"

        Write-Host " [1] Ẩn Widgets" -ForegroundColor Cyan
        Write-Host " [2] Hiện Widgets" -ForegroundColor Cyan
        Write-Host " [0] Quay lại" -ForegroundColor Yellow
        $sel = Read-MenuSelection -Min 0 -Max 2
        switch ($sel) {
            1 {
                Set-ItemProperty -Path $regPath -Name "TaskbarDa" -Value 0 -Force
                Write-Success "Đã ẩn Widgets trên Taskbar."
            }
            2 {
                Set-ItemProperty -Path $regPath -Name "TaskbarDa" -Value 1 -Force
                Write-Success "Đã hiện Widgets trên Taskbar."
            }
        }
    } catch {
        Handle-TMException -TaskId "PRIV_WIDGETS" -TaskName "Widgets Taskbar" -Exception $_.Exception
    }
    Pause-Screen
}
