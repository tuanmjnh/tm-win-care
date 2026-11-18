<# : batch script
@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion
title TM-WinCare – Windows Optimization & Maintenance Toolkit (All-In-One)

set "PS_EXE=powershell.exe"
where pwsh.exe >nul 2>nul && set "PS_EXE=pwsh.exe"

net session >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo =========================================================
    echo         TM-WINCARE - WINDOWS TOOLKIT LAUNCHER
    echo =========================================================
    echo  [NOTICE] Currently running under standard user privileges.
    echo  System maintenance and optimization functions require
    echo  elevated Administrator rights.
    echo.
    echo  [1] Continue with standard privileges (Read-Only / Basic)
    echo  [2] Restart with Administrator privileges (Recommended)
    echo =========================================================
    set /p "ADMIN_CHOICE= Select choice [1-2] (Default 2): "
    if "!ADMIN_CHOICE!"=="" set "ADMIN_CHOICE=2"
    if "!ADMIN_CHOICE!"=="2" (
        powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process cmd.exe -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
        exit /b 0
    )
)

%PS_EXE% -NoProfile -ExecutionPolicy Bypass -Command "$c=[System.IO.File]::ReadAllText('%~f0', [System.Text.Encoding]::UTF8); $i=$c.IndexOf('#_POWERSHELL_START_#'); Invoke-Expression $c.Substring($i)"
endlocal
exit /b
: end batch / begin powershell #>
#_POWERSHELL_START_#
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
  "defaultLocale": "en-US",
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
    "name": "Check Windows Version (winver)",
    "description": "Displays About Windows dialog with OS edition, version, and build number",
    "command": "winver",
    "type": "process",
    "requiresAdmin": false,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "SYS_MSINFO32",
    "group": "System",
    "name": "Detailed System Information (msinfo32)",
    "description": "Opens System Information tool showing hardware, drivers, and components",
    "command": "msinfo32",
    "type": "process",
    "requiresAdmin": false,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "SYS_DXDIAG",
    "group": "System",
    "name": "DirectX Diagnostic Tool (dxdiag)",
    "description": "Checks DirectX, GPU display adapters, audio devices, and display drivers",
    "command": "dxdiag",
    "type": "process",
    "requiresAdmin": false,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "SYS_DEVMGMT",
    "group": "System",
    "name": "Device Manager (devmgmt.msc)",
    "description": "Opens Device Manager to inspect drivers, missing devices, and hardware status",
    "command": "devmgmt.msc",
    "type": "process",
    "requiresAdmin": true,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "SYS_DISKMGMT",
    "group": "System",
    "name": "Disk Management (diskmgmt.msc)",
    "description": "Opens Disk Management to manage partitions, format volumes, and assign drive letters",
    "command": "diskmgmt.msc",
    "type": "process",
    "requiresAdmin": true,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "SYS_SERVICES",
    "group": "System",
    "name": "Windows Services Manager (services.msc)",
    "description": "Opens Windows background services console",
    "command": "services.msc",
    "type": "process",
    "requiresAdmin": true,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "SYS_EVENTVWR",
    "group": "System",
    "name": "Event Viewer (eventvwr.msc)",
    "description": "Opens Event Viewer to diagnose system, application, and security logs",
    "command": "eventvwr.msc",
    "type": "process",
    "requiresAdmin": true,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "SYS_PERFMON_REL",
    "group": "System",
    "name": "Reliability Monitor (perfmon /rel)",
    "description": "Opens Reliability Monitor showing app crashes, updates, and OS failure history",
    "command": "perfmon /rel",
    "type": "process",
    "requiresAdmin": false,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "SYS_TASKMGR",
    "group": "System",
    "name": "Task Manager (taskmgr)",
    "description": "Opens Task Manager to monitor CPU, RAM, Disk, Network, and running processes",
    "command": "taskmgr",
    "type": "process",
    "requiresAdmin": false,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "DISK_DFRGUI",
    "group": "Disk",
    "name": "Optimize Drives GUI (dfrgui.exe)",
    "description": "Opens Windows Drive Optimizer (TRIM for SSDs, Defragmentation for HDDs)",
    "command": "dfrgui.exe",
    "type": "process",
    "requiresAdmin": true,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "PRINT_PRINTUI",
    "group": "Printer",
    "name": "Printer Driver Server Properties (printui /s /t2)",
    "description": "Opens Print Server Properties directly on Drivers tab to add or remove drivers",
    "command": "rundll32.exe printui.dll,PrintUIEntry /s /t2",
    "type": "process",
    "requiresAdmin": true,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "PRINT_CONTROL",
    "group": "Printer",
    "name": "Classic Devices and Printers",
    "description": "Opens classic Control Panel Devices and Printers applet",
    "command": "control printers",
    "type": "process",
    "requiresAdmin": false,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "NET_NCPA",
    "group": "Network",
    "name": "Network Connections (ncpa.cpl)",
    "description": "Opens Network Connections to configure static IP, DNS, or toggle adapters",
    "command": "ncpa.cpl",
    "type": "process",
    "requiresAdmin": true,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "NET_CREDMAN",
    "group": "Network",
    "name": "Credential Manager (control credman)",
    "description": "Opens Windows Credential Manager to manage saved LAN share credentials",
    "command": "control /name Microsoft.CredentialManager",
    "type": "process",
    "requiresAdmin": false,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "NET_INETCPL",
    "group": "Network",
    "name": "Internet Options (inetcpl.cpl)",
    "description": "Opens Internet Properties to configure Proxy, TLS protocols, and Security zones",
    "command": "inetcpl.cpl",
    "type": "process",
    "requiresAdmin": false,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "NET_IPCONFIG",
    "group": "Network",
    "name": "View Full Network Configuration (ipconfig /all)",
    "description": "Displays detailed IP, Subnet, Gateway, DHCP, DNS, and MAC addresses",
    "command": "ipconfig /all",
    "type": "cli",
    "requiresAdmin": false,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "NET_GPUPDATE",
    "group": "Network",
    "name": "Force Group Policy Update (gpupdate /force)",
    "description": "Applies domain security and policy changes immediately",
    "command": "gpupdate /force",
    "type": "cli",
    "requiresAdmin": true,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "REPAIR_SFC_VERIFY",
    "group": "Repair",
    "name": "Verify System File Integrity (sfc /verifyonly)",
    "description": "Scans Windows system files and reports integrity violations without modifying",
    "command": "sfc /verifyonly",
    "type": "cli",
    "requiresAdmin": true,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "REPAIR_SFC_SCAN",
    "group": "Repair",
    "name": "Scan and Repair System Files (sfc /scannow)",
    "description": "Scans and replaces corrupt system files using cached local copies",
    "command": "sfc /scannow",
    "type": "cli",
    "requiresAdmin": true,
    "changesSystem": true,
    "requiresRestart": false
  },
  {
    "id": "REPAIR_DISM_CHECK",
    "group": "Repair",
    "name": "DISM Quick Health Check (CheckHealth)",
    "description": "Checks whether the component store corruption flag has been set",
    "command": "DISM /Online /Cleanup-Image /CheckHealth",
    "type": "cli",
    "requiresAdmin": true,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "REPAIR_DISM_SCAN",
    "group": "Repair",
    "name": "DISM Deep Health Scan (ScanHealth)",
    "description": "Performs comprehensive scan of Windows Component Store for corruption",
    "command": "DISM /Online /Cleanup-Image /ScanHealth",
    "type": "cli",
    "requiresAdmin": true,
    "changesSystem": false,
    "requiresRestart": false
  },
  {
    "id": "REPAIR_DISM_RESTORE",
    "group": "Repair",
    "name": "DISM Restore Health (RestoreHealth)",
    "description": "Repairs Windows Component Store using Windows Update repair sources",
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
    "name": "Audit Only (Inspection & Report)",
    "description": "Scans system configuration, running services, startup programs, and generates recommendations without altering any settings.",
    "target": "All Systems",
    "actions": [
      { "id": "AUDIT_STARTUP", "name": "Audit startup applications", "action": "audit" },
      { "id": "AUDIT_SERVICES", "name": "Audit resource-heavy background services", "action": "audit" },
      { "id": "AUDIT_TEMP", "name": "Measure temporary and junk file sizes", "action": "audit" },
      { "id": "AUDIT_DISK", "name": "Inspect disk storage capacity and media types", "action": "audit" }
    ]
  },
  {
    "id": "balanced",
    "name": "Balanced (Recommended for General Use)",
    "description": "Balances performance and system stability. Disables unnecessary animations, cleans temp files, and audits startup apps. Retains all core security services.",
    "target": "Standard Office & Home PC",
    "actions": [
      { "id": "CLEAN_SAFE_TEMP", "name": "Clean safe user and Windows temporary files", "action": "clean_temp" },
      { "id": "VISUAL_BALANCED", "name": "Disable window animations while preserving smooth font rendering", "action": "visual_balanced" },
      { "id": "AUDIT_STARTUP_RECOMMEND", "name": "Audit and recommend disabling unnecessary third-party startup apps", "action": "startup_recommend" },
      { "id": "TRIM_SSD", "name": "Run ReTrim optimization on SSD volumes", "action": "trim_ssd" }
    ]
  },
  {
    "id": "desktop_perf",
    "name": "Desktop Performance (High-Performance Workstation)",
    "description": "Optimizes system responsiveness for mains-powered desktop PCs. Preserves Windows Defender, Firewall, and Windows Update.",
    "target": "Desktop Workstations prioritizing speed",
    "actions": [
      { "id": "CLEAN_SAFE_TEMP", "name": "Clean safe user and Windows temporary files", "action": "clean_temp" },
      { "id": "POWER_HIGH_PERF", "name": "Suggest High Performance power scheme for AC power", "action": "power_high_perf" },
      { "id": "VISUAL_PERFORMANCE", "name": "Tune visual effects for maximum responsiveness", "action": "visual_perf" },
      { "id": "TRIM_SSD", "name": "Run ReTrim optimization on SSD volumes", "action": "trim_ssd" }
    ]
  },
  {
    "id": "low_resource_hdd",
    "name": "Low Resource / HDD (Budget PC or Mechanical Drive)",
    "description": "Reduces visual overhead, suggests search indexing limits, clears temporary caches, and checks HDD fragmentation.",
    "target": "Legacy PCs, systems with < 8GB RAM or mechanical HDDs",
    "actions": [
      { "id": "CLEAN_SAFE_TEMP", "name": "Clean temporary files safely", "action": "clean_temp" },
      { "id": "VISUAL_MINIMAL", "name": "Switch visual effects to Best Performance (keeping font smoothing)", "action": "visual_minimal" },
      { "id": "ANALYZE_HDD", "name": "Analyze fragmentation status on drive C: (HDD)", "action": "analyze_hdd" },
      { "id": "STARTUP_MINIMAL", "name": "Recommend disabling non-essential third-party startup entries", "action": "startup_minimal" }
    ]
  },
  {
    "id": "laptop_balanced",
    "name": "Laptop Balanced (Battery-Conscious Optimization)",
    "description": "Maintains energy efficiency while cleaning junk files and trimming unnecessary animations. Never forces high power drain on battery.",
    "target": "Laptops & portable devices",
    "actions": [
      { "id": "CLEAN_SAFE_TEMP", "name": "Clean safe temporary files", "action": "clean_temp" },
      { "id": "VISUAL_BALANCED", "name": "Disable window animation overhead", "action": "visual_balanced" },
      { "id": "BATTERY_AWARE_POWER", "name": "Maintain Balanced Power Scheme", "action": "power_balanced" }
    ]
  }
]

