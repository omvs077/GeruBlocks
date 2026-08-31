import QtQuick
import GeruBlocks

// AvatarGroup — Step 11 Data Display ("Avatar (+ group)" in the spec's
// component list)
//
// Overlapping stack of Avatars (e.g. "4 members" on a project card),
// with a "+N" overflow tile when there are more entries than
// maxVisible. Takes a plain array rather than pre-built Avatar
// children — the overlap/z-order math needs to own positioning, so
// this can't be a thin-wrapper like Form/Accordion.
//
// Usage:
//   AvatarGroup {
//       people: [
//           { name: "Priya Nair" },
//           { name: "Rahul Verma" },
//           { name: "Aditi Sharma" },
//           { name: "Sanjay Gupta" }
//       ]
//       maxVisible: 3
//   }

Item {
    id: root
    property var people: []  // [{ name, imageSource? }]
    property int avatarSize: 32
    property int maxVisible: 4
    property real overlap: 0.35  // fraction of avatarSize overlapped per item

    readonly property int _visibleCount: Math.min(people.length, maxVisible)
    readonly property int _overflowCount: Math.max(0, people.length - maxVisible)
    readonly property real _step: avatarSize * (1 - overlap)

    implicitWidth: _step * (_visibleCount - 1 + (_overflowCount > 0 ? 1 : 0)) + avatarSize
    implicitHeight: avatarSize

    Repeater {
        model: root._visibleCount

        Item {
            x: index * root._step
            z: root._visibleCount - index
            width: root.avatarSize
            height: root.avatarSize

            Avatar {
                anchors.fill: parent
                size: root.avatarSize
                name: root.people[index].name
                imageSource: root.people[index].imageSource !== undefined ? root.people[index].imageSource : ""
            }

            Rectangle {
                anchors.fill: parent
                radius: 0
                color: "transparent"
                border.width: 3
                border.color: ThemeManager.backgroundSurface
            }
        }
    }

    Rectangle {
        visible: root._overflowCount > 0
        x: root._visibleCount * root._step
        width: root.avatarSize
        height: root.avatarSize
        radius: 0
        color: ThemeManager.borderStrong
        border.width: 2
        border.color: ThemeManager.backgroundSurface

        Text {
            anchors.centerIn: parent
            text: "+" + root._overflowCount
            color: ThemeManager.textPrimary
            font.family: "Poppins Medium"
            font.pixelSize: root.avatarSize * 0.32
        }
    }
}
