import QtQuick
import QtQuick.Effects
import GeruBlocks

// Coachmark — Step 9 Transient Overlays (final piece of this batch)
//
// GLASS MATERIAL, ADDED (backlog item — was previously scoped down to
// solid, same stale reasoning as Dialog originally had; see Dialog.qml's
// header for why that reasoning no longer holds).
//
// COORDINATE HANDLING: Coachmark uses `parent: anchorItem`, the same
// trigger-relative positioning as Popover, NOT the shared-coordinate-
// space structure Dialog/Drawer/CommandPalette rely on — so this uses
// the identical `mapToItem`-based crop offset as Popover, for the same
// reason. See Popover.qml's header COORDINATE HANDLING note for the full
// explanation; not repeated here in full to avoid the two copies
// drifting out of sync with each other over time.
//
// Unlike Dialog/Drawer/CommandPalette/Popover, Coachmark has no dimming
// scrim at all (it's a small floating callout, not a modal) — this only
// adds the blur+tint treatment to the callout panel itself, nothing else
// changes.
//
// border.color stays unconditionally ThemeManager.accentPrimary (not
// switched to a lower-alpha accent like the other four) — that's
// Coachmark's existing, intentional always-accent-bordered look for
// onboarding attention-grabbing, unrelated to whether blur is active,
// so it's left alone here.
//
// backdropSource defaults to null — old fully-opaque behavior unchanged
// for any existing usage that doesn't pass it. No breaking API change.
//
// DELIBERATE THEMATIC NOTE, same spirit as Stepper.qml: the pointer
// callout is a plain triangle (Warli grammar: triangle = structure) —
// drawn as an actual right-angled triangle via Canvas, not a rotated
// square hack, keeping it a real angular shape rather than faking one.
//
// Points at `anchorItem` from one side (`side: "top" | "bottom" | "left"
// | "right"`, which side the coachmark itself sits ON relative to the
// anchor — e.g. side: "bottom" means the coachmark appears below the
// anchor with its pointer aiming up at it). Includes an optional
// step counter ("2 of 4") and a single dismiss/next action — onboarding
// coachmarks are almost always part of a sequence, not a one-off,
// so the counter is built in rather than left for the caller to
// reconstruct with a separate Text every time.
//
// Usage:
//   Coachmark {
//       anchorItem: someButton
//       side: "bottom"
//       title: "New: Command Palette"
//       body: "Press Ctrl+K anywhere to jump to any action instantly."
//       step: 2
//       totalSteps: 4
//       backdropSource: chromeRoot   // NEW -- omit for the old opaque look
//       onNext: coachmarkFlow.advance()
//   }

