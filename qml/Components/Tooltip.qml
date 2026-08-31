import QtQuick
import GeruBlocks

// Tooltip — Step 9 Transient Overlays
//
// MATERIAL NOTE: spec Section 3.5's glass-eligible list (nav pane,
// flyouts, context menus, dialogs, toasts, coachmarks) doesn't actually
// include tooltips -- solid material is spec-correct here, not a
// scope-down like the other three in this batch.
//
// HOVER DETECTION, DELIBERATE CHOICE: overlays a MouseArea on
// `anchorItem` with acceptedButtons: Qt.NoButton. Unlike ContextMenu's
// right-button-only overlay (Step 7), NoButton means this MouseArea
// never grabs a press for ANY button -- a strictly stronger
// non-interference guarantee, since a tooltip needs to work on
// literally anything (a Card, a plain Rectangle, a button that already
// has its own click handling) without touching that item's existing
// interaction at all.
//
// TIMING FLAGGED, NOT SPEC-STATED: 500ms hover delay before showing
// (avoids flashing on quick mouse passes over a row of icons),
// disappears immediately on mouse-out. No smart repositioning if it
// would run off the top of the window -- same flagged gap as
// DropdownMenu/Select/AppCombobox.
//
// Usage:
//   IconButton {
//       id: settingsBtn
//       iconName: "settings"
//       Tooltip { anchorItem: settingsBtn; text: "Settings" }
//   }

Item {
    id: root
    property Item anchorItem: null
    property string text: ""
    property int delay: 500

    parent: anchorItem
    anchors.horizontalCenter: anchorItem ? anchorItem.horizontalCenter : undefined
    y: anchorItem ? -height - ThemeManager.spacing4 : 0
    z: 2000

    width: label.implicitWidth + ThemeManager.spacing12 * 2
    height: label.implicitHeight + ThemeManager.spacing8 * 2

    property bool _shown: false
    visible: opacity > 0
    opacity: _shown ? 1.0 : 0.0

    Behavior on opacity {
        NumberAnimation {
            duration: ThemeManager.durationFast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: ThemeManager.easingCurve
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 0
        color: ThemeManager.backgroundPanel
        border.width: 1
        border.color: ThemeManager.borderDefault
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        font.family: "Poppins"
        font.pixelSize: 12
        color: ThemeManager.textPrimary
    }

    Timer {
        id: showTimer
        interval: root.delay
        onTriggered: root._shown = true
    }

    // FIX: originally `anchors.fill: root.anchorItem` alongside a
    // separate `parent: root.anchorItem` binding on this same object --
    // QML doesn't guarantee the reparenting resolves before the anchor
    // validity check runs, producing an intermittent "Cannot anchor to
    // an item that isn't a parent or sibling" runtime warning. Anchoring
    // to `parent` (whatever it currently is) instead of the external
    // reference directly is always structurally valid by definition.
    MouseArea {
        parent: root.anchorItem
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onEntered: showTimer.start()
        onExited: { showTimer.stop(); root._shown = false }
    }
}
