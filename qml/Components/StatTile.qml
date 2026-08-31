import QtQuick
import GeruBlocks

// StatTile — Step 11 Data Display ("Stat/KPI tile" in the spec's
// component list)
//
// A single metric card: label, big number, optional trend indicator
// (up/down + delta text). Uses statusSuccess/statusError for the trend
// arrow/text — a legitimate use of those tokens since trend direction
// genuinely IS success/error semantics, not a workaround around the
// locked-color rules.
//
// Big number uses Heading (not AppText) — matches the established type-
// ramp split where Heading owns the 24px/600 "Header" size and AppText
// covers everything from Title down, per Section 3.2's ramp.
//
// Usage:
//   StatTile { label: "Active Projects"; value: "24" }
//   StatTile { label: "Monthly Revenue"; value: "\u20b945,00,000"; trend: "up"; trendText: "+12% vs last month" }

Rectangle {
    id: root
    property string label: ""
    property string value: ""
    property string trend: "none"  // "up" | "down" | "none"
    property string trendText: ""

    implicitWidth: 220
    implicitHeight: contentColumn.implicitHeight + ThemeManager.spacing16 * 2
    radius: 0
    color: ThemeManager.backgroundSurface
    border.width: 1
    border.color: ThemeManager.borderDefault

    Column {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: ThemeManager.spacing16
        spacing: ThemeManager.spacing4

        AppText { text: root.label; variant: "caption"; color: ThemeManager.textSecondary }
        Heading { text: root.value }

        Row {
            visible: root.trend !== "none" && root.trendText !== ""
            spacing: ThemeManager.spacing4

            Text {
                text: root.trend === "up" ? "\u25B2" : "\u25BC"
                font.pixelSize: 10
                color: root.trend === "up" ? ThemeManager.statusSuccess : ThemeManager.statusError
                anchors.verticalCenter: parent.verticalCenter
            }
            AppText {
                text: root.trendText
                variant: "caption"
                color: root.trend === "up" ? ThemeManager.statusSuccess : ThemeManager.statusError
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
