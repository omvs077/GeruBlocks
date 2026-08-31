import QtQuick
import GeruBlocks

// Pagination — Step 8 Navigation
//
// Reuses IconButton.qml (Step 7) for prev/next, with the confirmed-
// existing chevron_left/chevron_right icons — both already verified
// working in this project.
//
// ELLIPSIS WINDOWING FLAGGED, NOT SPEC-STATED: shows first page, last
// page, current page ± 1, and "..." for any gap — a common convention,
// not a stated requirement. Revisit if you want different windowing.
//
// Usage:
//   Pagination {
//       totalPages: 12
//       currentPage: 3
//       onPageChanged: (page) => console.log("Go to page", page)
//   }

Row {
    id: root
    property int totalPages: 1
    property int currentPage: 1
    signal pageChanged(int page)

    spacing: ThemeManager.spacing4

    function _visiblePages() {
        var pages = []
        for (var p = 1; p <= root.totalPages; p++) {
            var isEdge = (p === 1 || p === root.totalPages)
            var isNearCurrent = Math.abs(p - root.currentPage) <= 1
            if (isEdge || isNearCurrent) {
                pages.push(p)
            } else if (pages[pages.length - 1] !== "...") {
                pages.push("...")
            }
        }
        return pages
    }

    IconButton {
        iconName: "chevron_left"
        enabled: root.currentPage > 1
        onClicked: root.pageChanged(root.currentPage - 1)
    }

    Repeater {
        model: root._visiblePages()

        Item {
            id: pageItem
            width: 32
            height: 32

            readonly property bool isEllipsis: modelData === "..."
            readonly property bool isCurrent: !isEllipsis && modelData === root.currentPage

            Rectangle {
                anchors.fill: parent
                radius: 0
                color: pageItem.isCurrent ? ThemeManager.accentPrimary : "transparent"
            }

            Text {
                anchors.centerIn: parent
                text: modelData
                font.family: "Poppins"
                font.pixelSize: 14
                color: pageItem.isCurrent ? "#FFFFFF" : ThemeManager.textPrimary
            }

            MouseArea {
                anchors.fill: parent
                enabled: !pageItem.isEllipsis
                cursorShape: Qt.PointingHandCursor
                onClicked: root.pageChanged(modelData)
            }
        }
    }

    IconButton {
        iconName: "chevron_right"
        enabled: root.currentPage < root.totalPages
        onClicked: root.pageChanged(root.currentPage + 1)
    }
}