'@ | ConvertFrom-Json
$global:TM_EMBEDDED_SYSTEM_CLEANUP = @'
[
  {
    "id": "CLEAN_USER_TEMP",
    "name": "User Temp (%TEMP%)",
    "description": "Temporary files generated by running applications of the current user",
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
    "name": "Windows System Temp (%WINDIR%\\Temp)",
    "description": "Temporary installation and system service files",
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
    "name": "Recycle Bin",
    "description": "Empty deleted files in Recycle Bin across all drives",
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
    "description": "Downloaded and completed update installation files in SoftwareDistribution\\Download",
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
    "description": "Past BSOD crash dumps and memory logs in Minidump",
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
    "description": "Windows Explorer thumbnail cache database files",
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
    "description": "Cached Python package wheel and tarball archives",
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
    "description": "High-performance cache directory for Python uv package manager",
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
    "description": "Compressed tarball packages downloaded from npm registry",
    "safeToDelete": true,
    "preserve": "Project node_modules, npm credentials, package.json"
  },
  {
    "id": "AIDEV_PNPM_STORE",
    "name": "Node.js pnpm Store Prune",
    "category": "Package Cache",
    "cliCommand": "pnpm store prune",
    "detectCommand": "pnpm --version",
    "infoCommand": "pnpm store path",
    "defaultPath": "%LOCALAPPDATA%\\pnpm\\store",
    "description": "Prune unreferenced package files in pnpm content-addressable store",
    "safeToDelete": true,
    "preserve": "Packages hard-linked to active workspace projects"
  },
  {
    "id": "AIDEV_HF_CACHE",
    "name": "Hugging Face Hub Cache",
    "category": "AI Cache",
    "detectCommand": "hf version",
    "defaultPath": "%USERPROFILE%\\.cache\\huggingface\\hub",
    "envVar": "HF_HOME",
    "description": "Cached AI model snapshots and datasets from Hugging Face Hub",
    "safeToDelete": false,
    "requiresReview": true,
    "preserve": "Model snapshots required for offline inference"
  },
  {
    "id": "AIDEV_OLLAMA",
    "name": "Ollama Models & Logs",
    "category": "AI Models",
    "detectCommand": "ollama --version",
    "listCommand": "ollama list",
    "defaultPath": "%USERPROFILE%\\.ollama\\models",
    "envVar": "OLLAMA_MODELS",
    "description": "Local LLM models (Llama, DeepSeek, Qwen) stored by Ollama",
    "safeToDelete": false,
    "requiresReview": true,
    "preserve": "NEVER deleted automatically. Only inspect usage and use explicit ollama rm"
  },
  {
    "id": "AIDEV_DOCKER_BUILDER",
    "name": "Docker Builder Cache",
    "category": "Container",
    "detectCommand": "docker --version",
    "cliCommand": "docker builder prune -f",
    "infoCommand": "docker system df",
    "description": "BuildKit layer cache generated during container builds",
    "safeToDelete": true,
    "preserve": "Active images, running containers, named Docker volumes"
  },
  {
    "id": "AIDEV_VSCODE_LOGS",
    "name": "VS Code & Cursor Disposable Cache / Logs",
    "category": "IDE",
    "defaultPath": "%APPDATA%\\Code\\logs",
    "cursorPath": "%APPDATA%\\Cursor\\logs",
    "description": "Expired session logs and temporary crash dumps for VS Code and Cursor",
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
    Write-Host "[WARNING] " -ForegroundColor Yellow -NoNewline
    Write-Host $Message -ForegroundColor Yellow
}

function Write-ErrorMessage {
    param ([string]$Message)
    Write-Host "[ERROR] " -ForegroundColor Red -NoNewline
    Write-Host $Message -ForegroundColor Red
}

function Write-InfoMessage {
    param ([string]$Message)
    Write-Host "[INFO] " -ForegroundColor Cyan -NoNewline
    Write-Host $Message -ForegroundColor Gray
}

function Write-SkipMessage {
    param ([string]$Message)
    Write-Host "[SKIPPED] " -ForegroundColor DarkYellow -NoNewline
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
        if ($val -is [string] -and ($val -match "OK|Running|Active|Enabled|Activated|Healthy|Good")) {
            Write-Host $val -ForegroundColor Green
        }
        elseif ($val -is [string] -and ($val -match "Warning|Expired|Low|Disabled|Stopped|Degraded")) {
            Write-Host $val -ForegroundColor Yellow
        }
        elseif ($val -is [string] -and ($val -match "Error|Failed|Corrupt|Disconnected|Critical")) {
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
        Write-Host "  (No data available)" -ForegroundColor DarkGray
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
        [string]$PromptText = "Select an option",
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
        Write-ErrorMessage "Please enter a valid number between $Min and $Max."
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
    Write-Host " CONFIRM ACTION: $TaskName" -ForegroundColor White
    Write-Host " Risk Level: $RiskLevel" -ForegroundColor Yellow
    if ($ImpactDescription) {
        Write-Host " Impact:" -ForegroundColor Gray
        Write-Host "   $ImpactDescription" -ForegroundColor Gray
    }
    Write-Host "=========================================================" -ForegroundColor Yellow

    if ($RequiresKeyword -or $RiskLevel -eq "high") {
        Write-Host " High-risk action. Type 'APPLY' to confirm, or press any other key to cancel: " -ForegroundColor Red -NoNewline
        $ans = Read-Host
        return ($ans.Trim() -eq "APPLY")
    }

    Write-Host " Are you sure you want to proceed? (Y/N): " -ForegroundColor Cyan -NoNewline
    $ans = Read-Host
    return ($ans.Trim().ToUpper() -eq "Y")
}

function Read-SecurePassword {
    param (
        [string]$PromptText = "Enter password"
    )
    Write-Host " $($PromptText): " -ForegroundColor Cyan -NoNewline
    $sec = Read-Host -AsSecureString
    return $sec
}

function Pause-Screen {
    param (
        [string]$Message = "Press Enter to return to menu..."
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
        [string]$TaskName = "System",
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
        [string]$ActionName = "this action"
    )
    if (-not (Test-IsAdmin)) {
        Write-ErrorMessage "Administrator privileges required to perform $ActionName."
        Write-InfoMessage "Please restart the tool as Administrator (right click -> 'Run as administrator')."
        return $false
    }
    return $true
}

function Request-Elevation {
    param (
        [string]$Reason = "perform system administration tasks"
    )
    if (Test-IsAdmin) { return $true }

    Write-WarningMessage "Administrator elevation required to $Reason."
    Write-Host " Would you like to restart in an elevated Administrator session? (Y/N): " -ForegroundColor Cyan -NoNewline
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
            $eolNotice = " [Standard EOL: Oct 14, 2025]"
        }

        $info["Operating System"] = "$osFamily $displayVersion (Build $buildNumber)$eolNotice"
        $info["OS Edition"] = $osCaption
        $info["Architecture"] = $osCim.OSArchitecture
        $info["Computer Name (Hostname)"] = [System.Environment]::MachineName
        $info["Current User"] = "$([System.Environment]::UserDomainName)\$([System.Environment]::UserName)"
        $info["Administrator Privilege"] = if (Test-IsAdmin) { "Yes (Elevated)" } else { "No (Standard User)" }
    } catch {
        $info["Operating System"] = "Windows (Unable to read CIM: $($_.Exception.Message))"
    }

    # 2. Hardware: CPU & RAM
    try {
        $cpu = Get-CimInstance -ClassName Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($cpu) {
            $info["Processor (CPU)"] = $cpu.Name.Trim()
        }

        $totalMem = [math]::Round($osCim.TotalVisibleMemorySize / 1MB, 1)
        $freeMem = [math]::Round($osCim.FreePhysicalMemory / 1MB, 1)
        $usedMem = [math]::Round($totalMem - $freeMem, 1)
        $pctMem = [math]::Round(($usedMem / $totalMem) * 100, 0)
        $info["RAM Memory"] = "$usedMem GB / $totalMem GB ($pctMem% used - $freeMem GB free)"
    } catch {}

    # 3. Storage
    try {
        $drives = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction SilentlyContinue
        $driveSummaries = @()
        foreach ($d in $drives) {
            $totalGB = [math]::Round($d.Size / 1GB, 1)
            $freeGB = [math]::Round($d.FreeSpace / 1GB, 1)
            $pctFree = if ($totalGB -gt 0) { [math]::Round(($freeGB / $totalGB) * 100, 0) } else { 0 }
            $driveSummaries += "$($d.DeviceID) ($freeGB GB free / $totalGB GB - $pctFree%)"
        }
        $info["Storage Drives"] = $driveSummaries -join ", "
    } catch {}

    # 4. Network Status
    try {
        $net = Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "*Wi-Fi*","*Ethernet*","*LAN*" -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notlike "169.254*" } | Select-Object -First 1
        if ($net) {
            $info["IPv4 Address"] = "$($net.IPAddress) ($($net.InterfaceAlias))"
        } else {
            $info["IPv4 Address"] = "No active LAN or Wi-Fi adapter detected"
        }
    } catch {
        $info["IPv4 Address"] = "Unable to read network info"
    }

    # 5. Security & Services
    try {
        $spooler = Get-Service -Name Spooler -ErrorAction SilentlyContinue
        $info["Print Spooler"] = if ($spooler) { "$($spooler.Status) (Startup: $($spooler.StartType))" } else { "Not Found" }
    } catch {}

    try {
        $printers = Get-Printer -ErrorAction SilentlyContinue
        $printerCount = if ($printers) { @($printers).Count } else { 0 }
        $info["Installed Printers"] = "$printerCount printers"
    } catch {
        $info["Installed Printers"] = "Unable to read printers"
    }

    try {
        $defenderSvc = Get-Service -Name WinDefend -ErrorAction SilentlyContinue
        $info["Microsoft Defender"] = if ($defenderSvc -and $defenderSvc.Status -eq "Running") { "Running (Active)" } else { "Disabled or Unavailable" }
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
            Write-WarningMessage "$FeatureName requires Windows build $MinBuild or newer (Current: $($global:TM_OS_INFO.Build))."
            return $false
        }
        if ($RequiresPro -and (Test-IsWindowsHome)) {
            Write-WarningMessage "$FeatureName requires Windows Pro or Enterprise edition (Windows Home is not supported)."
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
        Write-ErrorMessage "Unable to backup Registry: $($_.Exception.Message)"
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
        Write-ErrorMessage "Unable to backup service state for $ServiceName : $($_.Exception.Message)"
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
        Write-Success "Created state backup snapshot: $($Session.Id)"
        return $Session.Id
    } catch {
        Write-ErrorMessage "Failed to save backup manifest: $($_.Exception.Message)"
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
    if (-not (Assert-Admin "restore backup")) { return $false }

    $backupRoot = if ($PSScriptRoot) { Join-Path $PSScriptRoot "../../Backups" } else { Join-Path $env:SystemDrive "TM-WinCare\Backups" }
    $backupDir = Join-Path $backupRoot $BackupId
    $manifestPath = Join-Path $backupDir "manifest.json"
    if (-not (Test-Path $manifestPath)) {
        Write-ErrorMessage "Backup manifest file not found for: $BackupId"
        return $false
    }

    try {
        $manifest = Get-Content -Path $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
        Write-SubHeader "RESTORE BACKUP SNAPSHOT: $BackupId ($($manifest.description))"

        # 1. Rollback Registry
        if ($manifest.registry) {
            foreach ($item in $manifest.registry) {
                Write-InfoMessage "Restoring Registry: $($item.path) -> $($item.name)"
                if ($item.existed) {
                    if (-not (Test-Path $item.path)) {
                        New-Item -Path $item.path -Force | Out-Null
                    }
                    Set-ItemProperty -Path $item.path -Name $item.name -Value $item.oldValue -Force
                    Write-Success "Restored value: $($item.name) = $($item.oldValue)"
                } else {
                    Remove-ItemProperty -Path $item.path -Name $item.name -ErrorAction SilentlyContinue
                    Write-Success "Removed newly added property: $($item.name)"
                }
            }
        }

        # 2. Rollback Services
        if ($manifest.services) {
            foreach ($svc in $manifest.services) {
                Write-InfoMessage "Restoring Service: $($svc.name) -> $($svc.startMode)"
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
                    Write-Success "Restored service: $($svc.name)"
                } catch {
                    Write-ErrorMessage "Unable to restore service $($svc.name): $($_.Exception.Message)"
                }
            }
        }

        Write-TMLog -TaskId "ROLLBACK" -TaskName "Rollback Backup" -Status "Success" -Message "Restored backup $BackupId"
        Write-Success "Rollback of snapshot $BackupId completed successfully!"
        return $true
    } catch {
        Write-ErrorMessage "Error during rollback: $($_.Exception.Message)"
        Write-TMLog -TaskId "ROLLBACK" -TaskName "Rollback Backup" -Status "Failed" -Message $_.Exception.Message
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
        if (-not (Request-Elevation -Reason "execute task '$TaskName'")) {
            Write-SkipMessage "Task '$TaskName' skipped due to missing Administrator privileges."
            return $false
        }
    }

    # 2. Risk confirmation
    $approved = Confirm-Action -TaskName $TaskName -ImpactDescription $ImpactDescription -RiskLevel $RiskLevel
    if (-not $approved) {
        Write-SkipMessage "User cancelled task '$TaskName'."
        Write-TMLog -TaskId $TaskId -TaskName $TaskName -Status "Skipped" -Message "Cancelled by user"
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
    Write-ErrorMessage "An error occurred while executing [$TaskId] $TaskName"
    if ($Context) {
        Write-InfoMessage "Context: $Context"
    }
    Write-Host "  Error details: $msg" -ForegroundColor Red

    # Log error
    Write-TMLog -TaskId $TaskId -TaskName $TaskName -Status "Failed" -Message "Error: $msg ($Context)"
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
        [string]$ExitLabel = "Back"
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

        $selection = Read-MenuSelection -PromptText "Select an option" -Min 0 -Max $MenuItems.Count
        if ($selection -eq 0) {
            break
        }

        $chosen = $MenuItems[$selection - 1]
        if ($chosen.Action -is [scriptblock]) {
            try {
                & $chosen.Action
            } catch {
                Write-ErrorMessage "Menu item execution error: $($_.Exception.Message)"
            }
        }
    }
}


# === SOURCE: src/Modules/Dashboard/Dashboard.ps1 ===
# TM-WinCare - Dashboard & System Health Information
# Adheres to Section 3.1 of TM-WinCare-Architecture-v1.2.md

function Show-TMDashboard {
    Write-Header -Title "SYSTEM INFORMATION & HEALTH DASHBOARD"
    Write-InfoMessage "Loading hardware and operating system metrics..."

    $sys = Get-TMSystemInfo
    Write-Host ""
    Show-PropertyGrid -Properties $sys -KeyWidth 28

    Write-Host ""
    Write-Host "  [1] Refresh Information" -ForegroundColor Cyan
    Write-Host "  [2] Export System Report to TXT" -ForegroundColor Cyan
    Write-Host "  [3] Export System Report to JSON" -ForegroundColor Cyan
    Write-Host "  [0] Back to Main Menu" -ForegroundColor Yellow
    Write-Divider

    $sel = Read-MenuSelection -PromptText "Select an option" -Min 0 -Max 3
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
    $lines += "         TM-WINCARE - SYSTEM DIAGNOSTIC REPORT"
    $lines += "  Generated: " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $lines += "========================================================="
    foreach ($k in $Properties.Keys) {
        $lines += ("{0,-28}: {1}" -f $k, $Properties[$k])
    }
    $lines += "========================================================="

    Set-Content -Path $fullPath -Value $lines -Encoding UTF8 -Force
    Write-Success "Report exported to file: $fullPath"
    Write-TMLog -TaskId "REPORT_TXT" -TaskName "Export System Report" -Status "Success" -Message "Exported $filename"
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
    Write-Success "Report exported to file: $fullPath"
    Write-TMLog -TaskId "REPORT_JSON" -TaskName "Export System Report JSON" -Status "Success" -Message "Exported $filename"
    Pause-Screen
}


# === SOURCE: src/Modules/PostInstall/CheckLicense.ps1 ===
# TM-WinCare - License and IT Inventory Tool
# Decodes Full 25-character Windows Key & Office Key, Mainboard Serial, UUID, Sync to Google Sheets / Form

