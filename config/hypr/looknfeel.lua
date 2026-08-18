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

-- Smooth workspace transition animation (Classic Slide)
hl.animation({
  leaf = "workspaces",
  enabled = true,
  speed = 4,
  bezier = "easeOutQuint",
  style = "slide",
})

-- Fluid window animations (open, close, splits, resize, moves)
hl.animation({ leaf = "windows", enabled = true, speed = 4.2, bezier = "overshoot" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3.8, bezier = "overshoot", style = "popin 82%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.8, bezier = "smoothOut", style = "popin 82%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4.2, bezier = "overshoot" })

-- Smooth window focus cross-fade
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 3.2, bezier = "smoothOut" })

-- Subtle modern corner rounding and inactive window dimming
hl.config({
  decoration = {
    rounding = 8,
    dim_inactive = true,
    dim_strength = 0.1,
  },
})


