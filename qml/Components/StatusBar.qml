import QtQuick

// Geru Blocks — StatusBar.qml (Step 13)
//
// Left/right slotted bottom bar. Per the handoff doc's Section 5, bug #7 lesson: left and
// right content are each anchored directly to their own edge of the same parent Item —
// never computed by subtracting an estimated sibling width.
//
// Usage:
//   StatusBar {
//       StatusDot { status: "online" }
//       AppText { text: "Connected"; variant: "caption" }
//       rightContent: [
//           AppText { text: "Ln 12, Col 4"; variant: "caption" },
//           AppText { text: "100%"; variant: "caption" }
//       ]
//   }

Item {
    id: root
    default property alias leftContent: leftRow.data
    property alias rightContent: rightRow.data

    width: parent ? parent.width : 400
    height: ThemeManager.spacing24 + ThemeManager.spacing4 // 28px — proposal: no exact existing token for this height

    Rectangle {
        anchors.fill: parent
        color: ThemeManager.backgroundSurface
    }
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 1
        color: ThemeManager.borderDefault
    }

    // Edge margin (spacing16) matches TitleBar/Toolbar/Panel's shared convention — every
    // full-width chrome bar in the system sits 16px off the window edge, no exceptions.
    // Item-to-item spacing (spacing12) is deliberately looser than a button cluster's
    // spacing8 (Toolbar/TitleBar) — status items read as separate small facts, not a
    // tightly-grouped set of actions, so they get more breathing room between them.
    Row {
        id: leftRow
        anchors.left: parent.left
        anchors.leftMargin: ThemeManager.spacing16
        anchors.verticalCenter: parent.verticalCenter
        spacing: ThemeManager.spacing12
    }

    Row {
        id: rightRow
        anchors.right: parent.right
        anchors.rightMargin: ThemeManager.spacing16
        anchors.verticalCenter: parent.verticalCenter
        spacing: ThemeManager.spacing12
    }
}
