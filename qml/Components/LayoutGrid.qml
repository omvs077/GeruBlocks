import QtQuick

// Geru Blocks — LayoutGrid.qml (Step 13, "layout Grid primitive")
//
// PROPOSAL: simplified to a fixed column count with a UNIFORM cell height (cellWidth is
// auto-computed from root.width; cellHeight must be supplied). A fully dynamic per-row
// auto-height grid is a materially bigger feature than what a "primitive" implies — this
// covers the common case (dashboard tiles, gallery grids of same-sized cards). Flag if a
// per-row auto-height variant is actually needed.
//
// Same non-QtQuick.Layouts approach as LayoutStack — reads the built-in Item.children list,
// no custom property named "data"/"children" declared.
//
// Usage:
//   LayoutGrid {
//       columns: 3
//       cellHeight: 120
//       StatTile { }
//       StatTile { }
//       StatTile { }
//   }

Item {
    id: root
    property int columns: 2
    property real cellHeight: 80
    property real rowSpacing: ThemeManager.spacing12
    property real columnSpacing: ThemeManager.spacing12

    readonly property real cellWidth: (width - columnSpacing * (columns - 1)) / columns

    onChildrenChanged: layoutChildren()
    onWidthChanged: layoutChildren()
    onColumnsChanged: layoutChildren()
    onCellHeightChanged: layoutChildren()
    onRowSpacingChanged: layoutChildren()
    onColumnSpacingChanged: layoutChildren()

    implicitHeight: {
        var rows = Math.ceil(children.length / columns)
        return rows * cellHeight + Math.max(0, rows - 1) * rowSpacing
    }

    function layoutChildren() {
        for (var i = 0; i < children.length; i++) {
            var child = children[i]
            var col = i % columns
            var row = Math.floor(i / columns)
            child.x = col * (cellWidth + columnSpacing)
            child.y = row * (cellHeight + rowSpacing)
            child.width = cellWidth
            child.height = cellHeight
        }
    }

    Component.onCompleted: layoutChildren()
}