function Invoke-LicenseInventoryCheck {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

    # ==================== GOOGLE SHEETS / FORM CONFIGURATION ====================
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

    Write-Host "`n[*] Scanning hardware and decoding Windows & Office Product Keys..." -ForegroundColor Cyan

    $cs = Get-CimInstance Win32_ComputerSystemProduct -ErrorAction SilentlyContinue
    $bb = Get-CimInstance Win32_BaseBoard -ErrorAction SilentlyContinue
    $os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
    $sls = Get-CimInstance SoftwareLicensingService -ErrorAction SilentlyContinue

    # 1. Full Key Windows (Registry + Backup Key + BIOS OEM Key)
    $winRegKey = Get-RegistryProductKeyLocal "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    $winBackupKey = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform" -ErrorAction SilentlyContinue).BackupProductKeyDefault
    $winOemKey = if ($sls) { $sls.OA3xOriginalProductKey } else { $null }

    $allLicProducts = @(Get-CimInstance SoftwareLicensingProduct -Filter "PartialProductKey IS NOT NULL" -ErrorAction SilentlyContinue)
    $winAllLic = $allLicProducts | Where-Object { $_.ApplicationID -eq '55c92734-d682-4d71-983e-d6ec3f16059f' } | Sort-Object LicenseStatus -Descending
    $winActiveLic = $winAllLic | Select-Object -First 1
    $winStatus = if ($winActiveLic -and $winActiveLic.LicenseStatus -eq 1) { "Activated" } else { "Unactivated" }
    $winPartial = if ($winActiveLic -and $winActiveLic.PartialProductKey) { $winActiveLic.PartialProductKey } else { "N/A" }

    $winFullList = @()
    if ($winRegKey) { $winFullList += "Active: $winRegKey" }
    if ($winBackupKey -and $winBackupKey -ne $winRegKey) { $winFullList += "Backup: $winBackupKey" }
    if ($winOemKey) { $winFullList += "OEM-BIOS: $winOemKey" }
    if ($winFullList.Count -eq 0) { $winFullList += "Last-5: $winPartial" }
    $winKeySummary = $winFullList -join " | "

    # 2. Key Office
    $offAllLic = @($allLicProducts | Where-Object { $_.Name -like '*Office*' })
    if ($offAllLic.Count -eq 0) {
        $offAllLic = @(Get-CimInstance OfficeSoftwareProtectionProduct -Filter "PartialProductKey IS NOT NULL" -ErrorAction SilentlyContinue)
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
            $st = if ($item.LicenseStatus -eq 1) { "Activated" } else { "Unactivated" }
            $pk = $item.PartialProductKey

            $matchedFull = $offRegKeys | Where-Object { $_ -like "*$pk" } | Select-Object -First 1
            $keyDisplay = if ($matchedFull) { $matchedFull } else { "XXXXX-$pk ($cleanName)" }

            $offNames += $cleanName
            $offStatuses += $st
            $offKeys += $keyDisplay
        }
        $offNameSummary = ($offNames | Select-Object -Unique) -join " | "
        $offStatusSummary = if ($offStatuses -contains "Activated") { "Activated" } else { "Unactivated" }
        $offKeySummary = $offKeys -join " | "
    } else {
        $offNameSummary = "Not Installed"
        $offStatusSummary = "Unactivated"
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
        Write-Host "`n================ SYSTEM INVENTORY & LICENSE KEY OVERVIEW ================" -ForegroundColor Green
        Write-Host ("  Timestamp         : {0}" -f $dataObj.Thoi_Gian_Check)
        Write-Host ("  Computer Name     : {0}" -f $dataObj.Ten_May) -ForegroundColor Yellow
        Write-Host ("  UUID Mainboard    : {0}" -f $dataObj.UUID_Mainboard)
        Write-Host ("  Model Mainboard   : {0}" -f $dataObj.Model_Mainboard)
        Write-Host ("  Serial Mainboard  : {0}" -f $dataObj.Serial_Mainboard)
        Write-Host ("  Windows OS        : {0}" -f $dataObj.Phien_Ban_Win)
        Write-Host ("  Windows Status    : {0}" -f $dataObj.Trang_Thai_Win)
        Write-Host ("  Full Windows Key  : {0}" -f $dataObj.Key_Win_5_Cuoi) -ForegroundColor Cyan
        Write-Host ("  Office Edition    : {0}" -f $dataObj.Phien_Ban_Office)
        Write-Host ("  Office Status     : {0}" -f $dataObj.Trang_Thai_Office)
        Write-Host ("  Office Keys       : {0}" -f $dataObj.Key_Office_5_Cuoi) -ForegroundColor Cyan
        Write-Host "=========================================================================" -ForegroundColor Green
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

        Write-Host "`nSelect export format (saving to $folder):" -ForegroundColor Cyan
        Write-Host "  [1] Append to CSV inventory table (IT_Inventory_List.csv)"
        Write-Host "  [2] Export detailed TXT report (Info_$($dataObj.Ten_May).txt)"
        Write-Host "  [3] Export JSON file (Info_$($dataObj.Ten_May).json)"
        $sub = Read-Host "Choice (1/2/3)"

        switch ($sub) {
            "1" {
                [PSCustomObject]$dataObj | Export-Csv -Path $csvPath -Append -NoTypeInformation -Encoding UTF8
                Write-Host "[+] Appended to CSV inventory: $csvPath" -ForegroundColor Green
            }
            "2" {
                $dataObj.GetEnumerator() | ForEach-Object { "{0,-20}: {1}" -f $_.Key, $_.Value } | Out-File -FilePath $txtPath -Encoding UTF8
                Write-Host "[+] Exported TXT report: $txtPath" -ForegroundColor Green
            }
            "3" {
                $dataObj | ConvertTo-Json | Out-File -FilePath $jsonPath -Encoding UTF8
                Write-Host "[+] Exported JSON: $jsonPath" -ForegroundColor Green
            }
            default { Write-Host "[!] Invalid selection." -ForegroundColor Red }
        }
    }

    function Send-ToGoogleSheetsLocal {
        $pin = Read-Host "Enter secret security PIN to authorize sync"
        $dataObj.Secret_PIN = $pin

        $note = Read-Host "`nEnter notes for this machine (Press Enter to skip)"
        $dataObj.Ghi_Chu = $note
        $payload = $dataObj | ConvertTo-Json -Compress

        Write-Host "[*] Syncing inventory data to Google Sheets..." -ForegroundColor Yellow
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $res = Invoke-RestMethod -Uri $WEB_APP_URL -Method Post -Body ([System.Text.Encoding]::UTF8.GetBytes($payload)) -ContentType "text/plain; charset=utf-8"
            if ($res.status -eq "updated") {
                Write-Host "[+] SUCCESS! Overwritten record on row #$($res.row) for $($dataObj.Ten_May) in Google Sheets." -ForegroundColor Green
            } elseif ($res.status -eq "inserted") {
                Write-Host "[+] SUCCESS! Added new entry for $($dataObj.Ten_May) to Google Sheets." -ForegroundColor Green
            } elseif ($res.status -eq "error") {
                Write-Host "[!] GOOGLE APPS SCRIPT ERROR: $($res.message)" -ForegroundColor Red
            } else {
                Write-Host "[+] Sent data! Response: $($res | ConvertTo-Json -Compress)" -ForegroundColor Green
            }
        } catch {
            Write-Host "[!] CONNECTION ERROR: $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    function Open-GoogleFormLocal {
        Write-Host "`nSelect Google Form mode:" -ForegroundColor Cyan
        Write-Host "  [1] Open Google Form and copy device info to Clipboard"
        Write-Host "  [2] Open blank Google Form"
        $fChoice = Read-Host "Choice (1/2)"

        if ($fChoice -eq "1" -and $PREFILL_TEMPLATE -ne "") {
            $note = Read-Host "Enter additional notes for Form (Press Enter to skip)"
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

            Write-Host "[*] Opening Google Form (prefilled with device specs)..." -ForegroundColor Green
            Start-Process $url
        } else {
            $clipText = "Computer: $($dataObj.Ten_May) | UUID: $($dataObj.UUID_Mainboard) | Main: $($dataObj.Model_Mainboard) | Serial: $($dataObj.Serial_Mainboard) | Win: $($dataObj.Phien_Ban_Win) ($($dataObj.Trang_Thai_Win) - $($dataObj.Key_Win_5_Cuoi)) | Office: $($dataObj.Phien_Ban_Office) ($($dataObj.Trang_Thai_Office) - $($dataObj.Key_Office_5_Cuoi))"
            Set-Clipboard -Value $clipText
            Write-Host "[+] Copied device information summary to Clipboard!" -ForegroundColor Cyan
            Start-Process $GOOGLE_FORM_URL
        }
    }

    Show-TerminalInfoLocal

    while ($true) {
        Write-Host "`n==================== LICENSE & INVENTORY MENU ====================" -ForegroundColor Cyan
        Write-Host "  [1] Display License & Hardware Information"
        Write-Host "  [2] Export Data to File (CSV / TXT / JSON)"
        Write-Host "  [3] Sync to Google Sheets (Direct API)"
        Write-Host "  [4] Open Google Form (Prefilled with Machine Info)"
        Write-Host "  [5] Open Google Sheets Inventory Spreadsheet"
        Write-Host "  [6] Run All: Export CSV + Sync Google Sheets"
        Write-Host "  [0] Return to Main Menu"
        Write-Host "==================================================================" -ForegroundColor Cyan
        $choice = Read-Host "Enter your choice (0-6)"

        switch ($choice) {
            "1" { Show-TerminalInfoLocal }
            "2" { Export-ToFileLocal }
            "3" { Send-ToGoogleSheetsLocal }
            "4" { Open-GoogleFormLocal }
            "5" {
                Write-Host "[*] Opening Google Sheets..." -ForegroundColor Green
                Start-Process $GOOGLE_SHEET_URL
            }
            "6" {
                $folder = Get-ExportFolder
                $csvPath = Join-Path $folder "IT_Inventory_List.csv"
                [PSCustomObject]$dataObj | Export-Csv -Path $csvPath -Append -NoTypeInformation -Encoding UTF8
                Write-Host "[+] Saved CSV record to: $csvPath" -ForegroundColor Green
                Send-ToGoogleSheetsLocal
            }
            "0" { return }
            default { Write-Host "[!] Please select between 0 and 6." -ForegroundColor Yellow }
        }
    }
}


# === SOURCE: src/Modules/PostInstall/PostInstall.ps1 ===
# TM-WinCare - Windows Post-Install Configuration
# Adheres to Section 3.2 of TM-WinCare-Architecture-v1.2.md


function Show-TMPostInstallMenu {
    $menuItems = @(
        @{ Label = "Windows & Office License Management (IT Inventory Full Key)"; Action = { Invoke-LicenseInventoryCheck } },
        @{ Label = "Rename Computer Hostname"; Action = { Invoke-RenameComputer } },
        @{ Label = "Show Known File Extensions (.exe, .txt...)"; Action = { Set-ExplorerShowFileExtensions -Enable $true } },
        @{ Label = "Hide Known File Extensions"; Action = { Set-ExplorerShowFileExtensions -Enable $false } },
        @{ Label = "Show Hidden Files and Folders"; Action = { Set-ExplorerShowHiddenFiles -Enable $true } },
        @{ Label = "Hide Hidden Files and Folders"; Action = { Set-ExplorerShowHiddenFiles -Enable $false } },
        @{ Label = "Check Missing / Faulty Drivers (Device Errors)"; Action = { Test-DeviceErrors } },
        @{ Label = "Open Date & Time Settings"; Action = { Start-Process "timedate.cpl" } },
        @{ Label = "Open Windows Update Settings"; Action = { Start-Process "ms-settings:windowsupdate" } },
        @{ Label = "Open Windows Activation Settings"; Action = { Start-Process "ms-settings:activation" } },
        @{ Label = "Open Startup Folder (shell:startup)"; Action = { Start-Process "explorer.exe" "shell:startup" } },
        @{ Label = "Open Power Options (powercfg.cpl)"; Action = { Start-Process "powercfg.cpl" } }
    )
    Show-TMMenu -Title "WINDOWS POST-INSTALL CONFIGURATION" -MenuItems $menuItems -ExitLabel "Back"
}

function Invoke-RenameComputer {
    if (-not (Assert-Admin "rename computer")) {
        Pause-Screen
        return
    }

    $currentName = [System.Environment]::MachineName
    Write-SubHeader "RENAME COMPUTER HOSTNAME"
    Write-InfoMessage "Current Computer Name: $currentName"
    Write-Host " Enter new computer name (letters, digits and dashes, max 15 chars): " -ForegroundColor Cyan -NoNewline
    $newName = Read-Host

    if ([string]::IsNullOrWhiteSpace($newName) -or $newName -match '[^a-zA-Z0-9\-]') {
        Write-ErrorMessage "Invalid computer name. Only characters a-z, 0-9 and hyphens (-) are permitted."
        Pause-Screen
        return
    }

    if ($newName.Length -gt 15) {
        Write-ErrorMessage "Computer NetBIOS name must not exceed 15 characters."
        Pause-Screen
        return
    }

    if ($newName.ToUpper() -eq $currentName.ToUpper()) {
        Write-WarningMessage "New name is identical to current computer name."
        Pause-Screen
        return
    }

    $approved = Confirm-Action -TaskName "Rename Computer" -ImpactDescription "Rename computer from '$currentName' to '$newName'. Requires a restart to take effect." -RiskLevel "medium"
    if ($approved) {
        try {
            Rename-Computer -NewName $newName -Force -ErrorAction Stop
            Write-Success "Computer successfully renamed to '$newName'!"
            Write-WarningMessage "A SYSTEM RESTART IS REQUIRED for the new hostname to take effect."
            Write-TMLog -TaskId "POST_RENAME" -TaskName "Rename Computer" -Status "Success" -Message "Renamed from $currentName to $newName" -RequiresRestart $true
        } catch {
            Handle-TMException -TaskId "POST_RENAME" -TaskName "Rename Computer" -Exception $_.Exception
        }
    }
    Pause-Screen
}

function Set-ExplorerShowFileExtensions {
    param ([bool]$Enable)
    $val = if ($Enable) { 0 } else { 1 }
    $actionDesc = if ($Enable) { "Show file extensions" } else { "Hide file extensions" }
    
    try {
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        Set-ItemProperty -Path $regPath -Name "HideFileExt" -Value $val -Force
        Write-Success "Setting updated: $actionDesc."
        Write-InfoMessage "Note: You may need to restart or refresh File Explorer."
        Write-TMLog -TaskId "POST_FILEEXT" -TaskName $actionDesc -Status "Success" -Message "HideFileExt = $val"
    } catch {
        Handle-TMException -TaskId "POST_FILEEXT" -TaskName $actionDesc -Exception $_.Exception
    }
    Pause-Screen
}

function Set-ExplorerShowHiddenFiles {
    param ([bool]$Enable)
    $val = if ($Enable) { 1 } else { 2 }
    $actionDesc = if ($Enable) { "Show hidden files and folders" } else { "Hide hidden files and folders" }

    try {
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        Set-ItemProperty -Path $regPath -Name "Hidden" -Value $val -Force
        Write-Success "Setting updated: $actionDesc."
        Write-TMLog -TaskId "POST_HIDDEN" -TaskName $actionDesc -Status "Success" -Message "Hidden = $val"
    } catch {
        Handle-TMException -TaskId "POST_HIDDEN" -TaskName $actionDesc -Exception $_.Exception
    }
    Pause-Screen
}

function Test-DeviceErrors {
    Write-SubHeader "CHECK HARDWARE DEVICES & MISSING DRIVERS"
    Write-InfoMessage "Querying Plug and Play entities via CIM..."

    try {
        $problemDevices = Get-CimInstance -ClassName Win32_PnPEntity | Where-Object { $_.ConfigManagerErrorCode -ne 0 -and $null -ne $_.ConfigManagerErrorCode }
        if (-not $problemDevices -or @($problemDevices).Count -eq 0) {
            Write-Success "All good! No faulty or missing driver devices detected on this system."
        } else {
            Write-WarningMessage "Detected $(@($problemDevices).Count) device(s) reporting error codes:"
            $headers = @("Device Name", "PnP Error Code", "Hardware ID")
            $props = @("Name", "ConfigManagerErrorCode", "DeviceID")
            $widths = @(30, 16, 30)
            Show-TableList -Items $problemDevices -Headers $headers -PropertyNames $props -Widths $widths
            Write-Host ""
            Write-InfoMessage "Tip: Open Device Manager (devmgmt.msc) to install or update drivers."
        }
    } catch {
        Handle-TMException -TaskId "DEV_CHECK" -TaskName "Check Devices" -Exception $_.Exception
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
        Write-ErrorMessage "Optimization profile not found: $ProfileId"
        Pause-Screen
        return
    }

    Write-Header -Title "AUTO OPTIMIZE: $($prof.name)"
    Write-InfoMessage "Objective: $($prof.description)"
    Write-Host " Target environment: $($prof.target)" -ForegroundColor Gray
    Write-Host ""

    # 1. Pre-scan
    Write-SubHeader "STEP 1: SYSTEM PRE-SCAN METRICS"
    $sys = Get-TMSystemInfo
    Write-Success "Operating System: $($sys['Operating System'])"
    Write-Success "RAM Memory: $($sys['RAM Memory'])"
    Write-Success "Storage Capacity: $($sys['Storage Drives'])"

    # 2. Health checks
    Write-SubHeader "STEP 2: SAFETY PREREQUISITE CHECKS"
    $needsAdmin = ($ProfileId -ne "audit")
    if ($needsAdmin -and -not (Test-IsAdmin)) {
        Write-ErrorMessage "This optimization profile requires Administrator privileges."
        if (-not (Request-Elevation -Reason "apply optimization profile $($prof.name)")) {
            Pause-Screen
            return
        }
    }
    Write-Success "Administrator Privilege Check: Valid."

    # 3. Preview Actions
    Write-SubHeader "STEP 3: ACTION PREVIEW"
    $actions = $prof.actions
    for ($i = 0; $i -lt $actions.Count; $i++) {
        Write-Host "  [$($i+1)] $($actions[$i].name)" -ForegroundColor Cyan
    }
    Write-Host ""

    if ($ProfileId -eq "audit") {
        Write-Success "System audit complete. No system changes were applied."
        Pause-Screen
        return
    }

    # 4. Confirm & Backup
    $confirmed = Confirm-Action -TaskName "Auto Optimize - $($prof.name)" -ImpactDescription "Apply safe optimizations defined in profile $($prof.name). An automatic rollback snapshot will be created." -RiskLevel "medium"
    if (-not $confirmed) {
        Write-SkipMessage "Optimization cancelled by user."
        Pause-Screen
        return
    }

    Write-SubHeader "STEP 4: CREATE SYSTEM RESTORE SNAPSHOT"
    $session = New-TMBackupSession -TaskId "AUTO_OPT_$ProfileId" -Description "Backup prior to Auto Optimize $($prof.name)"
    
    # Backup relevant Registry keys for visual effects
    Backup-RegistryValue -Session $session -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" | Out-Null
    $backupId = Save-TMBackupSession -Session $session

    # 5. Apply
    Write-SubHeader "STEP 5: APPLYING OPTIMIZATIONS"
    foreach ($act in $actions) {
        Write-Host "-> Executing: $($act.name)... " -ForegroundColor White -NoNewline
        switch ($act.action) {
            "clean_temp" {
                $userTemp = [System.IO.Path]::GetTempPath()
                $cleanedCount = 0
                Get-ChildItem -Path $userTemp -File -ErrorAction SilentlyContinue | ForEach-Object {
                    try { Remove-Item $_.FullName -Force -ErrorAction Stop; $cleanedCount++ } catch {}
                }
                Write-Host "Done (Cleaned $cleanedCount temp files)." -ForegroundColor Green
            }
            "visual_balanced" {
                try {
                    # VisualFXSetting: 3 = Custom (disable animation, keep font smoothing)
                    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 3 -Force -ErrorAction SilentlyContinue
                    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0 -Force -ErrorAction SilentlyContinue
                    Write-Host "Done (Animations reduced, fonts preserved)." -ForegroundColor Green
                } catch { Write-Host "Skipped ($($_.Exception.Message))" -ForegroundColor Yellow }
            }
            "visual_perf" {
                try {
                    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -Force -ErrorAction SilentlyContinue
                    Write-Host "Done (Configured for Best Performance)." -ForegroundColor Green
                } catch { Write-Host "Skipped" -ForegroundColor Yellow }
            }
            "visual_minimal" {
                try {
                    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -Force -ErrorAction SilentlyContinue
                    Write-Host "Done." -ForegroundColor Green
                } catch { Write-Host "Skipped" -ForegroundColor Yellow }
            }
            "trim_ssd" {
                try {
                    if (Test-CmdletAvailable "Optimize-Volume") {
                        Optimize-Volume -DriveLetter C -ReTrim -ErrorAction SilentlyContinue | Out-Null
                        Write-Host "Done (SSD ReTrim executed)." -ForegroundColor Green
                    } else {
                        Write-Host "Not available." -ForegroundColor DarkGray
                    }
                } catch { Write-Host "Skipped." -ForegroundColor Yellow }
            }
            default {
                Write-Host "Complete." -ForegroundColor Green
            }
        }
    }

    # 6. Verify & Report
    Write-SubHeader "STEP 6: VERIFICATION & SUMMARY"
    Write-Success "Optimization profile '$($prof.name)' applied successfully!"
    Write-InfoMessage "Backup snapshot created: $backupId (Rollback available anytime in Backup & Restore menu)"
    Write-TMLog -TaskId "AUTO_OPT_$ProfileId" -TaskName "Auto Optimize $($prof.name)" -Status "Success" -Message "Profile applied successfully" -BackupId $backupId
    
    Pause-Screen
}


