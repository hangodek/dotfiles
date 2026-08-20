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
| Grid Snapping | None. Basic floating toggle only. | Interactive Tactile Grid HUD (`Super + T`) on Wayland Layer 3. |
| Grid Configuration | None. Rigid automatic dwindle tree. | In-Menu Config (`Super + Space` -> Setup -> Tactile Grid) for presets, column weights, and gaps. |
| New Window Gap Filling | None. Spawns in background or over floating windows. | Real-time `tactile-autofill` daemon that snaps new windows into unoccupied grid gaps with 0px error. |
| Window Spatial Swapping | `hl.dsp.window.swap` (deforms and forces small windows into large slots). | Smart Spatial Swapper (`swap-window`) preserving exact window sizes and proportions. |
| Incremental Resizing | Unbound / manual mouse dragging. | `resize-step` (`Super + [` and `Super + ]`) in 10% monitor width increments. |
| Scratchpad System | Single monolithic overlay (`special:scratchpad`). | Multi-Deck Engine (`scratchpad-deck`) with independent virtual workspaces (`special:deck_*`). |
| App Menu Animations | Standard instant/flat popup. | Smooth Spotlight zoom and fade patch (`patch-smooth-menu.sh`) in 150ms. |
| AI Agent Ecosystem | Standard agent switcher. | Antigravity CLI (`agy`, `agyd`) with floating TUI overlay (`Super + Shift + Ctrl + A`). |
| Power Management | Generic shell switcher. | Native DBus `powerprofilesctl` wrapper for 1-click Top Bar switching. |
| Kernel & Network Stack | Stock Arch Linux kernel + default sysctl. | `linux-cachyos` (BORE scheduler), TCP BBRv3 + CAKE queueing, 150 swappiness ZRAM, and PipeWire RTKit. |
| Keyboard Layout | US International with dead keys. | Clean US layout with direct programmer quotes and Compose on CapsLock. |
| Restoration | Manual configuration. | Master `bootstrap.sh` script with optional `--cachyos` automated installer. |

---

## Core Subsystems & Features

### 1. Tactile Grid HUD (`Super + T`)
- An interactive on-screen grid overlay rendered on native Wayland Layer 3 (`WlrLayer.Overlay`), guaranteed to display on top of all windows and fullscreen surfaces.
- Press two keys to snap the active window to the bounding box spanning between those tiles (e.g. `Q` then `D` for Full Screen, `Q` then `A` for Left 1/3, `W` then `D` for Right 2/3).
- Supports mouse hover and click interactions alongside keyboard input.

### 2. In-Menu Grid Configuration (`Super + Space ➔ Setup ➔ Tactile Grid`)
- Accessible directly from the Omarchy App Menu without editing configuration files manually.
- Presets: `2 x 3 Standard`, `3 x 3 Precision`, `2 x 2 Quadrants`, `1 x 3 Triple Columns`, `2 x 4 Ultrawide`. Active presets display a live checkmark.
- Column Proportions: `Equal (1:1:1)`, `Master Left (2:1:1 — 50%/25%/25%)`, `Center Stage (1:2:1 — 25%/50%/25%)`, `Master Right (1:1:2 — 25%/25%/50%)`.
- Dynamic Dimensions: Add/remove rows and columns on the fly.
- Gaps: Standard (12px/8px), Compact (6px/4px), Spacious (20px/12px), Zero Gaps (0px).
- Interactive TUI settings wizard and raw JSON config editor.

### 3. Intelligent Grid Gap Auto-Filling (`tactile-autofill`)
- A lightweight daemon monitoring Hyprland window creation events via socket2.
- When an existing window occupies a sub-region (e.g. Left 2/3), opening a new window automatically places and sizes it into the empty gap (e.g. Right 1/3) instead of hiding underneath.
- Snapping a window simultaneously reorganizes all other open windows on the workspace into the remaining unoccupied space.

### 4. Smart Spatial Window Swapping (`Super + Shift + Arrow`)
- Swaps physical screen coordinates between adjacent windows while strictly preserving each window's individual width, height, and layout proportions.
- Prevents small sidebar windows from stretching into master slots when moving across the screen.

### 5. Independent Multi-Deck Scratchpads (`special:deck_*`)
- Replaces standard monolithic scratchpads with dynamic, independent virtual workspaces (`special:deck_1`, `special:deck_2`, `special:deck_3`, ...).
- Each deck supports dwindle split tiling, allowing side-by-side terminal workflows inside a floating overlay.
- `Super + Up` / `Super + Down`: Slide smoothly between scratchpad decks.
- `Super + Left` / `Super + Right`: Focus between window tiles within the current deck.
- `Super + N` / `Alt + Shift + F`: Launch a new application in a newly created deck.
- `Super + W`: Smart close that automatically transitions focus to remaining decks when the last window in a deck closes.

