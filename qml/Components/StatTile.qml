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
// FEATURED VARIANT (backlog 1e, signed off — "Metro-tile-boldness"):
// variant: "featured" swaps the surface for a solid accentPrimary fill.
// Border dropped when featured; label text becomes translucent white.
//
// COUNT-UP (Phase 2 backlog): when `value` changes AND is a plain
// integer string (e.g. "24"), the displayed number animates toward the
// new value over durationSlow (250ms). Currency/formatted strings
// instant-swap (parsing/reformatting mid-animation judged too fragile).
//
// TILE-FLIP (Phase 2 backlog — 4th hover behavior): opt-in via
// `backContent`. See file history / commit log for full technical notes
// on the Scale-transform approach and duration split.
//
// DISPLAY TYPE STEP (Phase 3 typography backlog, lever 1, signed off):
// the hero value now uses Heading's new "display" variant at
// weight: "black" (40px Poppins Black) instead of the old default
// "header" size (24px SemiBold) — the backlog's explicit sign-off was
// "StatTile's hero KPI numbers use Poppins Black, not Plex Sans Bold."
//
// OVERFLOW HANDLING, FLAGGED AS MY OWN ADDITION NOT SPEC-STATED: jumping
// from 24px to 40px Black makes long currency strings (e.g.
// "₹45,00,000") a real risk of overflowing StatTile's fixed 220px
// implicitWidth — the backlog's sign-off only discusses the treatment
// itself, not this width consequence. Added fontSizeMode: Text.HorizontalFit
// with minimumPixelSize: 20 so long values shrink to fit rather than
// clip or overflow, rather than leaving this unhandled. Confirm on-screen
// that a long currency value still reads acceptably at its shrunk size —
// this is a reasonable engineering response to a real constraint, not
// something explicitly reviewed/signed off.
//
// Usage:
//   StatTile { label: "Active Projects"; value: "24" }
//   StatTile { label: "Monthly Revenue"; value: "\u20b945,00,000"; trend: "up"; trendText: "+12% vs last month" }
//   StatTile { label: "Active Projects"; value: "24"; variant: "featured" }
//   StatTile {
//       label: "Active Projects"; value: "24"
//       backContent: Component {
//           AppText { text: "12 completed this month"; anchors.centerIn: parent }
//       }
//   }

Rectangle {
    id: root
    property string label: ""
    property string value: ""
    property string trend: "none"  // "up" | "down" | "none"
    property string trendText: ""
    property string variant: "default"  // "default" | "featured"
    property Component backContent: null

    readonly property bool isFeatured: variant === "featured"
    readonly property bool _isPlainNumeric: /^\d+$/.test(root.value)

    property real _animatedNumber: _isPlainNumeric ? parseInt(root.value) : 0
    Behavior on _animatedNumber {
        enabled: !ThemeManager.reducedMotion
        NumberAnimation {
            duration: ThemeManager.durationSlow
            easing.type: Easing.BezierSpline
            easing.bezierCurve: ThemeManager.easingCurve
        }
    }

    property bool _showingBack: false

    implicitWidth: 220
    implicitHeight: contentColumn.implicitHeight + ThemeManager.spacing16 * 2
    radius: 0
    color: isFeatured ? ThemeManager.accentPrimary : ThemeManager.backgroundSurface
    border.width: isFeatured ? 0 : 1
    border.color: ThemeManager.borderDefault

    transform: Scale {
        id: flipScale
        origin.x: root.width / 2
        origin.y: root.height / 2
        xScale: 1
        yScale: 1
    }

    SequentialAnimation {
        id: flipAnim
        NumberAnimation {
            target: flipScale; property: "xScale"; to: 0
            duration: ThemeManager.durationPanel / 2
            easing.type: Easing.BezierSpline
            easing.bezierCurve: ThemeManager.easingCurve
        }
        ScriptAction { script: root._showingBack = !root._showingBack }
        NumberAnimation {
            target: flipScale; property: "xScale"; to: 1
            duration: ThemeManager.durationPanel / 2
            easing.type: Easing.BezierSpline
            easing.bezierCurve: ThemeManager.easingCurve
        }
    }

    HoverHandler {
        id: hoverHandler
        enabled: root.backContent !== null
        onHoveredChanged: {
            if (root.backContent === null) return
            if (ThemeManager.reducedMotion) {
                root._showingBack = !root._showingBack
            } else {
                flipAnim.start()
            }
        }
    }

    // ---------- Front face ----------
    Column {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: ThemeManager.spacing16
        spacing: ThemeManager.spacing4
        visible: !root._showingBack

        AppText {
            text: root.label
            variant: "caption"
            color: root.isFeatured ? Qt.rgba(1, 1, 1, 0.85) : ThemeManager.textSecondary
        }
        Heading {
            width: contentColumn.width
            variant: "display"
            weight: "black"
            fontSizeMode: Text.HorizontalFit
            minimumPixelSize: 20
            text: root._isPlainNumeric ? Math.round(root._animatedNumber).toString() : root.value
            color: root.isFeatured ? "#FFFFFF" : ThemeManager.textPrimary
        }

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

    // ---------- Back face (opt-in) ----------
    Loader {
        anchors.fill: parent
        anchors.margins: ThemeManager.spacing16
        active: root.backContent !== null && root._showingBack
        sourceComponent: root.backContent
    }
}
