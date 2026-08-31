import QtQuick
import QtQuick.Controls.Basic as Basic
import GeruBlocks

// ContextMenu — Step 7 Actions & Menus (built one-at-a-time, not batched)
//
// Right-click-triggered action menu, positioned at the cursor rather
// than anchored under a fixed trigger item — the reason this is a
// separate component from DropdownMenu.qml rather than a variant of it,
// even though the item-list rendering below is deliberately styled to
// match it exactly (same delegate shape, same icon/label row).
//
// TWO TRIGGER MODES, BOTH SUPPORTED (explicit choice, not spec-stated):
//   1. AUTO: set `attachedTo` and right-click anywhere on that item
//      opens the menu automatically.
//   2. MANUAL: call openAt(x, y, relativeTo) yourself from your own
//      MouseArea's onClicked — needed when the target already has its
//      own left-click handling and you want full control rather than
//      layering another MouseArea on top of it.
//
// AUTO-WIRING RISK, FLAGGED EXPLICITLY: mode 1 works by overlaying a
// MouseArea on `attachedTo` with acceptedButtons: Qt.RightButton only.
// QtQuick's standard behavior is that a button not in acceptedButtons
// is left unaccepted and falls through to whatever's underneath, so
// left-click on the same item should keep working untouched — but this
// project already hit one real z-order/input bug before (AppShell,
// Step 4), so treat this as the part of ContextMenu most worth
// confirming visually: right-click opens the menu AND left-click on
// the same item still does whatever it did before.
//
// Usage (auto):
//   Card {
//       id: myCard
//       ContextMenu {
//           attachedTo: myCard
//           items: [
//               { label: "Rename", onTriggered: function() { ... } },
//               { label: "Delete", onTriggered: function() { ... } }
//           ]
//       }
//   }
//
// Usage (manual):
//   MouseArea {
//       id: area
//       anchors.fill: someItem
//       acceptedButtons: Qt.LeftButton | Qt.RightButton
//       onClicked: (mouse) => {
//           if (mouse.button === Qt.RightButton) {
//               contextMenu.openAt(mouse.x, mouse.y, area)
//           } else {
//               // your normal left-click handling
//           }
//       }
//   }
//   ContextMenu { id: contextMenu; items: [...] }

Basic.Popup {
    id: root

    property Item attachedTo: null
    // [{ label, iconName?, disabled?, onTriggered }]
    property var items: []

    padding: 0
    width: 200
    implicitHeight: Math.min(listView.contentHeight, 280)
    closePolicy: Basic.Popup.CloseOnEscape | Basic.Popup.CloseOnPressOutside

    // Opens at (x, y), interpreted relative to `relativeTo`'s own
    // coordinate space (i.e. pass mouse.x/mouse.y straight from that
    // item's MouseArea). Falls back to attachedTo if relativeTo is
    // omitted, for the auto-wired case below.
    function openAt(x, y, relativeTo) {
        root.parent = relativeTo || root.attachedTo
        root.x = x
        root.y = y
        root.open()
    }

    Component.onCompleted: {
        if (root.attachedTo) {
            rightClickOverlay.createObject(root.attachedTo)
        }
    }

    Component {
        id: rightClickOverlay
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onClicked: (mouse) => root.openAt(mouse.x, mouse.y, root.attachedTo)
        }
    }

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
