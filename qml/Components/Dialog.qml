import QtQuick
import QtQuick.Effects
import GeruBlocks

// Dialog — Step 4 Overlays & App Shell
//
// GLASS MATERIAL, ADDED (backlog item — was previously scoped down to
// solid, on the reasoning that AppShell's overlay layer didn't exist yet
// to grab a live texture from). That reasoning is now stale: AppShell.qml
// exists and the exact live-capture technique this file uses is already
// proven working on Drawer.qml/CommandPalette.qml. This applies the
// IDENTICAL technique, unmodified — see Drawer.qml's header for the full
// rationale (ShaderEffectSource + MultiEffect, blur painted first/tint
// painted second inside a transparent panel, offset by -panel.x/-panel.y).
// Dialog's root shares the same `anchors.fill: parent` structure as
// Drawer/CommandPalette, so the same coordinate-space assumption holds
// (root and backdropSource both fill the same Window) — no adaptation
// needed here, unlike Popover/Coachmark (see those files).
//
// backdropSource defaults to null — old fully-opaque behavior unchanged
// for any existing usage that doesn't pass it. No breaking API change.
//
// KNOWN MINOR LIMITATION, carried over from CommandPalette (same cause):
// this panel SCALES during its open/close transition (0.95 -> 1.0), same
// as CommandPalette and unlike Drawer (which only translates). The blur
// child scales along with panel, so alignment is very slightly off
// during the ~320ms transition, settling correctly once fully open/
// closed. Same judgment call as CommandPalette: not worth a second
// capture pass for a sub-third-of-a-second cosmetic wobble.
//
// AppShell WIRING NOTE, FLAGGED SEPARATELY — NOT FIXED HERE: AppShell.qml
// mounts `CommandPalette {}` with no backdropSource passed at all, so
// even CommandPalette's own proven glass sits dormant (falls back to
// opaque) in the actual app shell today, not just in Dialog/Popover/
// Coachmark. Giving Dialog this SAME opt-in capability doesn't fix that
// wiring gap — it just means Dialog is no longer behind Drawer/
// CommandPalette in capability. Actually connecting a real backdropSource
// at every call site (AppShell and per-page Dialog instances alike) is
// its own follow-up task, out of scope for "give these components the
// capability" vs. "wire every real usage to it."
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
//       backdropSource: chromeRoot   // NEW -- omit for the old opaque look
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

    // NEW: the real app-content Item sitting behind this overlay, to be
    // captured + blurred. null (default) = old opaque behavior, no blur.
    // Same property, same meaning, same default as Drawer/CommandPalette.
    property Item backdropSource: null

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

    // Live capture of whatever's behind this overlay — identical
    // technique to Drawer.qml/CommandPalette.qml, see Drawer.qml's
    // header for the full rationale. Only live while a backdropSource
    // is supplied and the dialog is actually open.
    ShaderEffectSource {
        id: bgCapture
        sourceItem: root.backdropSource
        live: root.backdropSource !== null && root.visible
        hideSource: false
        recursive: false
        visible: false
        width: root.backdropSource ? root.backdropSource.width : 1
        height: root.backdropSource ? root.backdropSource.height : 1
    }

    Rectangle {
        id: panel
        anchors.centerIn: parent
        width: root.panelWidth
        height: contentColumn.implicitHeight + ThemeManager.spacing24 * 2
        radius: 0  // sharp corners, no exceptions, even for dialogs (Section 3.4)
        color: "transparent"  // see Drawer.qml LAYERING NOTE — tint is a child Rectangle below
        border.width: 1
        border.color: root.backdropSource
            ? Qt.rgba(ThemeManager.accentPrimary.r, ThemeManager.accentPrimary.g, ThemeManager.accentPrimary.b, 0.5)
            : ThemeManager.borderDefault
        clip: true

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

        // Blurred backdrop, clipped to panel's bounds, offset to align
        // with the live capture behind it. Painted first (bottom-most) —
        // identical positioning technique to Drawer/CommandPalette,
        // valid here because Dialog's root also anchors.fill the same
        // parent as backdropSource (see file header note).
        MultiEffect {
            visible: root.backdropSource !== null
            source: bgCapture
            x: -panel.x
            y: -panel.y
            width: root.width
            height: root.height
            blurEnabled: true
            blur: 0.85
            blurMax: 64
            autoPaddingEnabled: false
        }

        // Tint layer, painted second (on top of blur). Falls back to the
        // original opaque surface color when no backdropSource supplied.
        Rectangle {
            anchors.fill: parent
            color: root.backdropSource
                ? Qt.rgba(ThemeManager.accentPrimary.r, ThemeManager.accentPrimary.g, ThemeManager.accentPrimary.b, 0.28)
                : ThemeManager.backgroundSurface
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
