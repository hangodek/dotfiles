# 🤖 AGENTS.md — AI Agent Guidelines & Architecture Manual

> **Purpose**: This document provides strict operational rules, architectural explanations, and navigation guides for AI coding agents (Antigravity, Claude, ChatGPT, Cursor, etc.) working on this dotfiles repository.

---

## ⚠️ 1. Critical Operational Rules (MANDATORY)

1. **GIT COMMIT & PUSH POLICY**:
   - **NEVER** run `git commit` or `git push` automatically unless the user **EXPLICITLY** commands you with `"commit dan push"` or `"commit and push"`.
   - Always verify changes live with the user before asking or waiting for the commit instruction.
   - When committing, use the user's configured identity (`hangodek <icyfarhan@gmail.com>`).

2. **EDIT REPOSITORY SOURCES, NOT SYMLINKS OR BACKUPS**:
   - Always edit files inside `~/dotfiles/` (e.g. `~/dotfiles/config/hypr/input.lua`), NOT `~/.config/...` directly and NEVER `.bak.*` files.
   - User configs in `~/.config/` and `~/.local/bin/` are symlinks managed by `bootstrap.sh`.

3. **SYSTEM MODIFICATIONS MUST BE SCRIPTED IN DOTFILES**:
   - If a fix modifies system files (like `/usr/share/omarchy/` or `/etc/`), **DO NOT** just run one-off `sudo` commands.
   - You **MUST** codify the fix as a reproducible script in `~/dotfiles/scripts/` (e.g. `scripts/patch-smooth-menu.sh`) and hook it into `~/dotfiles/bootstrap.sh`.

4. **VERIFY & RELOAD LIVE**:
   - Always reload the relevant component after changing configs:
     - Hyprland: `hyprctl reload`
     - Omarchy Shell / Top Bar / Menus: `omarchy restart shell`
     - Sysctl: `sudo sysctl --system`

---

## 💻 2. Target Machine & Environment

| Component | Specification |
| :--- | :--- |
| **Hardware** | **Lenovo ThinkPad X395** |
| **CPU / GPU** | AMD Ryzen 5 PRO 3500U with Radeon Vega 8 Mobile Graphics |
| **RAM / Swap** | 16 GB Physical RAM + 13.6 GB ZRAM (`zstd`) |
| **OS & WM** | Arch Linux (**Omarchy**) + **Hyprland** (Wayland) + **Quickshell** |
| **Active Kernel** | **`linux-cachyos`** (BORE Scheduler, `-O3 -march=x86-64-v3`, ThinLTO) |
| **Audio Stack** | PipeWire 32-bit Float + Realtek ALC257 DAC + `rtkit-daemon` (Real-Time Priority 99) |
| **Default Browser** | **Microsoft Edge** (`microsoft-edge.desktop`) |
| **Default Shell** | Fish / Bash with Starship Prompt |

---

## 📂 3. Repository Architecture & Layout

```
~/dotfiles/
├── bootstrap.sh                 # Master restore script for configs, links, and patches
├── AGENTS.md                    # Instructions and rules for AI agents (this file)
├── README.md                    # Human-readable documentation and hardware details
├── scripts/
│   ├── setup-cachyos.sh         # CachyOS kernel, headers, sysctl, and rtkit installer
│   └── patch-smooth-menu.sh     # Spotlight zoom & fade animation patch for Super+Space
├── config/
│   ├── hypr/
│   │   ├── input.lua            # Keyboard layout, mouse/trackpad speed, gestures
│   │   ├── bindings.lua         # Personal keybindings (scratchpads, navigation, apps)
│   │   ├── looknfeel.lua        # Window borders, gaps, animations, decoration
│   │   ├── monitors.lua         # Display scaling, resolution, refresh rate
│   │   └── autostart.lua        # Personal background daemons and startup apps
│   ├── omarchy/
│   │   ├── shell.json           # Top bar layout, transparency, and widget placement
│   │   └── extensions/
│   │       └── omarchy-menu.jsonc # App launcher menu customizations (Antigravity option)
│   ├── bash/
│   │   └── aliases.sh           # Shell aliases (agyd -> agy --dangerously-skip-permissions)
│   ├── starship.toml            # Fast cross-shell prompt configuration
│   └── git/
│       └── config               # Git user identity and aliases
└── local/
    └── bin/
        ├── agyd                 # Auto-permission wrapper for Google Antigravity CLI
        ├── omarchy-agent        # Default agent dispatcher with agy floating TUI support
        ├── omarchy-default-agent# Agent switcher supporting Antigravity (agy)
        ├── nav-window           # Compiled C 2D workspace & scratchpad tile navigator (1.74ms)
        ├── scratchpad-deck      # Independent multi-deck floating workspace engine
        └── powerprofilesctl     # Native DBus wrapper for instant 1-click power profiles
```

