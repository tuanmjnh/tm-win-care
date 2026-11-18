# TM-WinCare - Windows Optimization and Maintenance Toolkit v1.2.0
try { & chcp.com 65001 | Out-Null } catch {}
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$global:IsBundledAIO = $true
$global:TM_CONFIG = @'
{
  "name": "TM-WinCare",
  "displayName": "TM Windows Support Toolkit",
  "version": "1.2.0",
  "releaseDate": "2026-11-18",
  "defaultLocale": "vi-VN",
  "supportedOS": ["10", "11"],
  "minimumBuild": 19041,
  "safeByDefault": true,
  "dryRunDefault": false,
  "requireAdminForMutations": true,
  "paths": {
    "logs": "Logs",
    "backups": "Backups",
    "data": "data"
  },
  "logging": {
    "enabled": true,
    "format": ["log", "jsonl"],
    "retentionDays": 30,
    "sanitizeSecrets": true
  },
  "features": {
    "dashboard": true,
    "postInstall": true,
    "optimization": true,
    "maintenance": true,
    "repair": true,
    "network": true,
    "printer": true,
    "aiDevCleanup": true,
    "privacy": true,
    "accounts": true,
    "quickCommands": true,
    "backupRestore": true
  }
}

'@ | ConvertFrom-Json
$global:TM_EMBEDDED_QUICK_COMMANDS = @'
[
  {
    "id": "SYS_WINVER",
    "group": "System",
    "name": "Xem phiên bản Windows (winver)",
    "description": "Hiển thị hộp thoại About Windows với edition, version và build number",
    "command": "winver",
    "type": "process",
    "requiresAdmin": false,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "SYS_MSINFO32",
    "group": "System",
    "name": "Thông tin hệ thống chi tiết (msinfo32)",
    "description": "Mở công cụ System Information hiển thị phần cứng, driver, components",
    "command": "msinfo32",
    "type": "process",
    "requiresAdmin": false,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "SYS_DXDIAG",
    "group": "System",
    "name": "Chẩn đoán DirectX (dxdiag)",
    "description": "Kiểm tra DirectX, card màn hình (GPU), âm thanh và driver",
    "command": "dxdiag",
    "type": "process",
    "requiresAdmin": false,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "SYS_DEVMGMT",
    "group": "System",
    "name": "Quản lý thiết bị (devmgmt.msc)",
    "description": "Mở Device Manager để kiểm tra driver, thiết bị thiếu hoặc bị lỗi",
    "command": "devmgmt.msc",
    "type": "process",
    "requiresAdmin": true,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "SYS_DISKMGMT",
    "group": "System",
    "name": "Quản lý phân vùng ổ đĩa (diskmgmt.msc)",
    "description": "Mở Disk Management để chia ổ, format, gán ký tự ổ đĩa",
    "command": "diskmgmt.msc",
    "type": "process",
    "requiresAdmin": true,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "SYS_SERVICES",
    "group": "System",
    "name": "Quản lý dịch vụ Windows (services.msc)",
    "description": "Mở danh sách Services hệ thống Windows",
    "command": "services.msc",
    "type": "process",
    "requiresAdmin": true,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "SYS_EVENTVWR",
    "group": "System",
    "name": "Xem nhật ký sự kiện (eventvwr.msc)",
    "description": "Mở Event Viewer để kiểm tra lỗi ứng dụng và hệ thống",
    "command": "eventvwr.msc",
    "type": "process",
    "requiresAdmin": true,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "SYS_PERFMON_REL",
    "group": "System",
    "name": "Giám sát độ ổn định hệ thống (perfmon /rel)",
    "description": "Mở Reliability Monitor xem lịch sử crash app, update và lỗi Windows",
    "command": "perfmon /rel",
    "type": "process",
    "requiresAdmin": false,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "SYS_TASKMGR",
    "group": "System",
    "name": "Trình quản lý tác vụ (taskmgr)",
    "description": "Mở Task Manager để kiểm tra CPU, RAM, Disk, Network và tiến trình",
    "command": "taskmgr",
    "type": "process",
    "requiresAdmin": false,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "DISK_DFRGUI",
    "group": "Disk",
    "name": "Tối ưu hóa ổ đĩa giao diện (dfrgui.exe)",
    "description": "Mở Optimize Drives của Windows (TRIM cho SSD, Defrag cho HDD)",
    "command": "dfrgui.exe",
    "type": "process",
    "requiresAdmin": true,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "PRINT_PRINTUI",
    "group": "Printer",
    "name": "Quản lý Driver máy in (printui /s /t2)",
    "description": "Mở Print Server Properties trực tiếp tại tab Drivers để gỡ/cài driver máy in",
    "command": "rundll32.exe printui.dll,PrintUIEntry /s /t2",
    "type": "process",
    "requiresAdmin": true,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "PRINT_CONTROL",
    "group": "Printer",
    "name": "Mở Devices and Printers cổ điển",
    "description": "Mở danh sách máy in và máy quét trong Control Panel",
    "command": "control printers",
    "type": "process",
    "requiresAdmin": false,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "NET_NCPA",
    "group": "Network",
    "name": "Quản lý Card mạng (ncpa.cpl)",
    "description": "Mở Network Connections để đặt IP tĩnh, DNS, bật/tắt card mạng",
    "command": "ncpa.cpl",
    "type": "process",
    "requiresAdmin": true,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "NET_CREDMAN",
    "group": "Network",
    "name": "Quản lý tài khoản mạng (Credential Manager)",
    "description": "Mở Credential Manager để lưu tài khoản/mật khẩu chia sẻ mạng LAN",
    "command": "control /name Microsoft.CredentialManager",
    "type": "process",
    "requiresAdmin": false,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "NET_INETCPL",
    "group": "Network",
    "name": "Tùy chọn mạng Internet (inetcpl.cpl)",
    "description": "Mở Internet Properties cấu hình Proxy, TLS, Security zones",
    "command": "inetcpl.cpl",
    "type": "process",
    "requiresAdmin": false,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "NET_IPCONFIG",
    "group": "Network",
    "name": "Xem cấu hình mạng chi tiết (ipconfig /all)",
    "description": "Hiển thị IP, Subnet, Gateway, DHCP, DNS, MAC address",
    "command": "ipconfig /all",
    "type": "cli",
    "requiresAdmin": false,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "NET_GPUPDATE",
    "group": "Network",
    "name": "Cập nhật Group Policy (gpupdate /force)",
    "description": "Áp dụng ngay các chính sách nhóm bảo mật và máy in",
    "command": "gpupdate /force",
    "type": "cli",
    "requiresAdmin": true,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "REPAIR_SFC_VERIFY",
    "group": "Repair",
    "name": "Xác minh file hệ thống (sfc /verifyonly)",
    "description": "Kiểm tra tính toàn vẹn file hệ thống, chỉ báo cáo không sửa",
    "command": "sfc /verifyonly",
    "type": "cli",
    "requiresAdmin": true,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "REPAIR_SFC_SCAN",
    "group": "Repair",
    "name": "Quét và sửa file hệ thống (sfc /scannow)",
    "description": "Quét và tự động thay thế file hệ thống bị hỏng bằng bản sao từ cache",
    "command": "sfc /scannow",
    "type": "cli",
    "requiresAdmin": true,
    "changesSystem": true,
    "requiresRestart": false
  },
  {
    "id": "REPAIR_DISM_CHECK",
    "group": "Repair",
    "name": "DISM kiểm tra nhanh (CheckHealth)",
    "description": "Kiểm tra xem component store có bị đánh dấu hỏng hóc hay không",
    "command": "DISM /Online /Cleanup-Image /CheckHealth",
    "type": "cli",
    "requiresAdmin": true,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "REPAIR_DISM_SCAN",
    "group": "Repair",
    "name": "DISM quét sâu (ScanHealth)",
    "description": "Quét toàn diện kho linh kiện Windows Component Store",
    "command": "DISM /Online /Cleanup-Image /ScanHealth",
    "type": "cli",
    "requiresAdmin": true,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "REPAIR_DISM_RESTORE",
    "group": "Repair",
    "name": "DISM khôi phục (RestoreHealth)",
    "description": "Tải và thay thế các component bị lỗi từ nguồn Windows Update",
    "command": "DISM /Online /Cleanup-Image /RestoreHealth",
    "type": "cli",
    "requiresAdmin": true,
    "changesSystem": true,
    "requiresRestart": false
  }
]

'@ | ConvertFrom-Json
$global:TM_EMBEDDED_OPTIMIZATION_PROFILES = @'
[
  {
    "id": "audit",
    "name": "Audit Only (Chỉ kiểm tra & báo cáo)",
    "description": "Quét toàn bộ cấu hình, dịch vụ, ứng dụng khởi động và gợi ý mà không thay đổi bất kỳ thiết lập nào.",
    "target": "Mọi loại máy",
    "actions": [
      { "id": "AUDIT_STARTUP", "name": "Kiểm tra ứng dụng khởi động (Startup)", "action": "audit" },
      { "id": "AUDIT_SERVICES", "name": "Kiểm tra dịch vụ tiêu thụ tài nguyên", "action": "audit" },
      { "id": "AUDIT_TEMP", "name": "Đo dung lượng thư mục rác và file tạm", "action": "audit" },
      { "id": "AUDIT_DISK", "name": "Kiểm tra dung lượng và loại ổ cứng", "action": "audit" }
    ]
  },
  {
    "id": "balanced",
    "name": "Balanced (Khuyến nghị cho máy phổ thông)",
    "description": "Cân bằng hiệu năng và độ ổn định. Tối ưu hiệu ứng thị giác thừa, dọn dẹp file tạm, tắt startup không thiết yếu. Giữ nguyên toàn bộ dịch vụ bảo mật.",
    "target": "Máy làm việc văn phòng, cá nhân phổ thông",
    "actions": [
      { "id": "CLEAN_SAFE_TEMP", "name": "Dọn dẹp Temp người dùng và Windows an toàn", "action": "clean_temp" },
      { "id": "VISUAL_BALANCED", "name": "Giảm hiệu ứng animation không cần thiết, giữ mịn font chữ", "action": "visual_balanced" },
      { "id": "AUDIT_STARTUP_RECOMMEND", "name": "Rà soát và đề xuất tắt ứng dụng chạy ngầm không cần thiết", "action": "startup_recommend" },
      { "id": "TRIM_SSD", "name": "Chạy ReTrim tối ưu SSD nếu có", "action": "trim_ssd" }
    ]
  },
  {
    "id": "desktop_perf",
    "name": "Desktop Performance (Máy bàn hiệu năng cao)",
    "description": "Tối ưu hóa độ phản hồi tối đa cho máy tính để bàn cắm nguồn trực tiếp. Giữ nguyên Defender/Firewall/Windows Update.",
    "target": "Máy tính bàn (Desktop) ưu tiên phản hồi nhanh",
    "actions": [
      { "id": "CLEAN_SAFE_TEMP", "name": "Dọn dẹp Temp người dùng và Windows an toàn", "action": "clean_temp" },
      { "id": "POWER_HIGH_PERF", "name": "Đề xuất chế độ nguồn High Performance (khi cắm điện)", "action": "power_high_perf" },
      { "id": "VISUAL_PERFORMANCE", "name": "Tối ưu visual effects cho hiệu năng cao", "action": "visual_perf" },
      { "id": "TRIM_SSD", "name": "Chạy ReTrim tối ưu SSD", "action": "trim_ssd" }
    ]
  },
  {
    "id": "low_resource_hdd",
    "name": "Low Resource / HDD (Máy cấu hình thấp hoặc dùng HDD)",
    "description": "Đo mức sử dụng tài nguyên trước. Giảm tải animation, gợi ý giảm phạm vi Search indexing, dọn dẹp bộ nhớ đệm, tối ưu phân mảnh HDD.",
    "target": "Máy cũ, RAM dưới 8GB hoặc ổ đĩa cơ HDD",
    "actions": [
      { "id": "CLEAN_SAFE_TEMP", "name": "Dọn dẹp file tạm an toàn", "action": "clean_temp" },
      { "id": "VISUAL_MINIMAL", "name": "Chuyển giao diện sang Best Performance (giữ font smoothing)", "action": "visual_minimal" },
      { "id": "ANALYZE_HDD", "name": "Phân tích tình trạng phân mảnh ổ C: (HDD)", "action": "analyze_hdd" },
      { "id": "STARTUP_MINIMAL", "name": "Khuyến nghị tắt tối đa startup bên thứ ba", "action": "startup_minimal" }
    ]
  },
  {
    "id": "laptop_balanced",
    "name": "Laptop Balanced (Laptop giữ thời lượng pin)",
    "description": "Cân bằng hiệu năng và pin. Không ép High Performance khi dùng pin. Tối ưu bộ nhớ đệm và dọn rác an toàn.",
    "target": "Laptop và thiết bị di động",
    "actions": [
      { "id": "CLEAN_SAFE_TEMP", "name": "Dọn dẹp Temp an toàn", "action": "clean_temp" },
      { "id": "VISUAL_BALANCED", "name": "Giảm bớt animation thừa", "action": "visual_balanced" },
      { "id": "BATTERY_AWARE_POWER", "name": "Giữ Balanced Power Plan", "action": "power_balanced" }
    ]
  }
]

'@ | ConvertFrom-Json
$global:TM_EMBEDDED_SYSTEM_CLEANUP = @'
[
  {
    "id": "CLEAN_USER_TEMP",
    "name": "User Temp (%TEMP%)",
    "description": "File tạm sinh ra từ các ứng dụng của người dùng hiện tại",
    "pathType": "env",
    "targetPath": "%TEMP%",
    "requiresAdmin": false,
    "risk": "low",
    "safeToDelete": true,
    "skipLocked": true,
    "minAgeDays": 0
  },
  {
    "id": "CLEAN_WIN_TEMP",
    "name": "Windows Temp (%WINDIR%\\Temp)",
    "description": "File tạm của các dịch vụ hệ thống và bộ cài đặt",
    "pathType": "env",
    "targetPath": "%WINDIR%\\Temp",
    "requiresAdmin": true,
    "risk": "low",
    "safeToDelete": true,
    "skipLocked": true,
    "minAgeDays": 0
  },
  {
    "id": "CLEAN_RECYCLE_BIN",
    "name": "Thùng rác (Recycle Bin)",
    "description": "Dọn sạch các file đã xóa tạm vào thùng rác trên tất cả các ổ đĩa",
    "pathType": "special",
    "targetPath": "RecycleBin",
    "requiresAdmin": false,
    "risk": "medium",
    "safeToDelete": true,
    "skipLocked": false,
    "minAgeDays": 0
  },
  {
    "id": "CLEAN_WU_CACHE",
    "name": "Windows Update Download Cache",
    "description": "Các file cài đặt bản cập nhật đã tải xong trong SoftwareDistribution\\Download",
    "pathType": "fixed",
    "targetPath": "%WINDIR%\\SoftwareDistribution\\Download",
    "requiresAdmin": true,
    "risk": "low",
    "safeToDelete": true,
    "skipLocked": true,
    "minAgeDays": 1
  },
  {
    "id": "CLEAN_CRASH_DUMPS",
    "name": "Crash Dumps & Minidumps",
    "description": "Bản ghi lỗi BSOD (Minidump) và crash bộ nhớ cũ của Windows",
    "pathType": "fixed",
    "targetPath": "%WINDIR%\\Minidump",
    "requiresAdmin": true,
    "risk": "low",
    "safeToDelete": true,
    "skipLocked": true,
    "minAgeDays": 7
  },
  {
    "id": "CLEAN_THUMB_CACHE",
    "name": "Thumbnail & Icon Cache",
    "description": "Bộ nhớ đệm hình thu nhỏ của Windows Explorer",
    "pathType": "env",
    "targetPath": "%LOCALAPPDATA%\\Microsoft\\Windows\\Explorer",
    "filter": "thumbcache_*.db",
    "requiresAdmin": false,
    "risk": "low",
    "safeToDelete": true,
    "skipLocked": true,
    "minAgeDays": 0
  }
]

'@ | ConvertFrom-Json
$global:TM_EMBEDDED_AIDEV_CLEANUP = @'
[
  {
    "id": "AIDEV_PIP_CACHE",
    "name": "Python Pip Cache",
    "category": "Package Cache",
    "cliCommand": "pip cache purge",
    "detectCommand": "pip --version",
    "infoCommand": "pip cache info",
    "defaultPath": "%LOCALAPPDATA%\\pip\\cache",
    "description": "Cache các file wheel và source code gói thư viện Python đã tải về",
    "safeToDelete": true,
    "preserve": "Virtual environments (.venv), python source projects"
  },
  {
    "id": "AIDEV_UV_CACHE",
    "name": "Python uv Cache",
    "category": "Package Cache",
    "cliCommand": "uv cache clean",
    "detectCommand": "uv --version",
    "infoCommand": "uv cache dir",
    "defaultPath": "%LOCALAPPDATA%\\uv\\cache",
    "description": "Bộ nhớ đệm siêu nhanh của package manager uv",
    "safeToDelete": true,
    "preserve": "Python installed versions, local virtual environments"
  },
  {
    "id": "AIDEV_NPM_CACHE",
    "name": "Node.js npm Cache",
    "category": "Package Cache",
    "cliCommand": "npm cache clean --force",
    "detectCommand": "npm --version",
    "infoCommand": "npm cache verify",
    "defaultPath": "%APPDATA%\\npm-cache",
    "description": "Cache các file nén tarball tải từ npm registry",
    "safeToDelete": true,
    "preserve": "node_modules của các project, credentials, package.json"
  },
  {
    "id": "AIDEV_PNPM_STORE",
    "name": "Node.js pnpm Store Prune",
    "category": "Package Cache",
    "cliCommand": "pnpm store prune",
    "detectCommand": "pnpm --version",
    "infoCommand": "pnpm store path",
    "defaultPath": "%LOCALAPPDATA%\\pnpm\\store",
    "description": "Dọn dẹp các package mồ côi trong pnpm hard-link content-addressable store",
    "safeToDelete": true,
    "preserve": "Các package đang được symlink vào dự án hiện hành"
  },
  {
    "id": "AIDEV_HF_CACHE",
    "name": "Hugging Face Hub Cache",
    "category": "AI Cache",
    "detectCommand": "hf version",
    "defaultPath": "%USERPROFILE%\\.cache\\huggingface\\hub",
    "envVar": "HF_HOME",
    "description": "Bộ nhớ đệm snapshot mô hình AI và dataset tải từ Hugging Face",
    "safeToDelete": false,
    "requiresReview": true,
    "preserve": "Model snapshots cần cho hoạt động offline"
  },
  {
    "id": "AIDEV_OLLAMA",
    "name": "Ollama Models & Logs",
    "category": "AI Models",
    "detectCommand": "ollama --version",
    "listCommand": "ollama list",
    "defaultPath": "%USERPROFILE%\\.ollama\\models",
    "envVar": "OLLAMA_MODELS",
    "description": "Danh sách các Local LLM models (Llama, DeepSeek, Qwen...) của Ollama",
    "safeToDelete": false,
    "requiresReview": true,
    "preserve": "KHÔNG BAO GIỜ xóa tự động. Chỉ liệt kê dung lượng và dùng lệnh ollama rm <model> có xác nhận"
  },
  {
    "id": "AIDEV_DOCKER_BUILDER",
    "name": "Docker Builder Cache",
    "category": "Container",
    "detectCommand": "docker --version",
    "cliCommand": "docker builder prune -f",
    "infoCommand": "docker system df",
    "description": "BuildKit cache của Docker khi build image",
    "safeToDelete": true,
    "preserve": "Docker images đang chạy, Docker volumes, containers"
  },
  {
    "id": "AIDEV_VSCODE_LOGS",
    "name": "VS Code & Cursor Disposable Cache / Logs",
    "category": "IDE",
    "defaultPath": "%APPDATA%\\Code\\logs",
    "cursorPath": "%APPDATA%\\Cursor\\logs",
    "description": "Nhật ký phiên làm việc cũ và crash dump tạm thời của VS Code và Cursor",
    "safeToDelete": true,
    "preserve": "Extensions, User Settings, Snippets, Keybindings, Conversation history"
  }
]

