import QtQuick
import QtQuick.Window

// Geru Blocks — TitleBar.qml (Step 13, Window Frame)
//
// PROPOSALS flagged for Ommy's confirmation, not silently decided:
//  1. Bar height uses ThemeManager.spacing8 + ThemeManager.controlHeight (= 40px) since no
//     existing token covers "title bar height" specifically. controlHeight (32px) alone felt
//     cramped once icon + title + 3 window buttons sit side by side.
//  2. Close button's hover fill reuses color.status.error (#D64545). Strictly, spec Section
//     3.1 scopes status colors to "status indicators — dots, badges, table status cells",
//     not general UI. A red close-hover is a near-universal destructive-action convention
//     (Windows 10 itself does this) distinct from a "status" meaning — flagging as a
//     proposed second use of that token, not a silent rule-break.
//  3. Minimize/Maximize/Restore glyphs are hand-drawn with Rectangles, NOT pulled from the
//     icon set — same precedent as the chevron glyphs noted in the handoff doc: none of
//     these three are on the confirmed-existing-icon list, and guessing SVG names that
//     don't exist has already caused a real problem once. The Close button DOES use the
//     real "close" icon since that one is confirmed to exist.
//  4. The app-mark icon on the left uses a placeholder icon name ("grid") — swap for the
//     real app icon asset when one exists.
//
// Drag-to-move and native resize both use Qt 6's Window.startSystemMove()/startSystemResize()
// so the OS handles the actual move/resize (correct multi-monitor/DPI behavior, and on
// Windows this is expected to preserve Aero Snap — not independently verified on real
// hardware yet, flagging as unconfirmed like the MenuBar Alt-mnemonic item).

Item {
    id: root

    property alias title: titleText.text
    property int barHeight: ThemeManager.spacing8 + ThemeManager.controlHeight // 40px — proposal, see header
    property bool showMinimize: true
    property bool showMaximizeRestore: true
    property bool showClose: true

    // --- Step 13 chrome-wide conventions (see Step13_Spacing_Conventions.md) ---
    // Every dimension below is an explicit, named, scale-aligned constant — no inline
    // arithmetic or magic multipliers. controlButtonWidth (48) sits on the locked spacing
    // scale itself (4·8·12·16·24·32·48·64), which also happens to equal Toolbar's height,
    // giving window controls and the toolbar the same interactive footprint on purpose.
    readonly property int controlButtonWidth: 48
    readonly property int glyphSize: 12

    readonly property var win: Window.window

    width: parent ? parent.width : 400
    height: barHeight

    Rectangle {
        anchors.fill: parent
        color: ThemeManager.backgroundSurface
    }

    // Bottom hairline separating chrome from content
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: ThemeManager.borderDefault
    }

    function toggleMaximizeRestore() {
        if (!root.win) return
        if (root.win.visibility === Window.Maximized) {
            root.win.showNormal()
        } else {
            root.win.showMaximized()
        }
    }

    // --- Drag region: everything left of the button cluster ---
    MouseArea {
        anchors.left: parent.left
        anchors.right: buttonRow.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        acceptedButtons: Qt.LeftButton
        onPressed: (mouse) => {
            if (root.win) root.win.startSystemMove()
        }
        onDoubleClicked: root.toggleMaximizeRestore()
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: ThemeManager.spacing16
        anchors.verticalCenter: parent.verticalCenter
        spacing: ThemeManager.spacing8

        Icon {
            name: "grid" // PROPOSAL: placeholder app-mark, see header note 4
            size: 16
            color: ThemeManager.accentPrimary
            anchors.verticalCenter: parent.verticalCenter
        }

        AppText {
            id: titleText
            variant: "subtitle"
            color: ThemeManager.textPrimary
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // --- Window control buttons ---
    Row {
        id: buttonRow
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        spacing: 0

        // Minimize
        Rectangle {
            visible: root.showMinimize
            width: root.controlButtonWidth
            height: root.barHeight
            color: minimizeArea.containsMouse ? ThemeManager.borderDefault : "transparent"
            Behavior on color {
                ColorAnimation { duration: ThemeManager.durationMicro; easing.type: Easing.BezierSpline; easing.bezierCurve: ThemeManager.easingCurve }
            }

            Rectangle {
                anchors.centerIn: parent
                width: root.glyphSize
                height: 1 // hairline glyph stroke — matches the 1px hairline convention used
                          // for every divider/border in the system, not a spacing value
                color: ThemeManager.textPrimary
            }

            MouseArea {
                id: minimizeArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: if (root.win) root.win.showMinimized()
            }
        }

        // Maximize / Restore
        Rectangle {
            visible: root.showMaximizeRestore
            width: root.controlButtonWidth
            height: root.barHeight
            color: maximizeArea.containsMouse ? ThemeManager.borderDefault : "transparent"
            Behavior on color {
                ColorAnimation { duration: ThemeManager.durationMicro; easing.type: Easing.BezierSpline; easing.bezierCurve: ThemeManager.easingCurve }
            }

            // Restore glyph: two overlapping outlined squares (shown when maximized).
            // Bounding box is the shared glyphSize (12); inner squares are 3/4 of that (9),
            // offset by 1/4 of it (3), so the proportions scale consistently if glyphSize
            // ever changes rather than being independently hand-tuned pixel values.
            Item {
                anchors.centerIn: parent
                width: root.glyphSize
                height: root.glyphSize
                visible: root.win && root.win.visibility === Window.Maximized

                readonly property int innerSize: Math.round(root.glyphSize * 0.75)
                readonly property int offset: root.glyphSize - innerSize

                Rectangle {
                    x: parent.offset; y: 0
                    width: parent.innerSize; height: parent.innerSize
                    color: "transparent"
                    border.width: 1
                    border.color: ThemeManager.textPrimary
                }
                Rectangle {
                    x: 0; y: parent.offset
                    width: parent.innerSize; height: parent.innerSize
                    color: ThemeManager.backgroundSurface
                    border.width: 1
                    border.color: ThemeManager.textPrimary
                }
            }

            // Maximize glyph: single outlined square (shown when not maximized)
            Rectangle {
                anchors.centerIn: parent
                width: root.glyphSize
                height: root.glyphSize
                color: "transparent"
                border.width: 1
                border.color: ThemeManager.textPrimary
                visible: !root.win || root.win.visibility !== Window.Maximized
            }

            MouseArea {
                id: maximizeArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.toggleMaximizeRestore()
            }
        }

        // Close
        Rectangle {
            visible: root.showClose
            width: root.controlButtonWidth
            height: root.barHeight
            color: closeArea.containsMouse ? ThemeManager.statusError : "transparent"
            Behavior on color {
                ColorAnimation { duration: ThemeManager.durationMicro; easing.type: Easing.BezierSpline; easing.bezierCurve: ThemeManager.easingCurve }
            }

            Icon {
                anchors.centerIn: parent
                name: "close"
                size: root.glyphSize
                color: closeArea.containsMouse ? "#FFFFFF" : ThemeManager.textPrimary
            }

            MouseArea {
                id: closeArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: if (root.win) root.win.close()
            }
        }
    }
}
