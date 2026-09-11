import QtQuick
import GeruBlocks

// TreeNode — Step 8 Navigation
//
// One recursive node in AppTreeView.qml. Renders arbitrarily-nested
// trees by loading itself via Loader + Qt.resolvedUrl("TreeNode.qml")
// (see the Loader block below) rather than instantiating TreeNode by
// type name inside its own file — Qt disallows the latter at compile
// time ("X is instantiated recursively"), a real limitation this file
// hit and got wrong on the first pass.
//
// Named "AppTreeView", not "TreeView" (the pair's container file), out
// of caution: Qt 6.3+ added a QtQuick.Controls TreeView type, and this
// project's own convention is to prefix rather than risk a same-name
// collision (AppText, AppTextInput, AppCheckbox all follow this for
// exactly this reason). TreeNode itself has no known collision risk.
//
// Row styling reuses NavItem.qml's border-reveal hover pattern exactly
// (spec 3.6 groups "list rows, nav items" under one hover behavior —
// a tree row is functionally a nav item at variable depth).
//
// Expand/collapse uses a text glyph (▶/▼), the same established
// fallback as Select.qml's indicator and Accordion's chevron — no
// confirmed dedicated expand/collapse icon exists yet.
//
// MOTION (Phase 2 backlog): children reveal previously had ZERO
// transition — a hard `visible` cut, not just an unmapped duration.
// Replaced with the same clipped-height-Behavior pattern
// AccordionSection already uses, at durationFast (150ms) — "same gap,
// same fix" per the backlog's own wording. Reduced-motion gated.
//
// Node shape: { label, iconName?, children?: [...], expanded? }

Column {
    id: root
    property var node: ({})
    property int depth: 0
    property bool expanded: node.expanded === true
    signal nodeClicked(var node)

    width: parent ? parent.width : 220

    readonly property bool hasChildren: node.children !== undefined && node.children.length > 0

    Item {
        id: rowItem
        width: root.width
        height: ThemeManager.rowHeight

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

        Row {
            anchors.fill: parent
            anchors.leftMargin: ThemeManager.spacing8 + (root.depth * ThemeManager.spacing16)
            anchors.rightMargin: ThemeManager.spacing12
            spacing: ThemeManager.spacing8

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: root.hasChildren
                text: root.expanded ? "\u25BC" : "\u25B6"
                font.pixelSize: 9
                color: ThemeManager.textSecondary
                width: 12
            }
            Item { visible: !root.hasChildren; width: 12; height: 1 }

            Icon {
                visible: root.node.iconName !== undefined && root.node.iconName !== ""
                anchors.verticalCenter: parent.verticalCenter
                name: root.node.iconName !== undefined ? root.node.iconName : ""
                size: 16
                color: ThemeManager.textSecondary
            }

            AppText {
                anchors.verticalCenter: parent.verticalCenter
                text: root.node.label !== undefined ? root.node.label : ""
                color: ThemeManager.textPrimary
            }
        }

        MouseArea {
            id: hoverArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.hasChildren) root.expanded = !root.expanded
                root.nodeClicked(root.node)
            }
        }
    }

    Item {
        id: childrenClip
        width: root.width
        clip: true
        height: (root.expanded && root.hasChildren) ? childrenColumn.implicitHeight : 0

        Behavior on height {
            enabled: !ThemeManager.reducedMotion
            NumberAnimation {
                duration: ThemeManager.durationFast
                easing.type: Easing.BezierSpline
                easing.bezierCurve: ThemeManager.easingCurve
            }
        }

        Column {
            id: childrenColumn
            width: root.width

            Repeater {
                model: root.hasChildren ? root.node.children : []

                // Recursion fix: TreeNode cannot instantiate TreeNode by type
                // name inside its own file -- Qt disallows that at compile
                // time ("TreeNode is instantiated recursively"), regardless
                // of runtime guards like `visible`. Loading itself by file
                // URL through a Loader defers resolution to runtime instead
                // of compile time, which is the standard way to do
                // recursive QML trees.
                Loader {
                    id: childLoader
                    width: root.width
                    property var _pendingNode: modelData
                    property int _pendingDepth: root.depth + 1
                    source: Qt.resolvedUrl("TreeNode.qml")

                    onLoaded: {
                        item.node = childLoader._pendingNode
                        item.depth = childLoader._pendingDepth
                        item.nodeClicked.connect(function(n) { root.nodeClicked(n) })
                    }
                }
            }
        }
    }
}
