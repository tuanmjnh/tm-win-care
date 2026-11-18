# TM-WinCare Online Bootstrap Launcher
# Usage:
#   Main Toolkit: irm https://raw.githubusercontent.com/tuanmjnh/tm-win-care/main/get.ps1 | iex
#   License Only: irm https://raw.githubusercontent.com/tuanmjnh/tm-win-care/main/dist/Check-License.ps1 | iex

try { & chcp.com 65001 | Out-Null } catch {}
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$url = "https://raw.githubusercontent.com/tuanmjnh/tm-win-care/main/dist/TM-WinCare-AIO.ps1"
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $content = (Invoke-RestMethod -Uri $url -UseBasicParsing)
    Invoke-Expression $content
} catch {
    Write-Host "[LỖI] Không thể tải TM-WinCare: $($_.Exception.Message)" -ForegroundColor Red
}