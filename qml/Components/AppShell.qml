import QtQuick
import QtQuick.Controls.Basic as Basic
import GeruBlocks

// AppShell — Step 4 Overlays & App Shell (final piece)
//
// The real application scaffold: a persistent left nav rail (built from
// NavItem) plus a swappable content area on the right, with the global
// overlay layer (ToastHost, CommandPalette) mounted once at the root so
// any page loaded into the content area can trigger toasts or use the
// command palette without re-mounting them.
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

Item {
    id: root

    property string selectedNavId: "dashboard"

    readonly property var navItems: [
        { id: "dashboard", label: "Dashboard", icon: "home" },
        { id: "projects", label: "Projects", icon: "grid" },
        { id: "tasks", label: "Tasks", icon: "list_bulleted" },
        { id: "settings", label: "Settings", icon: "settings" }
    ]

    Row {
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

    // ---------- Global overlay layer ----------
    ToastHost {}

    CommandPalette {}

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
