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

-- Centered scratchpad window move (main workspace <-> special:center)
hl.unbind("SUPER + O")
o.bind("SUPER + O", "Move window to/from centered scratchpad", "float-center")

-- Alt+F: Show/hide the centered scratchpad panel (launches app menu if empty)
o.bind("ALT + F", "Toggle centered scratchpad", "toggle-scratchpad")

-- Toggle active window between Stacked (tab) and Split (side-by-side tile)
hl.unbind("SUPER + G")
o.bind("SUPER + G", "Toggle stacked/split window", "toggle-stack")

-- Smart window navigation (switches left/right window on main workspace, or switches tabs in scratchpad stack)
hl.unbind("SUPER + LEFT")
o.bind("SUPER + LEFT", "Focus left / previous tab", "nav-window left")
hl.unbind("SUPER + RIGHT")
o.bind("SUPER + RIGHT", "Focus right / next tab", "nav-window right")

-- Original DHH pinned pop-out (sticky across all workspaces + always on top for PiP)
o.bind("SUPER + SHIFT + O", "Pop window out (float & pin)", "omarchy-hyprland-window-pop")


