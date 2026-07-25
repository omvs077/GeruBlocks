import QtQuick
import GeruBlocks

// AppText — Step 2 Typography & Core Primitives
//
// Covers the five body-scale rows of the type ramp (spec Section 3.2):
//   Title    16px / 500 / card & dialog titles
//   Subtitle 14px / 500 / secondary headings
//   Base     14px / 400 / default UI text
//   Caption  12px / 400 / metadata, timestamps, helper text
//   Body     13px / 400 / longer-form text, descriptions
//
// Same font-weight-string convention as Heading — see that file's note.
//
// ASSUMPTION FLAGGED, NOT LOCKED: the spec's type ramp table (3.2) only
// defines size/weight/use per row, not color. Defaulting "caption" to
// textSecondary (muted) and everything else to textPrimary is a common,
// sensible convention (metadata/timestamps are usually visually
// de-emphasized) but it's a proposal, not something the spec states
// explicitly — override via the `color` property if this isn't right.
//
// SCOPE NOTE: tabular-nums (Section 3.2's "Data-density fix") is
// deliberately NOT applied here. The spec scopes that to "table and
// metric-text components" specifically, not general body text — that
// belongs to DataTable / a future metric-text variant in Step 3, not
// this general-purpose component.
//
// Usage:
//   Text { text: "Card title"; variant: "title" }
//   Text { text: "Default text" }                      // defaults to "base"
//   Text { text: "Last updated 2 min ago"; variant: "caption" }

Text {
    id: root

    // "title" | "subtitle" | "base" | "caption" | "body"
    property string variant: "base"

    readonly property var _styles: ({
        "title":    { size: 16, family: "Poppins Medium" },
        "subtitle": { size: 14, family: "Poppins Medium" },
        "base":     { size: 14, family: "Poppins" },
        "caption":  { size: 12, family: "Poppins" },
        "body":     { size: 13, family: "Poppins" }
    })

    readonly property var _style: _styles[variant] !== undefined ? _styles[variant] : _styles["base"]

    font.family: _style.family
    font.pixelSize: _style.size
    color: variant === "caption" ? ThemeManager.textSecondary : ThemeManager.textPrimary
}
