# Han's Omarchy Dotfiles

Personal configuration and customizations for [Omarchy Linux](https://omarchy.org/) (Arch Linux + Hyprland).

---

## Features & Highlights

- **Vertical Stacked Deck (`special:center`)**:
  - Zellij-style floating workspace overlay (`special_scale_factor = 0.85`) with vertical stacked card headers (`stacked = true`).
  - Windows automatically open and stack vertically at **100% full container size**.
  - Isolated `Alt + Tab` cycle (scratchpad windows never pollute the main workspace).
- **Auto App Launcher on Empty Scratchpad**:
  - Pressing `Alt + F` when the scratchpad is empty automatically brings up the **Omarchy Apps Menu**, launching any chosen app directly into the centered scratchpad stack.
- **Hybrid Layout Support**:
  - Keep apps (like Spotify or documentation) in clean vertical stacked decks while splitting out other apps (like side-by-side terminals).
- **Two-Way Stack ↔ Split Switch (`Super + G`)**:
  - Pop any card out of the stack into a side-by-side split tile, or merge any split window back into the stack.
- **Intuitive 2D Navigation**:
  - `Super + Up` / `Super + Down` cycles vertically through the stacked cards in the deck.
  - `Super + Left` / `Super + Right` moves horizontally between side-by-side split columns.
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
│   │   ├── looknfeel.lua        # Window decorations, gaps, special scale, stacked groupbar, animations
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
        ├── float-center         # Centered scratchpad manager (Super+O)
        ├── toggle-scratchpad    # Smart scratchpad toggle + app launcher (Alt+F)
        ├── toggle-stack         # Two-way stack ↔ split toggle (Super+G)
        ├── nav-window           # Smart 2D navigation (Up/Down stack, Left/Right column)
        └── resize-step          # Step-based window resize helper script
```

---

## Custom Keybindings

| Shortcut | Description | Context |
| :--- | :--- | :--- |
| `ALT + F` | **Toggle scratchpad overlay** (shows/hides, or opens App Menu if empty) | Anywhere |
| `SUPER + O` | **Move window to/from scratchpad** (joins stack or ejects to main) | Main / Scratchpad |
| `SUPER + G` | **Toggle Stack ↔ Split** (Pop card out to tile / merge window into stack) | Scratchpad / Main |
| `SUPER + UP` | **Cycle up** through vertical stacked deck / Focus window above | Scratchpad / Main |
| `SUPER + DOWN` | **Cycle down** through vertical stacked deck / Focus window below | Scratchpad / Main |
| `SUPER + LEFT` | **Focus left column** | Scratchpad / Main |
| `SUPER + RIGHT` | **Focus right column** | Scratchpad / Main |
| `SUPER + ]` | **Expand window width** by 10% of monitor width | Anywhere |
| `SUPER + [` | **Shrink window width** by 10% of monitor width | Anywhere |
| `SUPER + SHIFT + O`| **Pop window out** (pinned sticky widget + always on top for PiP) | Anywhere |

---

## Helper Scripts

| Script | Purpose |
| :--- | :--- |
| `powerprofilesctl` | Wrapper around power-profiles-daemon / tuned that enables instant single-click power profile switching. |
| `toggle-scratchpad` | Handles `Alt + F` toggling and automatically triggers the Apps Menu when the scratchpad is empty. |
| `float-center` | Manages moving windows between main workspaces and `special:center`, ensuring auto-grouping and auto-closing when empty. |
| `toggle-stack` | Intelligently converts tabs into side-by-side split tiles (`out_of_group`) and merges standalone split windows back into existing stacks. |
| `nav-window` | Provides smooth navigation that traverses tabs within groups and jumps across split boundaries. |
| `resize-step` | Resizes the focused window in 10% monitor width increments. |

---

## Quick Restore (Fresh Install)

When reinstalling Omarchy or setting up a new machine:

```bash
git clone git@github.com:hangodek/dotfiles.git ~/dotfiles
bash ~/dotfiles/bootstrap.sh
```
