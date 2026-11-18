# TM-WinCare - Windows Repair Module
# Adheres to Section 3.4 & 3.5 of TM-WinCare-Architecture-v1.2.md

function Show-TMRepairMenu {
    $menuItems = @(
        @{ Label = "Quy trình sửa chữa hoàn chỉnh (DISM RestoreHealth -> SFC Scannow)"; Action = { Invoke-RepairPipeline } },
        @{ Label = "SFC - Quét và sửa file hệ thống (sfc /scannow)"; Action = { Invoke-SfcScanNow } },
        @{ Label = "DISM - Kiểm tra trạng thái hỏng hóc nhanh (CheckHealth)"; Action = { Invoke-DismCheckHealth } },
        @{ Label = "DISM - Quét sâu linh kiện Component Store (ScanHealth)"; Action = { Invoke-DismScan } },
        @{ Label = "DISM - Khôi phục linh kiện Component Store (RestoreHealth)"; Action = { Invoke-DismRestore } },
        @{ Label = "Dọn dẹp Windows Component Store (DISM StartComponentCleanup)"; Action = { Invoke-DismComponentCleanup } },
        @{ Label = "Đặt lại cấu hình mạng & Winsock (Netsh Winsock Reset)"; Action = { Invoke-ResetWinsock } }
    )
    Show-TMMenu -Title "SỬA CHỮA HỆ THỐNG WINDOWS (SYSTEM REPAIR)" -MenuItems $menuItems -ExitLabel "Quay lại"
}

function Invoke-DismCheckHealth {
    if (-not (Assert-Admin "kiểm tra nhanh DISM")) { Pause-Screen; return }
    Write-SubHeader "DISM /CheckHealth - KIỂM TRA NHANH TRẠNG THÁI COMPONENT STORE"
    & dism.exe /Online /Cleanup-Image /CheckHealth
    Pause-Screen
}

function Invoke-DismComponentCleanup {
    if (-not (Assert-Admin "dọn dẹp component store")) { Pause-Screen; return }
    Write-SubHeader "DỌN DẸP WIN-SXS COMPONENT STORE (DISM StartComponentCleanup)"
    Write-InfoMessage "Thu hồi dung lượng các bản cập nhật cũ trong thư mục WinSxS an toàn theo chuẩn Microsoft."
    
    $confirmed = Confirm-Action -TaskName "DISM Component Cleanup" -ImpactDescription "Dọn dẹp các bản backup update cũ trong WinSxS. Thao tác không thể hoàn tác nhưng an toàn." -RiskLevel "medium"
    if ($confirmed) {
        Write-InfoMessage "Đang thực thi DISM /Online /Cleanup-Image /StartComponentCleanup..."
        & dism.exe /Online /Cleanup-Image /StartComponentCleanup
        Write-Success "Dọn dẹp Component Store hoàn tất!"
        Write-TMLog -TaskId "DISM_CLEANUP" -TaskName "DISM StartComponentCleanup" -Status "Success" -Message "Hoàn tất"
    }
    Pause-Screen
}

function Invoke-ResetWinsock {
    if (-not (Assert-Admin "đặt lại Winsock")) { Pause-Screen; return }
    Write-SubHeader "ĐẶT LẠI WINSOCK & TCP/IP STACK"
    $confirmed = Confirm-Action -TaskName "Reset Winsock" -ImpactDescription "Đặt lại cấu hình socket mạng về mặc định để sửa lỗi mất mạng, DNS hoặc proxy bị hỏng. Cần khởi động lại máy." -RiskLevel "medium"
    if ($confirmed) {
        & netsh.exe winsock reset
        & netsh.exe int ip reset
        Write-Success "Đã đặt lại Winsock và TCP/IP stack!"
        Write-WarningMessage "Vui lòng khởi động lại máy để hoàn tất cấu hình mạng."
        Write-TMLog -TaskId "NET_WINSOCK_RESET" -TaskName "Reset Winsock" -Status "Success" -Message "Thành công" -RequiresRestart $true
    }
    Pause-Screen
}