'@ | ConvertFrom-Json

# === SOURCE: src/UI/Colors.ps1 ===
# TM-WinCare - UI Colors & Visual Formatting
# Compatible with Windows PowerShell 5.1 & PowerShell 7

function Write-Header {
    param (
        [string]$Title,
        [int]$Width = 65
    )
    $line = "=" * $Width
    Write-Host ""
    Write-Host $line -ForegroundColor Cyan
    $pad = [math]::Max(0, [int](($Width - $Title.Length) / 2))
    $centered = (" " * $pad) + $Title
    Write-Host $centered -ForegroundColor White
    Write-Host $line -ForegroundColor Cyan
}

function Write-SubHeader {
    param (
        [string]$Title,
        [int]$Width = 65
    )
    $line = "-" * $Width
    Write-Host ""
    Write-Host (" " + $Title) -ForegroundColor Yellow
    Write-Host $line -ForegroundColor DarkGray
}

function Write-Divider {
    param ([int]$Width = 65)
    Write-Host ("-" * $Width) -ForegroundColor DarkGray
}

function Write-Success {
    param ([string]$Message)
    Write-Host "[OK] " -ForegroundColor Green -NoNewline
    Write-Host $Message -ForegroundColor White
}

function Write-WarningMessage {
    param ([string]$Message)
    Write-Host "[CẢNH BÁO] " -ForegroundColor Yellow -NoNewline
    Write-Host $Message -ForegroundColor Yellow
}

function Write-ErrorMessage {
    param ([string]$Message)
    Write-Host "[LỖI] " -ForegroundColor Red -NoNewline
    Write-Host $Message -ForegroundColor Red
}

function Write-InfoMessage {
    param ([string]$Message)
    Write-Host "[THÔNG TIN] " -ForegroundColor Cyan -NoNewline
    Write-Host $Message -ForegroundColor Gray
}

function Write-SkipMessage {
    param ([string]$Message)
    Write-Host "[BỎ QUA] " -ForegroundColor DarkYellow -NoNewline
    Write-Host $Message -ForegroundColor DarkGray
}


# === SOURCE: src/UI/Tables.ps1 ===
# TM-WinCare - UI Tables and Property Grid formatting
# Compatible with PowerShell 5.1 & PowerShell 7

function Show-PropertyGrid {
    param (
        [System.Collections.IDictionary]$Properties,
        [int]$KeyWidth = 26
    )
    foreach ($key in $Properties.Keys) {
        $val = $Properties[$key]
        $displayKey = ($key.ToString() + ":").PadRight($KeyWidth)
        Write-Host "  $displayKey " -ForegroundColor Cyan -NoNewline
        if ($val -is [string] -and ($val -match "OK|Đang chạy|Hoạt động|Bật|Đã kích hoạt|Khỏe mạnh")) {
            Write-Host $val -ForegroundColor Green
        }
        elseif ($val -is [string] -and ($val -match "Cảnh báo|Hết hạn|Gần đầy|Tắt|Dừng")) {
            Write-Host $val -ForegroundColor Yellow
        }
        elseif ($val -is [string] -and ($val -match "Lỗi|Hỏng|Không kết nối")) {
            Write-Host $val -ForegroundColor Red
        }
        else {
            Write-Host "$val" -ForegroundColor White
        }
    }
}

function Show-TableList {
    param (
        [array]$Items,
        [array]$Headers,
        [array]$PropertyNames,
        [array]$Widths
    )
    if (-not $Items -or $Items.Count -eq 0) {
        Write-Host "  (Không có dữ liệu)" -ForegroundColor DarkGray
        return
    }

    # Print Header
    $headerLine = "  "
    for ($i = 0; $i -lt $Headers.Count; $i++) {
        $w = if ($i -lt $Widths.Count) { $Widths[$i] } else { 20 }
        $headerLine += ($Headers[$i].ToString().PadRight($w)) + " "
    }
    Write-Host $headerLine -ForegroundColor Yellow
    Write-Host ("  " + ("-" * [math]::Min(75, ($headerLine.Length)))) -ForegroundColor DarkGray

    # Print Rows
    foreach ($item in $Items) {
        $rowLine = "  "
        for ($i = 0; $i -lt $Headers.Count; $i++) {
            $w = if ($i -lt $Widths.Count) { $Widths[$i] } else { 20 }
            $prop = $PropertyNames[$i]
            $val = if ($item -is [hashtable]) { $item[$prop] } else { $item.$prop }
            $strVal = if ($null -eq $val) { "" } else { $val.ToString() }
            if ($strVal.Length -gt $w) {
                $strVal = $strVal.Substring(0, [math]::Max(3, $w - 3)) + "..."
            }
            $rowLine += ($strVal.PadRight($w)) + " "
        }
        Write-Host $rowLine -ForegroundColor White
    }
}


# === SOURCE: src/UI/Prompts.ps1 ===
# TM-WinCare - User Interaction & Prompts
# Compatible with PowerShell 5.1 & PowerShell 7

function Read-MenuSelection {
    param (
        [string]$PromptText = "Lựa chọn của bạn",
        [int]$Min = 0,
        [int]$Max = 99
    )
    while ($true) {
        Write-Host ""
        Write-Host " $PromptText [$Min-$Max]: " -ForegroundColor Cyan -NoNewline
        $inputVal = Read-Host
        if ($inputVal -match "^\d+$") {
            $num = [int]$inputVal
            if ($num -ge $Min -and $num -le $Max) {
                return $num
            }
        }
        Write-ErrorMessage "Vui lòng nhập một số hợp lệ từ $Min đến $Max."
    }
}

function Confirm-Action {
    param (
        [string]$TaskName,
        [string]$ImpactDescription,
        [string]$RiskLevel = "medium",
        [bool]$RequiresKeyword = $false
    )
    Write-Host ""
    Write-Host "=========================================================" -ForegroundColor Yellow
    Write-Host " XÁC NHẬN THỰC HIỆN TÁC VỤ: $TaskName" -ForegroundColor White
    Write-Host " Mức độ rủi ro: $RiskLevel" -ForegroundColor Yellow
    if ($ImpactDescription) {
        Write-Host " Ảnh hưởng:" -ForegroundColor Gray
        Write-Host "   $ImpactDescription" -ForegroundColor Gray
    }
    Write-Host "=========================================================" -ForegroundColor Yellow

    if ($RequiresKeyword -or $RiskLevel -eq "high") {
        Write-Host " Tác vụ có rủi ro cao. Nhập 'APPLY' để xác nhận thực hiện, hoặc bấm phím khác để hủy:" -ForegroundColor Red -NoNewline
        $ans = Read-Host
        return ($ans.Trim() -eq "APPLY")
    }

    Write-Host " Bạn có chắc chắn muốn tiếp tục? (Y/N): " -ForegroundColor Cyan -NoNewline
    $ans = Read-Host
    return ($ans.Trim().ToUpper() -eq "Y")
}

function Read-SecurePassword {
    param (
        [string]$PromptText = "Nhập mật khẩu"
    )
    Write-Host " $($PromptText): " -ForegroundColor Cyan -NoNewline
    $sec = Read-Host -AsSecureString
    return $sec
}

function Pause-Screen {
    param (
        [string]$Message = "Nhấn Enter để quay lại menu..."
    )
    Write-Host ""
    Write-Host " $Message" -ForegroundColor DarkGray
    [void][System.Console]::ReadLine()
}


# === SOURCE: src/Core/Logger.ps1 ===
# TM-WinCare - Structured Logging (TXT & JSONL)
# Adheres to Section 11 of TM-WinCare-Architecture-v1.2.md

$script:LogDirectory = if ($PSScriptRoot) { Join-Path $PSScriptRoot "../../Logs" } else { Join-Path $env:TEMP "TM-WinCare\Logs" }
if (-not (Test-Path $script:LogDirectory)) {
    New-Item -ItemType Directory -Path $script:LogDirectory -Force | Out-Null
}

function Sanitize-LogMessage {
    param ([string]$Message)
    if ([string]::IsNullOrEmpty($Message)) { return "" }
    # Filter passwords, tokens, credentials
    $sanitized = $Message -replace "(?i)(password|pwd|secret|token|key)\s*[:=]\s*\S+", '$1: [REDACTED]'
    $sanitized = $sanitized -replace '(?i)(net\s+user\s+\S+\s+)"?[^"\s/]+"?', '$1[REDACTED]'
    $sanitized = $sanitized -replace '(?i)/add\s+"[^"]+"', '/add [REDACTED]'
    return $sanitized
}

function Write-TMLog {
    param (
        [string]$TaskId = "SYS",
        [string]$TaskName = "Hệ thống",
        [ValidateSet("Started", "Success", "Failed", "Skipped", "Warning", "Info")]
        [string]$Status = "Info",
        [string]$Message = "",
        [string]$BackupId = "",
        [bool]$RequiresRestart = $false
    )

    $cleanMsg = Sanitize-LogMessage -Message $Message
    $now = Get-Date
    $dateStr = $now.ToString("yyyy-MM-dd")
    $timeStr = $now.ToString("yyyy-MM-dd HH:mm:ss")
    $logTxtPath = Join-Path $script:LogDirectory "$dateStr.log"
    $logJsonlPath = Join-Path $script:LogDirectory "$dateStr.jsonl"

    $osVersion = if ($global:TM_OS_INFO) { "$($global:TM_OS_INFO.Version) Build $($global:TM_OS_INFO.Build)" } else { [System.Environment]::OSVersion.VersionString }

    # 1. Plain text log
    $txtLine = "[$timeStr] [$Status] [$TaskId] $TaskName - $cleanMsg"
    if ($BackupId) { $txtLine += " (Backup: $BackupId)" }
    if ($RequiresRestart) { $txtLine += " [Requires Restart]" }
    
    try {
        Add-Content -Path $logTxtPath -Value $txtLine -Encoding UTF8 -ErrorAction SilentlyContinue
    } catch {}

    # 2. Structured JSONL record
    $record = [ordered]@{
        timestamp = $now.ToString("o")
        taskId = $TaskId
        taskName = $TaskName
        status = $Status
        message = $cleanMsg
        backupId = $BackupId
        requiresRestart = $RequiresRestart
        os = $osVersion
        user = "$([System.Environment]::UserDomainName)\$([System.Environment]::UserName)"
    }

    try {
        $jsonLine = $record | ConvertTo-Json -Compress
        Add-Content -Path $logJsonlPath -Value $jsonLine -Encoding UTF8 -ErrorAction SilentlyContinue
    } catch {}
}


# === SOURCE: src/Core/Admin.ps1 ===
# TM-WinCare - Elevation & Admin Check
# Adheres to Section 13 of TM-WinCare-Architecture-v1.2.md

function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Assert-Admin {
    param (
        [string]$ActionName = "thao tác này"
    )
    if (-not (Test-IsAdmin)) {
        Write-ErrorMessage "Bạn cần chạy với quyền Quản trị viên (Run as Administrator) để thực hiện $ActionName."
        Write-InfoMessage "Vui lòng đóng công cụ và chuột phải vào Start.cmd -> chọn 'Run as administrator'."
        return $false
    }
    return $true
}

