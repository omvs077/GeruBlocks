import QtQuick
import GeruBlocks

// EmptyState — Step 10 Feedback & Status
//
// ILLUSTRATION (backlog 1f, built together with the background corner
// motif per the backlog's own grouping): useIllustration: true swaps the
// plain placeholder icon for a real Warli-grammar scene
// (empty_state_illustration.svg — a figure beside a hut-shaped building,
// per spec Section 5's own example), rendered larger since a two-element
// scene needs more room to read than a single glyph did. A faint
// BackgroundMotif corner-fan sits behind it, per backlog 1f's second
// placement.
//
// BACKWARD COMPATIBLE: useIllustration defaults to false, so every
// existing EmptyState { iconName: "..." } usage elsewhere is completely
// unchanged — no breaking API change. iconName-based usage still renders
// exactly as before when useIllustration is left at its default.
//
// Usage:
//   EmptyState {
//       iconName: "folder"
//       title: "No projects yet"
//       body: "Create your first project to get started."
//       actionText: "New Project"
//       onActionClicked: createProject()
//   }
//
//   EmptyState {                    // NEW — real illustration instead of a plain icon
//       useIllustration: true
//       title: "No projects yet"
//       body: "Create your first project to get started."
//       actionText: "New Project"
//       onActionClicked: createProject()
//   }

Column {
    id: root
    property string iconName: "folder"
    property bool useIllustration: false
    property string title: ""
    property string body: ""
    property string actionText: ""
    signal actionClicked()

    width: 320
    spacing: ThemeManager.spacing16

    Item {
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.useIllustration ? 120 : 48
        height: root.useIllustration ? 120 : 48

        // Faint corner motif behind the illustration only -- kept out of
        // the plain-icon path so existing usage is visually unchanged.
        BackgroundMotif {
            visible: root.useIllustration
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            size: 80
        }

        Icon {
            anchors.centerIn: parent
            name: root.useIllustration ? "empty_state_illustration" : root.iconName
            size: root.useIllustration ? 96 : 48
            color: ThemeManager.borderStrong
        }
    }

    Column {
        width: parent.width
        spacing: ThemeManager.spacing4

        AppText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.title
            variant: "title"
            visible: root.title !== ""
        }
        AppText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.body
            variant: "body"
            color: ThemeManager.textSecondary
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            width: parent.width
            visible: root.body !== ""
        }
    }

    Button {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.actionText
        variant: "primary"
        visible: root.actionText !== ""
        onClicked: root.actionClicked()
    }
}
