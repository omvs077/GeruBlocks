import QtQuick
import GeruBlocks

// AppTreeView — Step 8 Navigation ("Tree view" in the spec's component
// list — originally scoped as a file/zone explorer under the dropped
// HVAC/BMS domain framing; generalized here to a generic recursive
// tree, matching the domain correction already applied elsewhere in
// this project (Project/Task language, not Zone/AHU).
//
// Prefixed "App" out of caution for a possible QtQuick.Controls
// TreeView naming collision (Qt 6.3+) — see TreeNode.qml's header for
// the full note. The actual recursive rendering lives in TreeNode.qml;
// this file is just the top-level Repeater over root-level nodes.
//
// Usage:
//   AppTreeView {
//       width: 260
//       model: [
//           { label: "Website Redesign", iconName: "folder", expanded: true, children: [
//               { label: "Homepage", iconName: "file" },
//               { label: "Assets", children: [
//                   { label: "logo.svg" }
//               ]}
//           ]},
//           { label: "Mobile App", iconName: "folder" }
//       ]
//       onNodeClicked: (node) => console.log("Clicked", node.label)
//   }

Column {
    id: root
    property var model: []  // array of node objects, see TreeNode.qml
    signal nodeClicked(var node)

    spacing: 0

    Repeater {
        model: root.model
        delegate: TreeNode {
            node: modelData
            depth: 0
            onNodeClicked: (n) => root.nodeClicked(n)
        }
    }
}
