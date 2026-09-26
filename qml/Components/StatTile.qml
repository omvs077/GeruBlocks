import QtQuick
import QtQuick.Effects
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
// ELEVATION, ADDED (backlog item — StatTile previously had NO shadow at
// all, unlike Card, which at least had a flagged simplified one). Two
// structural things changed to make a real shadow possible:
//
//   1. root is now a plain Item instead of a Rectangle. A shadow can't
//      be sourced from the same Item it's attached behind — MultiEffect
//      needs a separate sibling Item to read as its `source`, so the
//      visible fill/border/radius that used to live directly on root
//      were moved into a new named child, `tileBg`. Nothing in this
//      file's own public API changes (label/value/trend/trendText/
//      variant/backContent are all custom properties, unaffected) — but
//      FLAG FOR YOU: if anything OUTSIDE this file reads or sets
//      StatTile.color / StatTile.border / StatTile.radius directly
//      (relying on the old Rectangle base type), that call site will
//      break. Worth a project-wide grep for `StatTile {` instances using
//      those properties before treating this as a safe drop-in.
//   2. StatTile previously had no general-purpose hover tracking at all
//      — the only existing HoverHandler is scoped to backContent !== null
//      (it drives the flip). A second, always-enabled HoverHandler was
//      added purely to drive the elevation raise (resting → elevation.2
//      on hover), matching the same hover-raises-elevation precedent
//      already established on Card. FLAGGED AS MY OWN EXTENSION, NOT
//      SPEC-STATED: the spec's elevation.2 token description says
//      "Hover state, dropdowns" without naming StatTile specifically —
//      this reads that as intent-consistent with Card's own precedent
//      rather than a literal instruction, so confirm this is wanted
//      before treating it as locked.
//
// Same blur-normalization caveat as Card.qml applies here — see that
// file's header comment for the full reasoning (elevation*Blur pixel
// tokens divided by 24 and clamped to MultiEffect's 0.0-1.0 shadowBlur
// range; not a verified-correct spec transcription).
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

Item {
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

    // General-purpose hover flag driving elevation only — deliberately
    // separate from the flip-triggering HoverHandler below, since flip
    // is opt-in (backContent !== null) but elevation-on-hover applies to
    // every tile.
    property bool _elevationHovered: false

    // Normalizes a pixel blur-radius token to MultiEffect's 0.0-1.0
    // shadowBlur range. See Card.qml's header comment for full reasoning.
    function _blurNormalized(pixelBlur) {
        return Math.min(pixelBlur / 24, 1.0)
    }

    implicitWidth: 220
    implicitHeight: contentColumn.implicitHeight + ThemeManager.spacing16 * 2

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

    // Elevation-only hover tracking (see file-header ELEVATION note).
    // Always enabled, unlike the flip HoverHandler above.
    HoverHandler {
        id: elevationHoverHandler
        onHoveredChanged: root._elevationHovered = hovered
    }

    // Real blurred drop-shadow, sourced from tileBg. Declared and
    // positioned before tileBg in document order (no explicit z needed,
    // though one is set for robustness against future reordering) so it
    // paints behind the visible surface.
    MultiEffect {
        id: tileShadow
        anchors.fill: tileBg
        source: tileBg
        z: -10
        autoPaddingEnabled: true

        shadowEnabled: true
        shadowColor: "#000000"
        shadowHorizontalOffset: 0

        shadowOpacity: root._elevationHovered ? ThemeManager.elevation2Alpha : ThemeManager.elevation1Alpha
        shadowVerticalOffset: root._elevationHovered ? ThemeManager.elevation2YOffset : ThemeManager.elevation1YOffset
        shadowBlur: root._elevationHovered ? root._blurNormalized(ThemeManager.elevation2Blur)
                                            : root._blurNormalized(ThemeManager.elevation1Blur)

        Behavior on shadowOpacity {
            NumberAnimation {
                duration: ThemeManager.durationBase
                easing.type: Easing.BezierSpline
                easing.bezierCurve: ThemeManager.easingCurve
            }
        }
        Behavior on shadowVerticalOffset {
            NumberAnimation {
                duration: ThemeManager.durationBase
                easing.type: Easing.BezierSpline
                easing.bezierCurve: ThemeManager.easingCurve
            }
        }
        Behavior on shadowBlur {
            NumberAnimation {
                duration: ThemeManager.durationBase
                easing.type: Easing.BezierSpline
                easing.bezierCurve: ThemeManager.easingCurve
            }
        }
    }

    // Visible surface — was previously root's own Rectangle base; moved
    // here so the shadow above has a separate Item to source from. See
    // file-header ELEVATION note, point 1, for the public-API flag.
    Rectangle {
        id: tileBg
        anchors.fill: parent
        radius: 0
        color: root.isFeatured ? ThemeManager.accentPrimary : ThemeManager.backgroundSurface
        border.width: root.isFeatured ? 0 : 1
        border.color: ThemeManager.borderDefault
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
