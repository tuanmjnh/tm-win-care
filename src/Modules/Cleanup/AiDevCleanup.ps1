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
