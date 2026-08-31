import QtQuick
import GeruBlocks

// ProgressBar — Step 10 Feedback & Status
//
// Two modes: determinate (value/from/to bound, matches QQC2 ProgressBar
// convention) and indeterminate (indeterminate: true — a sliding
// segment when duration is unknown).
//
// Usage:
//   ProgressBar { value: 0.6 }           // 60%, determinate
//   ProgressBar { indeterminate: true }  // unknown duration

Item {
    id: root
    property real from: 0
    property real to: 1
    property real value: 0
    property bool indeterminate: false

    implicitWidth: 200
    implicitHeight: 6
    clip: true

    readonly property real _fraction: Math.max(0, Math.min(1, (value - from) / (to - from)))

    Rectangle {
        anchors.fill: parent
        radius: 0
        color: ThemeManager.borderDefault
    }

    Rectangle {
        visible: !root.indeterminate
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width * root._fraction
        radius: 0
        color: ThemeManager.accentPrimary

        Behavior on width {
            NumberAnimation {
                duration: ThemeManager.durationBase
                easing.type: Easing.BezierSpline
                easing.bezierCurve: ThemeManager.easingCurve
            }
        }
    }

    Rectangle {
        id: indeterminateSegment
        visible: root.indeterminate
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width * 0.3
        radius: 0
        color: ThemeManager.accentPrimary

        SequentialAnimation on x {
            running: root.indeterminate
            loops: Animation.Infinite
            NumberAnimation { from: -indeterminateSegment.width; to: root.width; duration: 1200; easing.type: Easing.InOutQuad }
        }
    }
}
