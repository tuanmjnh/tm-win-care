# TM-WinCare – Windows Optimization & Maintenance Toolkit

> **TM Windows Support** | Phiên bản: **1.2.0** | Ngày phát hành: **18/11/2026**  
> Nền tảng mục tiêu: **Windows 10** và **Windows 11** (Home / Pro / Enterprise)

TM-WinCare là bộ công cụ dòng lệnh (Console/CMD Toolkit) portable, chạy trực tiếp trên Windows mà không cần cài đặt phần mềm bên ngoài, không cần database và hoạt động độc lập ngay cả khi máy tính offline. Công cụ được thiết kế chuyên biệt cho kỹ thuật viên IT, quản trị viên hệ thống và người dùng bảo trì máy tính, máy in và mạng nội bộ.

---

## 1. Triết lý thiết kế (Core Principles)

- **Safe by default**: Mặc định chỉ kiểm tra (Audit/Read-only) hoặc áp dụng các cấu hình an toàn, ít rủi ro.
- **Không tối ưu mù**: Tuyệt đối **không** tự ý tắt Windows Defender, Windows Security, Tường lửa (Firewall), Tamper Protection hay Windows Update.
- **Có giải thích & cảnh báo**: Luôn hiển thị rõ tác dụng, phạm vi ảnh hưởng và yêu cầu khởi động lại trước khi chạy bất kỳ thay đổi nào.
- **Tự động sao lưu & Hỗ trợ hoàn tác (Rollback)**: Tự động xuất Registry key và ghi nhận trạng thái dịch vụ vào thư mục `Backups/` trước khi thay đổi để có thể khôi phục bất cứ lúc nào.
- **Không hard-code mật khẩu**: Khi tạo tài khoản (ví dụ tài khoản scan máy in), hệ thống yêu cầu nhập mật khẩu bảo mật hai lần (`-AsSecureString`), không bao giờ ghi mật khẩu rõ vào log hay code.
- **Bảo vệ dữ liệu AI & Developer**: Phân biệt rạch ròi giữa cache có thể tải lại với model weights (Ollama, Hugging Face), project source code, conversation history, Docker volumes và WSL virtual disks (.vhdx).

---

## 2. Cấu trúc thư mục

