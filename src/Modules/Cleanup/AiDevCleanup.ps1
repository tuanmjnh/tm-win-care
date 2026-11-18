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
