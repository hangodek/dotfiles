# Han's Dotfiles for Omarchy & Hyprland

Personal dotfiles, native helper utilities, and system optimizations for Arch Linux, Omarchy, Hyprland, and Quickshell.

---

## Features

- **Native Spatial Navigation (`nav-window`)**: Compiled C helper executing in under 1ms for direct 2D directional window focus (`Super + Arrow keys`).
- **Full-Width Mode (`Super + E`)**: Dedicated full-width maximization toggle featuring dual visual feedback with an illuminated top bar indicator (`󰊓`) and a dynamic 3px glowing amber window border.
- **Universal Turbo Downloader (`omarchy-download`)**: Unified aria2c (16 parallel connections) and yt-dlp wrapper with automatic clipboard link detection, Bilibili anti-403 referer injection, format extraction, and decoupled background file manager spawning.
- **Instant Zero-Flicker Window Resizing**: Disabled intermediate Wayland buffer scaling flood and tuned snappy layout transitions, eliminating black/white blank screens when resizing Chromium, OpenCode, and terminals.
- **Foot Terminal Optimization (`foot.ini`)**: Configured `resize-delay-ms = 20` for responsive, debounced redraws on tiling window resizing.
- **Spotlight Menu Animations**: Smooth cubic zoom and fade animation patch for the application launcher (`Super + Space`).
- **Navbar 1px Font Slider**: Patch enabling 1px fine-grained text scaling steps (`9px` to `20px`) in the monitor/display panel.
- **Limine Dynamic Kernel Selector (`omarchy-default-kernel`)**: Automatic parsing of UKI entries and persistent post-update hooks.
- **Debloated Keybindings**: Preinstalled webapp shortcuts disabled in favor of clean user keybindings.
- **Low-Latency PipeWire & Real-Time Audio Engine**: Configured native sample rates (`44.1kHz` to `96kHz`), enforced 512-sample quantum headroom, 1024-sample WirePlumber ALSA DMA buffer headroom, DAC anti-sleep, and real-time priority limits for crackle-free DSP audio.
- **Aggressive NVMe Preload Daemon (`preload.conf`)**: Optimized predictive readahead engine with 60 parallel threads, 10s adaptive cycle, and 500KB map resolution for near-instant app and shared library launches.
- **CachyOS BORE + LTO Performance Suite**: Clang/LLVM Link-Time Optimized kernel with BORE CPU scheduler, TCP BBRv3 + CAKE queueing, ZRAM optimization, and PipeWire real-time priority.
- **Programmer Keyboard Layout**: Clean US layout with direct quotes and Compose mapped to CapsLock.

---

## Custom Keybindings

| Keybinding | Action | Description |
| :--- | :--- | :--- |
| **`Super + Return`** | Launch Terminal | Standard Omarchy terminal in active working directory |
| **`Super + O`** | Pop window out | Float and pin active window across all workspaces (native Omarchy) |
| **`Super + W`** | Close window | Native Hyprland clean window close |
| **`Super + E`** | Maximize / Full width | Toggle full-width mode with glowing amber border & bar indicator |
| **`Super + T` / `Shift + T`** | Toggle Float / Tile | Toggle window between floating and tiled layout |
| **`Super + Left` / `Right`** | Focus horizontal tile | Instant < 1ms native C socket directional focus |
| **`Super + Up` / `Down`** | Focus vertical tile | Instant < 1ms native C socket directional focus |
| **`Super + Shift + Arrows`** | Swap window tile | Swap active window position in layout tree |
| **`Super + -` / `Super + =`** | Resize window 10% | Step-by-step 10% window resizing |
| **`Super + S`** | Toggle Scratchpad | Native Hyprland scratchpad overlay (`special:scratchpad`) |
| **`Super + Alt + S`** | Move to Scratchpad | Send active window to native scratchpad overlay |

---

## Repository Structure

```
~/dotfiles/
├── bootstrap.sh                 # Master setup script for configs and native helpers
├── AGENTS.md                    # Operational manual for AI coding agents
├── README.md                    # Documentation and keybindings
├── scripts/
│   ├── restore-system-patches.sh # Master system restorer and Pacman post-update hook
│   ├── setup-cachyos.sh         # Optional CachyOS kernel and sysctl installer
│   ├── setup-preload.sh         # Aggressive NVMe preload daemon installer
│   ├── setup-audio-performance.sh # Real-time audio limits and DAC power-save installer
│   ├── patch-smooth-menu.sh     # Spotlight animation patch for Super+Space
│   ├── patch-navbar-font-slider.sh # 1px incremental font size slider patch
│   └── patch-fullwidth-indicator.sh # Top bar full-width mode indicator patch
├── config/
│   ├── hypr/                    # Hyprland bindings, looknfeel, input, autostart
│   ├── omarchy/                 # Omarchy shell and menu customizations
│   ├── pipewire/                # PipeWire native clock rates and quantum buffer headroom
│   ├── wireplumber/             # WirePlumber ALSA DMA headroom and DAC anti-sleep
│   ├── foot/                    # Terminal configuration (resize-delay-ms = 20)
│   ├── preload/                 # Aggressive NVMe preload daemon tuning
│   ├── bash/                    # Shell aliases (agyd)
│   ├── starship.toml            # Cross-shell prompt configuration
│   └── git/config               # Git identity and configuration
└── local/bin/
    ├── nav-window               # Compiled C 2D spatial window navigator
    ├── omarchy-download         # Turbo downloader (aria2c + yt-dlp)
    ├── omarchy-default-kernel   # Default boot kernel selector and Limine configurator
    ├── powerprofilesctl         # Native DBus wrapper for 1-click power profiles
    ├── agyd                     # Auto-permission wrapper for Antigravity CLI
    └── omarchy-agent            # Default agent dispatcher
```

---

## Installation & Restore

On a fresh Arch Linux / Omarchy installation:

```bash
git clone git@github.com:hangodek/dotfiles.git ~/dotfiles

# Standard restore (symlinks configs, compiles native helpers, applies patches)
bash ~/dotfiles/bootstrap.sh

# Optional: Complete restore with CachyOS Kernel & Performance Suite
bash ~/dotfiles/bootstrap.sh --cachyos
```
