import QtQuick
import GeruBlocks

// Breadcrumbs — Step 8 Navigation
//
// Uses the confirmed-existing "chevron_right" icon as the separator —
// already verified working in this project, no icon-name uncertainty
// to flag here (unlike the chevron_down situation in Step 7).
//
// Last entry in `model` is treated as the current page: rendered in
// primary text color, not clickable, no trailing separator.
//
// Usage:
//   Breadcrumbs {
//       model: ["Dashboard", "Projects", "Website Redesign"]
//       onCrumbClicked: (index) => console.log("Go to crumb", index)
//   }

Row {
    id: root
    property var model: []  // array of strings
    signal crumbClicked(int index)

    spacing: ThemeManager.spacing4

    Repeater {
        model: root.model

        Row {
            id: crumbRow
            spacing: ThemeManager.spacing4
            readonly property bool isLast: index === root.model.length - 1

            AppText {
                anchors.verticalCenter: parent.verticalCenter
                text: modelData
                color: crumbRow.isLast ? ThemeManager.textPrimary : ThemeManager.accentPrimary

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -4
                    enabled: !crumbRow.isLast
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.crumbClicked(index)
                }
            }

            Icon {
                visible: !crumbRow.isLast
                anchors.verticalCenter: parent.verticalCenter
                name: "chevron_right"
                size: 14
                color: ThemeManager.textSecondary
            }
        }
    }
}
