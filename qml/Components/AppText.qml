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
// LETTER-SPACING (Phase 3 typography backlog, lever 2): +0.4px tracking
// on "caption" specifically — verified safe against Badge/RemovableTag
// (see commit history for the full verification).
//
// MULTI-SCRIPT (backlog Section 3, deeper-integration option, signed
// off): `scriptCode` (ISO 639-1, e.g. "bn", "te", "ta"...) makes this
// component call LocalizationUtil.fontFamilyForScript() instead of the
// hardcoded Poppins family — defaults to "" (empty), which falls
// straight through to the original Poppins logic unchanged, so every
// existing usage across the app is unaffected. WEIGHT MAPPING FLAGGED:
// Anek only has 3 instanced weights (Regular/Medium/SemiBold) versus
// Poppins' full range, so "title"/"subtitle" map to "medium" and
// "base"/"caption"/"body" map to "regular" — a reasonable compression,
// not a spec-stated rule. If scriptCode is set but unrecognized (or
// LocalizationUtil returns empty for any reason), silently falls back
// to the normal Poppins family rather than breaking.
//
// Usage:
//   Text { text: "Card title"; variant: "title" }
//   Text { text: "Default text" }                      // defaults to "base"
//   Text { text: "Last updated 2 min ago"; variant: "caption" }
//   Text { text: "লেখা"; scriptCode: "bn" }              // NEW — Bangla via Anek

Text {
    id: root

    // "title" | "subtitle" | "base" | "caption" | "body"
    property string variant: "base"

    // ISO 639-1 script code ("bn", "te", "ta", "gu", "kn", "or", "ml", "pa")
    // or "" (default) for the normal Poppins path. See header note.
    property string scriptCode: ""

    readonly property var _styles: ({
        "title":    { size: 16, family: "Poppins Medium" },
        "subtitle": { size: 14, family: "Poppins Medium" },
        "base":     { size: 14, family: "Poppins" },
        "caption":  { size: 12, family: "Poppins" },
        "body":     { size: 13, family: "Poppins" }
    })

    readonly property var _style: _styles[variant] !== undefined ? _styles[variant] : _styles["base"]

    readonly property var _scriptWeightForVariant: ({
        "title": "medium",
        "subtitle": "medium",
        "base": "regular",
        "caption": "regular",
        "body": "regular"
    })

    readonly property string _resolvedFamily: {
        if (root.scriptCode !== "") {
            var weight = _scriptWeightForVariant[variant] !== undefined ? _scriptWeightForVariant[variant] : "regular"
            var scriptFamily = LocalizationUtil.fontFamilyForScript(root.scriptCode, weight)
            if (scriptFamily !== "") return scriptFamily
        }
        return _style.family
    }

    font.family: _resolvedFamily
    font.pixelSize: _style.size
    font.letterSpacing: variant === "caption" ? 0.4 : 0
    color: variant === "caption" ? ThemeManager.textSecondary : ThemeManager.textPrimary
}
