import QtQuick
import QtQuick.Controls.Basic as Basic
import QtQuick.Effects
import GeruBlocks

// CommandPalette — Step 4 Overlays & App Shell
//
// Global Ctrl+K searchable command interface, per your confirmed scope:
// full fuzzy search + a real command registry (CommandRegistry.qml),
// not deferred to later.
//
// FUZZY MATCH ALGORITHM, FLAGGED AS A REASONABLE IMPLEMENTATION, NOT A
// SPEC REQUIREMENT (the spec just says "Command Palette (Ctrl+K)," no
// matching-algorithm detail): simplified subsequence scoring similar in
// spirit to fzf/Sublime Text -- query characters must appear in the
// target string in order (not necessarily contiguous), with consecutive
// matches scoring higher than scattered ones. No external library, kept
// intentionally simple rather than a full weighted/typo-tolerant fuzzy
// matcher.
//
// GLASS MATERIAL — backlog item 1c (signed off, "proof-of-material"):
// same technique as Drawer.qml (see that file's header for the full
// rationale) -- ShaderEffectSource captures a live texture of whatever
// Item is passed as `backdropSource`, MultiEffect blurs it, and the
// blurred result sits inside `panel`, offset by (-panel.x, -panel.y) and
// clipped to panel's bounds. backdropSource defaults to null, so any
// usage that doesn't pass it keeps the old fully-opaque look -- no
// breaking API change.
//
// KNOWN MINOR LIMITATION, not yet resolved: unlike Drawer (which only
// translates via x), this panel also SCALES during its open/close
// transition (scale: 0.95 -> 1.0). The blur child inside panel scales
// along with it, so the blur is very slightly misaligned during the
// ~320ms transition -- it settles correctly once fully open/closed.
// Not worth solving with a second capture pass for a sub-third-of-a-
// second cosmetic wobble; flagging honestly rather than claiming it's
// pixel-perfect throughout the animation.
//
// Same scale+fade panel treatment as Dialog (duration.panel, 320ms).
// The scoped-down-from-glass-recipe note for the OTHER deferred overlays
// (Dialog, ContextMenu, DropdownMenu, Coachmark) still applies -- those
// remain unchanged, no backdrop blur yet.
//
// Usage: place ONE CommandPalette at the app root (eventually AppShell;
// for now the test harness). Ctrl+K toggles it globally. Register
// commands from anywhere via CommandRegistry.register(...).
//   CommandPalette { backdropSource: chromeRoot }   // NEW -- omit for old opaque look

