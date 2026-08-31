import QtQuick
import GeruBlocks

// Spinner — Step 10 Feedback & Status
//
// THEMATIC FIT, DELIBERATE: a rotating arc would need a curved stroke —
// against the no-curves-except-full-circle rule this project already
// rebuilt Undo/Redo/Wifi/Power/Theme-toggle away from once before. This
// is instead a ring of small full circles (the one allowed curve
// primitive) with a fading opacity trail, rotating as a group — works
// with the grammar instead of fighting it.
//
// Usage:
//   Spinner { size: 24 }

Item {
    id: root
    property int size: 24
    property int dotCount: 8
    property color color: ThemeManager.accentPrimary

    implicitWidth: size
    implicitHeight: size

    RotationAnimation on rotation {
        running: root.visible
        loops: Animation.Infinite
        from: 0
        to: 360
        duration: 900
    }

    Repeater {
        model: root.dotCount

        Rectangle {
            readonly property real _angle: (2 * Math.PI * index) / root.dotCount
            readonly property real _radius: root.size / 2 - width / 2
            width: root.size * 0.14
            height: width
            radius: width / 2
            color: root.color
            opacity: 0.25 + 0.75 * (index / root.dotCount)
            x: root.size / 2 + _radius * Math.cos(_angle) - width / 2
            y: root.size / 2 + _radius * Math.sin(_angle) - height / 2
        }
    }
}
