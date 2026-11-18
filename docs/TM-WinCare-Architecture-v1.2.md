# TM-WinCare
## Định hướng sản phẩm, kiến trúc và kế hoạch triển khai

- **Tên dự án đề xuất:** TM-WinCare
- **Tên repository:** `tm-wincare`
- **Tên đầy đủ:** TM-WinCare – Windows Optimization & Maintenance Toolkit
- **Tên hiển thị:** TM Windows Support
- **Phiên bản tài liệu:** 1.2
- **Ngày:** 18/11/2026
- **Nền tảng mục tiêu:** Windows 10 và Windows 11
- **Đối tượng sử dụng:** Kỹ thuật viên cài đặt, bảo trì máy tính và máy in; người dùng có kiến thức cơ bản
- **Mục tiêu:** Bộ công cụ hậu cài đặt Windows, kiểm tra hệ thống, tối ưu an toàn và xử lý nhanh các tác vụ máy in/mạng nội bộ

---

## 1. Tầm nhìn và định hướng

TM-WinCare là một bộ tiện ích chạy trực tiếp trên Windows, có giao diện menu dạng CMD/Terminal. Công cụ tập trung vào những việc thường làm sau khi cài Windows mới hoặc khi xử lý máy tính cho khách hàng:

1. Kiểm tra thông tin máy và tình trạng Windows.
2. Cài đặt/hậu cấu hình Windows theo nhóm tác vụ.
3. Tối ưu hiệu năng theo hướng an toàn, không chạy các tweak cực đoan.
4. Kiểm tra và sửa các lỗi hệ thống phổ biến.
5. Cấu hình mạng LAN, chia sẻ file và máy in.
6. Quản lý Print Spooler, hàng đợi in, driver và kết nối máy in.
7. Chạy nhanh các lệnh quản trị thường dùng.
8. Ghi log, sao lưu thay đổi và hỗ trợ hoàn tác.

### Nguyên tắc thiết kế

- **Safe by default:** mặc định chỉ kiểm tra hoặc áp dụng cấu hình ít rủi ro.
- **Không tối ưu mù:** không tắt hàng loạt Services, Defender, Windows Update hoặc các thành phần bảo mật.
- **Có giải thích:** trước khi chạy một tác vụ thay đổi hệ thống, hiển thị tác dụng, phạm vi ảnh hưởng và yêu cầu khởi động lại.
- **Có xác nhận:** tác vụ ảnh hưởng bảo mật, mạng, tài khoản, Registry hoặc dữ liệu phải yêu cầu xác nhận riêng.
- **Có thể hoàn tác:** lưu trạng thái cũ trước khi thay đổi nếu có thể.
- **Tương thích:** kiểm tra phiên bản Windows, edition, quyền Administrator và khả năng tồn tại của lệnh/policy trước khi chạy.
- **Không lưu bí mật dạng rõ:** không ghi mật khẩu, token hoặc thông tin đăng nhập vào log/config.
- **Tách module:** mỗi chức năng có script riêng, dễ bảo trì và kiểm thử.

### Lưu ý về Windows 10

Windows 10 đã kết thúc hỗ trợ tiêu chuẩn ngày 14/10/2025. Máy vẫn hoạt động nhưng không còn nhận cập nhật bảo mật thông thường nếu không thuộc chương trình ESU. Vì vậy, công cụ cần cảnh báo trạng thái hỗ trợ và khuyến nghị nâng cấp hoặc đăng ký ESU khi thiết bị đủ điều kiện. Không được quảng bá việc chạy tối ưu là có thể thay thế cập nhật bảo mật.

