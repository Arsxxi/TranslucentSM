# TranslucentSM — Reworked by Arsxxi (fork of rounk-ctrl)
<p align="center">
  <img src="Assets/yamadaaa.png" width="550" alt="Yamadaaa">
</p>
A lightweight utility that makes the Windows Start Menu translucent/transparent.<br>
This app utilizes XAML Diagnostics to inject a dll into a process and modifies the XAML.



Original: [rounk-ctrl/TranslucentSM](https://github.com/rounk-ctrl/TranslucentSM) • Fork: [Arsxxi/TranslucentSM](https://github.com/Arsxxi/TranslucentSM) • Installer: `Setup_TranslucentSM_v0.6.10.exe`

> **Reworked by Arsxxi** — fork of [rounk-ctrl/TranslucentSM](https://github.com/rounk-ctrl/TranslucentSM) (GPL-3.0). Original ©2024 Rounak, this fork ©2026 Arsxxi, same license per GPL §5a. See [LICENSE](./LICENSE). Injection logic (XAML Diagnostics, CLSID `{36162BD3-3531-4131-9B8B-7FB1A991EF51}`) unchanged; changes are installer/startup only.
## Screenshots

Upstream (rounk-ctrl):

![image](https://github.com/rounk-ctrl/TranslucentSM/assets/70931017/4a569f8c-f66a-45d3-9841-07d4a39a5063)

![image](https://github.com/rounk-ctrl/TranslucentSM/assets/70931017/2987e096-7334-4172-a25b-0ddf9ee2665f)
## What's New in v0.6.10

- **No CMD popup** — `start.exe` rebuilt as `Windows` GUI (`SubSystem:Windows`, `mainCRTStartup`) instead of Console. Daemon hides console fallback too (`start/start.cpp`).
- **Hidden Task Scheduler logon task with 5s delay** — `schtasks /create /tn TranslucentSM /tr "'{app}\start.exe' --daemon" /sc onlogon /delay 0000:05 /rl limited /f` + `runhidden`. Replaces legacy `HKCU\...\Run`; installer also runs `--daemon` immediately so no reboot required.
- **User-choosable install dir** — Inno Setup 6 → `Setup_TranslucentSM_v0.6.10.exe` (`DefaultDirName={autopf}\TranslucentSM`, `DisableDirPage=no`). Admin UAC, but any folder works.
- **<2 MB daemon** — polling `StartMenuExperienceHost.exe` every 2s (`CreateToolhelp32Snapshot`), `VC-LTL 5.0.9`, `Release|x64`.
- **Packaging fixed** — `Package/Package.wapproj` now refs `StartTAP` (was broken `TAPdll`), version `0.6.10.0` (`Arsxxi (fork of Rounak)`).

## Installation

**Recommended:** Download `Setup_TranslucentSM_v0.6.10.exe` from [Releases](https://github.com/Arsxxi/TranslucentSM/releases) → pick any folder → `Install` (UAC) → Start Menu translucent immediately, and hidden 5s after every logon. No CMD window.

**Uninstall:** `Settings → Apps → TranslucentSM → Uninstall` (or Start Menu → Uninstall) — deletes the chosen dir, `schtasks /delete /tn TranslucentSM /f`, `taskkill /f /im start.exe`, and legacy `HKCU\Software\Microsoft\Windows\CurrentVersion\Run` cleanup.

**Manual (dev):** `msbuild start.sln /p:Configuration=Release /p:Platform=x64` after `Tools > NuGet Package Manager > Restore` (or `nuget restore`). Then `installer/TranslucentSM.iss` via `iscc` (Inno Setup 6) → `Setup_*.exe`.

## How it Works

`start.exe` (loader) finds `StartMenuExperienceHost.exe` PID, seeds `HKCU\SOFTWARE\TranslucentSM`, grants permissive ACLs, injects `StartTAP.dll` via `InitializeXamlDiagnosticsEx` (from `Windows.UI.Xaml.dll`). `StartTAP.dll` (`IObjectWithSite`/`IClassFactory`) watches `OnVisualTreeChange` and tweaks `AcrylicBorder`/`BackgroundElement`/`RootGrid` etc.; `misc.cpp:AddSettingsPanel` injects the flyout.

## Settings

All `REG_DWORD` under `HKEY_CURRENT_USER\SOFTWARE\TranslucentSM` (seeded on first run, permissive ACL for `ALL APPLICATION PACKAGES`/`Users`):

- `TintOpacity=30` — main acrylic brush
- `TintLuminosityOpacity=30` — luminosity brush
- `HideSearch=0` — hide search box
- `HideBorder=0` — hide white border (`AcrylicOverlay`)
- `HideRecommended=0` — hide recommended section
- `EditButton=1` — inject settings flyout

Values are 0-100. Live edits via the injected flyout (`misc.cpp` `SetVal`) apply instantly; registry edits otherwise need `taskkill /f /im StartMenuExperienceHost.exe` (TAP loads into a fresh process).

### `TintLuminosityOpacity`
Controls the luminosity brush (some secondary layer ig).

### `TintOpacity`
The main acrylic brush.

## Build

- Requires Visual Studio 2022 (v143) + Windows 10+ SDK. Open `start.sln` → `Tools > NuGet Package Manager > Restore` → `Release|x64`.
- `start` targets min `10.0.10240.0`, `StartTAP` targets min `10.0.18362.0`.
- Installer: `iscc installer/TranslucentSM.iss` (needs `x64/Release/start.exe` + `StartTAP.dll` + optional `installer/yamadaaa.bmp`). Output `Setup_TranslucentSM_v0.6.10.exe`.

## License

GPL-3.0 — same as upstream. See [LICENSE](./LICENSE). Modified version marked per §5a.
