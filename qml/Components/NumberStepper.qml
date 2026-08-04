import QtQuick
import QtQuick.Controls.Basic as Basic
import GeruBlocks

// NumberStepper — Step 5
// No naming collision (QQC2's builtin is "SpinBox", not "Number
// stepper"). Extends Basic.SpinBox, sharp-cornered increment/decrement
// buttons. Sized to match ThemeManager.controlHeight (32px) and spacing
// tokens, consistent with Button/AppTextInput — the earlier stub used
// QQC2's cramped default implicit sizing instead.

Basic.SpinBox {
    id: root
    from: 0
    to: 100
    value: 0
    editable: true
    font.family: "Poppins"
    font.pixelSize: 14

    implicitWidth: 140
    implicitHeight: ThemeManager.controlHeight

    contentItem: TextInput {
        text: root.textFromValue(root.value, root.locale)
        font: root.font
        color: ThemeManager.textPrimary
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        readOnly: !root.editable
        validator: root.validator
        selectByMouse: true
        leftPadding: root.up.indicator.width
        rightPadding: root.down.indicator.width
    }

    up.indicator: Rectangle {
        x: root.width - width
        width: ThemeManager.controlHeight
        height: root.height
        radius: 0
        color: upArea.pressed ? ThemeManager.accentPrimaryPressed : ThemeManager.backgroundSurface
        border.width: 1
        border.color: ThemeManager.borderDefault
        Text {
            text: "+"
            anchors.centerIn: parent
            font.pixelSize: 16
            color: upArea.pressed ? "#FFFFFF" : ThemeManager.textPrimary
        }
        MouseArea {
            id: upArea
            anchors.fill: parent
            onClicked: root.value = Math.min(root.value + root.stepSize, root.to)
        }
    }

    down.indicator: Rectangle {
        x: 0
        width: ThemeManager.controlHeight
        height: root.height
        radius: 0
        color: downArea.pressed ? ThemeManager.accentPrimaryPressed : ThemeManager.backgroundSurface
        border.width: 1
        border.color: ThemeManager.borderDefault
        Text {
            text: "\u2212"
            anchors.centerIn: parent
            font.pixelSize: 16
            color: downArea.pressed ? "#FFFFFF" : ThemeManager.textPrimary
        }
        MouseArea {
            id: downArea
            anchors.fill: parent
            onClicked: root.value = Math.max(root.value - root.stepSize, root.from)
        }
    }

    background: Rectangle {
        radius: 0
        border.width: 1
        border.color: ThemeManager.borderDefault
        color: ThemeManager.backgroundSurface
    }
}