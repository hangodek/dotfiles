-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Step-resize focused window by 10% of monitor width per press
o.bind("SUPER + BRACKETRIGHT", "Expand window width (10%)", "resize-step expand")
o.bind("SUPER + BRACKETLEFT", "Shrink window width (10%)", "resize-step shrink")

-- Multi-Deck Scratchpad controls
hl.unbind("SUPER + O")
o.bind("SUPER + O", "Move window to/from active scratchpad deck", "scratchpad-deck eject")

-- Alt+F: Toggle active scratchpad deck (launches app menu if empty)
o.bind("ALT + F", "Toggle active scratchpad deck", "scratchpad-deck toggle")

-- Create brand new independent scratchpad deck
o.bind("ALT + SHIFT + F", "New scratchpad deck", "scratchpad-deck new")
o.bind("SUPER + N", "New scratchpad deck", "scratchpad-deck new")

-- Smart window navigation (Super+Up/Down slides between decks in scratchpad, Super+Left/Right navigates side-by-side tiles)
hl.unbind("SUPER + LEFT")
o.bind("SUPER + LEFT", "Focus left window", "nav-window left")
hl.unbind("SUPER + RIGHT")
o.bind("SUPER + RIGHT", "Focus right window", "nav-window right")
hl.unbind("SUPER + UP")
o.bind("SUPER + UP", "Focus up / previous scratchpad deck", "nav-window up")
hl.unbind("SUPER + DOWN")
o.bind("SUPER + DOWN", "Focus down / next scratchpad deck", "nav-window down")

-- Original DHH pinned pop-out (sticky across all workspaces + always on top for PiP)
o.bind("SUPER + SHIFT + O", "Pop window out (float & pin)", "omarchy-hyprland-window-pop")


