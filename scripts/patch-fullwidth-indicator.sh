#!/bin/bash
# Patch Omarchy Top Bar to add a Full-Width (Super+E) Active Indicator widget
# Automatically supports system (/usr/share/omarchy) and dev channel checkout paths.

set -euo pipefail

# Collect all potential shell directories
TARGET_DIRS=()

# 1. Dev channel checkout in user home if present
if [[ -d "${HOME}/omarchy/shell/plugins/bar" ]]; then
  TARGET_DIRS+=("${HOME}/omarchy/shell/plugins/bar")
fi

# 2. OMARCHY_PATH environment if set
if [[ -n "${OMARCHY_PATH:-}" && -d "${OMARCHY_PATH}/shell/plugins/bar" ]]; then
  TARGET_DIRS+=("${OMARCHY_PATH}/shell/plugins/bar")
fi

# 3. System installation directory
if [[ -d "/usr/share/omarchy/shell/plugins/bar" ]]; then
  TARGET_DIRS+=("/usr/share/omarchy/shell/plugins/bar")
fi

# Remove duplicates while preserving order
UNIQUE_TARGETS=()
for dir in "${TARGET_DIRS[@]}"; do
  canonical=$(readlink -f "$dir" 2>/dev/null || echo "$dir")
  found=0
  for u in "${UNIQUE_TARGETS[@]}"; do
    if [[ "$u" == "$canonical" ]]; then
      found=1
      break
    fi
  done
  if (( !found )); then
    UNIQUE_TARGETS+=("$canonical")
  fi
done

if (( ${#UNIQUE_TARGETS[@]} == 0 )); then
  echo "    Notice: No Omarchy bar plugins directory found."
  exit 0
fi

FULLWIDTH_QML_CONTENT='import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Commons
import qs.Ui

BarIndicator {
  id: root

  property bool isFullWidth: false

  active: isFullWidth
  activeText: "󰊓"
  inactiveText: ""
  activeTooltipText: "Full-Width Mode (Super+E to exit)"
  inactiveTooltipText: ""

  function updateState() {
    if (!probeProcess.running) {
      probeProcess.running = true
    }
  }

  Process {
    id: probeProcess
    command: ["bash", "-c", "hyprctl activewindow -j 2>/dev/null | jq -r \x27.fullscreen // 0\x27"]
    stdout: SplitParser {
      onRead: function(line) {
        var fs = parseInt(String(line).trim())
        root.isFullWidth = (fs > 0)
      }
    }
  }

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      var name = String(event && event.name ? event.name : "")
      if (name === "fullscreen") {
        var val = parseInt(String(event.data || "0").trim())
        root.isFullWidth = (val > 0)
      } else if (name === "activewindow" || name === "activewindowv2" || name === "focusedmon" || name === "workspace") {
        root.updateState()
      }
    }
  }

  Component.onCompleted: root.updateState()

  onPressed: function() {
    toggleProcess.running = true
  }

  Process {
    id: toggleProcess
    command: ["hyprctl", "dispatch", "hl.dsp.window.fullscreen({ mode = \"maximized\" })"]
  }
}
'

echo "--> Checking Top Bar Full-Width mode indicator across Omarchy targets..."

for bar_dir in "${UNIQUE_TARGETS[@]}"; do
  indicators_dir="$bar_dir/indicators"
  fullwidth_file="$indicators_dir/FullWidth.qml"
  widget_file="$bar_dir/widgets/Indicators.qml"

  echo "    Checking target: $bar_dir"

  # Determine if write access requires sudo
  write_cmd=()
  if [[ ! -w "$indicators_dir" || ! -w "$widget_file" ]]; then
    if [[ $EUID -ne 0 ]]; then
      if command -v sudo >/dev/null 2>&1; then
        write_cmd=(sudo)
      else
        echo "    Notice: Write permission required for $bar_dir (skipping)."
        continue
      fi
    fi
  fi

  # 1. Write FullWidth.qml if missing
  if [[ ! -f "$fullwidth_file" ]]; then
    echo "    Writing FullWidth.qml to $indicators_dir..."
    if (( ${#write_cmd[@]} > 0 )); then
      printf "%s" "$FULLWIDTH_QML_CONTENT" | "${write_cmd[@]}" tee "$fullwidth_file" > /dev/null
    else
      printf "%s" "$FULLWIDTH_QML_CONTENT" > "$fullwidth_file"
    fi
  fi

  # 2. Patch Indicators.qml defaultIndicatorEntries
  if [[ -f "$widget_file" ]] && ! grep -q '"FullWidth"' "$widget_file"; then
    echo "    Patching Indicators.qml in $widget_file..."
    if (( ${#write_cmd[@]} > 0 )); then
      "${write_cmd[@]}" sed -i 's/defaultIndicatorEntries: \[/defaultIndicatorEntries: [ "FullWidth",/' "$widget_file"
    else
      sed -i 's/defaultIndicatorEntries: \[/defaultIndicatorEntries: [ "FullWidth",/' "$widget_file"
    fi
  fi
done

echo "--> Full-Width indicator patch verified across all targets."
