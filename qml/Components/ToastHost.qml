import QtQuick
import QtQuick.Effects
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
// GLASS MATERIAL, ADDED (backlog follow-up from the Dialog/Popover/
// Coachmark batch — spec Section 3.5 does list toasts as glass-eligible).
// This needed real adaptation, not a copy of that batch's pattern,
// for two structural reasons:
//
//   1. SEMANTIC COLOR, NOT DECORATION: every other glass component
//      switches its tint to a neutral accentPrimary wash when glass is
//      active. A toast's color IS its meaning (success = green, error =
//      red) — overriding that to accent-blue would break the actual
//      signal, not just the look. So each toast keeps its existing
//      status-tint color unconditionally; only the presence/opacity of
//      the blur behind it changes with backdropSource.
//   2. MULTIPLE SIMULTANEOUS PANELS AT UNPREDICTABLE POSITIONS: Dialog/
//      Popover/Coachmark are each exactly one panel. Toasts stack
//      dynamically (0 to N, each independently timed/dismissed), so
//      there's no single "the panel" to crop around.
//
// ARCHITECTURE NOTE, REVISED AFTER ON-DEVICE TESTING: the first version
// of this hoisted ONE shared ShaderEffectSource to the host level,
// consumed by every toastItem's MultiEffect simultaneously, to avoid
// redundant captures. That did NOT render any blur at all on-device
// (confirmed via a temporary diagnostic marker that backdropSource WAS
// correctly reaching every toast — so the bug was specifically in the
// shared-capture rendering, not the wiring). Rather than keep debugging
// an architecture that's unproven anywhere else in this project, each
// toastItem now owns its OWN private ShaderEffectSource, exactly
// mirroring Dialog.qml's confirmed-working single-consumer pattern.
// This means N toasts showing at once means N live captures of the same
// backdropSource rather than one shared — a real but acceptable
// inefficiency given toasts are few, transient, and this isn't a
// performance-sensitive path, traded for using a technique that's
// actually proven to work rather than continuing to guess at why the
// shared version didn't.
//
// NEUTRAL/INFO TOAST ALPHA (0.82), FLAGGED — MY OWN JUDGMENT CALL, NOT
// SPEC-DERIVED: success/error toasts were already semi-transparent
// (0.10 alpha) even before this change, which read fine since their
// color itself carries weight. The neutral type used a fully opaque
// backgroundSurface fill; at anywhere near 0.10 alpha it would become
// nearly invisible (backgroundSurface is a near-white/near-black
// neutral, not a saturated hue) and the message text unreadable against
// an arbitrary blurred background. 0.82 was chosen to keep it clearly
// legible while still visibly showing blur behind it — worth a visual
// check once built, not treated as locked.
//
// backdropSource defaults to null — old fully-opaque-for-neutral-type /
// same-look-for-success-error behavior is unchanged for any existing
// usage that doesn't pass it. No breaking API change.
//
// toastItem changed from Rectangle to Item (fill/border moved to a
// plain child Rectangle) so a shadow-style MultiEffect can sit behind
// it — same reasoning as StatTile.qml's root-type change, but with NO
// external-API risk here at all, since toastItem is a private Repeater
// delegate, never referenced from outside this file.
//
// Usage: place ONE ToastHost at the app root, then call
// ToastManager.show(...) from anywhere.
//   ToastHost { backdropSource: chromeRoot }   // NEW -- omit for the old look