### 6. CachyOS Performance & Low-Latency Network Stack
- BORE CPU Scheduler: Burst-Oriented Response Enhancer prioritizing interactive UI threads, rendering, and audio streams.
- TCP BBRv3 + CAKE Queueing: Loaded via `/etc/modules-load.d/bbr.conf` and configured in `/etc/sysctl.d/99-bbr.conf` for minimum bufferbloat and fast throughput.
- ZRAM Optimization: `vm.swappiness = 150` with single-page swap-in (`vm.page-cluster = 0`).
- Anti-Stutter Writeback: `vm.dirty_bytes = 268435456` (256MB cap) preventing disk write stalling.
- RTKit Priority: PipeWire audio threads run at Real-Time Priority 99 via `rtkit-daemon`.

### 7. Google Antigravity AI Agent Integration (`agy` & `agyd`)
- Integrated into Omarchy's agent switcher (`Setup ➔ Defaults ➔ Agent` and `Install ➔ AI`).
- `agyd`: Standalone wrapper executing `agy --dangerously-skip-permissions` for uninterrupted autonomous agent operations.
- `Super + Shift + Ctrl + A`: Dedicated keybinding launching Antigravity in an Omarchy floating TUI window.

### 8. Smooth App Menu Animations (`Super + Space`)
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
│   │   ├── bindings.lua         # Personal keybindings (navigation, scratchpads, tactile)
│   │   ├── input.lua            # Keyboard layout, trackpad speed, gestures
│   │   ├── looknfeel.lua        # Window borders, gaps, curves, workspace animations
│   │   ├── monitors.lua         # Display scaling, resolution, refresh rate
│   │   └── autostart.lua        # Background daemons and startup apps
│   ├── tactile/
│   │   ├── config.json          # Tactile geometry, gaps, and column weight settings
│   │   └── Tactile.qml          # Native Wayland Layer 3 QML overlay engine
│   ├── omarchy/
│   │   ├── shell.json           # Top bar layout, widgets, transparency
│   │   └── extensions/
│   │       └── omarchy-menu.jsonc # App launcher menu extensions (Tactile, Antigravity)
│   ├── bash/
│   │   └── aliases.sh           # Shell aliases (agyd wrapper)
│   ├── starship.toml            # Cross-shell prompt configuration
│   └── git/
│       └── config               # Git user identity and aliases
└── local/
    └── bin/
        ├── tactile              # Interactive Grid HUD (Super+T) for 2-key window snapping
        ├── tactile-autofill     # Background daemon auto-filling unoccupied grid gaps
        ├── omarchy-tactile-setup# CLI/TUI helper and menu dispatcher for Tactile settings
        ├── swap-window          # Spatial window mover/swapper preserving sizes
        ├── nav-window           # 2D workspace and scratchpad tile navigator
        ├── scratchpad-deck      # Independent multi-deck floating workspace engine
        ├── resize-step          # 10% incremental window resizing helper
        ├── agyd                 # Auto-permission wrapper for Google Antigravity CLI
        ├── omarchy-agent        # Default agent dispatcher with agy floating TUI support
        ├── omarchy-default-agent# Agent switcher supporting Antigravity (agy)
        └── powerprofilesctl     # Native DBus wrapper for instant 1-click power profiles
