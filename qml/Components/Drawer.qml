import QtQuick
import QtQuick.Effects
import GeruBlocks

// Drawer — Step 9 Transient Overlays ("Drawer/Flyout panel" in the
// spec's component list)
//
// GLASS MATERIAL — backlog item 1c (signed off, "proof-of-material"):
// Section 3.5's recipe (background at ~28% opacity of its semantic
// color, 16px backdrop blur, 1px border at ~50% opacity) needed a real
// backdrop-blur architecture, which didn't exist before this change.
// Approach: ShaderEffectSource captures a live texture of whatever Item
// is passed in as `backdropSource` (the real app content sitting behind
// this overlay -- e.g. Main.qml's chromeRoot), MultiEffect blurs that
// capture, and the blurred result is placed as a child INSIDE the panel
// itself, offset by (-panel.x, -panel.y) and clipped to the panel's own
// bounds. Because both `root` (this Item) and `backdropSource` share the
// same coordinate space (both anchors.fill the same Window in Main.qml),
// panel.x/y IS the correct offset into the full-size capture -- no
// separate coordinate-mapping code needed, and the offset binding keeps
// the blur aligned automatically as the panel slides in/out.
//
// LAYERING NOTE: a Rectangle's own `color`/`border` always paint BEFORE
// its children, so the translucent tint can't be `panel.color` itself
// (a child blur painted after it would sit ON TOP of the tint, hiding
// it). panel.color is kept "transparent"; the tint is an explicit child
// Rectangle painted AFTER the blur, so the stacking is: blur (bottom) ->
// tint (middle) -> content (top).
//
// BACKWARD COMPATIBLE: backdropSource defaults to null. Any existing
// usage that doesn't pass it keeps the exact previous behavior (fully
// opaque backgroundSurface panel, no blur) -- no breaking API change.
//
// NOT YET SCREENSHOT-CONFIRMED on real hardware -- this is a first
// working attempt at live backdrop blur in this project (nothing else
// has needed it yet). blurMax/blur values below are a first guess
// mapped toward the spec's literal "16px" (blurMax: 64, blur: 0.5 ==
// roughly half of a 32px max radius). Confirm visually before treating
// this mapping as locked.
//
// SCOPED DOWN FROM THE FULL SPEC RECIPE FOR THE REMAINING COMPONENTS
// (Dialog, ContextMenu, DropdownMenu, Coachmark): this is being built as
// ONE proof-of-material pass across Drawer + CommandPalette together,
// per your direction -- those 4 remain deferred, unchanged.
//
// Slides in from a screen edge (`edge: "left" | "right"`, left default)
// rather than fading in place like Dialog/Popover -- that's the actual
// distinguishing behavior of a drawer vs. a dialog.
//
// Usage:
//   Drawer {
//       id: navDrawer
//       edge: "left"
//       drawerWidth: 280
//       backdropSource: chromeRoot   // NEW -- omit for the old opaque look
//       Heading { text: "Filters"; variant: "subheader" }
//       AppCheckbox { text: "Active only" }
//   }
//   navDrawer.open()

Item {
    id: root

    default property alias content: contentColumn.children
    property string edge: "left"  // "left" | "right"
    property real drawerWidth: 280
    property bool dismissOnScrimClick: true

    // NEW (backlog 1c): the real app-content Item sitting behind this
    // overlay, to be captured + blurred. null (default) = old opaque
    // behavior, no blur.
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
                duration: ThemeManager.durationSlow
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

    // Live capture of whatever's behind this overlay -- only active
    // while a backdropSource is supplied and the drawer is actually
    // open, to avoid paying for a continuous FBO capture while
    // closed/unused.
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
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.drawerWidth
        radius: 0
        color: "transparent"  // see header LAYERING NOTE -- tint is a child Rectangle below
        border.width: 1
        border.color: root.backdropSource
            ? Qt.rgba(ThemeManager.accentPrimary.r, ThemeManager.accentPrimary.g, ThemeManager.accentPrimary.b, 0.5)
            : ThemeManager.borderDefault
        clip: true

        // Blurred backdrop, clipped to this panel's own bounds. Positioned
        // at (-panel.x, -panel.y) so it always shows the exact slice of
        // the full-size capture that sits geometrically behind this
        // panel -- see header note on why this offset is correct without
        // extra coordinate-mapping code. Painted first (bottom-most).
        MultiEffect {
            visible: root.backdropSource !== null
            source: bgCapture
            x: -panel.x
            y: -panel.y
            width: root.width
            height: root.height
            blurEnabled: true
            blur: 0.85     // increased past the spec's literal 16px -- confirmed text behind stayed too legible at 0.5/32
            blurMax: 64
            autoPaddingEnabled: false
        }

        // Tint layer, painted second (on top of blur). 28% accent opacity
        // per Section 3.5's recipe -- accent rather than a neutral gray so
        // the panel visibly carries brand color, not a flat fog (Governance
        // Principle 6). Falls back to the original opaque surface color
        // when no backdropSource is supplied.
        Rectangle {
            anchors.fill: parent
            color: root.backdropSource
                ? Qt.rgba(ThemeManager.accentPrimary.r, ThemeManager.accentPrimary.g, ThemeManager.accentPrimary.b, 0.28)
                : ThemeManager.backgroundSurface
        }

        // Single x binding drives slide-in/out for BOTH edges -- no
        // anchors.left/right on this axis at all, since mixing an
        // anchor with an animated x on the same axis is exactly the
        // kind of conflicting-positioning bug this project's own
        // lessons warn about (anchors.centerIn-in-a-Column, Main.qml
        // Step 2 session). One source of truth for horizontal position.
        x: {
            if (root.edge === "left") return root.visible ? 0 : -width
            return root.visible ? (root.width - width) : root.width
        }

        Behavior on x {
            NumberAnimation {
                duration: ThemeManager.durationPanel
                easing.type: Easing.BezierSpline
                easing.bezierCurve: ThemeManager.easingCurve
            }
        }

        // Swallow clicks so they don't fall through to the scrim.
        MouseArea { anchors.fill: parent }

        Column {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: ThemeManager.spacing24
            spacing: ThemeManager.spacing16
        }
    }
}

