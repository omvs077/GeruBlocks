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
// STEP 6 FOLLOW-UP — validation metadata + password mode:
//   AppTextInput stays a "dumb" field. It does NOT validate itself.
//   validationType / minLength / maxLength / validator are just metadata
//   that Form.qml reads and acts on — consistent with the thin-wrapper
//   design where Form owns all validation logic.
//     validationType: "text" | "email" | "password" | "custom"
//     minLength / maxLength: optional ints
//     validator: optional function(value) -> true | "error message",
//       e.g. for confirm-password matching another field's text.
//   masked: renders as a password field. Uses a TEXT-based Show/Hide
//   toggle rather than an eye icon — no confirmed icon name for that
//   exists in the 252-icon set yet. Swap to Icon{} once one is verified
//   (see the project's own note on not guessing icon names).
//
// Usage:
//   AppTextInput {
//       label: "Password"
//       validationType: "password"
//       required: true
//       masked: true
//   }

Column {
    id: root

    property string label: ""
    property string helperText: ""
    property string errorMessage: ""
    // "default" | "error" | "success"
    property string validationState: "default"
    property bool required: false

    // Validation metadata, consumed by Form.qml — not enforced here.
    // "text" | "email" | "password" | "custom"
    property string validationType: "text"
    property var minLength: undefined
    property var maxLength: undefined
    property var validator: null

    // Password mode
    property bool masked: false
    property bool _revealed: false

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
            rightPadding: root.masked ? ThemeManager.spacing48 : ThemeManager.spacing12
            echoMode: (root.masked && !root._revealed) ? Basic.TextField.Password : Basic.TextField.Normal
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

        // Show/Hide toggle for masked (password) fields.
        AppText {
            visible: root.masked
            text: root._revealed ? "Hide" : "Show"
            variant: "caption"
            color: ThemeManager.accentPrimary
            anchors.right: parent.right
            anchors.rightMargin: ThemeManager.spacing12
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                cursorShape: Qt.PointingHandCursor
                onClicked: root._revealed = !root._revealed
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
