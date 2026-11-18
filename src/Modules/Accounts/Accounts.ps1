# TM-WinCare - Local Accounts & Access Management Module
# Adheres to Section 4.3 & Section 13 of TM-WinCare-Architecture-v1.2.md

function Show-TMAccountsMenu {
    $menuItems = @(
        @{ Label = "List Local User Accounts (Get-LocalUser)"; Action = { Show-LocalUsersList } },
        @{ Label = "Create Scan-to-Folder Dedicated Local User"; Action = { Invoke-CreateScanAccount } },
        @{ Label = "Open Local Users and Groups Console (lusrmgr.msc)"; Action = { Start-Process "lusrmgr.msc" } },
        @{ Label = "Open User Accounts Management (netplwiz)"; Action = { Start-Process "netplwiz.exe" } },
        @{ Label = "Open Windows Credential Manager (control credman)"; Action = { Start-Process "control.exe" "/name Microsoft.CredentialManager" } }
    )
    Show-TMMenu -Title "ACCOUNTS & ACCESS MANAGEMENT" -MenuItems $menuItems -ExitLabel "Back"
}

function Show-LocalUsersList {
    Write-SubHeader "LOCAL USER ACCOUNTS ON THIS PC"
    try {
        if (Test-CmdletAvailable "Get-LocalUser") {
            $users = Get-LocalUser
            $list = @()
            foreach ($u in $users) {
                $list += [PSCustomObject]@{
                    Username = $u.Name
                    Status = if ($u.Enabled) { "Enabled" } else { "Disabled" }
                    PasswordNeverExpires = if ($u.PasswordNeverExpires) { "Yes" } else { "No" }
                    Description = $u.Description
                }
            }
            $headers = @("Username", "Status", "Password Never Expires", "Description")
            $props = @("Username", "Status", "PasswordNeverExpires", "Description")
            $widths = @(22, 12, 24, 25)
            Show-TableList -Items $list -Headers $headers -PropertyNames $props -Widths $widths
        } else {
            & net.exe user
        }
    } catch {
        Handle-TMException -TaskId "ACC_LIST" -TaskName "List Accounts" -Exception $_.Exception
    }
    Pause-Screen
}