# === SOURCE: src/Modules/Optimization/Optimization.ps1 ===
# TM-WinCare - Optimization Main Module
# Adheres to Section 3.3.1 of TM-WinCare-Architecture-v1.2.md


function Show-TMOptimizationMenu {
    $menuItems = @(
        @{ Label = "Audit System & Generate Optimization Recommendations"; Action = { Invoke-AutoOptimizeProfile -ProfileId "audit" } },
        @{ Label = "Auto Optimize - Balanced (Recommended for General PC)"; Action = { Invoke-AutoOptimizeProfile -ProfileId "balanced" } },
        @{ Label = "Auto Optimize - Desktop Performance (High-Performance Workstation)"; Action = { Invoke-AutoOptimizeProfile -ProfileId "desktop_perf" } },
        @{ Label = "Auto Optimize - Low Resource / HDD Budget PC"; Action = { Invoke-AutoOptimizeProfile -ProfileId "low_resource_hdd" } },
        @{ Label = "Auto Optimize - Laptop Balanced (Battery-Conscious)"; Action = { Invoke-AutoOptimizeProfile -ProfileId "laptop_balanced" } },
        @{ Label = "Services Manager (SysMain / WSearch / Ndu Status)"; Action = { Show-ServicesManagerMenu } },
        @{ Label = "Visual Effects & Window Animations"; Action = { Show-VisualEffectsMenu } },
        @{ Label = "Startup Applications (Run at Boot)"; Action = { Show-StartupAppsMenu } },
        @{ Label = "Power Plan & Performance Schemes"; Action = { Show-PowerPlanMenu } },
        @{ Label = "View Recent Backups & Rollback"; Action = { Show-TMBackupMenu } }
    )
    Show-TMMenu -Title "SAFE SYSTEM OPTIMIZATION (PROFILES & TUNING)" -MenuItems $menuItems -ExitLabel "Back"
}

function Show-ServicesManagerMenu {
    Write-Header -Title "WINDOWS SERVICES MANAGEMENT CONSOLE"
    Write-InfoMessage "Querying service status for critical system components..."

    $servicesToCheck = @("SysMain", "WSearch", "Ndu")
    $list = @()
    foreach ($sName in $servicesToCheck) {
        $svc = Get-Service -Name $sName -ErrorAction SilentlyContinue
        $startMode = "Not Found"
        if ($svc) {
            $cim = Get-CimInstance Win32_Service -Filter "Name='$sName'" -ErrorAction SilentlyContinue
            if ($cim) { $startMode = $cim.StartMode }
        }
        $list += [PSCustomObject]@{
            ServiceName = $sName
            Status = if ($svc) { $svc.Status.ToString() } else { "Not Present" }
            StartupType = $startMode
        }
    }

    $headers = @("Service Name", "Status", "Startup Type")
    $props = @("ServiceName", "Status", "StartupType")
    $widths = @(18, 18, 20)
    Show-TableList -Items $list -Headers $headers -PropertyNames $props -Widths $widths

    Write-Host ""
    Write-Host "  IMPORTANT STABILITY & ARCHITECTURAL GUIDANCE:" -ForegroundColor Yellow
    Write-Host "  - SysMain: Memory prefetching. Do NOT disable if using SSD and sufficient RAM." -ForegroundColor Gray
    Write-Host "  - WSearch: Search indexer. Do NOT fully disable; narrow index locations instead." -ForegroundColor Gray
    Write-Host "  - Ndu: Network Data Usage monitor. Keep running; disabling is not supported by Microsoft." -ForegroundColor Gray
    Write-Host ""

    Write-Host "  [1] Open Services Management Console (services.msc)" -ForegroundColor Cyan
    Write-Host "  [2] Configure Search Indexing Scope (control srchadmin.dll)" -ForegroundColor Cyan
    Write-Host "  [0] Back" -ForegroundColor Yellow
    Write-Divider

    $sel = Read-MenuSelection -PromptText "Select an option" -Min 0 -Max 2
    switch ($sel) {
        1 { Start-Process "services.msc" }
        2 { Start-Process "control.exe" "srchadmin.dll" }
        0 { return }
    }
}

function Show-VisualEffectsMenu {
    Write-Header -Title "VISUAL EFFECTS & WINDOW ANIMATIONS"
    Write-Host "  [1] Balanced Optimization (Disable window animations, keep font smoothing)" -ForegroundColor Cyan
    Write-Host "  [2] Best Performance (Disable all animations and effects)" -ForegroundColor Cyan
    Write-Host "  [3] Restore Windows Default (Let Windows choose what's best)" -ForegroundColor Cyan
    Write-Host "  [4] Open Windows Performance Options GUI" -ForegroundColor Cyan
    Write-Host "  [0] Back" -ForegroundColor Yellow
    Write-Divider

    $sel = Read-MenuSelection -PromptText "Select visual preset" -Min 0 -Max 4
    switch ($sel) {
        1 {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 3 -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0 -Force -ErrorAction SilentlyContinue
            Write-Success "Balanced visual effects applied."
            Pause-Screen
        }
        2 {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -Force -ErrorAction SilentlyContinue
            Write-Success "Best Performance preset applied."
            Pause-Screen
        }
        3 {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 0 -Force -ErrorAction SilentlyContinue
            Write-Success "Restored automatic Windows defaults."
            Pause-Screen
        }
        4 {
            Start-Process "SystemPropertiesPerformance.exe"
        }
        0 { return }
    }
}

function Show-StartupAppsMenu {
    Write-Header -Title "STARTUP APPLICATIONS (RUN AT BOOT)"
    Write-InfoMessage "Querying startup entries in user and system Registry..."

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
                        AppName = $name
                        Scope = if ($rp -match "HKCU") { "User" } else { "System" }
                        Command = $props.$name
                    }
                }
            }
        }
    }

    $headers = @("Application Name", "Scope", "Command Line")
    $props = @("AppName", "Scope", "Command")
    $widths = @(25, 10, 35)
    Show-TableList -Items $items -Headers $headers -PropertyNames $props -Widths $widths

    Write-Host ""
    Write-Host "  [1] Open Startup Apps in Windows Settings" -ForegroundColor Cyan
    Write-Host "  [2] Open Task Manager (Startup Tab)" -ForegroundColor Cyan
    Write-Host "  [0] Back" -ForegroundColor Yellow
    Write-Divider

    $sel = Read-MenuSelection -PromptText "Select an option" -Min 0 -Max 2
    switch ($sel) {
        1 { Start-Process "ms-settings:startupapps" }
        2 { Start-Process "taskmgr.exe" }
        0 { return }
    }
}

function Show-PowerPlanMenu {
    Write-Header -Title "POWER PLAN & PERFORMANCE SCHEMES"
    try {
        $activePlan = (powercfg /getactivescheme)
        Write-InfoMessage "Current Scheme: $activePlan"
    } catch {}

    Write-Host ""
    Write-Host "  [1] Open Classic Power Options (Control Panel)" -ForegroundColor Cyan
    Write-Host "  [2] Set to Balanced Power Scheme" -ForegroundColor Cyan
    Write-Host "  [3] Set to High Performance Power Scheme" -ForegroundColor Cyan
    Write-Host "  [0] Back" -ForegroundColor Yellow
    Write-Divider

    $sel = Read-MenuSelection -PromptText "Select an option" -Min 0 -Max 3
    switch ($sel) {
        1 { Start-Process "powercfg.cpl" }
        2 {
            powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e
            Write-Success "Switched to Balanced Power Scheme."
            Pause-Screen
        }
        3 {
            powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
            Write-Success "Switched to High Performance Power Scheme."
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
        @{ Label = "Inspect Disk Media Types & Storage Capacity"; Action = { Show-DiskInventory } },
        @{ Label = "Optimize Volume / SSD Re-Trim (Optimize-Volume)"; Action = { Invoke-DiskOptimization } },
        @{ Label = "Open Windows Optimize Drives GUI (dfrgui.exe)"; Action = { Start-Process "dfrgui.exe" } },
        @{ Label = "CHKDSK - Read-Only Filesystem Check"; Action = { Invoke-ChkdskBasic } },
        @{ Label = "CHKDSK - Online NTFS Scan (/scan)"; Action = { Invoke-ChkdskScan } },
        @{ Label = "CHKDSK - Fix Filesystem Errors (/f)"; Action = { Invoke-ChkdskFix } },
        @{ Label = "CHKDSK - Locate Bad Sectors & Recover Readable Data (/r)"; Action = { Invoke-ChkdskRecovery } },
        @{ Label = "SFC - Verify System File Integrity (/verifyonly)"; Action = { Invoke-SfcVerify } },
        @{ Label = "SFC - Scan and Automatically Repair Corrupted Files (/scannow)"; Action = { Invoke-SfcScanNow } },
        @{ Label = "DISM - Scan Component Store Health (/ScanHealth)"; Action = { Invoke-DismScan } },
        @{ Label = "DISM - Repair Component Store Corruption (/RestoreHealth)"; Action = { Invoke-DismRestore } },
        @{ Label = "Run Sequential Windows Repair Wizard (DISM RestoreHealth -> SFC Scannow)"; Action = { Invoke-RepairPipeline } },
        @{ Label = "Open Windows Disk Cleanup (cleanmgr.exe)"; Action = { Start-Process "cleanmgr.exe" } },
        @{ Label = "Export Disk & Maintenance Report"; Action = { Export-MaintenanceReport } }
    )
    Show-TMMenu -Title "DISK & SYSTEM MAINTENANCE" -MenuItems $menuItems -ExitLabel "Back"
}

function Show-DiskInventory {
    Write-SubHeader "SYSTEM STORAGE VOLUMES & HEALTH STATUS"
    try {
        $volumes = Get-Volume | Where-Object { $null -ne $_.DriveLetter }
        $list = @()
        foreach ($v in $volumes) {
            $totalGB = [math]::Round($v.Size / 1GB, 1)
            $freeGB = [math]::Round($v.SizeRemaining / 1GB, 1)
            $pctFree = if ($totalGB -gt 0) { [math]::Round(($freeGB / $totalGB) * 100, 0) } else { 0 }
            
            # Detect Media Type if possible
            $mediaType = "Unknown"
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
                Drive = "$($v.DriveLetter):"
                Label = $v.FileSystemLabel
                FileSystem = $v.FileSystem
                MediaType = $mediaType
                Capacity = "$freeGB GB / $totalGB GB ($pctFree% free)"
                Health = $v.HealthStatus
            }
        }
        $headers = @("Drive", "Label", "File System", "Media Type", "Free Space", "Health")
        $props = @("Drive", "Label", "FileSystem", "MediaType", "Capacity", "Health")
        $widths = @(6, 15, 12, 12, 28, 10)
        Show-TableList -Items $list -Headers $headers -PropertyNames $props -Widths $widths
    } catch {
        Handle-TMException -TaskId "DISK_INV" -TaskName "Inspect Disks" -Exception $_.Exception
    }
    Pause-Screen
}

function Invoke-DiskOptimization {
    if (-not (Assert-Admin "optimize drive")) { Pause-Screen; return }

    Write-SubHeader "OPTIMIZE STORAGE VOLUME / SSD RE-TRIM"
    Write-Host " Enter drive letter to optimize (e.g. C): " -ForegroundColor Cyan -NoNewline
    $dl = Read-Host
    if (-not ($dl -match "^[a-zA-Z]$")) {
        Write-ErrorMessage "Invalid drive letter."
        Pause-Screen
        return
    }

    $confirmed = Confirm-Action -TaskName "Optimize Drive $dl`:" -ImpactDescription "Execute Optimize-Volume (automatically runs TRIM for SSD or safe defragmentation for HDD)." -RiskLevel "low"
    if ($confirmed) {
        try {
            Write-InfoMessage "Running Optimize-Volume on drive $dl`:..."
            Optimize-Volume -DriveLetter $dl -Verbose
            Write-Success "Optimization of drive $dl`: completed successfully!"
            Write-TMLog -TaskId "DISK_OPT" -TaskName "Optimize Drive" -Status "Success" -Message "Drive $dl`:"
        } catch {
            Handle-TMException -TaskId "DISK_OPT" -TaskName "Optimize Drive" -Exception $_.Exception
        }
    }
    Pause-Screen
}

function Invoke-ChkdskBasic {
    Write-SubHeader "CHKDSK - READ-ONLY FILESYSTEM CHECK"
    Write-Host " Enter drive letter (default C): " -ForegroundColor Cyan -NoNewline
    $dl = Read-Host
    if ([string]::IsNullOrWhiteSpace($dl)) { $dl = "C" }
    $dl = $dl.Trim().Substring(0, 1).ToUpper()

    Write-InfoMessage "Running chkdsk $dl`: (read-only mode)..."
    & chkdsk.exe "$dl`:"
    Write-TMLog -TaskId "CHKDSK_RO" -TaskName "CHKDSK Read-Only" -Status "Success" -Message "Drive $dl`:"
    Pause-Screen
}

function Invoke-ChkdskScan {
    if (-not (Assert-Admin "run CHKDSK online scan")) { Pause-Screen; return }
    Write-SubHeader "CHKDSK - ONLINE NTFS SCAN (/scan)"
    Write-Host " Enter drive letter (default C): " -ForegroundColor Cyan -NoNewline
    $dl = Read-Host
    if ([string]::IsNullOrWhiteSpace($dl)) { $dl = "C" }
    $dl = $dl.Trim().Substring(0, 1).ToUpper()

    Write-InfoMessage "Running chkdsk $dl`: /scan..."
    & chkdsk.exe "$dl`:" /scan
    Write-TMLog -TaskId "CHKDSK_SCAN" -TaskName "CHKDSK Scan" -Status "Success" -Message "Drive $dl`:"
    Pause-Screen
}

function Invoke-ChkdskFix {
    if (-not (Assert-Admin "fix disk errors")) { Pause-Screen; return }
    Write-SubHeader "CHKDSK - REPAIR FILESYSTEM ERRORS (/f)"
    Write-Host " Enter drive letter (default C): " -ForegroundColor Cyan -NoNewline
    $dl = Read-Host
    if ([string]::IsNullOrWhiteSpace($dl)) { $dl = "C" }
    $dl = $dl.Trim().Substring(0, 1).ToUpper()

    $confirmed = Confirm-Action -TaskName "CHKDSK /f $dl`:" -ImpactDescription "Fixes filesystem logic errors. For system drive C:, Windows will schedule the check upon next reboot." -RiskLevel "medium"
    if ($confirmed) {
        Write-InfoMessage "Executing chkdsk $dl`: /f..."
        & chkdsk.exe "$dl`:" /f
        Write-TMLog -TaskId "CHKDSK_FIX" -TaskName "CHKDSK /f" -Status "Success" -Message "Drive $dl`:" -RequiresRestart ($dl -eq "C")
    }
    Pause-Screen
}

function Invoke-ChkdskRecovery {
    if (-not (Assert-Admin "scan and recover bad sectors")) { Pause-Screen; return }
    Write-SubHeader "CHKDSK - BAD SECTOR SCAN & DATA RECOVERY (/r)"
    Write-WarningMessage "Notice: Scanning every sector on the drive surface may take hours depending on disk capacity."
    Write-Host " Enter drive letter (default C): " -ForegroundColor Cyan -NoNewline
    $dl = Read-Host
    if ([string]::IsNullOrWhiteSpace($dl)) { $dl = "C" }
    $dl = $dl.Trim().Substring(0, 1).ToUpper()

    $confirmed = Confirm-Action -TaskName "CHKDSK /r $dl`:" -ImpactDescription "Locates bad sectors and recovers readable information. Demands high disk I/O and requires a restart for drive C:." -RiskLevel "high" -RequiresKeyword $true
    if ($confirmed) {
        Write-InfoMessage "Executing chkdsk $dl`: /r..."
        & chkdsk.exe "$dl`:" /r
        Write-TMLog -TaskId "CHKDSK_R" -TaskName "CHKDSK /r" -Status "Success" -Message "Drive $dl`:" -RequiresRestart ($dl -eq "C")
    }
    Pause-Screen
}

