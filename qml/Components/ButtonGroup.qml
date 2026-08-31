import QtQuick
import GeruBlocks

// ButtonGroup — Step 7 Actions & Menus
//
// Visually joins a row of Button/IconButton children into one bordered
// toolbar unit. NOT a single-select control — that's SegmentedControl
// (Step 5), which tracks a current value. ButtonGroup only affects
// layout/border; each child keeps its own independent onClicked.
//
// DIVIDER TECHNIQUE, DELIBERATE: rather than computing divider-line
// positions by summing child widths in a binding (fragile — this
// project already lost real time once to a QML binding-destruction bug
// in DatePicker, so any binding whose correctness depends on manual
// index math is being avoided on principle here), the wrapping
// Rectangle's own fill color IS the divider color, and the inner Row
// has spacing:1 — each 1px gap between opaque child buttons reveals a
// sliver of that background as a clean divider line. No computed
// positions, nothing to get out of sync.
//
// Usage:
//   ButtonGroup {
//       IconButton { iconName: "grid" }
//       IconButton { iconName: "list_bulleted" }
//       IconButton { glyph: "\u25BC" }
//   }

Rectangle {
    id: root

    default property alias content: inner.children

    radius: 0
    border.width: 1
    border.color: ThemeManager.borderDefault
    color: ThemeManager.borderDefault
    implicitWidth: inner.width + 2
    implicitHeight: inner.height + 2

    Row {
        id: inner
        anchors.centerIn: parent
        spacing: 1
    }
}