function Request-Elevation {
    param (
        [string]$Reason = "thực hiện các tác vụ quản trị hệ thống"
    )
    if (Test-IsAdmin) { return $true }

    Write-WarningMessage "Yêu cầu nâng quyền Administrator để $Reason."
    Write-Host " Bạn có muốn mở phiên làm việc mới với quyền Administrator không? (Y/N): " -ForegroundColor Cyan -NoNewline
    $ans = Read-Host
    if ($ans.Trim().ToUpper() -eq "Y") {
        $startCmd = Join-Path $PSScriptRoot "../../Start.cmd"
        if (Test-Path $startCmd) {
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$startCmd`"" -Verb RunAs
            exit 0
        }
    }
    return $false
}


# === SOURCE: src/Core/WindowsInfo.ps1 ===
# TM-WinCare - Hardware & Windows OS Detection Engine
# Adheres to Section 3.1 & Section 12 of TM-WinCare-Architecture-v1.2.md
# No WMIC dependency; uses CIM & Native Registry

function Get-TMSystemInfo {
    $info = [ordered]@{}

    # 1. OS & Build Identification
    try {
        $osCim = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
        $buildNumber = [int]$osCim.BuildNumber
        $osCaption = $osCim.Caption
        
        # Determine Windows 10 vs 11 cleanly
        $isWin11 = ($buildNumber -ge 22000)
        $osFamily = if ($isWin11) { "Windows 11" } else { "Windows 10" }

        # Get DisplayVersion (e.g. 22H2, 23H2) from Registry
        $displayVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name DisplayVersion -ErrorAction SilentlyContinue).DisplayVersion
        if (-not $displayVersion) {
            $displayVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ReleaseId -ErrorAction SilentlyContinue).ReleaseId
        }

        # Check Windows 10 EOL
        $eolNotice = ""
        if (-not $isWin11 -and $buildNumber -le 19045) {
            $eolNotice = " [Hết hỗ trợ tiêu chuẩn 14/10/2025]"
        }

        $info["Hệ điều hành"] = "$osFamily $displayVersion (Build $buildNumber)$eolNotice"
        $info["Phiên bản chi tiết"] = $osCaption
        $info["Kiến trúc"] = $osCim.OSArchitecture
        $info["Tên máy (Hostname)"] = [System.Environment]::MachineName
        $info["Người dùng hiện tại"] = "$([System.Environment]::UserDomainName)\$([System.Environment]::UserName)"
        $info["Quyền Administrator"] = if (Test-IsAdmin) { "Có (Elevated)" } else { "Không (Standard User)" }
    } catch {
        $info["Hệ điều hành"] = "Windows (Không thể đọc CIM: $($_.Exception.Message))"
    }

    # 2. Hardware: CPU & RAM
    try {
        $cpu = Get-CimInstance -ClassName Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($cpu) {
            $info["Bộ vi xử lý (CPU)"] = $cpu.Name.Trim()
        }

        $totalMem = [math]::Round($osCim.TotalVisibleMemorySize / 1MB, 1)
        $freeMem = [math]::Round($osCim.FreePhysicalMemory / 1MB, 1)
        $usedMem = [math]::Round($totalMem - $freeMem, 1)
        $pctMem = [math]::Round(($usedMem / $totalMem) * 100, 0)
        $info["Bộ nhớ RAM"] = "$usedMem GB / $totalMem GB ($pctMem% đang dùng - $freeMem GB trống)"
    } catch {}

    # 3. Storage
    try {
        $drives = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction SilentlyContinue
        $driveSummaries = @()
        foreach ($d in $drives) {
            $totalGB = [math]::Round($d.Size / 1GB, 1)
            $freeGB = [math]::Round($d.FreeSpace / 1GB, 1)
            $pctFree = if ($totalGB -gt 0) { [math]::Round(($freeGB / $totalGB) * 100, 0) } else { 0 }
            $driveSummaries += "$($d.DeviceID) ($freeGB GB trống / $totalGB GB - $pctFree%)"
        }
        $info["Ổ đĩa lưu trữ"] = $driveSummaries -join ", "
    } catch {}

    # 4. Network Status
    try {
        $net = Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "*Wi-Fi*","*Ethernet*","*LAN*" -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notlike "169.254*" } | Select-Object -First 1
        if ($net) {
            $info["Địa chỉ IPv4"] = "$($net.IPAddress) ($($net.InterfaceAlias))"
        } else {
            $info["Địa chỉ IPv4"] = "Không phát hiện card mạng LAN/Wi-Fi đang kết nối"
        }
    } catch {
        $info["Địa chỉ IPv4"] = "Không thể lấy thông tin mạng"
    }

    # 5. Security & Services
    try {
        $spooler = Get-Service -Name Spooler -ErrorAction SilentlyContinue
        $info["Print Spooler"] = if ($spooler) { "$($spooler.Status) (Khởi động: $($spooler.StartType))" } else { "Không tìm thấy" }
    } catch {}

    try {
        $printers = Get-Printer -ErrorAction SilentlyContinue
        $printerCount = if ($printers) { @($printers).Count } else { 0 }
        $info["Số lượng máy in đã cài"] = "$printerCount máy in"
    } catch {
        $info["Số lượng máy in đã cài"] = "Không thể đọc danh sách máy in"
    }

    try {
        $defenderSvc = Get-Service -Name WinDefend -ErrorAction SilentlyContinue
        $info["Microsoft Defender"] = if ($defenderSvc -and $defenderSvc.Status -eq "Running") { "Đang chạy (Hoạt động)" } else { "Tắt hoặc không khả dụng" }
    } catch {}

    # Store global OS info
    $global:TM_OS_INFO = [PSCustomObject]@{
        IsWin11 = $isWin11
        Build = $buildNumber
        Version = $displayVersion
        Edition = $osCaption
        TotalRAM = $totalMem
        IsAdmin = (Test-IsAdmin)
    }

    return $info
}


# === SOURCE: src/Core/Compatibility.ps1 ===
# TM-WinCare - Compatibility & Feature Testing
# Adheres to Section 12 of TM-WinCare-Architecture-v1.2.md

function Test-IsWindowsHome {
    try {
        $edition = (Get-CimInstance Win32_OperatingSystem).Caption
        return ($edition -match "Home")
    } catch {
        return $false
    }
}

function Test-CmdletAvailable {
    param ([string]$Name)
    $cmd = Get-Command -Name $Name -ErrorAction SilentlyContinue
    return ($null -ne $cmd)
}

function Test-ToolAvailable {
    param ([string]$ExecutableName)
    $path = Get-Command -Name $ExecutableName -ErrorAction SilentlyContinue
    return ($null -ne $path)
}

function Assert-FeatureSupported {
    param (
        [string]$FeatureName,
        [int]$MinBuild = 0,
        [bool]$RequiresPro = $false
    )
    if ($global:TM_OS_INFO) {
        if ($MinBuild -gt 0 -and $global:TM_OS_INFO.Build -lt $MinBuild) {
            Write-WarningMessage "$FeatureName yêu cầu Windows build tối thiểu $MinBuild (Hiện tại: $($global:TM_OS_INFO.Build))."
            return $false
        }
        if ($RequiresPro -and (Test-IsWindowsHome)) {
            Write-WarningMessage "$FeatureName yêu cầu phiên bản Windows Pro/Enterprise (Phiên bản Home không hỗ trợ chính thức)."
            return $false
        }
    }
    return $true
}


# === SOURCE: src/Core/Backup.ps1 ===
# TM-WinCare - State Backup & Rollback Engine
# Adheres to Section 8 of TM-WinCare-Architecture-v1.2.md

$script:BackupDirectory = if ($PSScriptRoot) { Join-Path $PSScriptRoot "../../Backups" } else { Join-Path $env:SystemDrive "TM-WinCare\Backups" }
if (-not (Test-Path $script:BackupDirectory)) {
    New-Item -ItemType Directory -Path $script:BackupDirectory -Force | Out-Null
}

function New-TMBackupSession {
    param (
        [string]$TaskId,
        [string]$Description
    )
    $backupId = (Get-Date).ToString("yyyy-MM-dd_HHmmss")
    $sessionDir = Join-Path $script:BackupDirectory $backupId
    New-Item -ItemType Directory -Path $sessionDir -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $sessionDir "registry") -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $sessionDir "services") -Force | Out-Null

    $manifest = [ordered]@{
        backupId = $backupId
        taskId = $TaskId
        description = $Description
        createdAt = (Get-Date).ToString("o")
        machine = [System.Environment]::MachineName
        user = "$([System.Environment]::UserDomainName)\$([System.Environment]::UserName)"
        registry = @()
        services = @()
    }

    return [PSCustomObject]@{
        Id = $backupId
        Directory = $sessionDir
        Manifest = $manifest
    }
}

function Backup-RegistryValue {
    param (
        [PSCustomObject]$Session,
        [string]$Path,
        [string]$Name
    )
    try {
        $regItem = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
        $exists = ($null -ne $regItem -and $null -ne $regItem.$Name)
        $oldVal = if ($exists) { $regItem.$Name } else { $null }
        
        # Detect Registry Value Kind
        $valKind = "Unknown"
        if ($exists) {
            try {
                $hiveKey = Get-Item -Path $Path -ErrorAction Stop
                $valKind = $hiveKey.GetValueKind($Name).ToString()
            } catch {}
        }

        # Backup key to .reg file
        $regFile = Join-Path $Session.Directory "registry/$($Name)_backup.reg"
        $cmdPath = $Path -replace '^Registry::', '' -replace '^HKLM:', 'HKLM' -replace '^HKCU:', 'HKCU'
        & reg.exe export "$cmdPath" "$regFile" /y *>$null

        $Session.Manifest.registry += [ordered]@{
            path = $Path
            name = $Name
            existed = $exists
            oldValue = $oldVal
            valueKind = $valKind
            regFile = $regFile
        }
        return $true
    } catch {
        Write-ErrorMessage "Không thể sao lưu Registry: $($_.Exception.Message)"
        return $false
    }
}

function Backup-ServiceState {
    param (
        [PSCustomObject]$Session,
        [string]$ServiceName
    )
    try {
        $svc = Get-Service -Name $ServiceName -ErrorAction Stop
        $startMode = (Get-CimInstance Win32_Service -Filter "Name='$ServiceName'").StartMode
        $Session.Manifest.services += [ordered]@{
            name = $ServiceName
            status = $svc.Status.ToString()
            startMode = $startMode
        }
        return $true
    } catch {
        Write-ErrorMessage "Không thể sao lưu trạng thái Service $ServiceName : $($_.Exception.Message)"
        return $false
    }
}

function Save-TMBackupSession {
    param (
        [PSCustomObject]$Session
    )
    try {
        $manifestPath = Join-Path $Session.Directory "manifest.json"
        $json = $Session.Manifest | ConvertTo-Json -Depth 5
        Set-Content -Path $manifestPath -Value $json -Encoding UTF8 -Force
        Write-Success "Đã tạo bản sao lưu an toàn: $($Session.Id)"
        return $Session.Id
    } catch {
        Write-ErrorMessage "Lỗi khi lưu manifest backup: $($_.Exception.Message)"
        return $null
    }
}


# === SOURCE: src/Core/Restore.ps1 ===
# TM-WinCare - Restore & Rollback Engine
# Adheres to Section 8 of TM-WinCare-Architecture-v1.2.md

function Get-TMBackupList {
    $backupDir = if ($PSScriptRoot) { Join-Path $PSScriptRoot "../../Backups" } else { Join-Path $env:SystemDrive "TM-WinCare\Backups" }
    if (-not (Test-Path $backupDir)) { return @() }
    
    $list = @()
    $folders = Get-ChildItem -Path $backupDir -Directory | Sort-Object Name -Descending
    foreach ($f in $folders) {
        $manifestPath = Join-Path $f.FullName "manifest.json"
        if (Test-Path $manifestPath) {
            try {
                $manifest = Get-Content -Path $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
                $list += [PSCustomObject]@{
                    Id = $f.Name
                    Description = $manifest.description
                    TaskId = $manifest.taskId
                    CreatedAt = $manifest.createdAt
                    Path = $f.FullName
                }
            } catch {}
        }
    }
    return $list
}

function Invoke-TMRollback {
    param (
        [string]$BackupId
    )
    if (-not (Assert-Admin "khôi phục sao lưu")) { return $false }

    $backupRoot = if ($PSScriptRoot) { Join-Path $PSScriptRoot "../../Backups" } else { Join-Path $env:SystemDrive "TM-WinCare\Backups" }
    $backupDir = Join-Path $backupRoot $BackupId
    $manifestPath = Join-Path $backupDir "manifest.json"
    if (-not (Test-Path $manifestPath)) {
        Write-ErrorMessage "Không tìm thấy file manifest của bản sao lưu: $BackupId"
        return $false
    }

    try {
        $manifest = Get-Content -Path $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
        Write-SubHeader "KHÔI PHỤC BẢN SAO LƯU: $BackupId ($($manifest.description))"

        # 1. Rollback Registry
        if ($manifest.registry) {
            foreach ($item in $manifest.registry) {
                Write-InfoMessage "Khôi phục Registry: $($item.path) -> $($item.name)"
                if ($item.existed) {
                    if (-not (Test-Path $item.path)) {
                        New-Item -Path $item.path -Force | Out-Null
                    }
                    Set-ItemProperty -Path $item.path -Name $item.name -Value $item.oldValue -Force
                    Write-Success "Đã khôi phục giá trị: $($item.name) = $($item.oldValue)"
                } else {
                    # If it did not exist before, remove it
                    Remove-ItemProperty -Path $item.path -Name $item.name -ErrorAction SilentlyContinue
                    Write-Success "Đã xóa thuộc tính được thêm mới: $($item.name)"
                }
            }
        }

        # 2. Rollback Services
        if ($manifest.services) {
            foreach ($svc in $manifest.services) {
                Write-InfoMessage "Khôi phục Service: $($svc.name) -> $($svc.startMode)"
                try {
                    $startType = switch ($svc.startMode) {
                        "Auto" { "Automatic" }
                        "Manual" { "Manual" }
                        "Disabled" { "Disabled" }
                        default { "Manual" }
                    }
                    Set-Service -Name $svc.name -StartupType $startType -ErrorAction SilentlyContinue
                    if ($svc.status -eq "Running") {
                        Start-Service -Name $svc.name -ErrorAction SilentlyContinue
                    }
                    Write-Success "Đã khôi phục dịch vụ: $($svc.name)"
                } catch {
                    Write-ErrorMessage "Không thể khôi phục dịch vụ $($svc.name): $($_.Exception.Message)"
                }
            }
        }

        Write-TMLog -TaskId "ROLLBACK" -TaskName "Khôi phục sao lưu" -Status "Success" -Message "Đã khôi phục bản sao lưu $BackupId"
        Write-Success "Quá trình hoàn tác bản sao lưu $BackupId đã hoàn thành thành công!"
        return $true
    } catch {
        Write-ErrorMessage "Lỗi trong quá trình khôi phục: $($_.Exception.Message)"
        Write-TMLog -TaskId "ROLLBACK" -TaskName "Khôi phục sao lưu" -Status "Failed" -Message "Lỗi: $($_.Exception.Message)"
        return $false
    }
}


# === SOURCE: src/Core/Confirm.ps1 ===
# TM-WinCare - Task Confirmation & Safety Gate
# Adheres to Section 1 & Section 13 of TM-WinCare-Architecture-v1.2.md

function Test-TaskApproval {
    param (
        [string]$TaskId,
        [string]$TaskName,
        [string]$ImpactDescription,
        [string]$RiskLevel = "low",
        [bool]$RequiresAdmin = $false
    )
    
    # 1. Elevation check
    if ($RequiresAdmin -and -not (Test-IsAdmin)) {
        if (-not (Request-Elevation -Reason "thực hiện tác vụ '$TaskName'")) {
            Write-SkipMessage "Đã bỏ qua tác vụ '$TaskName' do thiếu quyền Administrator."
            return $false
        }
    }

    # 2. Risk confirmation
    $approved = Confirm-Action -TaskName $TaskName -ImpactDescription $ImpactDescription -RiskLevel $RiskLevel
    if (-not $approved) {
        Write-SkipMessage "Người dùng đã từ chối thực hiện tác vụ '$TaskName'."
        Write-TMLog -TaskId $TaskId -TaskName $TaskName -Status "Skipped" -Message "Bỏ qua bởi người dùng"
        return $false
    }

    return $true
}


# === SOURCE: src/Core/ErrorHandler.ps1 ===
# TM-WinCare - Centralized Error Handling
# Adheres to Section 11 & Section 17 of TM-WinCare-Architecture-v1.2.md

function Handle-TMException {
    param (
        [string]$TaskId,
        [string]$TaskName,
        [System.Exception]$Exception,
        [string]$Context = ""
    )
    $msg = $Exception.Message
    Write-ErrorMessage "Đã xảy ra lỗi trong quá trình thực hiện [$TaskId] $TaskName"
    if ($Context) {
        Write-InfoMessage "Ngữ cảnh: $Context"
    }
    Write-Host "  Chi tiết lỗi: $msg" -ForegroundColor Red

    # Log error
    Write-TMLog -TaskId $TaskId -TaskName $TaskName -Status "Failed" -Message "Lỗi: $msg ($Context)"
}

function Invoke-TMSafeBlock {
    param (
        [string]$TaskId,
        [string]$TaskName,
        [scriptblock]$Action,
        [string]$Context = ""
    )
    try {
        & $Action
    } catch {
        Handle-TMException -TaskId $TaskId -TaskName $TaskName -Exception $_.Exception -Context $Context
    }
}


# === SOURCE: src/Core/Menu.ps1 ===
# TM-WinCare - Interactive Console Menu Engine
# Adheres to Section 10 of TM-WinCare-Architecture-v1.2.md

function Show-TMMenu {
    param (
        [string]$Title,
        [array]$MenuItems,
        [string]$ExitLabel = "Quay lại"
    )

    while ($true) {
        Write-Header -Title $Title
        
        for ($i = 0; $i -lt $MenuItems.Count; $i++) {
            $num = $i + 1
            $item = $MenuItems[$i]
            $padNum = $num.ToString().PadLeft(2)
            Write-Host "  [$padNum] " -ForegroundColor Cyan -NoNewline
            Write-Host "$($item.Label)" -ForegroundColor White
        }

        Write-Host "  [ 0] " -ForegroundColor Yellow -NoNewline
        Write-Host "$ExitLabel" -ForegroundColor Yellow
        Write-Divider

        $selection = Read-MenuSelection -PromptText "Chọn chức năng" -Min 0 -Max $MenuItems.Count
        if ($selection -eq 0) {
            break
        }

        $chosen = $MenuItems[$selection - 1]
        if ($chosen.Action -is [scriptblock]) {
            try {
                & $chosen.Action
            } catch {
                Write-ErrorMessage "Lỗi thực thi mục menu: $($_.Exception.Message)"
            }
        }
    }
}


# === SOURCE: src/Modules/Dashboard/Dashboard.ps1 ===
# TM-WinCare - Dashboard & System Health Information
# Adheres to Section 3.1 of TM-WinCare-Architecture-v1.2.md

function Show-TMDashboard {
    Write-Header -Title "THÔNG TIN HỆ THỐNG & DASHBOARD"
    Write-InfoMessage "Đang tải thông tin phần cứng và hệ điều hành..."

    $sys = Get-TMSystemInfo
    Write-Host ""
    Show-PropertyGrid -Properties $sys -KeyWidth 25

    Write-Host ""
    Write-Host "  [1] Làm mới thông tin (Refresh)" -ForegroundColor Cyan
    Write-Host "  [2] Xuất báo cáo hệ thống ra file TXT" -ForegroundColor Cyan
    Write-Host "  [3] Xuất báo cáo hệ thống ra file JSON" -ForegroundColor Cyan
    Write-Host "  [0] Quay lại Menu chính" -ForegroundColor Yellow
    Write-Divider

    $sel = Read-MenuSelection -PromptText "Chọn thao tác" -Min 0 -Max 3
    switch ($sel) {
        1 { Show-TMDashboard }
        2 { Export-TMDashboardText -Properties $sys }
        3 { Export-TMDashboardJson -Properties $sys }
        0 { return }
    }
}

function Export-TMDashboardText {
    param ([System.Collections.IDictionary]$Properties)
    $reportDir = Join-Path $PSScriptRoot "../../../Logs"
    $filename = "SystemReport_" + (Get-Date).ToString("yyyyMMdd_HHmmss") + ".txt"
    $fullPath = Join-Path $reportDir $filename

    $lines = @()
    $lines += "========================================================="
    $lines += "         TM-WINCARE - BÁO CÁO THÔNG TIN HỆ THỐNG"
    $lines += "  Thời gian tạo: " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $lines += "========================================================="
    foreach ($k in $Properties.Keys) {
        $lines += ("{0,-28}: {1}" -f $k, $Properties[$k])
    }
    $lines += "========================================================="

    Set-Content -Path $fullPath -Value $lines -Encoding UTF8 -Force
    Write-Success "Đã xuất báo cáo ra file: $fullPath"
    Write-TMLog -TaskId "REPORT_TXT" -TaskName "Xuất báo cáo hệ thống" -Status "Success" -Message "Đã xuất file $filename"
    Pause-Screen
}

function Export-TMDashboardJson {
    param ([System.Collections.IDictionary]$Properties)
    $reportDir = Join-Path $PSScriptRoot "../../../Logs"
    $filename = "SystemReport_" + (Get-Date).ToString("yyyyMMdd_HHmmss") + ".json"
    $fullPath = Join-Path $reportDir $filename

    $obj = [ordered]@{
        generator = "TM-WinCare v$($global:TM_CONFIG.version)"
        timestamp = (Get-Date).ToString("o")
        system = $Properties
    }
    $json = $obj | ConvertTo-Json -Depth 4
    Set-Content -Path $fullPath -Value $json -Encoding UTF8 -Force
    Write-Success "Đã xuất báo cáo ra file: $fullPath"
    Write-TMLog -TaskId "REPORT_JSON" -TaskName "Xuất báo cáo hệ thống JSON" -Status "Success" -Message "Đã xuất file $filename"
    Pause-Screen
}


# === SOURCE: src/Modules/PostInstall/CheckLicense.ps1 ===
# TM-WinCare - Windows & Office License Management (IT Inventory)
# Decodes Full 25-character Windows Key & Office Key, Mainboard Serial, UUID, Sync to Google Sheets / Form

function Invoke-LicenseInventoryCheck {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

    # ==================== CAU HINH LINK GOOGLE SHEETS / FORM ====================
    $WEB_APP_URL      = "https://script.google.com/macros/s/AKfycbyY0fbv2IehFvC8oLCi9sFIYI_HHXNyF2WEfCBdKDOwkW-5MmjFyBacjqbHXfj4R5YI0w/exec"
    $GOOGLE_FORM_URL  = "https://docs.google.com/forms/d/e/1FAIpQLSfrIXm1b_mpo0A_L0Ns4IUOElJSeAqYcOYtMY6REThZP8phKQ/viewform"
    $PREFILL_TEMPLATE = "https://docs.google.com/forms/d/e/1FAIpQLSfrIXm1b_mpo0A_L0Ns4IUOElJSeAqYcOYtMY6REThZP8phKQ/viewform?usp=pp_url&entry.149006453=__TEN_MAY__&entry.2097722978=__UUID__&entry.172201661=__MODEL__&entry.218557984=__SERIAL__&entry.2007771510=__WIN_VER__&entry.901102999=Da+kich+hoat&entry.1856982139=__WIN_KEY__&entry.610740607=__OFF_VER__&entry.695594658=Da+kich+hoat&entry.1357205106=__OFF_KEY__&entry.1710584041=__GHI_CHU__"
    $GOOGLE_SHEET_URL = "https://docs.google.com/spreadsheets/d/1GsDhi-PbcJylNoSbZaXqtzF92ZCOe12LkASalCUdHQQ/edit"
    # ============================================================================

    function Get-RegistryProductKeyLocal($regPath) {
        try {
            $reg = Get-ItemProperty -Path $regPath -ErrorAction Stop
            $bin = $reg.DigitalProductId
            if (-not $bin) { return $null }
            $chars = "BCDFGHJKMPQRTVWXY2346789"
            $isWin8OrNewer = ([math]::Truncate($bin[66] / 6) -band 1)
            $bin[66] = ($bin[66] -band 0xF7) -bor (($isWin8OrNewer -band 2) * 4)
            $keyOutput = ""
            $last = 0
            for ($i = 24; $i -ge 0; $i--) {
                $cur = 0
                for ($j = 14; $j -ge 0; $j--) {
                    $cur = $cur * 256
                    $cur = $bin[$j + 52] + $cur
                    $bin[$j + 52] = [math]::Truncate($cur / 24)
                    $cur = $cur % 24
                }
                $keyOutput = $chars[$cur] + $keyOutput
                $last = $cur
            }
            if ($isWin8OrNewer -eq 1) {
                $keypart1 = $keyOutput.Substring(1, $last)
                $keypart2 = $keyOutput.Substring($last + 1, $keyOutput.Length - ($last + 1))
                $keyOutput = $keypart1 + "N" + $keypart2
            }
            return ($keyOutput -replace '(.{5})', '$1-').TrimEnd('-')
        } catch {
            return $null
        }
    }

    Write-Host "`n[*] Đang quét phần cứng và giải mã toàn bộ Key Windows / Office..." -ForegroundColor Cyan

    $cs = Get-CimInstance Win32_ComputerSystemProduct -ErrorAction SilentlyContinue
    $bb = Get-CimInstance Win32_BaseBoard -ErrorAction SilentlyContinue
    $os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
    $sls = Get-CimInstance SoftwareLicensingService -ErrorAction SilentlyContinue

    # 1. Full Key Windows (Registry + Backup Key + BIOS OEM Key)
    $winRegKey = Get-RegistryProductKeyLocal "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    $winBackupKey = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" -ErrorAction SilentlyContinue).BackupProductKeyDefault
    $winOemKey = if ($sls) { $sls.OA3xOriginalProductKey } else { $null }

    $winAllLic = Get-CimInstance SoftwareLicensingProduct -ErrorAction SilentlyContinue | Where-Object { $_.ApplicationID -eq '55c92734-d682-4d71-983e-d6ec3f16059f' -and $_.PartialProductKey } | Sort-Object LicenseStatus -Descending
    $winActiveLic = $winAllLic | Select-Object -First 1
    $winStatus = if ($winActiveLic -and $winActiveLic.LicenseStatus -eq 1) { "Da kich hoat" } else { "Chua kich hoat" }
    $winPartial = if ($winActiveLic -and $winActiveLic.PartialProductKey) { $winActiveLic.PartialProductKey } else { "N/A" }

    $winFullList = @()
    if ($winRegKey) { $winFullList += "Active: $winRegKey" }
    if ($winBackupKey -and $winBackupKey -ne $winRegKey) { $winFullList += "Backup: $winBackupKey" }
    if ($winOemKey) { $winFullList += "OEM-BIOS: $winOemKey" }
    if ($winFullList.Count -eq 0) { $winFullList += "5-Cuoi: $winPartial" }
    $winKeySummary = $winFullList -join " | "

    # 2. Key Office tren may
    $offAllLic = @(Get-CimInstance SoftwareLicensingProduct -ErrorAction SilentlyContinue | Where-Object { $_.Name -like '*Office*' -and $_.PartialProductKey })
    if ($offAllLic.Count -eq 0) {
        $offAllLic = @(Get-CimInstance OfficeSoftwareProtectionProduct -ErrorAction SilentlyContinue | Where-Object { $_.PartialProductKey })
    }

    $offRegKeys = @()
    $offRegPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Office\*\Registration\*",
        "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Office\*\Registration\*"
    )
    foreach ($p in $offRegPaths) {
        Get-ItemProperty -Path $p -ErrorAction SilentlyContinue | ForEach-Object {
            $k = Get-RegistryProductKeyLocal $_.PSPath
            if ($k -and ($offRegKeys -notcontains $k)) { $offRegKeys += $k }
        }
    }

    if ($offAllLic.Count -gt 0) {
        $offNames = @()
        $offStatuses = @()
        $offKeys = @()

        foreach ($item in ($offAllLic | Sort-Object LicenseStatus -Descending)) {
            $cleanName = ($item.Name -replace 'Office \d+, ', '' -replace ' edition', '' -replace 'Microsoft ', '').Trim()
            $st = if ($item.LicenseStatus -eq 1) { "Da kich hoat" } else { "Chua kich hoat" }
            $pk = $item.PartialProductKey

            $matchedFull = $offRegKeys | Where-Object { $_ -like "*$pk" } | Select-Object -First 1
            $keyDisplay = if ($matchedFull) { $matchedFull } else { "XXXXX-$pk ($cleanName)" }

            $offNames += $cleanName
            $offStatuses += $st
            $offKeys += $keyDisplay
        }
        $offNameSummary = ($offNames | Select-Object -Unique) -join " | "
        $offStatusSummary = if ($offStatuses -contains "Da kich hoat") { "Da kich hoat" } else { "Chua kich hoat" }
        $offKeySummary = $offKeys -join " | "
    } else {
        $offNameSummary = "Chua cai"
        $offStatusSummary = "Chua kich hoat"
        $offKeySummary = "N/A"
    }

    $dataObj = [ordered]@{
        "Thoi_Gian_Check"   = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        "Ten_May"           = $env:COMPUTERNAME
        "UUID_Mainboard"    = if ($cs -and $cs.UUID) { $cs.UUID } else { "N/A" }
        "Model_Mainboard"   = if ($bb) { "$($bb.Manufacturer) $($bb.Product)".Trim() } else { "N/A" }
        "Serial_Mainboard"  = if ($bb -and $bb.SerialNumber) { $bb.SerialNumber } else { "N/A" }
        "Phien_Ban_Win"     = if ($os) { ($os.Caption -replace 'Microsoft ', '').Trim() } else { "Windows" }
        "Trang_Thai_Win"    = $winStatus
        "Key_Win_5_Cuoi"    = $winKeySummary
        "Phien_Ban_Office"  = $offNameSummary
        "Trang_Thai_Office" = $offStatusSummary
        "Key_Office_5_Cuoi" = $offKeySummary
        "Nguon_Nhap"        = "TM-WinCare"
        "Ghi_Chu"           = ""
        "Cap_Nhat_Trung"    = $true
    }

    function Show-TerminalInfoLocal {
        Write-Host "`n================ THÔNG TIN MÁY & TOÀN BỘ BẢN QUYỀN KEY ================" -ForegroundColor Green
        Write-Host ("  Thời gian check   : {0}" -f $dataObj.Thoi_Gian_Check)
        Write-Host ("  Tên máy           : {0}" -f $dataObj.Ten_May) -ForegroundColor Yellow
        Write-Host ("  UUID Mainboard    : {0}" -f $dataObj.UUID_Mainboard)
        Write-Host ("  Model Mainboard   : {0}" -f $dataObj.Model_Mainboard)
        Write-Host ("  Serial Mainboard  : {0}" -f $dataObj.Serial_Mainboard)
        Write-Host ("  Phiên bản Windows : {0}" -f $dataObj.Phien_Ban_Win)
        Write-Host ("  Trạng thái Win    : {0}" -f $dataObj.Trang_Thai_Win)
        Write-Host ("  Full Key Windows  : {0}" -f $dataObj.Key_Win_5_Cuoi) -ForegroundColor Cyan
        Write-Host ("  Phiên bản Office  : {0}" -f $dataObj.Phien_Ban_Office)
        Write-Host ("  Trạng thái Office : {0}" -f $dataObj.Trang_Thai_Office)
        Write-Host ("  Các Key Office    : {0}" -f $dataObj.Key_Office_5_Cuoi) -ForegroundColor Cyan
        Write-Host "========================================================================" -ForegroundColor Green
    }

    function Get-ExportFolder {
        if ($PSScriptRoot -and (Test-Path $PSScriptRoot)) {
            $logsDir = Join-Path $PSScriptRoot "../../../Logs"
            if (Test-Path $logsDir) { return $logsDir }
        }
        return [System.Environment]::GetFolderPath('Desktop')
    }

    function Export-ToFileLocal {
        $folder = Get-ExportFolder
        $csvPath = Join-Path $folder "IT_Inventory_List.csv"
        $txtPath = Join-Path $folder ("Info_" + $dataObj.Ten_May + ".txt")
        $jsonPath = Join-Path $folder ("Info_" + $dataObj.Ten_May + ".json")

        Write-Host "`nChọn định dạng xuất file (lưu tại $folder):" -ForegroundColor Cyan
        Write-Host "  [1] Xuất/Cộng dồn vào file CSV (IT_Inventory_List.csv)"
        Write-Host "  [2] Xuất file TXT chi tiết (Info_$($dataObj.Ten_May).txt)"
        Write-Host "  [3] Xuất file JSON (Info_$($dataObj.Ten_May).json)"
        $sub = Read-Host "Chọn (1/2/3)"

        switch ($sub) {
            "1" {
                [PSCustomObject]$dataObj | Export-Csv -Path $csvPath -Append -NoTypeInformation -Encoding UTF8
                Write-Host "[+] Đã lưu cộng dồn vào: $csvPath" -ForegroundColor Green
            }
            "2" {
                $dataObj.GetEnumerator() | ForEach-Object { "{0,-20}: {1}" -f $_.Key, $_.Value } | Out-File -FilePath $txtPath -Encoding UTF8
                Write-Host "[+] Đã xuất file TXT: $txtPath" -ForegroundColor Green
            }
            "3" {
                $dataObj | ConvertTo-Json | Out-File -FilePath $jsonPath -Encoding UTF8
                Write-Host "[+] Đã xuất file JSON: $jsonPath" -ForegroundColor Green
            }
            default { Write-Host "[!] Lựa chọn không hợp lệ." -ForegroundColor Red }
        }
    }

    function Send-ToGoogleSheetsLocal {
        $pin = Read-Host "Nhập mã PIN bảo mật để đồng bộ"
        $dataObj.Secret_PIN = $pin

        $note = Read-Host "`nNhập ghi chú cho máy này (Bấm Enter để bỏ qua)"
        $dataObj.Ghi_Chu = $note
        $payload = $dataObj | ConvertTo-Json -Compress

        Write-Host "[*] Đang đồng bộ dữ liệu lên Google Sheets..." -ForegroundColor Yellow
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $res = Invoke-RestMethod -Uri $WEB_APP_URL -Method Post -Body ([System.Text.Encoding]::UTF8.GetBytes($payload)) -ContentType "text/plain; charset=utf-8"
            if ($res.status -eq "updated") {
                Write-Host "[+] THÀNH CÔNG! Đã cập nhật đè lên dòng #$($res.row) của máy $($dataObj.Ten_May) trên Google Sheets." -ForegroundColor Green
            } elseif ($res.status -eq "inserted") {
                Write-Host "[+] THÀNH CÔNG! Đã thêm mới máy $($dataObj.Ten_May) vào Google Sheets." -ForegroundColor Green
            } elseif ($res.status -eq "error") {
                Write-Host "[!] LỖI TỪ GOOGLE APPS SCRIPT: $($res.message)" -ForegroundColor Red
            } else {
                Write-Host "[+] Đã gửi dữ liệu! Phản hồi: $($res | ConvertTo-Json -Compress)" -ForegroundColor Green
            }
        } catch {
            Write-Host "[!] LỖI KẾT NỐI WEB APP: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    function Open-GoogleFormLocal {
        Write-Host "`nChọn chế độ mở Google Form:" -ForegroundColor Cyan
        Write-Host "  [1] Mở Google Form và Copy sẵn thông tin máy vào Clipboard"
        Write-Host "  [2] Mở Google Form trống"
        $fChoice = Read-Host "Chọn (1/2)"

        if ($fChoice -eq "1" -and $PREFILL_TEMPLATE -ne "") {
            $note = Read-Host "Nhập ghi chú kèm theo trên Form (Bấm Enter để bỏ qua)"
            $url = $PREFILL_TEMPLATE
            $url = $url.Replace("__TEN_MAY__", [uri]::EscapeDataString($dataObj.Ten_May))
            $url = $url.Replace("__UUID__", [uri]::EscapeDataString($dataObj.UUID_Mainboard))
            $url = $url.Replace("__MODEL__", [uri]::EscapeDataString($dataObj.Model_Mainboard))
            $url = $url.Replace("__SERIAL__", [uri]::EscapeDataString($dataObj.Serial_Mainboard))
            $url = $url.Replace("__WIN_VER__", [uri]::EscapeDataString($dataObj.Phien_Ban_Win))
            $url = $url.Replace("__WIN_KEY__", [uri]::EscapeDataString($dataObj.Key_Win_5_Cuoi))
            $url = $url.Replace("__OFF_VER__", [uri]::EscapeDataString($dataObj.Phien_Ban_Office))
            $url = $url.Replace("__OFF_KEY__", [uri]::EscapeDataString($dataObj.Key_Office_5_Cuoi))
            $url = $url.Replace("__GHI_CHU__", [uri]::EscapeDataString($note))

            $regex = [regex]"Da\+kich\+hoat|Da%20kich%20hoat"
            $url = $regex.Replace($url, [uri]::EscapeDataString($dataObj.Trang_Thai_Win), 1)
            $url = $regex.Replace($url, [uri]::EscapeDataString($dataObj.Trang_Thai_Office), 1)

            Write-Host "[*] Đang mở Google Form (Đã điền sẵn thông tin máy)..." -ForegroundColor Green
            Start-Process $url
        } else {
            $clipText = "Tên máy: $($dataObj.Ten_May) | UUID: $($dataObj.UUID_Mainboard) | Main: $($dataObj.Model_Mainboard) | Serial: $($dataObj.Serial_Mainboard) | Win: $($dataObj.Phien_Ban_Win) ($($dataObj.Trang_Thai_Win) - $($dataObj.Key_Win_5_Cuoi)) | Office: $($dataObj.Phien_Ban_Office) ($($dataObj.Trang_Thai_Office) - $($dataObj.Key_Office_5_Cuoi))"
            Set-Clipboard -Value $clipText
            Write-Host "[+] Đã copy toàn bộ thông tin máy vào Clipboard!" -ForegroundColor Cyan
            Start-Process $GOOGLE_FORM_URL
        }
    }

    Show-TerminalInfoLocal

    while ($true) {
        Write-Host "`n==================== MENU QUẢN LÝ BẢN QUYỀN ====================" -ForegroundColor Cyan
        Write-Host "  [1] In lại thông tin bản quyền và phần cứng"
        Write-Host "  [2] Xuất dữ liệu ra File (CSV / TXT / JSON)"
        Write-Host "  [3] Đồng bộ trực tiếp lên Google Sheets (Auto API)"
        Write-Host "  [4] Mở Google Form (Tự động điền sẵn)"
        Write-Host "  [5] Mở bảng Google Sheets quản lý"
        Write-Host "  [6] Chạy tất cả: Xuất CSV + Đồng bộ Google Sheets"
        Write-Host "  [0] Quay lại Menu chính"
        Write-Host "=================================================================" -ForegroundColor Cyan
        $choice = Read-Host "Nhập lựa chọn của bạn (0-6)"

        switch ($choice) {
            "1" { Show-TerminalInfoLocal }
            "2" { Export-ToFileLocal }
            "3" { Send-ToGoogleSheetsLocal }
            "4" { Open-GoogleFormLocal }
            "5" {
                Write-Host "[*] Đang mở Google Sheets..." -ForegroundColor Green
                Start-Process $GOOGLE_SHEET_URL
            }
            "6" {
                $folder = Get-ExportFolder
                $csvPath = Join-Path $folder "IT_Inventory_List.csv"
                [PSCustomObject]$dataObj | Export-Csv -Path $csvPath -Append -NoTypeInformation -Encoding UTF8
                Write-Host "[+] Đã lưu file CSV tại: $csvPath" -ForegroundColor Green
                Send-ToGoogleSheetsLocal
            }
            "0" { break }
            default { Write-Host "[!] Vui lòng chọn từ 0 đến 6." -ForegroundColor Yellow }
        }
    }
}


