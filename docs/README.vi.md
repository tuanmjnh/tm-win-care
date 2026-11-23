# TM-WinCare – Windows Optimization & Maintenance Toolkit

[![GitHub Release](https://img.shields.io/github/v/release/tuanmjnh/tm-win-care?style=flat-square&color=blue)](https://github.com/tuanmjnh/tm-win-care/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D6?style=flat-square&logo=windows)](https://microsoft.com/windows)

> **TM Windows Support** | Phiên bản: **1.2.0** | Ngày phát hành: **18/11/2026**  
> Nền tảng mục tiêu: **Windows 10** và **Windows 11** (Home / Pro / Enterprise)

TM-WinCare là bộ công cụ dòng lệnh (Console Toolkit) tiện ích, chạy trực tiếp trên Windows mà không cần cài đặt phần mềm bên ngoài, không cần database và hoạt động độc lập ngay cả khi máy tính offline. Công cụ tập trung vào việc hậu cài đặt Windows, tối ưu hóa an toàn, khắc phục lỗi hệ thống và xử lý nhanh các tác vụ máy in, mạng LAN nội bộ cho kỹ thuật viên IT.

---

## ⚡ Hướng dẫn sử dụng & Khởi chạy nhanh

### Cách 1: PowerShell Online One-Liner ❤️ (Khuyến nghị)

Không cần tải về hay giải nén, chỉ cần mở PowerShell và dán câu lệnh:

#### 🔹 1. Khởi chạy toàn bộ bộ công cụ TM-WinCare (12 Module):
```powershell
irm https://raw.githubusercontent.com/tuanmjnh/tm-win-care/main/dist/TM-WinCare-AIO.ps1 | iex
```

*Dự phòng khi bị chặn DNS / ISP:*
```powershell
iex (curl.exe -s --doh-url https://1.1.1.1/dns-query https://raw.githubusercontent.com/tuanmjnh/tm-win-care/main/dist/TM-WinCare-AIO.ps1 | Out-String)
```

#### 🔹 2. Khởi chạy nhanh công cụ Quản lý Bản quyền Windows & Office (IT Inventory Full Key):
Dành riêng cho kỹ thuật viên muốn kiểm tra nhanh Key bản quyền (Full 25 ký tự), Model/Serial máy và đồng bộ lên Google Sheets/Form:
```powershell
irm https://raw.githubusercontent.com/tuanmjnh/tm-win-care/main/dist/Check-License.ps1 | iex
```

*Dự phòng khi bị chặn DNS / ISP:*
```powershell
iex (curl.exe -s --doh-url https://1.1.1.1/dns-query https://raw.githubusercontent.com/tuanmjnh/tm-win-care/main/dist/Check-License.ps1 | Out-String)
```

---

### Cách 2: Tải file chạy đơn All-In-One (Không cần gõ lệnh)

Dành cho người dùng muốn tải sẵn về máy hoặc copy vào USB:

1. Truy cập mục **[Releases](https://github.com/tuanmjnh/tm-win-care/releases/latest)** của dự án.
2. Tải về file:
   - **[`TM-WinCare-AIO.cmd`](https://github.com/tuanmjnh/tm-win-care/releases/latest/download/TM-WinCare-AIO.cmd)**: File đơn duy nhất, tự động nhận diện quyền Admin và chạy menu.
   - Hoặc **[`TM-WinCare-Portable.zip`](https://github.com/tuanmjnh/tm-win-care/releases/latest/download/TM-WinCare-Portable.zip)**: Bộ nén đầy đủ cho kỹ thuật viên mang theo USB đi cứu hộ máy offline.
3. Nhấp đúp chuột vào file `TM-WinCare-AIO.cmd` để bắt đầu.

---

### Cách 3: Chạy từ mã nguồn Git (Offline / Developers)

```powershell
git clone https://github.com/tuanmjnh/tm-win-care.git
cd tm-win-care
.\Start.cmd
```

---

## 1. Triết lý thiết kế (Core Principles)

- **Safe by default**: Mặc định chỉ kiểm tra (Audit/Read-only) hoặc áp dụng các cấu hình an toàn, ít rủi ro.
- **Không tối ưu mù**: Tuyệt đối **không** tự ý tắt Windows Defender, Windows Security, Tường lửa (Firewall), Tamper Protection hay Windows Update.
- **Có giải thích & cảnh báo**: Luôn hiển thị rõ tác dụng, phạm vi ảnh hưởng và yêu cầu khởi động lại trước khi chạy bất kỳ thay đổi nào.
- **Tự động sao lưu & Hỗ trợ hoàn tác (Rollback)**: Tự động xuất Registry key và ghi nhận trạng thái dịch vụ vào thư mục `Backups/` trước khi thay đổi để có thể khôi phục bất cứ lúc nào.
- **Không hard-code mật khẩu**: Khi tạo tài khoản (ví dụ tài khoản scan máy in), hệ thống yêu cầu nhập mật khẩu bảo mật hai lần (`-AsSecureString`), không bao giờ ghi mật khẩu rõ vào log hay code.
- **Bảo vệ dữ liệu AI & Developer**: Phân biệt rạch ròi giữa cache có thể tải lại với model weights (Ollama, Hugging Face), project source code, conversation history, Docker volumes và WSL virtual disks (.vhdx).

---

## 2. Danh mục 12 chức năng chính

```text
=========================================================
                 TM-WINDOWS TOOLKIT                      
      Windows Optimization & Maintenance Toolkit         
=========================================================
  Hệ điều hành: Windows 11 Build 26100 | Quyền: [ADMIN]
---------------------------------------------------------
  [ 1] Dashboard / Thông tin hệ thống
  [ 2] Windows Post-Install & Kích hoạt bản quyền
  [ 3] Chế Độ Auto: Tự Động Tối Ưu Toàn Bộ Hệ Thống (Auto Care)
  [ 4] Disk & System Maintenance
  [ 5] Windows Repair (SFC / DISM / CHKDSK)
  [ 6] Network & LAN Support
  [ 7] Printer Support
  [ 8] AI & Developer Cleanup
  [ 9] Privacy, Notifications & Copilot
  [10] Tài khoản & quyền truy cập
  [11] Quick Commands
  [12] Backup & Restore
  [ 0] Thoát
=========================================================
```

1. **Dashboard / Thông tin hệ thống**: Đọc thời gian thực thông tin CPU, RAM, dung lượng phân vùng ổ đĩa, card mạng, IP, trạng thái Microsoft Defender, Print Spooler và số lượng máy in đã cài. Hỗ trợ xuất báo cáo ra file TXT / JSON.
2. **Windows Post-Install & Kích hoạt bản quyền**: Kích hoạt Windows và Microsoft Office bằng Product Key 25 ký tự (`slmgr.vbs /ipk /ato` và `ospp.vbs /inpkey /act`), đổi tên máy tính (Rename Computer), bật/tắt đuôi mở rộng file (`.exe`, `.txt`), hiện file ẩn, kiểm tra phần cứng thiếu driver (`Win32_PnPEntity`), tra cứu full key bản quyền và đồng bộ Google Sheets/Form.
3. **Chế Độ Auto: Tự Động Tối Ưu Toàn Bộ Hệ Thống (Auto Care & Profiles)**:
   - *1-Click Full System Auto Optimize*: Chế độ tự động chạy trọn gói quy trình dọn dẹp và tối ưu toàn diện toàn bộ máy tính (dọn %TEMP%, Windows Temp, thùng rác, crash minidump, cache Windows Update, cache pip/npm/uv, tối ưu độ mượt hiệu ứng hình ảnh, tắt quảng cáo & gợi ý ngầm, SSD ReTrim, flush DNS resolver cache, dọn sạch WinSxS) kèm sao lưu khôi phục tự động.
   - *Audit Only*: Chỉ quét và phân tích tình trạng mà không thay đổi hệ thống.
   - *Balanced*: Tối ưu hiệu ứng thị giác thừa, dọn dẹp file tạm, SSD ReTrim, giữ nguyên toàn bộ dịch vụ bảo mật.
   - *Desktop Performance*: Tối ưu phản hồi cho máy tính bàn cắm điện.
   - *Low Resource / HDD*: Tối ưu cho máy RAM thấp hoặc dùng ổ cứng HDD.
   - *Laptop Balanced*: Cân bằng thời lượng pin và nhiệt độ cho laptop.
   - *Services Manager*: Hiển thị trạng thái `SysMain`, `WSearch`, `Ndu` kèm khuyến cáo bảo mật của Microsoft.
4. **Disk & System Maintenance**: Kiểm tra chi tiết ổ đĩa HDD/SSD, chạy Optimize-Volume (TRIM cho SSD, Defrag cho HDD), CHKDSK các chế độ (Read-only, `/scan`, `/f`, `/r`), SFC scannow và DISM.
5. **Windows Repair**: Sửa chữa kho linh kiện Component Store bằng DISM RestoreHealth kết hợp SFC Scannow tuần tự, dọn dẹp WinSxS qua `DISM StartComponentCleanup`, đặt lại Winsock và TCP/IP stack.
6. **Network & LAN Support**: Xem chi tiết IP, Gateway, DNS, MAC address; Flush DNS; Renew DHCP; kiểm tra Ping; phân giải tên miền (Nslookup); kiểm tra cổng TCP (Test-NetConnection cho port 80, 443, 445 SMB, 135 RPC, 9100 Print); kiểm tra trạng thái SMB signing an toàn.
7. **Printer Support**: Liệt kê danh sách máy in; mở Print Server Properties (`printui /s /t2`); khởi động lại Print Spooler; xóa hàng đợi in kẹt (dừng Spooler -> xóa file tạm -> khởi động lại -> xác minh); kiểm tra kết nối UNC máy in chia sẻ; tạo tài khoản scan máy in bảo mật; hỗ trợ tạo kết nối qua Local Port (`\\Server\Share`); hướng dẫn khắc phục lỗi Access Denied (0x0000011b).
8. **AI & Developer Cleanup**: Nhận diện môi trường AI/Dev (Python, pip, uv, Node.js, npm, pnpm, Docker, WSL, Ollama); dọn dẹp an toàn các package cache; liệt kê mô hình Ollama (tuyệt đối không xóa tự động); dọn Docker build cache (không xóa volume); dọn log tạm của VS Code / Cursor.
9. **Privacy, Notifications & Copilot**: Bật/tắt nút Copilot trên Taskbar; ẩn/hiện Widgets trên Windows 11; tắt gợi ý và quảng cáo mẹo vặt của Windows; mở nhanh trang quản lý thông báo.
10. **Tài khoản & quyền truy cập**: Liệt kê tài khoản local (`Get-LocalUser`); tạo tài khoản scan; mở giao diện `lusrmgr.msc`, `netplwiz` và Credential Manager.
11. **Quick Commands**: Thư viện hơn 20 câu lệnh quản trị phổ biến (winver, msinfo32, devmgmt, diskmgmt, services, perfmon, ncpa.cpl, sfc, dism...) hỗ trợ chạy trực tiếp hoặc sao chép vào Clipboard.
12. **Backup & Restore**: Quản lý lịch sử các bản sao lưu, xem chi tiết manifest JSON, thực hiện hoàn tác (Rollback) khôi phục lại các giá trị Registry và dịch vụ về trạng thái ban đầu.

---

## 3. Cấu trúc thư mục dự án

```text
tm-win-care/
├─ Start.cmd                    # Bộ khởi chạy CMD cổ điển
├─ get.ps1                      # Bộ kéo tải trực tuyến
├─ README.md                    # Tài liệu hướng dẫn sử dụng
├─ LICENSE                      # Giấy phép phần mềm MIT
├─ config/
│  ├─ app.json                  # Nơi cấu hình định danh & số phiên bản Version
│  └─ tasks.json                # Danh mục tác vụ và phân cấp rủi ro
├─ src/
│  ├─ Main.ps1                  # Điểm điều phối Menu chính 12 mục
│  ├─ Core/                     # Bootstrap, Admin, Info, Backup, Restore, Logger...
│  ├─ Modules/                  # 12 module tính năng độc lập
│  └─ UI/                       # Colors, Tables, Prompts
├─ data/                        # Command catalog, cleanup catalog, profiles
├─ scripts/
│  └─ build.ps1                 # Script đóng gói tự động ra dist/
├─ dist/                        # Chứa các file AIO độc lập và file nén release
│  ├─ TM-WinCare-AIO.ps1        # File PowerShell All-In-One (chạy qua irm)
│  ├─ TM-WinCare-AIO.cmd        # File CMD All-In-One (double-click chạy ngay)
│  └─ TM-WinCare-Portable.zip   # Gói zip portable đầy đủ
└─ tests/                       # Bộ kiểm thử Unit test tầng Core và Modules
```

---

## 4. Hướng dẫn dành cho Quản trị viên & Phát hành phiên bản mới (Release Guide)

### Quản lý phiên bản (Version Management) ở đâu?
Phiên bản của bộ công cụ được quản lý tại **`config/app.json`**:
```json
{
  "name": "TM-WinCare",
  "displayName": "TM Windows Support Toolkit",
  "version": "1.2.0",
  "releaseDate": "2026-11-18"
}
```

### Quy trình đóng gói và phát hành phiên bản mới:
Khi bạn cập nhật tính năng và muốn ra mắt phiên bản mới (ví dụ `1.2.1`):

1. **Cập nhật số phiên bản**: Mở file `config/app.json` và sửa `"version": "1.2.1"`.
2. **Đóng gói file release**: Mở PowerShell tại thư mục dự án và chạy:
   ```powershell
   pwsh ./scripts/build.ps1
   ```
   *Script sẽ tự động đọc `app.json`, nhúng toàn bộ logic mới vào `dist/TM-WinCare-AIO.ps1`, `dist/TM-WinCare-AIO.cmd` và nén `dist/TM-WinCare-v1.2.1-Portable.zip`.*
3. **Commit & Tạo Git Tag**:
   ```powershell
   git add .
   git commit -m "chore: release version v1.2.1"
   git push origin main
   git tag v1.2.1
   git push origin v1.2.1
   ```
4. **Tạo Release trên GitHub**:
   - Nếu bạn đã bật GitHub Actions, workflow `.github/workflows/release.yml` sẽ **tự động** tạo GitHub Release và đính kèm các file trong `dist/`.
   - Nếu bạn tạo thủ công trên web GitHub: Vào mục **Releases** > **Draft a new release** > Chọn tag `v1.2.1` > Kéo thả các file trong thư mục `dist/` vào phần đính kèm rồi nhấn **Publish release**.

---

## 5. Kiểm thử tự động (Unit Tests)

```powershell
# Chạy bộ kiểm thử tầng Core
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Unit\CoreTests.ps1

# Chạy bộ kiểm thử tầng Modules
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Unit\ModuleTests.ps1
```

---

## 6. Giấy phép

Phát hành dưới giấy phép mã nguồn mở **MIT License**.
