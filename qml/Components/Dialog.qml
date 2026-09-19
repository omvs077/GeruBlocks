import QtQuick
import GeruBlocks

// Dialog — Step 4 Overlays & App Shell
//
// SCOPED DOWN FROM THE FULL SPEC RECIPE, FLAGGED CLEARLY: Section 3.5's
// glass material recipe calls for a translucent background + 16px
// backdrop blur of whatever's behind the dialog. Implementing real
// backdrop blur requires an overlay architecture that can grab a live
// texture of the actual app content sitting behind the modal — which
// doesn't exist yet, since AppShell (the thing that defines "what's
// behind the dialog") is last in this build step's order. Rather than
// hack together blur against a structure that doesn't exist, this uses
// a plain dimming scrim (no blur) and a solid, fully-opaque panel
// background for now. Revisit once AppShell's overlay layer exists —
// this is an interim scope decision, not a finished implementation of
// the spec's glass recipe.
//
// TYPEFACE CONVENTION, Phase 3 typography backlog lever 5 (Martel):
// the backlog's Martel use case is "Dialog terms-and-conditions text,
// legal/formal copy wherever it appears on-screen" — NOT a change to
// this file's own code. Dialog's body is a fully open default-property
// slot (bodyColumn below), the same "chrome I own vs. content I don't"
// situation as Panel's featured variant — Dialog has no way to know
// whether a caller's content is legal copy or a plain "Are you sure?"
// confirmation, so forcing Martel here would wrongly restyle every
// dialog's body text, not just the ones that should get it.
// CONVENTION: when a Dialog's body genuinely IS legal/formal copy
// (terms of service, license text, a formal notice), the CALLER sets
// font.family: "Martel" directly on that content — see Main.qml's
// terms-and-conditions demo for the applied pattern. Ordinary dialogs
// (confirmations, simple prompts) stay on Poppins, unchanged.
//
// Entrance/exit uses duration.panel (320ms, "Panel scale+fade settle")
// exactly as the spec's own duration table names it — scale 0.95→1.0 +
// fade, not a guessed animation.
//
// Usage:
//   Dialog {
//       id: myDialog
//       title: "Confirm Action"
//       Text { text: "Are you sure?"; color: ThemeManager.textSecondary }
//       footer: Component {
//           Row {
//               spacing: 8
//               Button { text: "Cancel"; variant: "ghost"; onClicked: myDialog.close() }
//               Button { text: "Confirm"; variant: "primary"; onClicked: myDialog.close() }
//           }
//       }
//   }
//   myDialog.open()

Item {
    id: root

    property string title: ""
    default property alias body: bodyColumn.data
    property Component footer: null
    property real panelWidth: 400

    // Click-outside-to-dismiss can be disabled for dialogs that require
    // an explicit action (e.g. destructive confirms) — not spec-stated,
    // a reasonable default that's easy to turn off per-instance.
    property bool dismissOnScrimClick: true

    signal opened()
    signal closed()

    function open() { visible = true; opened() }
    function close() { visible = false; closed() }

    anchors.fill: parent
    visible: false
    z: 1000

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: root.visible ? 0.5 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: ThemeManager.durationSlow  // 250ms, "Panel enter/exit"
                easing.type: Easing.BezierSpline
                easing.bezierCurve: ThemeManager.easingCurve
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: root.dismissOnScrimClick
            onClicked: root.close()
        }
    }

    Rectangle {
        id: panel
        anchors.centerIn: parent
        width: root.panelWidth
        height: contentColumn.implicitHeight + ThemeManager.spacing24 * 2
        radius: 0  // sharp corners, no exceptions, even for dialogs (Section 3.4)
        color: ThemeManager.backgroundSurface
        border.width: 1
        border.color: ThemeManager.borderDefault

        scale: root.visible ? 1.0 : 0.95
        opacity: root.visible ? 1.0 : 0.0

        Behavior on scale {
            NumberAnimation {
                duration: ThemeManager.durationPanel  // 320ms, "Panel scale+fade settle"
                easing.type: Easing.BezierSpline
                easing.bezierCurve: ThemeManager.easingCurve
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: ThemeManager.durationPanel
                easing.type: Easing.BezierSpline
                easing.bezierCurve: ThemeManager.easingCurve
            }
        }

        // Swallow clicks so they don't fall through to the scrim's
        // click-outside-to-dismiss handler.
        MouseArea { anchors.fill: parent }

        Column {
            id: contentColumn
            anchors.centerIn: parent
            width: parent.width - ThemeManager.spacing24 * 2
            spacing: ThemeManager.spacing16

            Heading {
                text: root.title
                variant: "subheader"
                visible: root.title !== ""
            }

            Column {
                id: bodyColumn
                width: parent.width
            }

            Loader {
                width: parent.width
                active: root.footer !== null
                sourceComponent: root.footer
            }
        }
    }
}