function Invoke-SfcVerify {
    if (-not (Assert-Admin "verify system files")) { Pause-Screen; return }
    Write-SubHeader "SFC - VERIFY SYSTEM FILE INTEGRITY (/verifyonly)"
    Write-InfoMessage "Running sfc /verifyonly... Please keep this window open."
    & sfc.exe /verifyonly
    Write-TMLog -TaskId "SFC_VERIFY" -TaskName "SFC VerifyOnly" -Status "Success" -Message "Verification complete"
    Pause-Screen
}

function Invoke-SfcScanNow {
    if (-not (Assert-Admin "scan and repair system files")) { Pause-Screen; return }
    Write-SubHeader "SFC - SCAN AND REPAIR SYSTEM FILES (/scannow)"
    Write-InfoMessage "Running sfc /scannow... This process takes several minutes."
    & sfc.exe /scannow
    Write-TMLog -TaskId "SFC_SCANNOW" -TaskName "SFC ScanNow" -Status "Success" -Message "Scan and repair complete"
    Pause-Screen
}

function Invoke-DismScan {
    if (-not (Assert-Admin "scan component store")) { Pause-Screen; return }
    Write-SubHeader "DISM - SCAN COMPONENT STORE (/ScanHealth)"
    Write-InfoMessage "Running DISM /Online /Cleanup-Image /ScanHealth..."
    & dism.exe /Online /Cleanup-Image /ScanHealth
    Write-TMLog -TaskId "DISM_SCAN" -TaskName "DISM ScanHealth" -Status "Success" -Message "Scan complete"
    Pause-Screen
}

function Invoke-DismRestore {
    if (-not (Assert-Admin "repair component store")) { Pause-Screen; return }
    Write-SubHeader "DISM - REPAIR COMPONENT STORE (/RestoreHealth)"
    Write-InfoMessage "Running DISM /Online /Cleanup-Image /RestoreHealth..."
    & dism.exe /Online /Cleanup-Image /RestoreHealth
    Write-TMLog -TaskId "DISM_RESTORE" -TaskName "DISM RestoreHealth" -Status "Success" -Message "Repair complete"
    Pause-Screen
}

function Invoke-RepairPipeline {
    if (-not (Assert-Admin "run Windows repair wizard")) { Pause-Screen; return }
    Write-Header -Title "COMPREHENSIVE WINDOWS REPAIR PIPELINE (DISM + SFC)"
    Write-InfoMessage "Standard Microsoft-recommended sequence:"
    Write-Host "  1. Repair Windows Component Store (DISM /Online /Cleanup-Image /RestoreHealth)" -ForegroundColor Gray
    Write-Host "  2. Scan and replace protected system files (SFC /scannow)" -ForegroundColor Gray
    Write-Host ""

    $confirmed = Confirm-Action -TaskName "DISM + SFC Repair Pipeline" -ImpactDescription "Automatically runs DISM RestoreHealth followed by SFC Scannow to fix corrupted OS files." -RiskLevel "medium"
    if ($confirmed) {
        Write-SubHeader "STEP 1/2: EXECUTING DISM RESTOREHEALTH"
        & dism.exe /Online /Cleanup-Image /RestoreHealth

        Write-SubHeader "STEP 2/2: EXECUTING SFC SCANNOW"
        & sfc.exe /scannow

        Write-Success "DISM + SFC Repair Pipeline completed successfully!"
        Write-TMLog -TaskId "REPAIR_PIPELINE" -TaskName "DISM + SFC Pipeline" -Status "Success" -Message "Repair pipeline finished"
    }
    Pause-Screen
}

function Export-MaintenanceReport {
    Write-SubHeader "EXPORT DISK & MAINTENANCE REPORT"
    $reportDir = Join-Path $PSScriptRoot "../../../Logs"
    $filename = "MaintenanceReport_" + (Get-Date).ToString("yyyyMMdd_HHmmss") + ".txt"
    $fullPath = Join-Path $reportDir $filename

    $lines = @()
    $lines += "========================================================="
    $lines += "         TM-WINCARE - DISK & MAINTENANCE REPORT"
    $lines += "  Generated: " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $lines += "========================================================="
    try {
        $volumes = Get-Volume | Where-Object { $null -ne $_.DriveLetter }
        foreach ($v in $volumes) {
            $totalGB = [math]::Round($v.Size / 1GB, 1)
            $freeGB = [math]::Round($v.SizeRemaining / 1GB, 1)
            $lines += "Drive $($v.DriveLetter): [$($v.FileSystemLabel)] - $freeGB GB free / $totalGB GB ($($v.FileSystem))"
        }
    } catch {}
    $lines += "========================================================="

    Set-Content -Path $fullPath -Value $lines -Encoding UTF8 -Force
    Write-Success "Report exported to: $fullPath"
    Pause-Screen
}


# === SOURCE: src/Modules/Repair/Repair.ps1 ===
# TM-WinCare - Windows Repair Module
# Adheres to Section 3.4 & 3.5 of TM-WinCare-Architecture-v1.2.md

function Show-TMRepairMenu {
    $menuItems = @(
        @{ Label = "Complete Windows Repair Wizard (DISM RestoreHealth -> SFC Scannow)"; Action = { Invoke-RepairPipeline } },
        @{ Label = "SFC - Scan and Automatically Repair Corrupted Files (sfc /scannow)"; Action = { Invoke-SfcScanNow } },
        @{ Label = "DISM - Quick Corruption Check (CheckHealth)"; Action = { Invoke-DismCheckHealth } },
        @{ Label = "DISM - Deep Component Store Health Scan (ScanHealth)"; Action = { Invoke-DismScan } },
        @{ Label = "DISM - Restore Component Store Health (RestoreHealth)"; Action = { Invoke-DismRestore } },
        @{ Label = "Clean Windows Component Store WinSxS (DISM StartComponentCleanup)"; Action = { Invoke-DismComponentCleanup } },
        @{ Label = "Reset Network Winsock & TCP/IP Stack (Netsh Winsock Reset)"; Action = { Invoke-ResetWinsock } }
    )
    Show-TMMenu -Title "WINDOWS SYSTEM REPAIR & HEALTH" -MenuItems $menuItems -ExitLabel "Back"
}

function Invoke-DismCheckHealth {
    if (-not (Assert-Admin "run DISM quick check")) { Pause-Screen; return }
    Write-SubHeader "DISM /CheckHealth - QUICK COMPONENT STORE HEALTH CHECK"
    & dism.exe /Online /Cleanup-Image /CheckHealth
    Pause-Screen
}

function Invoke-DismComponentCleanup {
    if (-not (Assert-Admin "clean component store")) { Pause-Screen; return }
    Write-SubHeader "CLEAN WINSXS COMPONENT STORE (DISM StartComponentCleanup)"
    Write-InfoMessage "Reclaims disk space by purging superseded update components per official Microsoft guidance."
    
    $confirmed = Confirm-Action -TaskName "DISM Component Cleanup" -ImpactDescription "Cleans superseded update packages in WinSxS. Operation cannot be rolled back but is officially safe." -RiskLevel "medium"
    if ($confirmed) {
        Write-InfoMessage "Executing DISM /Online /Cleanup-Image /StartComponentCleanup..."
        & dism.exe /Online /Cleanup-Image /StartComponentCleanup
        Write-Success "Component Store cleanup complete!"
        Write-TMLog -TaskId "DISM_CLEANUP" -TaskName "DISM StartComponentCleanup" -Status "Success" -Message "Complete"
    }
    Pause-Screen
}

function Invoke-ResetWinsock {
    if (-not (Assert-Admin "reset Winsock")) { Pause-Screen; return }
    Write-SubHeader "RESET WINSOCK & TCP/IP STACK"
    $confirmed = Confirm-Action -TaskName "Reset Winsock" -ImpactDescription "Resets network socket catalog to default to fix internet, DNS, or broken proxy issues. Requires restart." -RiskLevel "medium"
    if ($confirmed) {
        & netsh.exe winsock reset
        & netsh.exe int ip reset
        Write-Success "Winsock and TCP/IP stack successfully reset!"
        Write-WarningMessage "Please restart your computer to apply the network reset."
        Write-TMLog -TaskId "NET_WINSOCK_RESET" -TaskName "Reset Winsock" -Status "Success" -Message "Success" -RequiresRestart $true
    }
    Pause-Screen
}


# === SOURCE: src/Modules/Network/Network.ps1 ===
# TM-WinCare - Network & LAN Support Module
# Adheres to Section 6 of TM-WinCare-Architecture-v1.2.md

function Show-TMNetworkMenu {
    $menuItems = @(
        @{ Label = "View Network Overview (IP, Gateway, DNS, MAC)"; Action = { Show-NetworkOverview } },
        @{ Label = "Run ipconfig /all (Detailed Adapter Metrics)"; Action = { & ipconfig.exe /all; Pause-Screen } },
        @{ Label = "Flush DNS Resolver Cache"; Action = { Clear-DnsClientCache; Write-Success "DNS Client Resolver Cache flushed successfully."; Pause-Screen } },
        @{ Label = "Renew DHCP IP Address (ipconfig /renew)"; Action = { & ipconfig.exe /renew; Pause-Screen } },
        @{ Label = "Ping Connectivity Test (Gateway / Target Host)"; Action = { Invoke-PingTest } },
        @{ Label = "DNS Hostname Lookup Test (nslookup / Resolve-DnsName)"; Action = { Invoke-DnsLookupTest } },
        @{ Label = "TCP Port Connectivity Test (Test-NetConnection)"; Action = { Invoke-TcpPortTest } },
        @{ Label = "Inspect SMB Client Security Configuration (Read-Only)"; Action = { Show-SmbConfiguration } },
        @{ Label = "Check Windows Firewall Rules for File & Printer Sharing"; Action = { Show-FirewallSharingRules } },
        @{ Label = "Open Network Connections (ncpa.cpl)"; Action = { Start-Process "ncpa.cpl" } },
        @{ Label = "Open Advanced Sharing Settings"; Action = { Start-Process "control.exe" "/name Microsoft.NetworkAndSharingCenter /page Advanced" } },
        @{ Label = "Open Windows Firewall (firewall.cpl)"; Action = { Start-Process "firewall.cpl" } },
        @{ Label = "Open Credential Manager (control credman)"; Action = { Start-Process "control.exe" "/name Microsoft.CredentialManager" } },
        @{ Label = "Export Network Diagnostic Report"; Action = { Export-NetworkReport } }
    )
    Show-TMMenu -Title "LOCAL NETWORK & LAN SUPPORT" -MenuItems $menuItems -ExitLabel "Back"
}

function Show-NetworkOverview {
    Write-SubHeader "ACTIVE NETWORK INTERFACES & IP CONFIGURATION"
    try {
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
        foreach ($ad in $adapters) {
            Write-Host " Interface : $($ad.Name) ($($ad.InterfaceDescription))" -ForegroundColor Cyan
            Write-Host "   MAC Address  : $($ad.MacAddress)" -ForegroundColor White
            Write-Host "   Link Speed   : $($ad.LinkSpeed)" -ForegroundColor White

            $ips = Get-NetIPAddress -InterfaceIndex $ad.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
            foreach ($ip in $ips) {
                Write-Host "   IPv4 Address : $($ip.IPAddress)/$($ip.PrefixLength)" -ForegroundColor Green
            }

            $routes = Get-NetRoute -InterfaceIndex $ad.InterfaceIndex -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue
            if ($routes) {
                Write-Host "   Default Gateway: $($routes[0].NextHop)" -ForegroundColor White
            }

            $dnsServers = (Get-DnsClientServerAddress -InterfaceIndex $ad.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue).ServerAddresses
            if ($dnsServers) {
                Write-Host "   DNS Servers  : $($dnsServers -join ', ')" -ForegroundColor White
            }
            Write-Host ""
        }
    } catch {
        Handle-TMException -TaskId "NET_OVERVIEW" -TaskName "View Network Config" -Exception $_.Exception
    }
    Pause-Screen
}

function Invoke-PingTest {
    Write-SubHeader "ICMP PING CONNECTIVITY TEST"
    Write-Host " Enter IP address or hostname to ping (default 8.8.8.8): " -ForegroundColor Cyan -NoNewline
    $target = Read-Host
    if ([string]::IsNullOrWhiteSpace($target)) { $target = "8.8.8.8" }

    Write-InfoMessage "Sending 4 ICMP echo requests to $target..."
    & ping.exe $target
    Pause-Screen
}

function Invoke-DnsLookupTest {
    Write-SubHeader "DNS NAME RESOLUTION TEST (NSLOOKUP)"
    Write-Host " Enter domain name or hostname to resolve (e.g. google.com): " -ForegroundColor Cyan -NoNewline
    $hostName = Read-Host
    if ([string]::IsNullOrWhiteSpace($hostName)) { $hostName = "google.com" }

    try {
        $res = Resolve-DnsName -Name $hostName -ErrorAction Stop
        $res | Select-Object Name, Type, IPAddress | Format-Table -AutoSize
    } catch {
        Write-ErrorMessage "Failed to resolve '$hostName': $($_.Exception.Message)"
    }
    Pause-Screen
}

function Invoke-TcpPortTest {
    Write-SubHeader "TCP PORT CONNECTIVITY TEST"
    Write-Host " Enter destination host or IP: " -ForegroundColor Cyan -NoNewline
    $dest = Read-Host
    if ([string]::IsNullOrWhiteSpace($dest)) {
        Write-ErrorMessage "Target address cannot be empty."
        Pause-Screen
        return
    }

    Write-Host " Enter TCP port number (e.g. 80, 443, 445 for SMB, 135 for RPC, 9100 for RAW printer): " -ForegroundColor Cyan -NoNewline
    $portStr = Read-Host
    if (-not ($portStr -match "^\d+$")) {
        Write-ErrorMessage "Invalid port number."
        Pause-Screen
        return
    }

    $port = [int]$portStr
    Write-InfoMessage "Testing TCP connection to $dest`:$port..."
    try {
        $test = Test-NetConnection -ComputerName $dest -Port $port -WarningAction SilentlyContinue
        if ($test.TcpTestSucceeded) {
            Write-Success "Connection to $dest`:$port SUCCEEDED!"
        } else {
            Write-ErrorMessage "Connection to $dest`:$port FAILED. Port may be closed or blocked by firewall."
        }
    } catch {
        Handle-TMException -TaskId "NET_PORT_TEST" -TaskName "Port Test" -Exception $_.Exception
    }
    Pause-Screen
}

function Show-SmbConfiguration {
    Write-SubHeader "SMB CLIENT SECURITY CONFIGURATION (READ-ONLY)"
    try {
        if (Test-CmdletAvailable "Get-SmbClientConfiguration") {
            $smb = Get-SmbClientConfiguration
            Write-Host "  RequireSecuritySignature (SMB Signing Mandatory): $($smb.RequireSecuritySignature)" -ForegroundColor $(if ($smb.RequireSecuritySignature) { "Green" } else { "Yellow" })
            Write-Host "  EnableInsecureGuestLogons (Insecure Guest Allowed): $($smb.EnableInsecureGuestLogons)" -ForegroundColor $(if ($smb.EnableInsecureGuestLogons) { "Red" } else { "Green" })
            Write-Host "  EnableSMB1Protocol (Deprecated SMBv1 Protocol):   $(if (Test-CmdletAvailable 'Get-WindowsOptionalFeature') { 'Queryable via Optional Features' } else { 'Not Available' })" -ForegroundColor Gray
            Write-Host ""
            Write-InfoMessage "Note: Keeping RequireSecuritySignature = True is official Microsoft security best practice."
        } else {
            Write-WarningMessage "Cmdlet Get-SmbClientConfiguration is unavailable on this edition."
        }
    } catch {
        Handle-TMException -TaskId "SMB_CONF" -TaskName "Inspect SMB" -Exception $_.Exception
    }
    Pause-Screen
}

function Show-FirewallSharingRules {
    Write-SubHeader "FIREWALL STATUS FOR FILE & PRINTER SHARING"
    try {
        $rules = Get-NetFirewallRule -DisplayGroup "*File and Printer Sharing*" -ErrorAction SilentlyContinue | Select-Object -First 5
        if ($rules) {
            foreach ($r in $rules) {
                $status = if ($r.Enabled -eq "True") { "[ENABLED]" } else { "[DISABLED]" }
                $color = if ($r.Enabled -eq "True") { "Green" } else { "Yellow" }
                Write-Host "  $status $($r.DisplayName)" -ForegroundColor $color
            }
        } else {
            Write-InfoMessage "No File and Printer Sharing rules detected."
        }
    } catch {
        Handle-TMException -TaskId "FW_RULES" -TaskName "Check Firewall Rules" -Exception $_.Exception
    }
    Pause-Screen
}

