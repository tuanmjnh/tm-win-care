# TM-WinCare - Optimization Main Module
# Adheres to Section 3.3.1 of TM-WinCare-Architecture-v1.2.md

. (Join-Path $PSScriptRoot "Profiles.ps1")

function Show-TMOptimizationMenu {
    $menuItems = @(
        @{ Label = "Phân tích & đề xuất tối ưu (Audit only)"; Action = { Invoke-AutoOptimizeProfile -ProfileId "audit" } },
        @{ Label = "Auto Optimize - Balanced (Khuyến nghị cho máy phổ thông)"; Action = { Invoke-AutoOptimizeProfile -ProfileId "balanced" } },
        @{ Label = "Auto Optimize - Desktop Performance (Máy bàn hiệu năng cao)"; Action = { Invoke-AutoOptimizeProfile -ProfileId "desktop_perf" } },
        @{ Label = "Auto Optimize - Máy cấu hình thấp / Ổ cứng HDD"; Action = { Invoke-AutoOptimizeProfile -ProfileId "low_resource_hdd" } },
        @{ Label = "Auto Optimize - Laptop Balanced (Laptop cân bằng pin)"; Action = { Invoke-AutoOptimizeProfile -ProfileId "laptop_balanced" } },
        @{ Label = "Services Manager (SysMain / WSearch / Ndu...)"; Action = { Show-ServicesManagerMenu } },
        @{ Label = "Hiệu ứng thị giác & Animations (Visual Effects)"; Action = { Show-VisualEffectsMenu } },
        @{ Label = "Ứng dụng khởi động cùng Windows (Startup Apps)"; Action = { Show-StartupAppsMenu } },
        @{ Label = "Chế độ Nguồn điện & Hiệu năng (Power Plan)"; Action = { Show-PowerPlanMenu } },
        @{ Label = "Xem thay đổi gần nhất / Rollback"; Action = { Show-TMBackupMenu } }
    )
    Show-TMMenu -Title "TỐI ƯU HÓA WINDOWS AN TOÀN (OPTIMIZATION)" -MenuItems $menuItems -ExitLabel "Quay lại"
}

function Show-ServicesManagerMenu {
    Write-Header -Title "QUẢN LÝ DỊCH VỤ HỆ THỐNG (SERVICES MANAGER)"
    Write-InfoMessage "Đang đọc trạng thái các dịch vụ quan trọng..."

    $servicesToCheck = @("SysMain", "WSearch", "Ndu")
    $list = @()
    foreach ($sName in $servicesToCheck) {
        $svc = Get-Service -Name $sName -ErrorAction SilentlyContinue
        $startMode = "Không tìm thấy"
        if ($svc) {
            $cim = Get-CimInstance Win32_Service -Filter "Name='$sName'" -ErrorAction SilentlyContinue
            if ($cim) { $startMode = $cim.StartMode }
        }
        $list += [PSCustomObject]@{
            DichVu = $sName
            TrangThai = if ($svc) { $svc.Status.ToString() } else { "Không tồn tại" }
            CheDoKhoiDong = $startMode
        }
    }

    $headers = @("Tên dịch vụ", "Trạng thái", "Chế độ khởi động")
    $props = @("DichVu", "TrangThai", "CheDoKhoiDong")
    $widths = @(18, 20, 22)
    Show-TableList -Items $list -Headers $headers -PropertyNames $props -Widths $widths

    Write-Host ""
    Write-Host "  LƯU Ý QUAN TRỌNG VỀ BẢO MẬT & ĐỘ ỔN ĐỊNH:" -ForegroundColor Yellow
    Write-Host "  - SysMain: Quản lý cache RAM. Không nên tắt nếu dùng SSD và RAM dồi dào." -ForegroundColor Gray
    Write-Host "  - WSearch: Dịch vụ tìm kiếm Windows. Không nên tắt hoàn toàn; nên thu hẹp phạm vi index." -ForegroundColor Gray
    Write-Host "  - Ndu: Bắt buộc giữ nguyên. Tắt Ndu không phải là khuyến nghị chính thức của Microsoft." -ForegroundColor Gray
    Write-Host ""

    Write-Host "  [1] Mở Services Management Console (services.msc)" -ForegroundColor Cyan
    Write-Host "  [2] Cấu hình phạm vi Search Indexing (Mở cài đặt Indexer)" -ForegroundColor Cyan
    Write-Host "  [0] Quay lại" -ForegroundColor Yellow
    Write-Divider

    $sel = Read-MenuSelection -PromptText "Chọn thao tác" -Min 0 -Max 2
    switch ($sel) {
        1 { Start-Process "services.msc" }
        2 { Start-Process "control.exe" "srchadmin.dll" }
        0 { return }
    }
}

