import QtQuick

// Geru Blocks — Panel.qml (Step 13, "Panel/group-box" line item)
//
// PROPOSAL: implemented as a bordered box with an optional header row above the content
// (title + optional trailing action slot), rather than the classic HTML <fieldset>
// "legend cut into the border line" style. The cut-in-border look doesn't read well with
// fully sharp corners and a plain 1px hairline border, and a solid header row above the
// content matches the rest of the system's Card/Panel conventions more closely. Flag if
// the classic cut-border look is actually wanted instead.
//
// Positioning note: header and content are positioned with explicit x/y, not nested inside
// a Column — a Column-managed child cannot itself use anchors/margins on ITS children
// without fighting the positioner, so content sits in a plain Item sized/offset directly.
//
// Usage:
//   Panel {
//       title: "Details"
//       AppText { text: "Some content" }
//       AppText { text: "More content" }
//       trailingContent: IconButton { icon: "settings" }
//   }

Item {
    id: root

    property string title: ""
    default property alias content: contentColumn.data
    property alias trailingContent: trailingRow.data

    readonly property real headerHeight: root.title.length > 0 ? ThemeManager.controlHeight : 0

    width: parent ? parent.width : 300
    implicitHeight: headerHeight + contentColumn.height + (ThemeManager.spacing16 * 2)

    Rectangle {
        anchors.fill: parent
        color: ThemeManager.backgroundSurface
        border.width: 1
        border.color: ThemeManager.borderDefault
    }

    Item {
        id: headerRow
        x: 0
        y: 0
        width: parent.width
        height: root.headerHeight
        visible: root.title.length > 0

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: ThemeManager.borderDefault
        }

        AppText {
            text: root.title
            variant: "subtitle"
            anchors.left: parent.left
            anchors.leftMargin: ThemeManager.spacing16
            anchors.verticalCenter: parent.verticalCenter
        }

        Row {
            id: trailingRow
            anchors.right: parent.right
            anchors.rightMargin: ThemeManager.spacing16
            anchors.verticalCenter: parent.verticalCenter
            spacing: ThemeManager.spacing8
        }
    }

    Column {
        id: contentColumn
        x: ThemeManager.spacing16
        y: headerRow.height + ThemeManager.spacing16
        width: parent.width - ThemeManager.spacing16 * 2
        spacing: ThemeManager.spacing8
    }
}
