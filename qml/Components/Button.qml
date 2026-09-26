import QtQuick
import QtQuick.Controls.Basic as Basic
import GeruBlocks

// Button — Step 2 Typography & Core Primitives
//
// Extends QtQuick.Controls.Basic's Button (not a bare Item+MouseArea)
// specifically to keep native keyboard focus/activation and accessible
// role semantics — Qt's accessibility API integration was an explicit,
// stated reason this whole platform was chosen (spec Section 12), so a
// from-scratch reimplementation would quietly throw that away for the
// first real interactive control. Only `background` and `contentItem`
// are overridden; all QQC2 interaction plumbing (hover/press/enabled/
// focus) stays intact.
//
// State recipe is transcribed from spec Section 3.6 exactly:
//   rest    = solid fill
//   hover   = same fill + ~12% overlay (no geometric scale change)
//   pressed = same fill + ~20% overlay + scale down to 0.97
//   no ripple (explicitly rejected in the spec as unprofessional)
//
// ASSUMPTION FLAGGED, NOT LOCKED: the spec only describes this recipe in
// terms of a single solid-fill button. Variant scope (primary/secondary/
// ghost) and how the overlay/border/text logic adapts to non-solid
// variants, plus the disabled treatment, are this component's own
// proposal built from the locked color tokens — not a transcription of
// an explicit spec rule for those cases. Also: "hover = ...subtle scale
// via ~12% overlay" is read here as the overlay itself being the subtle
// effect, not a geometric scale on hover — only "pressed" gets an actual
// scale transform (0.97), matching the parallel sentence structure where
// pressed explicitly says "+ scale-down to 0.97" as a separate clause.
//
// FOCUS RING, ADDED (backlog Phase 2 item, previously entirely missing):
// Section 8 requires "visible 2px accent-colored outline with 3px offset
// on every interactive element for keyboard navigation." ThemeManager
// already exposed focusRingColor/focusRingWidth/focusRingOffset for
// exactly this purpose — they were just never consumed anywhere. Uses
// QQC2 Control's built-in `visualFocus` property rather than plain
// `activeFocus`: visualFocus is true only when the control has focus AND
// the current input context calls for a visible indicator (keyboard /
// gamepad navigation) — it's deliberately false after an ordinary mouse
// click, which is exactly the "for keyboard navigation" scoping Section 8
// asks for, not "show a ring on every focus event regardless of cause."
// Fade-in/out uses durationMicro (100ms, same bucket as button hover/
// press) and is gated by ThemeManager.reducedMotion, matching the
// gating convention already used elsewhere in this project (e.g.
// StatTile's count-up Behavior) rather than leaving it ungated.
//
// Usage:
//   Button { text: "Save"; variant: "primary"; onClicked: ... }
//   Button { text: "Cancel"; variant: "secondary" }
//   Button { text: "Skip"; variant: "ghost" }
//   Button { text: "Disabled"; enabled: false }

Basic.Button {
    id: root

    // "primary" | "secondary" | "ghost"
    property string variant: "primary"

    hoverEnabled: true
    implicitHeight: ThemeManager.controlHeight
    implicitWidth: contentItem.implicitWidth + ThemeManager.spacing16 * 2

    readonly property color _fillColor: {
        if (variant !== "primary") return "transparent"
        return enabled ? ThemeManager.accentPrimary : ThemeManager.borderStrong
    }

    readonly property color _borderColor: {
        if (variant !== "secondary") return "transparent"
        return enabled ? ThemeManager.accentPrimary : ThemeManager.borderStrong
    }

    readonly property color _textColor: {
        if (!enabled) return ThemeManager.textSecondary
        if (variant === "primary") return "#FFFFFF"
        return ThemeManager.accentPrimary
    }

    // Overlay: white lightens on hover, black darkens further on press —
    // the spec says "white/black overlay" without disambiguating which
    // applies when; this is the common convention for a solid mid-tone
    // fill and is what's implemented here.
    readonly property color _overlayColor: root.pressed ? "#000000" : "#FFFFFF"
    readonly property real _overlayOpacity: {
        if (!enabled) return 0
        if (root.pressed) return 0.20
        if (root.hovered) return 0.12
        return 0
    }

    scale: enabled && root.pressed ? 0.97 : 1.0
    Behavior on scale {
        NumberAnimation {
            duration: ThemeManager.durationMicro
            easing.type: Easing.BezierSpline
            easing.bezierCurve: ThemeManager.easingCurve
        }
    }

    background: Rectangle {
        radius: 0  // sharp corners, system-wide, no exceptions for buttons
        color: root._fillColor
        border.width: root._borderColor !== "transparent" ? ThemeManager.borderWidthDefault : 0
        border.color: root._borderColor

        // Secondary/ghost don't have a solid fill to overlay onto, so the
        // hover/press feedback for those variants is a light accent-tinted
        // wash instead of the white/black overlay used on primary's solid
        // fill — same opacity curve, different color source, since
        // "lightening/darkening nothing" (transparent) has no visible effect.
        Rectangle {
            anchors.fill: parent
            radius: 0
            color: root.variant === "primary" ? root._overlayColor : ThemeManager.accentPrimary
            opacity: root._overlayOpacity
            Behavior on opacity {
                NumberAnimation {
                    duration: ThemeManager.durationMicro
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: ThemeManager.easingCurve
                }
            }
        }

        // --- Focus ring (Section 8: 2px accent outline, 3px offset) ---
        // Sits outside the button's own bounds via negative margins of
        // (offset + width) on all sides, so the ring's *inner* edge is
        // `focusRingOffset` px clear of the button border, and the ring
        // itself is `focusRingWidth` px thick — matching standard
        // outline-offset semantics rather than an outline drawn flush
        // against the edge. radius: 0 to stay consistent with the
        // system-wide sharp-corner rule (Section 3.4) even though this
        // is decorative chrome, not a content surface.
        Rectangle {
            id: focusRing
            anchors.fill: parent
            anchors.margins: -(ThemeManager.focusRingOffset + ThemeManager.focusRingWidth)
            radius: 0
            color: "transparent"
            border.width: ThemeManager.focusRingWidth
            border.color: ThemeManager.focusRingColor
            visible: opacity > 0
            opacity: root.visualFocus ? 1.0 : 0.0

            Behavior on opacity {
                enabled: !ThemeManager.reducedMotion
                NumberAnimation {
                    duration: ThemeManager.durationMicro
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: ThemeManager.easingCurve
                }
            }
        }
    }

    contentItem: Text {
        text: root.text
        font.family: "Poppins Medium"
        font.pixelSize: 14
        color: root._textColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
