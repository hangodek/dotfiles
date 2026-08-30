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


-- 2D Window Navigation (Super + Arrow Keys navigates tiled split windows in all 4 directions)
hl.unbind("SUPER + LEFT")
o.bind("SUPER + LEFT", "Focus left window", "nav-window left")
hl.unbind("SUPER + RIGHT")
o.bind("SUPER + RIGHT", "Focus right window", "nav-window right")
hl.unbind("SUPER + UP")
o.bind("SUPER + UP", "Focus up window", "nav-window up")
hl.unbind("SUPER + DOWN")
o.bind("SUPER + DOWN", "Focus down window", "nav-window down")

-- Native Hyprland window swap & move in layout tree
hl.unbind("SUPER + SHIFT + LEFT")
o.bind("SUPER + SHIFT + LEFT", "Move window left in layout", hl.dsp.window.move({ direction = "l" }))
hl.unbind("SUPER + SHIFT + RIGHT")
o.bind("SUPER + SHIFT + RIGHT", "Move window right in layout", hl.dsp.window.move({ direction = "r" }))
hl.unbind("SUPER + SHIFT + UP")
o.bind("SUPER + SHIFT + UP", "Move window up in layout", hl.dsp.window.move({ direction = "u" }))
hl.unbind("SUPER + SHIFT + DOWN")
o.bind("SUPER + SHIFT + DOWN", "Move window down in layout", hl.dsp.window.move({ direction = "d" }))

-- Super+T: Toggle window floating/tiling
hl.unbind("SUPER + T")
o.bind("SUPER + T", "Toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" }))
o.bind("SUPER + SHIFT + T", "Toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" }))

-- Super+E: Maximize / Full width (replaces Super+Alt+F)
hl.unbind("SUPER + ALT + F")
o.bind("SUPER + E", "Maximize window / Full width", hl.dsp.window.fullscreen({ mode = "maximized" }))

-- 10% per step window resize (Super + - and Super + =/+)
hl.unbind("SUPER + code:20")
hl.unbind("SUPER + code:21")
hl.unbind("SUPER + SHIFT + code:20")
hl.unbind("SUPER + SHIFT + code:21")

o.bind("SUPER + code:20", "Expand window left 10%", hl.dsp.window.resize({ x = -192, y = 0, relative = true }))
o.bind("SUPER + code:21", "Shrink window left 10%", hl.dsp.window.resize({ x = 192, y = 0, relative = true }))
o.bind("SUPER + SHIFT + code:20", "Shrink window up 10%", hl.dsp.window.resize({ x = 0, y = -108, relative = true }))
o.bind("SUPER + SHIFT + code:21", "Expand window down 10%", hl.dsp.window.resize({ x = 0, y = 108, relative = true }))