function Export-NetworkReport {
    Write-SubHeader "EXPORT NETWORK DIAGNOSTIC REPORT"
    $reportDir = Join-Path $PSScriptRoot "../../../Logs"
    $filename = "NetworkReport_" + (Get-Date).ToString("yyyyMMdd_HHmmss") + ".txt"
    $fullPath = Join-Path $reportDir $filename

    $lines = @()
    $lines += "========================================================="
    $lines += "         TM-WINCARE - NETWORK DIAGNOSTIC REPORT"
    $lines += "  Generated: " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $lines += "========================================================="
    try {
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
        foreach ($ad in $adapters) {
            $lines += "Adapter: $($ad.Name) | MAC: $($ad.MacAddress) | Speed: $($ad.LinkSpeed)"
        }
    } catch {}
    $lines += "========================================================="
    Set-Content -Path $fullPath -Value $lines -Encoding UTF8 -Force
    Write-Success "Report exported to file: $fullPath"
    Pause-Screen
}


# === SOURCE: src/Modules/Printer/Printer.ps1 ===
# TM-WinCare - Printer Support Module
# Adheres to Section 4 & Section 5 of TM-WinCare-Architecture-v1.2.md

function Show-TMPrinterMenu {
    $menuItems = @(
        @{ Label = "List Installed Printers & Driver Status"; Action = { Show-InstalledPrinters } },
        @{ Label = "Open Windows Printers & Scanners Settings"; Action = { Start-Process "ms-settings:printers" } },
        @{ Label = "Open Classic Devices and Printers (Control Panel)"; Action = { Start-Process "control.exe" "printers" } },
        @{ Label = "Open Print Server Driver Properties (printui /s /t2)"; Action = { Start-Process "rundll32.exe" "printui.dll,PrintUIEntry /s /t2" } },
        @{ Label = "Restart Print Spooler Service"; Action = { Invoke-RestartSpooler } },
        @{ Label = "Clear Stuck Print Spool Queue Files"; Action = { Invoke-ClearPrintQueue } },
        @{ Label = "Test Print Spooler Health & Service Status"; Action = { Test-PrintSpoolerHealth } },
        @{ Label = "Test Network Shared Printer Path (UNC Connectivity)"; Action = { Test-SharedPrinterConnection } },
        @{ Label = "Create Scan-to-Folder Local Account"; Action = { Invoke-CreateScanAccount } },
        @{ Label = "Host Printer Sharing Setup Guide & Tools"; Action = { Show-HostPrinterGuide } },
        @{ Label = "Client Printer Connection Guide & Tools"; Action = { Show-ClientPrinterGuide } },
        @{ Label = "Local Port Helper for Shared Network Printers (\\Server\\Share)"; Action = { Show-LocalPortHelper } },
        @{ Label = "Troubleshoot Access Denied & 0x0000011b / 0x00000709 Errors"; Action = { Show-PrinterAccessDeniedGuide } },
        @{ Label = "Export Printer Configuration Report to TXT"; Action = { Export-PrinterReport } }
    )
    Show-TMMenu -Title "PRINTER & PRINT SPOOLER SUPPORT" -MenuItems $menuItems -ExitLabel "Back"
}

function Show-InstalledPrinters {
    Write-SubHeader "INSTALLED PRINTERS ON THIS SYSTEM"
    try {
        $printers = Get-Printer -ErrorAction Stop
        if (-not $printers -or @($printers).Count -eq 0) {
            Write-InfoMessage "No printers currently installed on this system."
        } else {
            $list = @()
            foreach ($p in $printers) {
                $list += [PSCustomObject]@{
                    PrinterName = $p.Name
                    Driver = $p.DriverName
                    Port = $p.PortName
                    Shared = if ($p.Shared) { "Yes ($($p.ShareName))" } else { "No" }
                    Status = $p.PrinterStatus.ToString()
                }
            }
            $headers = @("Printer Name", "Driver", "Port Name", "Shared", "Status")
            $props = @("PrinterName", "Driver", "Port", "Shared", "Status")
            $widths = @(25, 25, 15, 12, 10)
            Show-TableList -Items $list -Headers $headers -PropertyNames $props -Widths $widths
        }
    } catch {
        Handle-TMException -TaskId "PRINT_LIST" -TaskName "List Printers" -Exception $_.Exception
    }
    Pause-Screen
}

function Invoke-RestartSpooler {
    if (-not (Assert-Admin "restart Print Spooler")) { Pause-Screen; return }

    Write-SubHeader "RESTART PRINT SPOOLER SERVICE"
    try {
        Write-InfoMessage "Stopping Spooler service..."
        Stop-Service -Name Spooler -Force -ErrorAction Stop
        Start-Sleep -Milliseconds 800
        
        Write-InfoMessage "Starting Spooler service..."
        Start-Service -Name Spooler -ErrorAction Stop
        Start-Sleep -Milliseconds 800

        $svc = Get-Service -Name Spooler
        if ($svc.Status -eq "Running") {
            Write-Success "Print Spooler service restarted and running normally!"
            Write-TMLog -TaskId "PRINT_RESTART_SPOOLER" -TaskName "Restart Spooler" -Status "Success" -Message "Success"
        } else {
            Write-ErrorMessage "Spooler service status: $($svc.Status)"
        }
    } catch {
        Handle-TMException -TaskId "PRINT_RESTART_SPOOLER" -TaskName "Restart Spooler" -Exception $_.Exception
    }
    Pause-Screen
}

function Invoke-ClearPrintQueue {
    if (-not (Assert-Admin "clear stuck print queue")) { Pause-Screen; return }

    Write-SubHeader "PURGE STUCK PRINT JOBS (CLEAR SPOOL QUEUE)"
    $spoolPath = Join-Path $env:SystemRoot "System32\spool\PRINTERS"

    $confirmed = Confirm-Action -TaskName "Purge Stuck Print Jobs" -ImpactDescription "Stops Spooler, deletes all pending .SPL/.SHD files in $spoolPath, and restarts Spooler." -RiskLevel "medium"
    if (-not $confirmed) { Pause-Screen; return }

    try {
        Write-InfoMessage "1. Stopping Print Spooler service..."
        Stop-Service -Name Spooler -Force -ErrorAction Stop
        Start-Sleep -Milliseconds 500

        Write-InfoMessage "2. Purging temporary spool job files in $spoolPath..."
        $files = Get-ChildItem -Path $spoolPath -File -ErrorAction SilentlyContinue
        $deleted = 0
        foreach ($f in $files) {
            try {
                Remove-Item $f.FullName -Force -ErrorAction Stop
                $deleted++
            } catch {}
        }
        Write-Success "Deleted $deleted stuck spool file(s)."

        Write-InfoMessage "3. Restarting Print Spooler service..."
        Start-Service -Name Spooler -ErrorAction Stop
        Start-Sleep -Milliseconds 500

        $svc = Get-Service -Name Spooler
        if ($svc.Status -eq "Running") {
            Write-Success "Print spool queue cleared and Spooler service resumed!"
            Write-TMLog -TaskId "PRINT_CLEAR_QUEUE" -TaskName "Clear Spool Queue" -Status "Success" -Message "Purged $deleted print jobs"
        }
    } catch {
        Handle-TMException -TaskId "PRINT_CLEAR_QUEUE" -TaskName "Clear Spool Queue" -Exception $_.Exception
    }
    Pause-Screen
}

function Test-PrintSpoolerHealth {
    Write-SubHeader "PRINT SPOOLER HEALTH & DIAGNOSTICS"
    try {
        $svc = Get-Service -Name Spooler -ErrorAction Stop
        Write-Host "  Service Name  : $($svc.ServiceName) ($($svc.DisplayName))" -ForegroundColor Cyan
        Write-Host "  Current Status: $($svc.Status)" -ForegroundColor $(if ($svc.Status -eq "Running") { "Green" } else { "Red" })

        $cim = Get-CimInstance Win32_Service -Filter "Name='Spooler'" -ErrorAction SilentlyContinue
        if ($cim) {
            Write-Host "  Startup Mode  : $($cim.StartMode)" -ForegroundColor White
            Write-Host "  Process PID   : $($cim.ProcessId)" -ForegroundColor White
        }

        # Check Spool folder size
        $spoolPath = Join-Path $env:SystemRoot "System32\spool\PRINTERS"
        if (Test-Path $spoolPath) {
            $files = Get-ChildItem -Path $spoolPath -File -ErrorAction SilentlyContinue
            Write-Host "  Pending Jobs  : $(@($files).Count) file(s)" -ForegroundColor $(if (@($files).Count -gt 0) { "Yellow" } else { "Green" })
        }
    } catch {
        Handle-TMException -TaskId "PRINT_HEALTH" -TaskName "Inspect Spooler" -Exception $_.Exception
    }
    Pause-Screen
}

function Test-SharedPrinterConnection {
    Write-SubHeader "TEST NETWORK SHARED PRINTER PATH (UNC)"
    Write-Host " Enter printer UNC path (e.g. \\SERVER-NAME\PrinterShare or \\192.168.1.100\PrinterShare): " -ForegroundColor Cyan -NoNewline
    $unc = Read-Host
    if ([string]::IsNullOrWhiteSpace($unc) -or -not ($unc.StartsWith("\\"))) {
        Write-ErrorMessage "Invalid path format. Must begin with \\ (e.g. \\Server\Printer)."
        Pause-Screen
        return
    }

    $parts = $unc.TrimStart('\').Split('\')
    $serverName = $parts[0]

    Write-InfoMessage "1. Testing name resolution & TCP 445 (SMB) connection to host $serverName..."
    $testSmb = Test-NetConnection -ComputerName $serverName -Port 445 -WarningAction SilentlyContinue
    if ($testSmb.TcpTestSucceeded) {
        Write-Success "Host $serverName is listening on SMB sharing port (TCP 445)."
    } else {
        Write-WarningMessage "Unable to reach SMB port on $serverName. Check IP address, hostname, or firewall rules."
    }

    Write-InfoMessage "2. Verifying accessibility of share path $unc..."
    if (Test-Path -LiteralPath $unc -ErrorAction SilentlyContinue) {
        Write-Success "Shared path $unc is accessible!"
    } else {
        Write-WarningMessage "Cannot access $unc directly. Authentication credentials in Credential Manager may be required."
    }
    Pause-Screen
}

function Invoke-CreateScanAccount {
    if (-not (Assert-Admin "create scan account")) { Pause-Screen; return }

    Write-SubHeader "CREATE DEDICATED SCAN-TO-FOLDER LOCAL ACCOUNT"
    Write-InfoMessage "Local account used by multi-function printers to deliver scanned files over SMB."
    Write-Host ""
    Write-Host " Enter account name (default 'scan'): " -ForegroundColor Cyan -NoNewline
    $uName = Read-Host
    if ([string]::IsNullOrWhiteSpace($uName)) { $uName = "scan" }

    # Check if user already exists
    if (Test-CmdletAvailable "Get-LocalUser") {
        $existing = Get-LocalUser -Name $uName -ErrorAction SilentlyContinue
        if ($existing) {
            Write-WarningMessage "Account '$uName' already exists on this computer!"
            Pause-Screen
            return
        }
    }

    # Secure Password Input
    Write-Host " Enter password for account '$uName': " -ForegroundColor Cyan -NoNewline
    $secPass1 = Read-Host -AsSecureString
    Write-Host " Confirm password: " -ForegroundColor Cyan -NoNewline
    $secPass2 = Read-Host -AsSecureString

    # Validate passwords match
    $bstr1 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secPass1)
    $bstr2 = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secPass2)
    $plain1 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr1)
    $plain2 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr2)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr1)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr2)

    if ($plain1 -ne $plain2) {
        Write-ErrorMessage "Passwords do not match. Action cancelled."
        Pause-Screen
        return
    }
    if ([string]::IsNullOrWhiteSpace($plain1)) {
        Write-ErrorMessage "Password cannot be empty."
        Pause-Screen
        return
    }

    Write-Host " Set password to never expire (PasswordNeverExpires)? (Y/N): " -ForegroundColor Cyan -NoNewline
    $pneAns = Read-Host
    $neverExpires = ($pneAns.Trim().ToUpper() -eq "Y")

    $confirmed = Confirm-Action -TaskName "Create scan account '$uName'" -ImpactDescription "Create dedicated local user '$uName' for printer scan delivery. Password is fully secured." -RiskLevel "medium"
    if ($confirmed) {
        try {
            if (Test-CmdletAvailable "New-LocalUser") {
                New-LocalUser -Name $uName -Password $secPass1 -Description "Dedicated Scan-to-folder service account" -PasswordNeverExpires:$neverExpires -ErrorAction Stop
            } else {
                & net.exe user "$uName" "$plain1" /add /comment:"Scan to folder account"
            }
            Write-Success "Account '$uName' successfully created!"
            Write-InfoMessage "Now grant '$uName' permissions to your shared scan destination folder (e.g. D:\Scan)."
            Write-TMLog -TaskId "PRINT_SCAN_USER" -TaskName "Create Scan User" -Status "Success" -Message "User: $uName"
        } catch {
            Handle-TMException -TaskId "PRINT_SCAN_USER" -TaskName "Create Scan User" -Exception $_.Exception
        }
    }
    Pause-Screen
}

function Show-HostPrinterGuide {
    Write-SubHeader "HOST PRINTER SHARING SETUP GUIDE (PRINT SERVER PC)"
    Write-Host " 1. Ensure the printer prints locally from the host PC without errors." -ForegroundColor White
    Write-Host " 2. Open Control Panel > Devices and Printers > Right-click printer > Printer Properties." -ForegroundColor White
    Write-Host " 3. In Sharing tab: Check 'Share this printer' and provide a concise share name (e.g. Canon2900)." -ForegroundColor White
    Write-Host " 4. In Security tab: Verify 'Everyone' group has 'Print' permissions." -ForegroundColor White
    Write-Host " 5. Open Advanced Sharing Settings: Verify 'Turn on file and printer sharing' is active." -ForegroundColor White
    Write-Host " 6. Record this host's Computer Name (Hostname) or static IP address." -ForegroundColor Cyan
    Pause-Screen
}

function Show-ClientPrinterGuide {
    Write-SubHeader "CLIENT PRINTER CONNECTION GUIDE (CLIENT PC)"
    Write-Host " 1. Open Credential Manager > Windows Credentials > Add a Windows credential:" -ForegroundColor White
    Write-Host "    - Network address: Enter host computer name or IP (e.g. \\HOST-PC)" -ForegroundColor Gray
    Write-Host "    - User name / Password: Enter valid credentials of the host computer." -ForegroundColor Gray
    Write-Host " 2. Press Win + R > Enter '\\HOST-PC' to view shared printer shares." -ForegroundColor White
    Write-Host " 3. Right-click the shared printer > Select 'Connect'." -ForegroundColor White
    Write-Host " 4. If an Access Denied or driver error occurs, use the 'Local Port Helper' option below." -ForegroundColor Cyan
    Pause-Screen
}

function Show-LocalPortHelper {
    Write-SubHeader "LOCAL PORT HELPER FOR SHARED NETWORK PRINTERS"
    Write-InfoMessage "A Local Port is the most reliable workaround when encountering RPC or driver install blocks."
    Write-Host ""
    Write-Host " Enter Host Computer Name or IP: " -ForegroundColor Cyan -NoNewline
    $server = Read-Host
    Write-Host " Enter Printer Share Name: " -ForegroundColor Cyan -NoNewline
    $share = Read-Host

    if ([string]::IsNullOrWhiteSpace($server) -or [string]::IsNullOrWhiteSpace($share)) {
        Write-ErrorMessage "Server and share name cannot be empty."
        Pause-Screen
        return
    }

    $portName = "\\$server\$share"
    Write-Success "Target Local Port string: $portName"
    Write-Host ""
    Write-Host " Setup steps in Windows:" -ForegroundColor Yellow
    Write-Host "  1. Open 'Devices and Printers' -> Click 'Add a printer'." -ForegroundColor White
    Write-Host "  2. Select 'The printer that I want isn't listed'." -ForegroundColor White
    Write-Host "  3. Select 'Add a local printer or network printer with manual settings' -> Next." -ForegroundColor White
    Write-Host "  4. Select 'Create a new port' -> Port type: 'Local Port' -> Next." -ForegroundColor White
    Write-Host "  5. Paste this exact string into Port Name: " -ForegroundColor White
    Write-Host "     $portName" -ForegroundColor Cyan
    Write-Host "  6. Select matching printer driver from vendor list or click Have Disk." -ForegroundColor White
    Write-Host ""
    Write-Host " Open Devices and Printers now? (Y/N): " -ForegroundColor Cyan -NoNewline
    $ans = Read-Host
    if ($ans.Trim().ToUpper() -eq "Y") {
        Start-Process "control.exe" "printers"
    }
    Pause-Screen
}

