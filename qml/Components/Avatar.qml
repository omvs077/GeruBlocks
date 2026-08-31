import QtQuick
import GeruBlocks

// Avatar — Step 11 Data Display (v2, redesigned per feedback: colors
// too loud, flat/no border unlike Card/StatTile, group overlap read
// unclear)
//
// CHANGES FROM v1:
//   - Fallback fill is now a MUTED, FULLY OPAQUE tint (accent color
//     blended 82% toward backgroundPage), not a solid saturated block
//     -- calmer, closer to the serious OS-grade feel. Deliberately NOT
//     real alpha transparency (Qt.rgba with an actual alpha channel):
//     that would have blended messily wherever AvatarGroup.qml's tiles
//     overlap, since a translucent tile lets whatever's directly behind
//     it (the adjacent avatar, in the overlap zone) show through and
//     muddy the color. Blending toward a target color in JS keeps the
//     result opaque and theme-aware (blends toward whichever theme's
//     backgroundPage is active) while still reading as muted.
//   - Initials text uses the full-saturation accent color (not white),
//     for contrast against the now-light tint.
//   - Real border now, matching Card.qml/StatTile.qml's convention
//     (border.width: 1) instead of being a flat, borderless block.
//   - Group separation ring (AvatarGroup.qml) widened 2px -> 3px for
//     clearer stacking definition.
//
// Still shows `imageSource` if set and it loads successfully,
// otherwise falls back to initials — same as v1. Still square, not
// circular (sharp corners per spec 3.4, no stated avatar exception).
//
// Usage unchanged:
//   Avatar { name: "Priya Nair"; size: 40 }
//   Avatar { name: "Priya Nair"; imageSource: "qrc:/photo.jpg"; size: 40 }

Item {
    id: root
    property string name: ""
    property url imageSource: ""
    property int size: 36

    implicitWidth: size
    implicitHeight: size

    readonly property string _initials: {
        if (name === "") return "?"
        var parts = name.trim().split(/\s+/)
        if (parts.length === 1) return parts[0].substring(0, 1).toUpperCase()
        return (parts[0].substring(0, 1) + parts[parts.length - 1].substring(0, 1)).toUpperCase()
    }

    readonly property var _palette: ["#1A5FD7", "#2E9B57", "#8B5FBF", "#D6A32E", "#2E9B9B", "#B3506B"]
    readonly property color _accentColor: {
        var sum = 0
        for (var i = 0; i < name.length; i++) sum += name.charCodeAt(i)
        return _palette[sum % _palette.length]
    }

    // Opaque blend toward a target color -- NOT alpha transparency, see
    // header note on why that distinction matters for AvatarGroup.
    function _mix(c, target, amount) {
        return Qt.rgba(
            c.r + (target.r - c.r) * amount,
            c.g + (target.g - c.g) * amount,
            c.b + (target.b - c.b) * amount,
            1.0
        )
    }
    readonly property color _tintColor: _mix(root._accentColor, ThemeManager.backgroundPage, 0.82)

    readonly property bool _hasImage: imageSource.toString() !== "" && image.status === Image.Ready

    Rectangle {
        anchors.fill: parent
        radius: 0
        color: root._tintColor
        border.width: 1
        border.color: root._accentColor
        visible: !root._hasImage

        Text {
            anchors.centerIn: parent
            text: root._initials
            color: root._accentColor
            font.family: "Poppins Medium"
            font.pixelSize: root.size * 0.38
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 0
        color: "transparent"
        border.width: 1
        border.color: ThemeManager.borderDefault
        visible: root._hasImage
    }

    Image {
        id: image
        anchors.fill: parent
        source: root.imageSource
        fillMode: Image.PreserveAspectCrop
        visible: root._hasImage
        asynchronous: true
    }
}
