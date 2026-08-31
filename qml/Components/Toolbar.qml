import QtQuick

// Geru Blocks — Toolbar.qml (Step 13, "Toolbar/Ribbon" line item)
//
// PROPOSAL: spec Step 13 bundles "Toolbar/Ribbon" as a single line-item, but a full
// Office-style multi-row tabbed Ribbon (tabs + grouped galleries + captions) is a
// materially bigger, separate scope decision on its own. This implements the literal
// toolbar half: a single horizontal action bar, solid material, bottom hairline. For
// grouping, drop a vertical Divider (Step 11) between clusters of IconButtons — that
// already covers most of what a lightweight "ribbon" needs without the full tabbed
// complexity. Flag if a genuine multi-tab Ribbon is actually required later — that's a
// bigger component than what's built here.
//
// Usage:
//   Toolbar {
//       IconButton { icon: "folder" }
//       IconButton { icon: "upload" }
//       Divider { orientation: "vertical"; height: ThemeManager.controlHeight }
//       IconButton { icon: "settings" }
//   }

Item {
    id: root
    default property alias content: row.data
    property real contentSpacing: ThemeManager.spacing8

    width: parent ? parent.width : 400
    height: ThemeManager.controlHeight + ThemeManager.spacing16

    Rectangle {
        anchors.fill: parent
        color: ThemeManager.backgroundSurface
    }
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: ThemeManager.borderDefault
    }

    Row {
        id: row
        anchors.left: parent.left
        anchors.leftMargin: ThemeManager.spacing16
        anchors.verticalCenter: parent.verticalCenter
        spacing: root.contentSpacing
    }
}