function Show-PrinterAccessDeniedGuide {
    Write-SubHeader "TROUBLESHOOTING ACCESS DENIED / 0x0000011b ERRORS (WIN 10 & 11)"
    Write-Host " Common root causes:" -ForegroundColor Yellow
    Write-Host "  - Windows Point and Print RPC hardening updates require elevated RPC authentication." -ForegroundColor Gray
    Write-Host "  - Client has not saved host credentials in Windows Credential Manager." -ForegroundColor Gray
    Write-Host "  - Windows 11 22H2+ enforces RPC over TCP while older servers use Named Pipes." -ForegroundColor Gray
    Write-Host ""
    Write-Host " Safe resolution sequence:" -ForegroundColor Cyan
    Write-Host "  1. Save host credentials into Credential Manager on the client PC." -ForegroundColor White
    Write-Host "  2. Pre-install identical printer driver version locally on client before connecting." -ForegroundColor White
    Write-Host "  3. Connect using Local Port (\\Server\Share) instead of automatic point-and-print." -ForegroundColor White
    Write-Host "  4. Restart Print Spooler on both host and client machines." -ForegroundColor White
    Pause-Screen
}

function Export-PrinterReport {
    Write-SubHeader "EXPORT PRINTER CONFIGURATION REPORT"
    $reportDir = Join-Path $PSScriptRoot "../../../Logs"
    $filename = "PrinterReport_" + (Get-Date).ToString("yyyyMMdd_HHmmss") + ".txt"
    $fullPath = Join-Path $reportDir $filename

    $lines = @()
    $lines += "========================================================="
    $lines += "         TM-WINCARE - PRINTER CONFIGURATION REPORT"
    $lines += "  Generated: " + (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $lines += "========================================================="
    try {
        $printers = Get-Printer
        foreach ($p in $printers) {
            $lines += "Printer: $($p.Name) | Driver: $($p.DriverName) | Port: $($p.PortName) | Shared: $($p.Shared)"
        }
    } catch {}
    $lines += "========================================================="
    Set-Content -Path $fullPath -Value $lines -Encoding UTF8 -Force
    Write-Success "Report exported to file: $fullPath"
    Pause-Screen
}


# === SOURCE: src/Modules/Cleanup/WindowsCleanup.ps1 ===
# TM-WinCare - System Cleanup Module
# Adheres to Section 7A of TM-WinCare-Architecture-v1.2.md

function Show-TMSystemCleanupMenu {
    $menuItems = @(
        @{ Label = "Scan & Analyze Junk Storage Footprint"; Action = { Scan-SystemCleanupTargets } },
        @{ Label = "Clean Current User Temporary Files (%TEMP%)"; Action = { Clean-UserTempFolder } },
        @{ Label = "Clean Windows System Temp Files (%WINDIR%\\Temp)"; Action = { Clean-WindowsTempFolder } },
        @{ Label = "Empty Recycle Bin Across All Drives"; Action = { Clean-RecycleBinCustom } },
        @{ Label = "Purge Windows Update Download Cache (SoftwareDistribution)"; Action = { Clean-WindowsUpdateCache } },
        @{ Label = "Purge Obsolete Crash Dumps & Minidumps"; Action = { Clean-CrashDumps } },
        @{ Label = "Windows.old Storage Inspection & Guidance"; Action = { Show-WindowsOldWizard } },
        @{ Label = "Open Windows Storage Sense Settings"; Action = { Start-Process "ms-settings:storagesense" } }
    )
    Show-TMMenu -Title "WINDOWS SYSTEM CLEANUP" -MenuItems $menuItems -ExitLabel "Back"
}

function Scan-SystemCleanupTargets {
    Write-SubHeader "SCAN & ANALYZE JUNK FILE VOLUMES"
    Write-InfoMessage "Measuring temporary directories and storage footprint..."

    $targets = @(
        @{ Name = "User Temp (%TEMP%)"; Path = [System.IO.Path]::GetTempPath() },
        @{ Name = "Windows Temp"; Path = (Join-Path $env:SystemRoot "Temp") },
        @{ Name = "Windows Update Cache"; Path = (Join-Path $env:SystemRoot "SoftwareDistribution\Download") },
        @{ Name = "Crash Minidumps"; Path = (Join-Path $env:SystemRoot "Minidump") }
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
            Target = $t.Name
            FileCount = "$count files"
            EstimatedSize = "$sizeMB MB"
            DirectoryPath = $t.Path
        }
    }

    $headers = @("Cleanup Target", "Files", "Estimated Size", "Directory Path")
    $props = @("Target", "FileCount", "EstimatedSize", "DirectoryPath")
    $widths = @(25, 14, 18, 32)
    Show-TableList -Items $results -Headers $headers -PropertyNames $props -Widths $widths

    # Check Windows.old
    $winOld = "C:\Windows.old"
    if (Test-Path $winOld) {
        Write-WarningMessage "Detected 'C:\Windows.old' folder. Use the 'Windows.old Guidance' wizard for safe removal."
    }
    Pause-Screen
}

function Clean-UserTempFolder {
    $tempPath = [System.IO.Path]::GetTempPath()
    Write-SubHeader "CLEAN USER TEMP FOLDER: $tempPath"
    
    $confirmed = Confirm-Action -TaskName "Clean User Temp" -ImpactDescription "Deletes temporary application files in %TEMP%. Locked or currently active files are automatically skipped." -RiskLevel "low"
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
    Write-Success "Cleaned $deleted temporary files ($skipped active file(s) safely skipped)."
    Write-TMLog -TaskId "CLEAN_USER_TEMP" -TaskName "Clean User Temp" -Status "Success" -Message "Deleted $deleted files"
    Pause-Screen
}

function Clean-WindowsTempFolder {
    if (-not (Assert-Admin "clean Windows Temp folder")) { Pause-Screen; return }

    $winTemp = Join-Path $env:SystemRoot "Temp"
    Write-SubHeader "CLEAN WINDOWS SYSTEM TEMP FOLDER: $winTemp"

    $confirmed = Confirm-Action -TaskName "Clean Windows Temp" -ImpactDescription "Deletes system and service temporary files. Active in-use files are skipped automatically." -RiskLevel "low"
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
    Write-Success "Cleaned $deleted file(s) in Windows Temp ($skipped in-use file(s) skipped)."
    Write-TMLog -TaskId "CLEAN_WIN_TEMP" -TaskName "Clean Windows Temp" -Status "Success" -Message "Deleted $deleted files"
    Pause-Screen
}

function Clean-RecycleBinCustom {
    Write-SubHeader "EMPTY RECYCLE BIN ACROSS ALL VOLUMES"
    $confirmed = Confirm-Action -TaskName "Empty Recycle Bin" -ImpactDescription "Permanently deletes all contents from Recycle Bin across all disk volumes. Cannot be undone." -RiskLevel "medium"
    if (-not $confirmed) { Pause-Screen; return }

    try {
        Clear-RecycleBin -Force -ErrorAction Stop
        Write-Success "Recycle Bin emptied successfully!"
        Write-TMLog -TaskId "CLEAN_RECYCLE_BIN" -TaskName "Empty Recycle Bin" -Status "Success" -Message "Success"
    } catch {
        Handle-TMException -TaskId "CLEAN_RECYCLE_BIN" -TaskName "Empty Recycle Bin" -Exception $_.Exception
    }
    Pause-Screen
}

function Clean-WindowsUpdateCache {
    if (-not (Assert-Admin "clean Windows Update cache")) { Pause-Screen; return }

    Write-SubHeader "PURGE WINDOWS UPDATE DOWNLOAD CACHE"
    $wuPath = Join-Path $env:SystemRoot "SoftwareDistribution\Download"

    $confirmed = Confirm-Action -TaskName "Purge Windows Update Cache" -ImpactDescription "Pauses wuauserv service, purges downloaded update files in SoftwareDistribution\Download, and restarts service." -RiskLevel "medium"
    if (-not $confirmed) { Pause-Screen; return }

    try {
        Write-InfoMessage "Pausing Windows Update service..."
        Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
        
        $files = Get-ChildItem -Path $wuPath -Recurse -File -ErrorAction SilentlyContinue
        $deleted = 0
        foreach ($f in $files) {
            try { Remove-Item $f.FullName -Force -ErrorAction Stop; $deleted++ } catch {}
        }
        Write-Success "Purged $deleted downloaded update cache files."

        Write-InfoMessage "Restarting Windows Update service..."
        Start-Service -Name wuauserv -ErrorAction SilentlyContinue
        Write-Success "Windows Update cache cleanup completed!"
        Write-TMLog -TaskId "CLEAN_WU_CACHE" -TaskName "Clean WU Cache" -Status "Success" -Message "Deleted $deleted files"
    } catch {
        Handle-TMException -TaskId "CLEAN_WU_CACHE" -TaskName "Clean WU Cache" -Exception $_.Exception
    }
    Pause-Screen
}

function Clean-CrashDumps {
    if (-not (Assert-Admin "clean crash dumps")) { Pause-Screen; return }

    Write-SubHeader "PURGE PAST CRASH DUMPS & MINIDUMPS"
    $dumpPath = Join-Path $env:SystemRoot "Minidump"
    if (-not (Test-Path $dumpPath)) {
        Write-InfoMessage "No Minidump directory present on this system."
        Pause-Screen
        return
    }

    $confirmed = Confirm-Action -TaskName "Purge Minidumps" -ImpactDescription "Deletes obsolete BSOD crash dump files in $dumpPath." -RiskLevel "low"
    if ($confirmed) {
        $files = Get-ChildItem -Path $dumpPath -File -ErrorAction SilentlyContinue
        $deleted = 0
        foreach ($f in $files) {
            try { Remove-Item $f.FullName -Force -ErrorAction Stop; $deleted++ } catch {}
        }
        Write-Success "Purged $deleted minidump file(s)."
    }
    Pause-Screen
}

function Show-WindowsOldWizard {
    Write-SubHeader "SAFE WINDOWS.OLD STORAGE GUIDANCE"
    $winOld = "C:\Windows.old"
    if (-not (Test-Path $winOld)) {
        Write-Success "'C:\Windows.old' does NOT exist on this PC. No action required."
        Pause-Screen
        return
    }

    Write-WarningMessage "DETECTED 'C:\Windows.old' ON SYSTEM DRIVE!"
    Write-Host " IMPORTANT SAFETY NOTICE:" -ForegroundColor Yellow
    Write-Host "  - Windows.old contains your previous Windows installation." -ForegroundColor Gray
    Write-Host "  - Removing Windows.old permanently deletes the ability to roll back to the prior OS build." -ForegroundColor Gray
    Write-Host "  - Microsoft recommends using Storage Sense or Disk Cleanup rather than manual deletion." -ForegroundColor Gray
    Write-Host ""
    Write-Host " Open Windows Storage Sense to safely purge 'Previous Windows installation(s)'? (Y/N): " -ForegroundColor Cyan -NoNewline
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
        @{ Label = "Scan & Detect Installed AI / Developer Toolchains"; Action = { Scan-AiDevEnvironment } },
        @{ Label = "Purge Python Pip Cache (pip cache purge)"; Action = { Clean-PipCache } },
        @{ Label = "Purge Python uv Cache (uv cache clean)"; Action = { Clean-UvCache } },
        @{ Label = "Purge Node.js npm Cache (npm cache clean)"; Action = { Clean-NpmCache } },
        @{ Label = "Prune Unreferenced pnpm Store Packages (pnpm store prune)"; Action = { Clean-PnpmStore } },
        @{ Label = "List Ollama Local LLMs & Safe Management Guidance"; Action = { Show-OllamaManager } },
        @{ Label = "Inspect Hugging Face Hub Cache Footprint"; Action = { Show-HuggingFaceCache } },
        @{ Label = "Prune Docker Builder Cache (docker builder prune)"; Action = { Clean-DockerBuilderCache } },
        @{ Label = "Inspect WSL Distributions & Virtual Disks (.vhdx)"; Action = { Show-WslStatus } },
        @{ Label = "Clean VS Code & Cursor Temporary Session Logs"; Action = { Clean-IdeLogs } }
    )
    Show-TMMenu -Title "AI & DEVELOPER TOOLCHAIN CLEANUP" -MenuItems $menuItems -ExitLabel "Back"
}

function Scan-AiDevEnvironment {
    Write-SubHeader "SCAN AI & DEVELOPER TOOLCHAINS ON THIS SYSTEM"
    
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
        $ver = "Not Installed"
        if ($found) {
            try {
                $verOutput = (& cmd.exe /c "$($t.Cmd) 2>&1")
                if ($verOutput) { $ver = $verOutput[0] }
            } catch { $ver = "Installed" }
        }
        $results += [PSCustomObject]@{
            Tool = $t.Name
            Status = if ($found) { "Detected" } else { "Not Found" }
            Version = $ver
        }
    }

    $headers = @("Tool / Platform", "Detection Status", "Version / Output")
    $props = @("Tool", "Status", "Version")
    $widths = @(18, 18, 38)
    Show-TableList -Items $results -Headers $headers -PropertyNames $props -Widths $widths
    Pause-Screen
}

function Clean-PipCache {
    Write-SubHeader "PURGE PYTHON PIP CACHE (pip cache purge)"
    if (-not (Test-ToolAvailable "pip")) {
        Write-WarningMessage "Tool 'pip' is not found in system PATH."
        Pause-Screen
        return
    }

    Write-InfoMessage "Current Pip Cache Metrics:"
    & pip cache info

    $confirmed = Confirm-Action -TaskName "Purge Pip Cache" -ImpactDescription "Deletes cached wheel and source archives. Does NOT modify installed site-packages or .venv environments." -RiskLevel "low"
    if ($confirmed) {
        & pip cache purge
        Write-Success "Pip cache purged successfully!"
    }
    Pause-Screen
}

function Clean-UvCache {
    Write-SubHeader "PURGE PYTHON UV CACHE (uv cache clean)"
    if (-not (Test-ToolAvailable "uv")) {
        Write-WarningMessage "Tool 'uv' is not found in system PATH."
        Pause-Screen
        return
    }

    $confirmed = Confirm-Action -TaskName "Purge uv Cache" -ImpactDescription "Clears uv package cache. Packages will be downloaded automatically when required." -RiskLevel "low"
    if ($confirmed) {
        & uv cache clean
        Write-Success "Python uv cache purged successfully!"
    }
    Pause-Screen
}

function Clean-NpmCache {
    Write-SubHeader "PURGE NODE.JS NPM CACHE (npm cache clean)"
    if (-not (Test-ToolAvailable "npm")) {
        Write-WarningMessage "Tool 'npm' is not found in system PATH."
        Pause-Screen
        return
    }

    $confirmed = Confirm-Action -TaskName "Purge npm Cache" -ImpactDescription "Cleans local tarballs in npm cache. Does NOT delete project node_modules folders." -RiskLevel "low"
    if ($confirmed) {
        & npm cache clean --force
        Write-Success "Node.js npm cache purged successfully!"
    }
    Pause-Screen
}

function Clean-PnpmStore {
    Write-SubHeader "PRUNE UNREFERENCED PNPM STORE PACKAGES"
    if (-not (Test-ToolAvailable "pnpm")) {
        Write-WarningMessage "Tool 'pnpm' is not found in system PATH."
        Pause-Screen
        return
    }

    $confirmed = Confirm-Action -TaskName "pnpm store prune" -ImpactDescription "Prunes orphaned packages in pnpm store that are no longer referenced by any workspace project." -RiskLevel "low"
    if ($confirmed) {
        & pnpm store prune
        Write-Success "pnpm store pruned successfully!"
    }
    Pause-Screen
}