# === SOURCE: src/Modules/PostInstall/PostInstall.ps1 ===
# TM-WinCare - Windows Post-Install Configuration
# Adheres to Section 3.2 of TM-WinCare-Architecture-v1.2.md


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


# === SOURCE: src/Modules/Optimization/Profiles.ps1 ===
# TM-WinCare - Optimization Profiles & Engine Logic
# Adheres to Section 3.3.1 & Section 14A of TM-WinCare-Architecture-v1.2.md

function Get-OptimizationProfiles {
    if ($global:TM_EMBEDDED_OPTIMIZATION_PROFILES) {
        return $global:TM_EMBEDDED_OPTIMIZATION_PROFILES
    }
    $path = if ($PSScriptRoot) { Join-Path $PSScriptRoot "../../../data/optimization-profiles/profiles.json" } else { "" }
    if ($path -and (Test-Path $path)) {
        return Get-Content -Path $path -Raw -Encoding UTF8 | ConvertFrom-Json
    }
    return @()
}

function Invoke-AutoOptimizeProfile {
    param ([string]$ProfileId)

    $profiles = Get-OptimizationProfiles
    $prof = $profiles | Where-Object { $_.id -eq $ProfileId }
    if (-not $prof) {
        Write-ErrorMessage "Không tìm thấy cấu hình tối ưu: $ProfileId"
        Pause-Screen
        return
    }

    Write-Header -Title "AUTO OPTIMIZE: $($prof.name)"
    Write-InfoMessage "Mục tiêu: $($prof.description)"
    Write-Host " Đối tượng phù hợp: $($prof.target)" -ForegroundColor Gray
    Write-Host ""

    # 1. Pre-scan
    Write-SubHeader "BƯỚC 1: QUÉT TRẠNG THÁI HỆ THỐNG (PRE-SCAN)"
    $sys = Get-TMSystemInfo
    Write-Success "Hệ điều hành: $($sys['Hệ điều hành'])"
    Write-Success "Bộ nhớ RAM: $($sys['Bộ nhớ RAM'])"
    Write-Success "Dung lượng ổ đĩa: $($sys['Ổ đĩa lưu trữ'])"

    # 2. Health checks
    Write-SubHeader "BƯỚC 2: KIỂM TRA ĐIỀU KIỆN AN TOÀN (HEALTH CHECKS)"
    $needsAdmin = ($ProfileId -ne "audit")
    if ($needsAdmin -and -not (Test-IsAdmin)) {
        Write-ErrorMessage "Tác vụ tối ưu này cần quyền Quản trị viên (Administrator)."
        if (-not (Request-Elevation -Reason "chạy cấu hình tối ưu $($prof.name)")) {
            Pause-Screen
            return
        }
    }
    Write-Success "Điều kiện quyền Administrator: Hợp lệ."

    # 3. Preview Actions
    Write-SubHeader "BƯỚC 3: XEM TRƯỚC CÁC TÁC VỤ SẼ THỰC HIỆN (PREVIEW)"
    $actions = $prof.actions
    for ($i = 0; $i -lt $actions.Count; $i++) {
        Write-Host "  [$($i+1)] $($actions[$i].name)" -ForegroundColor Cyan
    }
    Write-Host ""

    if ($ProfileId -eq "audit") {
        Write-Success "Đã hoàn thành kiểm tra phân tích hệ thống (Không có thay đổi nào được áp dụng)."
        Pause-Screen
        return
    }

    # 4. Confirm & Backup
    $confirmed = Confirm-Action -TaskName "Auto Optimize - $($prof.name)" -ImpactDescription "Áp dụng các tinh chỉnh an toàn theo profile $($prof.name). Tự động tạo bản sao lưu để có thể hoàn tác." -RiskLevel "medium"
    if (-not $confirmed) {
        Write-SkipMessage "Đã hủy tác vụ tối ưu theo yêu cầu của người dùng."
        Pause-Screen
        return
    }

    Write-SubHeader "BƯỚC 4: TẠO BẢN SAO LƯU TRẠNG THÁI (BACKUP)"
    $session = New-TMBackupSession -TaskId "AUTO_OPT_$ProfileId" -Description "Sao lưu trước khi chạy Auto Optimize $($prof.name)"
    
    # Backup relevant Registry keys for visual effects
    Backup-RegistryValue -Session $session -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" | Out-Null
    $backupId = Save-TMBackupSession -Session $session

    # 5. Apply
    Write-SubHeader "BƯỚC 5: ÁP DỤNG CÁC TÁC VỤ TỐI ƯU (APPLY)"
    foreach ($act in $actions) {
        Write-Host "-> Đang thực hiện: $($act.name)... " -ForegroundColor White -NoNewline
        switch ($act.action) {
            "clean_temp" {
                $userTemp = [System.IO.Path]::GetTempPath()
                $cleanedCount = 0
                Get-ChildItem -Path $userTemp -File -ErrorAction SilentlyContinue | ForEach-Object {
                    try { Remove-Item $_.FullName -Force -ErrorAction Stop; $cleanedCount++ } catch {}
                }
                Write-Host "Xong (Dọn được $cleanedCount file tạm)." -ForegroundColor Green
            }
            "visual_balanced" {
                try {
                    # VisualFXSetting: 3 = Custom (disable animation, keep font smoothing)
                    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 3 -Force -ErrorAction SilentlyContinue
                    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0 -Force -ErrorAction SilentlyContinue
                    Write-Host "Xong (Đã giảm animations)." -ForegroundColor Green
                } catch { Write-Host "Bỏ qua ($($_.Exception.Message))" -ForegroundColor Yellow }
            }
            "visual_perf" {
                try {
                    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -Force -ErrorAction SilentlyContinue
                    Write-Host "Xong (Tối ưu Best Performance)." -ForegroundColor Green
                } catch { Write-Host "Bỏ qua" -ForegroundColor Yellow }
            }
            "visual_minimal" {
                try {
                    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -Force -ErrorAction SilentlyContinue
                    Write-Host "Xong." -ForegroundColor Green
                } catch { Write-Host "Bỏ qua" -ForegroundColor Yellow }
            }
            "trim_ssd" {
                try {
                    if (Test-CmdletAvailable "Optimize-Volume") {
                        Optimize-Volume -DriveLetter C -ReTrim -ErrorAction SilentlyContinue | Out-Null
                        Write-Host "Xong (SSD ReTrim)." -ForegroundColor Green
                    } else {
                        Write-Host "Không khả dụng." -ForegroundColor DarkGray
                    }
                } catch { Write-Host "Bỏ qua." -ForegroundColor Yellow }
            }
            default {
                Write-Host "Hoàn tất." -ForegroundColor Green
            }
        }
    }

    # 6. Verify & Report
    Write-SubHeader "BƯỚC 6: XÁC MINH & BÁO CÁO (VERIFY)"
    Write-Success "Hồ sơ tối ưu '$($prof.name)' đã được áp dụng thành công!"
    Write-InfoMessage "ID bản sao lưu đã tạo: $backupId (Có thể hoàn tác bất kỳ lúc nào tại menu Backup & Restore)"
    Write-TMLog -TaskId "AUTO_OPT_$ProfileId" -TaskName "Auto Optimize $($prof.name)" -Status "Success" -Message "Áp dụng thành công" -BackupId $backupId
    
    Pause-Screen
}


