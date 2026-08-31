import QtQuick
import QtQuick.Controls.Basic as Basic
import GeruBlocks

// AppTextArea — Step 6, STUB (batch 2 of 4)
// Renamed with "App" prefix: collides with QtQuick.Controls' built-in
// TextArea type. Caller should wrap in a ScrollView for long content —
// not built in here, kept minimal for the stub pass.
//
// VALIDATION-GAP FOLLOW-UP: adds validationState/errorMessage/required.
// No new alias needed — QQC2 TextArea's native `text` property already
// satisfies Form.qml's contract as-is.

Basic.TextArea {
    id: root
    font.family: "Poppins"
    font.pixelSize: 14
    color: ThemeManager.textPrimary
    placeholderTextColor: ThemeManager.textSecondary
    wrapMode: TextEdit.WordWrap
    selectByMouse: true
    padding: ThemeManager.spacing12

    property string errorMessage: ""
    // "default" | "error" | "success"
    property string validationState: "default"
    property bool required: false

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
}
