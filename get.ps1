# TM-WinCare Online Bootstrap Launcher
# Usage: irm https://raw.githubusercontent.com/tuanmjnh/tm-win-care/main/dist/TM-WinCare-AIO.ps1 | iex
$url = "https://raw.githubusercontent.com/tuanmjnh/tm-win-care/main/dist/TM-WinCare-AIO.ps1"
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $content = (Invoke-RestMethod -Uri $url -UseBasicParsing)
    Invoke-Expression $content
} catch {
    Write-Host "[LỖI] Không thể tải TM-WinCare: $($_.Exception.Message)" -ForegroundColor Red
}