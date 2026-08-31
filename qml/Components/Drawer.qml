import QtQuick
import GeruBlocks

// Drawer — Step 9 Transient Overlays ("Drawer/Flyout panel" in the
// spec's component list)
//
// SCOPED DOWN FROM THE FULL SPEC RECIPE, SAME REASONING AS DIALOG.QML
// (Step 4): Section 3.5's glass recipe calls for translucent background
// + 16px backdrop blur of whatever's behind it. That needs an overlay
// architecture that can grab a live texture of app content, which
// still doesn't exist. Uses a dimming scrim (no blur) + solid, fully-
// opaque panel, exactly like Dialog. Not re-solving this per-component;
// see this batch's top-level note — worth revisiting Dialog,
// CommandPalette, ContextMenu, DropdownMenu, Drawer, and Coachmark
// together as one pass once real blur architecture exists, rather than
// partially glass-ifying one at a time.
//
// Slides in from a screen edge (`edge: "left" | "right"`, left default)
// rather than fading in place like Dialog/Popover — that's the actual
// distinguishing behavior of a drawer vs. a dialog.
//
// Usage:
//   Drawer {
//       id: navDrawer
//       edge: "left"
//       drawerWidth: 280
//       Heading { text: "Filters"; variant: "subheader" }
//       AppCheckbox { text: "Active only" }
//   }
//   navDrawer.open()

Item {
    id: root

    default property alias content: contentColumn.children
    property string edge: "left"  // "left" | "right"
    property real drawerWidth: 280
    property bool dismissOnScrimClick: true

    signal opened()
    signal closed()

    function open() { visible = true; opened() }
    function close() { visible = false; closed() }

    anchors.fill: parent
    visible: false
    z: 1000

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

        MouseArea {
            anchors.fill: parent
            enabled: root.dismissOnScrimClick
            onClicked: root.close()
        }
    }

    Rectangle {
        id: panel
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.drawerWidth
        radius: 0
        color: ThemeManager.backgroundSurface
        border.width: 1
        border.color: ThemeManager.borderDefault

        // Single x binding drives slide-in/out for BOTH edges -- no
        // anchors.left/right on this axis at all, since mixing an
        // anchor with an animated x on the same axis is exactly the
        // kind of conflicting-positioning bug this project's own
        // lessons warn about (anchors.centerIn-in-a-Column, Main.qml
        // Step 2 session). One source of truth for horizontal position.
        x: {
            if (root.edge === "left") return root.visible ? 0 : -width
            return root.visible ? (root.width - width) : root.width
        }

        Behavior on x {
            NumberAnimation {
                duration: ThemeManager.durationPanel
                easing.type: Easing.BezierSpline
                easing.bezierCurve: ThemeManager.easingCurve
            }
        }

        // Swallow clicks so they don't fall through to the scrim.
        MouseArea { anchors.fill: parent }

        Column {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: ThemeManager.spacing24
            spacing: ThemeManager.spacing16
        }
    }
}
