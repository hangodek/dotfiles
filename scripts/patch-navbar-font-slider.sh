#!/bin/bash
# Patch Omarchy Navbar Monitor Panel to enable 1px incremental font size steps (9px to 20px).
# Usage: sudo bash ~/dotfiles/scripts/patch-navbar-font-slider.sh

set -euo pipefail

PANEL_FILE="/usr/share/omarchy/shell/plugins/panels/monitor/Panel.qml"

if [[ ! -f "$PANEL_FILE" ]]; then
  echo "Omarchy Panel.qml not found at $PANEL_FILE"
  exit 0
fi

echo "--> Checking 1px font size slider patch for Navbar Monitor Panel..."

python3 -c "
import sys, os

panel_path = '$PANEL_FILE'
with open(panel_path, 'r') as f:
    content = f.read()

target_old = 'readonly property var textSizeStops: [9, 10, 11, 12, 14, 16, 20]'
target_new = 'readonly property var textSizeStops: [9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]'

if target_new in content:
    print('    1px font size slider patch is already active.')
    sys.exit(0)

if target_old not in content:
    print('    Notice: textSizeStops definition was not found or already modified.')
    sys.exit(0)

if not os.access(panel_path, os.W_OK):
    print('    Notice: Root permissions needed to patch /usr/share/omarchy/ (run with sudo to apply).')
    sys.exit(0)

new_content = content.replace(target_old, target_new, 1)

with open(panel_path, 'w') as f:
    f.write(new_content)

print('    Successfully applied 1px font size slider patch to Panel.qml!')
"

# Restart shell if running and omarchy-restart-shell is available
if command -v omarchy-restart-shell >/dev/null 2>&1; then
  omarchy-restart-shell >/dev/null 2>&1 || true
fi
