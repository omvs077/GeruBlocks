import QtQuick
import QtQuick.Controls.Basic as Basic
import GeruBlocks

// AppTextArea — Step 6, STUB (batch 2 of 4)
// Renamed with "App" prefix: collides with QtQuick.Controls' built-in
// TextArea type. Caller should wrap in a ScrollView for long content —
// not built in here, kept minimal for the stub pass.

Basic.TextArea {
    id: root
    font.family: "Poppins"
    font.pixelSize: 14
    color: ThemeManager.textPrimary
    placeholderTextColor: ThemeManager.textSecondary
    wrapMode: TextEdit.WordWrap
    selectByMouse: true
    padding: ThemeManager.spacing12

    background: Rectangle {
        radius: 0
        border.width: 1
        border.color: root.activeFocus ? ThemeManager.accentPrimary : ThemeManager.borderDefault
        color: ThemeManager.backgroundSurface
    }
}