Column {
    id: root

    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.margins: ThemeManager.spacing16
    width: 320
    spacing: ThemeManager.spacing8

    // NEW: the real app-content Item sitting behind this overlay, to be
    // captured + blurred. null (default) = old behavior, no blur.
    property Item backdropSource: null

    Repeater {
        model: ToastManager.model

        delegate: Item {
            id: toastItem
            width: root.width
            implicitHeight: contentRow.implicitHeight + ThemeManager.spacing16 * 2
            height: implicitHeight
            // REQUIRED, WAS MISSING: the blur MultiEffect below is sized
            // to the full window, then offset so the right slice lines
            // up under this toast. Without clip: true (compare Dialog's
            // `panel`, which has it), nothing confines that full-window
            // content to this toast's small bounds -- this was almost
            // certainly the root cause of "no blur visible at all."
            clip: true

            // Private capture, owned by this toast alone — see file
            // header ARCHITECTURE NOTE for why this replaced the
            // originally-shared version.
            ShaderEffectSource {
                id: bgCapture
                sourceItem: root.backdropSource
                live: root.backdropSource !== null && toastItem.visible
                hideSource: false
                recursive: false
                visible: false
                width: root.backdropSource ? root.backdropSource.width : 1
                height: root.backdropSource ? root.backdropSource.height : 1
            }

            readonly property color _statusColor: {
                if (model.type === "success") return ThemeManager.statusSuccess
                if (model.type === "error") return ThemeManager.statusError
                return ThemeManager.backgroundSurface
            }
            readonly property color _borderColor: {
                if (model.type === "success") return ThemeManager.statusSuccess
                if (model.type === "error") return ThemeManager.statusError
                return ThemeManager.borderDefault
            }

            // This toast's own on-screen position in backdropSource's
            // coordinate space — same per-instance mapToItem technique
            // as Popover/Coachmark, needed here because each stacked
            // toast sits at a different y position within the window.
            //
            // FIX, ADDED AFTER ON-DEVICE TESTING SHOWED NO BLUR AT ALL:
            // mapToItem() called from inside a property binding is a
            // documented QML gotcha — its internal transform traversal
            // doesn't reliably register as a tracked dependency with the
            // binding engine, so the computed offset can freeze at
            // whatever it was when first evaluated (for a Repeater-
            // created toast, likely BEFORE Column's layout pass has
            // settled its real y position) and never update again. The
            // `_trigger` line below forces explicit, reliably-tracked
            // dependencies on the properties that actually determine
            // this toast's real position, so the binding re-evaluates
            // when they change, even though mapToItem's own internal
            // reads might not trigger that on their own.
            readonly property point _captureOffset: {
                var _trigger = [toastItem.x, toastItem.y, toastItem.width, toastItem.height,
                                 root.x, root.y, root.height]
                return root.backdropSource
                    ? toastItem.mapToItem(root.backdropSource, 0, 0)
                    : Qt.point(0, 0)
            }

            // Blurred backdrop, cropped to this toast's exact position.
            // Painted first (bottom-most), same layering convention as
            // every other glass component in this project.
            MultiEffect {
                visible: root.backdropSource !== null
                source: bgCapture
                x: -toastItem._captureOffset.x
                y: -toastItem._captureOffset.y
                width: root.backdropSource ? root.backdropSource.width : 1
                height: root.backdropSource ? root.backdropSource.height : 1
                blurEnabled: true
                blur: 0.85
                blurMax: 64
                autoPaddingEnabled: false
            }

            // Tint + border layer, painted second (on top of blur).
            // Color logic deliberately keeps the EXISTING status tint in
            // both the glass and non-glass cases — see file header
            // GLASS MATERIAL note, point 1, for why this never switches
            // to an accent wash the way other glass components do.
            Rectangle {
                anchors.fill: parent
                radius: 0  // sharp corners, no exceptions
                border.width: 1
                border.color: toastItem._borderColor
                color: {
                    var isStatusType = model.type === "success" || model.type === "error"
                    if (isStatusType) {
                        // Unchanged from before this file's glass work:
                        // already translucent at 0.10 alpha regardless
                        // of backdropSource, since color itself carries
                        // the meaning here, not opacity.
                        return Qt.rgba(toastItem._statusColor.r, toastItem._statusColor.g, toastItem._statusColor.b, 0.10)
                    }
                    if (!root.backdropSource) {
                        return ThemeManager.backgroundSurface  // unchanged old look
                    }
                    // Neutral type, glass active: see file header
                    // NEUTRAL/INFO TOAST ALPHA note for why 0.82.
                    return Qt.rgba(toastItem._statusColor.r, toastItem._statusColor.g, toastItem._statusColor.b, 0.82)
                }
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
