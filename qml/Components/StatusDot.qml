import QtQuick
import GeruBlocks

// StatusDot — Step 10 Feedback & Status
//
// A literal circle=node from the Warli grammar doing double duty as
// its own meaning — a status indicator IS a node in the grammar's own
// terms. Optional pulse for "live" states (something actively
// processing) uses opacity breathing, matching Skeleton.qml's existing
// pulse technique rather than inventing a new animation language for
// "this is active" (Skeleton's own header already notes its 900ms
// timing sits outside the formal duration token scale — reusing that
// same timing here rather than adding a third ad-hoc value).
//
// Usage:
//   StatusDot { status: "success" }
//   StatusDot { status: "error"; pulse: true }

Item {
    id: root
    property string status: "neutral"  // "success" | "error" | "neutral" | "pending"
    property bool pulse: false
    property int size: 8

    implicitWidth: size
    implicitHeight: size

    readonly property color _color: {
        if (status === "success") return ThemeManager.statusSuccess
        if (status === "error") return ThemeManager.statusError
        if (status === "pending") return ThemeManager.accentPrimary
        return ThemeManager.borderStrong
    }

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: root._color

        SequentialAnimation on opacity {
            running: root.pulse
            loops: Animation.Infinite
            NumberAnimation { from: 1.0; to: 0.35; duration: 900; easing.type: Easing.InOutQuad }
            NumberAnimation { from: 0.35; to: 1.0; duration: 900; easing.type: Easing.InOutQuad }
        }
    }
}
