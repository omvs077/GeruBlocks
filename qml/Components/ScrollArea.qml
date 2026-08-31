import QtQuick

// Geru Blocks — ScrollArea.qml (Step 13)
//
// Wraps Flickable with a thin, auto-hiding overlay scrollbar (Windows 10 "reveal on
// hover/scroll" style) instead of a permanently-visible track — matches the system's
// minimal-chrome philosophy. clip: true is required at the root (Section 5, bug #9) since
// scrolled content genuinely moves outside the visible viewport bounds.
//
// Content is added through Flickable's own default property, `flickableData` (NOT `data` —
// Flickable redefines its default property specifically so declared children are correctly
// parented under its internal contentItem). Aliasing to a name other than `data` keeps this
// safe per Section 5 bug #1 (never redeclare a property literally named `data`).
//
// Usage:
//   ScrollArea {
//       width: 300; height: 400
//       contentWidth: width
//       contentHeight: innerColumn.height
//       Column { id: innerColumn; width: parent.width; /* long content */ }
//   }

Item {
    id: root
    default property alias content: flickable.flickableData
    property alias contentWidth: flickable.contentWidth
    property alias contentHeight: flickable.contentHeight
    clip: true

    Flickable {
        id: flickable
        anchors.fill: parent
        clip: true
        boundsBehavior: Flickable.StopAtBounds
    }

    // Vertical scrollbar — thickness is the finest token on the spacing scale (spacing4),
    // deliberately minimal for an overlay-style scrollbar that only appears on hover/scroll
    Rectangle {
        id: vTrack
        width: ThemeManager.spacing4
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        color: "transparent"
        visible: flickable.contentHeight > flickable.height

        Rectangle {
            id: vThumb
            width: parent.width
            color: ThemeManager.borderStrong
            opacity: (flickable.moving || vHover.containsMouse) ? 0.9 : 0
            Behavior on opacity {
                NumberAnimation { duration: ThemeManager.durationFast; easing.type: Easing.BezierSpline; easing.bezierCurve: ThemeManager.easingCurve }
            }

            y: (flickable.contentY / Math.max(1, flickable.contentHeight - flickable.height)) * (vTrack.height - height)
            height: Math.max(24, (flickable.height / Math.max(1, flickable.contentHeight)) * vTrack.height)
        }

        MouseArea {
            id: vHover
            anchors.fill: parent
            hoverEnabled: true
        }
    }

    // Horizontal scrollbar — same spacing4 thickness as the vertical bar, for symmetry
    Rectangle {
        id: hTrack
        height: ThemeManager.spacing4
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: "transparent"
        visible: flickable.contentWidth > flickable.width

        Rectangle {
            id: hThumb
            height: parent.height
            color: ThemeManager.borderStrong
            opacity: (flickable.moving || hHover.containsMouse) ? 0.9 : 0
            Behavior on opacity {
                NumberAnimation { duration: ThemeManager.durationFast; easing.type: Easing.BezierSpline; easing.bezierCurve: ThemeManager.easingCurve }
            }

            x: (flickable.contentX / Math.max(1, flickable.contentWidth - flickable.width)) * (hTrack.width - width)
            width: Math.max(24, (flickable.width / Math.max(1, flickable.contentWidth)) * hTrack.width)
        }

        MouseArea {
            id: hHover
            anchors.fill: parent
            hoverEnabled: true
        }
    }
}
