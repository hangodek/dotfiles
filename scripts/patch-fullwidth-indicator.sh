#!/bin/bash
# Patch Omarchy Top Bar to add a Full-Width (Super+E) Active Indicator widget
# This script must be run with sudo or via bootstrap.sh

set -euo pipefail

INDICATORS_DIR="/usr/share/omarchy/shell/plugins/bar/indicators"
FULLWIDTH_QML="$INDICATORS_DIR/FullWidth.qml"
INDICATORS_WIDGET="/usr/share/omarchy/shell/plugins/bar/widgets/Indicators.qml"

echo "--> Checking Top Bar Full-Width mode indicator..."

# Check if both FullWidth.qml exists AND Indicators.qml includes FullWidth
if [[ -f "$FULLWIDTH_QML" ]] && grep -q '"FullWidth"' "$INDICATORS_WIDGET" 2>/dev/null; then
  echo "    Full-Width indicator already active."
  exit 0
fi

if [[ ! -w "/usr/share/omarchy" && $EUID -ne 0 ]]; then
  echo "    Notice: Root permissions needed to patch /usr/share/omarchy/ (run with sudo to apply)."
  exit 0
fi

# 1. Write FullWidth.qml indicator component if missing
if [[ ! -f "$FULLWIDTH_QML" ]]; then
sudo tee "$FULLWIDTH_QML" > /dev/null << 'EOF'
import QtQuick
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
    command: ["bash", "-c", "hyprctl activewindow -j 2>/dev/null | jq -r '.fullscreen // 0'"]
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
EOF
fi

# 2. Patch Indicators.qml default list to include FullWidth if not already present
if ! grep -q '"FullWidth"' "$INDICATORS_WIDGET"; then
  echo "    Patching Indicators.qml defaultIndicatorEntries..."
  sudo sed -i 's/defaultIndicatorEntries: \[/defaultIndicatorEntries: [ "FullWidth",/' "$INDICATORS_WIDGET"
fi

echo "--> Full-Width indicator patch applied."
