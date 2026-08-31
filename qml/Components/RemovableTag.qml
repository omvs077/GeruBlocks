import QtQuick
import GeruBlocks

// RemovableTag — Step 11 Data Display ("Removable filter tag/chip" in
// the spec's component list)
//
// Distinct from Badge.qml (Step 2): Badge is a static status/label
// indicator with no interaction; this is specifically for active
// filter state (e.g. "Status: Active ×") with a dismiss action —
// matching Badge's visual language (sharp corners, small text) but
// adding the × affordance Badge deliberately doesn't have.
//
// Usage:
//   RemovableTag { text: "Status: Active"; onRemoved: filters.remove("status") }

Item {
    id: root
    property string text: ""
    signal removed()

    implicitWidth: contentRow.implicitWidth + ThemeManager.spacing12 * 2
    implicitHeight: 28

    Rectangle {
        anchors.fill: parent
        radius: 0
        color: ThemeManager.backgroundPage
        border.width: 1
        border.color: ThemeManager.borderDefault
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: ThemeManager.spacing8

        AppText {
            text: root.text
            variant: "caption"
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: removeGlyph
            text: "\u00D7"
            font.pixelSize: 14
            color: ThemeManager.textSecondary
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                onClicked: root.removed()
            }
        }
    }
}
