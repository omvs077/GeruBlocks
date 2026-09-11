import QtQuick
import GeruBlocks

// BackgroundMotif — backlog item 1f ("background personality motif")
//
// A single small, faint corner-fan built from the locked Warli grammar,
// arranged using rangoli's PLACEMENT logic (corner/threshold-anchored
// symmetry) — not rangoli's actual dot-mandala imagery, per the
// backlog's explicit scoping. Renders one of four hand-authored
// corner_motif_*.svg assets through the existing Icon.qml masking
// pipeline, so it theme-adapts automatically.
//
// Four corner variants available — `corner` selects the matching asset
// and sets default anchors, both overridable by the caller.
//
// OPACITY: spec's literal "3-6%" (0.05 originally used here) was
// confirmed too faint to read on a real screen against actual content —
// bumped to 0.15. Same category of adjustment as the glass blur needing
// to go past its literal "16px" spec value once tested on-device;
// documented here rather than silently deviating.
//
// Usage:
//   BackgroundMotif { corner: "bottom_right" }   // default
//   BackgroundMotif { corner: "top_left" }

Icon {
    id: root

    // "bottom_right" | "bottom_left" | "top_left" | "top_right"
    property string corner: "bottom_right"

    readonly property var _assetForCorner: ({
        "bottom_right": "corner_motif_right_bottom",
        "bottom_left":  "corner_motif_left_bottom",
        "top_left":     "corner_motif_upper_left",
        "top_right":    "corner_motif_upper_right"
    })

    name: _assetForCorner[corner] !== undefined ? _assetForCorner[corner] : _assetForCorner["bottom_right"]
    size: 100
    color: ThemeManager.textSecondary
    opacity: ThemeManager.backgroundPatternsEnabled ? 0.15 : 0
    visible: ThemeManager.backgroundPatternsEnabled

    anchors.right: (corner === "bottom_right" || corner === "top_right") ? (parent ? parent.right : undefined) : undefined
    anchors.left: (corner === "bottom_left" || corner === "top_left") ? (parent ? parent.left : undefined) : undefined
    anchors.bottom: (corner === "bottom_right" || corner === "bottom_left") ? (parent ? parent.bottom : undefined) : undefined
    anchors.top: (corner === "top_left" || corner === "top_right") ? (parent ? parent.top : undefined) : undefined
}
