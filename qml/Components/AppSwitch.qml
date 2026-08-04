import QtQuick
import QtQuick.Controls.Basic as Basic
import GeruBlocks

// AppSwitch — Step 5, STUB (batch scaffolding pass)
// Renamed with "App" prefix: collides with QtQuick.Controls' built-in
// Switch type. FLAGGED OPEN QUESTION: thumb is a sharp square here to
// strictly follow "no curves anywhere" — but a fully square toggle
// thumb may read wrong visually. Needs your sign-off once seen, not
// assumed correct as-is.

Basic.Switch {
    id: root
    font.family: "Poppins"
    font.pixelSize: 14

    indicator: Rectangle {
        implicitWidth: 40
        implicitHeight: 20
        radius: 0
        x: root.leftPadding
        y: root.height / 2 - height / 2
        color: root.checked ? ThemeManager.accentPrimary : ThemeManager.borderStrong
        border.width: 1
        border.color: root.checked ? ThemeManager.accentPrimary : ThemeManager.borderStrong

        Rectangle {
            x: root.checked ? parent.width - width - 2 : 2
            y: 2
            width: 16
            height: 16
            radius: 0
            color: "#FFFFFF"
            Behavior on x {
                NumberAnimation {
                    duration: ThemeManager.durationFast
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: ThemeManager.easingCurve
                }
            }
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