Item {
    id: root

    property Item anchorItem: null
    property string side: "bottom"  // "top" | "bottom" | "left" | "right"
    property string title: ""
    property string body: ""
    property int step: 0        // 0 = no counter shown
    property int totalSteps: 0
    property real panelWidth: 260

    // NEW: the real app-content Item sitting behind this overlay, to be
    // captured + blurred. null (default) = old opaque behavior, no blur.
    property Item backdropSource: null

    signal next()
    signal dismissed()

    parent: anchorItem
    z: 2500

    readonly property int _pointerSize: 10

    x: {
        if (side === "left") return -width - _pointerSize
        if (side === "right") return anchorItem ? anchorItem.width + _pointerSize : 0
        // top/bottom: center under/over the anchor
        return anchorItem ? (anchorItem.width / 2 - width / 2) : 0
    }
    y: {
        if (side === "top") return -height - _pointerSize
        if (side === "bottom") return anchorItem ? anchorItem.height + _pointerSize : 0
        return anchorItem ? (anchorItem.height / 2 - height / 2) : 0
    }

    width: panelWidth
    height: contentColumn.implicitHeight + ThemeManager.spacing16 * 2

    // Live capture of whatever's behind this overlay — see Popover.qml's
    // header for why the mapToItem-based crop offset is used here
    // instead of Dialog/Drawer/CommandPalette's simpler -x/-y offset.
    // No open/close visibility flag exists on this component today (see
    // usage — callers appear to Loader this in/out externally), so
    // `root.visible`'s default-true Item behavior is used for the live
    // gate, matching the convention of every other glass-enabled
    // component in this project.
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

    Item {
        id: panelBg
        anchors.fill: parent

        readonly property point captureOffset: root.backdropSource
            ? panelBg.mapToItem(root.backdropSource, 0, 0)
            : Qt.point(0, 0)

        // Blurred backdrop, cropped to this exact on-screen position.
        MultiEffect {
            visible: root.backdropSource !== null
            source: bgCapture
            x: -panelBg.captureOffset.x
            y: -panelBg.captureOffset.y
            width: root.backdropSource ? root.backdropSource.width : 1
            height: root.backdropSource ? root.backdropSource.height : 1
            blurEnabled: true
            blur: 0.85
            blurMax: 64
            autoPaddingEnabled: false
        }

        // Tint layer, painted second (on top of blur). border.color is
        // deliberately unconditional accentPrimary regardless of
        // backdropSource — see file header note.
        Rectangle {
            anchors.fill: parent
            radius: 0
            color: root.backdropSource
                ? Qt.rgba(ThemeManager.accentPrimary.r, ThemeManager.accentPrimary.g, ThemeManager.accentPrimary.b, 0.28)
                : ThemeManager.backgroundSurface
            border.width: 1
            border.color: ThemeManager.accentPrimary
        }
    }

    // Pointer triangle, drawn via Canvas (real angular shape, not a
    // rotated Rectangle hack). Positioned on whichever edge faces the
    // anchor.
    Canvas {
        id: pointer
        width: root._pointerSize * 2
        height: root._pointerSize * 2
        x: {
            if (root.side === "top" || root.side === "bottom") return root.width / 2 - width / 2
            if (root.side === "left") return root.width - 1
            return -width + 1
        }
        y: {
            if (root.side === "left" || root.side === "right") return root.height / 2 - height / 2
            if (root.side === "top") return root.height - 1
            return -height + 1
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.fillStyle = ThemeManager.accentPrimary
            ctx.beginPath()
            if (root.side === "bottom") {
                ctx.moveTo(0, 0); ctx.lineTo(width, 0); ctx.lineTo(width / 2, height)
            } else if (root.side === "top") {
                ctx.moveTo(0, height); ctx.lineTo(width, height); ctx.lineTo(width / 2, 0)
            } else if (root.side === "right") {
                ctx.moveTo(0, 0); ctx.lineTo(0, height); ctx.lineTo(width, height / 2)
            } else {
                ctx.moveTo(width, 0); ctx.lineTo(width, height); ctx.lineTo(0, height / 2)
            }
            ctx.closePath()
            ctx.fill()
        }
    }

    Column {
        id: contentColumn
        x: ThemeManager.spacing16
        y: ThemeManager.spacing16
        width: parent.width - ThemeManager.spacing16 * 2
        spacing: ThemeManager.spacing8

        AppText {
            text: root.title
            variant: "subtitle"
            visible: root.title !== ""
            wrapMode: Text.WordWrap
            width: parent.width
        }

        AppText {
            text: root.body
            variant: "body"
            color: ThemeManager.textSecondary
            wrapMode: Text.WordWrap
            width: parent.width
        }

        Item {
            width: parent.width
            height: nextBtn.height

            AppText {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                visible: root.step > 0 && root.totalSteps > 0
                text: root.step + " of " + root.totalSteps
                variant: "caption"
                color: ThemeManager.textSecondary
            }

            Button {
                id: nextBtn
                anchors.right: parent.right
                text: root.step >= root.totalSteps && root.totalSteps > 0 ? "Done" : "Next"
                variant: "primary"
                onClicked: { root.next(); if (root.step >= root.totalSteps) root.dismissed() }
            }
        }
    }
}
