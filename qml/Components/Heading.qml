import QtQuick
import GeruBlocks

// Heading — Step 2 Typography & Core Primitives
//
// Covers three rows of the type ramp:
//   Header    24px / 600 / page titles (spec Section 3.2)
//   Subheader 20px / 600 / section titles (spec Section 3.2)
//   Display   40px / Light or Black / hero headlines + hero KPI numerals
//             (Phase 3 typography backlog, lever 1)
//
// DISPLAY WEIGHT SELECTION: `weight` ("light" | "black") selects between
// Display's two Poppins weight variants, ignored for header/subheader.
//
// IMPORTANT — font weight convention: font.weight does NOT reliably
// select the right embedded Poppins face. Always use the explicit
// family string.
//
// MULTI-SCRIPT (backlog Section 3, deeper-integration option, signed
// off): `scriptCode` (ISO 639-1) makes this component call
// LocalizationUtil.fontFamilyForScript() instead of the hardcoded
// Poppins family — defaults to "" (empty), falling straight through to
// the original Poppins logic unchanged for every existing usage.
// WEIGHT LIMITATION, FLAGGED: Anek only has 3 instanced weights
// (Regular/Medium/SemiBold) — no Light/Black extremes. So BOTH
// header/subheader AND display map to "semibold" (Anek's heaviest
// available weight) when scriptCode is set. This means a multi-script
// Display headline will NOT get the same dramatic Light-vs-Black
// weight contrast Poppins gets — it's the closest available weight,
// not an equivalent one. Confirm this reads acceptably once actually
// used with real script text, rather than assuming parity with Poppins.
//
// Usage:
//   Heading { text: "Page title" }                                // "header"
//   Heading { text: "Section title"; variant: "subheader" }
//   Heading { text: "Welcome to Geru Blocks"; variant: "display" } // Light, 40px
//   Heading { text: "24"; variant: "display"; weight: "black" }    // Black, 40px
//   Heading { text: "শিরোনাম"; scriptCode: "bn" }                   // NEW — Bangla via Anek

Text {
    id: root

    // "header" | "subheader" | "display"
    property string variant: "header"
    // "light" | "black" — only applies when variant === "display"
    property string weight: "light"

    // ISO 639-1 script code ("bn", "te", "ta", "gu", "kn", "or", "ml", "pa")
    // or "" (default) for the normal Poppins path. See header note on
    // the weight-mapping limitation.
    property string scriptCode: ""

    readonly property var _sizes: ({
        "header": 24,
        "subheader": 20,
        "display": 40
    })

    readonly property string _poppinsFamily: {
        if (variant === "display") return weight === "black" ? "Poppins Black" : "Poppins Light"
        return "Poppins SemiBold"
    }

    readonly property string _resolvedFamily: {
        if (root.scriptCode !== "") {
            var scriptFamily = LocalizationUtil.fontFamilyForScript(root.scriptCode, "semibold")
            if (scriptFamily !== "") return scriptFamily
        }
        return _poppinsFamily
    }

    font.family: _resolvedFamily
    font.pixelSize: _sizes[variant] !== undefined ? _sizes[variant] : _sizes["header"]
    color: ThemeManager.textPrimary

    // Headings commonly need to wrap or elide in constrained layouts;
    // leave wrapMode/elide to the caller rather than forcing a default,
    // since page titles vs. card titles have different truncation needs.
}
