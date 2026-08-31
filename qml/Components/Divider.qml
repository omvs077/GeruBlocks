import QtQuick
import GeruBlocks

// Divider — Step 11 Data Display
// Formalizes the inline `Rectangle { width: parent.width; height: 1;
// color: ThemeManager.borderDefault }` pattern already hand-rolled
// throughout Main.qml as an actual reusable component. Also supports a
// vertical orientation for inline use (e.g. between toolbar items).
//
// Usage:
//   Divider {}                                    // horizontal
//   Divider { orientation: "vertical"; height: 24 }

Rectangle {
    id: root
    property string orientation: "horizontal"  // "horizontal" | "vertical"

    width: orientation === "horizontal" ? (parent ? parent.width : 200) : 1
    height: orientation === "vertical" ? (parent ? parent.height : 24) : 1
    color: ThemeManager.borderDefault
}
