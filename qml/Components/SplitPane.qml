import QtQuick

// Geru Blocks — SplitPane.qml (Step 13)
//
// NEW GOTCHA (extends handoff doc Section 5 — not previously hit in Steps 1-12): assigning
// an Item to a plain typed property (e.g. `property Item first`) does NOT automatically
// parent it into the visual scene the way the built-in default `data` property does. Unlike
// a component's default-property children, an item passed through a custom typed property
// has no QQuickItem parent set for it automatically — it will exist in the object tree but
// render nowhere until `.parent` is set explicitly. Handled below via onFirstChanged/
// onSecondChanged. Worth remembering for any future component that takes content through a
// named property instead of the default property (Split pane needs exactly two named slots,
// so the default property alone can't distinguish "first" from "second").
//
// Positioning uses explicit x/y/width/height only, no anchors mixed in on the same axis —
// per Section 5 bug #5 (mixing anchors with directly-manipulated x/y on one axis fights
// itself). divider.x (or .y) is the single source of truth; firstContainer/secondContainer
// geometry is derived from it, and MouseArea's built-in `drag.target` updates it during a
// drag (this intentionally breaks any binding on divider.x once the user starts dragging,
// which is the correct, expected behavior — the user has taken control of the position).
//
// Usage:
//   SplitPane {
//       orientation: "horizontal"
//       first: MyListView { }
//       second: MyDetailView { }
//   }

Item {
    id: root

    property string orientation: "horizontal" // "horizontal" | "vertical"
    property int minFirstSize: 120
    property int minSecondSize: 120
    property int dividerSize: 4

    property Item first
    property Item second

    readonly property bool isHorizontal: orientation === "horizontal"
    readonly property real splitPosition: isHorizontal ? divider.x : divider.y

    onFirstChanged: if (first) first.parent = firstContainer
    onSecondChanged: if (second) second.parent = secondContainer

    Item {
        id: firstContainer
        x: 0
        y: 0
        width: root.isHorizontal ? divider.x : root.width
        height: root.isHorizontal ? root.height : divider.y
        clip: true

        onWidthChanged: if (root.first) { root.first.width = width; root.first.height = height }
        onHeightChanged: if (root.first) { root.first.width = width; root.first.height = height }
    }

    Rectangle {
        id: divider
        x: root.isHorizontal ? Math.round(root.width / 2) : 0
        y: root.isHorizontal ? 0 : Math.round(root.height / 2)
        width: root.isHorizontal ? root.dividerSize : root.width
        height: root.isHorizontal ? root.height : root.dividerSize
        color: (dividerArea.containsMouse || dividerArea.drag.active) ? ThemeManager.accentPrimary : ThemeManager.borderDefault
        Behavior on color {
            ColorAnimation { duration: ThemeManager.durationMicro; easing.type: Easing.BezierSpline; easing.bezierCurve: ThemeManager.easingCurve }
        }

        MouseArea {
            id: dividerArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: root.isHorizontal ? Qt.SizeHorCursor : Qt.SizeVerCursor
            drag.target: divider
            drag.axis: root.isHorizontal ? Drag.XAxis : Drag.YAxis
            drag.minimumX: root.minFirstSize
            drag.maximumX: root.width - root.minSecondSize - root.dividerSize
            drag.minimumY: root.minFirstSize
            drag.maximumY: root.height - root.minSecondSize - root.dividerSize
        }
    }

    Item {
        id: secondContainer
        x: root.isHorizontal ? divider.x + root.dividerSize : 0
        y: root.isHorizontal ? 0 : divider.y + root.dividerSize
        width: root.isHorizontal ? root.width - divider.x - root.dividerSize : root.width
        height: root.isHorizontal ? root.height : root.height - divider.y - root.dividerSize
        clip: true

        onWidthChanged: if (root.second) { root.second.width = width; root.second.height = height }
        onHeightChanged: if (root.second) { root.second.width = width; root.second.height = height }
    }
}
