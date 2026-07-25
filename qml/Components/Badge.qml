import QtQuick
import GeruBlocks

// Badge — Step 2 Typography & Core Primitives
//
// CRITICAL CONSTRAINT FROM SPEC (Section 3.1 contrast guardrail):
// "#F26327 (accent orange) fails WCAG AA for text on light backgrounds.
// It is enforced as fill-with-dark-text, border, or dot only — never as
// text color directly. This must be built into the Badge/Tag component
// API so it cannot be misused."
//
// This component makes that structurally true: there is no code path
// anywhere in here that sets a label's color to the variant's own accent
// color. Labels are always textPrimary (fill mode uses a fixed on-fill
// color chosen per variant, not theme-bound — see below); the accent
// color only ever appears as a fill background, a border, or the dot.
//
// EXTENDED TO success/error TOO, NOT JUST orange (my own extension, not
// explicitly spec'd for those two): I checked the actual contrast math
// before assuming success/error were safe as text, and they aren't
// either — statusSuccess and statusError both only clear the spec's own
// 3:1 "large text" threshold on white, not the 4.5:1 body-text threshold
// a 12px badge label actually needs. Applying the same never-as-text-
// color rule to all three status colors for consistency, not just the
// one the spec named.
//
// FILL-MODE TEXT COLOR IS A FIXED CONSTANT PER VARIANT, NOT THEME-BOUND:
// a badge's fill sits on a small saturated color swatch, not the page
// background, so ThemeManager.textPrimary (which flips navy/near-white
// between themes) isn't the right binding — it could make contrast worse
// in one theme. Each variant's fill-text color below was chosen from
// actually measured contrast ratios against that exact fill color:
//   primary (accentPrimary #1A5FD7) + white text  = 5.73:1 (passes 4.5)
//   error   (#D64545)              + white text  = 4.38:1 (marginal)
//   success (#2E9B57)              + navy text   = 3.65:1 (marginal)
//   urgent  (#F26327, orange)      + navy text   = 4.04:1 (marginal —
//     this is the spec's own explicitly sanctioned "fill-with-dark-text"
//     pattern for orange; flagging the measured number rather than
//     claiming a clean pass it doesn't quite reach)
// None of the three status colors have a text color that cleanly clears
// 4.5:1 at small size on their own fill — that's a genuine constraint of
// using saturated color as a small-badge fill, not something more
// clever color math can fix. "outline" and "dot" styles avoid the
// problem entirely by keeping text on the theme's normal page/surface
// background instead, which is why those are the safer default choice
// for anything that needs to stay readable.
//
// Usage:
//   Badge { text: "Beta"; variant: "neutral" }
//   Badge { text: "Online"; variant: "success"; style: "outline" }
//   Badge { text: "Urgent"; variant: "urgent"; style: "fill" }
//   Badge { variant: "error"; style: "dot" }   // no text, just a status dot

Item {
    id: root

    // "neutral" | "primary" | "success" | "error" | "urgent"
    property string variant: "neutral"
    // "fill" | "outline" | "dot"
    property string style: "outline"
    property string text: ""

    readonly property color _accentColor: {
        switch (variant) {
            case "primary": return ThemeManager.accentPrimary
            case "success": return ThemeManager.statusSuccess
            case "error":   return ThemeManager.statusError
            case "urgent":  return ThemeManager.accentSecondary
            default:        return ThemeManager.borderStrong
        }
    }

    // Fixed per-variant fill-text colors — see header note. Neutral fill
    // is a light tint, not saturated, so it safely uses normal textPrimary.
    readonly property color _fillTextColor: {
        switch (variant) {
            case "primary": return "#FFFFFF"
            case "error":   return "#FFFFFF"
            case "success": return "#2D3142"
            case "urgent":  return "#2D3142"
            default:        return ThemeManager.textPrimary
        }
    }

    implicitWidth: style === "dot" ? 8 : label.implicitWidth + ThemeManager.spacing12 * 2
    implicitHeight: style === "dot" ? 8 : 20

    Rectangle {
        anchors.fill: parent
        radius: root.style === "dot" ? width / 2 : 0  // dot is the one
            // sanctioned circle exception (icon grammar: "circle = node,
            // status dot" — this isn't a rounded-corner violation of the
            // sharp-corners rule, it's the same circle-primitive exception
            // used throughout icons, applied to a UI dot indicator)

        color: {
            if (root.style === "fill") return root._accentColor
            if (root.style === "dot") return root._accentColor
            return "transparent"  // outline
        }
        border.width: root.style === "outline" ? ThemeManager.borderWidthDefault : 0
        border.color: root._accentColor
    }

    Text {
        id: label
        anchors.centerIn: parent
        visible: root.style !== "dot"
        text: root.text
        font.family: "Poppins Medium"
        font.pixelSize: 12
        // Never the variant's own accent color — fixed fill-text color
        // on fill mode, normal theme textPrimary on outline mode (safe,
        // since outline's background is the page/surface, not a
        // saturated fill).
        color: root.style === "fill" ? root._fillTextColor : ThemeManager.textPrimary
    }
}
