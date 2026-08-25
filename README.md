# Han's Dotfiles for Omarchy & Hyprland

Personal dotfiles, native helper utilities, and system optimizations for Arch Linux, Omarchy, Hyprland, and Quickshell.

---

## Features

- **Multi-Deck Scratchpads (`special:deck_*`)**: Independent floating workspaces supporting split tiling, instant overlay dismissal on window eject (`Super + O`), and vertical deck navigation (`Super + Up/Down`).
- **Native Spatial Navigation (`nav-window`)**: Compiled C helper executing in under 2ms for directional window focus and scratchpad navigation.
- **Universal Turbo Downloader (`omarchy-download`)**: Unified aria2c (16 parallel connections) and yt-dlp wrapper with automatic clipboard link detection, Bilibili anti-403 referer injection, format extraction, and decoupled background file manager spawning.
- **Instant Zero-Flicker Window Resizing**: Disabled intermediate Wayland buffer scaling flood and tuned snappy layout transitions, eliminating black/white blank screens when resizing Chromium, OpenCode, and terminals.
- **Foot Terminal Optimization (`foot.ini`)**: Configured `resize-delay-ms = 20` for responsive, debounced redraws on tiling window resizing.
- **Spotlight Menu Animations**: Smooth cubic zoom and fade animation patch for the application launcher (`Super + Space`).
- **Navbar 1px Font Slider**: Patch enabling 1px fine-grained text scaling steps (`9px` to `20px`) in the monitor/display panel.
- **Ryzen Mobile Power Unlocker (`ryzenadj-power.service`)**: Sustained 25W-30W power limit on battery for AMD Ryzen 5 PRO 3500U.
- **Limine Dynamic Kernel Selector (`omarchy-default-kernel`)**: Automatic parsing of UKI entries and persistent post-update hooks.
- **Debloated Keybindings**: Preinstalled webapp shortcuts disabled in favor of clean user keybindings.
- **Aggressive NVMe Preload Daemon (`preload.conf`)**: Optimized predictive readahead engine with 60 parallel threads, 10s adaptive cycle, and 500KB map resolution for near-instant app and shared library launches.
- **CachyOS Performance Configuration**: BORE CPU scheduler, TCP BBRv3 + CAKE queueing, ZRAM optimization, and PipeWire real-time priority.
- **Programmer Keyboard Layout**: Clean US layout with direct quotes and Compose mapped to CapsLock.

---

## Custom Keybindings

| Keybinding | Action | Context |
| :--- | :--- | :--- |
| **`Alt + F`** | Toggle active scratchpad deck | Anywhere |
| **`Super + Up` / `Down`** | Slide between scratchpad decks | Anywhere |
| **`Super + Left` / `Right`** | Focus window or split tile (Native C IPC) | Anywhere |
| **`Super + E`** | Maximize window / Full width toggle | Anywhere |
| **`Super + T` / `Super + Shift + T`** | Toggle window floating / tiling | Anywhere |
| **`Super + N` / `Alt + Shift + F`** | Create new scratchpad deck | Anywhere |
| **`Super + W`** | Smart close window (preserves deck focus) | Anywhere |
| **`Super + O`** | Move window to / from active scratchpad deck (instant exit) | Anywhere |
| **`Super + Shift + O`** | Pop window out (float and pin across workspaces) | Anywhere |

---

## Repository Structure

```
~/dotfiles/
├── bootstrap.sh                 # Master setup script for configs and native helpers
├── AGENTS.md                    # Operational manual for AI coding agents
├── README.md                    # Documentation and keybindings
├── scripts/
│   ├── setup-cachyos.sh         # Optional CachyOS kernel and sysctl installer
│   ├── setup-preload.sh         # Aggressive NVMe preload daemon installer
│   ├── setup-ryzenadj.sh        # AMD Ryzen Mobile 25W-30W battery boost unlocker
│   ├── patch-smooth-menu.sh     # Spotlight animation patch for Super+Space
│   └── patch-navbar-font-slider.sh # 1px incremental font size slider patch
├── config/
│   ├── hypr/                    # Hyprland bindings, looknfeel, input, autostart
│   ├── omarchy/                 # Omarchy shell and menu customizations
│   ├── foot/                    # Terminal configuration (resize-delay-ms = 20)
│   ├── preload/                 # Aggressive NVMe preload daemon tuning
│   ├── bash/                    # Shell aliases (agyd)
│   ├── starship.toml            # Cross-shell prompt configuration
│   └── git/config               # Git identity and configuration
└── local/bin/
    ├── nav-window               # Compiled C 2D navigator
    ├── scratchpad-deck          # Multi-deck scratchpad engine
    ├── omarchy-download         # Turbo downloader (aria2c + yt-dlp)
    ├── omarchy-default-kernel   # Default boot kernel selector and Limine configurator
    ├── agyd                     # Script wrapper for agy permissions
    └── powerprofilesctl         # DBus power profile wrapper
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
