import QtQuick
import QtQuick.Controls.Basic as Basic
import GeruBlocks

// AppShell — Step 4 Overlays & App Shell (final piece)
//
// The real application scaffold: a persistent left nav rail (built from
// NavItem) plus a swappable content area on the right, with the global
// overlay layer (ToastHost, CommandPalette) mounted once at the root so
// any page loaded into the content area can trigger toasts or use the
// command palette without re-mounting them. CommandPalette's glass now
// has a real backdropSource wired to it — see GLASS WIRING note below.
//
// PLACEHOLDER CONTENT, FLAGGED NOT SPEC-STATED: nav items below (Dashboard,
// Zones, Maintenance, Settings) are scaffolding — real navigation and
// page content land in Steps 5-13 as those components exist. The content
// area just shows which nav item is selected for now.
//
// Dialog is NOT mounted here globally, unlike ToastHost/CommandPalette —
// per Section 3.5, dialogs are typically triggered by specific actions
// with their own content, so each page should own its own Dialog
// instance(s) rather than AppShell providing one generic instance.
//
// ICON NAMES FLAGGED UNVERIFIED: "grid_view", "wrench", "theme_toggle"
// below have not been confirmed against the actual 252-icon set (only
// checkmark/close were verified earlier in this project). Check these
// exist before relying on this compiling clean — swap for confirmed
// names if not.
//
// BACKGROUND MOTIF (backlog 1f): placed inside contentArea specifically,
// anchored to ITS bottom-right corner, not the shell root — navRail is
// an opaque solid-fill panel that would just hide the motif entirely if
// it sat behind the whole shell. This is the real intended home for the
// motif (Main.qml's copy is the flat test harness; this is the actual
// app shell it's meant to live in).
//
// GLASS WIRING, ADDED (this is the actual AppShell-level fix the earlier
// glass batch was deferred pending): CommandPalette previously had a
// working `backdropSource` capability but nothing here ever passed one
// in, so its glass sat dormant. `chromeRow` (the Row containing navRail
// + contentArea) is passed in, NOT `root` itself — root also contains
// CommandPalette/ToastHost (the overlay layer), and a ShaderEffectSource
// whose sourceItem is an ancestor of the Item consuming its own capture
// is a genuine self-referential-capture problem (Qt explicitly warns
// against this), not just a style choice. chromeRow correctly captures
// only the real app content behind the overlay, nothing else.
//
// STILL NOT WIRED HERE, DELIBERATELY — FLAGGED, NOT FORGOTTEN:
//   - ToastHost: the spec's glass-eligible list (Section 3.5) DOES
//     include toasts, but ToastHost.qml's own source hasn't been read in
//     this pass — giving it backdropSource without first confirming it
//     even exposes that property (or has the ShaderEffectSource/
//     MultiEffect plumbing to use it) would be exactly the kind of
//     guessing this project has been deliberately avoiding. Separate
//     follow-up.
//   - Dialog/Popover/Coachmark: per this file's own existing note above,
//     Dialog is intentionally NOT mounted globally here — pages own
//     their own Dialog/Popover/Coachmark instances, and no real pages
//     exist yet (Steps 5-13 placeholder). Each page will need to pass
//     its own backdropSource (likely `chromeRow` or an equivalent) once
//     built — nothing to wire here until real page content exists.
//
// `standalone` PROPERTY, ADDED: Main.qml's test harness currently loads
// this whole file as a NESTED PAGE inside its own Loader (via the "View
// AppShell" toggle), while Main.qml ALSO keeps its own top-level
// CommandPalette/ToastHost/Drawer mounted at all times. Without a guard,
// that means TWO CommandPalette instances (and two ToastHost instances)
// would be alive simultaneously whenever AppShell is shown that way —
// each with its own Ctrl+K Shortcut, competing for the same key. This
// component is meant to eventually BE the real, sole entry point (per
// Main.qml's own top comment: "once Step 2 components are fully signed
// off, this gets replaced by the real AppShell... as the actual app
// entry point") — it isn't that yet. `standalone` (default true) governs
// whether AppShell mounts its own overlay layer at all: true = "I own
// the global overlay" (the eventual real-entry-point case, and the safe
// default for any other future caller); false = "someone above me
// already provides one" (Main.qml's current nested-page case). Using a
// guarded Loader rather than a plain `visible` binding matters here — a
// non-standalone instance mounts NO CommandPalette/ToastHost object at
// all (no Shortcut registration, no CommandRegistry side effects),
// not just an invisible one.

Item {
    id: root

    property bool standalone: true
    property string selectedNavId: "dashboard"

    readonly property var navItems: [
        { id: "dashboard", label: "Dashboard", icon: "home" },
        { id: "projects", label: "Projects", icon: "grid" },
        { id: "tasks", label: "Tasks", icon: "list_bulleted" },
        { id: "settings", label: "Settings", icon: "settings" }
    ]

    Row {
        id: chromeRow
        anchors.fill: parent

        // ---------- Nav rail ----------
        Rectangle {
            id: navRail
            width: 220
            height: parent.height
            color: ThemeManager.backgroundSurface
            border.width: 1
            border.color: ThemeManager.borderDefault

            Column {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: ThemeManager.spacing16

                Repeater {
                    model: root.navItems
                    delegate: NavItem {
                        width: navRail.width
                        iconName: modelData.icon
                        label: modelData.label
                        selected: modelData.id === root.selectedNavId
                        onClicked: root.selectedNavId = modelData.id
                    }
                }
            }
        }

        // ---------- Content area ----------
        Item {
            id: contentArea
            width: parent.width - navRail.width
            height: parent.height

            BackgroundMotif {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }

            AppText {
                anchors.centerIn: parent
                variant: "subtitle"
                text: {
                    for (var i = 0; i < root.navItems.length; i++) {
                        if (root.navItems[i].id === root.selectedNavId)
                            return root.navItems[i].label + " — page not built yet"
                    }
                    return ""
                }
            }
        }
    }

    // ---------- Global overlay layer (only when this AppShell instance
    // owns it — see `standalone` property note above) ----------
    Loader {
        active: root.standalone
        sourceComponent: ToastHost {}
    }

    Loader {
        active: root.standalone
        sourceComponent: CommandPalette { backdropSource: chromeRow }
    }

    Component.onCompleted: {
        CommandRegistry.register("go-projects", "Go to Projects", "Navigation", "grid", "", function() {
            root.selectedNavId = "projects"
        })
        CommandRegistry.register("go-tasks", "Go to Tasks", "Navigation", "list_bulleted", "", function() {
            root.selectedNavId = "tasks"
        })
        CommandRegistry.register("go-settings", "Go to Settings", "Navigation", "settings", "", function() {
            root.selectedNavId = "settings"
        })
        CommandRegistry.register("toggle-theme", "Toggle Light / Dark", "Actions", "sun", "", function() {
            ThemeManager.toggleLightDark()
        })
    }
}
