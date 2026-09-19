import QtQuick
import GeruBlocks

// KeyValue — Step 11 Data Display ("Key-value (description list)" in
// the spec's component list)
//
// Simple label/value row pairs (e.g. a details panel: "Owner: Priya
// Nair", "Created: 06/08/2026"). Takes a plain model array, same
// reasoning as Timeline — this is display-only data, not a place for
// arbitrary child content the way Form/Accordion need.
//
// TYPEFACE (Phase 3 typography backlog, lever 3): the `key` label
// switches to IBM Plex Sans, mirroring Timeline's timestamp treatment —
// both are metadata-style labels rather than main content. `value`
// stays Poppins. Interpretation flagged, not an explicit line-by-line
// spec call.
//
// Usage:
//   KeyValue {
//       items: [
//           { key: "Owner", value: "Priya Nair" },
//           { key: "Created", value: "06/08/2026" },
//           { key: "Status", value: "Active" }
//       ]
//   }

Column {
    id: root
    property var items: []  // [{ key, value }]
    property int keyWidth: 120
    spacing: ThemeManager.spacing8

    Repeater {
        model: root.items

        Row {
            width: root.width
            spacing: ThemeManager.spacing12

            AppText {
                width: root.keyWidth
                text: modelData.key
                color: ThemeManager.textSecondary
                font.family: "IBM Plex Sans"
            }
            AppText {
                width: parent.width - root.keyWidth - parent.spacing
                text: modelData.value
                color: ThemeManager.textPrimary
                wrapMode: Text.WordWrap
            }
        }
    }
}
