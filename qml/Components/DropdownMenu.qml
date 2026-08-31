import QtQuick
import QtQuick.Controls.Basic as Basic
import GeruBlocks

// DropdownMenu — Step 7 Actions & Menus
//
// Reusable action-list popup, anchored under any trigger item via
// `anchorItem`. Distinct from Select.qml: Select picks a VALUE and
// echoes it back into a trigger field; DropdownMenu items each carry
// their own `onTriggered` callback and there's no retained "current
// selection" — it behaves like an actual menu, not a form control.
//
// POSITIONING PATTERN MATCHES Select.qml/AppCombobox.qml EXACTLY
// (parent = trigger, y = trigger.height) rather than reparenting to a
// window overlay — that proven pattern already works correctly in this
// project; a custom repositioning scheme would be new, untested surface
// for no real benefit here.
//
// Reused directly by SplitButton.qml below. Intended as the shared base
// Context Menu and Menu Bar can build on when those are built
// one-at-a-time next, rather than each reimplementing its own popup
// from scratch.
//
// GAP FLAGGED, NOT FIXED: does not yet do DatePicker/TimePicker's smart
// above/below repositioning (measuring available window space) — always
// opens below its anchor. DatePicker started the same way before that
// fix was added; revisit only if this actually runs off-screen in
// practice, same as the standing note already on Select/AppCombobox.
//
// Usage:
//   IconButton { id: trigger; iconName: "settings"; onClicked: menu.open() }
//   DropdownMenu {
//       id: menu
//       anchorItem: trigger
//       items: [
//           { label: "Rename", onTriggered: function() { ... } },
//           { label: "Delete", iconName: "close", onTriggered: function() { ... } }
//       ]
//   }

Basic.Popup {
    id: root

    property Item anchorItem: null
    // [{ label, iconName?, disabled?, onTriggered }]
    property var items: []

    parent: anchorItem
    y: anchorItem ? anchorItem.height : 0
    x: 0
    width: anchorItem ? Math.max(200, anchorItem.width) : 200
    padding: 0
    implicitHeight: Math.min(listView.contentHeight, 280)

    background: Rectangle {
        radius: 0
        border.width: 1
        border.color: ThemeManager.borderDefault
        color: ThemeManager.backgroundSurface
    }

    contentItem: ListView {
        id: listView
        clip: true
        implicitHeight: contentHeight
        model: root.items

        delegate: Basic.ItemDelegate {
            id: delegateRoot
            width: listView.width
            height: ThemeManager.rowHeight
            enabled: modelData.disabled !== true

            background: Rectangle {
                color: delegateRoot.hovered ? ThemeManager.backgroundPage : "transparent"
            }

            contentItem: Row {
                spacing: ThemeManager.spacing8
                leftPadding: ThemeManager.spacing12

                Icon {
                    visible: modelData.iconName !== undefined && modelData.iconName !== ""
                    name: modelData.iconName !== undefined ? modelData.iconName : ""
                    size: 16
                    color: delegateRoot.enabled ? ThemeManager.textPrimary : ThemeManager.textSecondary
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: modelData.label
                    font.family: "Poppins"
                    font.pixelSize: 14
                    color: delegateRoot.enabled ? ThemeManager.textPrimary : ThemeManager.textSecondary
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            onClicked: {
                root.close()
                if (modelData.onTriggered) modelData.onTriggered()
            }
        }
    }
}
