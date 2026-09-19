import QtQuick
import GeruBlocks

// ListItem — Step 11 Data Display
//
// Generic row: optional leading slot (icon/avatar), title + optional
// subtitle, optional trailing slot (a Badge, StatusDot, chevron,
// etc). Border-reveal hover, matching NavItem.qml/TreeNode.qml exactly
// (spec 3.6 groups "list rows, nav items" under one hover behavior).
//
// TYPEFACE (Phase 3 typography backlog, lever 3): subtitle switches to
// IBM Plex Sans — this is the literal target of the backlog's "List
// secondary text" line (List.qml itself is just a wrapper/divider
// container with no text of its own). Title stays Poppins, same
// metadata-vs-main-content split as Timeline's timestamp / KeyValue's key.
//
// SLOT PATTERN: leading/trailing use `.data`-aliased containers, a
// standard QML technique for accepting arbitrary declared content into
// a named property — distinct from Form/Accordion's single default-
// property pattern since ListItem needs TWO independent slots. The
// container auto-sizes to whatever's assigned via childrenRect, so an
// empty slot costs nothing and needs no visible-toggling logic.
//
// Usage:
//   ListItem {
//       title: "Website Redesign"
//       subtitle: "Updated 2 hours ago"
//       leading: Avatar { name: "Priya Nair"; size: 32 }
//       trailing: StatusDot { status: "success" }
//       onClicked: openProject()
//   }

Item {
    id: root
    property string title: ""
    property string subtitle: ""
    property alias leading: leadingContainer.data
    property alias trailing: trailingContainer.data
    signal clicked()

    width: parent ? parent.width : 320
    implicitHeight: root.subtitle !== "" ? 56 : ThemeManager.rowHeight

    Rectangle {
        anchors.fill: parent
        color: hoverArea.containsMouse ? ThemeManager.backgroundPage : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: ThemeManager.durationBase
                easing.type: Easing.BezierSpline
                easing.bezierCurve: ThemeManager.easingCurve
            }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: hoverArea.containsMouse ? 3 : 0
        color: ThemeManager.accentPrimary

        Behavior on width {
            NumberAnimation {
                duration: ThemeManager.durationBase
                easing.type: Easing.BezierSpline
                easing.bezierCurve: ThemeManager.easingCurve
            }
        }
    }

    Item {
        id: trailingContainer
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: ThemeManager.spacing12
        width: childrenRect.width
        height: childrenRect.height
    }

    Row {
        anchors.left: parent.left
        anchors.right: trailingContainer.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: ThemeManager.spacing12
        anchors.rightMargin: ThemeManager.spacing12
        spacing: ThemeManager.spacing12

        Item {
            id: leadingContainer
            anchors.verticalCenter: parent.verticalCenter
            width: childrenRect.width
            height: childrenRect.height
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            AppText { text: root.title; color: ThemeManager.textPrimary }
            AppText {
                text: root.subtitle
                variant: "caption"
                color: ThemeManager.textSecondary
                visible: root.subtitle !== ""
                font.family: "IBM Plex Sans"
            }
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
