#!/bin/bash
# Patch Omarchy Menu (Super + Space) to add silky-smooth Spotlight-style zoom and fade animation.
# Automatically supports system (/usr/share/omarchy) and dev channel checkout paths.

set -euo pipefail

TARGET_FILES=()

if [[ -f "${HOME}/omarchy/shell/plugins/menu/Menu.qml" ]]; then
  TARGET_FILES+=("${HOME}/omarchy/shell/plugins/menu/Menu.qml")
fi

if [[ -n "${OMARCHY_PATH:-}" && -f "${OMARCHY_PATH}/shell/plugins/menu/Menu.qml" ]]; then
  TARGET_FILES+=("${OMARCHY_PATH}/shell/plugins/menu/Menu.qml")
fi

if [[ -f "/usr/share/omarchy/shell/plugins/menu/Menu.qml" ]]; then
  TARGET_FILES+=("/usr/share/omarchy/shell/plugins/menu/Menu.qml")
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
  echo "    Notice: No Omarchy Menu.qml found."
  exit 0
fi

echo "--> Checking Spotlight-style smooth zoom & fade animation for Menu.qml across targets..."

for menu_path in "${UNIQUE_FILES[@]}"; do
  echo "    Checking target: $menu_path"

  python3 -c "
import sys, os

menu_path = '$menu_path'
with open(menu_path, 'r') as f:
    content = f.read()

if 'Easing.OutCubic' in content and ('scale: root.opened' in content or 'scale: (root.opened' in content or 'scale: panel.shown' in content):
    print('    Spotlight zoom & fade animation already active in ' + menu_path)
    sys.exit(0)

if not os.access(menu_path, os.W_OK):
    print('    Notice: Write permission required for ' + menu_path + ' (run with sudo to apply).')
    sys.exit(0)

# Check whether target uses OverlayWindow (dev channel) or PanelWindow (stable channel)
is_overlay = 'OverlayWindow {' in content

modified = False

if is_overlay:
    # 1. Scrim fade animation for OverlayWindow
    target_scrim = '''    Rectangle {
      anchors.fill: parent
      color: root.scrim
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.cancel()
    }'''

    repl_scrim = '''    Rectangle {
      id: scrimRect
      anchors.fill: parent
      color: root.scrim
      opacity: root.opened && root.rowsLoaded ? 1.0 : 0.0

      Behavior on opacity {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
      }
    }

    MouseArea {
      anchors.fill: parent
      enabled: root.opened
      onClicked: root.cancel()
    }'''

    # 2. Card scale & opacity animation for OverlayWindow
    target_card = '''    BorderSurface {
      id: card
      width: root.cardWidth
      height: Math.min(root.cardHeight, panel.height - Style.gapsOut - panel.effectiveCardTop)
      radius: root.cornerRadius
      anchors.horizontalCenter: parent.horizontalCenter
      y: panel.effectiveCardTop
      color: root.background
      borderSpec: root.borderSpec
      padding: root.contentMargin

      MouseArea { anchors.fill: parent; onClicked: {} }'''

    repl_card = '''    BorderSurface {
      id: card
      width: root.cardWidth
      height: Math.min(root.cardHeight, panel.height - Style.gapsOut - panel.effectiveCardTop)
      radius: root.cornerRadius
      anchors.horizontalCenter: parent.horizontalCenter
      y: panel.effectiveCardTop
      color: root.background
      borderSpec: root.borderSpec
      padding: root.contentMargin
      opacity: root.opened && root.rowsLoaded ? 1.0 : 0.0
      scale: root.opened && root.rowsLoaded ? 1.0 : 0.96
      transformOrigin: Item.Center

      Behavior on opacity {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
      }
      Behavior on scale {
        NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
      }

      MouseArea { anchors.fill: parent; onClicked: {} }'''

    if target_scrim in content:
        content = content.replace(target_scrim, repl_scrim, 1)
        modified = True
    if target_card in content:
        content = content.replace(target_card, repl_card, 1)
        modified = True

else:
    # Classic PanelWindow (stable channel)
    target1 = '''  PanelWindow {
    id: panel
    visible: root.opened && root.rowsLoaded
    anchors { top: true; bottom: true; left: true; right: true }
    color: \"transparent\"
    WlrLayershell.namespace: \"omarchy-menu\"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive'''

    repl1 = '''  PanelWindow {
    id: panel
    visible: (root.opened && root.rowsLoaded) || card.opacity > 0
    anchors { top: true; bottom: true; left: true; right: true }
    color: \"transparent\"
    WlrLayershell.namespace: \"omarchy-menu\"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None'''

    target2 = '''    Rectangle {
      anchors.fill: parent
      color: root.scrim
    }

    MouseArea {
      anchors.fill: parent
      onClicked: root.cancel()
    }'''

    repl2 = '''    Rectangle {
      id: scrimRect
      anchors.fill: parent
      color: root.scrim
      opacity: root.opened && root.rowsLoaded ? 1.0 : 0.0

      Behavior on opacity {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
      }
    }

    MouseArea {
      anchors.fill: parent
      enabled: root.opened
      onClicked: root.cancel()
    }'''

    target3 = '''    BorderSurface {
      id: card
      width: root.cardWidth
      height: Math.min(root.cardHeight, panel.height - Style.gapsOut - panel.effectiveCardTop)
      radius: root.cornerRadius
      anchors.horizontalCenter: parent.horizontalCenter
      y: panel.effectiveCardTop
      color: root.background
      borderSpec: root.borderSpec
      padding: root.contentMargin

      MouseArea { anchors.fill: parent; onClicked: {} }'''

    repl3 = '''    BorderSurface {
      id: card
      width: root.cardWidth
      height: Math.min(root.cardHeight, panel.height - Style.gapsOut - panel.effectiveCardTop)
      radius: root.cornerRadius
      anchors.horizontalCenter: parent.horizontalCenter
      y: panel.effectiveCardTop
      color: root.background
      borderSpec: root.borderSpec
      padding: root.contentMargin
      opacity: root.opened && root.rowsLoaded ? 1.0 : 0.0
      scale: root.opened && root.rowsLoaded ? 1.0 : 0.96
      transformOrigin: Item.Center

      Behavior on opacity {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
      }
      Behavior on scale {
        NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
      }

      MouseArea { anchors.fill: parent; onClicked: {} }'''

    if target1 in content:
        content = content.replace(target1, repl1, 1)
        modified = True
    if target2 in content:
        content = content.replace(target2, repl2, 1)
        modified = True
    if target3 in content:
        content = content.replace(target3, repl3, 1)
        modified = True

if modified:
    with open(menu_path, 'w') as f:
        f.write(content)
    print('    Spotlight animation patch applied successfully to ' + menu_path)
else:
    print('    Notice: Patch targets not found in ' + menu_path)
"
done