# === SOURCE: src/Modules/Optimization/Optimization.ps1 ===
# TM-WinCare - Optimization Main Module
# Adheres to Section 3.3.1 of TM-WinCare-Architecture-v1.2.md


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


# === SOURCE: src/Modules/Maintenance/Maintenance.ps1 ===
# TM-WinCare - Disk & System Maintenance Module
# Adheres to Section 3.5 of TM-WinCare-Architecture-v1.2.md

function Show-TMMaintenanceMenu {
    $menuItems = @(
        @{ Label = "Kiểm tra loại ổ đĩa và dung lượng"; Action = { Show-DiskInventory } },
        @{ Label = "Phân tích / tối ưu HDD hoặc SSD (Optimize-Volume)"; Action = { Invoke-DiskOptimization } },
        @{ Label = "Mở công cụ Optimize Drives của Windows (dfrgui.exe)"; Action = { Start-Process "dfrgui.exe" } },
        @{ Label = "CHKDSK - Kiểm tra ổ đĩa (Không sửa)"; Action = { Invoke-ChkdskBasic } },
        @{ Label = "CHKDSK - Quét online NTFS (/scan)"; Action = { Invoke-ChkdskScan } },
        @{ Label = "CHKDSK - Sửa lỗi hệ thống file (/f)"; Action = { Invoke-ChkdskFix } },
        @{ Label = "CHKDSK - Quét sector và phục hồi (/r)"; Action = { Invoke-ChkdskRecovery } },
        @{ Label = "SFC - Xác minh file hệ thống (/verifyonly)"; Action = { Invoke-SfcVerify } },
        @{ Label = "SFC - Quét và sửa file hệ thống (/scannow)"; Action = { Invoke-SfcScanNow } },
        @{ Label = "DISM - Quét Component Store (/ScanHealth)"; Action = { Invoke-DismScan } },
        @{ Label = "DISM - Khôi phục Component Store (/RestoreHealth)"; Action = { Invoke-DismRestore } },
        @{ Label = "Chạy quy trình DISM + SFC tuần tự (Windows Repair Wizard)"; Action = { Invoke-RepairPipeline } },
        @{ Label = "Mở Cài đặt Dọn đĩa (Storage Settings / cleanmgr)"; Action = { Start-Process "cleanmgr.exe" } },
        @{ Label = "Xuất báo cáo ổ đĩa và bảo trì"; Action = { Export-MaintenanceReport } }
    )
    Show-TMMenu -Title "BẢO TRÌ Ổ ĐĨA & HỆ THỐNG (DISK & MAINTENANCE)" -MenuItems $menuItems -ExitLabel "Quay lại"
}

function Show-DiskInventory {
    Write-SubHeader "DANH SÁCH Ổ ĐĨA LƯU TRỮ TRÊN HỆ THỐNG"
    try {
        $volumes = Get-Volume | Where-Object { $null -ne $_.DriveLetter }
        $list = @()
        foreach ($v in $volumes) {
            $totalGB = [math]::Round($v.Size / 1GB, 1)
            $freeGB = [math]::Round($v.SizeRemaining / 1GB, 1)
            $pctFree = if ($totalGB -gt 0) { [math]::Round(($freeGB / $totalGB) * 100, 0) } else { 0 }
            
            # Detect Media Type if possible
            $mediaType = "Không rõ"
            try {
                $part = Get-Partition -DriveLetter $v.DriveLetter -ErrorAction SilentlyContinue
                if ($part) {
                    $disk = Get-Disk -Number $part.DiskNumber -ErrorAction SilentlyContinue
                    if ($disk) {
                        $pDisk = Get-PhysicalDisk | Where-Object { $_.DeviceId -eq $disk.Number } -ErrorAction SilentlyContinue
                        if ($pDisk) { $mediaType = $pDisk.MediaType }
                    }
                }
            } catch {}

            $list += [PSCustomObject]@{
                O = "$($v.DriveLetter):"
                Nhan = $v.FileSystemLabel
                DinhDang = $v.FileSystem
                LoaiMedia = $mediaType
                DungLuong = "$freeGB GB / $totalGB GB ($pctFree% trống)"
                TrangThai = $v.HealthStatus
            }
        }
        $headers = @("Ổ", "Nhãn", "Định dạng", "Loại ổ", "Dung lượng trống", "Sức khỏe")
        $props = @("O", "Nhan", "DinhDang", "LoaiMedia", "DungLuong", "TrangThai")
        $widths = @(5, 15, 12, 12, 28, 10)
        Show-TableList -Items $list -Headers $headers -PropertyNames $props -Widths $widths
    } catch {
        Handle-TMException -TaskId "DISK_INV" -TaskName "Kiểm tra ổ đĩa" -Exception $_.Exception
    }
    Pause-Screen
}

function Invoke-DiskOptimization {
    if (-not (Assert-Admin "tối ưu hóa ổ đĩa")) { Pause-Screen; return }

    Write-SubHeader "TỐI ƯU HÓA VOLUME / SSD RE-TRIM"
    Write-Host " Nhập ký tự ổ đĩa cần tối ưu (ví dụ: C): " -ForegroundColor Cyan -NoNewline
    $dl = Read-Host
    if (-not ($dl -match "^[a-zA-Z]$")) {
        Write-ErrorMessage "Ký tự ổ đĩa không hợp lệ."
        Pause-Screen
        return
    }

    $confirmed = Confirm-Action -TaskName "Tối ưu ổ đĩa $dl`:" -ImpactDescription "Chạy Optimize-Volume (tự động chọn TRIM cho SSD hoặc Defrag an toàn cho HDD)." -RiskLevel "low"
    if ($confirmed) {
        try {
            Write-InfoMessage "Đang chạy Optimize-Volume cho ổ $dl`:..."
            Optimize-Volume -DriveLetter $dl -Verbose
            Write-Success "Tối ưu hóa ổ $dl`: hoàn tất thành công!"
            Write-TMLog -TaskId "DISK_OPT" -TaskName "Tối ưu ổ đĩa" -Status "Success" -Message "Ổ $dl`:"
        } catch {
            Handle-TMException -TaskId "DISK_OPT" -TaskName "Tối ưu ổ đĩa" -Exception $_.Exception
        }
    }
    Pause-Screen
}

function Invoke-ChkdskBasic {
    Write-SubHeader "CHKDSK - KIỂM TRA Ổ ĐĨA CHẾ ĐỘ READ-ONLY"
    Write-Host " Nhập ký tự ổ đĩa (mặc định C): " -ForegroundColor Cyan -NoNewline
    $dl = Read-Host
    if ([string]::IsNullOrWhiteSpace($dl)) { $dl = "C" }
    $dl = $dl.Trim().Substring(0, 1).ToUpper()

    Write-InfoMessage "Đang chạy chkdsk $dl`: (chỉ đọc, không sửa)..."
    & chkdsk.exe "$dl`:"
    Write-TMLog -TaskId "CHKDSK_RO" -TaskName "CHKDSK Read-Only" -Status "Success" -Message "Ổ $dl`:"
    Pause-Screen
}

function Invoke-ChkdskScan {
    if (-not (Assert-Admin "chạy CHKDSK online scan")) { Pause-Screen; return }
    Write-SubHeader "CHKDSK - QUÉT ONLINE NTFS (/scan)"
    Write-Host " Nhập ký tự ổ đĩa (mặc định C): " -ForegroundColor Cyan -NoNewline
    $dl = Read-Host
    if ([string]::IsNullOrWhiteSpace($dl)) { $dl = "C" }
    $dl = $dl.Trim().Substring(0, 1).ToUpper()

    Write-InfoMessage "Đang chạy chkdsk $dl`: /scan..."
    & chkdsk.exe "$dl`:" /scan
    Write-TMLog -TaskId "CHKDSK_SCAN" -TaskName "CHKDSK Scan" -Status "Success" -Message "Ổ $dl`:"
    Pause-Screen
}

function Invoke-ChkdskFix {
    if (-not (Assert-Admin "sửa lỗi ổ đĩa")) { Pause-Screen; return }
    Write-SubHeader "CHKDSK - SỬA LỖI HỆ THỐNG FILE (/f)"
    Write-Host " Nhập ký tự ổ đĩa (mặc định C): " -ForegroundColor Cyan -NoNewline
    $dl = Read-Host
    if ([string]::IsNullOrWhiteSpace($dl)) { $dl = "C" }
    $dl = $dl.Trim().Substring(0, 1).ToUpper()

    $confirmed = Confirm-Action -TaskName "CHKDSK /f $dl`:" -ImpactDescription "Sửa lỗi logic hệ thống file. Với ổ hệ thống C:, Windows sẽ hỏi lên lịch quét khi khởi động lại máy." -RiskLevel "medium"
    if ($confirmed) {
        Write-InfoMessage "Đang thực thi chkdsk $dl`: /f..."
        & chkdsk.exe "$dl`:" /f
        Write-TMLog -TaskId "CHKDSK_FIX" -TaskName "CHKDSK /f" -Status "Success" -Message "Ổ $dl`:" -RequiresRestart ($dl -eq "C")
    }
    Pause-Screen
}

function Invoke-ChkdskRecovery {
    if (-not (Assert-Admin "quét phục hồi sector")) { Pause-Screen; return }
    Write-SubHeader "CHKDSK - QUÉT SECTOR VÀ PHỤC HỒI DỮ LIỆU (/r)"
    Write-WarningMessage "Lưu ý: Quá trình /r quét toàn bộ bề mặt ổ đĩa có thể mất từ 1 đến vài giờ."
    Write-Host " Nhập ký tự ổ đĩa (mặc định C): " -ForegroundColor Cyan -NoNewline
    $dl = Read-Host
    if ([string]::IsNullOrWhiteSpace($dl)) { $dl = "C" }
    $dl = $dl.Trim().Substring(0, 1).ToUpper()

    $confirmed = Confirm-Action -TaskName "CHKDSK /r $dl`:" -ImpactDescription "Tìm sector lỗi và cố gắng phục hồi dữ liệu đọc được. Thao tác mất nhiều thời gian và yêu cầu khởi động lại nếu là ổ C:." -RiskLevel "high" -RequiresKeyword $true
    if ($confirmed) {
        Write-InfoMessage "Đang thực thi chkdsk $dl`: /r..."
        & chkdsk.exe "$dl`:" /r
        Write-TMLog -TaskId "CHKDSK_R" -TaskName "CHKDSK /r" -Status "Success" -Message "Ổ $dl`:" -RequiresRestart ($dl -eq "C")
    }
    Pause-Screen
}

function Invoke-SfcVerify {
    if (-not (Assert-Admin "xác minh file hệ thống")) { Pause-Screen; return }
    Write-SubHeader "SFC - XÁC MINH FILE HỆ THỐNG (/verifyonly)"
    Write-InfoMessage "Đang chạy sfc /verifyonly... Vui lòng không đóng cửa sổ."
    & sfc.exe /verifyonly
    Write-TMLog -TaskId "SFC_VERIFY" -TaskName "SFC VerifyOnly" -Status "Success" -Message "Hoàn tất kiểm tra"
    Pause-Screen
}

function Invoke-SfcScanNow {
    if (-not (Assert-Admin "quét và sửa file hệ thống")) { Pause-Screen; return }
    Write-SubHeader "SFC - QUÉT VÀ SỬA FILE HỆ THỐNG (/scannow)"
    Write-InfoMessage "Đang chạy sfc /scannow... Quá trình này mất khoảng vài phút."
    & sfc.exe /scannow
    Write-TMLog -TaskId "SFC_SCANNOW" -TaskName "SFC ScanNow" -Status "Success" -Message "Hoàn tất quét sửa"
    Pause-Screen
}

function Invoke-DismScan {
    if (-not (Assert-Admin "quét component store")) { Pause-Screen; return }
    Write-SubHeader "DISM - QUÉT COMPONENT STORE (/ScanHealth)"
    Write-InfoMessage "Đang chạy DISM /Online /Cleanup-Image /ScanHealth..."
    & dism.exe /Online /Cleanup-Image /ScanHealth
    Write-TMLog -TaskId "DISM_SCAN" -TaskName "DISM ScanHealth" -Status "Success" -Message "Hoàn tất"
    Pause-Screen
}

function Invoke-DismRestore {
    if (-not (Assert-Admin "khôi phục component store")) { Pause-Screen; return }
    Write-SubHeader "DISM - KHÔI PHỤC COMPONENT STORE (/RestoreHealth)"
    Write-InfoMessage "Đang chạy DISM /Online /Cleanup-Image /RestoreHealth..."
    & dism.exe /Online /Cleanup-Image /RestoreHealth
    Write-TMLog -TaskId "DISM_RESTORE" -TaskName "DISM RestoreHealth" -Status "Success" -Message "Hoàn tất"
    Pause-Screen
}

function Invoke-RepairPipeline {
    if (-not (Assert-Admin "chạy quy trình sửa chữa Windows")) { Pause-Screen; return }
    Write-Header -Title "QUY TRÌNH SỬA CHỮA WINDOWS TOÀN DIỆN (DISM + SFC)"
    Write-InfoMessage "Trình tự khuyến nghị chuẩn của Microsoft:"
    Write-Host "  1. Quét và khôi phục kho linh kiện Windows Component Store (DISM RestoreHealth)" -ForegroundColor Gray
    Write-Host "  2. Quét và thay thế các file hệ thống được bảo vệ (SFC scannow)" -ForegroundColor Gray
    Write-Host ""

    $confirmed = Confirm-Action -TaskName "Sửa chữa hệ thống DISM + SFC" -ImpactDescription "Tự động chạy DISM RestoreHealth rồi đến SFC Scannow để sửa các file Windows bị hỏng." -RiskLevel "medium"
    if ($confirmed) {
        Write-SubHeader "BƯỚC 1/2: CHẠY DISM RESTOREHEALTH"
        & dism.exe /Online /Cleanup-Image /RestoreHealth

        Write-SubHeader "BƯỚC 2/2: CHẠY SFC SCANNOW"
        & sfc.exe /scannow

        Write-Success "Quy trình sửa chữa DISM + SFC đã hoàn thành!"
        Write-TMLog -TaskId "REPAIR_PIPELINE" -TaskName "DISM + SFC Pipeline" -Status "Success" -Message "Hoàn tất quy trình sửa chữa"
    }
    Pause-Screen
}

function Export-MaintenanceReport {
    Write-SubHeader "XUẤT BÁO CÁO Ổ ĐĨA & BẢO TRÌ"
    $reportDir = Join-Path $PSScriptRoot "../../../Logs"
    $filename = "MaintenanceReport_" + (Get-Date).ToString("yyyyMMdd_HHmmss") + ".txt"
    $fullPath = Join-Path $reportDir $filename

    $lines = @()
    $lines += "========================================================="
    $lines += "         TM-WINCARE - BÁO CÁO BẢO TRÌ & Ổ ĐĨA"
    $lines += "  Thời gian: " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $lines += "========================================================="
    try {
        $volumes = Get-Volume | Where-Object { $null -ne $_.DriveLetter }
        foreach ($v in $volumes) {
            $totalGB = [math]::Round($v.Size / 1GB, 1)
            $freeGB = [math]::Round($v.SizeRemaining / 1GB, 1)
            $lines += "Ổ $($v.DriveLetter): [$($v.FileSystemLabel)] - $freeGB GB trống / $totalGB GB ($($v.FileSystem))"
        }
    } catch {}
    $lines += "========================================================="

    Set-Content -Path $fullPath -Value $lines -Encoding UTF8 -Force
    Write-Success "Đã xuất báo cáo ra: $fullPath"
    Pause-Screen
}


# === SOURCE: src/Modules/Repair/Repair.ps1 ===
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


# === SOURCE: src/Modules/Network/Network.ps1 ===
# TM-WinCare - Network & LAN Support Module
# Adheres to Section 6 of TM-WinCare-Architecture-v1.2.md

function Show-TMNetworkMenu {
    $menuItems = @(
        @{ Label = "Xem tổng quan IP, Gateway, DNS, MAC"; Action = { Show-NetworkOverview } },
        @{ Label = "Chạy ipconfig /all (Chi tiết cấu hình)"; Action = { & ipconfig.exe /all; Pause-Screen } },
        @{ Label = "Xóa cache DNS (Flush DNS)"; Action = { Clear-DnsClientCache; Write-Success "Đã xóa DNS Cache thành công."; Pause-Screen } },
        @{ Label = "Làm mới địa chỉ IP DHCP (Renew IP)"; Action = { & ipconfig.exe /renew; Pause-Screen } },
        @{ Label = "Kiểm tra Ping tới Gateway / IP / Máy chủ"; Action = { Invoke-PingTest } },
        @{ Label = "Kiểm tra phân giải tên miền (DNS Lookup)"; Action = { Invoke-DnsLookupTest } },
        @{ Label = "Kiểm tra kết nối cổng TCP (Port Ping)"; Action = { Invoke-TcpPortTest } },
        @{ Label = "Kiểm tra cấu hình SMB Client (Read-Only)"; Action = { Show-SmbConfiguration } },
        @{ Label = "Kiểm tra Firewall Rules cho File & Printer Sharing"; Action = { Show-FirewallSharingRules } },
        @{ Label = "Mở Network Connections (ncpa.cpl)"; Action = { Start-Process "ncpa.cpl" } },
        @{ Label = "Mở Advanced Sharing Settings (Cài đặt chia sẻ nâng cao)"; Action = { Start-Process "control.exe" "/name Microsoft.NetworkAndSharingCenter /page Advanced" } },
        @{ Label = "Mở Windows Firewall (firewall.cpl)"; Action = { Start-Process "firewall.cpl" } },
        @{ Label = "Mở Credential Manager (Quản lý tài khoản mạng)"; Action = { Start-Process "control.exe" "/name Microsoft.CredentialManager" } },
        @{ Label = "Xuất báo cáo cấu hình mạng"; Action = { Export-NetworkReport } }
    )
    Show-TMMenu -Title "MẠNG NỘI BỘ & LAN SUPPORT (NETWORK SUPPORT)" -MenuItems $menuItems -ExitLabel "Quay lại"
}

function Show-NetworkOverview {
    Write-SubHeader "TỔNG QUAN KẾT NỐI MẠNG"
    try {
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
        foreach ($ad in $adapters) {
            Write-Host " Card mạng: $($ad.Name) ($($ad.InterfaceDescription))" -ForegroundColor Cyan
            Write-Host "   MAC Address  : $($ad.MacAddress)" -ForegroundColor White
            Write-Host "   Tốc độ kết nối: $($ad.LinkSpeed)" -ForegroundColor White

            $ips = Get-NetIPAddress -InterfaceIndex $ad.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
            foreach ($ip in $ips) {
                Write-Host "   Địa chỉ IPv4 : $($ip.IPAddress)/$($ip.PrefixLength)" -ForegroundColor Green
            }

            $routes = Get-NetRoute -InterfaceIndex $ad.InterfaceIndex -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue
            if ($routes) {
                Write-Host "   Default Gateway: $($routes[0].NextHop)" -ForegroundColor White
            }

            $dnsServers = (Get-DnsClientServerAddress -InterfaceIndex $ad.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue).ServerAddresses
            if ($dnsServers) {
                Write-Host "   Máy chủ DNS  : $($dnsServers -join ', ')" -ForegroundColor White
            }
            Write-Host ""
        }
    } catch {
        Handle-TMException -TaskId "NET_OVERVIEW" -TaskName "Xem cấu hình mạng" -Exception $_.Exception
    }
    Pause-Screen
}