Tham khảo: [Microsoft – Windows 10 support has ended](https://support.microsoft.com/en-us/windows/deployment/updates-lifecycle/windows-10-support-has-ended-on-october-14-2025).

---

## 2. Nên làm CMD hay ứng dụng có giao diện?

### Phương án đề xuất: PowerShell Core logic + CMD launcher + menu console

Không nên viết toàn bộ logic bằng Batch `.bat`. Batch phù hợp làm bộ khởi chạy và tương thích nhanh, nhưng xử lý Registry, JSON, kiểm tra dịch vụ, lỗi và dữ liệu có cấu trúc khá bất tiện.

Kiến trúc đề xuất:

- **`Start.cmd`:** điểm khởi chạy, kiểm tra thư mục và gọi PowerShell.
- **PowerShell 5.1:** runtime mặc định có sẵn trên Windows 10/11, thực hiện các tác vụ hệ thống.
- **Menu console:** giao diện chữ, menu phân cấp, màu sắc vừa phải, hỗ trợ bàn phím.
- **Module `.ps1`:** mỗi nhóm chức năng là một module riêng.
- **Cấu hình JSON:** lưu thiết lập mặc định, danh mục tác vụ và tuỳ chọn.
- **Log:** ghi thời gian, tác vụ, kết quả và lỗi; không ghi dữ liệu nhạy cảm.

Nên ưu tiên PowerShell 5.1 có sẵn thay vì bắt buộc cài PowerShell 7. Có thể kiểm thử tương thích PowerShell 7 ở giai đoạn sau.

### Vì sao chưa nên làm GUI ngay?

Menu CMD có ưu điểm gọn nhẹ, chạy nhanh, dễ mang theo USB và phù hợp thao tác kỹ thuật. Khi chức năng đã ổn định, có thể phát triển giao diện GUI bằng WinUI/WPF hoặc một ứng dụng desktop riêng nhưng tái sử dụng cùng lớp module PowerShell.

**Kết luận:** phiên bản đầu tiên nên là portable console toolkit, không cần cài đặt, không cần database, không cần Internet để chạy các chức năng nội bộ.

---

## 3. Phạm vi chức năng

### 3.1. Dashboard – thông tin hệ thống

Khi mở công cụ, hiển thị:

- Tên máy, tên người dùng, domain/workgroup.
- Windows 10/11, edition, version, build, kiến trúc 64-bit/32-bit.
- Trạng thái quyền Administrator.
- CPU, RAM, ổ đĩa, dung lượng trống.
- Model máy/mainboard/BIOS nếu truy xuất được.
- Card mạng, địa chỉ IPv4, gateway, DNS.
- Trạng thái Windows Update, Microsoft Defender và Firewall.
- Trạng thái Print Spooler.
- Số lượng máy in đã cài.
- Trạng thái kết nối Internet/LAN cơ bản.

Dashboard chỉ đọc thông tin; không tự ý thay đổi hệ thống.

### 3.2. Windows Post-Install – cấu hình sau cài đặt

Chia thành các nhóm:

**A. Thông tin và cá nhân hoá**
- Đổi tên máy (có yêu cầu khởi động lại).
- Mở trang thiết lập ngày giờ, ngôn ngữ, vùng.
- Mở System Properties, Device Manager, Disk Management.
- Mở Windows Activation và Windows Update.
- Mở thư mục Startup, Task Scheduler.

**B. Cấu hình hệ thống**
- Bật hiển thị phần mở rộng file.
- Bật hiển thị file ẩn (có cảnh báo về file hệ thống).
- Cấu hình chế độ ngủ/nguồn điện theo profile.
- Mở/cấu hình Startup Apps.
- Kiểm tra dung lượng ổ đĩa.
- Dọn file tạm qua cơ chế Windows hỗ trợ.
- Mở Storage Sense và Disk Cleanup.

**C. Cập nhật và bảo mật**
- Mở Windows Update để người dùng chủ động cập nhật.
- Kiểm tra trạng thái Defender, Firewall.
- Kiểm tra Secure Boot/TPM nếu có thể.
- Cảnh báo Windows 10 hết hỗ trợ tiêu chuẩn.
- Không tự tắt Defender, Firewall, SmartScreen hoặc Windows Update.

**D. Driver và thiết bị**
- Mở Device Manager.
- Liệt kê thiết bị có vấn đề nếu truy xuất được.
- Hiển thị thông tin driver mạng, âm thanh, đồ hoạ, máy in.
- Không tự tải driver từ nguồn không xác minh.
- Có thể bổ sung thư mục driver offline do kỹ thuật viên chuẩn bị.

### 3.3. Windows Optimization – tối ưu an toàn

Tách thành 3 mức:

| Mức | Mô tả | Chính sách |
|---|---|---|
| Kiểm tra | Chỉ đọc và báo cáo | Mặc định |
| An toàn | Dọn file tạm, mở công cụ bảo trì, cấu hình ít rủi ro | Có thể chọn nhiều tác vụ |
| Nâng cao | Registry, Services, SMB, policy, power settings | Xác nhận từng tác vụ, backup trước |

Nhóm tác vụ dự kiến:

- Dọn thư mục Temp của user và Windows theo cách có kiểm tra.
- Chạy Storage Sense/Disk Cleanup.
- Kiểm tra file hệ thống bằng `DISM` và `sfc`.
- Kiểm tra ổ đĩa bằng `chkdsk` ở chế độ phù hợp.
- Xem ứng dụng khởi động cùng Windows.
- Kiểm tra Services đang chạy và trạng thái Startup Type.
- Kiểm tra dung lượng ổ C.
- Mở Task Manager và Resource Monitor.
- Kiểm tra các thiết lập power plan.

### 3.3.1. Optimize Windows – Auto Profile và Custom Profile

Thiết kế hai cách sử dụng song song:

- **Auto Optimize:** người dùng chọn một profile phù hợp với máy; toolkit quét cấu hình trước, hiển thị danh sách thay đổi và dung lượng/tác động dự kiến, sau đó mới yêu cầu xác nhận.
- **Custom Optimize:** người dùng tự bật/tắt từng hạng mục, xem giá trị hiện tại, giá trị đề xuất, mức rủi ro và khả năng hoàn tác.

Không có nút “Boost 100%” hoặc cam kết tăng FPS/tốc độ theo phần trăm. Mỗi máy khác nhau; toolkit phải ưu tiên đo/ghi nhận trạng thái trước và sau thay đổi.

#### Menu Optimize Windows

```text
---------------------- OPTIMIZE WINDOWS ----------------------
 [1] Phân tích & đề xuất tối ưu (Audit only)
 [2] Auto Optimize - Balanced (khuyến nghị)
 [3] Auto Optimize - Desktop Performance
 [4] Auto Optimize - Máy cấu hình thấp / HDD
 [5] Auto Optimize - Laptop Balanced
 [6] Custom Optimize - Tự chọn từng mục
 [7] Services Manager (SysMain / WSearch / Ndu ...)
 [8] Visual Effects & Animations
 [9] Startup Apps & Background Apps
[10] Power Plan & Performance Mode
[11] Copilot & Windows Experience
[12] Xem thay đổi gần nhất / Rollback
 [0] Quay lại
---------------------------------------------------------------
```

#### Các profile khởi điểm

| Profile | Dành cho | Hành vi mặc định |
|---|---|---|
| Audit only | Mọi máy | Chỉ quét, không thay đổi |
| Balanced | Máy cá nhân phổ thông | Giữ dịch vụ Windows mặc định; gợi ý tắt animation không cần thiết; rà Startup; dọn file an toàn |
| Desktop Performance | Máy bàn, ưu tiên phản hồi | Có thể chọn Best performance; cảnh báo điện/nhiệt; không tắt Defender/Firewall/Update |
| Low Resource / HDD | Máy cũ, RAM thấp hoặc HDD | Đo mức sử dụng dịch vụ trước; đề xuất giảm indexing ở thư mục lớn; không tự tắt SysMain/WSearch hàng loạt |
| Laptop Balanced | Laptop | Giữ cân bằng pin/nhiệt; không ép Best performance khi chạy pin |
| Custom | Kỹ thuật viên | Chọn từng tweak, backup và rollback riêng |

Profile chỉ là bộ đề xuất đã kiểm thử, không phải danh sách registry tweak áp dụng giống nhau trên mọi build. Mọi profile phải hỗ trợ “Preview changes” trước khi Apply.


#### Auto Optimize – quy trình tự động đề xuất và áp dụng

Mục tiêu của Auto Optimize là giảm tải không cần thiết, cải thiện thời gian khởi động và độ phản hồi. Không cam kết một con số RAM được giải phóng vì Windows chủ động dùng RAM trống làm cache và tự quản lý memory. Công cụ phải phân biệt **RAM đang được ứng dụng sử dụng**, **standby/cache memory**, **committed memory** và **memory pressure**; không được coi RAM cache là RAM lãng phí.

**Luồng xử lý bắt buộc:**

1. **Pre-scan:** nhận diện Windows build/edition, desktop hay laptop, AC/battery, HDD/SSD, RAM, dung lượng trống, uptime, startup apps, process tiêu thụ CPU/RAM, service state, Defender/Firewall/Update và notification settings.
2. **Health checks:** cảnh báo ổ đĩa gần đầy, RAM/commit pressure, process bất thường, Windows Update pending reboot, Defender/Firewall tắt, lỗi hệ thống hoặc máy đang chạy tác vụ cài đặt/copy lớn.
3. **Recommendation engine:** chỉ đề xuất những thay đổi phù hợp phần cứng và trạng thái máy. Không áp dụng profile cố định giống nhau cho mọi máy.
4. **Preview:** liệt kê từng action, trạng thái hiện tại, trạng thái đích, lý do, rủi ro, yêu cầu restart và rollback.
5. **Backup:** lưu cấu hình trước thay đổi.
6. **Apply:** chỉ chạy action đã được người dùng duyệt; tác vụ rủi ro cao cần xác nhận riêng.
7. **Verify:** đọc lại trạng thái sau thay đổi; nếu không đạt, báo lỗi và đề xuất rollback.
8. **Report:** xuất báo cáo trước/sau; không tuyên bố “đã giải phóng X GB RAM” nếu chỉ đo biến động tạm thời.

**Nhóm action có thể chạy tự động trong Safe Auto Optimize:**

- Phân tích và đề xuất tắt các ứng dụng startup không thiết yếu; mặc định không tự tắt ứng dụng driver, touchpad, audio, GPU, backup, security, VPN, sync hoặc phần mềm máy in.
- Hiển thị ứng dụng/process đang tiêu thụ RAM/CPU cao; chỉ đóng ứng dụng do người dùng chọn, không kill process hệ thống tự động.
- Dọn các file tạm thuộc allowlist (Windows/user temp) theo quy trình preview; bỏ qua file đang khóa, không xóa Downloads, Desktop, Documents, browser profile hoặc dữ liệu ứng dụng.
- Chạy Storage Sense/Disk Cleanup qua cơ chế Windows hỗ trợ; Windows.old chỉ là mục riêng, phải cảnh báo mất khả năng rollback bản Windows trước.
- Chuyển visual effects sang Reduce animations hoặc preset do người dùng chọn; giữ font smoothing và khả năng đọc.
- Quản lý thông báo theo chế độ đã chọn (xem mục Notifications); không tắt thông báo bảo mật/cập nhật quan trọng bằng cách disable service.
- Kiểm tra Windows Update, Defender, Firewall và driver; không tự tắt để giảm RAM.
- Tùy chọn restart sau khi hoàn tất, nhưng chỉ khi người dùng xác nhận rõ.

**Không được làm trong Auto Optimize:**

- Không chạy RAM cleaner, EmptyStandbyList, standby-list purge theo lịch hoặc liên tục; không ép giải phóng RAM bằng cách kill process hàng loạt.
- Không tự disable SysMain, WSearch, Ndu hoặc service khác chỉ vì tên xuất hiện trong danh sách “debloat”.
- Không tự đổi pagefile/virtual memory, CPU scheduler, core parking, registry memory management hoặc power throttling bằng tweak không có căn cứ.
- Không xóa Prefetch, WinSxS, Installer cache, Windows Update component store, browser profile, crash dump đang cần phân tích hoặc log bảo mật.
- Không xóa Windows.old tự động.
- Không disable Defender, Windows Security, Firewall, SmartScreen, UAC, Windows Update, BITS, RPC, Plug and Play, Audio, Network stack hay Print Spooler.

#### Các profile Auto Optimize nên triển khai

| Profile | Tác vụ chính | Những gì không tự làm |
|---|---|---|
| Safe Quick Optimize | Audit, startup review, dọn temp an toàn, Reduce animations tùy chọn, notification mode đã chọn | Không đổi service startup, không xóa app/model/user data |
| Balanced | Safe Quick Optimize + đề xuất app nền và dung lượng ổ đĩa | Không ép Best Performance, không tắt Search/SysMain |
| Low RAM | Phát hiện app chiếm RAM, startup/background review, giảm animation, cảnh báo commit/pagefile | Không kill process, không tắt pagefile, không disable service theo preset |
| HDD System | Kiểm tra sức khỏe/dung lượng, đề xuất Optimize Drives và giảm indexing scope nếu phù hợp | Không ép defrag SSD, không tắt SysMain mặc định |
| Desktop Performance | Có thể chọn Best Performance và startup review | Không tự thay đổi bảo mật hoặc thermal settings |
| Laptop Balanced | Cân bằng AC/battery, animation và startup review | Không ép hiệu năng cao khi dùng pin |
| Custom | Người dùng tự chọn action | Mỗi action vẫn phải qua policy/risk check |

**Nút “One-click Auto Optimize”** chỉ thực hiện Safe Quick Optimize theo cấu hình người dùng đã lưu. Lần đầu chạy phải hiển thị preview và xin xác nhận; những lần sau vẫn phải thông báo danh sách action, không được âm thầm thêm action mới sau khi cập nhật ứng dụng.

#### Service Manager: SysMain, WSearch, Ndu

Bắt buộc đọc trạng thái trước khi thao tác: Service Name, Display Name, State, StartType, DelayedAutoStart, trigger/start conditions nếu có, phụ thuộc và lý do đang chạy.

| Thành phần | Đề xuất thiết kế | Cảnh báo / đánh giá |
|---|---|---|
| `SysMain` | Cho phép giữ nguyên, đổi Startup Type hoặc Stop trong Custom mode; luôn ghi lại trạng thái ban đầu | Dịch vụ quản lý hoạt động tải trước/cache. Không có căn cứ đủ mạnh để khẳng định tắt luôn làm máy nhanh hơn; kết quả tùy HDD/SSD, RAM và workload. Không disable trong Balanced mặc định |
| `WSearch` | Ưu tiên cấu hình phạm vi Indexing/Exclude folders; có thể cho phép Stop/Disable trong Custom mode | Tắt sẽ ảnh hưởng tìm kiếm Windows/Start và khả năng tìm nội dung. Microsoft khuyến nghị xử lý Search Indexer bằng cách loại trừ thư mục hoặc điều chỉnh phạm vi index trước, không chạy “optimizer” tắt dịch vụ |
| `Ndu` | Chỉ hiển thị trạng thái; không đưa vào Auto Optimize. Nếu có mục thử nghiệm thì phải ẩn sau Advanced/Experimental và cảnh báo rõ | `Start=4` là đặt service startup thành Disabled, không phải “tối ưu mạng” được Microsoft khuyến nghị. Không có bằng chứng đáng tin cậy rằng thay đổi này tăng tốc mạng/Windows phổ quát |

Đối với `WSearch`, nên có wizard mở Search Indexing Settings và cho phép loại trừ các thư mục nặng (ví dụ thư mục source, dependency, model cache) thay vì tắt toàn bộ dịch vụ. Điều này vừa giảm công việc index vừa giữ tìm kiếm các thư mục tài liệu bình thường.

**Quy tắc kỹ thuật khi thay đổi Services:**

1. Không đoán Startup Type mặc định. Đọc giá trị thực tế trên máy.
2. Backup StartType, State, DelayedAutoStart và các cấu hình liên quan trước khi sửa.
3. Không sửa service thuộc Windows Security, Defender, Firewall, Update, RPC, Plug and Play, Audio, Network stack hoặc Print Spooler trong profile tối ưu.
4. Không dùng `sc delete`; không xóa service.
5. Nếu service đang có trigger start hoặc bị policy quản trị điều khiển, hiển thị “Managed/Unsupported” thay vì cố ghi đè.
6. Sau Apply, xác minh trạng thái; cung cấp Restore original settings.
7. Tách “Stop service tạm thời” khỏi “Disable startup” vì hai hành động khác nhau.

#### Visual Effects & Animations

Các tùy chọn nên có:

- Tắt/bật animation cửa sổ, menu, taskbar và hiệu ứng chuyển cảnh khi có thiết lập được Windows hỗ trợ.
- Chọn “Let Windows choose”, “Best appearance”, “Best performance” hoặc “Custom”.
- Giữ tùy chọn làm mịn font chữ (font smoothing/ClearType) và thumbnail nếu người dùng muốn trải nghiệm dễ nhìn.
- Có preview, lưu cấu hình cũ và Restore.
- Không thay đổi registry bằng một file `.reg` tổng hợp không kiểm tra build.

Cách triển khai ưu tiên mở giao diện Performance Options (`SystemPropertiesPerformance.exe`) hoặc dùng API/cấu hình được tài liệu hóa, đọc lại giá trị hiện hành trước/sau. Có thể cung cấp preset “Reduce animations” riêng, không bắt buộc chọn “Adjust for best performance” vì tùy chọn đó có thể làm giao diện xấu/khó đọc.

#### Startup & Background Activity

- Liệt kê Startup Apps và đường dẫn executable/publisher nếu truy xuất được.
- Hiển thị impact nếu Windows cung cấp.
- Cho phép mở Task Manager > Startup Apps hoặc tắt từng entry do người dùng chọn.
- Không tự xóa shortcut, Scheduled Task hoặc Run key không rõ nguồn gốc.
- Với ứng dụng có Background permissions, mở trang Settings tương ứng; không tự tắt mọi ứng dụng.

#### Notifications & Quiet Mode – quản lý thông báo

Tạo menu riêng, hỗ trợ cả Windows 10 và Windows 11 theo khả năng của từng build:

```text
---------------- NOTIFICATIONS & QUIET MODE ----------------
 [1] Kiểm tra cấu hình thông báo hiện tại
 [2] Mở Notification Settings
 [3] Bật Do Not Disturb / Focus Assist (khi được hỗ trợ)
 [4] Tắt thông báo theo từng ứng dụng (mở Settings để chọn)
 [5] Quản lý tips, suggestions và welcome experience
 [6] Khôi phục cấu hình thông báo đã backup
 [0] Quay lại
------------------------------------------------------------
```

Các chế độ:
- **Keep Important Notifications:** giữ thông báo hệ thống, bảo mật, cập nhật, ứng dụng do người dùng chọn.
- **Quiet Mode:** ưu tiên Do Not Disturb/Focus Assist để ẩn banner và giảm gián đoạn; người dùng vẫn có thể xem thông báo trong Notification Center.
- **Custom per-app:** mở trang Settings để người dùng chọn ứng dụng được phép gửi thông báo; không cố ghi registry undocumented để tắt từng app.
- **Disable tips/suggestions:** chỉ áp dụng các setting/policy được hỗ trợ trên build/edition hiện tại; ghi rõ policy nào không khả dụng.

Không được tắt toàn bộ Windows notifications bằng cách disable Action Center/notification services hoặc xóa hệ thống notification database. Không tắt cảnh báo Defender, Firewall, Windows Update, low disk, backup hoặc lỗi phần cứng trong preset Auto Optimize. Do Not Disturb không đồng nghĩa với tắt thông báo vĩnh viễn; cần có nút Restore/Turn Off Quiet Mode.

Nguồn triển khai: Windows Settings > System > Notifications; trên Windows 11 dùng Do not disturb, trên Windows 10 dùng Focus Assist/notification controls tương ứng. Giao diện và policy có khác biệt theo build.

#### Power & Thermal Profile

- Balanced là mặc định.
- Best performance là tùy chọn, cảnh báo tăng tiêu thụ điện, nhiệt và giảm thời lượng pin.
- Laptop cần phân biệt AC/Battery; không ép High Performance khi đang chạy pin.
- Không thay đổi CPU minimum/maximum state, core parking, PCIe Link State hoặc USB selective suspend bằng các tweak không có kiểm thử phần cứng.

### 3.3.2. Windows Privacy, Copilot và Windows Security

Tách rõ ba nhóm: **gỡ/ẩn ứng dụng Copilot**, **quản lý privacy/notification**, và **bảo vệ Windows Security**.

**Copilot:**
- Phát hiện app Copilot consumer đã cài, hiển thị package/display name và cách gỡ qua Settings > Apps > Installed apps.
- Có thể cung cấp shortcut mở Installed Apps và nút gỡ bằng cơ chế package/app đã xác minh, kèm xác nhận.
- Không xóa Edge WebView2, Microsoft Edge, Windows App Runtime hoặc thành phần chia sẻ chỉ vì Copilot sử dụng chúng.
- Policy `TurnOffWindowsCopilot` là policy legacy/deprecated, có giới hạn edition/build và không áp dụng cho mọi trải nghiệm Copilot mới. Không dùng nó làm phương thức duy nhất hoặc áp dụng hàng loạt.
- Với thiết bị tổ chức, ưu tiên policy quản trị hiện hành như AppLocker theo tài liệu Microsoft; với máy cá nhân, ưu tiên uninstall app/ẩn icon bằng Settings.
- Không xóa dữ liệu Copilot/chat của người dùng khi gỡ app nếu chưa có lựa chọn riêng và giải thích hậu quả.

**Windows Security:**
- Toolkit có thể kiểm tra và hiển thị trạng thái Defender, Firewall, SmartScreen, Tamper Protection và Windows Security notifications.
- Có shortcut mở Windows Security, Virus & threat protection, Firewall & network protection và App & browser control.
- Có thể cho người dùng quản lý thông báo không thiết yếu qua Settings, nhưng không được giả lập thao tác đó bằng cách tắt dịch vụ bảo vệ.
- **Không cung cấp nút tắt Windows Security/Defender/Firewall/Real-time Protection/Tamper Protection trong Auto Optimize.** Không tắt Security Center, Defender services hoặc xóa app Windows Security.
- Nếu cần troubleshooting antivirus trong tình huống kiểm thử có kiểm soát, chỉ hướng dẫn quy trình tạm thời chính thức, có thời hạn và khôi phục; không ghi thành profile thường trực.

---

**Không đưa vào preset mặc định:**
- Tắt hàng loạt Services theo danh sách trên mạng.
- Tắt Windows Defender, Firewall, UAC, SmartScreen.
- Tắt Windows Update.
- Tắt pagefile hoặc xoá pagefile.
- Ép tắt các tác vụ bảo trì hệ thống.
- Xoá component store/WinSxS thủ công.
- Áp dụng hàng loạt Registry tweak không có tài liệu và phương án rollback.

### 3.4. Repair Tools – sửa lỗi Windows

Menu sửa lỗi:

1. Kiểm tra file hệ thống (`sfc /verifyonly`).
2. Sửa file hệ thống (`sfc /scannow`).
3. Kiểm tra component store (`DISM /Online /Cleanup-Image /ScanHealth`).
4. Sửa component store (`DISM /Online /Cleanup-Image /RestoreHealth`).
5. Kiểm tra ổ đĩa.
6. Mở Event Viewer.
7. Mở Reliability Monitor (`perfmon /rel`).
8. Mở Troubleshoot Settings.
9. Kiểm tra dịch vụ Windows Update.
10. Xuất báo cáo thông tin hệ thống.

Các tác vụ sửa chữa phải thông báo thời gian chạy có thể lâu, yêu cầu quyền Administrator và có thể cần khởi động lại.

### 3.5. Disk & System Maintenance – bảo trì ổ đĩa và hệ thống

Đây là module riêng trên menu chính, tập hợp các thao tác kiểm tra ổ đĩa, tối ưu HDD/SSD và sửa chữa Windows. Không gộp tất cả thành một nút “Fix All”; người dùng phải chọn từng tác vụ và xem trước phạm vi ảnh hưởng.

#### Menu đề xuất

```text
---------------- DISK & SYSTEM MAINTENANCE --------------
 [1] Kiểm tra loại ổ đĩa và dung lượng
 [2] Phân tích / tối ưu HDD hoặc SSD
 [3] Chạy Optimize Drives của Windows
 [4] CHKDSK - kiểm tra ổ đĩa (không sửa)
 [5] CHKDSK - quét online NTFS
 [6] CHKDSK - sửa lỗi hệ thống file (/f)
 [7] CHKDSK - quét sector và sửa lỗi (/r)
 [8] SFC - kiểm tra file hệ thống
 [9] SFC - quét và sửa file hệ thống
[10] DISM - kiểm tra component store
[11] DISM - sửa component store
[12] Chạy quy trình DISM + SFC tuần tự
[13] Mở Disk Cleanup / Storage Settings
[14] Xuất báo cáo ổ đĩa và bảo trì
 [0] Quay lại
---------------------------------------------------------
```

#### A. Kiểm tra thông tin ổ đĩa

Trước khi tối ưu, hiển thị:
- Danh sách volume, ký tự ổ, nhãn, filesystem, tổng dung lượng và dung lượng trống.
- Loại media HDD/SSD/NVMe nếu Windows cung cấp được thông tin.
- Trạng thái volume và khả năng truy cập.
- Các ổ đang có BitLocker, nếu phát hiện được thì chỉ hiển thị trạng thái; không tự giải mã hoặc thay đổi protector.
- Cảnh báo nếu ổ gần đầy hoặc có dấu hiệu lỗi được hệ thống báo cáo.

Có thể dùng `Get-Volume`, `Get-Partition`, `Get-Disk` và `Get-PhysicalDisk` khi cmdlet/driver hỗ trợ. Không được giả định mọi bộ điều khiển RAID/USB đều trả về chính xác loại media. Nếu không xác định được, hiển thị “Không xác định” và không ép chế độ tối ưu.

#### B. Defragment và Optimize HDD/SSD

Không dùng một lệnh chống phân mảnh thủ công cho mọi loại ổ.

| Loại ổ | Tác vụ phù hợp | Hành vi toolkit |
|---|---|---|
| HDD | Analyze và Defragment | Phân tích trước; cho phép tối ưu khi người dùng xác nhận |
| SSD SATA | Optimize / TRIM | Dùng cơ chế Optimize Drives của Windows, ưu tiên ReTrim khi phù hợp |
| SSD NVMe | Optimize / TRIM | Dùng cơ chế tối ưu do Windows quản lý; không ép defrag thủ công |
| Không xác định | Chỉ phân tích | Không chạy thao tác tối ưu cưỡng bức |

Lệnh CMD tham khảo:

```cmd
:: Phân tích volume, không tối ưu
 defrag C: /A /U /V

:: Tối ưu theo loại media Windows nhận diện
 defrag C: /O /U /V

:: Mở giao diện Optimize Drives
 dfrgui.exe
```

PowerShell tham khảo:

```powershell
# Phân tích volume
Optimize-Volume -DriveLetter C -Analyze -Verbose

# Tối ưu theo cơ chế phù hợp với loại ổ
Optimize-Volume -DriveLetter C -Verbose

# ReTrim cho SSD khi cần và khi được hỗ trợ
Optimize-Volume -DriveLetter C -ReTrim -Verbose
```

Quy tắc triển khai:
- Ưu tiên `defrag /O` hoặc `Optimize-Volume` để Windows chọn phương thức phù hợp với media.
- Không chạy `defrag /D` như preset chung cho SSD.
- Không chạy tối ưu hàng loạt tất cả ổ mà không hiển thị danh sách volume và yêu cầu xác nhận.
- Hiển thị tiến trình, kết quả, thời gian và exit code.
- Nếu PowerShell Storage module không hỗ trợ hoặc media không nhận diện được, mở `dfrgui.exe` thay vì tự suy đoán.
- Không quảng cáo defrag sẽ sửa được ổ cứng có lỗi vật lý.

#### C. CHKDSK – kiểm tra và sửa lỗi ổ đĩa

Cung cấp các mức thao tác rõ ràng:

| Mức | Lệnh | Ý nghĩa | Tác động |
|---|---|---|---|
| Kiểm tra cơ bản | `chkdsk C:` | Kiểm tra và báo cáo lỗi filesystem | Không chủ động sửa |
| Quét online NTFS | `chkdsk C: /scan` | Quét NTFS khi Windows đang chạy | Ưu tiên cho kiểm tra online |
| Sửa lỗi | `chkdsk C: /f` | Sửa lỗi logic filesystem | Có thể cần khóa volume hoặc lên lịch lúc restart |
| Quét sector | `chkdsk C: /r` | Tìm sector lỗi, cố gắng phục hồi dữ liệu đọc được; bao gồm chức năng `/f` | Rất lâu, có thể cần restart |

Quy trình UI:
1. Cho người dùng chọn volume từ danh sách hợp lệ; không nhận chuỗi lệnh tuỳ ý.
2. Hiển thị filesystem, dung lượng và cảnh báo nếu là ổ hệ thống.
3. Chọn chế độ kiểm tra hoặc sửa chữa.
4. Với `/f` hoặc `/r`, cảnh báo có thể cần restart và yêu cầu xác nhận rõ ràng.
5. Với volume đang sử dụng, hiển thị câu hỏi Windows về việc lên lịch kiểm tra khi khởi động; không tự trả lời thay người dùng.
6. Ghi lại lệnh, thời điểm, exit code và trạng thái lên lịch; hướng dẫn xem kết quả sau restart trong Event Viewer nếu cần.

Không chạy `/r` định kỳ như một thao tác “tăng tốc”. Đây là tác vụ dài, chỉ nên dùng khi có dấu hiệu filesystem/sector cần điều tra. Nếu ổ có dấu hiệu hỏng vật lý, ưu tiên sao lưu dữ liệu quan trọng và chẩn đoán tình trạng thiết bị trước; CHKDSK không thay thế backup hoặc công cụ kiểm tra sức khoẻ ổ.

#### D. SFC – kiểm tra file hệ thống Windows

Các lựa chọn:

```cmd
:: Chỉ xác minh, không sửa
sfc /verifyonly

:: Quét và sửa file hệ thống được bảo vệ
sfc /scannow
```

- Yêu cầu quyền Administrator.
- Hiển thị thông báo không tắt cửa sổ khi đang chạy.
- Lưu kết quả và exit code.
- Nếu SFC báo không thể sửa một số file, hướng dẫn chạy DISM rồi chạy lại SFC.

#### E. DISM – sửa Windows Component Store

Các lựa chọn:

```cmd
:: Kiểm tra nhanh trạng thái component store
DISM /Online /Cleanup-Image /CheckHealth

:: Quét sâu để phát hiện corruption
DISM /Online /Cleanup-Image /ScanHealth

:: Sửa component store
DISM /Online /Cleanup-Image /RestoreHealth
```

- Yêu cầu quyền Administrator.
- `/RestoreHealth` có thể cần Windows Update/nguồn sửa chữa phù hợp và có thể mất nhiều thời gian.
- Không tự tải ISO hoặc file nguồn không rõ nguồn gốc.
- Nếu máy offline hoặc DISM không tìm thấy source, ghi rõ lỗi và hướng dẫn người dùng cung cấp nguồn Windows phù hợp với edition/build/language.

#### F. Quy trình sửa chữa tổng hợp

Tạo tác vụ “Repair Windows – DISM + SFC” theo trình tự:

1. Kiểm tra quyền Administrator, trạng thái pending reboot và dung lượng ổ hệ thống.
2. Nhắc người dùng lưu công việc; nếu máy có dấu hiệu lỗi ổ đĩa, ưu tiên backup trước.
3. Chạy `DISM /Online /Cleanup-Image /ScanHealth` để kiểm tra.
4. Chạy `DISM /Online /Cleanup-Image /RestoreHealth` để sửa component store.
5. Chỉ khi DISM hoàn tất phù hợp, chạy `sfc /scannow`.
6. Tổng hợp kết quả từng bước; không coi exit code thành công của DISM là bằng chứng mọi file hệ thống đều đã sạch.
7. Đề xuất restart nếu Windows yêu cầu hoặc có thao tác đang chờ hoàn tất.

Có thể cung cấp chế độ “SFC trước” chỉ để chẩn đoán, nhưng quy trình sửa chữa chuẩn nên dùng DISM RestoreHealth trước rồi SFC để kiểm tra/sửa các file hệ thống được bảo vệ.

#### G. An toàn dữ liệu và giới hạn

- CHKDSK `/f` và `/r` có thể thay đổi filesystem; luôn cảnh báo và yêu cầu xác nhận.
- Không chạy sửa chữa đồng thời trên cùng một volume.
- Không tự động chạy CHKDSK `/r` trên mọi máy sau cài Windows.
- Không tự động restart máy khi người dùng chưa đồng ý.
- Không xóa dữ liệu cá nhân để “sửa lỗi hệ thống”.
- Không hứa hẹn sửa được lỗi ổ cứng vật lý; khuyến nghị backup trước khi can thiệp ổ có dấu hiệu bất thường.
- Các tác vụ bảo trì phải được log đầy đủ, nhưng không ghi dữ liệu cá nhân.

---

## 4. Module Printer & Network Support

Đây là module quan trọng, cần ưu tiên phát triển sớm vì phù hợp với quy trình hỗ trợ máy tính/máy in thực tế.

### 4.1. Menu máy in đề xuất

```text
=========================================================
                 TM-WINDOWS TOOLKIT
=========================================================
 [1] Dashboard / Thông tin hệ thống
 [2] Windows Post-Install
 [3] Auto Optimize / Custom Optimize
 [4] Disk & System Maintenance
 [5] Windows Repair (SFC / DISM / CHKDSK)
 [6] Network & LAN Support
 [7] Printer Support
 [8] AI & Developer Cleanup
 [9] Privacy, Notifications & Copilot
[10] Tài khoản & quyền truy cập
[11] Quick Commands
[12] Backup & Restore
 [0] Thoát
=========================================================
```

Menu Printer Support:

```text
------------------- PRINTER SUPPORT --------------------
 [1] Danh sách máy in đã cài
 [2] Mở Printers & Scanners
 [3] Mở Printer Properties
 [4] Mở Print Server Properties (printui /s /t2)
 [5] Khởi động lại Print Spooler
 [6] Xoá hàng đợi in bị treo
 [7] Kiểm tra Print Spooler
 [8] Kiểm tra kết nối máy in chia sẻ
 [9] Tạo tài khoản scan
 [10] Cấu hình máy in chia sẻ - máy chủ
 [11] Cấu hình máy khách kết nối máy in
 [12] Tạo Local Port
 [13] Hướng dẫn xử lý Access Denied
 [14] Xuất báo cáo máy in
 [0] Quay lại
---------------------------------------------------------
```

### 4.2. Quản lý Print Spooler

Các thao tác:

- Kiểm tra trạng thái `Spooler`.
- Start/Stop/Restart dịch vụ.
- Mở thư mục hàng đợi in.
- Xem danh sách job.
- Xoá job bị treo sau khi dừng Spooler.
- Khởi động lại Spooler và xác minh trạng thái.

Quy trình xoá hàng đợi in bị treo:

1. Cảnh báo các lệnh in đang chờ có thể bị xoá.
2. Dừng Print Spooler.
3. Xoá các file job trong thư mục spool tương ứng.
4. Khởi động lại Print Spooler.
5. Kiểm tra dịch vụ đã chạy trở lại.

Không tự động xoá driver hoặc máy in đã cài khi người dùng chỉ chọn dọn hàng đợi.

### 4.3. Các lệnh nhanh từ ghi chú hiện tại

| Lệnh | Tác dụng | Cách tích hợp |
|---|---|---|
| `net user scan "123456" /add` | Tạo local user `scan` | Form nhập mật khẩu; không hard-code mật khẩu mặc định |
| `wmic useraccount ...` | Ghi chú cũ để cấu hình tài khoản | Thay bằng PowerShell `Set-LocalUser` nếu có; kiểm tra module/cmdlet |
| `net user scan` | Xem thông tin tài khoản | Chạy dạng read-only |
| `printui /s /t2` | Mở Print Server Properties, tab Drivers | Quick launch |
| `Set-SmbClientConfiguration -RequireSecuritySignature $false` | Tắt yêu cầu SMB signing phía client | Tác vụ nâng cao, cảnh báo bảo mật, không bật mặc định |
| `gpupdate /force` | Cập nhật Group Policy | Quick launch sau khi đổi policy |

#### Tạo tài khoản scan

Không sử dụng mật khẩu `123456` cố định trong chương trình. Khi chạy chức năng này:

- Cho phép nhập tên tài khoản, mặc định gợi ý `scan`.
- Yêu cầu nhập mật khẩu và xác nhận mật khẩu.
- Không hiển thị mật khẩu khi gõ.
- Không ghi mật khẩu vào log.
- Kiểm tra user đã tồn tại hay chưa.
- Có tuỳ chọn đặt mật khẩu không hết hạn, nhưng phải giải thích rủi ro.
- Không tự thêm tài khoản vào Administrators.
- Không tự bật Guest hoặc chia sẻ thư mục rộng quyền.

Có thể dùng `New-LocalUser` và `Set-LocalUser` trên Windows hỗ trợ module LocalAccounts. Nếu môi trường không có cmdlet phù hợp, hiển thị hướng dẫn hoặc fallback đã kiểm thử. Không dùng WMIC làm nền tảng mới vì WMIC đã bị deprecated và có thể không hiện diện ở các bản Windows mới.

Ví dụ thao tác PowerShell (mã triển khai cần xử lý lỗi và xác nhận):

```powershell
$Password = Read-Host "Nhap mat khau cho tai khoan scan" -AsSecureString

if (-not (Get-LocalUser -Name "scan" -ErrorAction SilentlyContinue)) {
    New-LocalUser -Name "scan" -Password $Password -Description "Tai khoan scan"
} else {
    Write-Host "Tai khoan scan da ton tai."
}
```

Đặt mật khẩu không hết hạn là lựa chọn có rủi ro. Chỉ cung cấp như một tuỳ chọn riêng, không bật mặc định. Với tài khoản dùng cho scan-to-folder, nên giới hạn quyền vào đúng thư mục nhận file.

### 4.4. Chia sẻ máy in giữa Windows 10 và Windows 11

Phải chia rõ hai vai trò:

- **Máy chủ/Host:** máy đang cắm trực tiếp máy in và chia sẻ máy in.
- **Máy khách/Client:** máy kết nối tới máy in được chia sẻ.

Các chức năng cần có:

**Trên máy chủ**
- Kiểm tra tên máy, IP, Workgroup.
- Kiểm tra máy in đã cài và trạng thái Share.
- Mở `Printer properties`.
- Mở tab Sharing và Security.
- Kiểm tra Print Spooler.
- Kiểm tra Windows Firewall rule liên quan File and Printer Sharing.
- Kiểm tra quyền người dùng được phép in.
- Hướng dẫn tạo user riêng nếu cần xác thực.

**Trên máy khách**
- Kiểm tra ping tới máy chủ.
- Kiểm tra phân giải tên máy.
- Mở Credential Manager.
- Hướng dẫn lưu thông tin đăng nhập Windows Credentials.
- Kiểm tra đường dẫn `\\TEN-MAY-CHU\TEN-MAY-IN`.
- Hỗ trợ tạo Local Port.
- Mở giao diện Add Printer.
- Kiểm tra lỗi Access Denied, driver, RPC và SMB.

### 4.5. Lưu thông tin đăng nhập Windows Credentials

Không nên yêu cầu người dùng nhập password vào tham số dòng lệnh hoặc ghi vào file cấu hình.

Phiên bản đầu tiên nên:
- Mở Credential Manager bằng lệnh `control /name Microsoft.CredentialManager`.
- Hiển thị hướng dẫn nhập địa chỉ máy chủ, username và password.
- Cho phép copy đường dẫn máy in dạng `\\SERVER\PRINTER`.
- Không đọc hoặc xuất mật khẩu đã lưu.
- Không ghi password vào log.

Có thể nghiên cứu `cmdkey` ở giai đoạn sau, nhưng phải tránh đưa password vào command-line argument vì có thể bị lộ qua lịch sử lệnh, process inspection hoặc log.

### 4.6. Tạo Local Port

Hỗ trợ kỹ thuật viên tạo kết nối bằng Local Port với đường dẫn dạng:

```text
\\DESKTOP-DT03IGN\ttdvth
```

Giao diện cần yêu cầu:
- Tên máy chủ hoặc IP.
- Tên share máy in.
- Hiển thị đường dẫn UNC trước khi mở wizard.
- Nút mở giao diện Add Printer / Printer Properties.
- Hướng dẫn chọn Add a local printer or network printer with manual settings > Create a new port > Local Port.
- Không tự cài driver không rõ nguồn gốc.

Nên hỗ trợ cả tên máy và IP. Khuyến nghị tên máy khi DNS/NetBIOS hoạt động ổn định; dùng IP khi cần kiểm tra lỗi phân giải tên.

---

## 5. Các Registry và Policy máy in trong ghi chú – phân loại an toàn

Một số cấu hình trong ghi chú có thể giúp xử lý môi trường cũ nhưng làm giảm bảo mật. Không được gộp tất cả thành nút “Fix Printer” chạy một lần.

### 5.1. `RpcAuthnLevelExemption`

Ghi chú hiện tại đề cập tạo DWORD `RpcAuthnLevelExemption=1` tại:

```text
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Print
```

Sau đó restart Print Spooler.

**Đề xuất xử lý trong toolkit:**
- Đưa vào mục Legacy Compatibility / Troubleshooting nâng cao.
- Hiển thị cảnh báo rõ rằng đây là ngoại lệ liên quan xác thực RPC và có thể làm giảm bảo mật.
- Chỉ cho phép chạy khi kỹ thuật viên xác nhận đang xử lý một môi trường cụ thể đã kiểm tra.
- Backup key/value hiện tại trước khi thay đổi.
- Ghi log tên máy, thời điểm và trạng thái trước/sau.
- Có chức năng Restore giá trị cũ hoặc xoá value do toolkit tạo.
- Không áp dụng mặc định cho mọi máy Windows 10.
- Kiểm tra tài liệu Microsoft hiện hành trước khi phát hành tính năng; không coi ghi chú cũ là hướng dẫn chung cho mọi build.
- **Lưu ý tên Registry:** `RpcAuthnLevelExemption` trong ghi chú của người dùng không phải là tên value được tài liệu Microsoft về RPC printing hiện hành nêu trong hướng dẫn tương thích Named Pipes. Tài liệu Microsoft đề cập `RpcAuthnLevelPrivacyEnabled` tại cùng nhánh Print trong một số tình huống tương thích. Đây là hai tên khác nhau, không được tự ý thay thế cho nhau. Toolkit phải kiểm tra build, tài liệu và kịch bản cụ thể trước khi thao tác; không tạo `RpcAuthnLevelExemption` theo kiểu mặc định hoặc tuyên bố đây là Microsoft fix chuẩn.

### 5.2. Configure RPC connection settings – Windows 11 Client

Ghi chú đề xuất:

`Computer Configuration > Administrative Templates > Printers > Configure RPC connection settings`

Chọn RPC over named pipes.

Microsoft xác nhận Windows 11 22H2 trở lên mặc định dùng RPC over TCP; Named Pipes vẫn có thể cấu hình nhưng không phải lựa chọn được khuyến nghị chung. Chỉ dùng Named Pipes khi môi trường hiện tại không thể dùng RPC over TCP và đã kiểm tra nguyên nhân.

Trong toolkit:
- Mặc định giữ cấu hình Windows.
- Có nút kiểm tra cấu hình hiện tại.
- Chỉ cung cấp Named Pipes như chế độ tương thích nâng cao.
- Yêu cầu xác nhận và backup policy Registry.
- Hỗ trợ rollback.
- Không tự động tắt xác thực RPC.

### 5.3. Point and Print Restrictions

Ghi chú đề xuất bật policy và bỏ các cảnh báo/elevation prompt khi cài/cập nhật driver.

Đây là vùng nhạy cảm bảo mật vì Point and Print liên quan việc tải/cài driver máy in. Không nên mặc định bỏ cảnh báo hoặc giảm yêu cầu elevation.

Hướng an toàn:
- Ưu tiên cài driver đã xác minh trước trên máy khách.
- Chỉ định print server đáng tin cậy nếu dùng môi trường quản trị tập trung.
- Giữ yêu cầu xác thực/elevation phù hợp.
- Nếu phải thay đổi policy, hiển thị rõ máy nào bị ảnh hưởng và lý do.
- Không cung cấp preset “tắt toàn bộ cảnh báo Point and Print”.

### 5.4. SMB signing và SMB guest

Ghi chú có lệnh:

```powershell
Set-SmbClientConfiguration -RequireSecuritySignature $false
```

Lệnh này thay đổi yêu cầu SMB signing phía client. Không nên bật như một bước tối ưu hay fix chung. SMB signing giúp bảo vệ tính toàn vẹn/xác thực của lưu lượng SMB trong các tình huống phù hợp.

Toolkit chỉ nên:
- Hiển thị trạng thái SMB signing hiện tại.
- Giải thích tác động.
- Giữ nguyên mặc định bảo mật.
- Chỉ cho phép thay đổi trong mục Advanced, xác nhận riêng, backup và có rollback.
- Không tự bật SMB1.
- Không tự bật insecure guest logons.
- Không cấp Everyone Full Control cho share hoặc thư mục.

### 5.5. Quyền Everyone / Guest trên máy in

Ghi chú đề xuất thêm Everyone hoặc Guest và cấp Print + Manage documents.

Cần phân biệt:
- **Print:** quyền gửi lệnh in.
- **Manage documents:** quyền quản lý/xoá job của người khác.
- **Manage this printer:** quyền quản lý cấu hình máy in.

Không nên cấp rộng `Manage documents` cho Everyone nếu không thật sự cần. Không nên sử dụng Guest như giải pháp mặc định. Nên ưu tiên user riêng hoặc nhóm người dùng được xác định, cấp đúng quyền tối thiểu.

Nếu có wizard phân quyền:
- Hiển thị rõ tên principal.
- Tách quyền Print / Manage documents / Manage this printer.
- Mặc định chỉ đề xuất Print cho nhóm cần in.
- Cảnh báo trước khi cấp quyền quản lý.
- Có thể xem lại ACL hiện tại; không tự xoá quyền đang tồn tại.

### 5.6. RPC over TCP – hướng xử lý ưu tiên

Với Windows 11 22H2 trở lên, cần kiểm tra:
- RPC Endpoint Mapper TCP 135.
- Dải TCP động cần thiết giữa client và host/print server.
- Windows Firewall profile và rule File and Printer Sharing.
- Tên máy/IP và khả năng phân giải tên.
- Driver máy in và trạng thái Print Spooler.

Named Pipes chỉ là phương án tương thích khi RPC over TCP không khả thi. Tham khảo hướng dẫn Microsoft ở phần tài liệu cuối.

---

## 6. Network & LAN Support

Menu Network:

1. Xem IP, gateway, DNS, MAC.
2. `ipconfig /all`.
3. Renew DHCP.
4. Flush DNS.
5. Ping gateway / máy chủ / IP tuỳ nhập.
6. Kiểm tra DNS resolution.
7. Kiểm tra kết nối TCP tới cổng do người dùng nhập.
8. Mở Network Connections.
9. Mở Advanced Sharing Settings.
10. Mở Windows Firewall.
11. Mở Credential Manager.
12. Kiểm tra SMB client/server configuration.
13. Kiểm tra File and Printer Sharing rules.
14. Xuất báo cáo Network.

Không tự bật Network Discovery, File Sharing, SMB1 hoặc Guest access nếu chưa được người dùng yêu cầu và hiểu rủi ro.

---

## 7. Quick Commands – thư viện lệnh nhanh

Tạo thư viện các lệnh thường dùng, phân loại:

| Nhóm | Lệnh / công cụ | Chức năng |
|---|---|---|
| System | `winver` | Xem phiên bản Windows |
| System | `msinfo32` | Thông tin hệ thống |
| System | `dxdiag` | Thông tin DirectX |
| System | `devmgmt.msc` | Device Manager |
| System | `diskmgmt.msc` | Disk Management |
| Disk | `dfrgui.exe` | Optimize Drives (HDD/SSD) |
| Disk | `defrag C: /A /U /V` | Phân tích volume, không tối ưu |
| Disk | `defrag C: /O /U /V` | Tối ưu theo loại media Windows nhận diện |
| Disk | `chkdsk C:` | Kiểm tra filesystem cơ bản |
| Disk | `chkdsk C: /scan` | Quét online NTFS |
| Disk | `chkdsk C: /f` | Sửa lỗi filesystem; có thể cần restart |
| Disk | `chkdsk C: /r` | Tìm sector lỗi và cố gắng phục hồi; chạy lâu |
| System | `services.msc` | Services |
| System | `eventvwr.msc` | Event Viewer |
| System | `perfmon /rel` | Reliability Monitor |
| System | `taskmgr` | Task Manager |
| Printer | `printui /s /t2` | Print Server Properties / Drivers |
| Printer | `control printers` | Devices and Printers |
| Printer | `services.msc` | Quản lý Print Spooler |
| Network | `ncpa.cpl` | Network Connections |
| Network | `inetcpl.cpl` | Internet Properties |
| Network | `control /name Microsoft.CredentialManager` | Credential Manager |
| Network | `ipconfig /all` | Thông tin mạng |
| Network | `gpupdate /force` | Cập nhật Group Policy |
| Repair | `sfc /verifyonly` | Chỉ xác minh file hệ thống |
| Repair | `sfc /scannow` | Quét và sửa file hệ thống |
| Repair | `DISM /Online /Cleanup-Image /CheckHealth` | Kiểm tra nhanh component store |
| Repair | `DISM /Online /Cleanup-Image /ScanHealth` | Quét component store |
| Repair | `DISM /Online /Cleanup-Image /RestoreHealth` | Sửa component store |

Mỗi lệnh cần có:
- Tên tiếng Việt.
- Mô tả ngắn.
- Yêu cầu quyền Administrator hay không.
- Có làm thay đổi hệ thống không.
- Có cần restart không.
- Nút chạy và nút copy.
- Kết quả thực thi và mã lỗi.

Không chạy lệnh từ file cấu hình bên ngoài một cách mù quáng. Chỉ chạy các command đã khai báo trong danh mục code nội bộ và được review.


## 7A. System Cleanup – dọn dẹp Windows, cập nhật và log

Mục tiêu là thu hồi dung lượng có kiểm soát, không phải xóa mọi thứ có tên “cache”, “temp” hoặc “log”. Mỗi mục phải được phân loại theo nguồn, loại dữ liệu, tuổi file, ứng dụng đang sử dụng và khả năng tái tạo.

### Menu System Cleanup

```text
------------------------ SYSTEM CLEANUP ------------------------
 [1] Quét dung lượng & phân tích thư mục lớn
 [2] Dọn User Temp (%TEMP%)
 [3] Dọn Windows Temp (quyền Admin)
 [4] Dọn Recycle Bin (xem trước)
 [5] Windows Update / Delivery Optimization cache
 [6] Component cleanup bằng DISM (không xóa WinSxS thủ công)
 [7] Windows.old / Previous Windows Installation
 [8] Crash dumps & diagnostic logs
 [9] Browser / App cache (theo ứng dụng)
[10] Lịch sử cleanup và dung lượng đã giải phóng
 [0] Quay lại
-----------------------------------------------------------------
```

### Phân loại mục dọn dẹp

| Mục | Cách xử lý | Mặc định |
|---|---|---|
| `%TEMP%` của user | Quét dung lượng, xóa file tạm không bị khóa; bỏ qua file đang dùng | Cho phép sau preview |
| `%WINDIR%\Temp` | Cần quyền Admin; bỏ qua file đang sử dụng/ACL không đủ | Xác nhận riêng |
| Recycle Bin | Hiển thị dung lượng và số mục trước khi xóa | Không tự xóa |
| Windows Update Download cache | Dùng cơ chế Windows/Storage cleanup; dừng dịch vụ đúng quy trình nếu phải thao tác thủ công | Advanced, không xóa DataStore tùy tiện |
| Delivery Optimization cache | Ưu tiên Windows Storage/cleanup APIs hoặc Settings | Có thể đề xuất |
| DirectX Shader Cache / thumbnail cache | Dùng danh mục Temporary Files do Windows cung cấp khi có | Cho phép sau preview |
| Memory dump / minidump | Hiển thị kích thước, ngày, loại dump; có thể cần giữ để chẩn đoán BSOD | Không tự xóa |
| Event logs | Chỉ xuất/archival hoặc xóa từng log có xác nhận; không clear toàn bộ log | Giữ nguyên |
| Browser cache | Theo từng browser, đóng browser trước, không xóa cookies/password/history theo mặc định | Tùy chọn |
| `WinSxS`, `Installer`, `System32`, `DriverStore` | Không xóa thủ công; dùng DISM/Windows servicing | Cấm trong cleanup thường |
| `Prefetch` | Không dọn định kỳ để “tăng tốc” | Không cung cấp nút dọn |

### Windows.old / Previous Windows Installation

- Kiểm tra thư mục có tồn tại, dung lượng, thời điểm nâng cấp và trạng thái Windows rollback nếu có thể.
- Ưu tiên mở Settings > System > Storage > Temporary files / Cleanup recommendations để người dùng chọn “Previous Windows installation(s)”.
- Cảnh báo: xóa Windows.old làm mất khả năng quay về bản Windows trước đó. Không tự xóa trong 10 ngày đầu sau nâng cấp hoặc khi chưa xác nhận người dùng không cần rollback.
- Không dùng `Remove-Item -Recurse -Force` trực tiếp làm phương pháp chuẩn; dùng Storage cleanup/servicing được Windows hỗ trợ.
- Nếu Windows.old không tồn tại hoặc cleanup không được hỗ trợ trên build đó, báo lý do thay vì cố xóa.

### Chính sách dọn dẹp

- Có Preview: đường dẫn, loại dữ liệu, dung lượng, số file, tuổi file, ứng dụng sở hữu.
- Mặc định giữ file mới và file đang sử dụng; bỏ qua junction/symlink để tránh xóa ngoài phạm vi.
- Không đi theo reparse point/junction khi quét/xóa.
- Không xóa file ngoài allowlist của module.
- Không xóa toàn bộ thư mục chỉ vì tên chứa `cache`, `log`, `temp`.
- Ghi log số lượng file/dung lượng đã xóa, số file bỏ qua và lỗi.
- Có chế độ dry-run; file đã xóa không phải lúc nào cũng khôi phục được nên không hứa rollback cho cleanup.

## 7B. AI & Developer Cleanup – dọn cache công cụ AI và môi trường phát triển

Đây là module chuyên biệt để xử lý tình trạng máy dùng AI/coding lâu ngày: cache model hub, package cache, build cache, log, crash dump, dữ liệu tạm và container build. Không được đánh đồng cache có thể tải lại với model, project, conversation, credential hoặc cấu hình người dùng.

### Menu AI & Developer Cleanup

```text
------------------- AI & DEVELOPER CLEANUP -------------------
 [1] Quét ứng dụng AI / Dev đã cài
 [2] Phân tích dung lượng theo ứng dụng
 [3] Hugging Face cache
 [4] Ollama models & logs
 [5] Python / pip / uv cache
 [6] Node.js / npm / pnpm cache
 [7] Docker images / build cache / containers
 [8] WSL distributions & virtual disks (chỉ phân tích)
 [9] VS Code / Cursor / IDE logs & disposable cache
[10] AI app logs / crash reports (allowlist)
[11] Dọn theo lựa chọn đã chọn
[12] Xuất báo cáo dung lượng AI/Dev
 [0] Quay lại
---------------------------------------------------------------
```

### Nguyên tắc phân loại dữ liệu AI/Dev

| Nhóm | Ví dụ | Mặc định xử lý |
|---|---|---|
| Download/package cache | pip, uv, npm, pnpm, Hugging Face Hub cache | Có thể dọn qua CLI chính chủ sau khi hiển thị dung lượng |
| Build cache | Docker BuildKit, compiler cache | Preview rồi prune; không xóa volume mặc định |
| Model weights | Ollama, Hugging Face snapshots, LM Studio models | Không xóa trong “Clean all”; chỉ quản lý model riêng, hiển thị tên/kích thước và yêu cầu xác nhận |
| Project/workspace | Git repo, source code, venv, node_modules | Không tự xóa; node_modules chỉ có thể đề xuất theo project được người dùng chọn |
| Conversation/session history | Chat, agent sessions, workspace storage | Giữ nguyên; không xem là cache |
| Credentials/config | API keys, `.env`, SSH keys, tokens, app settings | Cấm quét nội dung/xóa |
| Logs/crash reports | Log cũ của app AI/IDE | Chỉ dọn theo allowlist, tuổi file và app đã đóng |
| WSL/Docker virtual disks | `.vhdx`, ext4.vhdx, Docker data disk | Chỉ phân tích; không xóa file disk trực tiếp |

### Các adapter nên hỗ trợ

**Hugging Face Hub**
- Nhận diện cache mặc định theo tài liệu (`~/.cache/huggingface/hub`) và biến môi trường `HF_HOME`, `HF_HUB_CACHE`.
- Không hard-code một đường dẫn duy nhất; đọc biến môi trường và đường dẫn cấu hình.
- Ưu tiên công cụ `hf cache`/cache management của Hugging Face nếu CLI có sẵn; nếu không, chỉ hiển thị dung lượng và hướng dẫn.
- Cảnh báo cache có thể chứa model/dataset snapshot lớn mà người dùng muốn giữ để chạy offline.

**Ollama**
- Phát hiện CLI và chạy `ollama list` để hiển thị model.
- Phát hiện thư mục model mặc định `%USERPROFILE%\.ollama\models` và biến `OLLAMA_MODELS` (có thể thay đổi vị trí).
- Phân biệt model weights với logs/cache. Không xóa model folder bằng thao tác dọn cache.
- Muốn xóa model phải hiển thị tên model, dung lượng ước tính và yêu cầu xác nhận; dùng `ollama rm <model>` thay vì xóa file blobs thủ công.
- Log chỉ dọn khi Ollama đã thoát và chỉ theo đường dẫn được xác minh trên phiên bản đang cài.

**Python / pip / uv**
- `pip cache dir` để lấy đường dẫn cache thực tế; `pip cache info` để xem dung lượng; `pip cache purge` chỉ sau xác nhận.
- `uv cache dir` và `uv cache clean` để quản lý cache; không xóa thư mục Python managed installs hoặc virtual environments.
- Không xóa `.venv`, `venv`, Conda environments hay Python installations trong mục cache cleanup.

**Node.js / npm / pnpm**
- npm: chạy `npm cache verify` trước; `npm cache clean --force` chỉ khi người dùng chọn dọn cache và được cảnh báo rằng package cần tải lại.
- pnpm: truy vấn `pnpm store path` và sử dụng `pnpm store prune` theo CLI của phiên bản đang cài; không xóa store bằng đường dẫn đoán.
- Không xóa `node_modules` toàn máy. Chỉ cung cấp Project Cleanup khi người dùng duyệt/chọn thư mục project, hiển thị `package.json`, lockfile và dung lượng trước khi xóa.

**Docker Desktop**
- Kiểm tra Docker CLI/daemon và chạy lệnh liệt kê dung lượng trước.
- Có lựa chọn `docker builder prune` cho build cache và `docker system prune` cho object không dùng.
- Không thêm `--volumes` trong preset; volumes có thể chứa database hoặc dữ liệu người dùng.
- `docker system prune -a` là tùy chọn nâng cao vì có thể xóa images không còn được container sử dụng và cần tải/build lại.
- Luôn yêu cầu người dùng xác nhận nội dung prune dự kiến.

**WSL**
- Liệt kê distro và trạng thái; phân biệt distro đang dùng với distro cũ.
- Không xóa `.vhdx`/`ext4.vhdx` trực tiếp.
- Muốn giải phóng dung lượng WSL cần hướng dẫn export/backup distro, dọn trong Linux filesystem, shutdown đúng cách và compact virtual disk theo phương pháp tương thích phiên bản WSL/Windows.
- Không tự unregister distro.

**VS Code / Cursor / IDE / AI agents**
- Phát hiện thư mục logs/cache theo app version và profile thực tế; đường dẫn có thể thay đổi theo Stable/Insiders/portable/custom data directory.
- Chỉ xóa cache tạm đã xác định và logs cũ khi ứng dụng đã đóng.
- Giữ nguyên extensions, user settings, keybindings, snippets, workspaceStorage, chat/session history, project index nếu chưa có hướng dẫn chính thức và lựa chọn riêng.
- Không đoán thư mục dữ liệu của mọi AI agent. Dùng adapter theo app, có tài liệu nguồn và test; app chưa hỗ trợ thì chỉ báo dung lượng, không xóa.

### Quy trình cleanup bắt buộc

1. Discover: nhận diện app, phiên bản, process đang chạy, cache path từ CLI/config/env var.
2. Scan: đo dung lượng, số file, tuổi file; không đọc nội dung prompt/chat/token.
3. Classify: Cache (re-downloadable), Logs (diagnostic), Models (large persistent assets), User Data (preserve), Unknown (preserve).
4. Preview: hiển thị đường dẫn, dung lượng, tác động và cách tải lại.
5. Confirm: xác nhận từng app hoặc từng nhóm; không có “Clean all” xóa model/user data.
6. Execute: dùng CLI chính chủ; nếu phải xóa file thì allowlist chính xác, skip locked/reparse points.
7. Verify: đo lại dung lượng và báo lỗi/bỏ qua.

## 7C. Tùy chọn cấu hình và trạng thái của các thành phần Windows

Tạo một trang “Windows Components” để kiểm tra/điều chỉnh có kiểm soát:

- Copilot consumer app và taskbar icon.
- Search indexing scope (không mặc định disable Search UI/service).
- Widgets/consumer experiences nếu có policy được tài liệu hóa và đúng edition/build.
- Startup apps và background app permissions.
- Notifications và tips/suggestions.
- Animation/visual effects.
- Power mode.

Mỗi thành phần có trạng thái: Supported / Unsupported / Managed by policy / Requires restart / Experimental. Không ghi registry nếu không có policy/setting tương ứng được xác minh trên build đang chạy.

---

## 8. Backup & Restore

Đây là module bắt buộc trước khi mở rộng các tính năng Registry/Policy.

### Backup tối thiểu

- Xuất Registry key trước khi thay đổi.
- Lưu giá trị Registry cũ dưới dạng JSON có kiểu dữ liệu.
- Lưu trạng thái service trước khi thay đổi.
- Lưu cấu hình SMB/policy có thể đọc được.
- Lưu danh sách máy in và driver để tham chiếu.
- Ghi manifest cho mỗi phiên thay đổi.

Ví dụ cấu trúc:

```text
Backups/
  2026-11-18_143000/
    manifest.json
    registry/
    services/
    network/
    printers/
    logs/
```

### Nguyên tắc rollback

- Chỉ hoàn tác các thay đổi do toolkit thực hiện và đã ghi nhận.
- Không khôi phục mù toàn bộ Registry.
- Không ghi đè cấu hình mới của người dùng nếu trạng thái đã thay đổi kể từ lúc backup.
- Hiển thị khác biệt trước khi restore.
- Có yêu cầu xác nhận.
- Ghi log kết quả rollback.

System Restore Point có thể được cung cấp như lựa chọn bổ sung nhưng không được xem là phương án backup duy nhất.

---

## 9. Kiến trúc source code

Cấu trúc đề xuất:

```text
TM-WinCare/
├─ Start.cmd
├─ README.md
├─ LICENSE
├─ config/
│  ├─ app.json
│  └─ tasks.json
├─ src/
│  ├─ Main.ps1
│  ├─ Core/
│  │  ├─ Bootstrap.ps1
│  │  ├─ Menu.ps1
│  │  ├─ Logger.ps1
│  │  ├─ Admin.ps1
│  │  ├─ WindowsInfo.ps1
│  │  ├─ Compatibility.ps1
│  │  ├─ Backup.ps1
│  │  ├─ Restore.ps1
│  │  ├─ Confirm.ps1
│  │  └─ ErrorHandler.ps1
│  ├─ Modules/
│  │  ├─ Dashboard/
│  │  ├─ PostInstall/
│  │  ├─ Optimization/
│  │  ├─ Cleanup/
│  │  │  ├─ WindowsCleanup.ps1
│  │  │  ├─ AiDevCleanup.ps1
│  │  │  ├─ CacheAdapters/
│  │  │  └─ CleanupCatalog.json
│  │  ├─ Privacy/
│  │  ├─ Repair/
│  │  ├─ Network/
│  │  ├─ Printer/
│  │  ├─ Accounts/
│  │  └─ QuickCommands/
│  └─ UI/
│     ├─ Colors.ps1
│     ├─ Tables.ps1
│     └─ Prompts.ps1
├─ data/
│  ├─ printer/
│  ├─ cleanup-catalog/
│  ├─ optimization-profiles/
│  └─ command-catalog/
├─ Backups/
├─ Logs/
└─ tests/
   ├─ Unit/
   ├─ Integration/
   └─ Compatibility/
```

Có thể tổ chức mỗi module thành một file `.psm1` khi codebase lớn hơn. Giai đoạn đầu giữ cấu trúc đơn giản để dễ debug.

### Trách nhiệm các lớp

**Core**
- Khởi tạo ứng dụng.
- Phát hiện OS/build/edition.
- Kiểm tra quyền Administrator.
- Quản lý log, backup, rollback.
- Xử lý lỗi tập trung.
- Chuẩn hoá kết quả tác vụ.

**Modules**
- Chỉ chứa logic của lĩnh vực tương ứng.
- Không tự tạo menu cấp cao.
- Gọi Core để log, xác nhận, backup.
- Không chạy tác vụ nếu OS không đáp ứng điều kiện.

**UI**
- Chỉ hiển thị menu, prompt và kết quả.
- Không chứa logic Registry hoặc thao tác hệ thống.
- Có thể thay thế bằng GUI về sau.

### Quy ước hàm

Mỗi tác vụ nên có cấu trúc thống nhất:

```powershell
function Invoke-TMTaskExample {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param()

    # 1. Validate OS / permission / prerequisites
    # 2. Read current state
    # 3. Explain intended change
    # 4. Backup current state
    # 5. Apply change only when confirmed
    # 6. Verify result
    # 7. Write structured log
}
```

Dùng `-WhatIf` ở những tác vụ hỗ trợ `ShouldProcess`. Không phải mọi cmdlet hệ thống đều hỗ trợ rollback tự động; phải tự triển khai và kiểm thử.

---

## 10. Thiết kế menu và trải nghiệm sử dụng

### Quy tắc UI

- Tiếng Việt là ngôn ngữ mặc định.
- Tên lệnh Windows giữ nguyên tiếng Anh để dễ đối chiếu.
- Menu đánh số, nhập số để chọn.
- Có `0 - Quay lại` và `0 - Thoát` theo từng cấp.
- Không dùng ký tự Unicode quá phức tạp khiến CMD cũ lỗi font.
- Hỗ trợ console UTF-8; có chế độ ASCII fallback.
- Luôn hiển thị trạng thái: OK / Cảnh báo / Lỗi.
- Không dùng màu sắc làm dấu hiệu duy nhất; luôn có chữ mô tả.
- Khi thao tác nguy hiểm, yêu cầu nhập từ khoá xác nhận như `APPLY`.

### Mẫu xác nhận

```text
TÁC VỤ: Thay đổi cấu hình SMB Client

Ảnh hưởng:
- Thay đổi yêu cầu SMB signing trên máy hiện tại.
- Có thể làm giảm bảo mật kết nối SMB.

Trạng thái hiện tại: ...
Trạng thái sau thay đổi: ...

Đã tạo backup: ...
Bạn có chắc chắn muốn tiếp tục? (Y/N):
```

---

## 11. Logging và báo cáo

Mỗi lần chạy cần tạo log theo ngày:

```text
Logs/
  2026-11-18.log
  2026-11-18.jsonl
```

Mỗi record nên có:
- Timestamp.
- Task ID.
- Tên tác vụ.
- Windows version/build.
- Kết quả: Started / Success / Failed / Skipped.
- Error message đã loại bỏ dữ liệu nhạy cảm.
- Backup ID nếu có.
- Có cần restart hay không.

Có chức năng xuất báo cáo TXT/JSON cho kỹ thuật viên gửi lại hoặc lưu hồ sơ máy khách.

Không log password, credential, token, nội dung file cá nhân hoặc dữ liệu nhạy cảm.

---

## 12. Tương thích Windows 10 và Windows 11

### Phát hiện hệ điều hành

Không dựa vào tên hiển thị đơn giản. Dùng thông tin hệ điều hành/build từ CIM và Registry đáng tin cậy; kiểm tra edition, build và kiến trúc.

Ví dụ logic:
- Windows 10: NT 10.0, build thuộc nhánh Windows 10.
- Windows 11: NT 10.0, build thuộc nhánh Windows 11.
- Phân biệt bằng build và thông tin sản phẩm, không chỉ dựa vào `Environment.OSVersion`.
- Kiểm tra lệnh/cmdlet tồn tại trước khi gọi.

### Bảng tương thích tính năng

| Tính năng | Windows 10 | Windows 11 | Ghi chú |
|---|---|---|---|
| PowerShell 5.1 | Có | Có | Runtime cơ sở |
| PrintUI | Có | Có | Kiểm tra đường dẫn/công cụ |
| Print Spooler | Có | Có | Có thể bị policy quản trị hạn chế |
| LocalAccounts module | Tuỳ môi trường | Tuỳ môi trường | Kiểm tra cmdlet |
| WMIC | Deprecated/tuỳ build | Có thể không có | Không dùng làm nền tảng |
| Configure RPC connection policy | Tuỳ build/edition | Windows 11 22H2+ | Kiểm tra policy có hỗ trợ |
| Point and Print policy | Có | Có | Cần giữ bảo mật |
| Một số Settings URI | Khác nhau | Khác nhau | Có fallback mở Control Panel |

Windows Home có thể không có `gpedit.msc`. Khi đó:
- Không gọi `gpedit.msc` như điều kiện bắt buộc.
- Dùng Registry policy chỉ khi có tài liệu chính xác và có rollback.
- Thông báo rõ policy nào không áp dụng hoặc không được hỗ trợ.

---

## 13. Bảo mật và giới hạn quyền

- Không yêu cầu chạy toàn bộ ứng dụng bằng Administrator ngay từ đầu nếu chỉ xem thông tin.
- Khi tác vụ cần quyền cao, chỉ nâng quyền cho tác vụ hoặc khởi chạy phiên elevated có giải thích.
- Không lưu mật khẩu trong `.ps1`, `.bat`, JSON hoặc log.
- Không tự động tạo tài khoản có mật khẩu mặc định.
- Không mở rộng quyền Everyone/Guest theo mặc định.
- Không tự tắt SMB signing, Defender, Firewall, UAC hoặc Point and Print protections.
- Không cung cấp Auto Optimize để tắt Windows Security, Microsoft Defender, Firewall, SmartScreen hoặc Tamper Protection.
- Không đưa SysMain/WSearch vào danh sách disable mặc định; Ndu Start=4 chỉ là tùy chọn thử nghiệm có cảnh báo, không phải khuyến nghị tăng tốc phổ quát.
- Không xóa Windows.old, model weights, project, conversation/session history, credentials, Docker volumes hoặc WSL virtual disks trong Clean All.
- Cleanup chỉ dùng allowlist đã review; không xóa đệ quy theo wildcard hoặc theo tên thư mục chung chung.
- Không tải và chạy script từ Internet không xác minh.
- Không thực thi lệnh tuỳ ý từ `tasks.json`.
- Không xoá driver hoặc file hệ thống khi chưa xác định chính xác mục tiêu.
- Có chế độ Dry Run/WhatIf cho tác vụ hỗ trợ.
- Mã nguồn cần được kiểm tra trước khi đóng gói; nếu phát hành rộng rãi nên ký code.

---

## 14. Kế hoạch phát triển theo giai đoạn

### Phase 1 – Nền tảng

- Tạo repo và cấu trúc thư mục.
- `Start.cmd` gọi PowerShell 5.1.
- Main menu và menu con.
- Kiểm tra Windows 10/11, quyền admin.
- Dashboard cơ bản.
- Logger và Error Handler.
- Kiểm tra encoding/console.

**Tiêu chí hoàn thành:** chạy được trên Windows 10 và 11, không cần cài runtime ngoài, menu không lỗi và log được.

### Phase 2 – Quick Commands & System Tools

- Quick Commands.
- Disk & System Maintenance cơ bản: phân tích/tối ưu HDD-SSD, CHKDSK, SFC và DISM.
- Mở các công cụ Windows.
- Thông tin phần cứng/hệ điều hành.
- Kiểm tra ổ đĩa, RAM, network.
- Xuất báo cáo TXT/JSON.

**Tiêu chí hoàn thành:** các lệnh mở đúng công cụ, quyền được kiểm tra, lỗi được hiển thị rõ.

### Phase 3 – Printer Support cơ bản

- Liệt kê máy in.
- Mở Printer Settings/Devices and Printers.
- Mở `printui /s /t2`.
- Kiểm tra/Restart Spooler.
- Dọn queue có xác nhận.
- Kiểm tra kết nối UNC.
- Hướng dẫn Credential Manager.
- Tạo Local Port theo wizard.
- Xuất báo cáo máy in.

**Tiêu chí hoàn thành:** kiểm thử với máy in USB và máy in chia sẻ LAN; không xoá nhầm driver hoặc queue ngoài lựa chọn.

### Phase 4 – Network & Printer Advanced

- Kiểm tra SMB.
- Kiểm tra RPC.
- Kiểm tra Firewall rules.
- Wizard tạo tài khoản scan.
- Wizard cấu hình quyền máy in.
- Policy tương thích RPC/Point and Print có backup và rollback.
- Không tự bật cấu hình yếu bảo mật.

**Tiêu chí hoàn thành:** mọi thay đổi có xác nhận, log, backup và rollback đã kiểm thử.

### Phase 5 – Post-Install & Safe Optimization

- Auto Optimize profiles: Audit, Balanced, Desktop, Low Resource/HDD, Laptop.
- Custom Optimize với Services Manager, Visual Effects, Startup Apps và Power Mode.
- SysMain/WSearch chỉ là tùy chọn có giải thích; Ndu không nằm trong preset.
- Dọn file tạm và Windows.old qua cơ chế Windows hỗ trợ.
- Kiểm tra Startup.
- DISM/SFC.
- Power settings.
- Cấu hình hiển thị Explorer.
- Windows Update/Defender status.
- Copilot app management và Windows Security status-only.
- Báo cáo tổng hợp.

**Tiêu chí hoàn thành:** không có tác vụ tối ưu nào tắt thành phần bảo mật hoặc làm giảm khả năng cập nhật theo mặc định.

### Phase 6 – AI & Developer Cleanup

- Scanner dung lượng theo ứng dụng và loại dữ liệu.
- Adapter Hugging Face, Ollama, pip, uv, npm, pnpm, Docker, WSL và IDE/AI app logs.
- Model, project, conversation, credential và WSL virtual disk được bảo vệ mặc định.
- Dùng CLI chính chủ, preview, confirm và verify.

**Tiêu chí hoàn thành:** không có thao tác xóa mù theo wildcard; kiểm thử cache purge và model retention; Docker không prune volumes; WSL không xóa VHDX.

### Phase 7 – Hoàn thiện và phát hành

- Test matrix Windows 10/11, Home/Pro.
- Kiểm thử quyền thường/Admin.
- Kiểm thử máy offline.
- Kiểm thử console tiếng Việt.
- Tạo README và hướng dẫn kỹ thuật viên.
- Đóng gói ZIP portable.
- Có phiên bản và changelog.

### Phase 8 – GUI (tuỳ chọn)

Chỉ thực hiện khi phiên bản console ổn định. GUI gọi chung lớp Core/Modules, không viết lại logic hệ thống.

---

## 14A. Tiêu chí đánh giá Auto Optimize

Không dùng “RAM trống” làm KPI duy nhất. Trước/sau tối ưu cần ghi nhận:

- Boot/login duration (nếu đo được ổn định; ghi rõ phương pháp đo).
- Startup apps enabled count và danh sách thay đổi.
- CPU utilization khi idle sau thời gian chờ cố định.
- Memory in use, available, committed/commit limit và top processes.
- Disk free space và dung lượng cache/temp được dọn.
- Service changes, notification mode và visual effects state.
- Defender/Firewall/Windows Update state phải không suy giảm.

So sánh trên cùng điều kiện (sau reboot, cùng thời gian chờ, không chạy update/scan/copy nền). Nếu số đo không đáng tin cậy thì báo “không đủ dữ liệu”, không bịa phần trăm cải thiện. Máy có RAM thấp nhưng committed memory cao cần khuyến nghị kiểm tra ứng dụng rò rỉ bộ nhớ, malware, dung lượng pagefile và cân nhắc nâng RAM; không hứa hẹn giải quyết chỉ bằng tweak.

## 15. Ma trận kiểm thử bắt buộc

| Môi trường | Kiểm thử |
|---|---|
| Windows 10 Home | Menu, dashboard, quick commands |
| Windows 10 Pro | Printer, policy, network |
| Windows 11 Home | Menu, dashboard, không có gpedit |
| Windows 11 Pro | RPC policy, printer, network |
| User thường | Chỉ xem thông tin và tác vụ không cần quyền cao |
| Administrator | Backup, repair, thay đổi cấu hình |
| Máy offline | Tất cả chức năng local; DISM RestoreHealth có thể cần source sửa chữa offline phù hợp |
| HDD | Analyze và Optimize/Defrag, CHKDSK các chế độ | 
| SSD SATA/NVMe | Optimize/TRIM, không ép defrag thủ công |
| Ổ hệ thống C: | CHKDSK /f và /r phải xử lý lịch restart đúng cách |
| Windows có corruption | DISM ScanHealth/RestoreHealth rồi SFC |
| Máy có máy in USB | Driver, spooler, queue |
| Máy làm print server | Share, quyền, spooler |
| Máy client | UNC, credential, Local Port |
| Máy không có máy in | Không crash, hiển thị trạng thái phù hợp |
| Auto Optimize | Audit/Preview trước Apply; kiểm thử từng profile và rollback |
| Services | SysMain/WSearch/Ndu: trạng thái, backup, apply riêng, restore |
| Visual Effects | Preset/custom, font smoothing, thumbnail và rollback |
| Windows Security | Chỉ đọc trạng thái; không tắt Defender/Firewall/Tamper Protection |
| Copilot | Phân biệt app consumer và legacy policy; không gỡ thành phần phụ thuộc |
| System Cleanup | Temp, Windows.old, dump/log có preview và skip file đang dùng |
| AI/Dev Cleanup | HF/Ollama/Python/Node/Docker/WSL/IDE; giữ models và user data |

Mọi tác vụ Registry/Policy phải có test:
1. Trạng thái ban đầu.
2. Backup.
3. Apply.
4. Verify.
5. Rollback.
6. Verify lại trạng thái cũ.

---

## 16. Đề xuất ưu tiên MVP

Không nên triển khai tất cả cùng lúc. Phiên bản đầu tiên nên có:

1. Menu CMD tiếng Việt.
2. Dashboard thông tin máy.
3. Quick Commands.
4. Disk & System Maintenance: Analyze/Optimize HDD-SSD, CHKDSK, SFC, DISM.
5. Mở công cụ Windows thường dùng.
6. Printer Support cơ bản.
7. Kiểm tra và restart Print Spooler.
8. Dọn hàng đợi in.
9. Kiểm tra kết nối máy in chia sẻ.
10. Mở Credential Manager và hỗ trợ Local Port.
11. Logger, backup và kiểm tra quyền.

Sau khi MVP chạy ổn định mới làm các tính năng Registry, SMB, RPC, Point and Print nâng cao.

### Quyết định công nghệ đề xuất

| Thành phần | Lựa chọn |
|---|---|
| Launcher | CMD `.cmd` |
| Runtime | Windows PowerShell 5.1 |
| UI | Console menu |
| Config | JSON |
| Log | TXT + JSONL |
| Backup | Registry export + JSON manifest |
| Packaging | Portable ZIP |
| Database | Không cần ở MVP |
| Internet | Không bắt buộc |
| GUI | Để giai đoạn sau |

---

## 17. Yêu cầu dành cho AI Coding Agent

Khi bắt đầu triển khai, AI coding agent phải tuân thủ:

1. Đọc toàn bộ tài liệu này trước khi code.
2. Tạo cấu trúc dự án và README.
3. Không viết một file PowerShell khổng lồ; tách Core, UI và Modules.
4. Không hard-code mật khẩu `123456` hoặc bất kỳ mật khẩu nào.
5. Không tự động áp dụng các cấu hình làm giảm bảo mật.
6. Mọi thay đổi Registry/Policy/Services phải có đọc trạng thái cũ, backup, xác nhận, verify và rollback nếu có thể.
7. Kiểm tra OS/build/edition trước khi chạy tính năng.
8. Không phụ thuộc WMIC.
9. Không giả định Windows Home có Group Policy Editor.
10. Dùng lệnh/cmdlet có sẵn; không yêu cầu cài module ngoài nếu chưa được người dùng đồng ý.
11. Có xử lý exception, exit code và log.
12. Tạo test cho từng module trước khi thêm tính năng tiếp theo.
13. Không báo tính năng hoàn thành nếu chưa chạy thử trên Windows tương ứng.
14. Ưu tiên MVP theo Phase 1 → Phase 3 trước.
15. Khi hoàn thành mỗi phase, cập nhật README, changelog và trạng thái test.
16. Auto Optimize phải có Audit/Preview, profile theo tình huống và Custom mode; không áp dụng một danh sách service chung cho mọi máy.
17. Không disable Defender, Firewall, Security Center, Tamper Protection hoặc Windows Update.
18. Ndu Start=4 không được đưa vào preset; chỉ hiển thị ở Advanced/Experimental với cảnh báo và rollback.
19. Cleanup phải phân biệt cache, logs, model weights, project, conversation, credential và unknown data.
20. Không xóa Ollama/Hugging Face models, Docker volumes, WSL VHDX, workspaceStorage hoặc project trong thao tác Clean All.
21. Không xóa Windows.old nếu người dùng chưa xác nhận mất khả năng rollback Windows.
22. Với ứng dụng AI/Dev, ưu tiên CLI chính chủ và đường dẫn được truy vấn từ cấu hình/biến môi trường; không đoán đường dẫn rồi xóa.

---

## 18. Tài liệu tham khảo chính thức

- [Microsoft – Windows 10 support has ended](https://support.microsoft.com/en-us/windows/deployment/updates-lifecycle/windows-10-support-has-ended-on-october-14-2025)
- [Microsoft Learn – Windows 11 RPC connection updates for print](https://learn.microsoft.com/en-us/troubleshoot/windows-client/printing/windows-11-rpc-connection-updates-for-print)
- [Microsoft Learn – Printers Policy CSP](https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-printers)

Các tài liệu Microsoft có thể được cập nhật theo từng build Windows. Trước khi phát hành các tính năng thay đổi bảo mật máy in, cần kiểm tra lại hướng dẫn tương ứng với phiên bản Windows thực tế.

---

## 19. Nguồn tham khảo mở và căn cứ kỹ thuật

Ưu tiên tài liệu chính chủ của Microsoft và tài liệu của chính dự án phần mềm. Không dùng các “debloat script” không rõ tác giả làm căn cứ để đặt preset mặc định.

### Windows optimization, services và security

- [Microsoft Support – Tips to improve PC performance in Windows](https://support.microsoft.com/en-us/windows/experience/performance-optimization/tips-to-improve-pc-performance-in-windows): Startup Apps, background activity, visual effects, power mode và Optimize Drives.
- [Microsoft Support – Search indexing in Windows](https://support.microsoft.com/en-us/windows/experience/performance-optimization/search-indexing-in-windows): phạm vi Classic/Enhanced indexing và điều chỉnh nội dung index.
- [Microsoft Learn – Troubleshoot Windows Search performance](https://learn.microsoft.com/en-us/troubleshoot/windows-client/shell-experience/windows-search-performance-issues): xử lý Search Indexer bằng cách loại trừ thư mục/điều chỉnh index; tài liệu lưu ý optimizer bên thứ ba có thể disable WSearch và làm Search không hoạt động.
- [Microsoft Learn – WindowsAI Policy CSP](https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-windowsai): `TurnOffWindowsCopilot` là policy legacy/deprecated, có phạm vi OS/edition và không áp dụng mọi trải nghiệm Copilot mới.
- [Microsoft Learn – Manage Windows Copilot](https://learn.microsoft.com/en-us/windows/client-management/manage-windows-copilot): quản lý/gỡ Copilot app và hướng AppLocker cho quản trị tổ chức.
- [Microsoft Learn – Configure Defender real-time protection](https://learn.microsoft.com/en-us/defender-endpoint/configure-real-time-protection-microsoft-defender-antivirus): Microsoft cảnh báo tắt real-time protection làm giảm đáng kể bảo vệ.
- [Microsoft Learn – Tamper Protection](https://learn.microsoft.com/en-us/defender-endpoint/manage-tamper-protection-microsoft-365-defender): bảo vệ cấu hình Defender khỏi bị thay đổi trái phép.

### Windows cleanup và storage

- [Microsoft Learn – Configure Storage Sense](https://learn.microsoft.com/en-us/windows/configuration/storage/storage-sense): chính sách dọn temporary files, Recycle Bin, Downloads và lịch chạy.
- [Microsoft Support – Manage drive space with Storage Sense](https://support.microsoft.com/en-us/windows/experience/storage-filemanagement/manage-drive-space-with-storage-sense): Storage Sense, Temporary Files và Windows.old.
- [Microsoft Support – Delete your previous version of Windows](https://support.microsoft.com/en-us/windows/deployment/install-upgrade/delete-your-previous-version-of-windows): xóa Windows.old sẽ mất khả năng quay về phiên bản trước.

### AI / Developer cache

- [Hugging Face – Manage Hub cache](https://huggingface.co/docs/huggingface_hub/guides/manage-cache): cấu trúc cache, `HF_HOME` và `HF_HUB_CACHE`.
- [Ollama – FAQ](https://github.com/ollama/ollama/blob/main/docs/faq.mdx): vị trí model trên Windows và biến `OLLAMA_MODELS`.
- [pip – Caching](https://pip.pypa.io/en/stable/topics/caching/): `pip cache dir`, cache Windows và cơ chế quản lý.
- [uv – Cache](https://docs.astral.sh/uv/concepts/cache/): `uv cache clean`, `uv cache dir` và phân biệt cache với persistent data.
- [npm – npm cache](https://docs.npmjs.com/cli/commands/npm-cache/): `npm cache verify` và `npm cache clean`.
- [Docker – Prune unused objects](https://docs.docker.com/engine/manage-resources/pruning): dọn images/containers/build cache; cần cẩn trọng với volumes.

### Nguyên tắc đánh giá nguồn

- Tài liệu Microsoft chính thức là nguồn chính cho Windows services, policies, Defender, Storage Sense và Copilot.
- Tài liệu chính chủ của Hugging Face/Ollama/Python/uv/npm/Docker là nguồn chính cho cache và model storage.
- Không tìm thấy căn cứ Microsoft đủ mạnh để khuyến nghị tắt SysMain hoặc đặt `Ndu\Start=4` như cách tăng tốc phổ quát. Vì vậy, hai mục này không được đưa vào Auto Optimize mặc định.
- Nếu tài liệu upstream thay đổi, adapter phải kiểm tra phiên bản CLI/app và cập nhật allowlist trước khi thực thi.

---

## 20. Kết luận

**TM-WinCare nên là một bộ công cụ kỹ thuật viên portable, lấy PowerShell làm lõi và CMD làm giao diện khởi chạy, có Safe Auto Optimize/Custom Optimize, Notifications & Quiet Mode, Disk Maintenance, Printer Support và AI & Developer Cleanup.**

Giá trị chính không nằm ở số lượng tweak Windows, mà nằm ở việc tập hợp các thao tác kỹ thuật thường dùng thành một quy trình có kiểm tra, có giải thích, có log và có thể khôi phục.

Hướng phát triển phù hợp nhất:

- Làm menu và Core trước.
- Hoàn thiện Quick Commands.
- Bổ sung Disk & System Maintenance cho HDD/SSD, CHKDSK, SFC và DISM.
- Ưu tiên Printer Support vì đây là nhu cầu thực tế và có nhiều thao tác lặp lại.
- Tiếp theo mở rộng Post-Install, Repair, Safe Optimization và AI & Developer Cleanup.
- Các cấu hình SMB/RPC/Point and Print phải được coi là công cụ xử lý tương thích nâng cao, không phải preset tối ưu mặc định.


---

## 20. Nguồn tham khảo bổ sung cho Auto Optimize và Notifications

Các action tối ưu phải ưu tiên hướng dẫn chính thức của Microsoft; không sao chép preset debloat không rõ nguồn:

- [Microsoft Support – Tips to improve PC performance in Windows](https://support.microsoft.com/en-us/windows/experience/performance-optimization/tips-to-improve-pc-performance-in-windows): startup apps, background activity, storage, visual effects, power mode, notifications và resource monitoring.
- [Microsoft Support – Configure startup applications in Windows](https://support.microsoft.com/en-us/windows/experience/startup-boot/configure-startup-applications-in-windows): quản lý ứng dụng tự chạy cùng Windows.
- [Microsoft Support – Notifications and Do Not Disturb in Windows](https://support.microsoft.com/en-us/windows/experience/notifications-and-do-not-disturb-in-windows): quản lý notification và chế độ Do Not Disturb.
- [Microsoft Support – Manage drive space with Storage Sense](https://support.microsoft.com/en-us/windows/experience/storage-filemanagement/manage-drive-space-with-storage-sense): dọn file tạm và Previous Windows Installation(s)/Windows.old qua giao diện hỗ trợ.
- [Microsoft Support – Defragment / optimize data drives](https://support.microsoft.com/en-us/windows/experience/storage-filemanagement/defragment-optimize-your-data-drives-in-windows): Windows tối ưu HDD và TRIM SSD theo loại ổ.
- [Microsoft Learn – Guidance on configuring system services](https://learn.microsoft.com/en-us/windows/iot/iot-enterprise/optimize/services): tham khảo vai trò dịch vụ; lưu ý hướng dẫn Windows IoT không được áp dụng máy móc cho mọi Windows client.
- [Microsoft Learn – Windows Search performance troubleshooting](https://learn.microsoft.com/en-us/troubleshoot/windows-client/shell-experience/windows-search-performance-issues): ưu tiên xử lý phạm vi indexing và nguyên nhân hiệu năng thay vì disable Search tùy tiện.

**Ghi chú:** tài liệu Microsoft về Windows IoT có danh sách service theo workload chuyên biệt; không lấy nguyên danh sách “disable/keep” đó làm preset cho Windows 10/11 desktop. Mọi service tweak cần kiểm chứng trên edition/build mục tiêu và workload thực tế.