function Show-VisualEffectsMenu {
    Write-Header -Title "HIỆU ỨNG THỊ GIÁC & ANIMATIONS"
    Write-Host "  [1] Tối ưu cân bằng (Tắt animation cửa sổ, giữ font chữ mịn)" -ForegroundColor Cyan
    Write-Host "  [2] Tối ưu hiệu năng cao (Best Performance - tắt toàn bộ hiệu ứng)" -ForegroundColor Cyan
    Write-Host "  [3] Khôi phục mặc định của Windows (Let Windows choose)" -ForegroundColor Cyan
    Write-Host "  [4] Mở giao diện Performance Options của Windows" -ForegroundColor Cyan
    Write-Host "  [0] Quay lại" -ForegroundColor Yellow
    Write-Divider

    $sel = Read-MenuSelection -PromptText "Chọn cấu hình visual" -Min 0 -Max 4
    switch ($sel) {
        1 {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 3 -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0 -Force -ErrorAction SilentlyContinue
            Write-Success "Đã áp dụng cấu hình hiệu ứng cân bằng."
            Pause-Screen
        }
        2 {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -Force -ErrorAction SilentlyContinue
            Write-Success "Đã chuyển sang chế độ Best Performance."
            Pause-Screen
        }
        3 {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 0 -Force -ErrorAction SilentlyContinue
            Write-Success "Đã khôi phục chế độ tự động của Windows."
            Pause-Screen
        }
        4 {
            Start-Process "SystemPropertiesPerformance.exe"
        }
        0 { return }
    }
}

function Show-StartupAppsMenu {
    Write-Header -Title "ỨNG DỤNG KHỞI ĐỘNG CÙNG WINDOWS (STARTUP APPS)"
    Write-InfoMessage "Đang truy vấn các mục Startup trong Registry..."

    $regPaths = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
    )

    $items = @()
    foreach ($rp in $regPaths) {
        if (Test-Path $rp) {
            $props = Get-ItemProperty -Path $rp
            foreach ($name in $props.PSObject.Properties.Name) {
                if ($name -notmatch "^PS.*") {
                    $items += [PSCustomObject]@{
                        Ten = $name
                        ViTri = if ($rp -match "HKCU") { "User" } else { "System" }
                        Lenh = $props.$name
                    }
                }
            }
        }
    }

    $headers = @("Tên ứng dụng", "Phạm vi", "Đường dẫn lệnh")
    $props = @("Ten", "ViTri", "Lenh")
    $widths = @(25, 10, 35)
    Show-TableList -Items $items -Headers $headers -PropertyNames $props -Widths $widths

    Write-Host ""
    Write-Host "  [1] Mở trang Startup Apps trong Windows Settings" -ForegroundColor Cyan
    Write-Host "  [2] Mở Task Manager (Tab Startup)" -ForegroundColor Cyan
    Write-Host "  [0] Quay lại" -ForegroundColor Yellow
    Write-Divider

    $sel = Read-MenuSelection -PromptText "Chọn thao tác" -Min 0 -Max 2
    switch ($sel) {
        1 { Start-Process "ms-settings:startupapps" }
        2 { Start-Process "taskmgr.exe" }
        0 { return }
    }
}

function Show-PowerPlanMenu {
    Write-Header -Title "CHẾ ĐỘ NGUỒN ĐIỆN & HIỆU NĂNG (POWER PLAN)"
    try {
        $activePlan = (powercfg /getactivescheme)
        Write-InfoMessage "Chế độ hiện tại: $activePlan"
    } catch {}

    Write-Host ""
    Write-Host "  [1] Mở cài đặt Power Options (Control Panel)" -ForegroundColor Cyan
    Write-Host "  [2] Đặt sang chế độ Cân bằng (Balanced)" -ForegroundColor Cyan
    Write-Host "  [3] Đặt sang chế độ Hiệu năng cao (High Performance)" -ForegroundColor Cyan
    Write-Host "  [0] Quay lại" -ForegroundColor Yellow
    Write-Divider

    $sel = Read-MenuSelection -PromptText "Chọn thao tác" -Min 0 -Max 3
    switch ($sel) {
        1 { Start-Process "powercfg.cpl" }
        2 {
            powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e
            Write-Success "Đã chuyển sang Balanced Power Scheme."
            Pause-Screen
        }
        3 {
            powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
            Write-Success "Đã chuyển sang High Performance Power Scheme."
            Pause-Screen
        }
        0 { return }
    }
}
