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
// new value over durationSlow (250ms) rather than swapping instantly.
// SCOPE, FLAGGED: currency/formatted strings (e.g. "₹45,00,000") are
// NOT animated — parsing/reformatting Indian-grouped currency text
// mid-animation is fragile, so those instant-swap exactly as before.
// Only plain-integer values get the count-up treatment. Side effect,
// treated as a feature not a bug: since a Behavior animates from a
// property's default (0), a tile mounting for the first time with a
// numeric value will count up from 0 on load — a reasonable "reveal"
// moment for a KPI tile, not something suppressed here.
//
// TILE-FLIP (Phase 2 backlog — 4th hover behavior, Governance Principle
// 3 formally amended per the backlog to cover 4 behaviors now; the
// spec .docx itself is NOT yet updated with this amendment — tracked as
// existing spec-doc debt, not new debt from this change).
// Opt-in via `backContent` (a Component, same slot pattern as Card's
// `footer`) — front face flips away to reveal back content on hover,
// reverses on hover-out. Tiles that don't set backContent behave
// exactly as before; this does NOT replace or interact with 3D-tilt
// (that behavior belongs to other large tiles, not StatTile).
//
// TECHNICAL NOTE: QtQuick's plain `scale` property is UNIFORM (both
// axes together) — Button.qml's press-scale uses it correctly for that
// reason. An X-axis-only "squish" needs a dedicated `Scale` transform
// object instead (see `transform: Scale { ... }` below) — a different
// mechanism, deliberately, not an inconsistency with the rest of the
// codebase's `scale:` usage elsewhere.
//
// DURATION READING, FLAGGED: the backlog states "Duration: duration.panel
// (320ms)" for the whole flip without specifying how it splits across
// the two squish phases. Read here as 320ms TOTAL, split evenly (160ms
// each direction) — a reasonable interpretation, not an explicit spec
// value, confirm if a different split was intended.
//
// REDUCED MOTION: flip becomes an instant content swap, no transform at
// all, per Section 8's explicit "instant... no transforms" allowance.
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
