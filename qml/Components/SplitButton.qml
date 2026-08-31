import QtQuick
import GeruBlocks

// SplitButton — Step 7 Actions & Menus
//
// Primary action (click the label = `clicked()`) + a small chevron that
// opens a DropdownMenu of secondary/alternate actions — e.g. "Save"
// with "Save As... / Save a Copy" behind the chevron. Visually merged
// via the same divider technique as ButtonGroup.qml (1px Row spacing
// revealing the wrapping Rectangle's fill as a divider line).
//
// Chevron uses IconButton's `glyph` fallback (▼), not an icon name —
// see IconButton.qml's header note on why (no confirmed chevron_down
// icon exists yet in the 252-icon set).
//
// Usage:
//   SplitButton {
//       text: "Save"
//       variant: "primary"
//       onClicked: saveCurrent()
//       menuItems: [
//           { label: "Save As...", onTriggered: function() { saveAs() } },
//           { label: "Save a Copy", onTriggered: function() { saveCopy() } }
//       ]
//   }

Item {
    id: root

    property string text: ""
    // "primary" | "secondary" | "ghost" — passed straight through to
    // the inner Button/IconButton, same vocabulary as Button.qml
    property string variant: "primary"
    // [{ label, iconName?, disabled?, onTriggered }]
    property var menuItems: []

    signal clicked()

    implicitWidth: mainBtn.implicitWidth + chevronBtn.implicitWidth + 1
    implicitHeight: ThemeManager.controlHeight

    Rectangle {
        anchors.fill: parent
        radius: 0
        color: ThemeManager.borderDefault  // shows through as the 1px divider

        Row {
            anchors.fill: parent
            spacing: 1

            Button {
                id: mainBtn
                text: root.text
                variant: root.variant
                width: parent.width - chevronBtn.width - parent.spacing
                height: parent.height
                onClicked: root.clicked()
            }

            IconButton {
                id: chevronBtn
                glyph: "\u25BC"
                iconSize: 12
                variant: root.variant === "ghost" ? "ghost" : "primary"
                width: ThemeManager.controlHeight
                height: parent.height
                onClicked: dropdown.open()
            }
        }
    }

    DropdownMenu {
        id: dropdown
        anchorItem: chevronBtn
        items: root.menuItems
    }
}
