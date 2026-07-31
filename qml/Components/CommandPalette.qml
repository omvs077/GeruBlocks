import QtQuick
import QtQuick.Controls.Basic as Basic
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
// spirit to fzf/Sublime Text — query characters must appear in the
// target string in order (not necessarily contiguous), with consecutive
// matches scoring higher than scattered ones. No external library, kept
// intentionally simple rather than a full weighted/typo-tolerant fuzzy
// matcher.
//
// Same scale+fade panel treatment as Dialog (duration.panel, 320ms),
// and the same scoped-down-from-glass-recipe note applies here too — no
// backdrop blur yet, same reasoning as Dialog.qml.
//
// Usage: place ONE CommandPalette at the app root (eventually AppShell;
// for now the test harness). Ctrl+K toggles it globally. Register
// commands from anywhere via CommandRegistry.register(...).

Item {
    id: root

    property int _selectedIndex: 0
    property var _filteredResults: []

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

    Rectangle {
        id: panel
        anchors.horizontalCenter: parent.horizontalCenter
        y: 100
        width: 520
        height: Math.min(420, 60 + resultsList.contentHeight)
        radius: 0
        color: ThemeManager.backgroundSurface
        border.width: 1
        border.color: ThemeManager.borderDefault

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
