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

Basic.CheckBox {
    id: root
    font.family: "Poppins"
    font.pixelSize: 14

    indicator: Rectangle {
        implicitWidth: 18
        implicitHeight: 18
        x: root.leftPadding
        y: root.height / 2 - height / 2
        radius: 0
        border.width: 1
        border.color: root.checked ? ThemeManager.accentPrimary : ThemeManager.borderStrong
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