# Han's Dotfiles for Omarchy & Hyprland

Personal dotfiles, custom window management subsystems, and low-latency system optimizations for Omarchy Linux (Arch Linux + Hyprland + Quickshell).

---

## 🖥️ System & Software Environment

| Component | Tested Version / Environment |
| :--- | :--- |
| **Operating System** | Arch Linux (Rolling) |
| **Omarchy Suite** | `v4.0.0` |
| **Window Manager** | Hyprland `v0.56.2` (Wayland `1.26.0`) |
| **Shell & UI** | Quickshell `v0.3.0` |
| **Active Kernel** | `linux-cachyos 7.1.8-1` (BORE Scheduler, `-O3 -march=x86-64-v3`, ThinLTO) |
| **Audio Server** | PipeWire 32-bit Float + `rtkit-daemon` (Real-Time Priority 99) |
| **Default Terminal** | Foot / Alacritty / Ghostty |
| **Default Shell** | Fish / Bash with Starship Prompt |

---

## Upstream Omarchy vs Custom Setup Comparison

| Feature Area | Upstream Omarchy | Custom Setup |
| :--- | :--- | :--- |
| Incremental Resizing | Unbound / manual mouse dragging. | `resize-step` (`Super + [` and `Super + ]`) in 10% monitor width increments ($1.47\text{ms}$). |
| Scratchpad System | Single monolithic overlay (`special:scratchpad`). | Multi-Deck Engine (`scratchpad-deck`) with independent virtual workspaces (`special:deck_*`). |
| Spatial Navigation | Basic focus cycling. | `nav-window` (`Super + Arrow`) navigating across split window tiles and scratchpad decks ($1.74\text{ms}$). |
| App Menu Animations | Standard instant/flat popup. | Smooth Spotlight zoom and fade patch (`patch-smooth-menu.sh`) in 150ms. |
| AI Agent Ecosystem | Standard agent switcher. | Antigravity CLI (`agy`, `agyd`) with floating TUI overlay (`Super + Shift + Ctrl + A`). |
| Power Management | Generic shell switcher. | Native DBus `powerprofilesctl` wrapper for 1-click Top Bar switching. |
| Kernel & Network Stack | Stock Arch Linux kernel + default sysctl. | `linux-cachyos` (BORE scheduler), TCP BBRv3 + CAKE queueing, 150 swappiness ZRAM, and PipeWire RTKit. |
| Keyboard Layout | US International with dead keys. | Clean US layout with direct programmer quotes and Compose on CapsLock. |
| Restoration | Manual configuration. | Clean modular `bootstrap.sh` script with optional `--cachyos` performance installer. |

---

## Core Subsystems & Features

### 1. Incremental Window Resizer (`Super + ]` / `Super + [`)
- Compiled native C binary (`local/bin/resize-step`) with $\mathbf{1.47\text{ ms}}$ execution latency.
- Dynamically queries monitor resolution and resizes the focused window in clean 10% monitor width steps without touching the mouse.

### 2. Independent Multi-Deck Scratchpads (`special:deck_*`)
- Replaces standard monolithic scratchpads with dynamic, independent virtual workspaces (`special:deck_1`, `special:deck_2`, `special:deck_3`, ...).
- Each deck supports dwindle split tiling, allowing side-by-side terminal workflows inside a floating overlay.
- `Super + Up` / `Super + Down`: Slide smoothly between scratchpad decks.
- `Super + Left` / `Super + Right`: Focus between window tiles within the current deck.
- `Super + N` / `Alt + Shift + F`: Launch a new application in a newly created deck.
- `Super + W`: Smart close that automatically transitions focus to remaining decks when the last window in a deck closes.

### 3. Native C Window & Deck Navigator (`nav-window`)
- Compiled native C helper (`local/bin/nav-window`) executing in $\mathbf{1.74\text{ ms}}$.
- Intelligently handles directional window focus in 2D space and seamlessly navigates across multi-deck scratchpads.

### 4. CachyOS Performance & Low-Latency Network Stack
- **BORE CPU Scheduler**: Burst-Oriented Response Enhancer prioritizing interactive UI threads, rendering, and audio streams.
- **TCP BBRv3 + CAKE Queueing**: Loaded via `/etc/modules-load.d/bbr.conf` and configured in `/etc/sysctl.d/99-bbr.conf` for minimum bufferbloat and fast throughput.
- **ZRAM Optimization**: `vm.swappiness = 150` with single-page swap-in (`vm.page-cluster = 0`).
- **Anti-Stutter Writeback**: `vm.dirty_bytes = 268435456` (256MB cap) preventing disk write stalling.
- **RTKit Priority**: PipeWire audio threads run at Real-Time Priority 99 via `rtkit-daemon`.

### 5. Google Antigravity AI Agent Integration (`agy` & `agyd`)
- Integrated into Omarchy's agent switcher (`Setup ➔ Defaults ➔ Agent` and `Install ➔ AI`).
- `agyd`: Standalone wrapper executing `agy --dangerously-skip-permissions` for uninterrupted autonomous agent operations.
- `Super + Shift + Ctrl + A`: Dedicated keybinding launching Antigravity in an Omarchy floating TUI window.

### 6. Smooth App Menu Animations (`Super + Space`)
- Patched via `scripts/patch-smooth-menu.sh`.
- Menu card features hardware-accelerated zoom (`scale: 0.96 -> 1.00`) and fade (`opacity: 0.0 -> 1.0`) in 150ms using `Easing.OutCubic`.
- Instant keyboard dismissal on escape.

---

## Repository Architecture

