import QtQuick
import QtQuick.Controls.Basic as Basic
import GeruBlocks

// Popover — Step 9 Transient Overlays
//
// Generic anchored panel for ARBITRARY CONTENT (a small form, a color
// picker, a details card) — distinct from DropdownMenu.qml, which is
// specifically an action-item list. Uses the same thin-wrapper default-
// content pattern as Form.qml/Accordion.qml (place any children, no
// fixed schema) rather than a `items` array, since popover content is
// by nature not list-shaped.
//
// MATERIAL: solid, matching the already-established precedent from
// DropdownMenu/ContextMenu (Step 7) and Dialog/CommandPalette (Step 4)
// — see this batch's top-level note on why glass wasn't introduced here
// despite the spec listing "flyouts" as glass-eligible.
//
// Positioning matches Select.qml/DropdownMenu.qml exactly (parent =
// trigger, y = trigger.height) — same proven pattern, not new surface.
//
// Usage:
//   IconButton { id: trigger; iconName: "settings"; onClicked: popover.open() }
//   Popover {
//       id: popover
//       anchorItem: trigger
//       AppText { text: "Quick settings"; variant: "subtitle" }
//       AppSwitch { text: "Dark mode" }
//   }

Basic.Popup {
    id: root

    default property alias content: contentColumn.children
    property Item anchorItem: null
    property real panelWidth: 260

    parent: anchorItem
    y: anchorItem ? anchorItem.height + ThemeManager.spacing4 : 0
    x: 0
    width: panelWidth
    padding: ThemeManager.spacing16
    implicitHeight: contentColumn.implicitHeight + ThemeManager.spacing16 * 2
    closePolicy: Basic.Popup.CloseOnEscape | Basic.Popup.CloseOnPressOutside

    background: Rectangle {
        radius: 0
        color: ThemeManager.backgroundSurface
        border.width: 1
        border.color: ThemeManager.borderDefault
    }

    contentItem: Column {
        id: contentColumn
        width: root.panelWidth - ThemeManager.spacing16 * 2
        spacing: ThemeManager.spacing12
    }
}
