import QtQuick
import QtQuick.Controls.Basic as Basic
import GeruBlocks

// Select — Step 6
// Non-editable dropdown — the simple case. Distinct from AppCombobox.qml
// (editable + autocomplete). model: [{value,label}].
// FIX: initial version bound the popup ListView to root.delegateModel
// with QAbstractItemModel-style "model.label" role access, which left
// the dropdown empty for a plain JS array model, and never explicitly
// set currentIndex on click — meaning nothing actually registered a
// selection. Rewritten to match AppCombobox.qml's proven pattern:
// bind directly to the raw array, use modelData, and explicitly set
// currentIndex + close the popup on click.
//
// VALIDATION-GAP FOLLOW-UP: adds validationState/errorMessage/required.
// No new value alias needed — ComboBox's native `currentValue` (from
// valueRole) already satisfies Form.qml's contract as-is.

Basic.ComboBox {
    id: root
    font.family: "Poppins"
    font.pixelSize: 14
    editable: false
    textRole: "label"
    valueRole: "value"

    property string errorMessage: ""
    // "default" | "error" | "success"
    property string validationState: "default"
    property bool required: false

    implicitWidth: 220
    implicitHeight: ThemeManager.controlHeight

    background: Rectangle {
        radius: 0
        border.width: 1
        border.color: {
            if (root.activeFocus) return ThemeManager.accentPrimary
            if (root.validationState === "error") return ThemeManager.statusError
            if (root.validationState === "success") return ThemeManager.statusSuccess
            return ThemeManager.borderDefault
        }
        color: ThemeManager.backgroundSurface
    }

    contentItem: Text {
        text: root.displayText
        font: root.font
        color: ThemeManager.textPrimary
        verticalAlignment: Text.AlignVCenter
        leftPadding: ThemeManager.spacing12
        rightPadding: root.indicator.width
        elide: Text.ElideRight
    }

    indicator: Text {
        x: root.width - width - ThemeManager.spacing12
        y: root.height / 2 - height / 2
        text: root.popup.visible ? "\u25B2" : "\u25BC"
        color: ThemeManager.textSecondary
        font.pixelSize: 10
    }

    popup: Basic.Popup {
        id: popup
        y: root.height
        width: root.width
        implicitHeight: Math.min(listView.contentHeight, 240)
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
            model: root.model

            delegate: Basic.ItemDelegate {
                width: listView.width
                height: ThemeManager.rowHeight

                background: Rectangle {
                    color: root.currentIndex === index ? ThemeManager.backgroundPage : "transparent"
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
                    root.currentIndex = index
                    popup.close()
                }
            }
        }
    }
}