```
~/dotfiles/
├── bootstrap.sh                 # Master restore script for configs, links, and patches
├── AGENTS.md                    # Operational manual and rules for AI coding agents
├── README.md                    # Documentation and system manual (this file)
├── scripts/
│   ├── setup-cachyos.sh         # CachyOS kernel, headers, sysctl, and rtkit installer
│   └── patch-smooth-menu.sh     # Spotlight zoom and fade animation patch for Super+Space
├── config/
│   ├── hypr/
│   │   ├── bindings.lua         # Personal keybindings (navigation, scratchpads, resizing)
│   │   ├── input.lua            # Keyboard layout, trackpad speed, gestures
│   │   ├── looknfeel.lua        # Window borders, gaps, curves, workspace animations
│   │   ├── monitors.lua         # Display scaling, resolution, refresh rate
│   │   └── autostart.lua        # Personal background daemons and startup apps
│   ├── omarchy/
│   │   ├── shell.json           # Top bar layout, widgets, transparency
│   │   └── extensions/
│   │       └── omarchy-menu.jsonc # App launcher menu extensions (Antigravity)
│   ├── bash/
│   │   └── aliases.sh           # Shell aliases (agyd wrapper)
│   ├── starship.toml            # Cross-shell prompt configuration
│   └── git/
│       └── config               # Git user identity and aliases
└── local/
    └── bin/
        ├── nav-window           # Compiled C 2D workspace & scratchpad navigator (1.74ms)
        ├── resize-step          # Compiled C 10% incremental window resizing helper (1.47ms)
        ├── scratchpad-deck      # Independent multi-deck floating workspace engine
        ├── agyd                 # Auto-permission wrapper for Google Antigravity CLI
        ├── omarchy-agent        # Default agent dispatcher with agy floating TUI support
        ├── omarchy-default-agent# Agent switcher supporting Antigravity (agy)
        └── powerprofilesctl     # Native DBus wrapper for instant 1-click power profiles
```

---

## Keybindings Reference

| Keybinding | Action | Context |
| :--- | :--- | :--- |
| `Super + T` | Toggle window floating / tiling | Focused Window |
| `Super + Shift + Left` | Move window left in layout tree | Focused Window |
| `Super + Shift + Right` | Move window right in layout tree | Focused Window |
| `Super + Shift + Up` | Move window up in layout tree | Focused Window |
| `Super + Shift + Down` | Move window down in layout tree | Focused Window |
| `Super + Left` | Focus left window / split tile | Anywhere |
| `Super + Right` | Focus right window / split tile | Anywhere |
| `Super + Up` | Focus up / slide to previous scratchpad deck | Anywhere |
| `Super + Down` | Focus down / slide to next scratchpad deck | Anywhere |
| `Super + ]` | Expand window width by 10% of monitor width | Anywhere |
| `Super + [` | Shrink window width by 10% of monitor width | Anywhere |
| `Alt + F` | Toggle active scratchpad deck visibility | Anywhere |
| `Super + N` | Create a new scratchpad deck via App Menu | Anywhere |
| `Alt + Shift + F` | Create a new scratchpad deck (alternative shortcut) | Anywhere |
| `Super + W` | Smart close window (preserves overlay focus on remaining decks) | Anywhere |
| `Super + O` | Move window to / from scratchpad deck | Anywhere |
| `Super + Shift + O` | Pop window out (float, pin across workspaces, always on top) | Anywhere |
| `Super + Shift + Ctrl + A` | Launch Antigravity AI CLI in floating TUI window | Anywhere |

---

## 🔬 Performance Benchmarks & Empirical Proof

> **Tested on this System Specification**:
>
> | Component | Specification |
> | :--- | :--- |
> | **Hardware** | Lenovo ThinkPad X395 |
> | **CPU / GPU** | AMD Ryzen 5 PRO 3500U with Radeon Vega 8 Mobile Graphics |
> | **RAM / Swap** | 16 GB Physical RAM + 13.6 GB ZRAM (`zstd`) |
> | **OS & WM** | Arch Linux (Omarchy) + Hyprland (Wayland) + Quickshell |
> | **Active Kernel** | `linux-cachyos` (BORE Scheduler, `-O3 -march=x86-64-v3`, ThinLTO) |
>
> All tests are 100% automated, process-isolated, and reproducible. Run `bash tests/run-all-tests.sh` to execute the live test suite on your own machine.

### 1. Latency: Compiled Native C Helpers vs Legacy Scripts

Tested with 30 consecutive iterations measuring end-to-end execution latency:

| Subsystem / Keystroke | Legacy Implementation | Compiled Native C (`gcc -O3`) | Minimum Latency | Speedup | Result |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`nav-window`** (`Super+Arrow`) | 21.81 ms (Bash + `hyprctl` + `jq`) | **1.74 ms** (Native C Direct IPC) | **1.55 ms** | **12.5x Faster** | **PASS** ✅ |
| **`resize-step`** (`Super+[` / `Super+]`) | 60.73 ms (Bash + 2×`hyprctl` + `awk`) | **1.47 ms** (Native C Direct Socket) | **1.29 ms** | **41.3x Faster** | **PASS** ✅ |

---

### 2. How to Run the Automated Benchmark Suite

To run the automated benchmark suite on your machine:

```bash
bash ~/dotfiles/tests/run-all-tests.sh
```

---

## Quick Restore & Fresh Install Procedure

On a fresh Arch Linux / Omarchy installation:

```bash
git clone git@github.com:hangodek/dotfiles.git ~/dotfiles

# Standard restore (symlinks, configs, native C helpers, menu animation patch)
bash ~/dotfiles/bootstrap.sh

# Complete restore + CachyOS x86-64-v3 Kernel & Performance Suite
bash ~/dotfiles/bootstrap.sh --cachyos
```
