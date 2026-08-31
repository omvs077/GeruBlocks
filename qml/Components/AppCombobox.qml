import QtQuick
import QtQuick.Controls.Basic as Basic
import GeruBlocks

// AppCombobox — Step 6, STUB (batch 3 of 4)
// Prefixed "App" to avoid confusion with QtQuick.Controls' "ComboBox"
// (technically a distinct identifier, but close enough to invite
// mistakes — same caution as AppText/AppTextInput). Editable, with a
// live-filtered dropdown — distinct from Select.qml's simple
// non-editable case.
// FILTER LOGIC FLAGGED, NOT SPEC-STATED: simple case-insensitive
// substring match, deliberately NOT CommandPalette's subsequence fuzzy
// scorer — that scorer suits command search, not form-filling
// predictability. Revisit only if you want the two made consistent.
//
// VALIDATION-GAP FOLLOW-UP: adds validationState/errorMessage/required
// plus a `value` alias to the existing currentValue property, since
// Form.qml's contract looks for `.text` or `.value` and root (a plain
// Item) previously exposed neither.

Item {
    id: root

    property var options: []  // [{value, label}]
    property string currentValue: ""
    property alias value: root.currentValue
    property alias placeholderText: input.placeholderText
    property var _filtered: options

    property string errorMessage: ""
    // "default" | "error" | "success"
    property string validationState: "default"
    property bool required: false

    implicitWidth: 220
    implicitHeight: ThemeManager.controlHeight

    function _filter() {
        var q = input.text.toLowerCase()
        if (q === "") { _filtered = options; return }
        var out = []
        for (var i = 0; i < options.length; i++) {
            if (options[i].label.toLowerCase().indexOf(q) !== -1) out.push(options[i])
        }
        _filtered = out
    }

    Basic.TextField {
        id: input
        anchors.fill: parent
        font.family: "Poppins"
        font.pixelSize: 14
        color: ThemeManager.textPrimary
        placeholderTextColor: ThemeManager.textSecondary
        background: Rectangle {
            radius: 0
            border.width: 1
            border.color: {
                if (input.activeFocus) return ThemeManager.accentPrimary
                if (root.validationState === "error") return ThemeManager.statusError
                if (root.validationState === "success") return ThemeManager.statusSuccess
                return ThemeManager.borderDefault
            }
            color: ThemeManager.backgroundSurface
        }
        onTextChanged: { root._filter(); popup.open() }
        onFocusChanged: if (focus) { root._filter(); popup.open() }
    }

    Basic.Popup {
        id: popup
        y: input.height
        width: root.width
        implicitHeight: Math.min(listView.contentHeight, 200)
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
            model: root._filtered

            delegate: Basic.ItemDelegate {
                width: popup.width
                height: ThemeManager.rowHeight
                contentItem: Text {
                    text: modelData.label
                    font.family: "Poppins"
                    font.pixelSize: 14
                    color: ThemeManager.textPrimary
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: ThemeManager.spacing12
                }
                onClicked: {
                    root.currentValue = modelData.value
                    input.text = modelData.label
                    popup.close()
                }
            }
        }
    }
}
