import QtQuick

// Geru Blocks — LayoutStack.qml (Step 13, "layout Stack primitive")
//
// Shows exactly one child at a time (by currentIndex); all children are sized to fill the
// container. This project doesn't use QtQuick.Layouts anywhere (see handoff doc Section 3),
// so this is a small hand-rolled equivalent of a StackLayout, not a Layouts-based type.
//
// Iterates the built-in Item.children list (read-only, derived from declared content) —
// this is fine to read since we're not declaring our own property named "data" or
// "children" (that's the mistake to avoid, per Section 5 bug #1 — reading the built-in list
// is completely safe, only REDECLARING one of those names is the hazard).
//
// Usage:
//   LayoutStack {
//       currentIndex: 0
//       Rectangle { color: "red" }
//       Rectangle { color: "blue" }
//   }

Item {
    id: root
    property int currentIndex: 0

    onChildrenChanged: layoutChildren()
    onCurrentIndexChanged: layoutChildren()
    onWidthChanged: layoutChildren()
    onHeightChanged: layoutChildren()

    function layoutChildren() {
        for (var i = 0; i < children.length; i++) {
            var child = children[i]
            child.x = 0
            child.y = 0
            child.width = root.width
            child.height = root.height
            child.visible = (i === root.currentIndex)
        }
    }

    Component.onCompleted: layoutChildren()
}
