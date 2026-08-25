#!/bin/bash
# Patch /usr/bin/omarchy-launch-terminal to add scratchpad routing when in fullwidth mode.
# This must be run with sudo.

set -euo pipefail

SYSTEM_BIN="/usr/bin/omarchy-launch-terminal"
MARKER="scratchpad-routing-patch"

if grep -q "$MARKER" "$SYSTEM_BIN" 2>/dev/null; then
  echo "--> Terminal scratchpad routing patch already active."
  exit 0
fi

echo "--> Patching $SYSTEM_BIN with scratchpad routing..."

sudo tee "$SYSTEM_BIN" > /dev/null << 'EOF'
#!/bin/bash
# omarchy:summary=Launch a terminal in the active terminal's current directory
# omarchy:args=[command...]
# scratchpad-routing-patch

set -euo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/scratchpad"
STATE_FILE="$STATE_DIR/active_deck"

active_json=$(hyprctl activewindow -j 2>/dev/null || echo "{}")
ws_name=$(echo "$active_json" | jq -r '.workspace.name // empty')
is_fullscreen=$(echo "$active_json" | jq -r '.fullscreen // 0')

target_dir="$(omarchy-cmd-terminal-cwd 2>/dev/null || echo "$HOME")"

# If the focused main-workspace window is maximized (Super+E), route to scratchpad
if [[ "$ws_name" =~ ^[0-9]+$ && "$is_fullscreen" -gt 0 ]]; then
  exec scratchpad-deck launch xdg-terminal-exec --dir="$target_dir" "$@"
fi

exec setsid uwsm-app -- xdg-terminal-exec --dir="$target_dir" "$@"
EOF

sudo chmod +x "$SYSTEM_BIN"
echo "--> Terminal scratchpad routing patch applied."
