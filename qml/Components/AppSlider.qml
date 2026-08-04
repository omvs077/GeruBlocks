import QtQuick
import QtQuick.Controls.Basic as Basic
import GeruBlocks

// AppSlider — Step 5, STUB (batch scaffolding pass)
// Renamed with "App" prefix: collides with QtQuick.Controls' built-in
// Slider type. Sharp-cornered handle, flat track. Stub for batch
// confirmation only.

Basic.Slider {
    id: root
    from: 0
    to: 100
    value: 50

    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: root.availableWidth
        height: 4
        radius: 0
        color: ThemeManager.borderDefault

        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            radius: 0
            color: ThemeManager.accentPrimary
        }
    }

    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: 16
        height: 16
        radius: 0
        color: ThemeManager.accentPrimary
        border.width: 1
        border.color: ThemeManager.accentPrimaryPressed
    }
}