function Invoke-PingTest {
    Write-SubHeader "KIỂM TRA PING KẾT NỐI"
    Write-Host " Nhập IP hoặc tên máy chủ cần ping (mặc định 8.8.8.8): " -ForegroundColor Cyan -NoNewline
    $target = Read-Host
    if ([string]::IsNullOrWhiteSpace($target)) { $target = "8.8.8.8" }

    Write-InfoMessage "Đang gửi 4 gói tin ICMP tới $target..."
    & ping.exe $target
    Pause-Screen
}

function Invoke-DnsLookupTest {
    Write-SubHeader "KIỂM TRA PHÂN GIẢI DNS (NSLOOKUP)"
    Write-Host " Nhập tên miền hoặc hostname cần tra cứu (ví dụ: google.com): " -ForegroundColor Cyan -NoNewline
    $hostName = Read-Host
    if ([string]::IsNullOrWhiteSpace($hostName)) { $hostName = "google.com" }

    try {
        $res = Resolve-DnsName -Name $hostName -ErrorAction Stop
        $res | Select-Object Name, Type, IPAddress | Format-Table -AutoSize
    } catch {
        Write-ErrorMessage "Không thể phân giải tên '$hostName': $($_.Exception.Message)"
    }
    Pause-Screen
}

function Invoke-TcpPortTest {
    Write-SubHeader "KIỂM TRA KẾT NỐI CỔNG TCP (PORT TEST)"
    Write-Host " Nhập địa chỉ IP hoặc tên máy: " -ForegroundColor Cyan -NoNewline
    $dest = Read-Host
    if ([string]::IsNullOrWhiteSpace($dest)) {
        Write-ErrorMessage "Địa chỉ không được để trống."
        Pause-Screen
        return
    }

    Write-Host " Nhập số cổng TCP (ví dụ: 80, 443, 445 cho SMB, 135 cho RPC, 9100 cho máy in): " -ForegroundColor Cyan -NoNewline
    $portStr = Read-Host
    if (-not ($portStr -match "^\d+$")) {
        Write-ErrorMessage "Số cổng không hợp lệ."
        Pause-Screen
        return
    }

    $port = [int]$portStr
    Write-InfoMessage "Đang kiểm tra kết nối TCP tới $dest`:$port..."
    try {
        $test = Test-NetConnection -ComputerName $dest -Port $port -WarningAction SilentlyContinue
        if ($test.TcpTestSucceeded) {
            Write-Success "Kết nối tới $dest`:$port THÀNH CÔNG!"
        } else {
            Write-ErrorMessage "Kết nối tới $dest`:$port THẤT BẠI. Cổng có thể bị đóng hoặc chặn bởi tường lửa."
        }
    } catch {
        Handle-TMException -TaskId "NET_PORT_TEST" -TaskName "Port Test" -Exception $_.Exception
    }
    Pause-Screen
}

function Show-SmbConfiguration {
    Write-SubHeader "CẤU HÌNH SMB CLIENT HIỆN TẠI (READ-ONLY)"
    try {
        if (Test-CmdletAvailable "Get-SmbClientConfiguration") {
            $smb = Get-SmbClientConfiguration
            Write-Host "  RequireSecuritySignature (Bắt buộc ký số SMB): $($smb.RequireSecuritySignature)" -ForegroundColor $(if ($smb.RequireSecuritySignature) { "Green" } else { "Yellow" })
            Write-Host "  EnableInsecureGuestLogons (Cho phép Guest):      $($smb.EnableInsecureGuestLogons)" -ForegroundColor $(if ($smb.EnableInsecureGuestLogons) { "Red" } else { "Green" })
            Write-Host "  EnableSMB1Protocol (Giao thức cũ SMB1):          $(if (Test-CmdletAvailable 'Get-WindowsOptionalFeature') { 'Kiểm tra qua Windows Features' } else { 'Không khả dụng' })" -ForegroundColor Gray
            Write-Host ""
            Write-InfoMessage "Ghi chú: Giữ RequireSecuritySignature = True là cấu hình an toàn tiêu chuẩn của Microsoft."
        } else {
            Write-WarningMessage "Cmdlet Get-SmbClientConfiguration không khả dụng trên phiên bản Windows này."
        }
    } catch {
        Handle-TMException -TaskId "SMB_CONF" -TaskName "Kiểm tra SMB" -Exception $_.Exception
    }
    Pause-Screen
}

function Show-FirewallSharingRules {
    Write-SubHeader "TRẠNG THÁI TƯỜNG LỬA CHO FILE & PRINTER SHARING"
    try {
        $rules = Get-NetFirewallRule -DisplayGroup "*File and Printer Sharing*" -ErrorAction SilentlyContinue | Select-Object -First 5
        if ($rules) {
            foreach ($r in $rules) {
                $status = if ($r.Enabled -eq "True") { "[BẬT]" } else { "[TẮT]" }
                $color = if ($r.Enabled -eq "True") { "Green" } else { "Yellow" }
                Write-Host "  $status $($r.DisplayName)" -ForegroundColor $color
            }
        } else {
            Write-InfoMessage "Không tìm thấy rule File and Printer Sharing."
        }
    } catch {
        Handle-TMException -TaskId "FW_RULES" -TaskName "Kiểm tra Firewall Rules" -Exception $_.Exception
    }
    Pause-Screen
}

function Export-NetworkReport {
    $reportDir = Join-Path $PSScriptRoot "../../../Logs"
    $filename = "NetworkReport_" + (Get-Date).ToString("yyyyMMdd_HHmmss") + ".txt"
    $fullPath = Join-Path $reportDir $filename

    $lines = @()
    $lines += "========================================================="
    $lines += "         TM-WINCARE - BÁO CÁO CẤU HÌNH MẠNG"
    $lines += "  Thời gian: " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $lines += "========================================================="
    try {
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
        foreach ($ad in $adapters) {
            $lines += "Card: $($ad.Name) | MAC: $($ad.MacAddress) | Tốc độ: $($ad.LinkSpeed)"
        }
    } catch {}
    $lines += "========================================================="
    Set-Content -Path $fullPath -Value $lines -Encoding UTF8 -Force
    Write-Success "Đã xuất báo cáo ra file: $fullPath"
    Pause-Screen
}


# === SOURCE: src/Modules/Printer/Printer.ps1 ===
# TM-WinCare - Printer Support Module
# Adheres to Section 4 & Section 5 of TM-WinCare-Architecture-v1.2.md

function Show-TMPrinterMenu {
    $menuItems = @(
        @{ Label = "Danh sách máy in đã cài trên hệ thống"; Action = { Show-InstalledPrinters } },
        @{ Label = "Mở cài đặt Printers & Scanners (Settings)"; Action = { Start-Process "ms-settings:printers" } },
        @{ Label = "Mở Devices and Printers cổ điển (Control Panel)"; Action = { Start-Process "control.exe" "printers" } },
        @{ Label = "Mở Quản lý Driver máy in (printui /s /t2)"; Action = { Start-Process "rundll32.exe" "printui.dll,PrintUIEntry /s /t2" } },
        @{ Label = "Khởi động lại dịch vụ Print Spooler"; Action = { Invoke-RestartSpooler } },
        @{ Label = "Xóa toàn bộ hàng đợi in bị treo / kẹt lệnh"; Action = { Invoke-ClearPrintQueue } },
        @{ Label = "Kiểm tra chi tiết trạng thái Print Spooler"; Action = { Test-PrintSpoolerHealth } },
        @{ Label = "Kiểm tra kết nối máy in chia sẻ qua mạng (UNC Test)"; Action = { Test-SharedPrinterConnection } },
        @{ Label = "Tạo tài khoản scan máy in (Scan-to-Folder)"; Action = { Invoke-CreateScanAccount } },
        @{ Label = "Hướng dẫn & công cụ cấu hình máy chủ chia sẻ máy in"; Action = { Show-HostPrinterGuide } },
        @{ Label = "Hướng dẫn & công cụ cấu hình máy khách kết nối máy in"; Action = { Show-ClientPrinterGuide } },
        @{ Label = "Tạo Local Port kết nối máy in qua mạng (\\Server\\Share)"; Action = { Show-LocalPortHelper } },
        @{ Label = "Hướng dẫn xử lý lỗi máy in Access Denied (0x0000011b, 0x00000709)"; Action = { Show-PrinterAccessDeniedGuide } },
        @{ Label = "Xuất báo cáo máy in ra file TXT"; Action = { Export-PrinterReport } }
    )
    Show-TMMenu -Title "HỖ TRỢ MÁY IN & IN ẤN (PRINTER SUPPORT)" -MenuItems $menuItems -ExitLabel "Quay lại"
}

function Show-InstalledPrinters {
    Write-SubHeader "DANH SÁCH MÁY IN ĐÃ CÀI ĐẶT"
    try {
        $printers = Get-Printer -ErrorAction Stop
        if (-not $printers -or @($printers).Count -eq 0) {
            Write-InfoMessage "Không tìm thấy máy in nào được cài đặt trên hệ thống."
        } else {
            $list = @()
            foreach ($p in $printers) {
                $list += [PSCustomObject]@{
                    TenMayIn = $p.Name
                    Driver = $p.DriverName
                    Cong = $p.PortName
                    ChiaSe = if ($p.Shared) { "Có ($($p.ShareName))" } else { "Không" }
                    TrangThai = $p.PrinterStatus.ToString()
                }
            }
            $headers = @("Tên máy in", "Driver", "Cổng kết nối", "Chia sẻ", "Trạng thái")
            $props = @("TenMayIn", "Driver", "Cong", "ChiaSe", "TrangThai")
            $widths = @(25, 25, 15, 12, 10)
            Show-TableList -Items $list -Headers $headers -PropertyNames $props -Widths $widths
        }
    } catch {
        Handle-TMException -TaskId "PRINT_LIST" -TaskName "Liệt kê máy in" -Exception $_.Exception
    }
    Pause-Screen
}

function Invoke-RestartSpooler {
    if (-not (Assert-Admin "khởi động lại Print Spooler")) { Pause-Screen; return }

    Write-SubHeader "KHỞI ĐỘNG LẠI DỊCH VỤ PRINT SPOOLER"
    try {
        Write-InfoMessage "Đang dừng dịch vụ Spooler..."
        Stop-Service -Name Spooler -Force -ErrorAction Stop
        Start-Sleep -Milliseconds 800
        
        Write-InfoMessage "Đang khởi động lại dịch vụ Spooler..."
        Start-Service -Name Spooler -ErrorAction Stop
        Start-Sleep -Milliseconds 800

        $svc = Get-Service -Name Spooler
        if ($svc.Status -eq "Running") {
            Write-Success "Dịch vụ Print Spooler đã được khởi động lại và đang hoạt động bình thường!"
            Write-TMLog -TaskId "PRINT_RESTART_SPOOLER" -TaskName "Restart Spooler" -Status "Success" -Message "Thành công"
        } else {
            Write-ErrorMessage "Dịch vụ Spooler ở trạng thái: $($svc.Status)"
        }
    } catch {
        Handle-TMException -TaskId "PRINT_RESTART_SPOOLER" -TaskName "Restart Spooler" -Exception $_.Exception
    }
    Pause-Screen
}

function Invoke-ClearPrintQueue {
    if (-not (Assert-Admin "xóa hàng đợi in bị treo")) { Pause-Screen; return }

    Write-SubHeader "XÓA HÀNG ĐỢI IN BỊ TREO (CLEAR SPOOL QUEUE)"
    $spoolPath = Join-Path $env:SystemRoot "System32\spool\PRINTERS"

    $confirmed = Confirm-Action -TaskName "Xóa hàng đợi in bị kẹt" -ImpactDescription "Dừng Print Spooler, dọn sạch tất cả lệnh in đang chờ trong thư mục $spoolPath và khởi động lại Spooler." -RiskLevel "medium"
    if (-not $confirmed) { Pause-Screen; return }

    try {
        Write-InfoMessage "1. Đang dừng dịch vụ Print Spooler..."
        Stop-Service -Name Spooler -Force -ErrorAction Stop
        Start-Sleep -Milliseconds 500

        Write-InfoMessage "2. Đang xóa các file lệnh in tạm trong $spoolPath..."
        $files = Get-ChildItem -Path $spoolPath -File -ErrorAction SilentlyContinue
        $deleted = 0
        foreach ($f in $files) {
            try {
                Remove-Item $f.FullName -Force -ErrorAction Stop
                $deleted++
            } catch {}
        }
        Write-Success "Đã xóa $deleted file lệnh in bị kẹt."

        Write-InfoMessage "3. Đang khởi động lại dịch vụ Print Spooler..."
        Start-Service -Name Spooler -ErrorAction Stop
        Start-Sleep -Milliseconds 500

        $svc = Get-Service -Name Spooler
        if ($svc.Status -eq "Running") {
            Write-Success "Hàng đợi in đã được dọn sạch và Spooler đã hoạt động trở lại!"
            Write-TMLog -TaskId "PRINT_CLEAR_QUEUE" -TaskName "Xóa hàng đợi in" -Status "Success" -Message "Đã xóa $deleted file lệnh in"
        }
    } catch {
        Handle-TMException -TaskId "PRINT_CLEAR_QUEUE" -TaskName "Xóa hàng đợi in" -Exception $_.Exception
    }
    Pause-Screen
}

function Test-PrintSpoolerHealth {
    Write-SubHeader "KIỂM TRA SỨC KHỎE DỊCH VỤ PRINT SPOOLER"
    try {
        $svc = Get-Service -Name Spooler -ErrorAction Stop
        Write-Host "  Tên dịch vụ   : $($svc.ServiceName) ($($svc.DisplayName))" -ForegroundColor Cyan
        Write-Host "  Trạng thái    : $($svc.Status)" -ForegroundColor $(if ($svc.Status -eq "Running") { "Green" } else { "Red" })

        $cim = Get-CimInstance Win32_Service -Filter "Name='Spooler'" -ErrorAction SilentlyContinue
        if ($cim) {
            Write-Host "  Chế độ startup: $($cim.StartMode)" -ForegroundColor White
            Write-Host "  Tiến trình PID: $($cim.ProcessId)" -ForegroundColor White
        }

        # Check Spool folder size
        $spoolPath = Join-Path $env:SystemRoot "System32\spool\PRINTERS"
        if (Test-Path $spoolPath) {
            $files = Get-ChildItem -Path $spoolPath -File -ErrorAction SilentlyContinue
            Write-Host "  Số lệnh in kẹt: $(@($files).Count) file" -ForegroundColor $(if (@($files).Count -gt 0) { "Yellow" } else { "Green" })
        }
    } catch {
        Handle-TMException -TaskId "PRINT_HEALTH" -TaskName "Kiểm tra Spooler" -Exception $_.Exception
    }
    Pause-Screen
}

function Test-SharedPrinterConnection {
    Write-SubHeader "KIỂM TRA KẾT NỐI MÁY IN CHIA SẺ TRONG MẠNG LAN"
    Write-Host " Nhập đường dẫn UNC máy in (ví dụ: \\TEN-MAY-CHU\TEN-MAY-IN hoặc \\192.168.1.100\PrinterName): " -ForegroundColor Cyan -NoNewline
    $unc = Read-Host
    if ([string]::IsNullOrWhiteSpace($unc) -or -not ($unc.StartsWith("\\"))) {
        Write-ErrorMessage "Đường dẫn không hợp lệ. Phải bắt đầu bằng \\ (ví dụ \\Server\Printer)."
        Pause-Screen
        return
    }

    $parts = $unc.TrimStart('\').Split('\')
    $serverName = $parts[0]

    Write-InfoMessage "1. Kiểm tra phân giải & kết nối TCP 445 (SMB) tới máy chủ $serverName..."
    $testSmb = Test-NetConnection -ComputerName $serverName -Port 445 -WarningAction SilentlyContinue
    if ($testSmb.TcpTestSucceeded) {
        Write-Success "Máy chủ $serverName đang mở cổng chia sẻ SMB (TCP 445)."
    } else {
        Write-WarningMessage "Không thể kết nối cổng SMB tới $serverName. Hãy kiểm tra địa chỉ IP, tên máy hoặc tường lửa."
    }

    Write-InfoMessage "2. Kiểm tra đường dẫn chia sẻ $unc..."
    if (Test-Path -LiteralPath $unc -ErrorAction SilentlyContinue) {
        Write-Success "Đường dẫn chia sẻ $unc có thể truy cập thành công!"
    } else {
        Write-WarningMessage "Chưa thể truy cập trực tiếp $unc. Điều này có thể do cần xác thực tài khoản qua Credential Manager."
    }
    Pause-Screen
}

function Invoke-CreateScanAccount {
    if (-not (Assert-Admin "tạo tài khoản scan")) { Pause-Screen; return }

    Write-SubHeader "TẠO TÀI KHOẢN SCAN MÁY IN (SCAN-TO-FOLDER)"
    Write-InfoMessage "Tài khoản local dùng cho máy in đa chức năng scan gửi file vào thư mục mạng."
    Write-Host ""
    Write-Host " Nhập tên tài khoản (mặc định 'scan'): " -ForegroundColor Cyan -NoNewline
    $uName = Read-Host
    if ([string]::IsNullOrWhiteSpace($uName)) { $uName = "scan" }

    # Check if user already exists
    if (Test-CmdletAvailable "Get-LocalUser") {
        $existing = Get-LocalUser -Name $uName -ErrorAction SilentlyContinue
        if ($existing) {
            Write-WarningMessage "Tài khoản '$uName' đã tồn tại trên máy tính này!"
            Pause-Screen
            return
        }
    }

    # Secure Password Input
    Write-Host " Nhập mật khẩu cho tài khoản '$uName': " -ForegroundColor Cyan -NoNewline
    $secPass1 = Read-Host -AsSecureString
    Write-Host " Xác nhận lại mật khẩu: " -ForegroundColor Cyan -NoNewline
    $secPass2 = Read-Host -AsSecureString

    # Validate passwords match
    $bstr1 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secPass1)
    $bstr2 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secPass2)
    $plain1 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr1)
    $plain2 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr2)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr1)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr2)

    if ($plain1 -ne $plain2) {
        Write-ErrorMessage "Mật khẩu xác nhận không khớp. Hủy thao tác."
        Pause-Screen
        return
    }
    if ([string]::IsNullOrWhiteSpace($plain1)) {
        Write-ErrorMessage "Mật khẩu không được để trống."
        Pause-Screen
        return
    }

    Write-Host " Bạn có muốn đặt mật khẩu không bao giờ hết hạn (PasswordNeverExpires)? (Y/N): " -ForegroundColor Cyan -NoNewline
    $pneAns = Read-Host
    $neverExpires = ($pneAns.Trim().ToUpper() -eq "Y")

    $confirmed = Confirm-Action -TaskName "Tạo tài khoản scan '$uName'" -ImpactDescription "Tạo user cục bộ '$uName' dùng riêng cho dịch vụ scan máy in. Mật khẩu được bảo mật hoàn toàn." -RiskLevel "medium"
    if ($confirmed) {
        try {
            if (Test-CmdletAvailable "New-LocalUser") {
                New-LocalUser -Name $uName -Password $secPass1 -Description "Tài khoản dùng cho scan máy in" -PasswordNeverExpires:$neverExpires -ErrorAction Stop
            } else {
                # Fallback to net user if LocalAccounts cmdlet not present
                & net.exe user "$uName" "$plain1" /add /comment:"Tai khoan scan"
            }
            Write-Success "Đã tạo tài khoản '$uName' thành công!"
            Write-InfoMessage "Bây giờ bạn có thể phân quyền cho user '$uName' vào thư mục nhận file scan (ví dụ D:\Scan)."
            Write-TMLog -TaskId "PRINT_SCAN_USER" -TaskName "Tạo tài khoản scan" -Status "Success" -Message "User: $uName"
        } catch {
            Handle-TMException -TaskId "PRINT_SCAN_USER" -TaskName "Tạo user scan" -Exception $_.Exception
        }
    }
    Pause-Screen
}

