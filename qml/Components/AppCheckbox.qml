import QtQuick
import QtQuick.Controls.Basic as Basic
import GeruBlocks

// AppCheckbox — Step 5, STUB (batch scaffolding pass)
// Renamed with "App" prefix per established convention: collides with
// QtQuick.Controls' built-in CheckBox type.
// Not yet themed to full Warli-grammar spec (focus ring, hover states) —
// this stub exists to compile, wire into CMakeLists.txt/module
// registration, and confirm in the test harness before the real design
// pass, one component at a time.
//
// VALIDATION-GAP FOLLOW-UP: adds validationState/errorMessage/required
// so Form.qml can enforce e.g. a required "I agree to terms" checkbox
// (required + unchecked = invalid — Form.qml has boolean-aware handling
// for this, see its _validateField). SCOPE LIMITED, FLAGGED: no error-
// message text row added here, since that needs restructuring this
// component's root from CheckBox into a label+control+error wrapper —
// a bigger change than "close the validation gap," and this component
// hasn't had its real design pass yet anyway. For now, invalid state
// only shows as a red indicator border. Ask if you want the full
// error-text treatment now instead of deferring it.

Basic.CheckBox {
    id: root
    font.family: "Poppins"
    font.pixelSize: 14

    property string errorMessage: ""
    // "default" | "error" | "success"
    property string validationState: "default"
    property bool required: false
    property alias value: root.checked

    indicator: Rectangle {
        implicitWidth: 18
        implicitHeight: 18
        x: root.leftPadding
        y: root.height / 2 - height / 2
        radius: 0
        border.width: 1
        border.color: {
            if (root.validationState === "error") return ThemeManager.statusError
            if (root.checked) return ThemeManager.accentPrimary
            return ThemeManager.borderStrong
        }
        color: root.checked ? ThemeManager.accentPrimary : "transparent"

        Text {
            visible: root.checked
            anchors.centerIn: parent
            text: "\u2713"
            color: "#FFFFFF"
            font.pixelSize: 12
        }
    }

    contentItem: Text {
        text: root.text
        font: root.font
        color: ThemeManager.textPrimary
        verticalAlignment: Text.AlignVCenter
        leftPadding: root.indicator.width + root.spacing
    }
}