---

## 🧠 4. Core Subsystems & How They Work

### A. Independent Multi-Deck Scratchpads (`special:deck_*`)
- **Concept**: Instead of a single toggle scratchpad, Omarchy uses dynamic virtual decks (`special:deck_1`, `special:deck_2`, `special:deck_3`, ...).
- **Behavior**:
  - Each deck is a completely independent floating workspace supporting dwindle split tiling.
  - `Super + Up` / `Super + Down`: Slide smoothly between scratchpad decks.
  - `Super + Left` / `Super + Right`: Navigate between split window tiles inside the current deck.
  - `Super + N` / `Alt + Shift + F`: Prompt the App Menu to launch a new app in a new deck.
  - `Super + W`: Smart close. If you close the last window in Deck 3, it seamlessly focuses Deck 2 without hiding the overlay.
  - `Alt + F`: Toggle overlay visibility on/off.
- **Engine Scripts**: `~/dotfiles/local/bin/scratchpad-deck` and `~/dotfiles/local/bin/nav-window`.

---

### B. CachyOS Performance & Low-Latency Network Stack
- **BORE CPU Scheduler**: Burst-Oriented Response Enhancer guarantees that interactive UI threads and audio streams preempt background compiling without micro-stutter.
- **TCP BBRv3 + CAKE Queueing**:
  - Module loaded via `/etc/modules-load.d/bbr.conf` (`tcp_bbr`).
  - Configured in `/etc/sysctl.d/99-bbr.conf`:
    ```ini
    net.core.default_qdisc = cake
    net.ipv4.tcp_congestion_control = bbr
    net.ipv4.tcp_fastopen = 3
    ```
- **ZRAM Optimizations**:
  - `vm.swappiness = 150` (Tells kernel ZRAM compression is faster than disk re-reading).
  - `vm.page-cluster = 0` (Single-page swap-in for instant response).
- **Anti-Stutter Disk Writeback**:
  - `vm.dirty_bytes = 268435456` (256MB cap prevents disk write stalling bursts).
  - `vm.dirty_background_bytes = 67108864` (64MB).
- **Daemons**:
  - `ananicy-cpp`: Automatically applies nice priorities to Hyprland, audio, and active games.
  - `rtkit-daemon`: Grants Real-Time Priority 99 to PipeWire audio threads.

---

### C. Keyboard Layout & Programming Quotes
- **Configuration File**: `~/dotfiles/config/hypr/input.lua`.
- **Settings**:
  - `kb_layout = "us"`
  - `kb_variant = ""` (Must stay empty! NEVER use `intl` dead keys because dead keys break double quotes `""`, single quotes `''`, and backticks ```` ```` during programming).
  - `kb_options = "compose:caps,shift:both_capslock_cancel"`

---

### D. Shell UI & Spotlight Menu Animations (`Super + Space`)
- **Quickshell Engine**: `omarchy-shell` / `quickshell`.
- **Patch Script**: `~/dotfiles/scripts/patch-smooth-menu.sh`.
- **Behavior**:
  - When `Super + Space` is pressed, the menu card smoothly zooms (`scale: 0.96 ➔ 1.00`) and fades (`opacity: 0.0 ➔ 1.0`) in **150–160 ms** with `Easing.OutCubic`.
  - Closing fades and shrinks smoothly with immediate keyboard release.
  - To apply edits to QML files, always run `omarchy restart shell`.

---

## 🛠️ 5. Common Maintenance Commands for AI Agents

```bash
# Validate and reload Hyprland after editing config/hypr/
hyprctl reload

# Restart Omarchy UI Shell after patching QML files
omarchy restart shell

# Check active TCP congestion control and queueing
sysctl net.ipv4.tcp_congestion_control net.core.default_qdisc

# Check active kernel and scheduler
uname -r

# Check running daemons
systemctl is-active ananicy-cpp rtkit-daemon

# Check Git status without modifying history
git -C ~/dotfiles status
```

---

## 🔄 6. Clean Install / Restore Procedure

On a fresh Arch Linux / Omarchy install:

```bash
git clone git@github.com:hangodek/dotfiles.git ~/dotfiles

# Clean standard restore (links configs, compiles native C helpers, applies menu patch)
bash ~/dotfiles/bootstrap.sh

# Complete restore + CachyOS x86-64-v3 Kernel & Performance Suite
bash ~/dotfiles/bootstrap.sh --cachyos
```
