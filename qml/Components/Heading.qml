import QtQuick
import GeruBlocks

// Heading — Step 2 Typography & Core Primitives
//
// Covers the two largest rows of the type ramp (spec Section 3.2):
//   Header    24px / 600 / page titles
//   Subheader 20px / 600 / section titles
//
// Both use the SemiBold weight, so this stays one component with a
// `variant` switch rather than two near-identical files.
//
// IMPORTANT — font weight convention (discovered during Stage 2 font
// testing, not optional): font.weight does NOT reliably select the right
// embedded Poppins face on this project's target platform. Always use
// the explicit family string ("Poppins SemiBold"), never
// font.family: "Poppins" + font.weight: Font.DemiBold.
//
// Usage:
//   Heading { text: "Page title" }                       // defaults to "header"
//   Heading { text: "Section title"; variant: "subheader" }

Text {
    id: root

    // "header" | "subheader"
    property string variant: "header"

    readonly property var _sizes: ({
        "header": 24,
        "subheader": 20
    })

    font.family: "Poppins SemiBold"
    font.pixelSize: _sizes[variant] !== undefined ? _sizes[variant] : _sizes["header"]
    color: ThemeManager.textPrimary

    // Headings commonly need to wrap or elide in constrained layouts;
    // leave wrapMode/elide to the caller rather than forcing a default,
    // since page titles vs. card titles have different truncation needs.
}
