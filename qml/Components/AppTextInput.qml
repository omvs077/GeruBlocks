import QtQuick
import QtQuick.Controls.Basic as Basic
import GeruBlocks

// AppTextInput — Step 3 Inputs & Data
//
// Extends QtQuick.Controls.Basic's TextField (not built from scratch)
// specifically to keep native text-editing behavior intact — cursor,
// selection, clipboard, and IME composition. Proper complex-script
// (Devanagari) text handling via Qt's text engine was an explicit stated
// reason this platform was chosen over the alternatives (Section 12) —
// reimplementing text editing from raw primitives would quietly regress
// exactly that.
//
// FOCUS RING IS ITS OWN LAYER, NOT THE VALIDATION BORDER: spec Section 8
// requires "a visible 2px accent-colored outline with 3px offset on
// every interactive element for keyboard navigation" — this is a
// distinct requirement from the validation border color (default/error/
// success), so it's implemented as a separate outer outline that only
// appears on keyboard focus, rather than folding focus into the border
// color logic. Otherwise a keyboard user tabbing through an error-state
// field would lose the focus indicator entirely (error red would
// visually stand in for it), which isn't what the spec asks for.
//
// Disabled uses the standard `enabled: false` property (not a 4th
// validationState value) for consistency with how Button.qml already
// handles disabled.
//
// ASSUMPTION FLAGGED, NOT LOCKED: fixed control height (ThemeManager.
// controlHeight, 32px) rather than density-aware height. Density modes
// in the spec (7.3) are specifically about table/list row height: form
// controls like Button already use the fixed control height regardless
// of density, and TextInput follows that same precedent for consistency
// — not something the spec states explicitly for form fields.
//
// Usage:
//   TextInput {
//       label: "Zone Name"
//       placeholderText: "Enter zone name"
//       validationState: "error"
//       errorMessage: "Zone name is required"
//   }

Column {
    id: root

    property string label: ""
    property string helperText: ""
    property string errorMessage: ""
    // "default" | "error" | "success"
    property string validationState: "default"

    property alias text: field.text
    property alias placeholderText: field.placeholderText

    signal editingFinished()

    width: 240
    spacing: ThemeManager.spacing4

    AppText {
        text: root.label
        variant: "caption"
        visible: root.label !== ""
    }

    Item {
        width: parent.width
        height: ThemeManager.controlHeight

        Basic.TextField {
            id: field
            anchors.fill: parent
            enabled: root.enabled
            selectByMouse: true
            font.family: "Poppins"
            font.pixelSize: 14
            color: enabled ? ThemeManager.textPrimary : ThemeManager.textSecondary
            leftPadding: ThemeManager.spacing12
            rightPadding: ThemeManager.spacing12
            onEditingFinished: root.editingFinished()

            background: Rectangle {
                radius: 0
                color: field.enabled ? ThemeManager.backgroundSurface : ThemeManager.borderStrong
                border.width: 1
                border.color: {
                    if (!field.enabled) return ThemeManager.borderStrong
                    if (root.validationState === "error") return ThemeManager.statusError
                    if (root.validationState === "success") return ThemeManager.statusSuccess
                    return ThemeManager.borderDefault
                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: ThemeManager.durationFast
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: ThemeManager.easingCurve
                    }
                }
            }
        }

        // Focus ring — separate layer, spec Section 8 exact values
        // (2px, accent color, 3px offset), independent of validation state.
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            radius: 0
            color: "transparent"
            border.width: 2
            border.color: ThemeManager.focusRingColor
            visible: field.activeFocus
        }
    }

    AppText {
        readonly property string _activeMessage: root.validationState === "error" && root.errorMessage !== ""
                                                    ? root.errorMessage
                                                    : root.helperText
        text: _activeMessage
        variant: "caption"
        color: root.validationState === "error" ? ThemeManager.statusError : ThemeManager.textSecondary
        visible: _activeMessage !== ""
        wrapMode: Text.WordWrap
        width: parent.width
    }
}
