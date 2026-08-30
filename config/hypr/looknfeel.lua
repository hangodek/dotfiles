-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
-- hl.config({
--   general = {
--     -- No gaps between windows or borders.
--     gaps_in = 0,
--     gaps_out = 0,
--     border_size = 0,
--
--     -- Change to niri-like side-scrolling layout.
--     layout = "scrolling",
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
-- hl.config({
--   decoration = {
--     -- Use round window corners.
--     rounding = 8,
--
--     -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
--     dim_inactive = true,
--     dim_strength = 0.15,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
-- hl.config({
--   animations = {
--     -- Disable all animations.
--     enabled = false,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })

-- Custom modern Bezier curves
hl.curve("overshoot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("smoothOut", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
hl.curve("snappy", { type = "bezier", points = { { 0.2, 0.9 }, { 0.1, 1.0 } } })

-- Smooth workspace transition animation (Classic Slide)
hl.animation({
  leaf = "workspaces",
  enabled = true,
  speed = 4,
  bezier = "easeOutQuint",
  style = "slide",
})

-- Fluid buttery-smooth window animations (open, close, splits, resize, moves)
hl.animation({ leaf = "windows", enabled = true, speed = 4.5, bezier = "smoothOut" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.2, bezier = "smoothOut", style = "popin 88%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3.0, bezier = "smoothOut", style = "popin 88%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 8.0, bezier = "snappy" })

-- Smooth window focus cross-fade
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 3.5, bezier = "smoothOut" })

-- Smooth scratchpad transition animation (tuned in & smooth out)
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4.5, bezier = "smoothOut", style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceIn", enabled = true, speed = 4.0, bezier = "overshoot", style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 4.8, bezier = "smoothOut", style = "slidevert" })

-- Subtle modern corner rounding, inactive window dimming, and clean tabless stacked windows
hl.config({
  group = {
    groupbar = {
      enabled = false,
    },
  },
  decoration = {
    rounding = 8,
    dim_inactive = true,
    dim_strength = 0.1,
  },
  dwindle = {
    special_scale_factor = 0.85,
  },
  misc = {
    vrr = 0,
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    animate_manual_resizes = false,
    enable_swallow = false,
    close_special_on_empty = true,
  },
  cursor = {
    no_warps = true,
    inactive_timeout = 5,
  },
})

-- Smart floating & centering for system dialogs, modals, and file pickers
o.window({ class = "(xdg-desktop-portal-gtk|org.kde.polkit-kde-authentication-agent-1|polkit-gnome-authentication-agent-1|zenity|file-roller|pavucontrol|nm-connection-editor|blueman-manager)" }, {
  float = true,
  center = true,
  tag = "+floating-window",
})

o.window({ title = "(Open File|Open Folder|Save File|Save As|Select a File|Choose Files|File Upload|Authentication Required)" }, {
  float = true,
  center = true,
  tag = "+floating-window",
})

-- Distinct border highlight and 3px thickness for full-width / maximized mode (Super+E)
o.window({ fullscreen = 1 }, {
  border_color = { colors = { "rgba(ffb74dee)", "rgba(ff7043ee)" }, angle = 45 },
  border_size = 3,
})
