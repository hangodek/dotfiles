# Han's Omarchy Dotfiles

Personal configuration and customizations for [Omarchy Linux](https://omarchy.org/) (Arch Linux + Hyprland).

## Structure

```
~/dotfiles/
├── bootstrap.sh                 # One-command restoration script
├── config/
│   ├── hypr/                    # Hyprland configurations
│   │   ├── bindings.lua         # Custom keybindings (e.g. resize-step)
│   │   ├── monitors.lua         # Monitor & display configuration
│   │   ├── input.lua            # Keyboard & mouse settings
│   │   ├── looknfeel.lua        # Window decorations, gaps, animations
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
        ├── float-center         # Centered float toggle helper script
        └── resize-step          # Step-based window resize helper script
```

## Custom Keybindings

| Shortcut | Description |
| :--- | :--- |
| `SUPER + ]` | **Expand focused window** width by 10% of monitor width |
| `SUPER + [` | **Shrink focused window** width by 10% of monitor width |
| `SUPER + O` | **Toggle centered floating window** (unpinned, Alt+Tab friendly) |
| `SUPER + SHIFT + O` | **Pop window out** (pinned sticky widget + always on top for PiP) |


## Quick Restore (Fresh Install)

When reinstalling Omarchy or moving to a new machine:

```bash
git clone git@github.com:hangodek/dotfiles.git ~/dotfiles
bash ~/dotfiles/bootstrap.sh
```
