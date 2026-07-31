import QtQuick
import GeruBlocks

// ToastHost — Step 4 Overlays & App Shell
//
// The visual half of the toast system — ToastManager (singleton) holds
// the queue/state, this displays it. Handles multiple simultaneous
// toasts stacking vertically with independent auto-dismiss timers, per
// your confirmed scope. Meant to be placed once, at the root of the app
// (eventually AppShell; for now the test harness), NOT per-screen.
//
// ASSUMPTIONS FLAGGED, NOT SPEC-STATED: bottom-right stacking position,
// newest toast appearing at the bottom of the stack (pushing older ones
// up) — the spec doesn't describe toast positioning/stacking order.
// Entrance/exit uses duration.slow (250ms, "Panel enter/exit") since a
// toast is a small transient panel, consistent with that token's stated use.
//
// Usage: place ONE ToastHost at the app root, then call
// ToastManager.show(...) from anywhere.

Column {
    id: root

    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.margins: ThemeManager.spacing16
    width: 320
    spacing: ThemeManager.spacing8

    Repeater {
        model: ToastManager.model

        delegate: Rectangle {
            id: toastItem
            width: root.width
            implicitHeight: contentRow.implicitHeight + ThemeManager.spacing16 * 2
            radius: 0  // sharp corners, no exceptions
            border.width: 1
            border.color: {
                if (model.type === "success") return ThemeManager.statusSuccess
                if (model.type === "error") return ThemeManager.statusError
                return ThemeManager.borderDefault
            }
            color: {
                if (model.type === "success") return Qt.rgba(ThemeManager.statusSuccess.r, ThemeManager.statusSuccess.g, ThemeManager.statusSuccess.b, 0.10)
                if (model.type === "error") return Qt.rgba(ThemeManager.statusError.r, ThemeManager.statusError.g, ThemeManager.statusError.b, 0.10)
                return ThemeManager.backgroundSurface
            }

            opacity: 0
            Component.onCompleted: opacity = 1
            Behavior on opacity {
                NumberAnimation {
                    duration: ThemeManager.durationSlow
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: ThemeManager.easingCurve
                }
            }

            Row {
                id: contentRow
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: ThemeManager.spacing16
                spacing: ThemeManager.spacing8

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    name: model.type === "success" ? "checkmark" : (model.type === "error" ? "close" : "")
                    size: 16
                    color: model.type === "success" ? ThemeManager.statusSuccess : (model.type === "error" ? ThemeManager.statusError : ThemeManager.textSecondary)
                    visible: model.type === "success" || model.type === "error"
                }

                Text {
                    id: label
                    width: parent.width - (model.type === "success" || model.type === "error" ? 24 : 0)
                    text: model.message
                    wrapMode: Text.WordWrap
                    font.family: "Poppins"
                    font.pixelSize: 13
                    color: ThemeManager.textPrimary
                }
            }

            Timer {
                interval: model.durationMs
                running: true
                onTriggered: ToastManager.dismissAt(index)
            }

            MouseArea {
                anchors.fill: parent
                onClicked: ToastManager.dismissAt(index)  // click to dismiss early
            }
        }
    }
}
