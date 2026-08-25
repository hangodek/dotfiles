# AGENTS.md — AI Agent Guidelines & Architecture Manual

> **Purpose**: This document provides operational rules, architectural explanations, and navigation guides for AI coding agents working on this dotfiles repository.

---

## 1. Critical Operational Rules (MANDATORY)

1. **GIT COMMIT & PUSH POLICY (STRICT)**:
   - **NEVER** run `git commit` or `git push` automatically.
   - **DO NOT** execute git commit/push as part of an implementation step or infer it from general approval.
   - You must **ONLY** run `git commit` and `git push` when the user **EXPLICITLY** gives the command (`"commit dan push"`, `"commit and push"`, or `"cp"`).
   - Always verify changes live with the user before waiting for their explicit commit command.
   - When committing, use the user's configured identity (`hangodek <icyfarhan@gmail.com>`).

2. **NO EMOJIS POLICY (STRICT)**:
   - **NEVER** output emojis in chat responses, git commit messages, script comments, or markdown documentation files.
   - Keep all responses clean, professional, direct, and emoji-free.

3. **EDIT REPOSITORY SOURCES, NOT SYMLINKS OR BACKUPS**:
   - Always edit files inside `~/dotfiles/` (e.g. `~/dotfiles/config/hypr/input.lua`), NOT `~/.config/...` directly and NEVER `.bak.*` files.
   - User configs in `~/.config/` and `~/.local/bin/` are symlinks managed by `bootstrap.sh`.

4. **SYSTEM MODIFICATIONS MUST BE SCRIPTED IN DOTFILES**:
   - If a fix modifies system files (like `/usr/share/omarchy/` or `/etc/`), **DO NOT** just run one-off `sudo` commands.
   - You **MUST** codify the fix as a reproducible script in `~/dotfiles/scripts/` (e.g. `scripts/patch-smooth-menu.sh`) and hook it into `~/dotfiles/bootstrap.sh`.

5. **VERIFY & RELOAD LIVE**:
   - Always reload the relevant component after changing configs:
     - Hyprland: `hyprctl reload`
     - Omarchy Shell / Top Bar / Menus: `omarchy-restart-shell`
     - Sysctl: `sudo sysctl --system`

6. **SAFE TESTING & ZERO LIVE SESSION DISRUPTION (STRICT)**:
   - **NEVER** run arbitrary `kill`, `hyprctl dispatch focuswindow`, or window manipulations targeting the active user workspace or the agent's own terminal (`agy`).
   - Do not risk closing or hijacking the user's active windows or killing the running agent process during tests.
   - Verify script logic using unit checks, headless execution, or dedicated sandbox environments.

---

## 2. Repository Architecture & Layout

```
~/dotfiles/
├── bootstrap.sh                 # Master restore script for configs, links, and patches
├── AGENTS.md                    # Instructions and rules for AI agents (this file)
├── README.md                    # Human-readable documentation and hardware details
├── scripts/
│   ├── setup-cachyos.sh         # CachyOS kernel, headers, sysctl, and rtkit installer
│   ├── setup-ryzenadj.sh        # AMD Ryzen Mobile 25W-30W battery boost unlocker
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
│   │       └── omarchy-menu.jsonc # App launcher menu customizations
│   ├── bash/
│   │   └── aliases.sh           # Shell aliases (agyd -> agy --dangerously-skip-permissions)
│   ├── starship.toml            # Fast cross-shell prompt configuration
│   └── git/
│       └── config               # Git user identity and aliases
└── local/
    └── bin/
        ├── agyd                 # Auto-permission wrapper for Antigravity CLI
        ├── omarchy-agent        # Default agent dispatcher
        ├── omarchy-default-agent# Agent switcher
        ├── omarchy-default-kernel# Default boot kernel switcher and Limine configurator
        ├── nav-window           # Compiled C 2D workspace & scratchpad navigator
        ├── scratchpad-deck      # Independent multi-deck floating workspace engine
        └── powerprofilesctl     # Native DBus wrapper for 1-click power profiles
```

---

## 3. Core Subsystems

### A. Independent Multi-Deck Scratchpads (`special:deck_*`)
- **Concept**: Omarchy uses dynamic virtual decks (`special:deck_1`, `special:deck_2`, `special:deck_3`, ...).
- **Behavior**:
  - Each deck is an independent floating workspace supporting dwindle split tiling.
  - `Super + Up` / `Super + Down`: Slide smoothly between scratchpad decks.
  - `Super + Left` / `Super + Right`: Navigate between split window tiles inside the current deck.
  - `Super + N` / `Alt + Shift + F`: Prompt the App Menu to launch an app in a new deck.
  - `Super + W`: Smart close that focuses the remaining deck when closing the last window in a deck.
  - `Alt + F`: Toggle overlay visibility.
- **Engine Scripts**: `~/dotfiles/local/bin/scratchpad-deck` and `~/dotfiles/local/bin/nav-window`.

---

### B. Performance & Low-Latency Network Stack
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
  - `vm.swappiness = 150` (ZRAM compression is faster than disk paging).
  - `vm.page-cluster = 0` (Single-page swap-in for immediate response).
- **Anti-Stutter Disk Writeback**:
  - `vm.dirty_bytes = 268435456` (256MB cap).
  - `vm.dirty_background_bytes = 67108864` (64MB).
- **Daemons**:
  - `ananicy-cpp`: Applies nice priorities to Hyprland, audio, and active games.
  - `rtkit-daemon`: Grants Real-Time Priority 99 to PipeWire audio threads.

---

### C. Keyboard Layout
- **Configuration File**: `~/dotfiles/config/hypr/input.lua`.
- **Settings**:
  - `kb_layout = "us"`
  - `kb_variant = ""` (Empty: never use dead keys).
  - `kb_options = "compose:caps,shift:both_capslock_cancel"`

---

### D. Shell UI & Spotlight Menu Animations (`Super + Space`)
- **Engine**: `omarchy-shell` / `quickshell`.
- **Patch Script**: `~/dotfiles/scripts/patch-smooth-menu.sh`.
- **Behavior**:
  - When `Super + Space` is pressed, the menu card smoothly zooms (`scale: 0.96 -> 1.00`) and fades (`opacity: 0.0 -> 1.0`) in 150 ms with `Easing.OutCubic`.
  - Closing fades and shrinks smoothly with immediate keyboard release.
  - Reload with `omarchy restart shell`.

---

## 4. Common Maintenance Commands

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

## 5. Clean Install & Restore Procedure

On a fresh Arch Linux / Omarchy install:

```bash
git clone git@github.com:hangodek/dotfiles.git ~/dotfiles

# Clean standard restore (links configs, compiles native C helpers, applies menu patch)
bash ~/dotfiles/bootstrap.sh

# Complete restore + CachyOS x86-64-v3 Kernel & Performance Suite
bash ~/dotfiles/bootstrap.sh --cachyos
```
