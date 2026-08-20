# Han's Dotfiles for Omarchy & Hyprland

Personal dotfiles, native helper utilities, and system optimizations for Arch Linux, Omarchy, Hyprland, and Quickshell.

---

## Features

- **Multi-Deck Scratchpads (`special:deck_*`)**: Independent floating workspaces supporting split tiling and vertical deck navigation (`Super + Up/Down`).
- **Native Spatial Navigation (`nav-window`)**: Compiled C helper executing in under 2ms for directional window focus and scratchpad navigation.
- **Spotlight Menu Animations**: Smooth cubic zoom and fade animation patch for the application launcher (`Super + Space`).
- **Shell Aliases**: Command wrapper `agyd` mapped to `agy --dangerously-skip-permissions`.
- **CachyOS Performance Configuration**: BORE CPU scheduler, TCP BBRv3 + CAKE queueing, ZRAM optimization, and PipeWire real-time priority.
- **Programmer Keyboard Layout**: Clean US layout with direct quotes and Compose mapped to CapsLock.

---

## Custom Keybindings

| Keybinding | Action | Context |
| :--- | :--- | :--- |
| **`Alt + F`** | Toggle active scratchpad deck | Anywhere |
| **`Super + Up` / `Down`** | Slide between scratchpad decks | Anywhere |
| **`Super + Left` / `Right`** | Focus window or split tile (Native C IPC) | Anywhere |
| **`Super + N` / `Alt + Shift + F`** | Create new scratchpad deck | Anywhere |
| **`Super + W`** | Smart close window (preserves deck focus) | Anywhere |
| **`Super + O`** | Move window to / from active scratchpad deck | Anywhere |

---

## Repository Structure

```
~/dotfiles/
├── bootstrap.sh                 # Master setup script for configs and native helpers
├── AGENTS.md                    # Operational manual for AI coding agents
├── README.md                    # Documentation and keybindings
├── scripts/
│   ├── setup-cachyos.sh         # Optional CachyOS kernel and sysctl installer
│   └── patch-smooth-menu.sh     # Spotlight animation patch for Super+Space
├── config/
│   ├── hypr/                    # Hyprland bindings, looknfeel, input, autostart
│   ├── omarchy/                 # Omarchy shell and menu customizations
│   ├── bash/                    # Shell aliases (agyd)
│   ├── starship.toml            # Cross-shell prompt configuration
│   └── git/config               # Git identity and configuration
└── local/bin/
    ├── nav-window               # Compiled C 2D navigator
    ├── scratchpad-deck          # Multi-deck scratchpad engine
    ├── agyd                     # Script wrapper for agy permissions
    └── powerprofilesctl         # DBus power profile wrapper
```

---

## Installation & Restore

On a fresh Arch Linux / Omarchy installation:

```bash
git clone git@github.com:hangodek/dotfiles.git ~/dotfiles

# Standard restore (symlinks configs, compiles native helpers, applies menu patch)
bash ~/dotfiles/bootstrap.sh

# Optional: Complete restore with CachyOS Kernel & Performance Suite
bash ~/dotfiles/bootstrap.sh --cachyos
```
