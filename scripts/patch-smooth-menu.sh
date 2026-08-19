#!/bin/bash
# Patch Omarchy Menu (Super + Space) to add silky-smooth Spotlight-style zoom and fade animation.
# Usage: sudo bash ~/dotfiles/scripts/patch-smooth-menu.sh

set -euo pipefail

MENU_FILE="/usr/share/omarchy/shell/plugins/menu/Menu.qml"

if [[ ! -f "$MENU_FILE" ]]; then
  echo "Omarchy Menu.qml not found at $MENU_FILE"
  exit 1
fi

echo "==> Applying Spotlight-style smooth zoom & fade animation to Menu.qml..."

python3 -c "
with open('$MENU_FILE', 'r') as f:
    content = f.read()

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

if target1 in content:
    content = content.replace(target1, repl1)
if target2 in content:
    content = content.replace(target2, repl2)
if target3 in content:
    content = content.replace(target3, repl3)

with open('$MENU_FILE', 'w') as f:
    f.write(content)
"

echo "==> Done! Animation patch applied to Menu.qml."
