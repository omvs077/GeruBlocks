import QtQuick
import GeruBlocks

// Link — Step 2 Typography & Core Primitives
//
// Interactive inline text link. Uses accent.primary per spec Section 3.1
// ("Primary actions, links, active states").
//
// ASSUMPTION FLAGGED, NOT LOCKED: the spec defines accent.primary /
// accent.primary-pressed color tokens and the system-wide motion timing
// (Section 3.6), but doesn't specify exact link interaction states
// (underline-on-hover vs. always-underlined, exact pressed treatment).
// This implements a common, conservative pattern — color shifts to
// accent.primary-pressed on press, underline appears on hover only —
// using the system's actual locked timing/easing tokens rather than
// inventing new ones. Flag for sign-off if a different treatment is
// wanted; this is a proposal, not a transcription of a spec rule.
//
// The hand/link cursor is the ONE deliberate rounded-corner exception in
// the whole system (Section 3.4) — using Qt's native PointingHandCursor
// here automatically satisfies that, since it's the OS's own cursor
// glyph, not something this component draws.
//
// Usage:
//   Link { text: "View details"; onClicked: /* navigate */ }

Text {
    id: root

    signal clicked()

    font.family: "Poppins"
    font.pixelSize: 14  // matches Base — links inherit body-text scale
    color: mouseArea.pressed ? ThemeManager.accentPrimaryPressed : ThemeManager.accentPrimary
    font.underline: mouseArea.containsMouse

    Behavior on color {
        ColorAnimation {
            duration: ThemeManager.durationMicro  // 100ms, "Button hover/press" per Section 3.6
            easing.type: Easing.BezierSpline
            easing.bezierCurve: ThemeManager.easingCurve  // the one system-wide "confident glide" curve
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
