import QtQuick
import GeruBlocks

// Tabs — Step 8 Navigation (v2, redesigned)
//
// v1 read as too plain/flat, cramped, and the thin underline-only
// active state didn't carry enough presence. Changes here:
//   - The tab strip now has its own backgroundSurface fill + 1px
//     border, reading as an actual control rather than floating text
//     over the page background.
//   - More generous sizing: 48px row height, spacing32 horizontal
//     padding per tab, spacing8 between icon and label (up from v1's
//     tighter values).
//   - Active tab: accent-tinted background fill (10% accentPrimary),
//     accent-colored icon/text, and a bold 3px bottom bar that sits
//     flush over the strip's separator line -- the classic "attached
//     tab" read, still fully sharp-cornered, no radius anywhere.
//   - Inactive tabs get a hover background tint, matching the
//     hover-reveal language used elsewhere instead of staying inert
//     until clicked.
//
// STILL HEADER-ONLY: caller swaps actual panel content separately,
// bound to currentIndex -- unchanged from v1.
//
// SCOPE NOTE, FLAGGED, NOT DONE: a single indicator bar that glides
// between tabs (animating to the active tab's live x/width, rather
// than each tab drawing its own static bar) would need geometry
// tracking across Repeater delegates -- real extra engineering, and
// the flavor of cross-item binding complexity that's bitten this
// project before (DatePicker's binding-destruction bug). This version
// is properly designed, just not animated between tabs. Worth doing as
// a follow-up if you want that exact polish.
//
// Usage unchanged:
//   Tabs {
//       id: tabs
//       model: [{ label: "Overview" }, { label: "Details" }]
//   }

Item {
    id: root
    property var model: []  // [{ label, iconName? }]
    property int currentIndex: 0

    implicitWidth: row.implicitWidth
    implicitHeight: 48

    Rectangle {
        anchors.fill: parent
        radius: 0
        color: ThemeManager.backgroundSurface
        border.width: 1
        border.color: ThemeManager.borderDefault
    }

    Row {
        id: row
        height: parent.height
        spacing: 0

        Repeater {
            model: root.model

            Item {
                id: tabItem
                width: tabContent.implicitWidth + ThemeManager.spacing32
                height: root.height

                readonly property bool isActive: index === root.currentIndex

                Rectangle {
                    anchors.fill: parent
                    radius: 0
                    color: {
                        if (tabItem.isActive) {
                            return Qt.rgba(ThemeManager.accentPrimary.r, ThemeManager.accentPrimary.g, ThemeManager.accentPrimary.b, 0.10)
                        }
                        if (hoverArea.containsMouse) return ThemeManager.backgroundPage
                        return "transparent"
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: ThemeManager.durationBase
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: ThemeManager.easingCurve
                        }
                    }
                }

                Row {
                    id: tabContent
                    anchors.centerIn: parent
                    spacing: ThemeManager.spacing8

                    Icon {
                        visible: modelData.iconName !== undefined && modelData.iconName !== ""
                        anchors.verticalCenter: parent.verticalCenter
                        name: modelData.iconName !== undefined ? modelData.iconName : ""
                        size: 16
                        color: tabItem.isActive ? ThemeManager.accentPrimary : ThemeManager.textSecondary
                    }

                    AppText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.label
                        color: tabItem.isActive ? ThemeManager.accentPrimary : ThemeManager.textSecondary
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 3
                    color: ThemeManager.accentPrimary
                    visible: tabItem.isActive
                }

                MouseArea {
                    id: hoverArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.currentIndex = index
                }
            }
        }
    }
}
