#!/bin/bash
# Patch Omarchy Navbar Monitor Panel to enable 1px incremental font size steps (9px to 20px).
# Automatically supports system (/usr/share/omarchy) and dev channel checkout paths.

set -euo pipefail

# Collect all potential panel files
TARGET_FILES=()

if [[ -f "${HOME}/omarchy/shell/plugins/panels/monitor/Panel.qml" ]]; then
  TARGET_FILES+=("${HOME}/omarchy/shell/plugins/panels/monitor/Panel.qml")
fi

if [[ -n "${OMARCHY_PATH:-}" && -f "${OMARCHY_PATH}/shell/plugins/panels/monitor/Panel.qml" ]]; then
  TARGET_FILES+=("${OMARCHY_PATH}/shell/plugins/panels/monitor/Panel.qml")
fi

if [[ -f "/usr/share/omarchy/shell/plugins/panels/monitor/Panel.qml" ]]; then
  TARGET_FILES+=("/usr/share/omarchy/shell/plugins/panels/monitor/Panel.qml")
fi

# Deduplicate
UNIQUE_FILES=()
for f in "${TARGET_FILES[@]}"; do
  canonical=$(readlink -f "$f" 2>/dev/null || echo "$f")
  found=0
  for u in "${UNIQUE_FILES[@]}"; do
    if [[ "$u" == "$canonical" ]]; then
      found=1
      break
    fi
  done
  if (( !found )); then
    UNIQUE_FILES+=("$canonical")
  fi
done

if (( ${#UNIQUE_FILES[@]} == 0 )); then
  echo "    Notice: No Omarchy monitor Panel.qml found."
  exit 0
fi

echo "--> Checking 1px font size slider patch for Navbar Monitor Panel across targets..."

for panel_path in "${UNIQUE_FILES[@]}"; do
  echo "    Checking target: $panel_path"

  python3 -c "
import sys, os

panel_path = '$panel_path'
with open(panel_path, 'r') as f:
    content = f.read()

target_old = 'readonly property var textSizeStops: [9, 10, 11, 12, 14, 16, 20]'
target_new = 'readonly property var textSizeStops: [9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]'

if target_new in content:
    print('    1px font size slider patch already active in ' + panel_path)
    sys.exit(0)

if target_old not in content:
    print('    Notice: textSizeStops not found or already modified in ' + panel_path)
    sys.exit(0)

if not os.access(panel_path, os.W_OK):
    print('    Notice: Write permission required for ' + panel_path + ' (run with sudo to apply).')
    sys.exit(0)

new_content = content.replace(target_old, target_new, 1)
with open(panel_path, 'w') as f:
    f.write(new_content)

print('    Successfully applied 1px font size slider patch to ' + panel_path)
"
done