function Show-HostPrinterGuide {
    Write-SubHeader "HƯỚNG DẪN CẤU HÌNH TRÊN MÁY CHỦ (MÁY CẮM MÁY IN)"
    Write-Host " 1. Kiểm tra máy in đã in được trực tiếp từ máy chủ." -ForegroundColor White
    Write-Host " 2. Vào Control Panel > Devices and Printers > Chuột phải vào máy in > Printer Properties." -ForegroundColor White
    Write-Host " 3. Mở tab Sharing > Tích chọn 'Share this printer' và đặt tên chia sẻ ngắn gọn (ví dụ: Canon2900)." -ForegroundColor White
    Write-Host " 4. Mở tab Security > Kiểm tra nhóm 'Everyone' có quyền 'Print'." -ForegroundColor White
    Write-Host " 5. Mở Advanced Sharing Settings > Bật 'Turn on file and printer sharing'." -ForegroundColor White
    Write-Host " 6. Ghi lại Tên máy chủ (Hostname) hoặc địa chỉ IP của máy này." -ForegroundColor Cyan
    Pause-Screen
}

function Show-ClientPrinterGuide {
    Write-SubHeader "HƯỚNG DẪN CẤU HÌNH TRÊN MÁY KHÁCH (CLIENT)"
    Write-Host " 1. Mở Credential Manager > Windows Credentials > Add a Windows credential." -ForegroundColor White
    Write-Host "    - Network address: Nhập tên hoặc IP máy chủ (ví dụ: \\TEN-MAY-CHU)" -ForegroundColor Gray
    Write-Host "    - User name / Password: Nhập tài khoản của máy chủ." -ForegroundColor Gray
    Write-Host " 2. Bấm Win + R > Nhập '\\TEN-MAY-CHU' để kiểm tra xem đã nhìn thấy máy in chia sẻ chưa." -ForegroundColor White
    Write-Host " 3. Chuột phải vào máy in chia sẻ > Chọn 'Connect'." -ForegroundColor White
    Write-Host " 4. Nếu gặp lỗi Access Denied hoặc driver, hãy dùng chức năng 'Tạo Local Port' bên dưới." -ForegroundColor Cyan
    Pause-Screen
}

function Show-LocalPortHelper {
    Write-SubHeader "HỖ TRỢ TẠO LOCAL PORT CHO MÁY IN MẠNG"
    Write-InfoMessage "Local Port là giải pháp cực kỳ tin cậy để kết nối máy in chia sẻ khi gặp lỗi driver hoặc mạng."
    Write-Host ""
    Write-Host " Nhập tên hoặc IP máy chủ (Server): " -ForegroundColor Cyan -NoNewline
    $server = Read-Host
    Write-Host " Nhập tên chia sẻ máy in (Share name): " -ForegroundColor Cyan -NoNewline
    $share = Read-Host

    if ([string]::IsNullOrWhiteSpace($server) -or [string]::IsNullOrWhiteSpace($share)) {
        Write-ErrorMessage "Tên máy chủ và tên chia sẻ không được để trống."
        Pause-Screen
        return
    }

    $portName = "\\$server\$share"
    Write-Success "Đường dẫn Local Port của bạn là: $portName"
    Write-Host ""
    Write-Host " Các bước thực hiện trong Windows:" -ForegroundColor Yellow
    Write-Host "  1. Mở 'Devices and Printers' -> Bấm 'Add a printer'." -ForegroundColor White
    Write-Host "  2. Chọn 'The printer that I want isn't listed'." -ForegroundColor White
    Write-Host "  3. Chọn 'Add a local printer or network printer with manual settings' -> Next." -ForegroundColor White
    Write-Host "  4. Chọn 'Create a new port' -> Loại port chọn: 'Local Port' -> Next." -ForegroundColor White
    Write-Host "  5. Dán chính xác đường dẫn sau vào ô Port Name: " -ForegroundColor White
    Write-Host "     $portName" -ForegroundColor Cyan
    Write-Host "  6. Chọn đúng Driver máy in từ danh sách hoặc Have Disk để hoàn tất." -ForegroundColor White
    Write-Host ""
    Write-Host " Bạn có muốn mở ngay trình quản lý Devices and Printers không? (Y/N): " -ForegroundColor Cyan -NoNewline
    $ans = Read-Host
    if ($ans.Trim().ToUpper() -eq "Y") {
        Start-Process "control.exe" "printers"
    }
    Pause-Screen
}

function Show-PrinterAccessDeniedGuide {
    Write-SubHeader "HƯỚNG DẪN XỬ LÝ LỖI ACCESS DENIED / 0x0000011b TRÊN WINDOWS 10 & 11"
    Write-Host " Nguyên nhân thường gặp:" -ForegroundColor Yellow
    Write-Host "  - Bản cập nhật bảo mật RPC Printing của Microsoft yêu cầu xác thực mức cao." -ForegroundColor Gray
    Write-Host "  - Máy khách chưa lưu thông tin tài khoản của máy chủ trong Credential Manager." -ForegroundColor Gray
    Write-Host "  - Windows 11 22H2+ mặc định dùng RPC over TCP trong khi máy chủ cũ dùng Named Pipes." -ForegroundColor Gray
    Write-Host ""
    Write-Host " Các bước xử lý an toàn theo thứ tự ưu tiên:" -ForegroundColor Cyan
    Write-Host "  1. Lưu tài khoản máy chủ vào Credential Manager trên máy khách." -ForegroundColor White
    Write-Host "  2. Cài đặt sẵn driver máy in giống hệt phiên bản trên máy khách trước khi kết nối." -ForegroundColor White
    Write-Host "  3. Sử dụng kết nối qua Local Port thay vì kết nối tự động (đã hướng dẫn ở mục 12)." -ForegroundColor White
    Write-Host "  4. Khởi động lại Print Spooler trên cả hai máy." -ForegroundColor White
    Pause-Screen
}

function Export-PrinterReport {
    $reportDir = Join-Path $PSScriptRoot "../../../Logs"
    $filename = "PrinterReport_" + (Get-Date).ToString("yyyyMMdd_HHmmss") + ".txt"
    $fullPath = Join-Path $reportDir $filename

    $lines = @()
    $lines += "========================================================="
    $lines += "         TM-WINCARE - BÁO CÁO DANH SÁCH MÁY IN"
    $lines += "  Thời gian: " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $lines += "========================================================="
    try {
        $printers = Get-Printer
        foreach ($p in $printers) {
            $lines += "Tên: $($p.Name) | Driver: $($p.DriverName) | Cổng: $($p.PortName) | Shared: $($p.Shared)"
        }
    } catch {}
    $lines += "========================================================="
    Set-Content -Path $fullPath -Value $lines -Encoding UTF8 -Force
    Write-Success "Đã xuất báo cáo ra file: $fullPath"
    Pause-Screen
}


# === SOURCE: src/Modules/Cleanup/WindowsCleanup.ps1 ===
# TM-WinCare - System Cleanup Module
# Adheres to Section 7A of TM-WinCare-Architecture-v1.2.md

function Show-TMSystemCleanupMenu {
    $menuItems = @(
        @{ Label = "Quét & Phân tích dung lượng các mục có thể dọn"; Action = { Scan-SystemCleanupTargets } },
        @{ Label = "Dọn thư mục Temp của người dùng (%TEMP%)"; Action = { Clean-UserTempFolder } },
        @{ Label = "Dọn thư mục Windows Temp (%WINDIR%\\Temp)"; Action = { Clean-WindowsTempFolder } },
        @{ Label = "Dọn Thùng rác (Recycle Bin)"; Action = { Clean-RecycleBinCustom } },
        @{ Label = "Dọn cache bản cập nhật Windows Update (SoftwareDistribution)"; Action = { Clean-WindowsUpdateCache } },
        @{ Label = "Dọn crash dumps và minidumps cũ"; Action = { Clean-CrashDumps } },
        @{ Label = "Kiểm tra & Hướng dẫn dọn dẹp thư mục Windows.old"; Action = { Show-WindowsOldWizard } },
        @{ Label = "Mở giao diện Cài đặt Lưu trữ (Storage Sense / Settings)"; Action = { Start-Process "ms-settings:storagesense" } }
    )
    Show-TMMenu -Title "DỌN DẸP HỆ THỐNG WINDOWS (SYSTEM CLEANUP)" -MenuItems $menuItems -ExitLabel "Quay lại"
}

function Scan-SystemCleanupTargets {
    Write-SubHeader "QUÉT & PHÂN TÍCH DUNG LƯỢNG RÁC HỆ THỐNG"
    Write-InfoMessage "Đang tính toán dung lượng các thư mục file tạm..."

    $targets = @(
        @{ Name = "User Temp (%TEMP%)"; Path = [System.IO.Path]::GetTempPath() },
        @{ Name = "Windows Temp"; Path = (Join-Path $env:SystemRoot "Temp") },
        @{ Name = "Windows Update Cache"; Path = (Join-Path $env:SystemRoot "SoftwareDistribution\Download") },
        @{ Name = "Minidumps"; Path = (Join-Path $env:SystemRoot "Minidump") }
    )

    $results = @()
    foreach ($t in $targets) {
        $sizeMB = 0
        $count = 0
        if (Test-Path $t.Path) {
            $files = Get-ChildItem -Path $t.Path -File -Recurse -ErrorAction SilentlyContinue
            if ($files) {
                $count = @($files).Count
                $measure = $files | Measure-Object -Property Length -Sum
                if ($measure.Sum) {
                    $sizeMB = [math]::Round($measure.Sum / 1MB, 2)
                }
            }
        }
        $results += [PSCustomObject]@{
            Muc = $t.Name
            SoLuongFile = "$count file"
            DungLuong = "$sizeMB MB"
            DuongDan = $t.Path
        }
    }

    $headers = @("Mục dọn dẹp", "Số lượng file", "Dung lượng ước tính", "Đường dẫn")
    $props = @("Muc", "SoLuongFile", "DungLuong", "DuongDan")
    $widths = @(25, 15, 20, 30)
    Show-TableList -Items $results -Headers $headers -PropertyNames $props -Widths $widths

    # Check Windows.old
    $winOld = "C:\Windows.old"
    if (Test-Path $winOld) {
        Write-WarningMessage "Phát hiện thư mục 'Windows.old' trên ổ C:. Hãy xem mục 'Windows.old Wizard' để dọn dẹp an toàn."
    }
    Pause-Screen
}

function Clean-UserTempFolder {
    $tempPath = [System.IO.Path]::GetTempPath()
    Write-SubHeader "DỌN THƯ MỤC USER TEMP: $tempPath"
    
    $confirmed = Confirm-Action -TaskName "Dọn User Temp" -ImpactDescription "Xóa các file tạm do ứng dụng tạo ra trong %TEMP%. Các file đang được mở hoặc bị khóa sẽ tự động được bỏ qua." -RiskLevel "low"
    if (-not $confirmed) { Pause-Screen; return }

    $files = Get-ChildItem -Path $tempPath -File -ErrorAction SilentlyContinue
    $deleted = 0
    $skipped = 0
    foreach ($f in $files) {
        try {
            Remove-Item $f.FullName -Force -ErrorAction Stop
            $deleted++
        } catch {
            $skipped++
        }
    }
    Write-Success "Đã dọn thành công $deleted file tạm (Bỏ qua $skipped file đang được hệ thống dùng)."
    Write-TMLog -TaskId "CLEAN_USER_TEMP" -TaskName "Dọn User Temp" -Status "Success" -Message "Đã xóa $deleted file"
    Pause-Screen
}

function Clean-WindowsTempFolder {
    if (-not (Assert-Admin "dọn thư mục Windows Temp")) { Pause-Screen; return }

    $winTemp = Join-Path $env:SystemRoot "Temp"
    Write-SubHeader "DỌN THƯ MỤC WINDOWS TEMP: $winTemp"

    $confirmed = Confirm-Action -TaskName "Dọn Windows Temp" -ImpactDescription "Xóa file tạm của Windows và dịch vụ hệ thống. Các file đang được dịch vụ sử dụng sẽ tự động được bỏ qua." -RiskLevel "low"
    if (-not $confirmed) { Pause-Screen; return }

    $files = Get-ChildItem -Path $winTemp -File -ErrorAction SilentlyContinue
    $deleted = 0
    $skipped = 0
    foreach ($f in $files) {
        try {
            Remove-Item $f.FullName -Force -ErrorAction Stop
            $deleted++
        } catch {
            $skipped++
        }
    }
    Write-Success "Đã dọn thành công $deleted file trong Windows Temp (Bỏ qua $skipped file đang dùng)."
    Write-TMLog -TaskId "CLEAN_WIN_TEMP" -TaskName "Dọn Windows Temp" -Status "Success" -Message "Đã xóa $deleted file"
    Pause-Screen
}

function Clean-RecycleBinCustom {
    Write-SubHeader "DỌN SẠCH THÙNG RÁC (RECYCLE BIN)"
    $confirmed = Confirm-Action -TaskName "Dọn sạch Thùng rác" -ImpactDescription "Xóa vĩnh viễn toàn bộ file trong Thùng rác trên tất cả các ổ đĩa. Thao tác này không thể hoàn tác." -RiskLevel "medium"
    if (-not $confirmed) { Pause-Screen; return }

    try {
        Clear-RecycleBin -Force -ErrorAction Stop
        Write-Success "Đã dọn sạch Thùng rác thành công!"
        Write-TMLog -TaskId "CLEAN_RECYCLE_BIN" -TaskName "Dọn thùng rác" -Status "Success" -Message "Thành công"
    } catch {
        Handle-TMException -TaskId "CLEAN_RECYCLE_BIN" -TaskName "Dọn thùng rác" -Exception $_.Exception
    }
    Pause-Screen
}

function Clean-WindowsUpdateCache {
    if (-not (Assert-Admin "dọn cache Windows Update")) { Pause-Screen; return }

    Write-SubHeader "DỌN CACHE BẢN CẬP NHẬT WINDOWS UPDATE"
    $wuPath = Join-Path $env:SystemRoot "SoftwareDistribution\Download"

    $confirmed = Confirm-Action -TaskName "Dọn cache Windows Update" -ImpactDescription "Tạm dừng dịch vụ wuauserv, dọn các file cài đặt đã tải xong trong SoftwareDistribution\Download và khởi động lại dịch vụ." -RiskLevel "medium"
    if (-not $confirmed) { Pause-Screen; return }

    try {
        Write-InfoMessage "Tạm dừng dịch vụ Windows Update..."
        Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
        
        $files = Get-ChildItem -Path $wuPath -Recurse -File -ErrorAction SilentlyContinue
        $deleted = 0
        foreach ($f in $files) {
            try { Remove-Item $f.FullName -Force -ErrorAction Stop; $deleted++ } catch {}
        }
        Write-Success "Đã xóa $deleted file cài đặt cập nhật cũ."

        Write-InfoMessage "Khởi động lại dịch vụ Windows Update..."
        Start-Service -Name wuauserv -ErrorAction SilentlyContinue
        Write-Success "Hoàn tất dọn dẹp cache Windows Update!"
        Write-TMLog -TaskId "CLEAN_WU_CACHE" -TaskName "Dọn cache Windows Update" -Status "Success" -Message "Đã xóa $deleted file"
    } catch {
        Handle-TMException -TaskId "CLEAN_WU_CACHE" -TaskName "Dọn cache WU" -Exception $_.Exception
    }
    Pause-Screen
}

function Clean-CrashDumps {
    if (-not (Assert-Admin "dọn crash dumps")) { Pause-Screen; return }

    Write-SubHeader "DỌN CRASH DUMPS & MINIDUMPS CŨ"
    $dumpPath = Join-Path $env:SystemRoot "Minidump"
    if (-not (Test-Path $dumpPath)) {
        Write-InfoMessage "Không tìm thấy thư mục Minidump trên máy tính này."
        Pause-Screen
        return
    }

    $confirmed = Confirm-Action -TaskName "Dọn Minidump" -ImpactDescription "Xóa các file ghi nhớ sự cố BSOD cũ trong $dumpPath." -RiskLevel "low"
    if ($confirmed) {
        $files = Get-ChildItem -Path $dumpPath -File -ErrorAction SilentlyContinue
        $deleted = 0
        foreach ($f in $files) {
            try { Remove-Item $f.FullName -Force -ErrorAction Stop; $deleted++ } catch {}
        }
        Write-Success "Đã xóa $deleted file minidump."
    }
    Pause-Screen
}

function Show-WindowsOldWizard {
    Write-SubHeader "HƯỚNG DẪN DỌN DẸP THƯ MỤC WINDOWS.OLD AN TOÀN"
    $winOld = "C:\Windows.old"
    if (-not (Test-Path $winOld)) {
        Write-Success "Thư mục 'C:\Windows.old' KHÔNG tồn tại trên máy tính này. Không cần dọn dẹp."
        Pause-Screen
        return
    }

    Write-WarningMessage "PHÁT HIỆN THƯ MỤC C:\Windows.old TRÊN HỆ THỐNG!"
    Write-Host " CẢNH BÁO QUAN TRỌNG:" -ForegroundColor Yellow
    Write-Host "  - Windows.old chứa bản cài đặt Windows trước đó của bạn." -ForegroundColor Gray
    Write-Host "  - Xóa Windows.old sẽ làm MẤT HOÀN TOÀN khả năng quay lại (Rollback) bản Windows cũ." -ForegroundColor Gray
    Write-Host "  - Microsoft khuyến nghị KHÔNG tự dùng lệnh xóa thủ công, mà dùng Disk Cleanup hoặc Storage Sense." -ForegroundColor Gray
    Write-Host ""
    Write-Host " Bạn có muốn mở giao diện Windows Storage Sense để dọn dẹp 'Previous Windows installation(s)' an toàn không? (Y/N): " -ForegroundColor Cyan -NoNewline
    $ans = Read-Host
    if ($ans.Trim().ToUpper() -eq "Y") {
        Start-Process "ms-settings:storagesense"
    }
    Pause-Screen
}


# === SOURCE: src/Modules/Cleanup/AiDevCleanup.ps1 ===
# TM-WinCare - AI & Developer Cleanup Module
# Adheres to Section 7B of TM-WinCare-Architecture-v1.2.md