Item {
    id: root

    property int _selectedIndex: 0
    property var _filteredResults: []

    // NEW (backlog 1c): the real app-content Item sitting behind this
    // overlay, to be captured + blurred. null (default) = old opaque
    // behavior, no blur.
    property Item backdropSource: null

    function open() {
        searchField.text = ""
        _updateResults()
        visible = true
        searchField.forceActiveFocus()
    }

    function close() {
        visible = false
    }

    function _fuzzyScore(query, target) {
        query = query.toLowerCase()
        target = target.toLowerCase()
        if (query === "") return 0
        var qi = 0
        var score = 0
        var consecutive = 0
        for (var ti = 0; ti < target.length && qi < query.length; ti++) {
            if (target[ti] === query[qi]) {
                qi++
                consecutive++
                score += consecutive
            } else {
                consecutive = 0
            }
        }
        return qi < query.length ? -1 : score  // -1 = not all query chars found, no match
    }

    function _updateResults() {
        var query = searchField.text
        var results = []
        for (var i = 0; i < CommandRegistry.commands.count; i++) {
            var cmd = CommandRegistry.commands.get(i)
            var s = _fuzzyScore(query, cmd.title)
            if (s >= 0) results.push({ cmd: cmd, score: s })
        }
        results.sort(function(a, b) { return b.score - a.score })
        var mapped = []
        for (var j = 0; j < results.length; j++) mapped.push(results[j].cmd)
        _filteredResults = mapped
        _selectedIndex = 0
    }

    anchors.fill: parent
    visible: false
    z: 2000

    Shortcut {
        sequence: "Ctrl+K"
        onActivated: root.visible ? root.close() : root.open()
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: root.visible ? 0.5 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: ThemeManager.durationSlow
                easing.type: Easing.BezierSpline
                easing.bezierCurve: ThemeManager.easingCurve
            }
        }
        MouseArea { anchors.fill: parent; onClicked: root.close() }
    }

    // Live capture of whatever's behind this overlay -- see Drawer.qml's
    // header for the full rationale. Only live while backdropSource is
    // supplied and the palette is actually open.
    ShaderEffectSource {
        id: bgCapture
        sourceItem: root.backdropSource
        live: root.backdropSource !== null && root.visible
        hideSource: false
        recursive: false
        visible: false
        width: root.backdropSource ? root.backdropSource.width : 1
        height: root.backdropSource ? root.backdropSource.height : 1
    }

    Rectangle {
        id: panel
        anchors.horizontalCenter: parent.horizontalCenter
        y: 100
        width: 520
        height: Math.min(420, 60 + resultsList.contentHeight)
        radius: 0
        color: "transparent"  // tint is a child Rectangle below -- see Drawer.qml LAYERING NOTE
        border.width: 1
        border.color: root.backdropSource
            ? Qt.rgba(ThemeManager.accentPrimary.r, ThemeManager.accentPrimary.g, ThemeManager.accentPrimary.b, 0.5)
            : ThemeManager.borderDefault
        clip: true

        scale: root.visible ? 1.0 : 0.95
        opacity: root.visible ? 1.0 : 0.0

        Behavior on scale {
            NumberAnimation {
                duration: ThemeManager.durationPanel
                easing.type: Easing.BezierSpline
                easing.bezierCurve: ThemeManager.easingCurve
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: ThemeManager.durationPanel
                easing.type: Easing.BezierSpline
                easing.bezierCurve: ThemeManager.easingCurve
            }
        }

        // Blurred backdrop, clipped to panel's bounds, offset to align
        // with the live capture behind it (see Drawer.qml header note).
        // Painted first (bottom-most). See header KNOWN MINOR LIMITATION
        // re: alignment during the scale transition specifically.
        MultiEffect {
            visible: root.backdropSource !== null
            source: bgCapture
            x: -panel.x
            y: -panel.y
            width: root.width
            height: root.height
            blurEnabled: true
            blur: 0.85     // increased past the spec's literal 16px -- confirmed text behind stayed too legible at 0.5/32
            blurMax: 64
            autoPaddingEnabled: false
        }

        // Tint layer, painted second (on top of blur).
        Rectangle {
            anchors.fill: parent
            color: root.backdropSource
                ? Qt.rgba(ThemeManager.accentPrimary.r, ThemeManager.accentPrimary.g, ThemeManager.accentPrimary.b, 0.28)
                : ThemeManager.backgroundSurface
        }

        MouseArea { anchors.fill: parent }  // swallow clicks so they don't hit the scrim

        Column {
            anchors.fill: parent
            anchors.margins: ThemeManager.spacing12
            spacing: ThemeManager.spacing8

            Basic.TextField {
                id: searchField
                width: parent.width
                placeholderText: "Type a command..."
                font.family: "Poppins"
                font.pixelSize: 14
                color: ThemeManager.textPrimary
                placeholderTextColor: ThemeManager.textSecondary
                background: Rectangle { radius: 0; color: "transparent"; border.width: 0 }
                onTextChanged: root._updateResults()

                Keys.onDownPressed: root._selectedIndex = Math.min(root._selectedIndex + 1, root._filteredResults.length - 1)
                Keys.onUpPressed: root._selectedIndex = Math.max(root._selectedIndex - 1, 0)
                Keys.onReturnPressed: {
                    if (root._filteredResults.length > 0) {
                        CommandRegistry.execute(root._filteredResults[root._selectedIndex].commandId)
                        root.close()
                    }
                }
                Keys.onEscapePressed: root.close()
            }

            Rectangle { width: parent.width; height: 1; color: ThemeManager.borderDefault }

            ListView {
                id: resultsList
                width: parent.width
                height: parent.height - 50
                clip: true
                model: root._filteredResults

                delegate: Rectangle {
                    width: resultsList.width
                    height: ThemeManager.rowHeight
                    color: index === root._selectedIndex ? ThemeManager.backgroundPage : "transparent"

                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: ThemeManager.spacing12
                        spacing: ThemeManager.spacing12

                        Icon {
                            anchors.verticalCenter: parent.verticalCenter
                            name: modelData.iconName
                            size: 18
                            color: ThemeManager.textSecondary
                            visible: modelData.iconName !== ""
                        }
                        AppText {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.title
                        }
                    }

                    Keycap {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: ThemeManager.spacing12
                        visible: modelData.shortcutText !== ""
                        text: modelData.shortcutText
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            CommandRegistry.execute(modelData.commandId)
                            root.close()
                        }
                    }
                }
            }
        }
    }
}

