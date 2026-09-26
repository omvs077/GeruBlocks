import QtQuick
import QtQuick.Controls.Basic as Basic
import QtQuick.Effects
import GeruBlocks

// Popover — Step 9 Transient Overlays
//
// Generic anchored panel for ARBITRARY CONTENT (a small form, a color
// picker, a details card) — distinct from DropdownMenu.qml, which is
// specifically an action-item list. Uses the same thin-wrapper default-
// content pattern as Form.qml/Accordion.qml (place any children, no
// fixed schema) rather than a `items` array, since popover content is
// by nature not list-shaped.
//
// GLASS MATERIAL, ADDED (backlog item — this file's old comment cited
// "the already-established precedent from Dialog/CommandPalette [staying
// solid]" as the reason glass wasn't added despite the spec listing
// "flyouts" as glass-eligible. That precedent no longer holds:
// CommandPalette has had working glass since Phase 1, and Dialog now
// does too — see Dialog.qml.) DropdownMenu/ContextMenu (Step 7) are
// unaffected by this change and remain solid, unchanged, since they're
// a separate component family with their own precedent, not touched by
// this batch.
//
// COORDINATE HANDLING — GENUINELY DIFFERENT FROM DIALOG/DRAWER/
// COMMANDPALETTE, NOT A COPY-PASTE OF THAT TECHNIQUE: those three all
// use `anchors.fill: parent`, so their root shares the exact same
// coordinate space as `backdropSource`, and a simple `-panel.x/-panel.y`
// offset correctly crops the right slice of the full-size capture.
// Popover instead has `parent: anchorItem` — it's positioned relative to
// whatever trigger button it's attached to, which can be anywhere in the
// tree, NOT necessarily sharing backdropSource's coordinate space. Using
// the same naive offset here would silently misalign the blur crop.
// Instead, this computes the background delegate's actual position in
// backdropSource's coordinate space directly via `mapToItem` and uses
// that as the crop offset. This is a correct adaptation of the same
// underlying idea (crop the full capture to the panel's own on-screen
// position), not an approximation — but it depends on QML's binding
// system re-evaluating `mapToItem` when the chain of ancestor x/y/scale
// values it reads changes, which is normal QtQuick behavior but is a
// genuinely different code path from Dialog/Drawer/CommandPalette's
// static offset binding. NOT YET SCREENSHOT-CONFIRMED — verify the crop
// stays aligned as the popover repositions against different trigger
// locations before treating this as locked, same discipline as every
// other new technique in this project.
//
// backdropSource defaults to null — old fully-opaque behavior unchanged
// for any existing usage that doesn't pass it. No breaking API change.
//
// Positioning matches Select.qml/DropdownMenu.qml exactly (parent =
// trigger, y = trigger.height) — same proven pattern, not new surface.
//
// Usage:
//   IconButton { id: trigger; iconName: "settings"; onClicked: popover.open() }
//   Popover {
//       id: popover
//       anchorItem: trigger
//       backdropSource: chromeRoot   // NEW -- omit for the old opaque look
//       AppText { text: "Quick settings"; variant: "subtitle" }
//       AppSwitch { text: "Dark mode" }
//   }

Basic.Popup {
    id: root

    default property alias content: contentColumn.children
    property Item anchorItem: null
    property real panelWidth: 260

    // NEW: the real app-content Item sitting behind this overlay, to be
    // captured + blurred. null (default) = old opaque behavior, no blur.
    property Item backdropSource: null

    parent: anchorItem
    y: anchorItem ? anchorItem.height + ThemeManager.spacing4 : 0
    x: 0
    width: panelWidth
    padding: ThemeManager.spacing16
    implicitHeight: contentColumn.implicitHeight + ThemeManager.spacing16 * 2
    closePolicy: Basic.Popup.CloseOnEscape | Basic.Popup.CloseOnPressOutside

    // Live capture of whatever's behind this overlay — see file header
    // COORDINATE HANDLING note for why the crop offset below differs
    // from Dialog/Drawer/CommandPalette. Only live while a
    // backdropSource is supplied and the popover is actually open.
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

    background: Item {
        id: bg

        // Popover's own on-screen position, expressed in backdropSource's
        // coordinate space — NOT a simple -x/-y offset like Dialog/Drawer/
        // CommandPalette, since Popover doesn't share their coordinate
        // space (see file header COORDINATE HANDLING note).
        readonly property point captureOffset: root.backdropSource
            ? bg.mapToItem(root.backdropSource, 0, 0)
            : Qt.point(0, 0)

        // Blurred backdrop, cropped to this exact on-screen position.
        // Painted first (bottom-most), same layering as Drawer/
        // CommandPalette/Dialog.
        MultiEffect {
            visible: root.backdropSource !== null
            source: bgCapture
            x: -bg.captureOffset.x
            y: -bg.captureOffset.y
            width: root.backdropSource ? root.backdropSource.width : 1
            height: root.backdropSource ? root.backdropSource.height : 1
            blurEnabled: true
            blur: 0.85
            blurMax: 64
            autoPaddingEnabled: false
        }

        // Tint + border layer, painted second (on top of blur). Falls
        // back to the original opaque surface color/default border when
        // no backdropSource supplied.
        Rectangle {
            anchors.fill: parent
            radius: 0
            color: root.backdropSource
                ? Qt.rgba(ThemeManager.accentPrimary.r, ThemeManager.accentPrimary.g, ThemeManager.accentPrimary.b, 0.28)
                : ThemeManager.backgroundSurface
            border.width: 1
            border.color: root.backdropSource
                ? Qt.rgba(ThemeManager.accentPrimary.r, ThemeManager.accentPrimary.g, ThemeManager.accentPrimary.b, 0.5)
                : ThemeManager.borderDefault
        }
    }

    contentItem: Column {
        id: contentColumn
        width: root.panelWidth - ThemeManager.spacing16 * 2
        spacing: ThemeManager.spacing12
    }
}