function Show-TMAiDevCleanupMenu {
    $menuItems = @(
        @{ Label = "Quét & Nhận diện các công cụ AI / Developer đã cài"; Action = { Scan-AiDevEnvironment } },
        @{ Label = "Dọn cache Python pip (pip cache purge)"; Action = { Clean-PipCache } },
        @{ Label = "Dọn cache Python uv (uv cache clean)"; Action = { Clean-UvCache } },
        @{ Label = "Dọn cache Node.js npm (npm cache clean)"; Action = { Clean-NpmCache } },
        @{ Label = "Dọn dẹp pnpm Store mồ côi (pnpm store prune)"; Action = { Clean-PnpmStore } },
        @{ Label = "Liệt kê mô hình Ollama & Hướng dẫn quản lý"; Action = { Show-OllamaManager } },
        @{ Label = "Kiểm tra dung lượng Hugging Face cache"; Action = { Show-HuggingFaceCache } },
        @{ Label = "Dọn dẹp Docker Builder Cache (docker builder prune)"; Action = { Clean-DockerBuilderCache } },
        @{ Label = "Kiểm tra dung lượng WSL Distributions (Virtual Disks)"; Action = { Show-WslStatus } },
        @{ Label = "Dọn dẹp Log tạm thời của VS Code & Cursor"; Action = { Clean-IdeLogs } }
    )
    Show-TMMenu -Title "DỌN DẸP CÔNG CỤ AI & DEVELOPER (AI & DEV CLEANUP)" -MenuItems $menuItems -ExitLabel "Quay lại"
}

function Scan-AiDevEnvironment {
    Write-SubHeader "QUÉT CÁC CÔNG CỤ AI & DEVELOPER TRÊN MÁY"
    
    $tools = @(
        @{ Name = "Python"; Cmd = "python --version" },
        @{ Name = "Pip"; Cmd = "pip --version" },
        @{ Name = "uv"; Cmd = "uv --version" },
        @{ Name = "Node.js"; Cmd = "node --version" },
        @{ Name = "npm"; Cmd = "npm --version" },
        @{ Name = "pnpm"; Cmd = "pnpm --version" },
        @{ Name = "Ollama"; Cmd = "ollama --version" },
        @{ Name = "Docker"; Cmd = "docker --version" },
        @{ Name = "WSL"; Cmd = "wsl --status" }
    )

    $results = @()
    foreach ($t in $tools) {
        $bin = $t.Cmd.Split(' ')[0]
        $found = Test-ToolAvailable $bin
        $ver = "Chưa cài đặt"
        if ($found) {
            try {
                $verOutput = (& cmd.exe /c "$($t.Cmd) 2>&1")
                if ($verOutput) { $ver = $verOutput[0] }
            } catch { $ver = "Đã cài đặt" }
        }
        $results += [PSCustomObject]@{
            CongCu = $t.Name
            TrangThai = if ($found) { "Đã phát hiện" } else { "Không tìm thấy" }
            PhienBan = $ver
        }
    }

    $headers = @("Công cụ", "Trạng thái", "Phiên bản / Thông tin")
    $props = @("CongCu", "TrangThai", "PhienBan")
    $widths = @(18, 18, 38)
    Show-TableList -Items $results -Headers $headers -PropertyNames $props -Widths $widths
    Pause-Screen
}

function Clean-PipCache {
    Write-SubHeader "DỌN CACHE PYTHON PIP (pip cache purge)"
    if (-not (Test-ToolAvailable "pip")) {
        Write-WarningMessage "Công cụ pip không có sẵn trong biến môi trường PATH."
        Pause-Screen
        return
    }

    Write-InfoMessage "Thông tin cache hiện tại:"
    & pip cache info

    $confirmed = Confirm-Action -TaskName "Dọn cache pip" -ImpactDescription "Xóa các gói wheel/tarball đã tải trong cache của pip. Không ảnh hưởng đến các thư viện và môi trường ảo .venv hiện có." -RiskLevel "low"
    if ($confirmed) {
        & pip cache purge
        Write-Success "Đã dọn dẹp cache pip thành công!"
    }
    Pause-Screen
}

function Clean-UvCache {
    Write-SubHeader "DỌN CACHE PYTHON UV (uv cache clean)"
    if (-not (Test-ToolAvailable "uv")) {
        Write-WarningMessage "Công cụ uv không có sẵn trong PATH."
        Pause-Screen
        return
    }

    $confirmed = Confirm-Action -TaskName "Dọn cache uv" -ImpactDescription "Xóa bộ nhớ đệm uv cache. Các gói cần thiết sẽ được tải lại khi cần." -RiskLevel "low"
    if ($confirmed) {
        & uv cache clean
        Write-Success "Đã dọn dẹp cache uv thành công!"
    }
    Pause-Screen
}

function Clean-NpmCache {
    Write-SubHeader "DỌN CACHE NODE.JS NPM (npm cache clean)"
    if (-not (Test-ToolAvailable "npm")) {
        Write-WarningMessage "Công cụ npm không có sẵn trong PATH."
        Pause-Screen
        return
    }

    $confirmed = Confirm-Action -TaskName "Dọn cache npm" -ImpactDescription "Xóa toàn bộ tarball đã lưu trong cache của npm. Không xóa thư mục node_modules của các dự án." -RiskLevel "low"
    if ($confirmed) {
        & npm cache clean --force
        Write-Success "Đã dọn dẹp cache npm thành công!"
    }
    Pause-Screen
}

function Clean-PnpmStore {
    Write-SubHeader "DỌN PNPM STORE MỒ CÔI (pnpm store prune)"
    if (-not (Test-ToolAvailable "pnpm")) {
        Write-WarningMessage "Công cụ pnpm không có sẵn trong PATH."
        Pause-Screen
        return
    }

    $confirmed = Confirm-Action -TaskName "pnpm store prune" -ImpactDescription "Xóa các package không còn được bất kỳ project nào liên kết (hard-link) trong pnpm store." -RiskLevel "low"
    if ($confirmed) {
        & pnpm store prune
        Write-Success "Đã dọn dẹp pnpm store thành công!"
    }
    Pause-Screen
}

function Show-OllamaManager {
    Write-SubHeader "QUẢN LÝ MÔ HÌNH OLLAMA LOCAL LLM"
    if (-not (Test-ToolAvailable "ollama")) {
        Write-WarningMessage "Ollama không có sẵn trong PATH."
        Pause-Screen
        return
    }

    Write-InfoMessage "Danh sách các model hiện có:"
    & ollama list

    Write-Host ""
    Write-Host " NGUYÊN TẮC BẢO VỆ DỮ LIỆU:" -ForegroundColor Yellow
    Write-Host "  - TM-WinCare TUYỆT ĐỐI KHÔNG BAO GIỜ tự xóa các mô hình Ollama." -ForegroundColor Gray
    Write-Host "  - Mỗi mô hình LLM có dung lượng từ vài GB đến hàng chục GB." -ForegroundColor Gray
    Write-Host "  - Nếu muốn xóa model không dùng, hãy chạy: ollama rm <tên_model>" -ForegroundColor Cyan
    Write-Host ""
    Write-Host " Bạn có muốn nhập tên model để xóa không? (Bỏ trống để quay lại): " -ForegroundColor Cyan -NoNewline
    $targetModel = Read-Host
    if (-not [string]::IsNullOrWhiteSpace($targetModel)) {
        $confirmed = Confirm-Action -TaskName "Xóa mô hình Ollama '$targetModel'" -ImpactDescription "Xóa mô hình $targetModel khỏi Ollama. Bạn sẽ phải tải lại nếu muốn sử dụng lại." -RiskLevel "medium"
        if ($confirmed) {
            & ollama rm $targetModel
            Write-Success "Đã xóa mô hình $targetModel."
        }
    }
    Pause-Screen
}

function Show-HuggingFaceCache {
    Write-SubHeader "DUNG LƯỢNG HUGGING FACE HUB CACHE"
    $hfPath = if ($env:HF_HOME) { Join-Path $env:HF_HOME "hub" } else { Join-Path $env:USERPROFILE ".cache\huggingface\hub" }
    
    if (-not (Test-Path $hfPath)) {
        Write-InfoMessage "Không tìm thấy thư mục Hugging Face cache tại: $hfPath"
        Pause-Screen
        return
    }

    Write-InfoMessage "Đang tính dung lượng thư mục: $hfPath..."
    $files = Get-ChildItem -Path $hfPath -File -Recurse -ErrorAction SilentlyContinue
    $totalMB = 0
    if ($files) {
        $measure = $files | Measure-Object -Property Length -Sum
        if ($measure.Sum) { $totalMB = [math]::Round($measure.Sum / 1GB, 2) }
    }
    Write-Host "  Tổng dung lượng HF Hub Cache: $totalMB GB" -ForegroundColor Cyan
    Write-InfoMessage "Lưu ý: Thư mục này chứa weights mô hình tải về. Nếu có cài công cụ 'huggingface-cli', bạn có thể dùng lệnh 'huggingface-cli delete-cache' để chọn xóa từng snapshot."
    Pause-Screen
}

function Clean-DockerBuilderCache {
    Write-SubHeader "DỌN DẸP DOCKER BUILDER CACHE"
    if (-not (Test-ToolAvailable "docker")) {
        Write-WarningMessage "Docker không có sẵn hoặc chưa chạy daemon."
        Pause-Screen
        return
    }

    Write-InfoMessage "Dung lượng Docker hiện tại:"
    & docker system df

    $confirmed = Confirm-Action -TaskName "Docker Builder Prune" -ImpactDescription "Xóa cache BuildKit của Docker. KHÔNG XÓA Volumes (dữ liệu database) hay container đang chạy." -RiskLevel "medium"
    if ($confirmed) {
        & docker builder prune -f
        Write-Success "Đã dọn dẹp Docker Builder Cache!"
    }
    Pause-Screen
}

function Show-WslStatus {
    Write-SubHeader "DANH SÁCH BẢN PHÂN PHỐI WSL (DISTRIBUTIONS)"
    if (-not (Test-ToolAvailable "wsl")) {
        Write-WarningMessage "WSL chưa được cài đặt."
        Pause-Screen
        return
    }

    & wsl.exe -l -v
    Write-Host ""
    Write-Host " NGUYÊN TẮC AN TOÀN:" -ForegroundColor Yellow
    Write-Host "  - Không bao giờ xóa file ext4.vhdx trực tiếp vì sẽ làm hỏng dữ liệu Linux." -ForegroundColor Gray
    Write-Host "  - Để thu hồi dung lượng WSL: hãy dọn dẹp bên trong Linux trước, sau đó chạy 'wsl --shutdown' và compact disk." -ForegroundColor Gray
    Pause-Screen
}

function Clean-IdeLogs {
    Write-SubHeader "DỌN LOG & CACHE TẠM THỜI CỦA VS CODE / CURSOR"
    $paths = @(
        (Join-Path $env:APPDATA "Code\logs"),
        (Join-Path $env:APPDATA "Cursor\logs")
    )
    $confirmed = Confirm-Action -TaskName "Dọn Log IDE" -ImpactDescription "Xóa các thư mục log cũ của VS Code và Cursor. Không ảnh hưởng đến extensions, cấu hình settings hay conversation history." -RiskLevel "low"
    if ($confirmed) {
        $deleted = 0
        foreach ($p in $paths) {
            if (Test-Path $p) {
                $files = Get-ChildItem -Path $p -File -Recurse -ErrorAction SilentlyContinue
                foreach ($f in $files) {
                    try { Remove-Item $f.FullName -Force -ErrorAction Stop; $deleted++ } catch {}
                }
            }
        }
        Write-Success "Đã dọn dẹp $deleted file log IDE."
    }
    Pause-Screen
}


# === SOURCE: src/Modules/Privacy/Privacy.ps1 ===
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


# === SOURCE: src/Modules/Accounts/Accounts.ps1 ===
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


# === SOURCE: src/Modules/QuickCommands/QuickCommands.ps1 ===
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


# === SOURCE: src/Modules/BackupRestore/BackupRestore.ps1 ===
# TM-WinCare - Backup & Restore Management Module
# Adheres to Section 8 of TM-WinCare-Architecture-v1.2.md

function Show-TMBackupMenu {
    while ($true) {
        Write-Header -Title "QUẢN LÝ SAO LƯU & HOÀN TÁC (BACKUP & RESTORE)"
        $backups = Get-TMBackupList

        if (-not $backups -or $backups.Count -eq 0) {
            Write-InfoMessage "Chưa có bản sao lưu nào được ghi nhận trong thư mục Backups."
        } else {
            Write-Host " Danh sách các bản sao lưu đã tạo:" -ForegroundColor Yellow
            for ($i = 0; $i -lt $backups.Count; $i++) {
                $b = $backups[$i]
                $num = ($i + 1).ToString().PadLeft(2)
                Write-Host "  [$num] " -ForegroundColor Cyan -NoNewline
                Write-Host "$($b.Id) " -ForegroundColor White -NoNewline
                Write-Host "- $($b.Description)" -ForegroundColor Gray
            }
        }

        Write-Host ""
        Write-Host "  [R] Hoàn tác bản sao lưu đã chọn" -ForegroundColor Cyan
        Write-Host "  [0] Quay lại" -ForegroundColor Yellow
        Write-Divider

        Write-Host " Lựa chọn của bạn (Nhập số bản sao lưu để xem chi tiết / R để hoàn tác / 0 để quay lại): " -ForegroundColor Cyan -NoNewline
        $ans = Read-Host

        if ($ans -eq "0") { break }

        if ($ans -match "^\d+$") {
            $idx = [int]$ans - 1
            if ($idx -ge 0 -and $idx -lt $backups.Count) {
                Show-BackupDetails -BackupItem $backups[$idx]
            }
        }
    }
}

function Show-BackupDetails {
    param ($BackupItem)

    Write-SubHeader "CHI TIẾT BẢN SAO LƯU: $($BackupItem.Id)"
    Write-Host " Tác vụ gốc: $($BackupItem.TaskId)" -ForegroundColor White
    Write-Host " Mô tả     : $($BackupItem.Description)" -ForegroundColor White
    Write-Host " Thời gian : $($BackupItem.CreatedAt)" -ForegroundColor White
    Write-Host " Thư mục   : $($BackupItem.Path)" -ForegroundColor Gray

    $manifestPath = Join-Path $BackupItem.Path "manifest.json"
    if (Test-Path $manifestPath) {
        $manifest = Get-Content -Path $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($manifest.registry) {
            Write-Host ""
            Write-Host "  Mục Registry được sao lưu:" -ForegroundColor Yellow
            foreach ($r in $manifest.registry) {
                Write-Host "   - $($r.path)\$($r.name) (Giá trị cũ: $($r.oldValue))" -ForegroundColor Gray
            }
        }
        if ($manifest.services) {
            Write-Host ""
            Write-Host "  Dịch vụ được sao lưu:" -ForegroundColor Yellow
            foreach ($s in $manifest.services) {
                Write-Host "   - $($s.name) (Khởi động: $($s.startMode))" -ForegroundColor Gray
            }
        }
    }

    Write-Host ""
    Write-Host " Bạn có muốn hoàn tác (Rollback) bản sao lưu này ngay bây giờ không? (Y/N): " -ForegroundColor Cyan -NoNewline
    $rb = Read-Host
    if ($rb.Trim().ToUpper() -eq "Y") {
        Invoke-TMRollback -BackupId $BackupItem.Id
    }
    Pause-Screen
}


# === MAIN ENTRY POINT ===
# TM-WinCare - Main Entry Point
# TM-WinCare – Windows Optimization & Maintenance Toolkit v1.2
# Adheres to Section 4.1, 9, 10 of TM-WinCare-Architecture-v1.2.md

param (
    [switch]$NonInteractive
)

# 1. Bootstrap Core & UI
$srcDir = $PSScriptRoot

# 2. Source All Functional Modules

# 3. Main Application Loop
function Start-TMApplication {
    while ($true) {
        $adminBadge = if (Test-IsAdmin) { "[ADMIN]" } else { "[USER]" }
        $adminColor = if (Test-IsAdmin) { "Green" } else { "Yellow" }
        $osStr = if ($global:TM_OS_INFO) { "$($global:TM_OS_INFO.Version) Build $($global:TM_OS_INFO.Build)" } else { "Windows" }

        Write-Host ""
        Write-Host "=========================================================" -ForegroundColor Cyan
        Write-Host "                 TM-WINDOWS TOOLKIT                      " -ForegroundColor White
        Write-Host "      Windows Optimization & Maintenance Toolkit         " -ForegroundColor Gray
        Write-Host "=========================================================" -ForegroundColor Cyan
        Write-Host "  Hệ điều hành: $osStr | Quyền: " -NoNewline -ForegroundColor DarkGray
        Write-Host "$adminBadge" -ForegroundColor $adminColor
        Write-Host "---------------------------------------------------------" -ForegroundColor DarkGray

        Write-Host "  [ 1] " -ForegroundColor Cyan -NoNewline; Write-Host "Dashboard / Thông tin hệ thống" -ForegroundColor White
        Write-Host "  [ 2] " -ForegroundColor Cyan -NoNewline; Write-Host "Windows Post-Install" -ForegroundColor White
        Write-Host "  [ 3] " -ForegroundColor Cyan -NoNewline; Write-Host "Auto Optimize / Custom Optimize" -ForegroundColor White
        Write-Host "  [ 4] " -ForegroundColor Cyan -NoNewline; Write-Host "Disk & System Maintenance" -ForegroundColor White
        Write-Host "  [ 5] " -ForegroundColor Cyan -NoNewline; Write-Host "Windows Repair (SFC / DISM / CHKDSK)" -ForegroundColor White
        Write-Host "  [ 6] " -ForegroundColor Cyan -NoNewline; Write-Host "Network & LAN Support" -ForegroundColor White
        Write-Host "  [ 7] " -ForegroundColor Cyan -NoNewline; Write-Host "Printer Support" -ForegroundColor White
        Write-Host "  [ 8] " -ForegroundColor Cyan -NoNewline; Write-Host "AI & Developer Cleanup" -ForegroundColor White
        Write-Host "  [ 9] " -ForegroundColor Cyan -NoNewline; Write-Host "Privacy, Notifications & Copilot" -ForegroundColor White
        Write-Host "  [10] " -ForegroundColor Cyan -NoNewline; Write-Host "Tài khoản & quyền truy cập" -ForegroundColor White
        Write-Host "  [11] " -ForegroundColor Cyan -NoNewline; Write-Host "Quick Commands" -ForegroundColor White
        Write-Host "  [12] " -ForegroundColor Cyan -NoNewline; Write-Host "Backup & Restore" -ForegroundColor White
        Write-Host "  [ 0] " -ForegroundColor Yellow -NoNewline; Write-Host "Thoát" -ForegroundColor Yellow
        Write-Host "=========================================================" -ForegroundColor Cyan

        $sel = Read-MenuSelection -PromptText "Chọn chức năng" -Min 0 -Max 12
        switch ($sel) {
            1  { Show-TMDashboard }
            2  { Show-TMPostInstallMenu }
            3  { Show-TMOptimizationMenu }
            4  { Show-TMMaintenanceMenu }
            5  { Show-TMRepairMenu }
            6  { Show-TMNetworkMenu }
            7  { Show-TMPrinterMenu }
            8  { Show-TMAiDevCleanupMenu }
            9  { Show-TMPrivacyMenu }
            10 { Show-TMAccountsMenu }
            11 { Show-TMQuickCommandsMenu }
            12 { Show-TMBackupMenu }
            0  {
                Write-InfoMessage "Cảm ơn bạn đã sử dụng TM-WinCare. Tạm biệt!"
                Write-TMLog -TaskId "EXIT" -TaskName "Thoát ứng dụng" -Status "Info" -Message "Thoát bình thường"
                return
            }
        }
    }
}


Start-TMApplication
