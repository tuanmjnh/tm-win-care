# TM-WinCare – Windows Optimization & Maintenance Toolkit

[![GitHub Release](https://img.shields.io/github/v/release/tuanmjnh/tm-win-care?style=flat-square&color=blue)](https://github.com/tuanmjnh/tm-win-care/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D6?style=flat-square&logo=windows)](https://microsoft.com/windows)

> **Language / Ngôn ngữ:** **English (Default)** | [🇻🇳 Tiếng Việt (Tài liệu hướng dẫn Tiếng Việt)](docs/README.vi.md)  
> **Platform Target:** **Windows 10** and **Windows 11** (Home / Pro / Enterprise)  
> **Version:** **1.2.0** | **Safe by Default • Zero Dependencies • Offline Capable**

TM-WinCare is an open-source, zero-dependency console toolkit designed for IT administrators, power users, and developers. It streamlines Windows post-installation setup, safe performance tuning, automated system repairs, LAN networking diagnostics, printer troubleshooting, and local AI/developer cache management.

---

## ⚡ Quick Start & Execution Methods

### Method 1: PowerShell Online One-Liner ❤️ (Recommended)

Run directly from Windows PowerShell without downloading or extracting any files. Open PowerShell (as Administrator) and paste:

#### 🔹 1. Launch the Full TM-WinCare Toolkit (All 12 Modules):
```powershell
irm https://raw.githubusercontent.com/tuanmjnh/tm-win-care/main/get.ps1 | iex
```

*Direct single-file script URL:*
```powershell
irm https://raw.githubusercontent.com/tuanmjnh/tm-win-care/main/dist/TM-WinCare-AIO.ps1 | iex
```

*DNS/ISP Bypassing Fallback (using Cloudflare 1.1.1.1 DoH):*
```powershell
iex (curl.exe -s --doh-url https://1.1.1.1/dns-query https://raw.githubusercontent.com/tuanmjnh/tm-win-care/main/dist/TM-WinCare-AIO.ps1 | Out-String)
```

#### 🔹 2. Fast Launch: Windows & Office License & IT Inventory Tool:
Instantly decodes 25-character product keys, motherboard serial, UUID, and syncs directly to Google Sheets or Form:
```powershell
irm https://raw.githubusercontent.com/tuanmjnh/tm-win-care/main/dist/Check-License.ps1 | iex
```

*DNS/ISP Bypassing Fallback:*
```powershell
iex (curl.exe -s --doh-url https://1.1.1.1/dns-query https://raw.githubusercontent.com/tuanmjnh/tm-win-care/main/dist/Check-License.ps1 | Out-String)
```

---

### Method 2: Standalone Double-Click Executable (No Commands Needed)

Ideal for field technicians carrying tools on a USB drive:

1. Navigate to the **[Releases](https://github.com/tuanmjnh/tm-win-care/releases/latest)** page.
2. Download your preferred package:
   - **[`TM-WinCare-AIO.cmd`](https://github.com/tuanmjnh/tm-win-care/releases/latest/download/TM-WinCare-AIO.cmd)**: Single-file launcher. Automatically requests elevation and runs the full toolkit.
   - **[`Check-License.cmd`](https://github.com/tuanmjnh/tm-win-care/releases/latest/download/Check-License.cmd)**: Standalone 1-click license decoder & IT inventory synchronizer.
   - **[`TM-WinCare-v1.2.0-Portable.zip`](https://github.com/tuanmjnh/tm-win-care/releases/latest/download/TM-WinCare-v1.2.0-Portable.zip)**: Full offline portable archive with modular code and catalog data.
3. Double-click `TM-WinCare-AIO.cmd` to start.

---

### Method 3: Clone from Source (Offline & Developers)

```powershell
git clone https://github.com/tuanmjnh/tm-win-care.git
cd tm-win-care
.\Start.cmd
```

---

## 🛡️ Core Design Principles

- **Safe by Default**: Inspect and audit first before applying changes.
- **No Blind De-bloating**: Never breaks Windows Defender, Windows Firewall, Tamper Protection, or Windows Update.
- **Explain & Confirm**: Clear explanations and risk ratings before modifying system state.
- **Automatic State Backups & Rollback**: Registry modifications and service states are automatically snapshotted in `Backups/` before applying optimizations.
- **No Hardcoded Credentials**: Passwords for local accounts (e.g. Scan-to-folder accounts) are read using `-AsSecureString` and never stored in plain text or logs.
- **AI & Developer Environment Safety**: Distinguishes between disposable caches (pip, uv, npm, Docker buildkit) and critical assets (Ollama weights, Hugging Face models, WSL virtual disks, and project source code).

---

## 📋 Toolkit Modules Overview

```text
=========================================================
                 TM-WINDOWS TOOLKIT                      
      Windows Optimization & Maintenance Toolkit         
=========================================================
  Operating System: Windows 11 Build 26100 | Privilege: [ADMIN]
---------------------------------------------------------
  [ 1] Dashboard / System Information
  [ 2] Windows Post-Install & Product Activation
  [ 3] Chế Độ Auto: Tự Động Tối Ưu Toàn Bộ Hệ Thống (Auto Optimize)
  [ 4] Disk & System Maintenance
  [ 5] Windows Repair (SFC / DISM / CHKDSK)
  [ 6] Network & LAN Support
  [ 7] Printer & Spooler Support
  [ 8] AI & Developer Environment Cleanup
  [ 9] Privacy, Notifications & Copilot
  [10] Accounts & Access Management
  [11] Quick Diagnostic Commands
  [12] Backup & State Restore
  [ 0] Exit
=========================================================
```

### Module Highlights:
1. **Dashboard**: Complete hardware and OS inspection (CPU, RAM, storage, IP, Spooler, Defender).
2. **Post-Install & Activation**: Hostname renaming, File Explorer view options, missing driver diagnostics, genuine Windows & Office 25-character Product Key activation (`slmgr.vbs` & `ospp.vbs`), and IT inventory management.
3. **Auto Optimize (Full Auto Care)**: 1-Click All-In-One Full System Auto Optimization pipeline (Temp & junk cleanup, Windows Update cache purge, dev caches, visual responsiveness tuning, lockscreen tips disable, SSD ReTrim, DNS flush, WinSxS component cleanup) plus custom profiles (Balanced, Desktop Performance, Low Resource/HDD, Laptop).
4. **Disk Maintenance**: Logical volumes, SSD Re-Trim, and CHKDSK modes (`/scan`, `/f`, `/r`).
5. **System Repair**: Sequential DISM Component Store repair (`/RestoreHealth`) followed by SFC (`/scannow`).
6. **Network Support**: IP overview, DNS flushing, DHCP renew, TCP port testing (SMB 445, RAW 9100), and SMB configuration review.
7. **Printer Support**: Print Spooler restart, stuck queue clearing, network UNC diagnostics, Scan-to-folder account generator, and Local Port creation wizard.
8. **AI & Developer Cleanup**: Purge pip, uv, npm caches, prune pnpm store, inspect Ollama LLM models, Docker builder pruning, and IDE logs.
9. **Privacy & Components**: Toggle Copilot button, taskbar widgets, and disable promotional suggestions.
10. **Accounts**: Local user inventory, user management, and Credential Manager shortcuts.
11. **Quick Commands**: Fast launcher for 20+ Windows diagnostic applets (devmgmt, diskmgmt, perfmon, ncpa, etc.).
12. **Backup & Restore**: View snapshot manifests and perform 1-click state rollback.

---

## 🔑 Fast License & IT Inventory Feature (`Check_License_Pro`)

A dedicated utility tailored for IT technicians deploying or auditing company workstations:
- Decodes **full 25-character product keys** for Windows and Microsoft Office from Registry, DigitalProductId, BackupProductKey, and BIOS ACPI MSDM tables.
- Retrieves Motherboard UUID, Model, and Serial Number via CIM.
- Exports records to **CSV (Appended)**, **TXT**, and **JSON**.
- **Syncs directly to Google Sheets API** or opens prefilled **Google Forms** for instant enterprise IT inventory tracking.

---

## 🛠️ Project Structure

```
tm-win-care/
├── config/              # Application settings (app.json)
├── data/                # JSON catalogs (quick-commands, profiles, cleanup targets)
├── dist/                # Packaged distribution files (AIO scripts, ZIP)
├── docs/                # Architecture specifications & Vietnamese documentation
│   ├── README.vi.md     # Tài liệu Tiếng Việt
│   └── TM-WinCare-Architecture-v1.2.md
├── scripts/             # Build and packaging script (build.ps1)
├── src/
│   ├── Core/            # Bootstrap, Logger, Admin, Backup, Restore, Menu
│   ├── UI/              # Colors, Tables, Prompts
│   ├── Modules/         # 12 functional toolkit modules
│   └── Main.ps1         # Application entry point
├── tests/Unit/          # Automated test suite (CoreTests, ModuleTests)
├── Start.cmd            # Offline Windows batch launcher
├── get.ps1              # Online bootstrap launcher
└── README.md            # Primary documentation (English)
```

---

## 🧪 Testing & Verification

Run the built-in automated test suite:
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { & .\tests\Unit\CoreTests.ps1; & .\tests\Unit\ModuleTests.ps1 }"
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
