import QtQuick
import GeruBlocks

// List — Step 11 Data Display ("List/list-item" in the spec's
// component list)
//
// Thin wrapper around ListItem children (or anything else), same
// default-content pattern as Form.qml/Accordion.qml. Divider technique
// reuses ButtonGroup.qml's proven approach exactly: the wrapping
// Rectangle's own fill IS the divider color, and the inner Column has
// spacing:1 — each 1px gap between items reveals a divider line. No
// computed divider positions, nothing to get out of sync — deliberately
// not reinventing per-item divider insertion when this project already
// has a working, low-risk pattern for exactly this.
//
// Usage:
//   List {
//       ListItem { title: "Website Redesign" }
//       ListItem { title: "Mobile App" }
//   }

Rectangle {
    id: root
    default property alias content: contentColumn.children
    property bool showDividers: true

    // FIX: originally `width: contentColumn.width` while contentColumn
    // itself had `width: parent.width` -- a circular binding (root's
    // width defined in terms of contentColumn's, which was defined in
    // terms of root's own width) that would have resolved to 0. Default
    // width now matches Accordion.qml's established pattern: fill the
    // parent if there is one, sensible fallback otherwise -- one clear
    // direction, no self-reference.
    width: parent ? parent.width : 300
    implicitHeight: contentColumn.height
    color: showDividers ? ThemeManager.borderDefault : "transparent"

    Column {
        id: contentColumn
        width: root.width
        spacing: root.showDividers ? 1 : 0
    }
}
