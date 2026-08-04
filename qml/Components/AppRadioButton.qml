import QtQuick
import QtQuick.Controls.Basic as Basic
import GeruBlocks

// AppRadioButton — Step 5, STUB (batch scaffolding pass)
// Renamed with "App" prefix: collides with QtQuick.Controls' built-in
// RadioButton type. Circle indicator is intentional and spec-consistent
// (circle = node in the Warli grammar). Stub for batch confirmation.

Basic.RadioButton {
    id: root
    font.family: "Poppins"
    font.pixelSize: 14

    indicator: Rectangle {
        implicitWidth: 18
        implicitHeight: 18
        radius: 9
        x: root.leftPadding
        y: root.height / 2 - height / 2
        border.width: 1
        border.color: root.checked ? ThemeManager.accentPrimary : ThemeManager.borderStrong
        color: "transparent"

        Rectangle {
            anchors.centerIn: parent
            visible: root.checked
            width: 10
            height: 10
            radius: 5
            color: ThemeManager.accentPrimary
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