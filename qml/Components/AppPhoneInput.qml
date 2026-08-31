import QtQuick
import QtQuick.Controls.Basic as Basic
import GeruBlocks

// AppPhoneInput — Step 6 follow-up
//
// Composite field: country-code Select + digits-only number field.
// Satisfies Form.qml's validation contract (validationState, errorMessage,
// required, text) plus validationType: "phone" so Form runs its phone
// length check (6–15 digits after stripping non-digits — see Form.qml's
// header note on why this is a loose sanity check, not real per-country
// validation).
//
// STRUCTURAL SAFETY: non-digit characters are stripped as you type
// (onTextChanged filter below), not just flagged after the fact on blur.
// You cannot type letters/symbols into the number portion at all.
//
// COUNTRY LIST FLAGGED AS A STARTING SET, NOT COMPREHENSIVE: a small
// curated list of common codes, defaulting to India (+91) per this
// project's India-first localization. Pass your own `countries` array to
// override/extend. No flag emoji used — relies on plain text (IN/US/UK/
// etc.) to avoid any font/glyph-rendering uncertainty with embedded
// Poppins.
//
// Usage:
//   AppPhoneInput {
//       label: "Phone Number"
//       required: true
//   }

Column {
    id: root

    property string label: ""
    property string helperText: ""
    property string errorMessage: ""
    // "default" | "error" | "success"
    property string validationState: "default"
    property bool required: false

    // Fixed — tells Form.qml to run the phone-format check.
    readonly property string validationType: "phone"

    property string countryCode: "+91"
    property alias text: numberField.text

    property var countries: [
        { code: "+91", label: "IN  +91" },
        { code: "+1",  label: "US  +1"  },
        { code: "+44", label: "UK  +44" },
        { code: "+61", label: "AU  +61" },
        { code: "+971", label: "AE  +971" },
        { code: "+65", label: "SG  +65" }
    ]

    signal editingFinished()

    width: 240
    spacing: ThemeManager.spacing4

    AppText {
        text: root.label
        variant: "caption"
        visible: root.label !== ""
    }

    Row {
        width: parent.width
        spacing: ThemeManager.spacing8

        Basic.ComboBox {
            id: codeBox
            width: 96
            height: ThemeManager.controlHeight
            font.family: "Poppins"
            font.pixelSize: 14
            editable: false
            model: root.countries
            textRole: "label"
            valueRole: "code"

            Component.onCompleted: {
                const idx = root.countries.findIndex(c => c.code === root.countryCode)
                currentIndex = idx >= 0 ? idx : 0
            }
            onActivated: root.countryCode = root.countries[currentIndex].code

            background: Rectangle {
                radius: 0
                border.width: 1
                border.color: codeBox.activeFocus ? ThemeManager.accentPrimary : ThemeManager.borderDefault
                color: ThemeManager.backgroundSurface
            }

            contentItem: Text {
                text: codeBox.displayText
                font: codeBox.font
                color: ThemeManager.textPrimary
                verticalAlignment: Text.AlignVCenter
                leftPadding: ThemeManager.spacing8
                elide: Text.ElideRight
            }

            popup: Basic.Popup {
                y: codeBox.height
                width: 160
                implicitHeight: Math.min(listView.contentHeight, 220)
                padding: 0

                background: Rectangle {
                    radius: 0
                    border.width: 1
                    border.color: ThemeManager.borderDefault
                    color: ThemeManager.backgroundSurface
                }

                contentItem: ListView {
                    id: listView
                    clip: true
                    implicitHeight: contentHeight
                    model: root.countries

                    delegate: Basic.ItemDelegate {
                        width: listView.width
                        height: ThemeManager.rowHeight
                        background: Rectangle {
                            color: codeBox.currentIndex === index ? ThemeManager.backgroundPage : "transparent"
                        }
                        contentItem: Text {
                            text: modelData.label
                            font.family: "Poppins"
                            font.pixelSize: 14
                            color: ThemeManager.textPrimary
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: ThemeManager.spacing12
                        }
                        onClicked: {
                            codeBox.currentIndex = index
                            root.countryCode = root.countries[index].code
                            codeBox.popup.close()
                        }
                    }
                }
            }
        }

        Item {
            width: parent.width - codeBox.width - parent.spacing
            height: ThemeManager.controlHeight

            Basic.TextField {
                id: numberField
                anchors.fill: parent
                enabled: root.enabled
                selectByMouse: true
                inputMethodHints: Qt.ImhDigitsOnly
                font.family: "Poppins"
                font.pixelSize: 14
                color: enabled ? ThemeManager.textPrimary : ThemeManager.textSecondary
                leftPadding: ThemeManager.spacing12
                rightPadding: ThemeManager.spacing12
                placeholderText: "9876543210"
                onEditingFinished: root.editingFinished()

                // Structural safety: strip anything non-digit as you type,
                // cap at 15 digits (E.164 max) — wrong characters simply
                // cannot end up in this field.
                onTextChanged: {
                    const filtered = text.replace(/[^0-9]/g, "").slice(0, 15)
                    if (filtered !== text) text = filtered
                }

                background: Rectangle {
                    radius: 0
                    color: numberField.enabled ? ThemeManager.backgroundSurface : ThemeManager.borderStrong
                    border.width: 1
                    border.color: {
                        if (!numberField.enabled) return ThemeManager.borderStrong
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

            Rectangle {
                anchors.fill: parent
                anchors.margins: -3
                radius: 0
                color: "transparent"
                border.width: 2
                border.color: ThemeManager.focusRingColor
                visible: numberField.activeFocus
            }
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
