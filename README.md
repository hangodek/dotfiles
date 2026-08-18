# Han's Omarchy Dotfiles

Personal configuration and customizations for [Omarchy Linux](https://omarchy.org/) (Arch Linux + Hyprland).

---

## Features & Highlights

- **Stacked Scratchpad Layer (`special:center`)**:
  - Zellij-style floating workspace overlay (`special_scale_factor = 0.85`) with centered margins.
  - Windows automatically open and group at **100% full container size** with native tab bars.
  - Isolated `Alt + Tab` cycle (scratchpad windows never pollute the main workspace).
- **Hybrid Layout Support**:
  - Keep apps (like Spotify or documentation) in clean stacked tabs while splitting out other apps (like side-by-side terminals).
- **Two-Way Stack ↔ Split Switch (`Super + G`)**:
  - Pop any tab out of the stack into a side-by-side split tile, or merge any split window back into the stack.
- **Smart Boundary-Aware Navigation**:
  - `Super + Left` / `Super + Right` cycles tabs inside stacks, jumps out to adjacent split tiles at boundaries, and focuses tiled windows on main workspaces without getting trapped.
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
        ├── float-center         # Centered scratchpad manager (Super+O)
        ├── toggle-stack         # Two-way stack ↔ split toggle (Super+G)
        ├── nav-window           # Smart boundary-aware tab & tile navigation
        └── resize-step          # Step-based window resize helper script
```

---

## Custom Keybindings

| Shortcut | Description | Context |
| :--- | :--- | :--- |
| `ALT + F` | **Toggle scratchpad overlay** (Show / Hide session) | Anywhere |
| `SUPER + O` | **Move window to/from scratchpad** (joins stack or ejects to main) | Main / Scratchpad |
| `SUPER + G` | **Toggle Stack ↔ Split** (Pop tab out to tile / merge window into stack) | Scratchpad / Main |
| `SUPER + LEFT` | **Focus left / Previous tab** (smart boundary-aware navigation) | Scratchpad / Main |
| `SUPER + RIGHT` | **Focus right / Next tab** (smart boundary-aware navigation) | Scratchpad / Main |
| `SUPER + ]` | **Expand window width** by 10% of monitor width | Anywhere |
| `SUPER + [` | **Shrink window width** by 10% of monitor width | Anywhere |
| `SUPER + SHIFT + O`| **Pop window out** (pinned sticky widget + always on top for PiP) | Anywhere |

---

## Helper Scripts

| Script | Purpose |
| :--- | :--- |
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
