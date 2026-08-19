# Han's Omarchy Dotfiles

Personal configuration and customizations for [Omarchy Linux](https://omarchy.org/) (Arch Linux + Hyprland).

> **Tested Hardware**: Fully tested and optimized on **Lenovo ThinkPad X395** (AMD Ryzen 5 PRO 3500U).

---

## Features & Highlights

- **Independent Multi-Deck Scratchpads (`special:deck_*`)**:
  - Each scratchpad deck is its own independent floating virtual workspace with **zero topbar/tabbar clutter**.
  - **Full Tiling Support Inside Decks**: Inside any deck, press `Super + Return` to open a terminal on the right side-by-side!
  - **Multi-Deck Switching**: Press `Super + Up` / `Super + Down` to slide smoothly between **Deck 1 ↔ Deck 2 ↔ Deck 3**!
- **Instant New Deck Creation**:
  - Press `Super + N` or `Alt + Shift + F` to create a brand new independent Scratchpad Deck with the App Launcher.
- **Smart 2D Navigation**:
  - Inside a scratchpad deck:
    - `Super + Up` / `Super + Down`: Switches vertically between scratchpad decks.
    - `Super + Left` / `Super + Right`: Focuses side-by-side split windows within the active deck.
  - On main workspaces: Standard directional navigation across tiled windows.
- **Tuned Animations**:
  - Responsive `overshoot` slide-in and fluid, gentle `smoothOut` slide-out transitions matching system rhythm.

---

## Repository Structure

```
~/dotfiles/
├── bootstrap.sh                 # One-command restoration script
├── config/
│   ├── hypr/                    # Hyprland configurations
│   │   ├── bindings.lua         # Custom keybindings & dispatcher overrides
│   │   ├── looknfeel.lua        # Window decorations, gaps, special scale, animations
│   │   ├── monitors.lua         # Monitor & display configuration
│   │   ├── input.lua            # Keyboard & mouse settings
│   │   ├── autostart.lua        # Startup applications
│   │   └── hyprland.lua         # Hyprland entry config
│   ├── omarchy/
│   │   ├── shell.json           # Status bar layout & widget setup
│   │   └── extensions/
│   │       └── omarchy-menu.jsonc # App launcher and menu settings
│   ├── git/
│   │   └── config               # Git settings
│   └── starship.toml            # Starship prompt configuration
└── local/
    └── bin/
        ├── scratchpad-deck      # Independent multi-deck scratchpad manager
        ├── nav-window           # Smart 2D navigation (Up/Down decks, Left/Right tiles)
        ├── powerprofilesctl     # Instant 1-click power profile switching via DBus
        └── resize-step          # Step-based window resize helper script
```

---

## Custom Keybindings

| Shortcut | Description | Context |
| :--- | :--- | :--- |
| `ALT + F` | **Toggle active scratchpad deck** (shows/hides, or opens App Menu if empty) | Anywhere |
| `SUPER + N` | **Create new scratchpad deck** (prompts App Menu to create next deck) | Anywhere |
| `ALT + SHIFT + F` | **Create new scratchpad deck** (alternative shortcut) | Anywhere |
| `SUPER + W` | **Close window** (transitions to previous deck if last window in deck closes) | Anywhere |
| `SUPER + O` | **Move window to/from scratchpad deck** (joins deck or ejects to main) | Main / Scratchpad |
| `SUPER + UP` | **Switch to previous scratchpad deck** / Focus window above | Scratchpad / Main |
| `SUPER + DOWN` | **Switch to next scratchpad deck** / Focus window below | Scratchpad / Main |
| `SUPER + LEFT` | **Focus left window** | Scratchpad / Main |
| `SUPER + RIGHT` | **Focus right window** | Scratchpad / Main |
| `SUPER + ]` | **Expand window width** by 10% of monitor width | Anywhere |
| `SUPER + [` | **Shrink window width** by 10% of monitor width | Anywhere |
| `SUPER + SHIFT + O`| **Pop window out** (pinned sticky widget + always on top for PiP) | Anywhere |

---

## Helper Scripts

| Script | Purpose |
| :--- | :--- |
| `scratchpad-deck` | Manages independent multi-deck floating workspaces (`special:deck_*`), deck switching, and app launcher hooks. |
| `powerprofilesctl` | Wrapper around power-profiles-daemon / tuned that enables instant single-click power profile switching. |
| `nav-window` | Provides smooth 2D navigation (slides between decks with Up/Down, navigates tiles with Left/Right). |
| `resize-step` | Resizes the focused window in 10% monitor width increments. |

---

## Quick Restore (Fresh Install)

When reinstalling Omarchy or setting up a new machine:

```bash
git clone git@github.com:hangodek/dotfiles.git ~/dotfiles
bash ~/dotfiles/bootstrap.sh
```
