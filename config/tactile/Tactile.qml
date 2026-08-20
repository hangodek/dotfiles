import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "tactile-hud"

    color: "#b30a0a0f"

    property var stateData: {
        "window": {},
        "monitor": {},
        "config": {
            "gaps": { "outer": 12, "inner": 8, "top_bar": 35 },
            "grid": { "rows": 2, "cols": 3, "keys": [["q", "w", "e"], ["a", "s", "d"]] }
        }
    }

    property var firstKeyPos: null
    property var hoveredKeyPos: null

    property var keyMap: {
        "q": [0, 0], "w": [0, 1], "e": [0, 2],
        "a": [1, 0], "s": [1, 1], "d": [1, 2]
    }

    property var subNames: [
        ["Top Left", "Top Mid", "Top Right"],
        ["Bottom Left", "Bottom Mid", "Bottom Right"]
    ]

    Component.onCompleted: {
        try {
            var raw = Quickshell.env("TACTILE_STATE_JSON") || "{}";
            root.stateData = JSON.parse(raw);
        } catch (e) {
            console.log("Error parsing state JSON:", e);
        }
    }

    function quitOverlay() {
        Quickshell.execDetached(["kill", "-9", Quickshell.processId.toString()]);
    }

    function isInRange(r, c) {
        if (!root.firstKeyPos) return false;
        var r1 = root.firstKeyPos[0];
        var c1 = root.firstKeyPos[1];
        
        var targetPos = root.hoveredKeyPos || root.firstKeyPos;
        var r2 = targetPos[0];
        var c2 = targetPos[1];

        var minR = Math.min(r1, r2);
        var maxR = Math.max(r1, r2);
        var minC = Math.min(c1, c2);
        var maxC = Math.max(c1, c2);

        return (r >= minR && r <= maxR && c >= minC && c <= maxC);
    }

    function isFirstKey(r, c) {
        if (!root.firstKeyPos) return false;
        return (root.firstKeyPos[0] === r && root.firstKeyPos[1] === c);
    }

    function snap(pos1, pos2) {
        var r1 = pos1[0], c1 = pos1[1];
        var r2 = pos2[0], c2 = pos2[1];

        var minR = Math.min(r1, r2), maxR = Math.max(r1, r2);
        var minC = Math.min(c1, c2), maxC = Math.max(c1, c2);

        var mon = root.stateData.monitor || {};
        var monW = mon.width || 1920;
        var monH = mon.height || 1080;
        var scale = mon.scale || 1.0;
        var monX = mon.x || 0;
        var monY = mon.y || 0;

        var scaledW = Math.floor(monW / scale);
        var scaledH = Math.floor(monH / scale);

        var gaps = (root.stateData.config && root.stateData.config.gaps) || { outer: 12, inner: 8, top_bar: 35 };
        var outer = gaps.outer || 12;
        var inner = gaps.inner || 8;
        var topBar = gaps.top_bar || 35;

        var canvasX = monX + outer;
        var canvasY = monY + topBar + outer;
        var canvasW = scaledW - (2 * outer);
        var canvasH = scaledH - topBar - (2 * outer);

        var cols = 3, rows = 2;
        var cellW = (canvasW - ((cols - 1) * inner)) / cols;
        var cellH = (canvasH - ((rows - 1) * inner)) / rows;

        var targetX = Math.floor(canvasX + minC * (cellW + inner));
        var targetY = Math.floor(canvasY + minR * (cellH + inner));

        var spanCols = (maxC - minC + 1);
        var spanRows = (maxR - minR + 1);

        var targetW = Math.floor(spanCols * cellW + (spanCols - 1) * inner);
        var targetH = Math.floor(spanRows * cellH + (spanRows - 1) * inner);

        var win = root.stateData.window || {};
        var addr = win.address || "";
        var isFullscreen = win.fullscreen && win.fullscreen !== 0;

        var script = "";
        if (isFullscreen) {
            script += "hyprctl dispatch \"hl.dsp.window.fullscreen({ action = 'toggle' })\"\n";
        }
        if (addr !== "") {
            script += "hyprctl dispatch \"hl.dsp.focus({ window = 'address:" + addr + "' })\"\n";
        }
        script += "hyprctl dispatch \"hl.dsp.window.float({ action = 'on' })\"\n";
        script += "hyprctl dispatch \"hl.dsp.window.resize({ x = " + targetW + ", y = " + targetH + " })\"\n";
        script += "hyprctl dispatch \"hl.dsp.window.move({ x = " + targetX + ", y = " + targetY + " })\"\n";

        Quickshell.execDetached(["bash", "-c", script]);
        root.quitOverlay();
    }

    Item {
        id: container
        anchors.fill: parent
        focus: true

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                root.quitOverlay();
                event.accepted = true;
                return;
            }

            var keyText = event.text.toLowerCase();
            if (root.keyMap[keyText] !== undefined) {
                var pos = root.keyMap[keyText];
                if (!root.firstKeyPos) {
                    root.firstKeyPos = pos;
                } else {
                    root.snap(root.firstKeyPos, pos);
                }
                event.accepted = true;
            } else if ((event.key === Qt.Key_Return || event.key === Qt.Key_Space) && root.firstKeyPos) {
                root.snap(root.firstKeyPos, root.firstKeyPos);
                event.accepted = true;
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: ((root.stateData.config && root.stateData.config.gaps && root.stateData.config.gaps.top_bar) || 35) + ((root.stateData.config && root.stateData.config.gaps && root.stateData.config.gaps.outer) || 12)
            anchors.bottomMargin: ((root.stateData.config && root.stateData.config.gaps && root.stateData.config.gaps.outer) || 12)
            anchors.leftMargin: ((root.stateData.config && root.stateData.config.gaps && root.stateData.config.gaps.outer) || 12)
            anchors.rightMargin: ((root.stateData.config && root.stateData.config.gaps && root.stateData.config.gaps.outer) || 12)
            spacing: 16

            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                rows: 2
                columns: 3
                rowSpacing: ((root.stateData.config && root.stateData.config.gaps && root.stateData.config.gaps.inner) || 8)
                columnSpacing: ((root.stateData.config && root.stateData.config.gaps && root.stateData.config.gaps.inner) || 8)

                Repeater {
                    model: [
                        { key: "Q", r: 0, c: 0 },
                        { key: "W", r: 0, c: 1 },
                        { key: "E", r: 0, c: 2 },
                        { key: "A", r: 1, c: 0 },
                        { key: "S", r: 1, c: 1 },
                        { key: "D", r: 1, c: 2 }
                    ]

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 16

                        property bool isSelected: root.isFirstKey(modelData.r, modelData.c)
                        property bool inRange: root.isInRange(modelData.r, modelData.c)

                        color: isSelected ? "#598ab4f8" : (inRange ? "#338ab4f8" : "#14ffffff")
                        border.color: isSelected ? "#8ab4f8" : (inRange ? "#808ab4f8" : "#24ffffff")
                        border.width: isSelected ? 3 : 2

                        Behavior on color { ColorAnimation { duration: 120 } }
                        Behavior on border.color { ColorAnimation { duration: 120 } }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: root.hoveredKeyPos = [modelData.r, modelData.c]
                            onExited: {
                                if (root.hoveredKeyPos && root.hoveredKeyPos[0] === modelData.r && root.hoveredKeyPos[1] === modelData.c) {
                                    root.hoveredKeyPos = null;
                                }
                            }
                            onClicked: {
                                if (!root.firstKeyPos) {
                                    root.firstKeyPos = [modelData.r, modelData.c];
                                } else {
                                    root.snap(root.firstKeyPos, [modelData.r, modelData.c]);
                                }
                            }
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.key
                                color: parent.parent.isSelected ? "#ffffff" : "#f1f3f4"
                                font.pixelSize: 44
                                font.bold: true
                                font.family: "JetBrains Mono, CaskaydiaMono Nerd Font, Fira Code, monospace"
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: root.subNames[modelData.r][modelData.c]
                                color: parent.parent.isSelected ? "#8ab4f8" : "#99ffffff"
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                height: 38
                width: footerText.width + 48
                radius: 19
                color: "#99000000"
                border.color: "#33ffffff"
                border.width: 1

                Text {
                    id: footerText
                    anchors.centerIn: parent
                    text: {
                        var title = (root.stateData.window && root.stateData.window.title) || "Active Window";
                        if (title.length > 36) title = title.substring(0, 33) + "...";
                        return "Tactile: " + title + "  •  Press 2 keys (e.g. Q D = Full, Q A = Left, W D = Right)  •  Esc to cancel";
                    }
                    color: "#e8eaed"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }
            }
        }
    }
}
