import QtQuick
import GeruBlocks

// Timeline — Step 11 Data Display
//
// Vertical sequence of events: circle=node (Warli grammar — same
// deliberate thematic fit as Stepper.qml) + connecting line +
// timestamp + title + optional body. Takes a plain model array rather
// than children, since the connector-line math needs uniform control
// over spacing between entries, the same reasoning as Stepper.qml's
// header/content split.
//
// TYPEFACE (Phase 3 typography backlog, lever 3): the `time` field
// switches to IBM Plex Sans — the clearest literal match for the
// backlog's "timestamps/metadata" wording. `title`/`body` stay Poppins,
// read here as main content rather than metadata. Interpretation
// flagged, not an explicit line-by-line spec call.
//
// Usage:
//   Timeline {
//       items: [
//           { time: "09:17 AM", title: "Project created", body: "by Priya Nair" },
//           { time: "10:30 AM", title: "First task added" },
//           { time: "02:48 PM", title: "Status changed to Active", current: true }
//       ]
//   }

Column {
    id: root
    property var items: []  // [{ time, title, body?, current? }]
    spacing: 0

    Repeater {
        model: root.items

        Item {
            id: entryItem
            width: root.width
            height: bodyText.visible ? 72 : 48

            readonly property bool isLast: index === root.items.length - 1

            Rectangle {
                id: node
                x: 0
                y: 4
                width: 12
                height: 12
                radius: 6
                color: modelData.current === true ? ThemeManager.accentPrimary : ThemeManager.backgroundSurface
                border.width: 2
                border.color: modelData.current === true ? ThemeManager.accentPrimary : ThemeManager.borderStrong
            }

            Rectangle {
                visible: !entryItem.isLast
                x: node.x + node.width / 2 - 1
                y: node.y + node.height
                width: 2
                height: entryItem.height - node.height - node.y
                color: ThemeManager.borderDefault
            }

            Column {
                anchors.left: node.right
                anchors.leftMargin: ThemeManager.spacing12
                anchors.top: parent.top
                width: parent.width - node.width - ThemeManager.spacing12
                spacing: 2

                AppText {
                    text: modelData.time
                    variant: "caption"
                    color: ThemeManager.textSecondary
                    font.family: "IBM Plex Sans"
                }
                AppText { text: modelData.title; color: ThemeManager.textPrimary }
                AppText {
                    id: bodyText
                    text: modelData.body !== undefined ? modelData.body : ""
                    variant: "caption"
                    color: ThemeManager.textSecondary
                    visible: text !== ""
                }
            }
        }
    }
}
