import QtQuick
import GeruBlocks

// EmptyState — Step 10 Feedback & Status
//
// PLACEHOLDER ILLUSTRATION, FLAGGED CLEARLY: spec Section 5 calls for
// a real Warli-grammar illustration scene (e.g. a figure beside a
// hut-shaped building icon) for empty states — that's genuine
// illustration/art work, not a component-architecture task, and
// doesn't exist yet. This uses a single large icon from the existing
// 252-icon set as a stand-in so the component is usable now. Swap
// `iconName` for a real illustration once one exists — this placeholder
// icon is not the finished illustration the spec actually asks for,
// don't mistake it for done.
//
// Usage:
//   EmptyState {
//       iconName: "folder"
//       title: "No projects yet"
//       body: "Create your first project to get started."
//       actionText: "New Project"
//       onActionClicked: createProject()
//   }

Column {
    id: root
    property string iconName: "folder"
    property string title: ""
    property string body: ""
    property string actionText: ""
    signal actionClicked()

    width: 320
    spacing: ThemeManager.spacing16

    Icon {
        anchors.horizontalCenter: parent.horizontalCenter
        name: root.iconName
        size: 48
        color: ThemeManager.borderStrong
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