```

---

## Keybindings Reference

| Keybinding | Action | Context |
| :--- | :--- | :--- |
| `Super + T` | Summon Tactile Grid HUD overlay (2-key bounding-box snapping) | Anywhere |
| `Super + Shift + T` | Toggle window floating / tiling | Focused Window |
| `Super + Shift + Left` | Move window leftward preserving exact sizes | Anywhere |
| `Super + Shift + Right` | Move window rightward preserving exact sizes | Anywhere |
| `Super + Shift + Up` | Move window upward preserving exact sizes | Anywhere |
| `Super + Shift + Down` | Move window downward preserving exact sizes | Anywhere |
| `Super + Left` | Focus left window | Anywhere |
| `Super + Right` | Focus right window | Anywhere |
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

## Helper Scripts & Daemons Reference

| Script | Purpose |
| :--- | :--- |
| `tactile` | Launches the native Wayland Layer 3 Grid HUD overlay for 2-key snapping. |
| `tactile-autofill` | Background daemon automatically snapping new windows into unoccupied grid gaps. |
| `omarchy-tactile-setup` | CLI and TUI management tool for presets, column weights, and grid dimensions. |
| `swap-window` | Spatially moves and swaps windows while strictly preserving individual dimensions. |
| `nav-window` | Manages directional focus across tiling windows and scratchpad decks. |
| `scratchpad-deck` | Manages virtual multi-deck scratchpads, switching, and smart close logic. |
| `resize-step` | Incremental 10% width resizing helper. |
| `agyd` | Autonomous wrapper executing `agy --dangerously-skip-permissions`. |
| `omarchy-agent` | Agent dispatcher supporting Antigravity floating TUI window. |
| `omarchy-default-agent`| Agent selector supporting Antigravity (`agy`). |
| `powerprofilesctl` | DBus wrapper for instant 1-click power profile switching from Top Bar. |

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
| **`swap-window`** (`Super+Shift+Arrow`) | 62.83 ms (Python + IPC) | **1.49 ms** (Resident Socket C) | **1.21 ms** | **42.2x Faster** | **PASS** ✅ |
| **`nav-window`** (`Super+Arrow`) | 21.81 ms (Bash + `hyprctl` + `jq`) | **1.74 ms** (Native C Direct IPC) | **1.55 ms** | **12.5x Faster** | **PASS** ✅ |
| **`resize-step`** (`Super+[` / `Super+]`) | 60.73 ms (Bash + 2×`hyprctl` + `awk`) | **1.47 ms** (Native C Direct Socket) | **1.29 ms** | **41.3x Faster** | **PASS** ✅ |

---

### 2. High-Density 10-Window Sequential Close (Zero Overlaps Test)

Tested opening 10 windows sequentially in Tactile mode and closing them one by one through all 9 stages:

| Stage | Windows Remaining | Overlap Detection Threshold | Overlaps Detected | Result |
| :--- | :--- | :--- | :--- | :--- |
| **Step 1** | 9 windows remaining | $> 15\text{px} \times 15\text{px}$ | **0 Overlaps** | **PASS** ✅ |
| **Step 2** | 8 windows remaining | $> 15\text{px} \times 15\text{px}$ | **0 Overlaps** | **PASS** ✅ |
| **Step 3** | 7 windows remaining | $> 15\text{px} \times 15\text{px}$ | **0 Overlaps** | **PASS** ✅ |
| **Step 4** | 6 windows remaining | $> 15\text{px} \times 15\text{px}$ | **0 Overlaps** | **PASS** ✅ |
| **Step 5** | 5 windows remaining | $> 15\text{px} \times 15\text{px}$ | **0 Overlaps** | **PASS** ✅ |
| **Step 6** | 4 windows remaining | $> 15\text{px} \times 15\text{px}$ | **0 Overlaps** | **PASS** ✅ |
| **Step 7** | 3 windows remaining | $> 15\text{px} \times 15\text{px}$ | **0 Overlaps** | **PASS** ✅ |
| **Step 8** | 2 windows remaining | $> 15\text{px} \times 15\text{px}$ | **0 Overlaps** | **PASS** ✅ |
| **Step 9** | 1 window (100% Full Canvas) | $> 15\text{px} \times 15\text{px}$ | **0 Overlaps** | **PASS** ✅ |

---

### 3. Multi-Cell Long Window Expansion & Void Collapse

- **Test A ($1 \times 2$ Full-Height Vertical Column Close)**: Closes a full-height column spanning both rows; remaining top and bottom windows expand simultaneously across the void. (**PASS** ✅)
- **Test B ($1 \times 3$ Full-Width Horizontal Row Close)**: Closes a full-width row spanning all 3 columns; remaining columns expand to full monitor height ($1021\text{px}$) with 100% canvas coverage. (**PASS** ✅)

---

### 4. How to Run the Automated Benchmark Suite

To run the full empirical benchmark suite on your machine:

```bash
bash ~/dotfiles/tests/run-all-tests.sh
```

---

## Quick Restore & Fresh Install Procedure

On a fresh Arch Linux / Omarchy installation:

```bash
git clone git@github.com:hangodek/dotfiles.git ~/dotfiles

# Standard restore (symlinks, scripts, native C helpers, menu animation patch)
bash ~/dotfiles/bootstrap.sh

# Complete restore + CachyOS x86-64-v3 Kernel & Performance Suite
bash ~/dotfiles/bootstrap.sh --cachyos
```
