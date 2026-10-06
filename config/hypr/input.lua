-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.

-- Keyboard layout and options.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input
hl.config({
  input = {
    -- Standard US layout without dead keys for programming
    kb_layout = "us",
    kb_options = "compose:caps,shift:both_capslock_cancel",

    -- No dead keys (instant quotes '', "", ``)
    kb_variant = "",

    -- Change speed of keyboard repeat.
    repeat_rate = 40,
    repeat_delay = 250,

    -- Start with numlock on by default.
    numlock_by_default = true,

    -- Increase sensitivity for mouse/trackpad (restored snappy preference).
    sensitivity = 0.35,

    -- Turn off mouse acceleration (default: adaptive).
    accel_profile = "adaptive",

    touchpad = {
      -- Use natural (inverse) scrolling.
      natural_scroll = true,

      -- Use two-finger clicks for right-click instead of lower-right corner.
      clickfinger_behavior = true,

      -- Tap button map: 1 finger = left, 2 fingers = right, 3 fingers = middle.
      tap_button_map = "lrm",

      -- Enable tap to click and tap and drag.
      tap_to_click = true,
      tap_and_drag = true,

      -- Control the speed of your scrolling.
      scroll_factor = 0.4,

      -- Enable the touchpad while typing.
      disable_while_typing = false,

      -- Disable 3-finger drag so 3 fingers are 100% dedicated to 1:1 workspace swiping.
      drag_3fg = 0,

      -- Disable accidental middle button emulation from button zones.
      middle_button_emulation = false,
    },
  },

  -- 1:1 Real-time workspace swipe physics (calm, weighted macOS feel)
  gestures = {
    workspace_swipe_distance = 300,
    workspace_swipe_invert = true,
    workspace_swipe_min_speed_to_force = 30,
    workspace_swipe_cancel_ratio = 0.4,
    workspace_swipe_create_new = true,
    workspace_swipe_use_r = true,
    workspace_swipe_direction_lock = true,
    workspace_swipe_direction_lock_threshold = 10,
    workspace_swipe_forever = false,
  },
})

-- App-specific touchpad scroll speeds.
-- o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.25 })

-- Enable 1:1 real-time workspace swiping with 3 fingers (macOS Mission Control).
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- 4-Finger swipe up: open App Menu (Spotlight launcher).
hl.gesture({
  fingers = 4,
  direction = "up",
  action = function()
    hl.dispatch(hl.dsp.exec_cmd("omarchy-menu toggle"))
  end,
})

-- 4-Finger swipe down: toggle special scratchpad overlay.
hl.gesture({
  fingers = 4,
  direction = "down",
  action = function()
    hl.dispatch(hl.dsp.workspace.toggle_special("scratchpad"))
  end,
})
