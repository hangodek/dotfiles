# 🚀 Han's Dotfiles for Omarchy & Hyprland

Personal dotfiles, high-performance native C helpers, and low-latency system optimizations for **Arch Linux** + **Omarchy** + **Hyprland** + **Quickshell**.

---

## ✨ Features & Architecture

- **Independent Multi-Deck Scratchpads (`special:deck_*`)**: Dynamic virtual floating workspaces (`scratchpad-deck`) supporting split tiling and smooth deck sliding (`Super + Up/Down`).
- **Native C Spatial Navigation (`nav-window`)**: Compiled `gcc -O3` binary delivering sub-2ms window and deck navigation via direct UNIX domain socket IPC.
- **Spotlight Menu Animations**: Hardware-accelerated zoom and fade curve patch (`Super + Space`) in 150ms.
- **Google Antigravity AI (`agy` / `agyd`)**: Integrated autonomous AI CLI with dedicated floating TUI overlay (`Super + Shift + Ctrl + A`).
- **CachyOS Performance Suite**: BORE CPU scheduler, TCP BBRv3 + CAKE queueing, and PipeWire Real-Time Priority 99 audio stack.
- **Clean Programmer US Layout**: Standard quotes with CapsLock Compose key. Zero dead key annoyance.

---

## ⌨️ Keybindings

| Keybinding | Action |
| :--- | :--- |
| **`Alt + F`** | Toggle active scratchpad deck |
| **`Super + Up` / `Down`** | Slide between scratchpad decks |
| **`Super + Left` / `Right`** | Focus window / split tile (Native C IPC) |
| **`Super + N` / `Alt + Shift + F`** | Open new scratchpad deck via App Menu |
| **`Super + W`** | Smart close window (preserves deck focus) |
| **`Super + O`** | Move window to / from active scratchpad deck |
| **`Super + T`** | Toggle window floating / tiling |
| **`Super + -` / `Super + =`** | Horizontal window resize (100px step) |
| **`Super + Shift + -` / `=`** | Vertical window resize (100px step) |
| **`Super + Alt + -` / `+`** | Fine-grain window resize (25px step) |
| **`Super + Space`** | Omarchy Spotlight App Launcher |
| **`Super + Shift + Ctrl + A`** | Launch Google Antigravity AI CLI |

---

## 📦 Repository Structure

```
~/dotfiles/
├── bootstrap.sh                 # Clean restore script for configs and native helpers
├── AGENTS.md                    # Operational manual for AI coding agents
├── README.md                    # Documentation & keybindings (this file)
├── scripts/
│   ├── setup-cachyos.sh         # Optional CachyOS kernel, sysctl, and rtkit installer
│   └── patch-smooth-menu.sh     # Spotlight zoom & fade animation patch
├── config/
│   ├── hypr/                    # Hyprland bindings, looknfeel, input, autostart
│   ├── omarchy/                 # Omarchy shell & menu extensions
│   ├── bash/                    # Shell aliases (agyd wrapper)
│   ├── starship.toml            # Cross-shell prompt configuration
│   └── git/config               # Git user identity and aliases
└── local/bin/
    ├── nav-window               # Compiled native C 2D navigator (nav-window.c)
    ├── scratchpad-deck          # Multi-deck scratchpad engine
    ├── agyd                     # Auto-permission wrapper for Antigravity CLI
    └── powerprofilesctl         # Native DBus wrapper for 1-click power profiles
```

---

## 🛠️ Quick Installation & Restore

On a fresh Arch Linux / Omarchy install:

```bash
git clone git@github.com:hangodek/dotfiles.git ~/dotfiles

# Standard restore (symlinks configs, compiles native helpers, applies menu patch)
bash ~/dotfiles/bootstrap.sh

# Optional: Complete restore + CachyOS x86-64-v3 Kernel & Performance Suite
bash ~/dotfiles/bootstrap.sh --cachyos
```
