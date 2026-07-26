import QtQuick
import GeruBlocks

// Keycap — Step 3 Inputs & Data
//
// Single-key chip for displaying keyboard shortcuts (Section 7.4:
// "shortcut keys shown as sharp-cornered 'keycap' chips"). Represents
// ONE key — combos (e.g. "Ctrl+K") are composed by placing multiple
// Keycap components in a Row with a separator, not built into this
// component itself, since the spec's own wording ("chips," plural)
// implies per-key chips rather than a single combo component.
//
// Deliberately neutral/quiet coloring (border-strong outline, secondary
// text) rather than accent-colored — this is UI chrome showing what key
// to press, not an interactive element or a status indicator, so it
// shouldn't visually compete with real accent/status color meanings
// (Governance Principle 4: color is functional, not decorative).
//
// Usage:
//   Row {
//       spacing: 4
//       Keycap { text: "Ctrl" }
//       AppText { text: "+"; variant: "caption" }
//       Keycap { text: "K" }
//   }

Rectangle {
    id: root

    property string text: ""

    radius: 0  // sharp corners, no exceptions
    implicitWidth: label.implicitWidth + ThemeManager.spacing12
    implicitHeight: 22
    color: ThemeManager.backgroundSurface
    border.width: 1
    border.color: ThemeManager.borderStrong

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        font.family: "Poppins Medium"
        font.pixelSize: 12
        color: ThemeManager.textSecondary
    }
}
