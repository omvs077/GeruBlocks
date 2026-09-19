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
// TYPEFACE (Phase 3 typography backlog, lever 4): switched from Poppins
// Medium to IBM Plex Mono Medium — the backlog's own "highest-value,
// most visible first use" for the monospace family, on the reasoning
// that a keycap showing a literal key ("Ctrl", "K") reads more like a
// physical/technical label when set in a monospace face, mirroring how
// real keyboards and technical documentation render key names.
// Family-name string verified directly against the actual .ttf's name
// table before use (not guessed from the filename) — see this project's
// established Poppins-weight-string lesson for why that verification
// step matters.
//
// NOT YET VISUALLY CONFIRMED: pixelSize kept at 12 (unchanged) even
// though monospace faces often read slightly larger/wider than a
// proportional face at the same pixel size — worth a real screenshot
// check before assuming 12px is still the right size for optical parity
// with the rest of the UI, rather than adjusting blind here.
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
        font.family: "IBM Plex Mono Medium"
        font.pixelSize: 12
        color: ThemeManager.textSecondary
    }
}
