import QtQuick
import GeruBlocks

// AccordionSection — Step 8 Navigation
//
// One collapsible section, meant to be used as a child of Accordion.qml.
// Follows Form.qml's thin-wrapper precedent: arbitrary content as
// children via a default property, not a fixed content-model schema —
// so any component (AppCheckbox, AppText, a whole DataTable) can live
// inside a section without AccordionSection needing to know about it.
//
// MOTION (Phase 2 backlog): expand/collapse duration remapped from
// durationSlow to durationFast (150ms) — "same bucket as dropdown-open/
// tab-switch" per the backlog's decided mapping. Reduced-motion gate
// added (was previously missing — Section 8's rule wasn't consistently
// wired into every animated component; fixing as encountered, per the
// backlog's own instruction not to defer this further).
//
// Usage (always as a child of Accordion, not standalone):
//   AccordionSection {
//       title: "Advanced Settings"
//       AppCheckbox { text: "Enable beta features" }
//   }

Column {
    id: root

    default property alias content: contentColumn.children
    property string title: ""
    property bool expanded: false
    signal toggled()

    width: parent ? parent.width : 300

    Item {
        id: header
        width: root.width
        height: ThemeManager.rowHeight

        Rectangle {
            anchors.fill: parent
            color: headerArea.containsMouse ? ThemeManager.backgroundPage : ThemeManager.backgroundSurface
        }

        Row {
            anchors.fill: parent
            anchors.leftMargin: ThemeManager.spacing12
            anchors.rightMargin: ThemeManager.spacing12
            spacing: ThemeManager.spacing8

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.expanded ? "\u25BC" : "\u25B6"
                font.pixelSize: 10
                color: ThemeManager.textSecondary
                width: 12
            }

            AppText {
                anchors.verticalCenter: parent.verticalCenter
                text: root.title
                variant: "subtitle"
            }
        }

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: ThemeManager.borderDefault
        }

        MouseArea {
            id: headerArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggled()
        }
    }

    Item {
        id: bodyClip
        width: root.width
        clip: true
        height: root.expanded ? contentColumn.implicitHeight + ThemeManager.spacing16 * 2 : 0

        Behavior on height {
            enabled: !ThemeManager.reducedMotion
            NumberAnimation {
                duration: ThemeManager.durationFast
                easing.type: Easing.BezierSpline
                easing.bezierCurve: ThemeManager.easingCurve
            }
        }

        Column {
            id: contentColumn
            x: ThemeManager.spacing12
            y: ThemeManager.spacing16
            width: parent.width - ThemeManager.spacing12 * 2
            spacing: ThemeManager.spacing8
        }
    }
}
