import QtQuick
import GeruBlocks

// NavItem — Step 4 Overlays & App Shell
//
// Uses the SAME border-reveal hover behavior already built for DataTable
// rows — spec Section 3.6 explicitly groups "List rows, nav items" under
// one hover behavior, so this isn't new interaction design, just the
// same proven pattern applied to a different component.
//
// ASSUMPTION FLAGGED, NOT LOCKED: the spec doesn't describe a distinct
// "selected/active" visual for NavItem separately from hover. This
// proposes reusing the same accent reveal bar for both — selected shows
// it permanently, hovering an unselected item shows it transiently via
// the same glide-in animation — rather than inventing a second, different
// selected-indicator language. Icon/label also shift to accent/primary
// color when selected vs. muted secondary color otherwise, common nav
// convention, not spec-stated.
//
// Usage:
//   NavItem { iconName: "home"; label: "Dashboard"; selected: true }
//   NavItem { iconName: "settings"; label: "Settings"; onClicked: ... }

Item {
    id: root

    property string iconName: ""
    property string label: ""
    property bool selected: false

    signal clicked()

    implicitWidth: 220
    implicitHeight: ThemeManager.rowHeight

    readonly property bool _revealed: selected || hoverArea.containsMouse

    Rectangle {
        anchors.fill: parent
        color: root.selected ? ThemeManager.backgroundPage
               : (hoverArea.containsMouse ? ThemeManager.backgroundPage : "transparent")

        Behavior on color {
            ColorAnimation {
                duration: ThemeManager.durationBase
                easing.type: Easing.BezierSpline
                easing.bezierCurve: ThemeManager.easingCurve
            }
        }
    }

    // Border-reveal bar — persistent when selected, hover-triggered
    // otherwise, same glide-in motion either way.
    Rectangle {
        width: 3
        height: parent.height
        color: ThemeManager.accentPrimary
        x: root._revealed ? 0 : -width

        Behavior on x {
            NumberAnimation {
                duration: ThemeManager.durationBase  // "List row hover" per spec's duration table
                easing.type: Easing.BezierSpline
                easing.bezierCurve: ThemeManager.easingCurve
            }
        }
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: ThemeManager.spacing12 + 3
        anchors.rightMargin: ThemeManager.spacing12
        spacing: ThemeManager.spacing12

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            name: root.iconName
            size: 20
            color: root.selected ? ThemeManager.accentPrimary : ThemeManager.textSecondary
        }

        AppText {
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: root.selected ? ThemeManager.textPrimary : ThemeManager.textSecondary
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
}
