import QtQuick
import GeruBlocks

// Heading — Step 2 Typography & Core Primitives
//
// Covers three rows of the type ramp:
//   Header    24px / 600 / page titles (spec Section 3.2)
//   Subheader 20px / 600 / section titles (spec Section 3.2)
//   Display   40px / Light or Black / hero headlines + hero KPI numerals
//             (Phase 3 typography backlog, lever 1 — additive to the
//             original 7-step ramp, nothing in Header/Subheader changes)
//
// DISPLAY WEIGHT SELECTION: unlike Header/Subheader (one fixed weight
// each), Display has TWO weight variants per the backlog's decision:
// "Poppins Light" for hero headlines/onboarding/empty-state text, and
// "Poppins Black" for hero numerals (e.g. StatTile's KPI number).
// `weight` selects between them, ignored for header/subheader. Defaults
// to "light" (the more general Display use case); StatTile explicitly
// opts into weight: "black".
//
// IMPORTANT — font weight convention (unchanged from before): font.weight
// does NOT reliably select the right embedded Poppins face. Always use
// the explicit family string. Poppins Light/Black family-name strings
// verified directly against the actual .ttf name tables before use here.
//
// Usage:
//   Heading { text: "Page title" }                                // "header"
//   Heading { text: "Section title"; variant: "subheader" }
//   Heading { text: "Welcome to Geru Blocks"; variant: "display" } // Light, 40px
//   Heading { text: "24"; variant: "display"; weight: "black" }    // Black, 40px

Text {
    id: root

    // "header" | "subheader" | "display"
    property string variant: "header"
    // "light" | "black" — only applies when variant === "display"
    property string weight: "light"

    readonly property var _sizes: ({
        "header": 24,
        "subheader": 20,
        "display": 40
    })

    readonly property string _family: {
        if (variant === "display") return weight === "black" ? "Poppins Black" : "Poppins Light"
        return "Poppins SemiBold"
    }

    font.family: _family
    font.pixelSize: _sizes[variant] !== undefined ? _sizes[variant] : _sizes["header"]
    color: ThemeManager.textPrimary

    // Headings commonly need to wrap or elide in constrained layouts;
    // leave wrapMode/elide to the caller rather than forcing a default,
    // since page titles vs. card titles have different truncation needs.
}
