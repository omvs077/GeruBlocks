import QtQuick
import GeruBlocks

// SegmentedControl — Step 5, STUB (batch scaffolding pass)
// No QtQuick.Controls base fits cleanly, so it's hand-built: a Row of
// equal-width option cells with a single selected state. Not yet themed
// with hover/press states — stub for batch confirmation only.

Row {
    id: root
    height: ThemeManager.controlHeight

    property var options: []
    property string currentValue: options.length > 0 ? options[0].value : ""

    Repeater {
        model: root.options
        delegate: Rectangle {
            width: root.width / root.options.length
            height: root.height
            radius: 0
            color: modelData.value === root.currentValue ? ThemeManager.accentPrimary : ThemeManager.backgroundSurface
            border.width: 1
            border.color: ThemeManager.borderDefault

            Text {
                anchors.centerIn: parent
                text: modelData.label
                font.family: "Poppins"
                font.pixelSize: 13
                color: modelData.value === root.currentValue ? "#FFFFFF" : ThemeManager.textPrimary
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.currentValue = modelData.value
            }
        }
    }
}