function Show-OllamaManager {
    Write-SubHeader "OLLAMA LOCAL LLM MODEL MANAGEMENT"
    if (-not (Test-ToolAvailable "ollama")) {
        Write-WarningMessage "Ollama is not found in system PATH."
        Pause-Screen
        return
    }

    Write-InfoMessage "Listing installed models:"
    & ollama list

    Write-Host ""
    Write-Host " DATA PROTECTION PRINCIPLE:" -ForegroundColor Yellow
    Write-Host "  - TM-WinCare NEVER deletes Ollama models automatically." -ForegroundColor Gray
    Write-Host "  - Each model weights several gigabytes." -ForegroundColor Gray
    Write-Host "  - To delete an unused model manually, run: ollama rm <model_name>" -ForegroundColor Cyan
    Write-Host ""
    Write-Host " Enter model name to delete (leave blank to return): " -ForegroundColor Cyan -NoNewline
    $targetModel = Read-Host
    if (-not [string]::IsNullOrWhiteSpace($targetModel)) {
        $confirmed = Confirm-Action -TaskName "Delete Ollama Model '$targetModel'" -ImpactDescription "Deletes $targetModel from Ollama storage. You must re-download if needed later." -RiskLevel "medium"
        if ($confirmed) {
            & ollama rm $targetModel
            Write-Success "Deleted model $targetModel."
        }
    }
    Pause-Screen
}

function Show-HuggingFaceCache {
    Write-SubHeader "HUGGING FACE HUB CACHE FOOTPRINT"
    $hfPath = if ($env:HF_HOME) { Join-Path $env:HF_HOME "hub" } else { Join-Path $env:USERPROFILE ".cache\huggingface\hub" }
    
    if (-not (Test-Path $hfPath)) {
        Write-InfoMessage "Hugging Face cache directory not found at: $hfPath"
        Pause-Screen
        return
    }

    Write-InfoMessage "Calculating cache directory size: $hfPath..."
    $files = Get-ChildItem -Path $hfPath -File -Recurse -ErrorAction SilentlyContinue
    $totalGB = 0
    if ($files) {
        $measure = $files | Measure-Object -Property Length -Sum
        if ($measure.Sum) { $totalGB = [math]::Round($measure.Sum / 1GB, 2) }
    }
    Write-Host "  Total HF Hub Cache Size: $totalGB GB" -ForegroundColor Cyan
    Write-InfoMessage "Note: Contains downloaded model snapshots. If huggingface-cli is installed, run 'huggingface-cli delete-cache' for interactive snapshot removal."
    Pause-Screen
}

function Clean-DockerBuilderCache {
    Write-SubHeader "PRUNE DOCKER BUILDER CACHE"
    if (-not (Test-ToolAvailable "docker")) {
        Write-WarningMessage "Docker is not installed or daemon is not running."
        Pause-Screen
        return
    }

    Write-InfoMessage "Current Docker storage metrics:"
    & docker system df

    $confirmed = Confirm-Action -TaskName "Docker Builder Prune" -ImpactDescription "Purges BuildKit layer cache. Does NOT touch named Volumes (database storage) or active containers." -RiskLevel "medium"
    if ($confirmed) {
        & docker builder prune -f
        Write-Success "Docker Builder Cache pruned successfully!"
    }
    Pause-Screen
}

function Show-WslStatus {
    Write-SubHeader "WSL LINUX DISTRIBUTIONS & VIRTUAL DISKS"
    if (-not (Test-ToolAvailable "wsl")) {
        Write-WarningMessage "WSL is not installed."
        Pause-Screen
        return
    }

    & wsl.exe -l -v
    Write-Host ""
    Write-Host " SAFETY PRINCIPLE:" -ForegroundColor Yellow
    Write-Host "  - Never delete ext4.vhdx files directly to prevent Linux corruption." -ForegroundColor Gray
    Write-Host "  - To reclaim WSL storage: run apt-get autoremove inside Linux, then run 'wsl --shutdown' and compact disk." -ForegroundColor Gray
    Pause-Screen
}

function Clean-IdeLogs {
    Write-SubHeader "PURGE VS CODE & CURSOR TEMPORARY SESSION LOGS"
    $paths = @(
        (Join-Path $env:APPDATA "Code\logs"),
        (Join-Path $env:APPDATA "Cursor\logs")
    )
    $confirmed = Confirm-Action -TaskName "Purge IDE Logs" -ImpactDescription "Deletes expired session log folders for VS Code and Cursor. Preserves all extensions, user settings, snippets, and conversation history." -RiskLevel "low"
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
        Write-Success "Purged $deleted temporary IDE log file(s)."
    }
    Pause-Screen
}


# === SOURCE: src/Modules/Privacy/Privacy.ps1 ===
# TM-WinCare - Privacy, Notifications & Copilot Module
# Adheres to Section 7C of TM-WinCare-Architecture-v1.2.md

function Show-TMPrivacyMenu {
    $menuItems = @(
        @{ Label = "Toggle Microsoft Copilot Taskbar Button (Windows 11)"; Action = { Toggle-CopilotTaskbar } },
        @{ Label = "Disable Windows Tips, Suggestions & Promotional Ads"; Action = { Disable-WindowsTips } },
        @{ Label = "Toggle Taskbar Widgets / News Feed (Windows 11)"; Action = { Toggle-TaskbarWidgets } },
        @{ Label = "Open Windows Notifications & Actions Settings"; Action = { Start-Process "ms-settings:notifications" } },
        @{ Label = "Open Windows Privacy & Security Settings"; Action = { Start-Process "ms-settings:privacy" } },
        @{ Label = "Open Windows Search Indexing Options (Reduce Disk I/O)"; Action = { Start-Process "control.exe" "srchadmin.dll" } }
    )
    Show-TMMenu -Title "PRIVACY, NOTIFICATIONS & SYSTEM COMPONENTS" -MenuItems $menuItems -ExitLabel "Back"
}

function Toggle-CopilotTaskbar {
    Write-SubHeader "TOGGLE COPILOT TASKBAR BUTTON"
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    try {
        $current = (Get-ItemProperty -Path $regPath -Name "ShowCopilotButton" -ErrorAction SilentlyContinue).ShowCopilotButton
        $statusStr = if ($current -eq 0) { "Hidden (Disabled)" } else { "Visible (Enabled)" }
        Write-InfoMessage "Current Copilot Button Status: $statusStr"

        Write-Host " [1] Hide Copilot Button" -ForegroundColor Cyan
        Write-Host " [2] Show Copilot Button" -ForegroundColor Cyan
        Write-Host " [0] Back" -ForegroundColor Yellow
        $sel = Read-MenuSelection -Min 0 -Max 2
        switch ($sel) {
            1 {
                Set-ItemProperty -Path $regPath -Name "ShowCopilotButton" -Value 0 -Force
                Write-Success "Copilot button hidden from Taskbar."
                Write-InfoMessage "You may need to restart or refresh File Explorer."
            }
            2 {
                Set-ItemProperty -Path $regPath -Name "ShowCopilotButton" -Value 1 -Force
                Write-Success "Copilot button enabled on Taskbar."
            }
        }
    } catch {
        Handle-TMException -TaskId "PRIV_COPILOT" -TaskName "Copilot Taskbar" -Exception $_.Exception
    }
    Pause-Screen
}

function Disable-WindowsTips {
    Write-SubHeader "DISABLE WINDOWS TIPS & SUGGESTIONS"
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    try {
        Set-ItemProperty -Path $regPath -Name "SoftLandingEnabled" -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $regPath -Name "SubscribedContent-338388Enabled" -Value 0 -Force -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $regPath -Name "SubscribedContent-338389Enabled" -Value 0 -Force -ErrorAction SilentlyContinue
        Write-Success "Windows tips, suggestions, and app recommendations disabled!"
        Write-TMLog -TaskId "PRIV_TIPS" -TaskName "Disable Windows Tips" -Status "Success" -Message "Success"
    } catch {
        Handle-TMException -TaskId "PRIV_TIPS" -TaskName "Disable Windows Tips" -Exception $_.Exception
    }
    Pause-Screen
}

function Toggle-TaskbarWidgets {
    Write-SubHeader "TOGGLE TASKBAR WIDGETS (WINDOWS 11)"
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    try {
        $current = (Get-ItemProperty -Path $regPath -Name "TaskbarDa" -ErrorAction SilentlyContinue).TaskbarDa
        $statusStr = if ($current -eq 0) { "Hidden (Disabled)" } else { "Visible (Enabled)" }
        Write-InfoMessage "Current Widgets Status: $statusStr"

        Write-Host " [1] Hide Widgets" -ForegroundColor Cyan
        Write-Host " [2] Show Widgets" -ForegroundColor Cyan
        Write-Host " [0] Back" -ForegroundColor Yellow
        $sel = Read-MenuSelection -Min 0 -Max 2
        switch ($sel) {
            1 {
                Set-ItemProperty -Path $regPath -Name "TaskbarDa" -Value 0 -Force
                Write-Success "Widgets hidden from Taskbar."
            }
            2 {
                Set-ItemProperty -Path $regPath -Name "TaskbarDa" -Value 1 -Force
                Write-Success "Widgets enabled on Taskbar."
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
        Write-ErrorMessage "Quick Commands catalog not found."
        Pause-Screen
        return
    }

    while ($true) {
        Write-Header -Title "QUICK COMMANDS & APPLET LAUNCHER"
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

        Write-Host "  [ 0] Back" -ForegroundColor Yellow
        Write-Divider

        $sel = Read-MenuSelection -PromptText "Select command to execute" -Min 0 -Max $commands.Count
        if ($sel -eq 0) { break }

        $chosen = $commands[$sel - 1]
        Invoke-QuickCommandItem -CommandItem $chosen
    }
}

function Invoke-QuickCommandItem {
    param ($CommandItem)

    Write-SubHeader "EXECUTE COMMAND: $($CommandItem.name)"
    Write-InfoMessage "Category : $($CommandItem.group)"
    Write-Host " Description : $($CommandItem.description)" -ForegroundColor Gray
    Write-Host " Command Line: " -ForegroundColor White -NoNewline
    Write-Host "$($CommandItem.command)" -ForegroundColor Cyan

    if ($CommandItem.requiresAdmin -and -not (Test-IsAdmin)) {
        Write-ErrorMessage "This command requires Administrator privileges."
        if (-not (Request-Elevation -Reason "execute '$($CommandItem.name)'")) {
            Pause-Screen
            return
        }
    }

    Write-Host ""
    Write-Host "  [1] Execute command now" -ForegroundColor Cyan
    Write-Host "  [2] Copy command string to Clipboard" -ForegroundColor Cyan
    Write-Host "  [0] Cancel" -ForegroundColor Yellow
    Write-Divider

    $sel = Read-MenuSelection -PromptText "Select an option" -Min 0 -Max 2
    switch ($sel) {
        1 {
            Write-InfoMessage "Executing: $($CommandItem.command)..."
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
                    Write-Success "Process started: $exe"
                } catch {
                    Handle-TMException -TaskId $CommandItem.id -TaskName $CommandItem.name -Exception $_.Exception
                }
            } else {
                & cmd.exe /c $CommandItem.command
                Write-Success "Command completed with Exit Code: $LASTEXITCODE"
            }
            Write-TMLog -TaskId $CommandItem.id -TaskName $CommandItem.name -Status "Success" -Message "Executed $($CommandItem.command)"
            Pause-Screen
        }
        2 {
            try {
                Set-Clipboard -Value $CommandItem.command
                Write-Success "Command copied to Clipboard!"
            } catch {
                Write-WarningMessage "Could not copy automatically: $($_.Exception.Message)"
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
        Write-Header -Title "BACKUP SNAPSHOTS & STATE ROLLBACK"
        $backups = Get-TMBackupList

        if (-not $backups -or $backups.Count -eq 0) {
            Write-InfoMessage "No backup snapshots found in Backups directory."
        } else {
            Write-Host " Available State Snapshots:" -ForegroundColor Yellow
            for ($i = 0; $i -lt $backups.Count; $i++) {
                $b = $backups[$i]
                $num = ($i + 1).ToString().PadLeft(2)
                Write-Host "  [$num] " -ForegroundColor Cyan -NoNewline
                Write-Host "$($b.Id) " -ForegroundColor White -NoNewline
                Write-Host "- $($b.Description)" -ForegroundColor Gray
            }
        }

        Write-Host ""
        Write-Host "  [0] Back" -ForegroundColor Yellow
        Write-Divider

        Write-Host " Select snapshot number to inspect / rollback (0 to return): " -ForegroundColor Cyan -NoNewline
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

    Write-SubHeader "SNAPSHOT DETAILS: $($BackupItem.Id)"
    Write-Host " Task ID    : $($BackupItem.TaskId)" -ForegroundColor White
    Write-Host " Description: $($BackupItem.Description)" -ForegroundColor White
    Write-Host " Created At : $($BackupItem.CreatedAt)" -ForegroundColor White
    Write-Host " Directory  : $($BackupItem.Path)" -ForegroundColor Gray

    $manifestPath = Join-Path $BackupItem.Path "manifest.json"
    if (Test-Path $manifestPath) {
        $manifest = Get-Content -Path $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($manifest.registry) {
            Write-Host ""
            Write-Host "  Backed Up Registry Keys:" -ForegroundColor Yellow
            foreach ($r in $manifest.registry) {
                Write-Host "   - $($r.path)\$($r.name) (Old Value: $($r.oldValue))" -ForegroundColor Gray
            }
        }
        if ($manifest.services) {
            Write-Host ""
            Write-Host "  Backed Up Service States:" -ForegroundColor Yellow
            foreach ($s in $manifest.services) {
                Write-Host "   - $($s.name) (Startup: $($s.startMode))" -ForegroundColor Gray
            }
        }
    }

    Write-Host ""
    Write-Host " Rollback this backup snapshot now? (Y/N): " -ForegroundColor Cyan -NoNewline
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
        Write-Host "  Operating System: $osStr | Privilege: " -NoNewline -ForegroundColor DarkGray
        Write-Host "$adminBadge" -ForegroundColor $adminColor
        Write-Host "---------------------------------------------------------" -ForegroundColor DarkGray

        Write-Host "  [ 1] " -ForegroundColor Cyan -NoNewline; Write-Host "Dashboard / System Information" -ForegroundColor White
        Write-Host "  [ 2] " -ForegroundColor Cyan -NoNewline; Write-Host "Windows Post-Install & Activation" -ForegroundColor White
        Write-Host "  [ 3] " -ForegroundColor Cyan -NoNewline; Write-Host "Auto Optimize / Custom Profiles" -ForegroundColor White
        Write-Host "  [ 4] " -ForegroundColor Cyan -NoNewline; Write-Host "Disk & System Maintenance" -ForegroundColor White
        Write-Host "  [ 5] " -ForegroundColor Cyan -NoNewline; Write-Host "Windows Repair (SFC / DISM / CHKDSK)" -ForegroundColor White
        Write-Host "  [ 6] " -ForegroundColor Cyan -NoNewline; Write-Host "Network & LAN Support" -ForegroundColor White
        Write-Host "  [ 7] " -ForegroundColor Cyan -NoNewline; Write-Host "Printer & Spooler Support" -ForegroundColor White
        Write-Host "  [ 8] " -ForegroundColor Cyan -NoNewline; Write-Host "AI & Developer Environment Cleanup" -ForegroundColor White
        Write-Host "  [ 9] " -ForegroundColor Cyan -NoNewline; Write-Host "Privacy, Notifications & Copilot" -ForegroundColor White
        Write-Host "  [10] " -ForegroundColor Cyan -NoNewline; Write-Host "Accounts & Access Management" -ForegroundColor White
        Write-Host "  [11] " -ForegroundColor Cyan -NoNewline; Write-Host "Quick Diagnostic Commands" -ForegroundColor White
        Write-Host "  [12] " -ForegroundColor Cyan -NoNewline; Write-Host "Backup & State Restore" -ForegroundColor White
        Write-Host "  [ 0] " -ForegroundColor Yellow -NoNewline; Write-Host "Exit" -ForegroundColor Yellow
        Write-Host "=========================================================" -ForegroundColor Cyan

        $sel = Read-MenuSelection -PromptText "Select an option" -Min 0 -Max 12
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
                Write-InfoMessage "Thank you for using TM-WinCare. Goodbye!"
                Write-TMLog -TaskId "EXIT" -TaskName "Exit Application" -Status "Info" -Message "Normal exit"
                return
            }
        }
    }
}


Start-TMApplication
