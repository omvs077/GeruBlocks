import QtQuick
import GeruBlocks

// Skeleton — Step 3 Inputs & Data
//
// Loading-state placeholder. Pulses gently between two opacity levels
// to signal "content not loaded yet" without implying an error or a
// blocking spinner.
//
// FLAGGED: this doesn't map to any of the 3 defined hover behaviors or
// the panel/dialog transition (Governance Principle 3's explicit "must
// map to one of these, nothing freeform" rule) — because it isn't
// interaction motion at all, it's ambient loading feedback, a different
// category the governance rule doesn't seem to have been written with
// in mind. Treating it as its own reasonable exception rather than
// force-fitting it into hover language it doesn't belong to, but this
// is my judgment call, not something the spec states.
//
// The pulse duration is ALSO not on the existing scale — every duration
// token tops out at 320ms (panel settle), and a skeleton pulse needs to
// be much slower than that or it reads as anxious flickering rather than
// a calm "still loading" cue. Proposing ~900ms per half-cycle here as a
// new value, not something already covered by the token scale.
//
// Usage:
//   Skeleton { width: 200; height: 16 }                    // text-line placeholder
//   Skeleton { variant: "block"; width: 200; height: 120 }  // arbitrary block

Rectangle {
    id: root

    // "text" (thin, fixed height matching a line of body text) | "block" (arbitrary size)
    property string variant: "text"

    radius: 0  // sharp corners, no exceptions
    width: 160
    height: variant === "text" ? 14 : 80
    color: ThemeManager.borderDefault

    SequentialAnimation on opacity {
        loops: Animation.Infinite
        NumberAnimation {
            from: 0.5; to: 1.0
            duration: 900  // flagged above — new value, not on the existing duration scale
            easing.type: Easing.BezierSpline
            easing.bezierCurve: ThemeManager.easingCurve
        }
        NumberAnimation {
            from: 1.0; to: 0.5
            duration: 900
            easing.type: Easing.BezierSpline
            easing.bezierCurve: ThemeManager.easingCurve
        }
    }
}
