#!/bin/bash
# Patch Omarchy Menu (Super + Space) to add silky-smooth Spotlight-style zoom and fade animation.
# Usage: sudo bash ~/dotfiles/scripts/patch-smooth-menu.sh

set -euo pipefail

MENU_FILE="/usr/share/omarchy/shell/plugins/menu/Menu.qml"

if [[ ! -f "$MENU_FILE" ]]; then
  echo "Omarchy Menu.qml not found at $MENU_FILE"
  exit 0
fi

echo "--> Checking Spotlight-style smooth zoom & fade animation for Menu.qml..."

python3 -c "
import sys, os

menu_path = '$MENU_FILE'
with open(menu_path, 'r') as f:
    content = f.read()

if 'Easing.OutCubic' in content and 'scale: root.opened' in content:
    print('    Spotlight zoom & fade animation already active.')
    sys.exit(0)

if not os.access(menu_path, os.W_OK):
    print('    Notice: Root permissions needed to patch /usr/share/omarchy/ (run with sudo to apply).')
    sys.exit(0)

# 1. Update PanelWindow visibility & focus
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

# 2. Update scrim fade animation
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

# 3. Update card scale & opacity animation
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

modified = False
if target1 in content:
    content = content.replace(target1, repl1)
    modified = True
if target2 in content:
    content = content.replace(target2, repl2)
    modified = True
if target3 in content:
    content = content.replace(target3, repl3)
    modified = True

if modified:
    with open(menu_path, 'w') as f:
        f.write(content)
    print('    Spotlight animation patch applied successfully.')
else:
    print('    Spotlight animation already up to date.')
"
