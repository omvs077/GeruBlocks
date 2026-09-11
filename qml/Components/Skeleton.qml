import QtQuick
import GeruBlocks

// Skeleton — Step 3 Inputs & Data
//
// Loading-state placeholder.
//
// MOTION (Phase 2 backlog): replaced the previous whole-shape opacity
// pulse with an actual light-sweep — a soft gradient band animating
// left-to-right across the placeholder, looping. The backlog describes
// this component as having "no shimmer/pulse specified... reads as a
// static gray block" — worth flagging that the file actually already
// had a pulse before this change; the backlog specifically asks for a
// SWEEP though ("a slow, subtle light-sweep looping while loading"),
// which is a different effect, so the pulse is being superseded here
// rather than kept alongside it.
//
// Root changed from Rectangle to Item (needed to layer a clipped
// overlay band on top of the base fill) — this doesn't affect external
// usage since only width/height/variant were ever set from outside.
//
// FIRST USE IN THIS PROJECT of a horizontal Gradient on a Rectangle fill
// (Gradient.Horizontal orientation) — not yet screenshot-confirmed on
// real hardware, unlike the border-reveal/reveal-glow/3D-tilt hover
// patterns which are all already proven working elsewhere.
//
// Sweep duration (1400ms) + pause (400ms) are NEW values, same as the
// original pulse's 900ms was — not on the existing duration scale
// (which tops out at 320ms for panel settle). A loading cue needs a
// much slower cadence than any interaction-motion token or it reads as
// anxious flickering rather than a calm "still loading" signal.
//
// REDUCED MOTION: sweep animation simply doesn't run (frozen off-screen)
// when ThemeManager.reducedMotion is set — the static base-color block
// alone communicates "placeholder" without any transform, per Section 8.
//
// Usage:
//   Skeleton { width: 200; height: 16 }                    // text-line placeholder
//   Skeleton { variant: "block"; width: 200; height: 120 }  // arbitrary block

Item {
    id: root

    // "text" (thin, fixed height matching a line of body text) | "block" (arbitrary size)
    property string variant: "text"

    width: 160
    height: variant === "text" ? 14 : 80
    clip: true

    Rectangle {
        anchors.fill: parent
        radius: 0  // sharp corners, no exceptions
        color: ThemeManager.borderDefault
    }

    Rectangle {
        id: shimmerBand
        width: root.width * 0.6
        height: root.height
        x: -width
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0) }
            GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, ThemeManager.isDark ? 0.08 : 0.35) }
            GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0) }
        }

        SequentialAnimation {
            running: !ThemeManager.reducedMotion
            loops: Animation.Infinite

            NumberAnimation {
                target: shimmerBand
                property: "x"
                from: -shimmerBand.width
                to: root.width
                duration: 1400
                easing.type: Easing.Linear
            }
            PauseAnimation { duration: 400 }
        }
    }
}
