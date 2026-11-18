# TM-WinCare - Local Accounts & Access Management Module
# Adheres to Section 4.3 & Section 13 of TM-WinCare-Architecture-v1.2.md

function Show-TMAccountsMenu {
    $menuItems = @(
        @{ Label = "Danh sách tài khoản người dùng cục bộ (Local Users)"; Action = { Show-LocalUsersList } },
        @{ Label = "Tạo tài khoản scan máy in (Scan-to-Folder)"; Action = { Invoke-CreateScanAccount } },
        @{ Label = "Mở Quản lý Người dùng & Nhóm (lusrmgr.msc)"; Action = { Start-Process "lusrmgr.msc" } },
        @{ Label = "Mở Cấu hình Tài khoản Nhanh (netplwiz)"; Action = { Start-Process "netplwiz.exe" } },
        @{ Label = "Mở Quản lý Mật khẩu Mạng (Credential Manager)"; Action = { Start-Process "control.exe" "/name Microsoft.CredentialManager" } }
    )
    Show-TMMenu -Title "TÀI KHOẢN & QUYỀN TRUY CẬP (ACCOUNTS & ACCESS)" -MenuItems $menuItems -ExitLabel "Quay lại"
}

function Show-LocalUsersList {
    Write-SubHeader "DANH SÁCH TÀI KHOẢN CỤC BỘ TRÊN MÁY"
    try {
        if (Test-CmdletAvailable "Get-LocalUser") {
            $users = Get-LocalUser
            $list = @()
            foreach ($u in $users) {
                $list += [PSCustomObject]@{
                    TenUser = $u.Name
                    TrangThai = if ($u.Enabled) { "Bật" } else { "Tắt" }
                    MatKhauKhongHetHan = if ($u.PasswordNeverExpires) { "Có" } else { "Không" }
                    MoTa = $u.Description
                }
            }
            $headers = @("Tên tài khoản", "Trạng thái", "Pass không hết hạn", "Mô tả")
            $props = @("TenUser", "TrangThai", "MatKhauKhongHetHan", "MoTa")
            $widths = @(22, 12, 22, 25)
            Show-TableList -Items $list -Headers $headers -PropertyNames $props -Widths $widths
        } else {
            & net.exe user
        }
    } catch {
        Handle-TMException -TaskId "ACC_LIST" -TaskName "Liệt kê tài khoản" -Exception $_.Exception
    }
    Pause-Screen
}
