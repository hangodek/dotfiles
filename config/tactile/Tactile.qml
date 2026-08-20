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
        "clients": [],
        "config": {
            "gaps": { "outer": 12, "inner": 8, "top_bar": 35 },
            "grid": { "rows": 2, "cols": 3, "keys": [["q", "w", "e"], ["a", "s", "d"]] },
            "col_weights": [1.0, 1.0, 1.0],
            "row_weights": [1.0, 1.0]
        }
    }

    property var firstKeyPos: null
    property var hoveredKeyPos: null
    property var keyMap: ({})
    property var gridModel: []

    Component.onCompleted: {
        try {
            var raw = Quickshell.env("TACTILE_STATE_JSON") || "{}";
            root.stateData = JSON.parse(raw);
            root.buildGridModel();
        } catch (e) {
            console.log("Error parsing state JSON:", e);
        }
    }

    function buildGridModel() {
        var grid = (root.stateData.config && root.stateData.config.grid) || { rows: 2, cols: 3, keys: [["q", "w", "e"], ["a", "s", "d"]] };
        var keys = grid.keys || [["q", "w", "e"], ["a", "s", "d"]];
        var rows = grid.rows || keys.length;
        var cols = grid.cols || (keys[0] ? keys[0].length : 3);

        var model = [];
        var kmap = {};

        for (var r = 0; r < rows; r++) {
            for (var c = 0; c < cols; c++) {
                var k = (keys[r] && keys[r][c]) ? keys[r][c] : "";
                if (k !== "") {
                    kmap[k.toLowerCase()] = [r, c];
                    model.push({
                        key: k.toUpperCase(),
                        r: r,
                        c: c,
                        subtext: "R" + (r + 1) + " C" + (c + 1)
                    });
                }
            }
        }
        root.keyMap = kmap;
        root.gridModel = model;
    }

    function quitOverlay() {
        Quickshell.execDetached(["kill", "-9", Quickshell.processId.toString()]);
    }

    function isInRange(r, c) {
        if (!root.firstKeyPos) return false;
        var r1 = root.firstKeyPos[0], c1 = root.firstKeyPos[1];
        var targetPos = root.hoveredKeyPos || root.firstKeyPos;
        var r2 = targetPos[0], c2 = targetPos[1];

        var minR = Math.min(r1, r2), maxR = Math.max(r1, r2);
        var minC = Math.min(c1, c2), maxC = Math.max(c1, c2);

        return (r >= minR && r <= maxR && c >= minC && c <= maxC);
    }

    function isFirstKey(r, c) {
        if (!root.firstKeyPos) return false;
        return (root.firstKeyPos[0] === r && root.firstKeyPos[1] === c);
    }

    function computeDimensionCoords(canvasStart, canvasTotal, inner, weights, idx1, idx2) {
        var num = weights.length;
        var sumW = 0;
        for (var i = 0; i < num; i++) sumW += weights[i];
        if (sumW <= 0) sumW = num;

        var netSpace = canvasTotal - (num - 1) * inner;
        var sizes = [];
        var allocated = 0;
        for (var i = 0; i < num; i++) {
            var s = Math.floor((weights[i] / sumW) * netSpace);
            sizes.push(s);
            allocated += s;
        }
        sizes[num - 1] += (netSpace - allocated);

        var starts = [];
        var curr = canvasStart;
        for (var i = 0; i < num; i++) {
            starts.push(curr);
            curr += sizes[i] + inner;
        }

        var targetStart = starts[idx1];
        var targetSize = 0;
        for (var i = idx1; i <= idx2; i++) {
            targetSize += sizes[i];
        }
        targetSize += (idx2 - idx1) * inner;

        return { start: targetStart, size: targetSize };
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
        var outer = gaps.outer !== undefined ? gaps.outer : 12;
        var inner = gaps.inner !== undefined ? gaps.inner : 8;
        var topBar = gaps.top_bar !== undefined ? gaps.top_bar : 35;

        var canvasX = monX + outer;
        var canvasY = monY + topBar + outer;
        var canvasW = scaledW - (2 * outer);
        var canvasH = scaledH - topBar - (2 * outer);

        var grid = (root.stateData.config && root.stateData.config.grid) || { rows: 2, cols: 3 };
        var cols = grid.cols || 3;
        var rows = grid.rows || 2;

        var colWeights = (root.stateData.config && root.stateData.config.col_weights) || [];
        while (colWeights.length < cols) colWeights.push(1.0);
        colWeights = colWeights.slice(0, cols);

        var rowWeights = (root.stateData.config && root.stateData.config.row_weights) || [];
        while (rowWeights.length < rows) rowWeights.push(1.0);
        rowWeights = rowWeights.slice(0, rows);

        var xRes = computeDimensionCoords(canvasX, canvasW, inner, colWeights, minC, maxC);
        var yRes = computeDimensionCoords(canvasY, canvasH, inner, rowWeights, minR, maxR);

        var targetX = xRes.start;
        var targetY = yRes.start;
        var targetW = xRes.size;
        var targetH = yRes.size;

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

        // Multi-window auto-reorganize into unoccupied space
        var clients = root.stateData.clients || [];
        var targetWs = (win.workspace && win.workspace.name) || "";
        var otherClients = clients.filter(function(c) {
            return c.address !== addr && (c.workspace && c.workspace.name === targetWs) && !c.hidden && c.mapped;
        });

        var occupied = {};
        for (var r = minR; r <= maxR; r++) {
            for (var c = minC; c <= maxC; c++) {
                occupied[r + "," + c] = true;
            }
        }

        var unoccupied = [];
        for (var r = 0; r < rows; r++) {
            for (var c = 0; c < cols; c++) {
                if (!occupied[r + "," + c]) {
                    unoccupied.push([r, c]);
                }
            }
        }

        if (otherClients.length > 0 && unoccupied.length > 0) {
            var oMinR = rows, oMaxR = 0, oMinC = cols, oMaxC = 0;
            for (var i = 0; i < unoccupied.length; i++) {
                var ur = unoccupied[i][0], uc = unoccupied[i][1];
                if (ur < oMinR) oMinR = ur;
                if (ur > oMaxR) oMaxR = ur;
                if (uc < oMinC) oMinC = uc;
                if (uc > oMaxC) oMaxC = uc;
            }

            var oXRes = computeDimensionCoords(canvasX, canvasW, inner, colWeights, oMinC, oMaxC);
            var oYRes = computeDimensionCoords(canvasY, canvasH, inner, rowWeights, oMinR, oMaxR);

            for (var j = 0; j < otherClients.length; j++) {
                var oAddr = otherClients[j].address;
                script += "hyprctl dispatch \"hl.dsp.focus({ window = 'address:" + oAddr + "' })\"\n";
                script += "hyprctl dispatch \"hl.dsp.window.float({ action = 'on' })\"\n";
                script += "hyprctl dispatch \"hl.dsp.window.resize({ x = " + oXRes.size + ", y = " + oYRes.size + " })\"\n";
                script += "hyprctl dispatch \"hl.dsp.window.move({ x = " + oXRes.start + ", y = " + oYRes.start + " })\"\n";
            }
            script += "hyprctl dispatch \"hl.dsp.focus({ window = 'address:" + addr + "' })\"\n";
        }

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
            anchors.topMargin: ((root.stateData.config && root.stateData.config.gaps && root.stateData.config.gaps.top_bar) !== undefined ? root.stateData.config.gaps.top_bar : 35) + ((root.stateData.config && root.stateData.config.gaps && root.stateData.config.gaps.outer) !== undefined ? root.stateData.config.gaps.outer : 12)
            anchors.bottomMargin: ((root.stateData.config && root.stateData.config.gaps && root.stateData.config.gaps.outer) !== undefined ? root.stateData.config.gaps.outer : 12)
            anchors.leftMargin: ((root.stateData.config && root.stateData.config.gaps && root.stateData.config.gaps.outer) !== undefined ? root.stateData.config.gaps.outer : 12)
            anchors.rightMargin: ((root.stateData.config && root.stateData.config.gaps && root.stateData.config.gaps.outer) !== undefined ? root.stateData.config.gaps.outer : 12)
            spacing: 16

            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                rows: (root.stateData.config && root.stateData.config.grid && root.stateData.config.grid.rows) || 2
                columns: (root.stateData.config && root.stateData.config.grid && root.stateData.config.grid.cols) || 3
                rowSpacing: ((root.stateData.config && root.stateData.config.gaps && root.stateData.config.gaps.inner) !== undefined ? root.stateData.config.gaps.inner : 8)
                columnSpacing: ((root.stateData.config && root.stateData.config.gaps && root.stateData.config.gaps.inner) !== undefined ? root.stateData.config.gaps.inner : 8)

                Repeater {
                    model: root.gridModel

                    Rectangle {
                        property var colWeights: (root.stateData.config && root.stateData.config.col_weights) || [1.0, 1.0, 1.0]
                        property var rowWeights: (root.stateData.config && root.stateData.config.row_weights) || [1.0, 1.0]

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.rowSpan: 1
                        Layout.columnSpan: 1
                        Layout.preferredWidth: (colWeights[modelData.c] !== undefined ? colWeights[modelData.c] : 1.0) * 100
                        Layout.preferredHeight: (rowWeights[modelData.r] !== undefined ? rowWeights[modelData.r] : 1.0) * 100

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
                                font.pixelSize: 40
                                font.bold: true
                                font.family: "JetBrains Mono, CaskaydiaMono Nerd Font, Fira Code, monospace"
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData.subtext
                                color: parent.parent.isSelected ? "#8ab4f8" : "#99ffffff"
                                font.pixelSize: 12
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
                        return "Tactile (" + ((root.stateData.config && root.stateData.config.grid && root.stateData.config.grid.rows) || 2) + "×" + ((root.stateData.config && root.stateData.config.grid && root.stateData.config.grid.cols) || 3) + "): " + title + "  •  Press 2 keys  •  Esc to cancel";
                    }
                    color: "#e8eaed"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }
            }
        }
    }
}