```text
TM-WinCare/
├─ Start.cmd                    # Bộ khởi chạy CMD (hỗ trợ UTF-8, phát hiện Admin)
├─ README.md                    # Tài liệu hướng dẫn sử dụng
├─ LICENSE                      # Giấy phép phần mềm MIT
├─ config/
│  ├─ app.json                  # Cấu hình ứng dụng, phiên bản và các tính năng
│  └─ tasks.json                # Định nghĩa danh mục tác vụ & mức độ rủi ro
├─ src/
│  ├─ Main.ps1                  # Điểm điều phối Menu chính 12 mục
│  ├─ Core/
│  │  ├─ Bootstrap.ps1          # Khởi tạo UTF-8, nạp module và cấu hình
│  │  ├─ Logger.ps1             # Ghi log kép (.log & .jsonl), lọc dữ liệu nhạy cảm
│  │  ├─ Admin.ps1              # Kiểm tra quyền và tự động nâng quyền Administrator
│  │  ├─ WindowsInfo.ps1        # Nhận diện phần cứng/OS qua CIM & Registry (Không dùng WMIC)
│  │  ├─ Compatibility.ps1      # Kiểm tra tương thích Windows 10/11, Home/Pro
│  │  ├─ Backup.ps1             # Sao lưu Registry (.reg) và Service state trước thay đổi
│  │  ├─ Restore.ps1            # Công cụ hoàn tác (Rollback) an toàn
│  │  ├─ Confirm.ps1            # Cổng xác nhận tác vụ (Y/N hoặc từ khóa APPLY)
│  │  ├─ ErrorHandler.ps1       # Bắt lỗi tập trung và thông báo thân thiện
│  │  └─ Menu.ps1               # Engine menu console phân cấp
│  ├─ Modules/
│  │  ├─ Dashboard/             # Bảng thông tin hệ thống, RAM, CPU, ổ đĩa, Spooler
│  │  ├─ PostInstall/           # Cấu hình sau cài đặt (đổi tên máy, hiện đuôi file...)
│  │  ├─ Optimization/          # Auto Optimize theo profile & Custom Optimize
│  │  ├─ Maintenance/           # Bảo trì ổ đĩa (TRIM SSD, Defrag HDD, CHKDSK)
│  │  ├─ Repair/                # Sửa chữa Windows (SFC, DISM RestoreHealth, Winsock reset)
│  │  ├─ Network/               # Cấu hình IP, Gateway, DNS, Port test, SMB inspection
│  │  ├─ Printer/               # Khởi động Spooler, dọn kẹt in, Local Port, tài khoản scan
│  │  ├─ Cleanup/               # Dọn rác Windows Temp, WU cache, AI/Dev cache (pip, npm...)
│  │  ├─ Privacy/               # Bật/tắt nút Copilot, Widgets, mẹo vặt Windows
│  │  ├─ Accounts/              # Quản lý tài khoản cục bộ, tạo user scan
│  │  ├─ QuickCommands/         # Thư viện phím tắt mở nhanh các công cụ Windows
│  │  └─ BackupRestore/         # Giao diện xem và hoàn tác các bản sao lưu
│  └─ UI/
│     ├─ Colors.ps1             # Định dạng màu sắc và huy hiệu trạng thái [OK], [WARN], [LỖI]
│     ├─ Tables.ps1             # Định dạng bảng console và property grid
│     └─ Prompts.ps1            # Bộ nhập liệu, xác nhận và đọc mật khẩu bảo mật
├─ data/
│  ├─ command-catalog/          # Thư viện lệnh nhanh (Quick commands)
│  ├─ cleanup-catalog/          # Danh mục dọn dẹp hệ thống & công cụ AI/Dev
│  └─ optimization-profiles/    # Các profile Auto Optimize (Balanced, Laptop, Desktop...)
├─ Backups/                     # Thư mục lưu các bản sao lưu cấu hình trước khi tinh chỉnh
├─ Logs/                        # Nhật ký thực thi theo ngày (.log và .jsonl)
└─ tests/
   └─ Unit/
      ├─ CoreTests.ps1          # Kiểm thử tầng lõi (Bootstrap, CIM, Logger, Backup)
      └─ ModuleTests.ps1        # Kiểm thử các module chức năng
```

---

## 3. Hướng dẫn khởi chạy

### Cách 1: Khởi chạy nhanh qua `Start.cmd` (Khuyến nghị)
1. Chuột phải vào file `Start.cmd` và chọn **Run as administrator** (hoặc nhấp đúp để chạy chế độ người dùng thông thường).
2. Chương trình sẽ tự động thiết lập bảng mã UTF-8 (`chcp 65001`), kiểm tra quyền Administrator và khởi chạy PowerShell với cờ `-ExecutionPolicy Bypass`.

### Cách 2: Khởi chạy thủ công qua PowerShell
Mở PowerShell (5.1 hoặc PowerShell 7) tại thư mục dự án và chạy:
```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\src\Main.ps1
```

---

## 4. Danh mục 12 chức năng chính

```text
=========================================================
                 TM-WINDOWS TOOLKIT                      
      Windows Optimization & Maintenance Toolkit         
=========================================================
  Hệ điều hành: Windows 11 Build 26100 | Quyền: [ADMIN]
---------------------------------------------------------
  [ 1] Dashboard / Thông tin hệ thống
  [ 2] Windows Post-Install
  [ 3] Auto Optimize / Custom Optimize
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
2. **Windows Post-Install**: Đổi tên máy tính (Rename Computer), bật/tắt đuôi mở rộng file (`.exe`, `.txt`), hiện file ẩn, kiểm tra phần cứng thiếu driver (`Win32_PnPEntity`), mở nhanh các công cụ thiết lập Ngày giờ, Kích hoạt Windows, Startup và Nguồn điện.
3. **Auto Optimize / Custom Optimize**:
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

## 5. Kiểm thử & Đảm bảo chất lượng

Dự án đi kèm bộ kiểm thử tự động Pester/PowerShell:
```powershell
# Chạy bộ kiểm thử tầng Core
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Unit\CoreTests.ps1

# Chạy bộ kiểm thử tầng Modules
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Unit\ModuleTests.ps1
```

---

## 6. Giấy phép

Phát hành dưới giấy phép mã nguồn mở **MIT License**.
